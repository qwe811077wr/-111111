local DecreeBoxs = class("DecreeBoxs", require('app.base.ChildViewBase'))

DecreeBoxs.RESOURCE_FILENAME = "decree/DecreeBoxs.csb"
DecreeBoxs.RESOURCE_BINDING = {
    ["title_txt"]                     = {["varname"] = "_txtTitle"},
    ["Image_2"]                       = {["varname"] = "_imgBg"},
    ["btn_txt"]                       = {["varname"] = "_txtBtn"},
    ["Button_1"]                      = {["varname"] = "_btnOk",["events"] = {{["event"] = "touch",["method"] = "onBtnGroup"}}},
}

function DecreeBoxs:onCreate()
    DecreeBoxs.super.onCreate(self)
    self:parseView()
    self._data = {}
end

function DecreeBoxs:setData(data)
    self._data = data or {}
    if not self._data or next(self._data) == nil then
        return
    end
    self._imgBg:loadTexture("img/decree/" .. self._data.picture)
    self._txtTitle:setString(self._data.name)
    self._txtBtn:setString(self._data.button)
end

function DecreeBoxs:onBtnGroup(event)
    if event.name ~= "ended" then
        return
    end
    if not self._data or next(self._data) == nil then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.DECREE_ISSUE, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, data = self._data})
end

return DecreeBoxs