local CropHelpListItem = class("CropHelpListItem", require('app.base.ChildViewBase'))

CropHelpListItem.RESOURCE_FILENAME = "crop/CropHelpListItem.csb"
CropHelpListItem.RESOURCE_BINDING = {
    ["Text_44"]     = {["varname"] = "_txtName"},
    ["Text_44_0"]   = {["varname"] = "_txtMem"},
    ["Text_44_0_0"] = {["varname"] = "_txtTime"},
}

function CropHelpListItem:onCreate()
    CropHelpListItem.super.onCreate(self)

end

function CropHelpListItem:setData(log_data)
    local build_xml = StaticData['buildings']['CastleMap'][log_data.build_id]
    self._txtName:setString(build_xml.name)
    self._txtMem:setString(log_data.name)
    self._txtTime:setString(uq.getTime2(uq.curServerSecond() - log_data.help_time) .. StaticData['local_text']['label.common.before'])
end

return CropHelpListItem