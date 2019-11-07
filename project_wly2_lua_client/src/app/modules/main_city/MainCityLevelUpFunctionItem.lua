local MainCityLevelUpFunctionItem = class("MainCityLevelUpFunctionItem", require('app.base.ChildViewBase'))

MainCityLevelUpFunctionItem.RESOURCE_FILENAME = "main_city/MainCityLevelUpFunctionItem.csb"
MainCityLevelUpFunctionItem.RESOURCE_BINDING = {
    ["Text_1"]     = {["varname"] = "_txtName"},
    ["Image_1"]    = {["varname"] = "_imgFunction"}
}

function MainCityLevelUpFunctionItem:ctor(name, params)
    MainCityLevelUpFunctionItem.super.ctor(self, name, params)
end

function MainCityLevelUpFunctionItem:setData(data, icon)
    self._txtName:setString(data.name)
    self._imgFunction:loadTexture('img/main_city/' .. icon)
end

function MainCityLevelUpFunctionItem:getBgContentWidth()
    return self._imgFunction:getContentSize().width
end

return MainCityLevelUpFunctionItem