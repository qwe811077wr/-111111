local AreanWinModule = class("AreanWinModule", require('app.base.PopupBase'))

AreanWinModule.RESOURCE_FILENAME = "instance/InstanceWinView.csb"
AreanWinModule.RESOURCE_BINDING = {
    ["Panel_1"]        = {["varname"] = "_panelBg"},
    ["Button_replay"]  = {["varname"] = "_btnReplay", ["events"] = {{["event"] = "touch", ["method"] = "onReplay"}}},
    ["Button_share"]   = {["varname"] = "_btnShare", ["events"] = {{["event"] = "touch", ["method"] = "onShare"}}},
    ["Button_confirm"] = {["varname"] = "_btnConfirm", ["events"] = {{["event"] = "touch", ["method"] = "onConfirm"}}},
    ["node_soldier"]   = {["varname"] = "_nodeSoldier"},
    ["node_battle"]    = {["varname"] = "_nodeBattle"},
    ["node_arena"]     = {["varname"] = "_nodeArean"},
    ["Node_1"]         = {["varname"] = "_nodeEffect1"},
    ["Node_2"]         = {["varname"] = "_nodeEffect2"},
    ["img_arrow"]      = {["varname"] = "_imgArrow"},
    ["Text_7"]         = {["varname"] = "_txtCurRank"},
    ["Text_6"]         = {["varname"] = "_txtNoChange"},
    ["Text_5"]         = {["varname"] = "_txtRankChange"},
    ["Node_3"]         = {["varname"] = "_nodeRank"},
    ["Text_3"]         = {["varname"] = "_txtTitle"},
}

function AreanWinModule:ctor(name, params)
    AreanWinModule.super.ctor(self, name, params)
    self._data = params.base_data
    self._callback = params.callback
    self._report = params.report
    self._rewards = self._data.rewards
    self._desTitle = params.text
end

function AreanWinModule:onCreate()
    AreanWinModule.super.onCreate(self)
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self._panelBg:setContentSize(display.size)
    self._nodeBattle:setVisible(false)
    self._nodeSoldier:setVisible(false)

    self._aniAction = cc.CSLoader:createTimeline("instance/InstanceWinView.csb")
    self:runAction(self._aniAction)
    self._aniAction:setFrameEventCallFunc(function(frame)
        self:animationEvent(frame)
    end)
    self._aniAction:gotoFrameAndPlay(0, false)
end

function AreanWinModule:animationEvent(frame)
    local str = frame:getEvent()
    if str == 'effect1' then
        uq:addEffectByNode(self._nodeEffect1, 900139, 1, false, cc.p(-5, 0), nil, 2)
    elseif str == 'effect2' then
        uq:addEffectByNode(self._nodeEffect1, 900141, -1, false, cc.p(10, 50), nil, 1)
    elseif str == 'effect4' then
        uq:addEffectByNode(self._nodeEffect1, 900140, -1, false, cc.p(23, -23), nil, 2)
    elseif str == 'effect9' then
        uq:addEffectByNode(self._txtTitle, 900024, 1, false, cc.p(50, 20), nil, 1)
    elseif str == 'effect10' then
        uq:addEffectByNode(self._nodeArean:getChildByName("Node_3"):getChildByName('Text_7'), 900024, 1, false, cc.p(50, 20), nil, 1)
    end
end

function AreanWinModule:init()
    self._txtNoChange:setVisible(self._data.rank_diff == 0)
    self._btnReplay:setVisible(not self._data.isAthleticSweep)
    self._btnShare:setVisible(not self._data.isAthleticSweep)

    self._nodeItem = self._nodeArean:getChildByName('node_reward_0')
    if self._rewards then
        local rwds = ''
        for i = 1, #self._rewards do
            local rwd_str = string.format('%d;%d;%d', self._rewards[i].type, self._rewards[i].num, self._rewards[i].paraml)
            rwds = rwds .. rwd_str
            if i ~= #self._rewards then
                rwds = rwds .. '|'
            end
        end

        local reward_items = uq.RewardType.parseRewards(rwds)
        local reward_node, total_width = uq.rewardToGrid(reward_items, 20, 'instance.DropItem', true)
        reward_node:setPositionX(-total_width / 2)
        self._nodeItem:addChild(reward_node)
        self._nodeItem:setScale(0.7)
    end

    uq.playSoundByID(58)
    self._imgArrow:setVisible(self._data.rank_diff > 0)
    self._txtCurRank:setString(self._data.new_rank)
    if self._data.rank_diff > 0 then
        self._txtRankChange:setString(self._data.rank_diff)
    end

    if self._desTitle then
        self._txtTitle:setString(self._desTitle)
    end
end

function AreanWinModule:dispose()
    AreanWinModule.super.dispose(self)
    uq.TimerProxy:removeTimer(self._addBarTag)
    uq.ModuleManager:getInstance():dispose(uq.ModuleManager.SINGLE_BATTLE_MODULE)
end

function AreanWinModule:onReplay(event)
    if event.name ~= "ended" then
        return
    end
    self._isReplay = true
    uq.runCmd('enter_single_battle_report', {self._report, handler(self, self._onPlayReportEnd)})
end

function AreanWinModule:_onPlayReportEnd(report)
    if self._callback then
        self._callback(report)
    end
end

function AreanWinModule:onShare(event)
    if event.name ~= "ended" then
        return
    end
    local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.BATTLE_REPORT_SHARE)
    panel:setReportInfo(self._report, self._rewards)
end

function AreanWinModule:onConfirm(event)
    if event.name ~= "ended" then
        return
    end
    self:disposeSelf()
end
return AreanWinModule