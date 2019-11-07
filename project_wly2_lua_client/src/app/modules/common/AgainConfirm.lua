local AgainConfirm = class("AgainConfirm", require('app.base.PopupBase'))

AgainConfirm.RESOURCE_FILENAME = "common/AgainConfirm.csb"
AgainConfirm.RESOURCE_BINDING = {
    ["Button_2_0"]             = {["varname"] = "_btnCancel"},
    ["Button_2"]               = {["varname"] = "_btnOk"},
    ["Text_2"]                 = {["varname"] = "_txtDec1"},
    ["Text_4"]                 = {["varname"] = "_txtDec2"},
    ["Button_2_0/Text_5_0"]    = {["varname"] = "_txtCancel"},
    ["Button_2/Text_5"]        = {["varname"] = "_txtOk"},
    ["Image_2/Text_3"]         = {["varname"] = "_txtTitle"},
}

function AgainConfirm:ctor(name, args)
    AgainConfirm.super.ctor(self, name, args)
    self._args = args or {}
end

function AgainConfirm:init()
    self:setPosition(cc.p(display.width / 2, display.height / 2+50))
    self:parseView()
    self:setLayerColor(0.4)
    self._isAgainConfirm = false
    --title,dec_up,dec_down,func_ok,func_cancel,left_txt,right_txt
    if self._args.title and self._args.title ~= "" then
        self._txtTitle:setString(tostring(self._args.title))
    end
    if self._args.dec_up then
        self._txtDec1:setString(tostring(self._args.dec_up))
    end
    if self._args.dec_down then
        self._txtDec2:setString(tostring(self._args.dec_down))
    end
    if self._args.left_txt then
        self._txtDec2:setString(tostring(self._args.left_txt))
    end
    if self._args.right_txt then
        self._txtDec2:setString(tostring(self._args.right_txt))
    end
    self._btnOk:addClickEventListenerWithSound(function()
        if self._args.func_ok then
            self._args.func_ok()
        end
        self._isAgainConfirm = true
        self:disposeSelf()
        end)
    self._btnCancel:addClickEventListenerWithSound(function()
        self:disposeSelf()
        end)
end

function AgainConfirm:dispose()
    if not self._isAgainConfirm and self._args.func_cancel then
        self._args.func_cancel()
    end
    AgainConfirm.super.dispose(self)
end

return AgainConfirm