local EquipItem = require("app.modules.common.EquipItem")
local AncientCityDailyRewardItem = class("AncientCityDailyRewardItem", function()
    return ccui.Layout:create()
end)

function AncientCityDailyRewardItem:ctor(args)
    self._view = nil
    self._info = args and args.info
    self:init()
end

function AncientCityDailyRewardItem:init()
    if not self._view then
        local node = cc.CSLoader:createNode("ancient_city/AncientCityDailyRewardItem.csb")
        self._view = node:getChildByName("Panel_1")
    end
    self._view:removeSelf()
    self:addChild(self._view)
    self:setAnchorPoint(cc.p(0.5,0.5))
    self:setContentSize(self._view:getContentSize())
    self._view:setPosition(cc.p(0,0))
    self._itemArray = {}
    self._desLabel = self._view:getChildByName("lbl_des");
    self._panelNotOpen = self._view:getChildByName("Panel_notopen");
    self._btnGet = self._view:getChildByName("btn_get");
    self._btnGet:setPressedActionEnabled(true)
    self._btnGet:addClickEventListenerWithSound(function(sender)
        network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_DRAW_GOAL, {id = self._info.ident})
    end)
    self._btnGoto = self._view:getChildByName("btn_goto");
    self._btnGoto:setPressedActionEnabled(true)
    self._btnGoto:addClickEventListenerWithSound(function(sender)
        uq.ModuleManager:getInstance():dispose(uq.ModuleManager.ANCIENT_CITY_DAILY_REWARD_MODULE)
    end)
    for i = 1,3 do
        local item = self._view:getChildByName("Panel_item" .. i);
        table.insert(self._itemArray, item)
    end
    self:initInfo()
end

function AncientCityDailyRewardItem:setInfo(info)
    self._info = info
    self:initInfo()
end

function AncientCityDailyRewardItem:initInfo()
    self._desLabel:setHTMLText(string.format(StaticData['local_text']['ancient.daily.reward.des'], self._info.nums))
    local reward_array = uq.RewardType.parseRewards(self._info.reward)
    for k, v in pairs(self._itemArray) do
        v:removeAllChildren()
    end
    local index = 1
    for _, t in ipairs(reward_array) do
        if index > 3 then
            break
        end
        local euqip_item = EquipItem:create({info = t:toEquipWidget()})
        local item_size = self._itemArray[index]:getContentSize()
        euqip_item:setPosition(cc.p(item_size.width * 0.5, item_size.height * 0.5))
        euqip_item:setTouchEnabled(true)
        euqip_item:addClickEventListenerWithSound(function(sender)
            local info = sender:getEquipInfo()
            uq.showItemTips(info)
        end)
        self._itemArray[index]:addChild(euqip_item)
        index = index + 1
    end
    if self._info.is_can_get == 0 then
        self._btnGoto:setVisible(false)
        self._btnGet:setVisible(false)
        self._panelNotOpen:setVisible(true)
    elseif self._info.is_can_get == 1 then
        self._btnGoto:setVisible(true)
        self._btnGet:setVisible(false)
        self._panelNotOpen:setVisible(false)
    elseif self._info.is_can_get == 2 then
        self._btnGoto:setVisible(false)
        self._btnGet:setVisible(true)
        self._panelNotOpen:setVisible(false)
    end
end

function AncientCityDailyRewardItem:getInfo()
    return self._info
end

return AncientCityDailyRewardItem