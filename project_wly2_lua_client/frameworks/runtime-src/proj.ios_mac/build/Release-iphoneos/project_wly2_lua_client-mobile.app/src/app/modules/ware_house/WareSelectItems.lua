local WareSelectItems = class("WareSelectItems", require('app.base.ChildViewBase'))
local EquipItem = require("app.modules.common.EquipItem")

WareSelectItems.RESOURCE_FILENAME = "ware_house/WareSelectItems.csb"
WareSelectItems.RESOURCE_BINDING = {
    ["Node_1"]                    = {["varname"] = "_nodeBase"},
    ["Node_1/items_node"]         = {["varname"] = "_nodeItems"},
    ["Node_1/Text_1"]             = {["varname"] = "_txtName"},
    ["Node_1/Text_3"]             = {["varname"] = "_txtNum"},
    ["CheckBox_1"]                = {["varname"] = '_checkBox'},
}

function WareSelectItems:onCreate()
    WareSelectItems.super.onCreate(self)
    self._idx = 0
    self:parseView()
end

function WareSelectItems:setData(data, idx, select_id)
    self._data = data or {}
    self._idx = idx
    self:setSelectShow(select_id)
    if not self._data or next(self._data) == nil then
        return
    end
    local info = StaticData.getCostInfo(self._data.type, self._data.id)
    if not info or next(info) == nil then
        return
    end
    self._txtName:setString(info.name)
    local num = uq.cache.role:getResNum(self._data.type, self._data.id)
    self._txtNum:setString(num)
    local item = EquipItem:create({info = self._data})
    local name = item:getChildByName("resource_layer"):getChildByName("lbl_name")
    name:setFontSize(16 / 0.59)
    item:setScale(0.59)
    self._nodeItems:removeAllChildren()
    self._nodeItems:addChild(item)
end

function WareSelectItems:initClickEvent(func)
    self._checkBox:addEventListener(function(sender, event_type)
        func(self._idx, sender, event_type)
    end)
end

function WareSelectItems:setSelectShow(select_id)
    self._checkBox:setSelected(self._idx == select_id)
end

return WareSelectItems