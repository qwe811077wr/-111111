local MailWrite = class("MailWrite", require('app.base.PopupBase'))

MailWrite.RESOURCE_FILENAME = "mail/MailWrite.csb"
MailWrite.RESOURCE_BINDING = {
    ["Image_4_0_0_0"] = {["varname"] = "_imgReceiver"},
    ["Image_4_0_0"]   = {["varname"] = "_imgTitle"},
    ["Image_4_0"]     = {["varname"] = "_imgContent"},
    ["Button_1"]      = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onClose"}}},
    ["Button_3_0"]    = {["varname"] = "_btnSend",["events"] = {{["event"] = "touch",["method"] = "onSend"}}},
    ["Button_2"]      = {["varname"] = "_btnShowRecentContact",["events"] = {{["event"] = "touch",["method"] = "onShowRecentContact"}}},
    ["Node_1"]        = {["varname"] = "_nodeRecentContact"},
    ["Image_3"]       = {["varname"] = "_imgRecentContact"}
}

function MailWrite:ctor(name, params)
    MailWrite.super.ctor(self, name, params)

    self._isHide = true
    self._recentContanct = uq.cache.mail._recentContanct
    self._nodeRecentContact:setVisible(false)
end

function MailWrite:init()
    self:centerView()
    self:setLayerColor(0)
    self:parseView()
    self:setTouchClose(false)
    self:createEditbox()
    self:initRecentContactList()
    self:initProtocol()
end

function MailWrite:initProtocol()
    self._eventTag = 'mailSend' .. tostring(self)
    network:addEventListener(Protocol.S_2_C_MAIL_SEND, handler(self, self._mailSend), self._eventTag)
end

function MailWrite:_mailSend(msg)
    if msg.data.ret == 0 then
        uq.cache.mail:addContanct(self._receiver)
        uq.fadeInfo(StaticData["local_text"]["mail.send.success"])
    else
        uq.fadeInfo(StaticData["local_text"]["mail.send.fail"])
    end
end

function MailWrite:createEditbox()
    local size = self._imgReceiver:getContentSize()
    self._editBoxReceiver = ccui.EditBox:create(cc.size(size.width, size.height + 2), '')
    self._editBoxReceiver:setAnchorPoint(cc.p(0.5, 0.5))
    self._editBoxReceiver:setFontName("font/hwkt.ttf")
    self._editBoxReceiver:setFontSize(24)
    self._editBoxReceiver:setFontColor(cc.c3b(102, 0, 0))
    self._editBoxReceiver:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._editBoxReceiver:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
    self._editBoxReceiver:setPosition(cc.p(size.width / 2, size.height / 2 + 2))
    self._editBoxReceiver:setPlaceholderFontName("font/hwkt.ttf")
    self._editBoxReceiver:setPlaceholderFontSize(24)
    self._editBoxReceiver:setPlaceHolder(StaticData['local_text']['mail.input.receiver'])
    self._editBoxReceiver:setPlaceholderFontColor(cc.c3b(121, 129, 129))
    self._editBoxReceiver:registerScriptEditBoxHandler(function(event, sender) self:editboxReceiverHandle(event, sender) end)
    self._imgReceiver:addChild(self._editBoxReceiver)

    local size = self._imgTitle:getContentSize()
    self._editBoxTitle = ccui.EditBox:create(cc.size(size.width, size.height + 2), '')
    self._editBoxTitle:setAnchorPoint(cc.p(0.5, 0.5))
    self._editBoxTitle:setFontName("font/hwkt.ttf")
    self._editBoxTitle:setFontSize(24)
    self._editBoxTitle:setFontColor(cc.c3b(31, 49, 51))
    self._editBoxTitle:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._editBoxTitle:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
    self._editBoxTitle:setPosition(cc.p(size.width / 2, size.height / 2 + 2))
    self._editBoxTitle:setPlaceholderFontName("font/hwkt.ttf")
    self._editBoxTitle:setPlaceholderFontSize(24)
    self._editBoxTitle:setPlaceHolder(StaticData['local_text']['mail.input.title'])
    self._editBoxTitle:setPlaceholderFontColor(cc.c3b(121, 129, 129))
    self._imgTitle:addChild(self._editBoxTitle)

    local size = self._imgContent:getContentSize()
    self._editBoxContent = ccui.EditBox:create(cc.size(size.width, size.height), '')
    self._editBoxContent:setAnchorPoint(cc.p(0.5, 0.5))
    self._editBoxContent:setFontName("font/hwkt.ttf")
    self._editBoxContent:setFontSize(24)
    self._editBoxContent:setFontColor(cc.c3b(31, 49, 51))
    self._editBoxContent:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._editBoxContent:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
    self._editBoxContent:setPosition(cc.p(size.width / 2, size.height / 2))
    self._editBoxContent:registerScriptEditBoxHandler(function(event, sender) self:editboxHandle(event, sender) end)
    self._imgContent:addChild(self._editBoxContent, -1)

    self._content = ''
    self._richText = uq.RichText:create()
    self._richText:setAnchorPoint(cc.p(0, 1))
    self._richText:setDefaultFont("font/hwkt.ttf")
    self._richText:setFontSize(24)
    self._richText:setContentSize(cc.size(size.width - 20, size.height / 2 ))
    self._richText:setMultiLineMode(true)
    self._richText:setTextColor(cc.c3b(121, 129, 129))
    self._richText:setPosition(cc.p(20, size.height - 10))
    self._richText:ignoreContentAdaptWithSize(false)
    self._richText:setText(StaticData['local_text']['mail.input.content'])
    self._imgContent:addChild(self._richText)
end

function MailWrite:editboxReceiverHandle(event, sender)
    if event == "began" then
        self._isHide = true
        self._nodeRecentContact:setVisible(false)
    end
end

function MailWrite:editboxHandle(event, sender)
    if event == "began" then
        self._editBoxContent:setText(self._content)
        self._richText:setText('')
        self._richText:setTextColor(cc.c3b(31, 49, 51))
    elseif event == "ended" then
    elseif event == "return" then
        local txt = self._editBoxContent:getText()
        self._content = txt
        self._richText:setText(txt)

        self._editBoxContent:setText('')
        if self._content == '' then
            self._richText:setTextColor(cc.c3b(121, 129, 129))
            self._richText:setText(StaticData['local_text']['mail.input.content'])
        end
    end
end

function MailWrite:onClose(event)
    if event.name == "ended" then
        network:removeEventListenerByTag(self._eventTag)

        self:disposeSelf()
    end
end

function MailWrite:onSend(event)
    if event.name == "ended" then
        self._receiver = self._editBoxReceiver:getText()
        local title    = self._editBoxTitle:getText()
        local content  = self._content
        if uq.isLimiteName(self._receiver) then
            uq.fadeInfo(StaticData["local_text"]["login.please.name"])
            return
        end

        if self._receiver == '' then
            uq.fadeInfo(StaticData['local_text']['mail.receiver.not.none'], 0, 0)
            return
        end

        if self._receiver == uq.cache.role.name then
            uq.fadeInfo(StaticData['local_text']['mail.send.role.mine'])
            return
        end

        if title == '' then
            uq.fadeInfo(StaticData['local_text']['mail.title.not.none'], 0, 0)
            return
        end

        if content == '' then
            uq.fadeInfo(StaticData['local_text']['mail.content.not.none'], 0, 0)
            return
        end

        if uq.hasKeyWord(self._receiver) or uq.hasKeyWord(title) or uq.hasKeyWord(content) then
            uq.fadeInfo(StaticData["local_text"]["label.screen.word"])
            return
        end

        if string.utfLen(title) > 7 then
            uq.fadeInfo(StaticData['local_text']['mail.title.long'], 0, 0)
            return
        end

        local data = {
            recver_name_len = string.len(self._receiver),
            recver_name = self._receiver,
            title_len = string.len(title),
            title = title,
            content_len = string.len(content),
            content = content,
        }
        network:sendPacket(Protocol.C_2_S_MAIL_SEND, data)
    end
end

function MailWrite:setSender(name)
    self._editBoxReceiver:setText(name)
end

function MailWrite:onShowRecentContact(event)
    if event.name ~= "ended" then
        return
    end

    if self._isHide then
        self._isHide = false
        self._recentContanct = uq.cache.mail._recentContanct
        self._nodeRecentContact:setVisible(true)
        self._listView:reloadData()
        return
    end
    self._isHide = true
    self._nodeRecentContact:setVisible(false)
end

function MailWrite:initRecentContactList()
    local viewSize = self._imgRecentContact:getContentSize()
    self._listView = cc.TableView:create(cc.size(viewSize.width, viewSize.height))
    self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listView:setPosition(cc.p(0, 0))
    self._listView:setDelegate()
    self._listView:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._listView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._listView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._listView:reloadData()
    self._imgRecentContact:addChild(self._listView)
end

function MailWrite:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
    local name = self._recentContanct[index]
    self:setSender(name)
end

function MailWrite:cellSizeForTable(view, idx)
    return 478, 35
end

function MailWrite:numberOfCellsInTableView(view)
    return #self._recentContanct
end

function MailWrite:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_Item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_Item = uq.createPanelOnly("mail.MailWriteItem")
        cell:addChild(cell_Item)
    else
        cell_Item = cell:getChildByTag(1000)
    end

    cell_Item:setTag(1000)
    cell_Item:setData(self._recentContanct[index])

    local width, height = self:cellSizeForTable(view, idx)
    cell_Item:setPosition(cc.p(width / 2, height / 2))

    return cell
end

return MailWrite