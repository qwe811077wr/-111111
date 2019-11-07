local ActivitySign = class("ActivitySign", require('app.base.PopupBase'))
local EquipItem = require("app.modules.common.EquipItem")

ActivitySign.RESOURCE_FILENAME = "activity/ActivitySign.csb"
ActivitySign.RESOURCE_BINDING = {
    ["Node_1/time_txt"]                   = {["varname"] = "_txtTime"},
    ["Node_1/itmes_txt"]                  = {["varname"] = "_txtItems"},
    ["Node_1/Node_2"]                     = {["varname"] = "_nodeItems"},
    ["Node_4/times_txt"]                  = {["varname"] = "_txtTimes"},
    ["Node_4/cost_txt"]                   = {["varname"] = "_txtCost"},
    ["Node_4/Image_7"]                    = {["varname"] = "_imgCost"},
    ["Node_4/Text_1_1_1_0"]               = {["varname"] = "_imgtips"},
    ["Button_1"]                          = {["varname"] = "_btnAgainSign"},
    ["list_pnl"]                          = {["varname"] = "_pnlList"},
    ["icon_spr"]                          = {["varname"] = "_sprIcon"},
    ["Button_2"]                          = {["varname"] = "_btnClose"},
}

function ActivitySign:ctor(name, params)
    ActivitySign.super.ctor(self, name, params)
end

function ActivitySign:init()
    self:centerView()
    self:parseView()
    self:setLayerColor(0.6)
    self._allItems = {}
    self._listData = self:dealData()
    self._surplusTime = uq.cache.achievement:getSurplusTime()
    self:initLayer()
    self:_onUpdateTime()
    self._onEventTime = "_onActivityTime" .. tostring(self)
    uq.TimerProxy:addTimer(self._onEventTime, handler(self, self._onUpdateTime), 1, -1)
    self._signRefresh = services.EVENT_NAMES.ON_ACHIEVEMENT_SIGN .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_ACHIEVEMENT_SIGN, handler(self, self._onSignRefresh), self._signRefresh)

    self._signRefreshAll = services.EVENT_NAMES.ON_ACHIEVEMENT_SIGN_ALL .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_ACHIEVEMENT_SIGN_ALL, handler(self, self.refreshSignLayer), self._signRefresh)
end

function ActivitySign:initLayer()
    for i, v in ipairs(self._listData.Daily) do
        local item = uq.createPanelOnly("activity.SignItems")
        item:setData(v)
        item:setPosition(cc.p(110 * i - 60 , 0))
        self._pnlList:addChild(item)
        table.insert(self._allItems, item)
    end
    self:refreshLayer()
    self._btnAgainSign:addClickEventListenerWithSound(function()
        if uq.cache.achievement:isCanSign() then
            uq.fadeInfo(StaticData["local_text"]["activity.sign.please.sign"])
            return
        end
        local again_num = uq.cache.achievement:getAaginSignTimes()
        if again_num <= 0 then
            uq.fadeInfo(StaticData["local_text"]["activity.sign.not.again"])
            return
        end
        local tab_complement = StaticData['checkin_complement'][uq.cache.achievement:getCanSignId()]
        if not tab_complement or not tab_complement.cost then
            uq.fadeInfo(StaticData["local_text"]["activity.sign.again.error"])
            return
        end
        local reward = uq.RewardType:create(tab_complement.cost)
        if not uq.cache.role:checkRes(reward:type(), reward:num()) then
            uq.fadeInfo(StaticData["local_text"]["label.no.enough.res"])
            return
        end
        network:sendPacket(Protocol.C_2_S_ROLE_CHECKIN, {checkin_type = 1})
    end)
    self._btnClose:addClickEventListenerWithSound(function()
        self:disposeSelf()
    end)
end

function ActivitySign:refreshSignItems()
    for i, v in ipairs(self._allItems) do
        v:setData(self._listData.Daily[i])
    end
end

function ActivitySign:_onSignRefresh(msg)
    local data = msg.data
    local tab = StaticData['checkin'][data.cycle_id]
    if tab and tab.Daily and tab.Daily[data.checkin_id] and tab.Daily[data.checkin_id].reward then
        uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, {rewards = tab.Daily[data.checkin_id].reward})
    end
    self:refreshLayer()
    self:refreshSignItems()
end

function ActivitySign:refreshLayer()
    if not self._listData or next(self._listData) == nil then
        return
    end
    if self._listData.totalReward then
        local tab_reward = uq.RewardType:create(self._listData.totalReward):toEquipWidget()
        local tab_info = StaticData.getCostInfo(tab_reward.type, tab_reward.id)
        if tab_info and tab_info.icon then
            self._sprIcon:setTexture("img/common/item/" .. tab_info.icon)
        end
        self._txtItems:setString(uq.formatResource(tab_reward.num, true))
    end
    if self._listData.Daily then
        local tab_complement = StaticData['checkin_complement'][uq.cache.achievement:getCanSignId()]
        if tab_complement and tab_complement.cost then
            local reward = uq.RewardType:create(tab_complement.cost)
            local info = StaticData.getCostInfo(reward:type(), reward:id())
            local miniIcon = info and info.miniIcon or "03_0002.png"
            self._imgCost:loadTexture('img/common/ui/' .. miniIcon)
            self._txtCost:setString(tostring(reward:num()))
        end
        local can_times = uq.cache.achievement:getAaginSignTimes()
        self._txtTimes:setString(tostring(can_times))
        self._imgCost:setVisible(can_times > 0)
        self._txtCost:setVisible(can_times > 0)
        self._txtTimes:setVisible(can_times > 0)
        self._imgtips:setVisible(can_times > 0)
        self._btnAgainSign:setVisible(can_times > 0)
    end
end

function ActivitySign:_onUpdateTime()
    self._surplusTime = self._surplusTime - 1
    if self._surplusTime < 0 then
        uq.cache.achievement:goToNextSign()
        return
    end
    local day = math.floor(self._surplusTime / 86400)
    local hour = math.floor((self._surplusTime - day * 86400) / 3600)
    local minutes = math.floor((self._surplusTime - day * 86400 - hour * 3600) / 60) + 1
    self._txtTime:setString(string.format(StaticData["local_text"]["activity.sign.surplus.time"], day, hour, minutes))
end

function ActivitySign:refreshSignLayer()
    self._surplusTime = uq.cache.achievement:getSurplusTime()
    if self._surplusTime > 0 then
        self:refreshLayer()
        self:refreshSignItems()
    end
end

function ActivitySign:dealData()
    local idx = uq.cache.achievement:getSignIndex()
    if idx ~= 0 and StaticData['checkin'][idx] and StaticData['checkin'][idx].Daily then
        return StaticData['checkin'][idx]
    end
    return {}
end

function ActivitySign:dispose()
    services:removeEventListenersByTag(self._signRefresh)
    services:removeEventListenersByTag(self._signRefreshAll)
    uq.TimerProxy:removeTimer(self._onEventTime)
    ActivitySign.super.dispose(self)
end

return ActivitySign