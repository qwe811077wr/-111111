local AppointHeadItem = class("AppointHeadItem", require('app.base.ChildViewBase'))

AppointHeadItem.RESOURCE_FILENAME = "collect/AppointHeadItem.csb"
AppointHeadItem.RESOURCE_BINDING = {
    ["Image_bg"]                = {["varname"] = "bgImg"},
    ["Sprite_1"]                = {["varname"] = "_iconSprite"},
    ["Image_add"]               = {["varname"] = "_imgAdd"},
    ["Image_lock"]              = {["varname"] = "_imgLock"},
    ["Node_data"]               = {["varname"] = "_nodeData"},
    ["des"]                     = {["varname"] = "_desLabel"},
    ["Image_desbg"]             = {["varname"] = "_imgDesBg"},
    ["Image_state"]             = {["varname"] = "_imgFace"},
}

function AppointHeadItem:ctor(name, params)
    AppointHeadItem.super.ctor(self, name, params)
end

function AppointHeadItem:onCreate()
    AppointHeadItem.super.onCreate(self)
    self._refreshEventTag = services.EVENT_NAMES.ON_BUILD_OFFICER_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_BUILD_OFFICER_REFRESH, handler(self, self.onEventRefresh), self._refreshEventTag)
    self.bgImg:addClickEventListenerWithSound(function(evt)
        uq.runCmd('enter_build_officer')
    end)
end

function AppointHeadItem:onEventRefresh(evt)
    if evt.build_id and evt.build_id ~= self._info.build_id then
        return
    end
    self:setInfo(self._info)
end

function AppointHeadItem:setInfo(info)
    self._info = info
    local str_array = string.split(self._info.str, ',')
    local limit_level = tonumber(str_array[1])
    local state = limit_level <= self._info.build_level
    self._nodeData:setVisible(state)
    self._imgAdd:setVisible(state)
    self._imgDesBg:setVisible(state)
    self._imgLock:setVisible(not state)
    self.bgImg:setTouchEnabled(state)
    if state then
        local officer_list = uq.cache.role:getBuildOfficerData(self._info.build_id)
        local is_have = officer_list[self._info.index] and officer_list[self._info.index].general_id > 0
        self._nodeData:setVisible(is_have)
        self._imgAdd:setVisible(not is_have)
        if is_have then
            local general_info = uq.cache.generals:getGeneralDataByID(officer_list[self._info.index].general_id)
            local xml_data = StaticData['general'][general_info.rtemp_id]
            local tire_data = uq.cache.generals:getGeneralTireModeData(officer_list[self._info.index].general_id)
            self._imgFace:loadTexture('img/build_officer/' .. tire_data.icon)
            self._iconSprite:setTexture("img/common/general_head/" .. xml_data.miniIcon)
            self._desLabel:setString(StaticData['local_text']['appoint.general.des1'])
        else
            self._desLabel:setString(StaticData['local_text']['appoint.general.des2'])
        end
    end
end

function AppointHeadItem:getInfo()
    return self._info
end

function AppointHeadItem:onExit()
    services:removeEventListenersByTag(self._refreshEventTag)
    AppointHeadItem.super:onExit()
end

return AppointHeadItem