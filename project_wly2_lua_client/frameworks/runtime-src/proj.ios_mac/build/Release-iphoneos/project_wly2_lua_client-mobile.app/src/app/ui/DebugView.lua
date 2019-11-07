local DebugView = class('DebugView', require('app.base.ChildViewBase'))

DebugView.RESOURCE_FILENAME = "common/Debug.csb"
DebugView.RESOURCE_BINDING = {
    ["ListView_1"] = {["varname"] = "_listInfo"},
}

function DebugView:onCreate()
    DebugView.super.onCreate()
    self:setContentSize(display.size)
    self:setPosition(display.center)
    self._listInfo:setContentSize(display.size)
    self:setLocalZOrder(uq.ModuleManager.SPECIAL_ZORDER.MSG_ZORDER)
    self._listInfo:setSwallowTouches(false)
end

function DebugView:debugInfo(info)
    local text = ccui.Text:create()
    text:setString(info)
    text:setFontSize(22)
    text:setTextAreaSize(cc.size(0, 0))
    text:ignoreContentAdaptWithSize(false)
    text:setTextColor(display.COLOR_RED)
    self._listInfo:pushBackCustomItem(text)
    self._listInfo:jumpToBottom()
end

return DebugView