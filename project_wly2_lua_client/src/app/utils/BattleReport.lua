local BattleReport = class('BattleReport')

BattleReport.S_INSTANCE = nil

BattleReport.TYPE_TEAM = 1
BattleReport.TYPE_PERSONAL = 2

BattleReport.ACTION_SIDE_ATK = 1
BattleReport.ACTION_SIDE_DEF = 2
BattleReport.ACTION_SIDE_ROUND = 5
BattleReport.ACTION_SIDE_OVER = 99

BattleReport.ACTION_TYPE_ATK = 1
BattleReport.ACTION_TYPE_HURT = 2
BattleReport.ACTION_TYPE_BUFF = 3
BattleReport.ACTION_TYPE_MORALE = 4
BattleReport.ACTION_TYPE_RELIVE = 5

function BattleReport:ctor()
    self._queue = {}
    self._httpDownloader = uq.HttpDownload:create()
    local listener = cc.EventListenerCustom:create(self._httpDownloader:eventName(), handler(self, self._onHttpEvent))
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)
    self._scheduled = false

    cc.FileUtils:getInstance():createDirectory(uq.config.battle_report_path)
end

function BattleReport:getInstance()
    if not BattleReport._INSTANCE then
        BattleReport._INSTANCE = BattleReport:create()
    end
    return BattleReport._INSTANCE
end

function BattleReport:load(addr, report_id, cb, type, is_zip)
    if is_zip == nil  then
        is_zip = true
    end
    table.insert(self._queue, {['addr'] = addr, ['cb'] = cb, ['report_id'] = report_id, ['type'] = type, ['is_zip'] = is_zip})
    if #self._queue == 1 then
        self:_scheduleLoading()
    end
end

function BattleReport:_scheduleLoading()
    if #self._queue == 0 then
        return
    end
    local item = self._queue[1]
    local path = uq.config.battle_report_path .. item.report_id
    self._httpDownloader:downloadFile(item.addr, path, item.report_id)
end

function BattleReport:_onHttpEvent(evt)
    local item = self._queue[1]
    if evt:getEventCode() ~= 1 then
        table.remove(self._queue, 1)
        local report = nil
        if evt:getEventCode() == 0 then
            local path = uq.config.battle_report_path .. item.report_id
            local data = uq.ProtocolPacket:new()
            if data:readReportData(path, item.is_zip) then
                if item.type == BattleReport.TYPE_PERSONAL then
                    report = self:_parsePersonalReport(data)
                elseif item.type == BattleReport.TYPE_TEAM then
                    report = self:_parseTeamReport(data)
                end
            end
        end
        if not pcall(item.cb, item.report_id, report) then
            print(debug.traceback())
        end
        self:_scheduleLoading()
    end
end

function BattleReport:_parsePersonalReport(packet)
    local report = {}
    report.battle_type = packet:readChar()
    report.major_version = packet:readChar()
    report.minor_version = packet:readChar()
    local head_len = packet:readShort()
    local skip_head = head_len - 5
    for i = 1, skip_head do
        packet:readChar()
    end
    local function read_battle_object(pp)
        local bo = {}
        local len = pp:readShort()
        bo.name = pp:readString(len)
        bo.level = pp:readShort()
        bo.master_skill = pp:readShort()
        bo.formation_id = pp:readChar()
        bo.img_type = pp:readShort()
        bo.img_id = pp:readInt()
        bo.country_id = pp:readShort()
        bo.general_num = pp:readChar()
        bo.generals = {}
        for i = 0, bo.general_num - 1 do
            local general = {}
            general.idx = i
            general.pos = pp:readChar()
            general.id = pp:readInt()
            general.skill_id = pp:readInt()
            general.level = pp:readShort()
            local len = pp:readShort()
            general.name = pp:readString(len)
            general.soldier_id = pp:readShort()
            general.skill_level = pp:readShort()
            general.max_soldier_num = pp:readInt()
            general.cur_soldier_num = pp:readInt()
            bo.generals[general.pos] = general
        end
        return bo
    end
    report.atker = read_battle_object(packet)
    report.defenser = read_battle_object(packet)
    report.rounds = {}
    local round = {}
    round.objects = {}
    local actions = {}
    local round_num = 1
    while true do
        local side = packet:readChar()
        if side == 0 then
            table.insert(round.objects, actions)
            actions = {}
        elseif side == BattleReport.ACTION_SIDE_ROUND then
            round.round = packet:readChar()
            round_num = round.round + 1
            table.insert(report.rounds, round)
            round = {}
            round.objects = {}
        elseif side == BattleReport.ACTION_SIDE_OVER then
            break
        else
            local action = {}
            action.side = side
            action.targets = {}
            action.action = packet:readChar()
            if action.action == BattleReport.ACTION_TYPE_ATK then
                local g = {}
                g.pos = packet:readChar()
                g.skill_id = packet:readInt()
                g.effect = packet:readChar() --1 暴击, 2 反击， 3 暴击和反击
                table.insert(action.targets, g)
            elseif action.action == BattleReport.ACTION_TYPE_HURT then
                local num = packet:readChar()
                for i = 1, num do
                    local g = {}
                    g.pos = packet:readChar()
                    g.hurt = packet:readInt()
                    table.insert(action.targets, g)
                end
            elseif action.action == BattleReport.ACTION_TYPE_BUFF then
                local buff = {}
                buff.type = packet:readChar()
                buff.state = packet:readChar()
                local num = packet:readChar()
                buff.poses = {}
                for i = 1, num do
                    table.insert(buff.poses, packet:readChar())
                end
                table.insert(action.targets, buff)
            elseif action.action == BattleReport.ACTION_TYPE_MORALE then
                local num = packet:readChar()
                for i = 1, num do
                    local g = {}
                    g.pos = packet:readChar()
                    g.morale = packet:readShort()
                    table.insert(action.targets, g)
                end
            elseif action.action == BattleReport.ACTION_TYPE_RELIVE then
                local g = {}
                g.pos = packet:readChar()
                g.hurt = packet:readInt()
                table.insert(action.targets, g)
            end
            table.insert(actions, action)
        end
    end
    if #actions > 0 then
        table.insert(round.objects, actions)
    end
    if #round.objects > 0 then
        round.round = round_num
        table.insert(report.rounds, round)
    end
    report.result = packet:readShort()
    local num = packet:readChar()
    report.atker.left_generals = {}
    for i = 1, num do
        local g = {}
        g.pos = packet:readChar()
        g.cur_soldier_num = packet:readInt()
        table.insert(report.atker.left_generals, g)
    end
    report.defenser.left_generals = {}
    num = packet:readChar()
    for i = 1, num do
        local g = {}
        g.pos = packet:readChar()
        g.cur_soldier_num = packet:readInt()
        table.insert(report.defenser.left_generals, g)
    end
    return report
end

function BattleReport:_parseTeamReport(packet)
    local report = {}
    local report_num = packet:readChar()
    report.battle_type = packet:readChar()
    print(report_num)
    local function readSide(pp)
        local len = pp:readShort()
        local side = {}
        side.name = pp:readString(len)
        local num = pp:readChar()
        side.players = {}
        for i = 1, num do
            local player = {}
            len = pp:readShort()
            player.name = pp:readString(len)
            player.win_num = pp:readChar()
            player.inspire_atk_lvl = pp:readChar()
            player.inspire_def_lvl = pp:readChar()
            table.insert(side.players, player)
        end
        return side
    end
    report.atker = readSide(packet)
    report.defenser = readSide(packet)
    report.reports = {}
    for i = 1, report_num do
        local r = {}
        r.atk_idx = packet:readChar()
        r.def_idx = packet:readChar()
        r.report_id = packet:readLLongString()
        table.insert(report.reports, r)
    end
    report.result = packet:readChar()
    return report
end

function BattleReport:showBattleReport(report_id, end_callback, battle_reward, battle_type, bg_path)
    self._battleReward = battle_reward or {}
    self._battleEndCallback = end_callback
    self._battleBg = bg_path
    battle_type = battle_type or uq.BattleReport.TYPE_PERSONAL

    local win_panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.NPC_WIN_MODULE)
    local lost_panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.NPC_LOST_MODULE)

    local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.SINGLE_BATTLE_MODULE)
    if panel and (not win_panel and not lost_panel) then
        return
    end

    local addr = uq.cache.nodes:getReportAddress(report_id)
    uq.BattleReport:getInstance():load(addr, report_id, handler(self, self._reportLoaded), battle_type)
end

function BattleReport:_reportLoaded(report_id, report)
    if not report then
        return
    end
    report.report_id = report_id

    local value_cache = cc.UserDefault:getInstance():getStringForKey(uq.cache.role:getUnipeKey(uq.config.constant.ROLE_SETTING.SET_REPORT), "off")
    if value_cache == 'on' then
        self:_onPlayReportEnd(report)
    else
        uq.runCmd('enter_single_battle_report', {report, handler(self, self._onPlayReportEnd), self._battleBg})
        services:dispatchEvent({name = services.EVENT_NAMES.ON_CLOSE_ARRANGED_BEFORE})
    end
end

function BattleReport:_onPlayReportEnd(report)
    if self._battleEndCallback then
        self._battleEndCallback(report)
    end
end

function BattleReport:showBattleResult(report)
    if not report then
        return
    end
    if report.result > 0 then
        local data = {rewards = self._battleReward, report = report}
        uq.ModuleManager:getInstance():show(uq.ModuleManager.NPC_WIN_MODULE, data)
    else
        local data = {report = report}
        uq.ModuleManager:getInstance():show(uq.ModuleManager.NPC_LOST_MODULE, data)
    end
end

function BattleReport:replayReport(report, battle_reward)
    if not report then
        return
    end
    self._battleReward = battle_reward or {}
    uq.runCmd('enter_single_battle_report', {report, handler(self, self._onPlayReportEnd), report.bg_path})
end

function BattleReport:shareReport(report, channel, is_atk, rewards)
    local enemy = {
        player_name = report.defenser.name,
        img_type = report.defenser.img_type,
        img_id = report.defenser.img_id,
        country_id = report.defenser.country_id,
    }

    local ower = {
        player_name = report.atker.name,
        img_type = report.atker.img_type,
        img_id = report.atker.img_id,
        country_id = report.atker.country_id,
    }
    local info = {
        is_atk = is_atk,
        result = report.result,
        report_id = report.report_id,
        enemy = enemy,
        ower = ower,
        rewards = rewards,
        bg_path = report.bg_path,
    }
    if StaticData['instance'][report.instance_id] then
        info.map_name = StaticData['instance'][report.instance_id].name
    end
    local content = json.encode(info)
    local data = {
        channel = channel,
        content_type = uq.config.constant.TYPE_CHAT_CONTENT.CCT_CHAT_BATTLE_SHARE,
        content = content
    }
    uq.sendShareMsg(data)
end

uq.BattleReport = BattleReport