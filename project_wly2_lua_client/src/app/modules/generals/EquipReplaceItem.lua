local EquipReplaceItem = class("EquipReplaceItem", require('app.base.ChildViewBase'))

EquipReplaceItem.RESOURCE_FILENAME = "generals/EquipReplaceItem.csb"
EquipReplaceItem.RESOURCE_BINDING = {
    ['Image_2']                   = {["varname"] = "_imgSelect"},
    ['Image_1']                   = {["varname"] = "_imgIcon"},
    ['lbl_name']                  = {["varname"] = "_txtName"},
}

function EquipReplaceItem:ctor()
    EquipReplaceItem.super.ctor(self)
end

function EquipReplaceItem:setInfo(info)
    if not info then
        return
    end
    self._info = uq.cache.generals:getGeneralDataByID(info.id)
    if not self._info then
        return
    end
    self:refreshPage()
end

function EquipReplaceItem:getInfo()
    return self._info
end

function EquipReplaceItem:refreshPage()
    self._txtName:setString(self._info.name)
    local xml_data = StaticData['general'][tonumber(self._info.rtemp_id)]
    self._imgIcon:loadTexture("img/common/general_head/" .. xml_data.miniIcon)
end

function EquipReplaceItem:setSelectedImgState(state)
    self._imgSelect:setVisible(state)
end

function EquipReplaceItem:dispose()
    EquipReplaceItem.super.dispose(self)
end

return EquipReplaceItem