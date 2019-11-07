local CropRedbag = class("CropRedbag", require('app.base.PopupBase'))

CropRedbag.RESOURCE_FILENAME = "crop/CropRedbag.csb"
CropRedbag.RESOURCE_BINDING = {
    ["Text_11"]          = {["varname"] = "_txtRedNum"},
    ["Text_12"]          = {["varname"] = "_txtRedMaxNum"},
    ["Image_9"]          = {["varname"] = "_imgRedSendNumBg"},
    ["Text_13"]          = {["varname"] = "_txtRedSend"},
    ["Button_3"]         = {["varname"] = "_btnRedPreview",["events"] = {{["event"] = "touch",["method"] = "onRedPreview"}}},
    ["Button_reduce"]    = {["varname"] = "_btnReduce",["events"] = {{["event"] = "touch",["method"] = "onReduce"}}},
    ["Button_increase"]  = {["varname"] = "_btnIncrease",["events"] = {{["event"] = "touch",["method"] = "onIncrease"}}},
    ["Button_ordinary"]  = {["varname"] = "_btnRedOrdinary",["events"] = {{["event"] = "touch",["method"] = "onRedOrdinary"}}},
    ["Text_2"]           = {["varname"] = "_txtOrdinary"},
    ["Button_command"]   = {["varname"] = "_btnRedCommand",["events"] = {{["event"] = "touch",["method"] = "onRedCommand"}}},
    ["Text_6"]           = {["varname"] = "_txtInputTittle"},
    ["Text_7"]           = {["varname"] = "_txtInputContent"},
    ["Text_7_0"]         = {["varname"] = "_txtInputPrompt"},
    ["Text_3"]           = {["varname"] = "_txtCommand"},
    ["Button_reset"]     = {["varname"] = "_btnReset",["events"] = {{["event"] = "touch",["method"] = "onReset"}}},
    ["Button_send"]      = {["varname"] = "_btnSend",["events"] = {{["event"] = "touch",["method"] = "onSend"}}},
}

function CropRedbag:ctor(name, params)
    CropRedbag.super.ctor(self, name, params)
end

function CropRedbag:init()
    self._redPacketNumData = StaticData['types']['EnvelopesType'][1]['Type']
    self._btnState = uq.config.constant.TYPE_CROP_RED_PACKET_SPECOES.COMMAND
    self._richTextContent = ''

    self:centerView()
    self:parseView()
    self:setTouchClose(false)
    self:createEditBox()
    self:createRichText()
    self._txtRedMaxNum:setString(StaticData['local_text']['chat.red.packet.interval'] .. self._redPacketNumData[1]['value'])
    self:refreshSendNum()
end

function CropRedbag:onCreate()
    CropRedbag.super.onCreate(self)

    self._serviceRefreshTag = services.EVENT_NAMES.ON_CROP_REDBAG_SEND_NUM_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_CROP_REDBAG_SEND_NUM_REFRESH, handler(self, self.refreshSendNum), self._serviceRefreshTag)
end

function CropRedbag:onExit()
    services:removeEventListenersByTag(self._serviceRefreshTag)

    CropRedbag.super:onExit()
end

function CropRedbag:refreshSendNum()
    self._txtRedNum:setString(uq.cache.crop._redbagSendNum or 0)
end

function CropRedbag:createEditBox()
    local size = self._imgRedSendNumBg:getContentSize()
    self._redNumEditBox = ccui.EditBox:create(cc.size(size.width, size.height), '')
    self._redNumEditBox:setAnchorPoint(cc.p(0.5, 0.5))
    self._redNumEditBox:setFontName("font/hwkt.ttf")
    self._redNumEditBox:setFontSize(22)
    self._redNumEditBox:setFontColor(uq.parseColor("#FEFDDD"))
    self._redNumEditBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._redNumEditBox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self._redNumEditBox:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    self._redNumEditBox:registerScriptEditBoxHandler(function(eventname,sender) self:redNumEditBoxHandle(eventname,sender) end)
    self._redNumEditBox:setPosition(cc.p(size.width / 2, size.height / 2))
    self._imgRedSendNumBg:addChild(self._redNumEditBox)

    size = self._txtInputContent:getContentSize()
    self._inputContentEditBox = ccui.EditBox:create(cc.size(size.width, size.height), '')
    self._inputContentEditBox:setAnchorPoint(cc.p(0.5, 0.5))
    self._inputContentEditBox:setFontName("font/hwkt.ttf")
    self._inputContentEditBox:setFontSize(22)
    self._inputContentEditBox:setFontColor(uq.parseColor("#FEFDDD"))
    self._inputContentEditBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._inputContentEditBox:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
    self._inputContentEditBox:registerScriptEditBoxHandler(function(eventname,sender) self:inputContentEditBoxHandle(eventname,sender) end)
    self._inputContentEditBox:setPosition(cc.p(size.width / 2, size.height / 2))
    self._txtInputContent:addChild(self._inputContentEditBox)
end

function CropRedbag:createRichText()
    local size = self._txtInputContent:getContentSize()
    self._richText = uq.RichText:create()
    self._richText:setAnchorPoint(cc.p(0, 1))
    self._richText:setDefaultFont("font/hwkt.ttf")
    self._richText:setFontSize(22)
    self._richText:setContentSize(cc.size(size.width, size.height))
    self._richText:setMultiLineMode(true)
    self._richText:setTextColor(uq.parseColor("#FEFDDD"))
    self._richText:ignoreContentAdaptWithSize(false)
    self._richText:setPosition(cc.p(0, size.height))
    self._txtInputContent:addChild(self._richText)
end

function CropRedbag:redNumEditBoxHandle(strEventName, sender)
    if strEventName == "began" then
        self._redNumEditBox:setText(self._txtRedSend:getString())
    elseif strEventName == "ended" then
        local text = self._redNumEditBox:getText()
        if text == '' then
            self._txtRedSend:setString(0)
            return
        end
        if uq.hasKeyWord(text) then
            uq.fadeInfo(StaticData["local_text"]["label.screen.word"])
            self._txtRedSend:setString(0)
            return
        end
        self._txtRedSend:setString(tonumber(text))
        self._redNumEditBox:setText('')
    end
end

function CropRedbag:inputContentEditBoxHandle(strEventName, sender)
    if strEventName == "began" then
        self._inputContentEditBox:setText(self._richTextContent)
    elseif strEventName == "ended" then
        local text = self._inputContentEditBox:getText()
        self._richTextContent = text
        if text == '' then
            self._richText:setText('')
            self._txtInputPrompt:setVisible(true)
            return
        end
        if uq.hasKeyWord(text) then
            self._richText:setText('')
            self._txtInputPrompt:setVisible(true)
            uq.fadeInfo(StaticData["local_text"]["label.screen.word"])
            return
        end

        self._inputContentEditBox:setText('')

        if string.utfLen(text) > 18 then
            uq.fadeInfo(StaticData['local_text']['chat.red.packet.content.long'])
            return
        end

        self._richText:setText(text)
        self._txtInputPrompt:setVisible(false)
    end
end

function CropRedbag:refreshBtn()
    self._btnRedOrdinary:setContentSize(cc.size(55, 55))
    self._btnRedOrdinary:loadTextures('img/common/ui/g02_000060.png', 'img/common/ui/g02_000060.png')
    self._txtOrdinary:setColor(uq.parseColor("#769996"))
    self._txtOrdinary:setFontSize(26)

    self._btnRedCommand:setContentSize(cc.size(55, 55))
    self._btnRedCommand:loadTextures('img/common/ui/g02_000061.png', 'img/common/ui/g02_000061.png')
    self._txtCommand:setColor(uq.parseColor("#769996"))
    self._txtCommand:setFontSize(26)

    self._txtInputPrompt:setVisible(true)
    self._richText:setText('')
    self._inputContentEditBox:setText('')
    self._txtRedSend:setString(0)
    self._redNumEditBox:setText('')

    self._richTextContent = ''

    if self._btnState == uq.config.constant.TYPE_CROP_RED_PACKET_SPECOES.COMMAND then
        self._txtInputTittle:setString(StaticData["local_text"]["chat.click.input.command"])
        self._txtInputPrompt:setString(StaticData["local_text"]["chat.input.command"])
        self._btnRedCommand:setContentSize(cc.size(81, 79))
        self._btnRedCommand:loadTextures('img/common/ui/g02_000059.png', 'img/common/ui/g02_000059.png')
        self._txtCommand:setColor(uq.parseColor("#FEFDDD"))
        self._txtCommand:setFontSize(30)
    elseif self._btnState == uq.config.constant.TYPE_CROP_RED_PACKET_SPECOES.ORIDINARY then
        self._txtInputTittle:setString(StaticData["local_text"]["chat.click.input.desc"])
        self._txtInputPrompt:setString(StaticData["local_text"]["chat.input.desc"])
        self._btnRedOrdinary:setContentSize(cc.size(81, 79))
        self._btnRedOrdinary:loadTextures('img/common/ui/g02_000058.png', 'img/common/ui/g02_000058.png')
        self._txtOrdinary:setColor(uq.parseColor("#FEFDDD"))
        self._txtOrdinary:setFontSize(30)
    end
end

function CropRedbag:onRedPreview(event)
    if event.name ~= "ended" then
        return
    end

    uq.ModuleManager:getInstance():show(uq.ModuleManager.CROP_REDBAG_REWARD, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
end

function CropRedbag:onReduce(event)
    if event.name ~= "ended" then
        return
    end

    local num = tonumber(self._txtRedSend:getString())
    if num == 0 then
        uq.fadeInfo(StaticData['local_text']['chat.red.packet.send.num.min'])
        return
    end

    num = num - 1
    self._txtRedSend:setString(num)
end

function CropRedbag:onIncrease(event)
    if event.name ~= "ended" then
        return
    end

    local num = tonumber(self._txtRedSend:getString())
    if num >= self._redPacketNumData[1]['value'] then
        uq.fadeInfo(StaticData['local_text']['chat.red.packet.send.num.max'])
        return
    end

    num = num + 1
    self._txtRedSend:setString(num)
end

function CropRedbag:onRedOrdinary(event)
    if event.name ~= "ended" then
        return
    end
    self._btnState = uq.config.constant.TYPE_CROP_RED_PACKET_SPECOES.ORIDINARY

    self:refreshBtn()
end

function CropRedbag:onRedCommand(event)
    if event.name ~= "ended" then
        return
    end
    self._btnState = uq.config.constant.TYPE_CROP_RED_PACKET_SPECOES.COMMAND

    self:refreshBtn()
end

function CropRedbag:onReset(event)
    if event.name ~= "ended" then
        return
    end

    self:disposeSelf()
end

function CropRedbag:onSend(event)
    if event.name ~= "ended" then
        return
    end

    local num = tonumber(self._txtRedSend:getString())
    if num == 0 then
        uq.fadeInfo(StaticData['local_text']['chat.red.packet.send.num.min'])
        return
    end

    if self._richTextContent == '' then
        uq.fadeInfo(StaticData['local_text']['crop.redbag.content.not'])
        return
    end

    if string.utfLen(self._richTextContent) > 18 then
        uq.fadeInfo(StaticData['local_text']['chat.red.packet.content.long'])
        return
    end

    local res_num = uq.cache.role:getResNum(uq.config.constant.COST_RES_TYPE.MATERIAL, 7)
    local has_crop = uq.cache.role:hasCrop()
    local send_num = uq.cache.crop._redbagSendNum

    if num > self._redPacketNumData[1]['value'] - send_num then
        uq.fadeInfo(StaticData['local_text']['chat.red.packet.send.num.max'])
        return
    end

    if not has_crop then
        uq.fadeInfo(StaticData['local_text']['crop.redbag.apply.not'])
        return
    end

    if res_num <= 0 then
        uq.fadeInfo(StaticData['local_text']['crop.redbag.metrial.not'])
        return
    end

    if send_num >= self._redPacketNumData[1]['value'] then
        uq.fadeInfo(StaticData['local_text']['crop.redbag.send.num.not'])
        return
    end

    local data = {
        num             = tonumber(self._txtRedSend:getString()),
        redbag_type     = self._btnState,
        msg_len         = string.len(self._richTextContent),
        msg             = self._richTextContent
    }
    network:sendPacket(Protocol.C_2_S_CROP_REDBAG_SEND, data)
end

return CropRedbag