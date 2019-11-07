local ConfirmModule = class("ConfirmModule", require("app.base.PopupBase"))


function ConfirmModule:ctor(name, args)
    ConfirmModule.super.ctor(self, name, args)
    self._data = args
end

function ConfirmModule:init()
    self:setView(cc.CSLoader:createNode("common/Confirm.csb"))
    self:parseView()

    local msgTxt = self._view:getChildByName("txt_msg")
    if self._data.msg ~= nil then
        msgTxt:setHTMLText(self._data.msg)
    end

    self._view:getChildByName("btn_ok"):setPressedActionEnabled(true)
    self._view:getChildByName("btn_ok"):addClickEventListenerWithSound(function(sender)
        uq.ModuleManager:getInstance():dispose(self:name())
        if self._data.okHandler ~= nil then
            self._data.okHandler()
        end
    end)

    self._view:getChildByName("btn_cancel"):setPressedActionEnabled(true)
    self._view:getChildByName("btn_cancel"):addClickEventListenerWithSound(function(sender)
        uq.ModuleManager:getInstance():dispose(self:name())
        if self._data.cancelHandler ~= nil then
            self._data.cancelHandler()
        end
    end)

    if self._data.isShowCancel ~= nil and not self._data.isShowCancel then
        self._view:getChildByName("btn_cancel"):setVisible(false)
        self._view:getChildByName("btn_ok"):setPositionX(0)
    end
end

function ConfirmModule:dispose()
    ConfirmModule.super.dispose(self)
end



return ConfirmModule