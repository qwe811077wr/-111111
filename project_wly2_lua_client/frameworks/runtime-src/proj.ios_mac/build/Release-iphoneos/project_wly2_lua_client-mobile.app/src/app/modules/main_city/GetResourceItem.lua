local GetResourceItem = class("GetResourceItem", require('app.base.ChildViewBase'))

GetResourceItem.RESOURCE_FILENAME = "main_city/GetResourceItem.csb"
GetResourceItem.RESOURCE_BINDING = {
    ["Text_desc"]      = {["varname"] = "_txtDesc"},
    ["name_txt"]       = {["varname"] = "_txtName"},
    ["icon_spr"]       = {["varname"] = "_sprIcon"},
    ["Button_forward"] = {["varname"] = "_btnForward",["events"] = {{["event"] = "touch",["method"] = "onForward"}}},
}

function GetResourceItem:onCreate()
    GetResourceItem.super.onCreate(self)
    self:parseView()
end

function GetResourceItem:setData(module_id, callback)
    self._moduleID = tonumber(module_id)
    local config = StaticData['module'][self._moduleID] or {}
    if config and next(config) ~= nil then
        self._txtDesc:setString(config.jumpDescription)
        self._txtName:setString(config.name)
        if config.jumpIcon ~= "" then
            self._sprIcon:setTexture("img/generals/" .. config.jumpIcon)
        end
    end

    self._callback = callback
end

function GetResourceItem:setIndex(index)
    self._index = index
end

function GetResourceItem:onForward(event)
    if event.name == "ended" then
        if uq.jumpToModule(self._moduleID) and self._callback then
            self._callback({name = "ended"})
        end
    end
end

return GetResourceItem