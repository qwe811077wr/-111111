local MainCityLevelUpBuildItem = class("MainCityLevelUpBuildItem", require('app.base.ChildViewBase'))

MainCityLevelUpBuildItem.RESOURCE_FILENAME = "main_city/MainCityLevelUpBuildItem.csb"
MainCityLevelUpBuildItem.RESOURCE_BINDING = {
    ["Image_19"]     = {["varname"] = "_imgModel"},
    ["Image_2"]      = {["varname"] = "_imgBg"},
    ["Text_1"]       = {["varname"] = "_txtModelName"}
}

function MainCityLevelUpBuildItem:ctor(name, params)
    MainCityLevelUpBuildItem.super.ctor(self, name, params)
end

function MainCityLevelUpBuildItem:setData(data)
    self._imgModel:loadTexture(data.icon)
    self._txtModelName:setString(data.name)
end

function MainCityLevelUpBuildItem:getBgContentWidth()
    return self._imgBg:getContentSize().width
end

return MainCityLevelUpBuildItem