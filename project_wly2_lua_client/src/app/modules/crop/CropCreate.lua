local CropCreate = class("CropCreate", require('app.base.PopupBase'))

CropCreate.RESOURCE_FILENAME = "crop/CropCreate.csb"
CropCreate.RESOURCE_BINDING = {
    ["Image_4"]      = {["varname"] = "_imgTitleBg"},
    ["Image_4_0"]    = {["varname"] = "_imgContentBg"},
    ["Text_1_0_0_0"] = {["varname"] = "_txtPrice"},
    ["Sprite_1"]     = {["varname"] = "_sprIcon"},
    ["Sprite_2"]     = {["varname"] = "_sprIconBg"},
    ["Image_55"]     = {["varname"] = "_imgIconBg"},
    ["Image_13"]     = {["varname"] = "_imgIconChange"},
    ["Button_2"]     = {["varname"] = "_btnClose"},
    ["Button_1"]     = {["varname"] = "_btnCreate",["events"] = {{["event"] = "touch",["method"] = "onBtnCreate",["sound_id"] = 61}}},
}

function CropCreate:ctor(name, params)
    CropCreate.super.ctor(self, name, params)
end

function CropCreate:onCreate()
    CropCreate.super.onCreate(self)

    self:centerView()
    self:setLayerColor()
    self:parseView()
    self._iconId = 1
    self._cost = StaticData['constant'][8].Data[1].cost or ""
    self._costArray = string.split(self._cost, ";")
    self:createEditbox()
    self:initLayer()
    self._eventRefreshCreate = "_onCreateCrop" .. tostring(self)
    network:addEventListener(Protocol.S_2_C_CREATE_CROP, handler(self, self._onCreateCrop), self._eventRefreshCreate)
end

function CropCreate:initLayer()
    self._txtPrice:setString(self._costArray[2])
    self:refreshIcon(self._iconId)
    self._imgIconBg:addClickEventListenerWithSound(function()
        self:showCropHead()
        end)
    self._imgIconChange:addClickEventListener(function()
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
        self:showCropHead()
        end)
    self._btnClose:addClickEventListenerWithSound(function()
        self:disposeSelf()
        end)
end

function CropCreate:showCropHead()
    local func = function (icon_id)
        self._iconId = icon_id
        self:refreshIcon(icon_id)
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.CROP_HEAD, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, icon_id = self._iconId, func = func, is_create = true})
end

function CropCreate:refreshIcon(icon_id)
    local icon_id = icon_id or 1
    local icon_bg, icon_icon = uq.cache.crop:getCropIcon(icon_id)
    if icon_bg ~= "" then
        self._sprIcon:setTexture(icon_icon)
        self._sprIconBg:setTexture(icon_bg)
    end
end

function CropCreate:createEditbox()
    local size = self._imgTitleBg:getContentSize()
    self._editBoxTitle = ccui.EditBox:create(cc.size(size.width, size.height), '')
    self._editBoxTitle:setAnchorPoint(cc.p(0.5, 0.5))
    self._editBoxTitle:setFontName("font/fzlthjt.ttf")
    self._editBoxTitle:setFontSize(20)
    self._editBoxTitle:setFontColor(cc.c3b(254, 253, 221))
    self._editBoxTitle:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._editBoxTitle:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
    self._editBoxTitle:setPosition(cc.p(size.width/2, size.height/2 - 3))
    self._editBoxTitle:setPlaceholderFontName("font/fzlthjt.ttf")
    self._editBoxTitle:setPlaceholderFontSize(20)
    self._editBoxTitle:setPlaceholderFontColor(cc.c3b(50, 85, 94))
    self._editBoxTitle:setPlaceHolder(StaticData["local_text"]["crop.input.name"])
    self._editBoxTitle:setMaxLength(7)
    self._imgTitleBg:addChild(self._editBoxTitle)

    local size = self._imgContentBg:getContentSize()
    self._editBoxContent = ccui.EditBox:create(cc.size(size.width, size.height), '')
    self._editBoxContent:setAnchorPoint(cc.p(0.5, 0.5))
    self._editBoxContent:setFontName("font/fzlthjt.ttf")
    self._editBoxContent:setFontSize(20)
    self._editBoxContent:setFontColor(cc.c3b(254, 253, 221))
    self._editBoxContent:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._editBoxContent:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
    self._editBoxContent:setPosition(cc.p(size.width / 2, size.height / 2 - 3))
    self._editBoxContent:setPlaceholderFontName("font/fzlthjt.ttf")
    self._editBoxContent:setPlaceholderFontSize(20)
    self._editBoxContent:setPlaceHolder(StaticData["local_text"]["crop.input.declare"])
    self._editBoxContent:setPlaceholderFontColor(cc.c3b(50, 85, 94))
    self._editBoxContent:setMaxLength(36)
    self._imgContentBg:addChild(self._editBoxContent)
end

function CropCreate:onBtnCreate(event)
    if event.name == 'ended' then
        local str_title = self._editBoxTitle:getText()
        local str_content = self._editBoxContent:getText()
        if str_title == '' then
            uq.fadeInfo(StaticData['local_text']["crop.name.blank"])
            return
        end

        if str_content == '' then
            uq.fadeInfo(StaticData['local_text']["crop.declare.blank"])
            return
        end

        if uq.hasKeyWord(str_title) or uq.hasKeyWord(str_content) then
            uq.fadeInfo(StaticData["local_text"]["label.screen.word"])
            return
        end

        if string.len(self._editBoxTitle:getText()) >  Protocol.MAX_CROPS_NAME_LEN then
            uq.fadeInfo(StaticData['local_text']["crop.name.limit"])
            return
        end

        if string.len(self._editBoxContent:getText()) > Protocol.MAX_CROPS_DECLARE_MSG_LEN then
            uq.fadeInfo(StaticData['local_text']["crop.content.limit"])
            return
        end

        if uq.cache.role:checkRes(tonumber(self._costArray[1]), tonumber(self._costArray[2])) then
            local data = {
                head_id = self._iconId,
                len1 = string.len(str_title),
                name = str_title,
                len2 = string.len(str_content),
                board_msg = str_content
            }
            network:sendPacket(Protocol.C_2_S_DO_CREATE_CROP, data)
            uq.cache.crop._cropIconId = self._iconId
        else
            uq.fadeInfo(StaticData['local_text']["crop.not.enough.money"], 0, 0)
        end
    end
end

function CropCreate:_onCreateCrop(evt)
    if evt.data.ret == Protocol.CREATE_CROP_RET.cr_ok then
        self:disposeSelf()
    end
end

function CropCreate:dispose()
    network:removeEventListenerByTag(self._eventRefreshCreate)
    CropCreate.super.dispose(self)
end

return CropCreate