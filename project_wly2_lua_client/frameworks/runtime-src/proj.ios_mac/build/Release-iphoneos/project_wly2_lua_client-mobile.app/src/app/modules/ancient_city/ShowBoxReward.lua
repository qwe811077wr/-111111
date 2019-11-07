local ShowBoxReward = class("ShowBoxReward", require('app.base.PopupBase'))
local EquipItem = require("app.modules.common.EquipItem")

ShowBoxReward.RESOURCE_FILENAME = "ancient_city/AncientCityBoxReward.csb"
ShowBoxReward.RESOURCE_BINDING = {
    ["Node_item"]               = {["varname"] = "_itemNode"},
    ["Node_effect"]             = {["varname"] = "_effectNode"},
    ["Panel_1"]                 = {["varname"] = "_panelPress"},
    ["label_des"]               = {["varname"] = "_desLabel"},
    ["Image_8"]                 = {["varname"] = "_imgBox"},
    ["Text_1"]                  = {["varname"] = "_txtTip"},
}

function ShowBoxReward:ctor(name, args)
    ShowBoxReward.super.ctor(self, name, args)
    self._curInfo = args.rewards
end

function ShowBoxReward:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self:initUi()
end

function ShowBoxReward:initUi()
    self._panelPress:setTouchEnabled(true)
    self._imgBox:addClickEventListenerWithSound(function()
        self._imgBox:setTouchEnabled(false)
        self._txtTip:setVisible(false)
        local data = {rewards = uq.RewardType:tabMergeReward(self._curInfo), callBack = handler(self, self.CloseLayer)}
        if uq.cache.ancient_city.city_id ~= 7 and uq.cache.ancient_city.city_id ~= 8 then
            data = {
                rewards = uq.RewardType:tabMergeReward(self._curInfo),
                show_two = true,
                left_txt = StaticData["local_text"]["ancient.box.reward.des"],
                right_txt = StaticData["local_text"]["ancient.box.reward.des2"],
                left_btn_txt = StaticData["local_text"]["label.common.stop"],
                right_btn_txt = StaticData["local_text"]["label.common.continue.fight"],
                left_func = handler(self, self.onBtnExit),
                right_func = handler(self, self.onBtnBattle)
            }
        end
        uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, data)
    end)
    self._itemNode:removeAllChildren()
    self._itemNode:setVisible(false)
    uq:addEffectByNode(self._effectNode, 900049, -1, true, cc.p(0, -30))
end

function ShowBoxReward:_setItemData()
    self._index = self._index + 1
    local item_size = self._itemNode:getContentSize()
    local data = self._curInfo[self._index]
    local info = {}
    info.type = tonumber(data.type)
    info.id = tonumber(data.paraml)
    info.num = tonumber(data.num)
    local euqip_item = EquipItem:create({info = info})
    euqip_item:setPosition(cc.p(0, -240))
    euqip_item:setTouchEnabled(true)
    euqip_item:addClickEventListenerWithSound(function(sender)
        local info = sender:getEquipInfo()
        uq.showItemTips(info)
    end)
    euqip_item:setScale(0.1)
    euqip_item:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3, 1.1), cc.ScaleTo:create(0.2, 1)))
    euqip_item:runAction(cc.MoveTo:create(0.2, cc.p(self._posX, item_size.height * 0.5)))
    self._itemNode:addChild(euqip_item)
    self._posX = self._posX + 130
end

function ShowBoxReward:onBtnExit()
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_ESCAPE, {})
    uq.fadeInfo(StaticData["local_text"]["ancient.city.box.reward.des"])
    uq.runCmd('enter_ancient_city')
    self:disposeSelf()
end

function ShowBoxReward:onBtnBattle()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ANCIENT_CITY_ENTER_SCENE})
    self:disposeSelf()
end

function ShowBoxReward:CloseLayer()
    if uq.cache.ancient_city.city_id == 7 then
        services:dispatchEvent({name = services.EVENT_NAMES.ON_ANCIENT_CITY_ENTER_SCENE})
        if tonumber(uq.cache.ancient_city.secret_info.exists) ~= 1 then --没密室
            services:dispatchEvent({name = services.EVENT_NAMES.ON_ANCIENT_CITY_CLEARANCE_REWARD})
        end
    elseif uq.cache.ancient_city.city_id == 8 then
        services:dispatchEvent({name = services.EVENT_NAMES.ON_ANCIENT_CITY_CLEARANCE_REWARD})
    end
    self:disposeSelf()
end

function ShowBoxReward:dispose()
    ShowBoxReward.super.dispose(self)
end
return ShowBoxReward