local DecomposeNum = class("DecomposeNum", require('app.base.PopupBase'))

DecomposeNum.RESOURCE_FILENAME = "decompose/DecomposeNum.csb"
DecomposeNum.RESOURCE_BINDING = {
    ["Node_1"]                       = {["varname"] = "_nodeBase"},
    ["Text_1_0"]                     = {["varname"] = "_txtSurplus"},
    ["Panel_4"]                      = {["varname"] = "_pnlNum"},
    ["Button_1"]                     = {["varname"] = "_btnReduce"},
    ["Button_2"]                     = {["varname"] = "_btnAdd"},
    ["ok_btn"]                       = {["varname"] = "_btnOk"},
    ["Button_3"]                     = {["varname"] = "_btnMin"},
    ["Button_3_0"]                   = {["varname"] = "_btnMax"},
}

function DecomposeNum:ctor(name, args)
    DecomposeNum.super.ctor(self, name, args)
    self._info = args.info or {}
    self._maxNum = args.max_num or 1
    self._func = args.func
end

function DecomposeNum:init()
    self:parseView()
    self:centerView()
    self:setLayerColor(0.4)
    self._num = 1
    self:initLayer()
    self:setTextNum()
end

function DecomposeNum:initLayer()
    self._txtSurplus:setString(tostring(self._maxNum))
    self._btnReduce:addClickEventListenerWithSound(function ()
        self._num = self:dealNum(self._num - 1)
        self:setTextNum()
    end)
    self._btnAdd:addClickEventListenerWithSound(function ()
        self._num = self:dealNum(self._num + 1)
        self:setTextNum()
    end)
    self._btnMin:addClickEventListenerWithSound(function ()
        self._num = 1
        self:setTextNum()
    end)
    self._btnMax:addClickEventListenerWithSound(function ()
        self._num = self._maxNum
        self:setTextNum()
    end)
    self._btnOk:addClickEventListenerWithSound(function ()
        if self._func then
            self._func(self._info, self._num)
        end
        self:disposeSelf()
    end)
    local size = self._pnlNum:getContentSize()
    self._editBox = ccui.EditBox:create(cc.size(size.width - 5, size.height), '')
    self._editBox:setAnchorPoint(cc.p(0.5, 0.5))
    self._editBox:setFontName("font/hwkt.ttf")
    self._editBox:setFontSize(22)
    self._editBox:setMaxLength(2)
    self._editBox:setFontColor(cc.c3b(255, 255, 255))
    self._editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._editBox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self._editBox:registerScriptEditBoxHandler(function(event, sender) self:editboxHandle(event, sender) end)
    self._editBox:setPlaceholderFontName("Arial")
    self._editBox:setPlaceholderFontSize(22)
    self._editBox:setPosition(cc.p(size.width / 2 + 5, size.height / 2))
    self._pnlNum:addChild(self._editBox)
end

function DecomposeNum:editboxHandle(event, sender)
    if event == "changed" then
        local str = self._editBox:getText()
        if str ~= "" and str ~= nil then
            self._num = self:dealNum(tonumber(str))
            self:setTextNum()
        end
    elseif event == "ended" then
        local str = self._editBox:getText()
        if str == "" or str == nil then
            self._num = 1
        else
            self._num = self:dealNum(tonumber(str))
        end
        self:setTextNum()
    end
end

function DecomposeNum:dealNum(num)
    return math.min(math.max(num, 1), self._maxNum)
end

function DecomposeNum:setTextNum()
    self._editBox:setText(tostring(self._num))
end

return DecomposeNum