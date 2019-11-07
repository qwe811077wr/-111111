local ArenaReportItem = class("ArenaReportItem", require('app.base.ChildViewBase'))
local HeadItem = require('app.modules.arena.AreanHeadItem')

ArenaReportItem.RESOURCE_FILENAME = "arena/ArenaReportItem.csb"
ArenaReportItem.RESOURCE_BINDING = {
    ["Text_2_0_0_0_0"] = {["varname"] = "_txtRankDiff"},
    ["Text_2_0_0_1"]   = {["varname"] = "_txtName"},
    ["Text_2_0_0_0"]   = {["varname"] = "_txtTime"},
    ["Button_1"]       = {["varname"] = "_btnShare",["events"] = {{["event"] = "touch",["method"] = "onShare"}}},
    ["Button_1_0"]     = {["varname"] = "_btnReport",["events"] = {{["event"] = "touch",["method"] = "onReport"}}},
    ["Image_2_0"]      = {["varname"] = "_imgFail"},
    ["Image_2"]        = {["varname"] = "_imgWin"},
    ["Panel_4"]        = {["varname"] = "_panelRole"},
    ["Image_city"]     = {["varname"] = "_imgCity"},
    ["Text_2_0"]       = {["varname"] = "_txtPower"},
    ["Image_12"]       = {["varname"] = "_imgUpArrow"},
    ["Image_12_0"]     = {["varname"] = "_imgDownArrow"},
    ["Image_26"]       = {["varname"] = "_imgSideAtk"},
    ["Image_26_0"]     = {["varname"] = "_imgSideDef"},
}

function ArenaReportItem:onCreate()
    ArenaReportItem.super.onCreate(self)
    self._roleItem = HeadItem:create()
    local size = self._panelRole:getContentSize()
    self._roleItem:setPosition(cc.p(size.width / 2, size.height / 2))
    self._panelRole:addChild(self._roleItem)
end

function ArenaReportItem:setData(data)
    self._data = data
    self._txtRankDiff:setString(math.abs(data.rank_diff))
    self._txtName:setString(data.name)

    local is_atk = self._data.type == uq.config.constant.BATTLE_SIDE_TYPE.BATTLE_ATK
    self._imgSideAtk:setVisible(is_atk)
    self._imgSideDef:setVisible(not is_atk)
    local is_win = (is_atk and data.battle_ret > 0) or (not is_atk and data.battle_ret <= 0)
    self._imgWin:setVisible(is_win)
    self._imgFail:setVisible(not is_win)

    local time_off = uq.cache.server_data:getServerTime() - data.time
    self._txtTime:setString(uq.getTime2(time_off) .. StaticData['local_text']['label.common.before'])
    self._txtPower:setString(data.power)

    local img = uq.cache.role:getCountryImg(data.country_id)
    self._imgCity:loadTexture(img)

    self._imgUpArrow:setVisible(is_atk and data.rank_diff > 0)
    self._imgDownArrow:setVisible(not is_atk and data.rank_diff < 0)
    self._txtRankDiff:setVisible(data.rank_diff ~= 0)
end

function ArenaReportItem:onReport(event)
    if event.name == "ended" then
        local addr = uq.cache.nodes:getReportAddress(self._data.report_id, '')
        uq.BattleReport:getInstance():load(addr, self._data.report_id, handler(self, self._reportLoaded), uq.BattleReport.TYPE_PERSONAL)
    end
end

function ArenaReportItem:onShare(event)
    if event.name ~= "ended" then
        return
    end
    local addr = uq.cache.nodes:getReportAddress(self._data.report_id, '')
    uq.BattleReport:getInstance():load(addr, self._data.report_id, handler(self, self._shareReportLoaded), uq.BattleReport.TYPE_PERSONAL)
end

function ArenaReportItem:_shareReportLoaded(report_id, report)
    if not report then
        return
    end
    report.report_id = report_id
    local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.BATTLE_REPORT_SHARE)
    panel:setReportInfo(report, {})
end

function ArenaReportItem:_reportLoaded(report_id, report)
    if not report then
        return
    end
    uq.runCmd('enter_single_battle_report', {report, handler(self, self._onPlayReportEnd)})
end

function ArenaReportItem:_onPlayReportEnd(report)
    self._data.new_rank = self._data.rank <= 0 and (5000 - self._data.rank_diff) or self._data.rank - self._data.rank_diff
    local data = {base_data = self._data, callback = handler(self, self._onPlayReportEnd), report = report}
    if self._data.battle_ret > 0 and self._data.type == uq.config.constant.BATTLE_SIDE_TYPE.BATTLE_DEF then
        data.text = StaticData['local_text']['athletics.report.result1']
        uq.ModuleManager:getInstance():show(uq.ModuleManager.ARENA_LOST_MODULE, data)
    elseif self._data.battle_ret > 0 and self._data.type == uq.config.constant.BATTLE_SIDE_TYPE.BATTLE_ATK then
        data.text = StaticData['local_text']['athletics.report.result2']
        uq.ModuleManager:getInstance():show(uq.ModuleManager.ARENA_WIN_MODULE, data)
    elseif self._data.battle_ret <= 0 and self._data.type == uq.config.constant.BATTLE_SIDE_TYPE.BATTLE_DEF then
        data.text = StaticData['local_text']['athletics.report.result3']
        uq.ModuleManager:getInstance():show(uq.ModuleManager.ARENA_WIN_MODULE, data)
    else
        data.text = StaticData['local_text']['athletics.report.result4']
        uq.ModuleManager:getInstance():show(uq.ModuleManager.ARENA_LOST_MODULE, data)
    end
end

return ArenaReportItem