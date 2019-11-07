local EquipBoughtTips = class("EquipBoughtTips", require('app.base.PopupBase'))

EquipBoughtTips.RESOURCE_FILENAME = "equip/EquipBoughtTip.csb"
EquipBoughtTips.RESOURCE_BINDING = {
    ["Text_1"]                   = {["varname"] = "_txtContent"},
    ["Button_2"]                 = {["varname"] = "_btnCancel", ["events"] = {{["event"] = "touch",["method"] = "onCancel"}}},
    ["Button_2_0"]               = {["varname"] = "_btnConfirm", ["events"] = {{["event"] = "touch",["method"] = "onConfirm"}}},
}

function EquipBoughtTips:ctor(name, params)
    EquipBoughtTips.super.ctor(self, name, params)
    self._data = params.data
end

function EquipBoughtTips:init()
    self:centerView()
    self:parseView()
    self:updatePage()
end

function EquipBoughtTips:updatePage()
    if not self._data or not self._data.content then
        return
    end
    self._txtContent:setString(self._data.content)
end

function EquipBoughtTips:onCancel(event)
    if event.name ~= "ended" then
        return
    end
    self:disposeSelf()
end

function EquipBoughtTips:onConfirm(event)
    if event.name ~= "ended" then
        return
    end
    if self._data.confirm_callback then
        self._data.confirm_callback()
    end

    self:disposeSelf()
end

return EquipBoughtTips