local TavernRewardReviewItem = class("TavernRewardReviewItem", require('app.base.ChildViewBase'))
local EquipItem = require("app.modules.common.EquipItem")

TavernRewardReviewItem.RESOURCE_FILENAME = "tavern/TavernRewardReviewItem.csb"
TavernRewardReviewItem.RESOURCE_BINDING = {
}

function TavernRewardReviewItem:onCreate()
    TavernRewardReviewItem.super.onCreate(self)
    self._oneRowNum = 7
    self._itemList = {}
    for i = 1, self._oneRowNum do
        local equip_item = EquipItem:create()
        local x = -380 + (i - 1) * 127
        local y = 0
        equip_item:setPosition(cc.p(x, y))
        equip_item:setTouchEnabled(true)
        equip_item:addClickEventListenerWithSound(function(sender)
            local info = sender:getEquipInfo()
            uq.showItemTips(info)
        end)
        equip_item:setSwallowTouches(false)
        equip_item:setVisible(false)
        self:addChild(equip_item)
        self._itemList[i] = equip_item
    end
end

function TavernRewardReviewItem:setData(item_data)
    for i = 1, self._oneRowNum do
        local show = false
        if item_data[i] then
            show = true
            self._itemList[i]:setInfo(item_data[i])
        end
        self._itemList[i]:setVisible(show)
        self._itemList[i]:setNameVisible(visible)
    end
end

return TavernRewardReviewItem