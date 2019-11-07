local NewFunctionOpen = class("NewFunctionOpen", require('app.base.PopupBase'))

NewFunctionOpen.RESOURCE_FILENAME = "main_city/NewFunctionOpen.csb"
NewFunctionOpen.RESOURCE_BINDING = {
    ["Image_19"]       = {["varname"] = "_imgBuild"},
    ["Text_1"]         = {["varname"] = "_txtName"},
    ["Text_23"]        = {["varname"] = "_txtContent"},
    ["Image_20"]       = {["varname"] = "_imgEffect"},
    ["Button_5"]       = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onRun"}}},
}

function NewFunctionOpen:ctor(name, params)
    NewFunctionOpen.super.ctor(self, name, params)
end

function NewFunctionOpen:init()
    self:centerView()
    self:setLayerColor(0.7)
    self:parseView()

    self:setCallBack(handler(self, self.onClose))
    uq:addEffectByNode(self._imgEffect, 900113, 1, true)
    uq:addEffectByNode(self._imgEffect, 900114, -1, true)
end

function NewFunctionOpen:onRun(event)
    if event.name ~= "ended" then
        return
    end
    uq.cache.level_up:addIndex()
    local is_success = uq.jumpToModule(self._id)
    if is_success then
        self:disposeSelf()
    end
end

function NewFunctionOpen:setData(data, index)
    self._data = data
    self._id = tonumber(data[index])
    local module_data = StaticData['module'][self._id]
    self._imgBuild:loadTexture('img/main_city/' .. module_data.jumpIcon)
    self._txtName:setString(module_data.name)
    self._txtContent:setString(module_data.jumpDescription)
end

function NewFunctionOpen:onClose()
    uq.cache.level_up:addIndex()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_SHOW_FUNCTION_OPEN})
end

return NewFunctionOpen