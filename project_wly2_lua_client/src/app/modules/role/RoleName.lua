local RoleName = class("RoleName", require('app.base.PopupBase'))

RoleName.RESOURCE_FILENAME = "role/RoleName.csb"
RoleName.RESOURCE_BINDING = {
    ["Image_40"]   = {["varname"] = "_imgBg"},
    ["Button_1"]   = {["varname"] = "_btnChange"},
    ["Text_2"]     = {["varname"] = "_txtGold"},
    ["Button_2"]   = {["varname"] = "_btnOk"},
    ["Button_1_0"] = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onTouchClose"}}},
}

function RoleName:onCreate()
    RoleName.super.onCreate(self)

    self:centerView()
    self:parseView()
    self:setLayerColor(0.4)

    self:createEditbox()
    self:initPage()
end

function RoleName:initPage()
    self._cost = 0
    if uq.cache.role.rename_times > 0 then
        self._cost = 500
    end
    if self._cost == 0 then
        self._txtGold:setString(StaticData['local_text']['ancient.city.shop.refresh.free'])
        self._txtGold:setTextColor(uq.parseColor('#69ec2d'))
    else
        self._txtGold:setString(tostring(self._cost))
        self._txtGold:setTextColor(uq.parseColor('#ffffff'))
    end
    self._btnChange:addClickEventListenerWithSound(function()
        network:sendPacket(Protocol.C_2_S_RAND_NAME)
        end)
    self._btnOk:addClickEventListenerWithSound(function()
        if not uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN, self._cost) then
            uq.fadeInfo(StaticData["local_text"]["label.common.not.enough.gold"])
            return
        end
        local str = self._editBoxName:getText()

        if str == '' then
            uq.fadeInfo(StaticData['local_text']['label.role.not.none'])
            return
        end

        if string.utf8len(str) > 7 then
            uq.fadeInfo(StaticData['local_text']['label.role.overflow'])
            return
        end

        if uq.hasKeyWord(str) then
            uq.fadeInfo(StaticData["local_text"]["label.screen.word"])
            return
        end
        if uq.isLimiteName(str) then
            uq.fadeInfo(StaticData["local_text"]["login.please.name"])
            return
        end
        local data = {
            name_len = string.len(str),
            name = str,
        }
        network:sendPacket(Protocol.C_2_S_MODITY_ACCOUNT_NAME, data)
        self:disposeSelf()
        end)
    network:addEventListener(Protocol.S_2_C_RAND_NAME, handler(self, self._onRandName), "_onRandName")
end

function RoleName:createEditbox()
    local size = self._imgBg:getContentSize()
    self._editBoxName = ccui.EditBox:create(cc.size(size.width, size.height), '')
    self._editBoxName:setAnchorPoint(cc.p(0.5, 0.5))
    self._editBoxName:setFontName("font/hwkt.ttf")
    self._editBoxName:setFontSize(22)
    self._editBoxName:setFontColor(uq.parseColor("#FEFDDD"))
    self._editBoxName:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._editBoxName:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self._editBoxName:setPosition(cc.p(size.width / 2, size.height / 2))
    self._editBoxName:setPlaceholderFontName("font/hwkt.ttf")
    self._editBoxName:setPlaceholderFontSize(22)
    self._editBoxName:setMaxLength(20)
    self._editBoxName:setPlaceHolder(StaticData['local_text']['label.role.input'])
    self._editBoxName:setPlaceholderFontColor(uq.parseColor('#586A6E'))
    self._imgBg:addChild(self._editBoxName)
end

function RoleName:_onRandName(evt)
    local data = evt.data
    uq.cache.account.rand_name = data.name
    self._editBoxName:setText(uq.cache.account.rand_name)
end

function RoleName:_onChangeName( evt )
    self:disposeSelf()
end

function RoleName:dispose()
    network:removeEventListenerByTag('_onRandName')
    RoleName.super.dispose(self)
end

function RoleName:onTouchClose(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

return RoleName