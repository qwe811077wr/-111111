local InstanceWarNpcInfo = class("InstanceWarNpcInfo", require('app.base.ChildViewBase'))

InstanceWarNpcInfo.RESOURCE_FILENAME = "instance_war/InstanceWarNpcInfo.csb"
InstanceWarNpcInfo.RESOURCE_BINDING = {
    ["Text_1"]         = {["varname"] = "_txtName"},
    ["Node_1"]         = {["varname"] = "_nodeGeneral"},
    ["res_name1"]      = {["varname"] = "_txtResLeftName1"},
    ["res_name2"]      = {["varname"] = "_txtResLeftName2"},
    ["res_name3"]      = {["varname"] = "_txtResLeftName3"},
    ["res_name4"]      = {["varname"] = "_txtResLeftName4"},
    ["left_res_name1"] = {["varname"] = "_txtResName1"},
    ["left_res_name2"] = {["varname"] = "_txtResName2"},
    ["left_res_name3"] = {["varname"] = "_txtResName3"},
    ["left_res_name4"] = {["varname"] = "_txtResName4"},
    ["res1"]           = {["varname"] = "_txtResLeft1"},
    ["res2"]           = {["varname"] = "_txtResLeft2"},
    ["res3"]           = {["varname"] = "_txtResLeft3"},
    ["res4"]           = {["varname"] = "_txtResLeft4"},
    ["left_res1"]      = {["varname"] = "_txtRes1"},
    ["left_res2"]      = {["varname"] = "_txtRes2"},
    ["left_res3"]      = {["varname"] = "_txtRes3"},
    ["left_res4"]      = {["varname"] = "_txtRes4"},
    ["Text_3_0"]       = {["varname"] = "_txtOn"},
    ["Text_3_0_0"]     = {["varname"] = "_txtOut"},
    ["Text_3_0_1"]     = {["varname"] = "_txtPrisioner"},
    ["Text_1_0"]       = {["varname"] = "_txtType"},
}

function InstanceWarNpcInfo:onCreate()
    InstanceWarNpcInfo.super.onCreate(self)

    self._eventTagRefresh = services.EVENT_NAMES.ON_INSTANCE_WAR_CITY_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_INSTANCE_WAR_CITY_REFRESH, handler(self, self.updateCityInfo), self._eventTagRefresh)
end

function InstanceWarNpcInfo:onExit()
    services:removeEventListenersByTag(self._eventTagRefresh)
    InstanceWarNpcInfo.super.onExit(self)
end

function InstanceWarNpcInfo:setData(data_xml)
    self._dataXml = data_xml
    local city_info = StaticData['instance_city'][data_xml.city]
    self._txtName:setString(city_info.name)
    self._txtType:setString(city_info.feature)

    for i = 1, 4 do
        self['_txtRes' .. i]:setString('')
        self['_txtResLeft' .. i]:setString('')
        self['_txtResName' .. i]:setString('')
        self['_txtResLeftName' .. i]:setString('')
    end

    local resource = string.split(data_xml.resource, "|")
    for k, item in ipairs(resource) do
        local strs = string.split(item, ';')
        local item_data = StaticData.getCostInfo(tonumber(strs[1]), tonumber(strs[3]))
        self['_txtRes' .. k]:setString(strs[2])
        self['_txtResName' .. k]:setString(item_data.name)
    end

    local city_data = uq.cache.instance_war:getCityData(data_xml.city)
    local res = {}
    res[uq.config.constant.COST_RES_TYPE.REDIF] = city_data.soldier
    if city_data.power == 1 then
        res[uq.config.constant.COST_RES_TYPE.FOOD] = uq.cache.instance_war:getRes(uq.config.constant.COST_RES_TYPE.FOOD)
        res[uq.config.constant.COST_RES_TYPE.IRON_MINE] = uq.cache.instance_war:getRes(uq.config.constant.COST_RES_TYPE.IRON_MINE)
        res[uq.config.constant.COST_RES_TYPE.MONEY] = uq.cache.instance_war:getRes(uq.config.constant.COST_RES_TYPE.MONEY)
    else
        res[uq.config.constant.COST_RES_TYPE.FOOD] = 0
        res[uq.config.constant.COST_RES_TYPE.IRON_MINE] = 0
        res[uq.config.constant.COST_RES_TYPE.MONEY] = 0
    end
    local index = 1
    for k, item in pairs(res) do
        local item_data = StaticData.getCostInfo(k)
        self['_txtResLeft' .. index]:setString(item)
        self['_txtResLeftName' .. index]:setString(item_data.name)
        index = index + 1
    end

    if not self._generalPanel then
        self._generalPanel = uq.createPanelOnly('instance_war.InstanceWarGeneralCard')
        self._generalPanel:setScale(0.48)
        self._nodeGeneral:addChild(self._generalPanel)
    end
    local general_id = data_xml.showGeneral == 0 and 400181 or data_xml.showGeneral
    self._generalPanel:setData(general_id)

    if city_data.power == 1 then
        self._txtOn:setString(#city_data.generals)
    else
        self._txtOn:setString(#city_data.troop_id)
    end
    self._txtOut:setString(#city_data.out_general)
    self._txtPrisioner:setString(#city_data.capture_general)
end

function InstanceWarNpcInfo:updateCityInfo()
    self:setData(self._dataXml)
end

return InstanceWarNpcInfo