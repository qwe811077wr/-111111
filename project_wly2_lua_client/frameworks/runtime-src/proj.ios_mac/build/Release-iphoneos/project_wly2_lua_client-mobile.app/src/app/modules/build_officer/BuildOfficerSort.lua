local BuildOfficerSort = class("BuildOfficerSort", require('app.base.PopupBase'))

BuildOfficerSort.RESOURCE_FILENAME = "build_officer/BuildOfficerSort.csb"
BuildOfficerSort.RESOURCE_BINDING = {
    ["Button_1"] = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onBtnClose"}}},
    ["Button_2"] = {["varname"] = "_btnConfirm",["events"] = {{["event"] = "touch",["method"] = "onConfirm"}}},
}

function BuildOfficerSort:ctor(name, params)
    BuildOfficerSort.super.ctor(self, name, params)
    self:centerView()
    self:parseView()
end

function BuildOfficerSort:onCreate()
    BuildOfficerSort.super.onCreate(self)

    for i = 1, 9 do
        local check_box = self:getResourceNode():getChildByName('CheckBox_' .. i)
        check_box:onEvent(handler(self, self.onCheck))
    end
end

function BuildOfficerSort:onCheck(event)
    local tag = event.target:getTag()
    if event.name ~= "selected" then
        return
    end
    if tag <= 7 then
        self._soryType = tag
    elseif tag == 8 then
        self._isUp = true
    elseif tag == 9 then
        self._isUp = false
    end
    self:refreshPage()
end

function BuildOfficerSort:setData(sort_type, is_up, callback)
    self._soryType = sort_type
    self._isUp = is_up
    self._confirmCallback = callback
    self:refreshPage()
end

function BuildOfficerSort:refreshPage()
    for i = 1, 9 do
        local check_box = self:getResourceNode():getChildByName('CheckBox_' .. i)
        check_box:setSelected(false)
    end

    local check_box = self:getResourceNode():getChildByName('CheckBox_' .. self._soryType)
    check_box:setSelected(true)

    if self._isUp then
        self:getResourceNode():getChildByName('CheckBox_8'):setSelected(true)
    else
        self:getResourceNode():getChildByName('CheckBox_9'):setSelected(true)
    end
end

function BuildOfficerSort:onBtnClose(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

function BuildOfficerSort:onConfirm(event)
    if event.name ~= 'ended' then
        return
    end
    if self._confirmCallback then
        self._confirmCallback(self._soryType, self._isUp)
    end
    self:disposeSelf()
end

return BuildOfficerSort

