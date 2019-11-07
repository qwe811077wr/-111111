local BuildOfficerTip = class("BuildOfficerTip", require('app.base.PopupBase'))

BuildOfficerTip.RESOURCE_FILENAME = "build_officer/BuildOfficerTip.csb"
BuildOfficerTip.RESOURCE_BINDING = {
    ["Text_1"]   = {["varname"] = "_txtTip"},
    ["Button_1"] = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onTouchClose"}}},
}

function BuildOfficerTip:onCreate()
    BuildOfficerTip.super.onCreate(self)
    self:centerView()
    self:parseView()
    self:setLayerColor()
end

function BuildOfficerTip:onExit()
    local office_data = self._data
    BuildOfficerTip.super.onExit(self)

    if table.nums(office_data) > 0 then
        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.BUILD_OFFICER_TIP, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
        panel:setData(office_data)
    end
end

function BuildOfficerTip:onTouchClose(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

function BuildOfficerTip:setData(office_data)
    self._data = office_data

    local general_list = nil
    local build_type = nil
    for k, item in pairs(self._data) do
        if #item > 0 then
            general_list = item
            build_type = k
            self._data[k] = nil
            break
        end
        self._data[k] = nil
    end

    if not build_type then
        self:disposeSelf()
        return
    end

    local names = ''
    for k, general_id in ipairs(general_list) do
        local general_data = uq.cache.generals:getGeneralDataByID(general_id)
        names = names .. general_data.name
        if k < #general_list then
            names = names .. '、'
        end
    end

    local build_id = uq.cache.role:getBuildIdByType(build_type)
    local build_data = StaticData['buildings']['CastleMap'][build_id]
    local str = string.format(StaticData['local_text']['label.buildofficer.unload.tip'], names, names, build_data.name)
    self._txtTip:setHTMLText(str, nil, nil, nil, true)
end

return BuildOfficerTip