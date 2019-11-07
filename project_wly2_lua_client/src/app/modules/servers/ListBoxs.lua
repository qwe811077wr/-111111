local ListBoxs = class("ListBoxs", require('app.base.ChildViewBase'))

ListBoxs.RESOURCE_FILENAME = "server_list/ListBoxs.csb"
ListBoxs.RESOURCE_BINDING = {
    ["Image_1"]             = {["varname"]="_imgBg"},
    ["Image_2"]             = {["varname"]="_imgBgSelect"},
    ["Panel_1"]             = {["varname"]="_pnl1"},
    ["Panel_1/Image_3"]     = {["varname"]="_imgIcon"},
    ["Panel_1/Text_1"]      = {["varname"]="_txtRegion"},
    ["Panel_1/Text_1_0"]    = {["varname"]="_txtServer"},
    ["Panel_1/Text_5"]      = {["varname"]="_txtLv"},
    ["Panel_1/Text_6"]      = {["varname"]="_txtLvStr"},
    ["Panel_1/select_head"]         = {["varname"]="_imgSelect"},
    ["Panel_1/select_head_not"]     = {["varname"]="_imgSelectNot"},
}

function ListBoxs:onCreate()
    ListBoxs.super.onCreate(self)
    self:parseView()
end

function ListBoxs:setData(data,sid)
    local data = data or {}
    if next(data) == nil then
        return
    end
    if data.name then
        self._txtServer:setString(data.name)
    end
    self._imgSelect:setVisible(tonumber(data.sid) == tonumber(sid))
    self._imgBgSelect:setVisible(tonumber(data.sid) == tonumber(sid))
    self._imgBg:setVisible(tonumber(data.sid) ~= tonumber(sid))
    self._imgSelectNot:setVisible(tonumber(data.sid) ~= tonumber(sid))
    self._txtRegion:setString(tostring(data.sid))

    if data.sid == sid then
        local color = uq.parseColor("#ffffff")
        self._txtRegion:setTextColor(color)
        self._txtServer:setTextColor(color)
        self._txtLv:setTextColor(color)
        self._txtLvStr:setTextColor(color)
    end
end

function ListBoxs:setLayerVisible(visible)
    self:setVisible(visible)
end
return ListBoxs