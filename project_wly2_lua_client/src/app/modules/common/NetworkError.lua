local NetworkError = class("NetworkError", require('app.base.PopupBase'))

NetworkError.RESOURCE_FILENAME = "common/ConfirmNoSelect.csb"
NetworkError.RESOURCE_BINDING = {
    ["Button_2"]              = {["varname"] = "_btnCancle",["events"] = {{["event"] = "touch",["method"] = "_onCancel"}}},
    ["Button_2_0"]            = {["varname"] = "_btnConfirm",["events"] = {{["event"] = "touch",["method"] = "_onConfirm"}}},
    ["Button_2/Text_30"]      = {["varname"] = "_txtCancel"},
    ["Button_2_0/Text_30"]    = {["varname"] = "_txtConfirm"},
    ["label"]                 = {["varname"] = "_title"},
    ["Panel_1"]               = {["varname"] = "_bg"},
}

NetworkError.DIALOG_STYLE = {
    RECONNECT = 1, -- 两个按钮，"重试"/"重新登录"
    LOGOUT    = 2, -- 单个按钮，"重新登录"
    LOGIN     = 3, -- 单个按钮，"确认"
}

function NetworkError:onCreate()
    NetworkError.super.onCreate(self)
    --
    self._richText = uq.RichText:create()
    self._richText:setAnchorPoint(cc.p(0.5, 0.5))
    self._richText:setDefaultFont("res/font/hwkt.ttf")
    self._richText:setFontSize(24)
    self._size = self._bg:getContentSize()
    self._richText:setContentSize(cc.size(0, self._size.height))
    self._richText:setMultiLineMode(false)
    self._richText:setTextColor(cc.c3b(255,255,255))
    local x,y = self._bg:getPosition()
    self._richText:setPosition(cc.p(x, y))
    self._view:addChild(self._richText)
end

function NetworkError:ctor(name, args)
    NetworkError.super.ctor(self, name, args)
    --
    self._confirmFunc = nil
    self._cancelFunc  = nil
    --
    self._dialogInfo = args.dialogInfo
    self:setTouchClose(false)
end

function NetworkError:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    --
    self:initDialog()
end

function NetworkError:getRichText()
end

function NetworkError:initDialog()
    self._confirmFunc = self._dialogInfo.confirmFunc
    self._cancelFunc  = self._dialogInfo.cancelFunc
    --
    self._title:setString(self._dialogInfo.title or StaticData['local_text']['label.common.tips'])
    self._richText:setText(self._dialogInfo.msg)
    self._richText:formatText()
    self:refreshSize()

    self._btnCancle:setVisible(self._dialogInfo.style == NetworkError.DIALOG_STYLE.RECONNECT)
    if self._dialogInfo.style ~= NetworkError.DIALOG_STYLE.RECONNECT then
        self._btnConfirm:setPositionX(0)
        if self._dialogInfo.style == NetworkError.DIALOG_STYLE.LOGIN then
            self._txtConfirm:setString(StaticData['local_text']['label.confirm2'])
        elseif self._dialogInfo.style == NetworkError.DIALOG_STYLE.LOGOUT then
            self._txtConfirm:setString(StaticData['local_text']['label.common.network.relogin'])
        end
    else
        self._btnConfirm:setPositionX(147)
        self._txtConfirm:setString(StaticData['local_text']['label.common.network.retry'])
    end
    --
    self._txtCancel:setString(StaticData['local_text']['label.common.network.relogin'])
end

function NetworkError:refreshSize()
    if self._richText:getTextRealSize().width > self._size.width then
        self._richText:setContentSize(cc.size(self._size.width, 0))
        self._richText:setMultiLineMode(true)
    end
end

function NetworkError:_onConfirm(event)
    if event.name == "ended" then
        if self._confirmFunc then
            self._confirmFunc()
        end
        uq.ModuleManager:getInstance():dispose(uq.ModuleManager.NETWORK_ERROR)
    end
end

function NetworkError:_onCancel(event)
    if event.name == "ended" then
        if self._cancelFunc then
            self._cancelFunc()
        end
        uq.ModuleManager:getInstance():dispose(uq.ModuleManager.NETWORK_ERROR)
    end
end

return NetworkError