local NPCDrillWinModule = class("NPCDrillWinModule", require('app.base.PopupBase'))

NPCDrillWinModule.RESOURCE_FILENAME = "instance/InstanceWinView.csb"
NPCDrillWinModule.RESOURCE_BINDING = {
    ["Panel_1"]        = {["varname"] = "_panelBg"},
    ["Button_replay"]  = {["varname"] = "_btnReplay", ["events"] = {{["event"] = "touch", ["method"] = "onReplay"}}},
    ["Button_share"]   = {["varname"] = "_btnShare", ["events"] = {{["event"] = "touch", ["method"] = "onShare"}}},
    ["Button_confirm"] = {["varname"] = "_btnConfirm", ["events"] = {{["event"] = "touch", ["method"] = "onConfirm"}}},
    ["node_soldier"]   = {["varname"] = "_nodeSoldier"},
    ["node_battle"]    = {["varname"] = "_nodeBattle"},
    ["node_arena"]     = {["varname"] = "_nodeArean"},
    ["Node_1"]         = {["varname"] = "_nodeEffect1"},
    ["Node_2"]         = {["varname"] = "_nodeEffect2"},
}

function NPCDrillWinModule:ctor(name, params)
    NPCDrillWinModule.super.ctor(self, name, params)
    self._rewards = params.rewards
    self._report = params.report
    self._data = params.data
end

function NPCDrillWinModule:onCreate()
    NPCDrillWinModule.super.onCreate(self)
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self._panelBg:setContentSize(display.size)
    self._nodeBattle:setVisible(false)
    self._nodeSoldier:setVisible(true)
    self._nodeArean:setVisible(false)

    self._aniAction = cc.CSLoader:createTimeline("instance/InstanceWinView.csb")
    self:runAction(self._aniAction)
    self._aniAction:setFrameEventCallFunc(function(frame)
        self:animationEvent(frame)
    end)
    self._aniAction:gotoFrameAndPlay(0, false)
end

function NPCDrillWinModule:animationEvent(frame)
    local str = frame:getEvent()
    if str == 'effect1' then
        uq:addEffectByNode(self._nodeEffect1, 900139, 1, false, cc.p(-5, 0), nil, 2)
    elseif str == 'effect2' then
        uq:addEffectByNode(self._nodeEffect1, 900141, -1, false, cc.p(10, 50), nil, 1)
    elseif str == 'effect4' then
        uq:addEffectByNode(self._nodeEffect1, 900140, -1, false, cc.p(-10, 113), nil, 2)
    elseif str == 'effect9' then
        uq:addEffectByNode(self._nodeSoldier:getChildByName('title_desc'), 900024, 1, false, cc.p(50, 20), nil, 1)
    elseif str == 'effect10' then
        uq:addEffectByNode(self._nodeSoldier:getChildByName('title_desc_0'), 900024, 1, false, cc.p(50, 20), nil, 1)
    elseif str == 'effect11' then
        uq:addEffectByNode(self._nodeSoldier:getChildByName('title_desc_0_0'), 900024, 1, false, cc.p(50, 20), nil, 1)
    end
end

function NPCDrillWinModule:init()
    local left_num = 0
    local lost_num = 0
    for k, item in pairs(self._report.atker.left_generals) do
        left_num = left_num + item.cur_soldier_num
    end
    for k, item in pairs(self._report.atker.generals) do
        lost_num = lost_num + item.cur_soldier_num
    end
    lost_num = lost_num - left_num
    self._txtLeftSoldier = self._nodeSoldier:getChildByName('left_soldier_txt')
    self._txtLostSoldier = self._nodeSoldier:getChildByName('lost_soldier_txt')
    self._nodeItem = self._nodeSoldier:getChildByName('node_reward')
    self._expAddBar = self._nodeSoldier:getChildByName('load_add')
    self._txtAdd = self._nodeSoldier:getChildByName('txt_soldier_add')
    self._expBar = self._nodeSoldier:getChildByName('load_soldier')
    self._txtPrecent = self._nodeSoldier:getChildByName('txt_soldier_desc')
    self._txtLvl = self._nodeSoldier:getChildByName('txt_soldier_level')
    self._txtLeftSoldier:setString(uq.formatResource(left_num, true))
    self._txtLostSoldier:setString(uq.formatResource(lost_num, true))

    self._nodeSoldier:getChildByName('num_add_3'):setString(self._data.add_exp)
    local id = uq.cache.drill:getDrillIdOperation()
    local data = uq.cache.drill:getDrillInfoById(id)
    local add = StaticData['drill_ground'].DrillGround[id].Mode[data.cur_mode].expUp
    self._nodeSoldier:getChildByName('num_add_2'):setString(add * 100 .. '%')
    self._nodeSoldier:getChildByName('num_add_1'):setString(self._data.add_exp / add)

    self._nodeItem = self._nodeSoldier:getChildByName('node_reward')
    if self._rewards then
        local reward_items = uq.RewardType.parseRewards(self._rewards)
        local reward_node, total_width = uq.rewardToGrid(reward_items, 20, 'instance.DropItem', true)
        reward_node:setPositionX(-total_width / 2)
        self._nodeItem:addChild(reward_node)
        self._nodeItem:setScale(0.7)
    end


    if self._data.exp > StaticData['drill_ground'].GroundLevel[self._data.level].exp then
        self._txtPrecent:setString(self._data.exp .. '/' .. StaticData['drill_ground'].GroundLevel[self._data.level].exp)
        self._txtLvl:setString(self._report.drill_tile .. StaticData['local_text']['label.common.level'] .. 'Lv.' .. self._data.level)
        self._expAddBar:setPercent(0)
        self._expBar:setPercent(100)
        self._txtAdd:setString(self._data.add_exp)
        return
    end

    local pre_exp = 0
    local pre_total_exp = 0
    if self._data.exp < self._data.add_exp then
        self._preLevel = self._data.level - 1
        pre_total_exp = StaticData['drill_ground'].GroundLevel[self._preLevel].exp
        local exp = self._data.add_exp - self._data.exp

        while math.floor(exp) > math.floor(pre_total_exp) do
            exp = exp - pre_total_exp
            self._preLevel = self._preLevel - 1
            pre_total_exp = StaticData['drill_ground'].GroundLevel[self._preLevel].exp
        end

        pre_exp = pre_total_exp - exp
        self._expAddBar:setPercent(100)
    else
        self._preLevel = self._data.level
        pre_total_exp = StaticData['drill_ground'].GroundLevel[self._preLevel].exp
        pre_exp = self._data.exp - self._data.add_exp
        self._expAddBar:setPercent(self._data.exp / pre_total_exp * 100)
    end
    self._txtLvl:setString(self._report.drill_tile .. StaticData['local_text']['label.common.level'] .. 'Lv.' .. self._preLevel)
    self._txtAdd:setString('+' .. self._data.add_exp)
    local id = uq.cache.drill:getDrillIdOperation()
    self._expBar:setPercent(pre_exp / pre_total_exp * 100)
    self._txtPrecent:setString(pre_exp .. '/' .. pre_total_exp)

    local delta = self._data.add_exp / 10
    self._addBarTag = "_add_loading_bar" .. tostring(self)
    uq.TimerProxy:removeTimer(self._addBarTag)
    uq.TimerProxy:addTimer(self._addBarTag, function()
        pre_exp = pre_exp + delta
        local integer_pre_exp = math.floor(pre_exp + 0.1)
        self._expBar:setPercent(integer_pre_exp / pre_total_exp * 100)
        self._txtPrecent:setString(integer_pre_exp .. '/' .. pre_total_exp)
        if integer_pre_exp >= pre_total_exp then
            pre_exp = integer_pre_exp - pre_total_exp
            self._preLevel = self._preLevel + 1
            pre_total_exp = StaticData['drill_ground'].GroundLevel[self._preLevel].exp
            integer_pre_exp = pre_exp
            self._txtLvl:setString(self._report.drill_tile .. StaticData['local_text']['label.common.level'] .. 'Lv.' .. self._preLevel)
            self._expBar:setPercent(pre_exp / pre_total_exp * 100)
            if self._preLevel < self._data.level then
                self._expAddBar:setPercent(100)
            else
                self._expAddBar:setPercent(self._data.exp / pre_total_exp * 100)
            end
            self._txtPrecent:setString(pre_exp .. '/' .. pre_total_exp)
        end
        if integer_pre_exp >= self._data.exp and self._preLevel >= self._data.level then
            self._txtAdd:setVisible(false)
            integer_pre_exp = self._data.exp
            uq.TimerProxy:removeTimer(self._addBarTag)
        end
    end, 0.1, 20)

    uq.playSoundByID(58)
end

function NPCDrillWinModule:dispose()
    NPCDrillWinModule.super.dispose(self)
    uq.TimerProxy:removeTimer(self._addBarTag)
    uq.ModuleManager:getInstance():dispose(uq.ModuleManager.SINGLE_BATTLE_MODULE)
end

function NPCDrillWinModule:onReplay(event)
    if event.name == "ended" then
        self._report.is_replay = true
        self._isReplay = true
        uq.BattleReport:getInstance():replayReport(self._report, self._rewards)
    end
end

function NPCDrillWinModule:onShare(event)
    if event.name ~= "ended" then
        return
    end
    local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.BATTLE_REPORT_SHARE)
    panel:setReportInfo(self._report, self._rewards)
end

function NPCDrillWinModule:onConfirm(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end
return NPCDrillWinModule