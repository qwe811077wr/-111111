local GeneralsInternalItem = class("GeneralsInternalItem", require('app.base.ChildViewBase'))

GeneralsInternalItem.RESOURCE_FILENAME = "generals/InternalPropertyItem.csb"
GeneralsInternalItem.RESOURCE_BINDING = {
    ["Text_1"]       = {["varname"] = "_txtName"},
    ["Text_1_0"]     = {["varname"] = "_txtProperty"},
    ["Text_1_0_1"]   = {["varname"] = "_txtLevel"},
    ["LoadingBar_1"] = {["varname"] = "_txtLoad"},
    ["Text_1_1"]     = {["varname"] = "_txtAddPerLevel"},
}

function GeneralsInternalItem:onCreate()
    GeneralsInternalItem.super.onCreate(self)
end

function GeneralsInternalItem:setData(data, temp_id, general_id)
    self._txtName:setString(data.name)

    local index = data.ident
    local value_property = uq.cache.generals:getGeneralBuildOfficerPropertyAdd(general_id)
    self._txtProperty:setString(value_property[index][1])

    local values_level = uq.cache.generals:getGeneralBuildOfficerLevelAdd(general_id)
    local xml_data = StaticData['officer_level'].OfficerLevel[values_level[index][1]]
    local per = values_level[index][2] / xml_data.proficiency
    self._txtLevel:setString(string.format('LV.%d（%.1f%%）', values_level[index][1], per * 100))
    self._txtLoad:setPercent(per * 100)

    self._txtAddPerLevel:setString(string.format('(%s +%s)', StaticData['local_text']['label.buildofficer.level'], tostring(value_property[index][2])))
end

return GeneralsInternalItem