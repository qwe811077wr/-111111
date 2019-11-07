local ConfirmBoxNoSelect = class("ConfirmBoxNoSelect", require('app.base.ChildViewBase'))

ConfirmBoxNoSelect.RESOURCE_FILENAME = "common/ConfirmNoSelect.csb"
ConfirmBoxNoSelect.RESOURCE_BINDING = {
    ["Button_2"]   = {["varname"] = "_btnCancle",["events"] = {{["event"] = "touch",["method"] = "onClosed"}}},
    ["Button_2_0"] = {["varname"] = "_btnConfirm",["events"] = {{["event"] = "touch",["method"] = "onConfirm"}}},
    ["label"]      = {["varname"] = "_title"},
    ["Panel_1"]    = {["varname"] = "_bg"},
    ["Panel_2"]    = {["varname"] = "_panelTips"},
    ["Button_1"]   = {["varname"] = "_btnExit", ["events"] = {{["event"] = "touch",["method"] = "onClosed"}}},
}

function ConfirmBoxNoSelect:onCreate()
    ConfirmBoxNoSelect.super.onCreate(self)

    self._callback = nil
    self._data = nil
    self:parseView()
    self._richText = uq.RichText:create()
    self._richText:setAnchorPoint(cc.p(0.5, 0.5))
    self._richText:setDefaultFont("res/font/hwkt.ttf")
    self._richText:setFontSize(24)
    local size = self._bg:getContentSize()
    self._richText:setContentSize(cc.size(0, size.height))
    self._richText:setMultiLineMode(false)
    self._richText:setTextColor(cc.c3b(255,255,255))
    local x,y = self._bg:getPosition()
    self._richText:setPosition(cc.p(x, y))
    self._view:addChild(self._richText)
end

function ConfirmBoxNoSelect:onClosed(event)
    if event.name == "ended" then
        if self._data.cancle_callback then
            self._data.cancle_callback()
        end

        if self._callback then
            self._callback(self)
        end
    end
end

function ConfirmBoxNoSelect:setConfirmId(id)

end

function ConfirmBoxNoSelect:refreshSize()
    local size = self._bg:getContentSize()
    if self._richText:getTextRealSize().width > size.width then
        self._richText:setContentSize(cc.size(size.width, 0))
        self._richText:setMultiLineMode(true)
    end
end

function ConfirmBoxNoSelect:setData(data)
    self._data = data
    self._panelTips:setVisible(data.tip ~= nil)
    local title = data.title or StaticData['local_text']['label.common.tips']
    self._title:setString(title)
    self._richText:setText(data.content)
    self._richText:formatText()
    self:refreshSize()

    if data.style == uq.config.constant.CONMFRIM_BOX_STYLE.CONFIRM_BTN_ONLY then
        self._btnCancle:setVisible(false)
        self._btnConfirm:setPositionX(1)
    end
end

function ConfirmBoxNoSelect:onConfirm(event)
    if event.name == "ended" then
        local need_close = self._data.need_close
        if self._data.confirm_callback then
            self._data.confirm_callback()
        end

        if need_close ~= false then
            self:onClosed({name = "ended"})
        end
    end
end

function ConfirmBoxNoSelect:setCallback(callback)
    self._callback = callback
end

return ConfirmBoxNoSelect