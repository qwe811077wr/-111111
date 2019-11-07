local SystemCell = class("SystemCell", require('app.base.ChildViewBase'))

SystemCell.RESOURCE_FILENAME = "chat/SystemCell.csb"
SystemCell.RESOURCE_BINDING = {
    ["Panel_1"]         = {["varname"] = "_panelTxt"},
}

function SystemCell:onCreate()
    SystemCell.super.onCreate(self)
    self:parseView()
    self._richTextContent = uq.RichText:create()
    self._richTextContent:setAnchorPoint(cc.p(0, 1))
    self._richTextContent:setDefaultFont("res/font/fzlthjt.ttf")
    self._richTextContent:setFontSize(24)
    local size = self._panelTxt:getContentSize()
    self._richTextContent:setContentSize(size)
    self._richTextContent:setMultiLineMode(true)
    self._richTextContent:setTextColor(cc.c3b(255, 255, 255))
    self._richTextContent:setPosition(cc.p(0, size.height))
    self._richTextContent:setWrapMode(1)
    self._richTextContent:ignoreContentAdaptWithSize(false)
    self._panelTxt:addChild(self._richTextContent)
end

function SystemCell:setData(data)
    local str = string.format(StaticData['local_text']['chat.cell.title.name'], data.content) .. self:getTime(data.create_time)
    self._richTextContent:setText(str)
end

function SystemCell:getTime(time)--获取时间
    local tab_server_time = os.date("*t", time)
    return string.format(StaticData['local_text']['chat.cell.time.des'],
        tab_server_time.month, tab_server_time.day, tab_server_time.hour, tab_server_time.min, tab_server_time.sec)
end

return SystemCell