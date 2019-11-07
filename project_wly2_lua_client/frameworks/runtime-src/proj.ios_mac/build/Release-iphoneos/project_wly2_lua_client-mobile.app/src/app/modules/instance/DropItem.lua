local DropItem = class("DropItem", require('app.base.ChildViewBase'))

DropItem.RESOURCE_FILENAME = "instance/DropItemNode.csb"

function DropItem:onCreate()
    DropItem.super.onCreate(self)
end

function DropItem:setCanSwallow(flag)
end

function DropItem:setData(item_config)
    local data = uq.RewardType.new(item_config)
    local info = data:toEquipWidget()
    self._equiItem = require("app.modules.common.EquipItem"):create({info = info})
    self._equiItem:setTouchEnabled(true)
    self._equiItem:addClickEventListener(function(sender)
        local info = sender:getEquipInfo()
        uq.showItemTips(info)
    end)
    self:addChild(self._equiItem)
end

function DropItem:setNum(num)
    local num = num or 0
    self._equiItem:setNameVisible(num > 0)
    self._equiItem:setNameString(num)
end

function DropItem:setImgNameVisible(txt_visible, img_visible)
    self._equiItem:setImgNameVisible(txt_visible, img_visible)
end

return DropItem