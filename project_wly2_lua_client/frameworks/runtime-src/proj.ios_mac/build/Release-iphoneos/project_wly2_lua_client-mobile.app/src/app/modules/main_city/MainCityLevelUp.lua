local MainCityLevelUp = class("MainCityLevelUp", require('app.base.PopupBase'))

MainCityLevelUp.RESOURCE_FILENAME = "main_city/MainCityLevelUp.csb"
MainCityLevelUp.RESOURCE_BINDING = {
    ["Text_2"]       = {["varname"] = "_txtNowLevel"},
    ["Text_3"]       = {["varname"] = "_txtUpLevel"},
    ["Text_2_0"]     = {["varname"] = "_txtNowLevelOne"},
    ["Text_3_0"]     = {["varname"] = "_txtUpLevelOne"},
    ["Node_1"]       = {["varname"] = "_nodeBuild"},
    ["Node_2"]       = {["varname"] = "_nodeFunction"},
    ["Text_4"]       = {["varname"] = "_txtTitle"},
    ["Image_3"]      = {["varname"] = "_imgEffect"},
}

function MainCityLevelUp:ctor(name, params)
    MainCityLevelUp.super.ctor(self, name, params)
end

function MainCityLevelUp:init()
    self:centerView()
    self:setLayerColor(0.7)
    self:parseView()

    self._modules = {}

    self._txtTitle:setString(StaticData['buildings']['CastleMap'][0]['result'])
    self:setCallBack(handler(self, self.onClose))
    uq:addEffectByNode(self._imgEffect, 900111, 1, true)
    uq:addEffectByNode(self._imgEffect, 900112, -1, true)
end

function MainCityLevelUp:setData(data)
    local cur_level = uq.cache.role:level()
    self._txtNowLevel:setString(cur_level)
    self._txtNowLevelOne:setString(cur_level)
    self._txtUpLevel:setString(cur_level + 1)
    self._txtUpLevelOne:setString(cur_level + 1)

    self:initBuilds(data)
    self:initFunctions(data)
end

function MainCityLevelUp:initBuilds(data)
    if data.castleId == "" then
        return
    end

    local build_ids = string.split(data.castleId, ',')
    local building = StaticData['buildings']['CastleMap']
    for k, v in pairs(build_ids) do
        local panel = uq.createPanelOnly("main_city.MainCityLevelUpBuildItem")
        panel:setData(building[tonumber(v)])

        local width = panel:getBgContentWidth() / 2
        panel:setPosition(cc.p(width * k + 130 * (k - 1), 20))
        self._nodeBuild:addChild(panel)
    end
end

function MainCityLevelUp:initFunctions(data)
    if data.moduleId == "" then
        return
    end

    local module_ids = string.split(data.moduleId, ',')
    local module_icons = string.split(data.moduleIcon, ',')
    self._modules = module_ids
    local module_data = StaticData['module']
    for k, v in pairs(module_ids) do
        local panel = uq.createPanelOnly("main_city.MainCityLevelUpFunctionItem")
        panel:setData(module_data[tonumber(v)], module_icons[k])

        local width = panel:getBgContentWidth() / 2
        panel:setPositionX(width * k + 80 * (k - 1))
        self._nodeFunction:addChild(panel)
    end
end

function MainCityLevelUp:onClose()
    uq.cache.level_up:setFuncData(self._modules)
    uq.cache.level_up:setFlag(true)
    services:dispatchEvent({name = services.EVENT_NAMES.ON_SHOW_FUNCTION_OPEN})
end

return MainCityLevelUp