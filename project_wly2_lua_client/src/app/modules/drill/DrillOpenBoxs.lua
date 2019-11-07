local DrillOpenBoxs = class("DrillOpenBoxs", require('app.base.PopupBase'))
local EquipItem = require("app.modules.common.EquipItem")

DrillOpenBoxs.RESOURCE_FILENAME = "drill/DrillOpenBoxs.csb"
DrillOpenBoxs.RESOURCE_BINDING = {
    ["Button_12"]                             = {["varname"] = "_btnBack"},
    ["Button_13"]                             = {["varname"] = "_btnOk"},
    ["times_txt"]                             = {["varname"] = "_txtTimes"},
    ["ScrollView_1"]                          = {["varname"] = "_scrollView"},
    ["cost_txt"]                              = {["varname"] = "_txtCost"},
    ["cost_img"]                              = {["varname"] = "_imgCost"},
    ["Image_1"]                               = {["varname"] = "_imgBg"},
    ["Image_7"]                               = {["varname"] = "_imgTitle"},
    ["Node_3"]                                = {["varname"] = "_nodeEffect"},
    ["Text_6"]                                = {["varname"] = "_txtTitle"},
    ["Node_7"]                                = {["varname"] = "_nodePanel"},
    ["Node_6"]                                = {["varname"] = "_nodeTips"},
    ["Node_5"]                                = {["varname"] = "_nodeButtons"},
}

function DrillOpenBoxs:ctor(name, param)
    param._isStopAction = true
    DrillOpenBoxs.super.ctor(self, name, param)
    self._data = param.data or {}
    self._cardId = self._data.id or 0
    self._isLast = self._data.is_last
    self._reward = self._data.reward or {}
end

function DrillOpenBoxs:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self:adaptBgSize()

    self._getRewardNum = 0
    self._canOpenBoxs = false
    self._allNum = StaticData['drill_ground'].Info[1].boxTimesLimit or 1
    self._timesCostTab = StaticData['drill_ground'].Cost or {}
    self._btnBack:addClickEventListenerWithSound(function ()
        if self._isLast then
            network:sendPacket(Protocol.C_2_S_DRILL_GROUND_END, {})
        end
        self:disposeSelf()
    end)
    self._btnOk:addClickEventListenerWithSound(function ()
        if self._allNum - self._getRewardNum <= 0 then
            uq.fadeInfo(StaticData['local_text']['drill.reward.cannot.open.chances'])
            return
        end
        if not self._canOpenBoxs then
            uq.fadeInfo(StaticData["local_text"]["label.common.not.enough.gold"])
            return
        end
        network:sendPacket(Protocol.C_2_S_DRILL_GROUND_REWARD, {id = self._cardId})
        self._btnOk:setTouchEnabled(false)
    end)
    self:refreshLayer()
    self:addRewardShow()
    self:runOpenAction()
    self._onEventReward = "_onEventReward" .. tostring(self)
    self._onEventCardChange = "_onEventCardChange" ..tostring(self)
    network:addEventListener(Protocol.S_2_C_DRILL_GROUND_REWARD, handler(self, self._onGroundReward), self._onEventReward)
    services:addEventListener(services.EVENT_NAMES.ON_DRILL_CARD_CHANGE, handler(self, self.refreshLayer), self._onEventCardChange)
end

function DrillOpenBoxs:addRewardShow()
    local ox = 100
    local arr_rewards = uq.RewardType:getRewardByDrop(self._reward)
    for i, v in pairs(arr_rewards) do
        local item = EquipItem:create()
        item:setTouchEnabled(true)
        local size = item:getContentSize()
        item:setPosition(cc.p((i - 0.5) * size.width + 10, size.height / 2))
        item:setInfo(v)
        item:addClickEventListenerWithSound(function(sender)
                local info = sender:getEquipInfo()
                uq.showItemTips(info)
                end)
        self._scrollView:addChild(item)
    end
    self._scrollView:setInnerContainerSize(cc.size(#arr_rewards * ox, ox))
    self._scrollView:setScrollBarEnabled(false)
end

function DrillOpenBoxs:refreshLayer()
    self._txtTimes:setString(self._allNum - self._getRewardNum .. "/" .. self._allNum)
    if self._allNum - self._getRewardNum <= 0 then
        self._canOpenBoxs = false
        return
    end
    local cost = self:getCostStrByTimes(self._getRewardNum + 1)
    if cost == "" then
        self._canOpenBoxs = true
        self._txtCost:setString(StaticData['local_text']['ancient.city.shop.refresh.free'])
    else
        local reward = uq.RewardType:create(cost):toEquipWidget()
        self._canOpenBoxs = uq.cache.role:checkRes(reward.type, reward.num, reward.id)
        self._txtCost:setString(tostring(reward.num))
        local info_award = StaticData.getCostInfo(reward.type, reward.id)
        if info_award.miniIcon and info_award.miniIcon ~= "" then
            self._imgCost:loadTexture("img/common/item/" .. info_award.miniIcon)
        end
    end
end

function DrillOpenBoxs:_onGroundReward(msg)
    self._getRewardNum = self._getRewardNum + 1
    self:refreshLayer()
    uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, {rewards = msg.data.rewards})
    self._btnOk:setTouchEnabled(true)
end

function DrillOpenBoxs:getCostStrByTimes(times)
    local str = ""
    for i, v in ipairs(self._timesCostTab) do
        if v.ident == times then
            return v.cost
        end
        str = v.cost
    end
    return str
end

function DrillOpenBoxs:runOpenAction()
    local delta = 1 / 12
    local pre_pos = self._imgBg:getPositionX()
    self._imgBg:setVisible(true)
    self._imgBg:setPositionX(pre_pos + 1000)
    self._imgBg:runAction(cc.MoveBy:create(delta * 3, cc.p(-1000, 0)))

    self._imgTitle:runAction(cc.Sequence:create(cc.DelayTime:create(delta * 2), cc.CallFunc:create(function()
        self._imgTitle:setVisible(true)
        uq:addEffectByNode(self._imgTitle, 900144, 1, true, cc.p(310, 43))
        uq:addEffectByNode(self._nodeEffect, 900145, -1, true)
        uq.playSoundByID(104)
    end)))

    local index = 1
    uq.TimerProxy:addTimer('run_open_action' .. tostring(self), function()
        if index == 1 then
            uq:addEffectByNode(self._txtTitle, 900024, 1, true, cc.p(128.5, 20))
        elseif index == 3 then
            self._scrollView:setClippingEnabled(true)
            self._nodePanel:setOpacity(0)
            self._nodePanel:runAction(cc.FadeIn:create(delta * 4))
        elseif index == 4 then
            self._nodeTips:setVisible(true)
        elseif index == 5 then
            local pre_pos_y = self._nodeButtons:getPositionY()
            self._nodeButtons:setPositionY(pre_pos_y - 100)
            self._nodeButtons:setVisible(true)
            self._nodeButtons:runAction(cc.MoveBy:create(delta * 2, cc.p(0, 100)))
        end
        index = index + 1
    end, delta, 5)
end

function DrillOpenBoxs:dispose()
    network:removeEventListenerByTag(self._onEventReward)
    uq.TimerProxy:removeTimer('run_open_action' .. tostring(self))
    services:removeEventListenersByTag(self._onEventCardChange)
    DrillOpenBoxs.super.dispose(self)
end

return DrillOpenBoxs