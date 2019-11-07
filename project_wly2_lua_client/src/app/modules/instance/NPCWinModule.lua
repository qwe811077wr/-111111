local NPCWinModule = class("NPCWinModule", require('app.base.PopupBase'))

NPCWinModule.RESOURCE_FILENAME = 'instance/InstanceWinView.csb'
NPCWinModule.RESOURCE_BINDING = {
    ["Panel_1"]        = {["varname"] = "_panelBg"},
    ["Button_replay"]  = {["varname"] = "_btnReplay", ["events"] = {{["event"] = "touch", ["method"] = "onReplay"}}},
    ["Button_share"]   = {["varname"] = "_btnShare", ["events"] = {{["event"] = "touch", ["method"] = "onShare"}}},
    ["Button_confirm"] = {["varname"] = "_btnConfirm", ["events"] = {{["event"] = "touch", ["method"] = "onConfirm"}}},
    ["node_soldier"]   = {["varname"] = "_nodeSoldier"},
    ["node_battle"]    = {["varname"] = "_nodeBattle"},
    ["node_arena"]     = {["varname"] = "_nodeArean"},
    ["Node_1"]         = {["varname"] = "_nodeEffect1"},
    ["Node_2"]         = {["varname"] = "_nodeEffect2"},
    ["Image_24"]       = {["varname"] = "_imgStarBg"},
}

function NPCWinModule:ctor(name, params)
    NPCWinModule.super.ctor(self, name, params)
    self._rewards = params.rewards
    self._report = params.report
    self._star = self._report.result
end

function NPCWinModule:onCreate()
    NPCWinModule.super.onCreate(self)
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self._panelBg:setContentSize(display.size)
    self._nodeBattle:setVisible(true)
    self._nodeSoldier:setVisible(false)
    self._nodeArean:setVisible(false)

    self._aniAction = cc.CSLoader:createTimeline("instance/InstanceWinView.csb")
    self:runAction(self._aniAction)
    self._aniAction:setFrameEventCallFunc(function(frame)
        self:animationEvent(frame)
    end)
    self._aniAction:gotoFrameAndPlay(0, false)
end

function NPCWinModule:animationEvent(frame)
    local str = frame:getEvent()
    if str == 'effect1' then
        uq:addEffectByNode(self._nodeEffect1, 900139, 1, false, cc.p(-5, 0), nil, 2)
    elseif str == 'effect2' then
        uq:addEffectByNode(self._nodeEffect1, 900141, -1, false, cc.p(10, 50), nil, 1)
    elseif str == 'effect4' then
        uq:addEffectByNode(self._nodeEffect1, 900140, -1, false, cc.p(-10, 113), nil, 2)
    elseif str == 'effect5' then
        uq:addEffectByNode(self._imgStarBg, 900143, 1, false, cc.p(420, 17), nil, 1)
        uq:addEffectByNode(self._nodeBattle:getChildByName('star_1'), 900023, 1, false, cc.p(-40, 5), nil, 1)
    elseif str == 'effect6' then
        uq:addEffectByNode(self._nodeBattle:getChildByName('star_2'), 900023, 1, false, cc.p(-40, 5), nil, 1)
    elseif str == 'effect12' then
        uq:addEffectByNode(self._nodeBattle:getChildByName('star_3'), 900023, 1, false, cc.p(-40, 5), nil, 1)
    elseif str == 'effect7' then
        uq:addEffectByNode(self._nodeBattle:getChildByName('title_desc_0'), 900024, 1, false, cc.p(50, 20), nil, 1)
    elseif str == 'effect8' then
        uq:addEffectByNode(self._nodeBattle:getChildByName('title_desc_0_0'), 900024, 1, false, cc.p(50, 20), nil, 1)
    end
end

function NPCWinModule:init()
    local left_num = 0
    local lost_num = 0
    for k, item in pairs(self._report.atker.left_generals) do
        left_num = left_num + item.cur_soldier_num
    end
    for k, item in pairs(self._report.atker.generals) do
        lost_num = lost_num + item.cur_soldier_num
    end
    lost_num = lost_num - left_num

    for i = 1, 3 do
        self._nodeBattle:getChildByName('star_' .. i):setVisible(i <= self._star)
    end
    self._txtLeftSoldier = self._nodeBattle:getChildByName('left_soldier_txt')
    self._txtLostSoldier = self._nodeBattle:getChildByName('lost_soldier_txt')
    self._nodeItem = self._nodeBattle:getChildByName('node_reward')
    self._txtLeftSoldier:setString(uq.formatResource(left_num, true))
    self._txtLostSoldier:setString(uq.formatResource(lost_num, true))

    local rwds = ''
    if type(self._rewards) == 'string' then
        rwds = self._rewards
    elseif type(self._rewards) == 'table' then
        for i = 1, #self._rewards do
            local rwd_str = string.format('%d;%d;%d', self._rewards[i].type, self._rewards[i].num, self._rewards[i].paraml)
            rwds = rwds .. rwd_str
            if i ~= #self._rewards then
                rwds = rwds .. '|'
            end
        end
    end
    local reward_items = uq.RewardType.parseRewards(rwds)
    local reward_node, total_width = uq.rewardToGrid(reward_items, 20, 'instance.DropItem', true)
    reward_node:setPositionX(-total_width / 2)
    self._nodeItem:addChild(reward_node)
    self._nodeItem:setScale(0.7)

    uq.playSoundByID(58)
end

function NPCWinModule:dispose()
    local is_replay = self._isReplay
    NPCWinModule.super.dispose(self)
    uq.ModuleManager:getInstance():dispose(uq.ModuleManager.SINGLE_BATTLE_MODULE)
    if not is_replay then
        uq.refreshNextNewGeneralsShow(function()
            uq.showRoleLevelUp()
        end)
        uq.cache.instance:checkNewInstance()
        services:dispatchEvent({name = services.EVENT_NAMES.ON_BATTLE_NPC_WIN})
        services:dispatchEvent({name = services.EVENT_NAMES.ON_NEW_INSTANCE})
        services:dispatchEvent({name = services.EVENT_NAMES.ON_SHOW_REWARD})
    end
end

function NPCWinModule:onReplay(event)
    if event.name == "ended" then
        self._report.is_replay = true
        self._isReplay = true
        uq.BattleReport:getInstance():replayReport(self._report, self._rewards)
    end
end

function NPCWinModule:onShare(event)
    if event.name ~= "ended" then
        return
    end
    local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.BATTLE_REPORT_SHARE)
    panel:setReportInfo(self._report, self._rewards)
end

function NPCWinModule:onConfirm(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

return NPCWinModule