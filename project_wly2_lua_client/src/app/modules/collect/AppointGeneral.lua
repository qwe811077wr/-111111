local AppointGeneral = class("AppointGeneral", require('app.base.ChildViewBase'))

AppointGeneral.RESOURCE_FILENAME = "collect/AppointGeneral.csb"
AppointGeneral.RESOURCE_BINDING = {
    ["des"]                 = {["varname"] = "_desLabel"},
    ["Node_head"]           = {["varname"] = "_headNode"},
}

function AppointGeneral:ctor(name, params)
    AppointGeneral.super.ctor(self, name, params)
    self._buildId = 0
end

function AppointGeneral:onCreate()
    AppointGeneral.super.onCreate(self)
    self._refreshEventTag = services.EVENT_NAMES.ON_BUILD_OFFICER_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_BUILD_OFFICER_REFRESH, handler(self, self.onEventRefresh), self._refreshEventTag)
end

function AppointGeneral:setBuildId(id)
    self._buildId = id
    self._headArray = {}
    self._headNode:removeAllChildren()
    local office_info = StaticData['officer_build_map'][self._buildId]
    if office_info == nil then
        return
    end
    self._totalNum = 0
    local build_data = uq.cache.role.buildings[self._buildId]
    local nums = string.split(office_info.officerNums, ';')
    local strs = string.split(nums[#nums], ',')
    self._totalNum = tonumber(strs[2])
    local pos_y = 0
    for i = 1, self._totalNum do
        local info = {
            index = i,
            str = nums[i],
            build_id = self._buildId,
            build_level = build_data.level
        }
        local general_item = uq.createPanelOnly('collect.AppointHeadItem')
        self._headNode:addChild(general_item)
        table.insert(self._headArray, general_item)
        general_item:setPositionY(pos_y)
        pos_y = pos_y - 105
        general_item:setInfo(info)
    end
    self._desLabel:setString(string.format(StaticData['local_text']['appoint.general.des3'], self:getOfficerGeneralNum(), self._totalNum))
end

function AppointGeneral:getOfficerGeneralNum()
    local officer_list = uq.cache.role:getBuildOfficerData(self._buildId)
    local num = 0
    for k, v in ipairs(officer_list) do
        if v.general_id > 0 then
            num = num + 1
        end
    end
    return num
end

function AppointGeneral:onEventRefresh(evt)
    if evt.build_id == nil then
        return
    end
    self._desLabel:setString(string.format(StaticData['local_text']['appoint.general.des3'], self:getOfficerGeneralNum(), self._totalNum))
end

function AppointGeneral:setInfo(info)
    self._info = info
end

function AppointGeneral:onExit()
    services:removeEventListenersByTag(self._refreshEventTag)
    AppointGeneral.super:onExit()
end

return AppointGeneral