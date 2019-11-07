local InfoRightItems = class("InfoRightItems", require('app.base.ChildViewBase'))

InfoRightItems.RESOURCE_FILENAME = "retainer/InfoRightItems.csb"
InfoRightItems.RESOURCE_BINDING = {
    ["Panel_1/Text_1"]            = {["varname"]="_txtTime"},
    ["Panel_1/Text_1_0"]          = {["varname"]="_txtDec"},
    ["Panel_1/Button_1"]          = {["varname"]="_btnGo"},
}

function InfoRightItems:onCreate()
    InfoRightItems.super.onCreate(self)
end

function InfoRightItems:setData(data)
    self:parseView()
    local data = data or {}
    self.data = data
    if next(data) ~= nil then
        self._txtDec:setString(data.dec)
        self._txtTime:setString(self:getTime())
    end
end

function InfoRightItems:getTime()
    local time = self.data.time or os.time()
    local str = os.date(StaticData['local_text']['retainer.time'], time) or ""
    return str
end
return InfoRightItems