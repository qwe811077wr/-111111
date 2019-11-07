local DropItem = class("DropItem", require('app.base.ChildViewBase'))

DropItem.RESOURCE_FILENAME = "instance/DropItemNode.csb"
DropItem.RESOURCE_BINDING = {
    ["CheckBox_1"] = {["varname"] = "_checkbox"},
    ["Node_1"]     = {["varname"] = "_nodeItem"},
    ["Panel_1"]    = {["varname"] = "_panelBg"},
}

function DropItem:onCreate()
    DropItem.super.onCreate(self)
    self._checkbox:setLocalZOrder(100)
end

function DropItem:setCanSwallow(flag)
end

function DropItem:setData(item_config, game_mode)
    self._gameMode = game_mode
    local data = uq.RewardType.new(item_config)
    local info = data:toEquipWidget()
    info.mode = game_mode
    self._equiItem = require("app.modules.common.EquipItem"):create({info = info})
    self._equiItem:setTouchEnabled(true)
    self._equiItem:addClickEventListener(function(sender)
        local info = sender:getEquipInfo()
        info.mode = self._gameMode
        uq.showItemTips(info)
    end)
    self._nodeItem:addChild(self._equiItem)
end

function DropItem:setGameMode(game_mode)
    self._gameMode = game_mode
end

function DropItem:setSwallow(flag)
    self._equiItem:setSwallowTouches(flag)
end

function DropItem:setPresssLong()
    self._equiItem:setTouchEnabled(false)
    self._equiItem:enableEvent()
end

function DropItem:setListenerSwallow(flag)
    self._equiItem:setSwallow(flag)
end

function DropItem:setNum(num)
    local num = num or 0
    self._equiItem:setNameVisible(num > 0)
    self._equiItem:setNameString(num)
end

function DropItem:setImgNameVisible(txt_visible, img_visible)
    self._equiItem:setImgNameVisible(txt_visible, img_visible)
end

function DropItem:setCheckboxVisible(flag)
    self._checkbox:setSelected(false)
    self._checkbox:setVisible(flag)
end

function DropItem:isSelect()
    return self._checkbox:isSelected()
end

function DropItem:setCheckboxSelect(flag)
    return self._checkbox:setSelected(flag)
end

function DropItem:setTouch(callback)
    self._panelBg:setTouchEnabled(true)
    self._panelBg:setSwallowTouches(false)
    self._panelBg:onTouch(function(event)
        uq.log('callback', event)
        if event.name == "ended" and callback then
            callback()
        end
    end)
end

return DropItem