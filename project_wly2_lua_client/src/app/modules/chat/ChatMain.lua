local ChatMain = class("ChatMain", require('app.base.ModuleBase'))

ChatMain.RESOURCE_FILENAME = "chat/Chat.csb"
ChatMain.RESOURCE_BINDING = {
    ["Node_head"]                                       = {["varname"] = "_nodeHead"},
    ["node_left_bottom"]                                = {["varname"] = "_nodeLeftBottom"},
    ["node_left_bottom/Image_39"]                       = {["varname"] = "_imgBottomBg"},
    ["node_left_bottom/Panel_1/Image_3"]                = {["varname"] = "_imgShowExpress"},
    ["node_left_bottom/Panel_1/Image_3/Button_2"]       = {["varname"] = "_btnExpress",["events"] = {{["event"] = "touch",["method"] = "onShowExpress",["sound_id"] = 0}}},
    ["node_left_bottom/Panel_1/Node_edit"]              = {["varname"] = "_nodeEdit"},
    ["node_left_bottom/Panel_1/Node_edit/Image_42"]     = {["varname"] = "_editImgBg"},
    ["node_left_bottom/Panel_1/Node_edit/Panel_2"]      = {["varname"] = "_panelEditBox"},
    ["node_left_bottom/Panel_1/Node_edit/Button_1"]     = {["varname"] = "_btnSend",["events"] = {{["event"] = "touch",["method"] = "onSend"}}},
    ["node_left_bottom/Panel_1/Node_edit/Image_6"]      = {["varname"] = "_imgChangeTalk"},
    ["node_left_bottom/Panel_1/Node_talk"]              = {["varname"] = "_nodeTalk"},
    ["node_left_bottom/Panel_1/Node_talk/Image_say"]    = {["varname"] = "_imgSay"},
    ["node_left_bottom/Panel_1/Node_talk/Image_6_0"]    = {["varname"] = "_imgChangeEdit"},
    ["node_left_bottom/Panel_3"]                        = {["varname"] = "_panelChannel"},
    ["node_left_bottom/Panel_3/button_red_packet"]      = {["varname"] = "_btnRedPacket",["events"] = {{["event"] = "touch",["method"] = "onOpenRedPacket"}}},
    ["node_left_bottom/Panel_3/Panel_1"]                = {["varname"] = "_panelItem"},
    ["node_left_bottom/Panel_21"]                       = {["varname"] = "_panelChatList"},
    ["node_left_bottom/Node_express"]                   = {["varname"] = "_nodeExpress"},
    ["node_left_bottom/Node_bubble"]                    = {["varname"] = "_nodeBubble"},
    ["Node_right_top"]                                  = {["varname"] = "_nodeRightTop"},
    ["Node_right_top/button_set"]                       = {["varname"] = "_btnSet",["events"] = {{["event"] = "touch",["method"] = "onSet"}}},
    ["Node_right_top/Node_1"]                           = {["varname"] = "_nodeFriend"},
    ["Node_right_top/Node_1/Text_rolenum"]              = {["varname"] = "_friendDesLabel"},
    ["Node_right_top/Node_1/Image_27"]                  = {["varname"] = "_imgFriendBg"},
    ["Node_right_top/Node_1/Panel_18"]                  = {["varname"] = "_panelFriend"},
    ["Node_right_top/Node_1/Button_22"]                 = {["varname"] = "_btnClean",["events"] = {{["event"] = "touch",["method"] = "onChatClean"}}},
}

function ChatMain:ctor(name, params)
    ChatMain.super.ctor(self, name, params)
    self._curChannel = params.chatChannel or uq.config.constant.TYPE_CHAT_CHANNEL.CC_WORLD

    ChatMain._tabTxt = {
        StaticData['local_text']["label.world"],
        StaticData['local_text']["chat.channel.nation"],
        StaticData['local_text']["label.crop"],
        StaticData['local_text']["crop.chat.private"],
        StaticData['local_text']["mail.type.game"],
    }

    ChatMain._constantTag = {
        uq.config.constant.TYPE_CHAT_CHANNEL.CC_WORLD,
        uq.config.constant.TYPE_CHAT_CHANNEL.CC_COUNTRY,
        uq.config.constant.TYPE_CHAT_CHANNEL.CC_TEAM,
        uq.config.constant.TYPE_CHAT_CHANNEL.CC_CONVERSATION,
        uq.config.constant.TYPE_CHAT_CHANNEL.CC_SYSTEM,
    }
end

function ChatMain:init()
    local top_ui = uq.ui.CommonHeaderUI:create()
    self._topUI = top_ui
    self._nodeHead:addChild(top_ui:getNode())
    self._chatData = {}
    self._chatItemArray = {}
    self._friendItemArray = {}
    self._isOpenTalk = false
    self._chatListViewMap = {}
    self:setContentSize(display.size)
    self:setPosition(display.center)
    self:parseView()
    self:adaptSize()
    self:createContentRichText()
    self:adaptBgSize()
    self:adaptNode()

    self:initChatPrivate()
    self:initChatList()
    self:createEditBox()
    self:createPageView()

    self:initChannelBtn()
    self:initChannelRed()

    self._nodeHead:setPosition(display.center)
    self._imgChangeTalk:setTouchEnabled(true)
    self._imgChangeTalk:addClickEventListener(function(sender)
        self._isOpenTalk = true
        self:setChatInputState()
    end)

    self._imgChangeEdit:setTouchEnabled(true)
    self._imgChangeEdit:addClickEventListener(function(sender)
        self._isOpenTalk = false
        self:setChatInputState()
    end)
    self._btnRedPacket:setVisible(false)
end

function ChatMain:adaptSize()
    local friend_bg_size = self._imgFriendBg:getContentSize()
    self._imgFriendBg:setContentSize(cc.size(friend_bg_size.width, CC_DESIGN_RESOLUTION.height - 60))  --70是顶部栏大小
    local friend_panel_size = self._panelFriend:getContentSize()
    self._panelFriend:setContentSize(cc.size(friend_panel_size.width, CC_DESIGN_RESOLUTION.height - 60 - 83))  --83是底部大小
end

function ChatMain:changeBottomSize()
    local width = display.width
    if self._curChannel == uq.config.constant.TYPE_CHAT_CHANNEL.CC_CONVERSATION then
        width = display.width - self._panelFriend:getContentSize().width
        width = width - 5
        self._imgSay:loadTexture("img/chat/s02_00071.png")
        if self._isOpenTalk then
            self:updateTalkPos(width)
        else
            self:updateEditPos(width)
        end
    else
        self._imgSay:loadTexture("img/chat/s02_00070.png")
        width = width - 40
        if self._isOpenTalk then
            self:updateTalkPos(width)
        else
            self:updateEditPos(width)
        end
    end
end

function ChatMain:updateTalkPos(width)
    self._imgShowExpress:setPositionX(width)
    width = width - self._imgShowExpress:getContentSize().width - 5 - self._imgSay:getPositionX()
    self._imgSay:setContentSize(cc.size(width, self._imgSay:getContentSize().height))
    self._imgSay:getChildByName("Text_des"):setPositionX(self._imgSay:getContentSize().width * 0.5)
end

function ChatMain:updateEditPos(width)
    self._btnSend:setPositionX(width)
    width = width - self._btnSend:getContentSize().width + 20
    self._imgShowExpress:setPositionX(width)
    width = width - self._imgShowExpress:getContentSize().width - 5 - self._editImgBg:getPositionX()
    self._editImgBg:setContentSize(cc.size(width, self._editImgBg:getContentSize().height))
    self._panelEditBox:setContentSize(cc.size(width - 2, self._panelEditBox:getContentSize().height))
    if self._chatEditBox then
        self._chatEditBox:setContentSize(cc.size(width - 7, self._chatEditBox:getContentSize().height))
    end
end

function ChatMain:initChatPrivate()
    self._chatPrivateList = uq.cache.chat._chatPrivateInfo
    self._chatPrivateListSearch = uq.cache.chat._chatPrivateInfoSearch
    self._curPrivateId = uq.cache.chat._curChatPrivateInfoId

    table.sort(self._chatPrivateList, function(a, b)
        return a.create_time > b.create_time
    end)

    self._chatPrivate = {}
    self._chatPrivate.content = {}
    if #self._chatPrivateList > 0 then
        self._chatPrivate = self._chatPrivateList[1]

        if self._chatPrivateListSearch[self._curPrivateId] then
            self._chatPrivate = self._chatPrivateListSearch[self._curPrivateId]
        end
        self._curPrivateId = self._chatPrivate.contact_id
        uq.cache.chat._curChatPrivateInfoId = self._curPrivateId
    end
    local str = StaticData['local_text']["chat.cell.friend"] .. string.format(StaticData['local_text']["chat.cell.title.des1"], 22, "#ffffff", #self._chatPrivateList)
    self._friendDesLabel:setHTMLText(str)
    self._chatData = self._chatPrivate.content
end

function ChatMain:onCreate()
    ChatMain.super.onCreate(self)

    self._serviceRefreshTag = services.EVENT_NAMES.ON_CHAT_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_CHAT_REFRESH, handler(self, self.refreshService), self._serviceRefreshTag)
    services:addEventListener(services.EVENT_NAMES.ON_CHAT_EDITBOX_TEXT_CHANGE, handler(self, self._onEditBoxTextChange), '_onChatEditBoxTextChange')
    services:addEventListener(services.EVENT_NAMES.ON_CHAT_REFRESH_CHANNEL, handler(self, self.refreshChannel), '_onChatRefreshChannel')
    services:addEventListener(services.EVENT_NAMES.ON_CHAT_BUBBLE_REFRESH, handler(self, self._onChatBubbleRefresh), '_onChatBubbleRefresh')
    network:addEventListener(Protocol.S_2_C_CROP_REDBAG_PICK, handler(self, self._onCropRedbagPick), '_onCropRedbagPick')

    self._eventTag = services.EVENT_NAMES.ON_CROP_REDBAG_COMMAND .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_CROP_REDBAG_COMMAND, handler(self, self._onCropRedbagCommand), self._eventTag)

    self._eventTag1 = services.EVENT_NAMES.ON_CHAT_CONVERSATION_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_CHAT_CONVERSATION_REFRESH, handler(self, self._onChatConversationRefresh), self._eventTag1)

    self:setBaseBgVisible(false)
end

function ChatMain:removeProtocolData()
    network:removeEventListenerByTag('_onCropRedbagPick')
    services:removeEventListenersByTag(self._serviceRefreshTag)
    services:removeEventListenersByTag("_onChatEditBoxTextChange")
    services:removeEventListenersByTag("_onChatBubbleRefresh")
    services:removeEventListenersByTag("_onChatRefreshChannel")
    services:removeEventListenersByTag(self._eventTag)
    services:removeEventListenersByTag(self._eventTag1)
end

function ChatMain:_onChatBubbleRefresh()
    for k, v in ipairs(self._chatItemArray) do
        local data = v:getData()
        if data and data.role_name == uq.cache.role.name then
            data.bubble_id = uq.cache.role.bubble_id
            v:setData(data)
        end
    end
end

function ChatMain:onExit()
    if self._topUI then
        self._topUI:dispose()
    end
    self._topUI = nil
    self:removeProtocolData()
    uq.TimerProxy:removeTimer("schedele_refresh_channel" .. tostring(self))
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CHAT_WRITE_FILE_DATA})
    ChatMain.super:onExit()
end

function ChatMain:refreshService(evt)
    self:refreshChannel(evt.count, evt.channel)

    uq.cache.chat._unReadMsgNum = 0
    self:showChannelRed(evt.channel)
end

function ChatMain:initChannelRed()
    local data = uq.cache.chat._chatChannelRedIndex
    if data[self._curChannel] ~= nil then
        data[self._curChannel].num = 0
    end
    for k, v in ipairs(self._tabModuleArray) do
        local channel = v:getTag()
        if data[channel] == nil or data[channel].num == 0 then
            v:getChildByName("Image_red"):setVisible(false)
        else
            v:getChildByName("Image_red"):setVisible(true)
            v:getChildByName("Image_red"):getChildByName("txt_num"):setString(data[channel].num)
        end
    end
end

function ChatMain:showChannelRed(channel)
    --在线且进入聊天界面红点
    local data = uq.cache.chat._chatChannelRedIndex
    local node = self._panelChannel:getChildByTag(channel)
    if channel == self._curChannel then
        if data[channel] ~= nil then
            data[channel].num = 0
        end
        node:getChildByName("Image_red"):setVisible(false)
    else
        node:getChildByName("Image_red"):setVisible(true)
        if data[channel] ~= nil then
            node:getChildByName("Image_red"):getChildByName("txt_num"):setString(data[channel].num)
        else
            node:getChildByName("Image_red"):getChildByName("txt_num"):setString("1")
        end
    end
end

function ChatMain:initChatList()
    local viewSize = self._panelFriend:getContentSize()
    self._listViewFriend = cc.TableView:create(cc.size(viewSize.width, viewSize.height))
    self._listViewFriend:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._listViewFriend:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listViewFriend:setPosition(cc.p(0, 0))
    self._listViewFriend:setDelegate()
    self._listViewFriend:registerScriptHandler(handler(self, self.tableCellTouchedFriend), cc.TABLECELL_TOUCHED)
    self._listViewFriend:registerScriptHandler(handler(self, self.cellSizeForTableFriend), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listViewFriend:registerScriptHandler(handler(self, self.tableCellAtIndexFriend), cc.TABLECELL_SIZE_AT_INDEX)
    self._listViewFriend:registerScriptHandler(handler(self, self.numberOfCellsInTableViewFriend), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._panelFriend:addChild(self._listViewFriend)
end

function ChatMain:createContentRichText()
    self._richTextContentRight = uq.RichText:create()
    self._richTextContentRight:setAnchorPoint(cc.p(0, 1))
    self._richTextContentRight:setDefaultFont("res/font/fzlthjt.ttf")
    self._richTextContentRight:setFontSize(24)
    self._richTextContentRight:setContentSize(cc.size(667, 50))
    self._richTextContentRight:setMultiLineMode(true)
    self._richTextContentRight:setPosition(cc.p(-display.width, display.height))
    self._richTextContentRight:ignoreContentAdaptWithSize(false)
    self._richTextContentRight:setWrapMode(1)
    self._nodeBubble:addChild(self._richTextContentRight)
end

function ChatMain:onClose(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

function ChatMain:initChannelBtn()
    self._tabModuleArray = {}
    local tab_item = self._panelChannel:getChildByName("Panel_1")
    local posx, posy = tab_item:getPosition()
    tab_item:removeSelf()
    local select_item = nil
    for k, v in ipairs(self._tabTxt) do
        local item = tab_item:clone()
        self._panelChannel:addChild(item)
        item:setTag(self._constantTag[k])
        item:getChildByName("txt"):setString(self._tabTxt[k])
        item:setPosition(posx, posy)
        item:setTouchEnabled(true)
        item:addClickEventListener(function(sender)
            uq.playSoundByID(uq.config.constant.COMMON_SOUND.CHANGE)
            self:onTabChanged(sender, true)
        end)
        if self._constantTag[k] == self._curChannel then
            select_item = item
        end
        posy = posy - item:getContentSize().height - 5
        table.insert(self._tabModuleArray, item)
    end
    self:onTabChanged(select_item, true)
end

function ChatMain:onTabChanged(sender, stop_action)
    local tag = sender:getTag()
    if self._curChannel == tag and not stop_action then
        return
    end
    self._curChannel = tag
    for k, v in ipairs(self._tabModuleArray) do
        v:getChildByName("img_select1"):setVisible(false)
        v:getChildByName("img_select2"):setVisible(false)
    end
    local img1 = sender:getChildByName("img_select1")
    local img2 = sender:getChildByName("img_select2")
    img1:setVisible(true)
    img2:setVisible(true)
    if not stop_action then
        img1:runAction(cc.RotateBy:create(0.15, -180))
        img2:runAction(cc.RotateBy:create(0.15, 180))
    end
    self:ChannelChangedRefresh()
end

function ChatMain:getChatDataCount(channel)
    local channel_id =self._curChannel
    if channel then
        channel_id = channel
    end
    if channel_id == uq.config.constant.TYPE_CHAT_CHANNEL.CC_BOARD then
        if self._addBoardData then
            return #self._addBoardData
        end
    else
        if self._chatData then
            return #self._chatData
        end
    end
    return 0
end

function ChatMain:getChatItem(index, channel)
    local chat_item = nil
    local channel_id = self._curChannel
    if channel then
        channel_id = channel
    end

    if channel_id == uq.config.constant.TYPE_CHAT_CHANNEL.CC_BOARD then
        if self._addBoardData and self._addBoardData[index] then
            chat_item = uq.createPanelOnly("chat.ChatCell")
            chat_item:setData(self._addBoardData[index])
        end
    else
        if self._chatData and self._chatData[index] then
            if channel_id == uq.config.constant.TYPE_CHAT_CHANNEL.CC_SYSTEM then
                chat_item = uq.createPanelOnly("chat.SystemCell")
            else
                chat_item = uq.createPanelOnly("chat.ChatCell")
            end
            if self._chatData[index].role_name == uq.cache.role.name then
                self._chatData[index].bubble_id = uq.cache.role.bubble_id
            end
            chat_item:setData(self._chatData[index])
        end
    end

    return chat_item
end

function ChatMain:getChatItemSize(index, channel)
    local channel_id = self._curChannel
    if channel then
        channel_id = channel
    end
    if channel_id == uq.config.constant.TYPE_CHAT_CHANNEL.CC_SYSTEM then
        local chat_data = self._chatData[index]
        self:setRichText(chat_data.content, cc.size(1110, 50))
        local height = self._richSize.height
        if height < 80 then
            height = 80
        end
        return 1216, height
    elseif channel_id == uq.config.constant.TYPE_CHAT_CHANNEL.CC_BOARD then
        if self._addBoardData[index].content_type ~= uq.config.constant.TYPE_CHAT_CONTENT.CCT_CHAT_CONTENT then
            return 880, 160
        else
            local width = 880
            local height = self:getContentHeight(self._addBoardData[index])
            return width, height
        end
    elseif self._chatData[index].content_type == uq.config.constant.TYPE_CHAT_CONTENT.CCT_CHAT_BATTLE_SHARE then
        return 880, 250
    else
        local width = 880
        local height = self:getContentHeight(self._chatData[index])
        return width, height
    end
end

function ChatMain:setChatItemPos(item, width, height, index, channel)
    local channel_id = self._curChannel
    if channel then
        channel_id = channel
    end
    if channel_id == uq.config.constant.TYPE_CHAT_CHANNEL.CC_SYSTEM then
        item:setPosition(cc.p(width / 2, height / 2))
    else
        item:setPositionX(width / 2)
        item:setPositionY(height - 60)
        if channel_id == uq.config.constant.TYPE_CHAT_CHANNEL.CC_BOARD or self._chatData[index].content_type == uq.config.constant.TYPE_CHAT_CONTENT.CCT_CHAT_BATTLE_SHARE then
            item:setPositionY(height - 70)
        end
    end
end

function ChatMain:refreshChannel(count, channel)
    local channel_id = self._curChannel
    if channel ~= nil then
        channel_id = channel
    end
    if channel_id == uq.config.constant.TYPE_CHAT_CHANNEL.CC_SYSTEM then
        self._chatData = uq.cache.chat:getChannelData(channel_id)
    else
        self._chatData = uq.cache.chat:getChannelData(channel_id)
        if channel_id == uq.config.constant.TYPE_CHAT_CHANNEL.CC_BOARD then
            self:initRedbagData()
        elseif channel_id == uq.config.constant.TYPE_CHAT_CHANNEL.CC_CONVERSATION then
            self:initChatPrivate()
        end

        self._listViewFriend:reloadData()
    end

    if count == nil then
        self:refreshListView()
    else
        self:listViewAddChat(count, channel)
    end

    uq.cache.chat._unReadMsgNum = 0
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CHAT_REFRESH_PROMPT_RED_NUM, {}})
end

--向某一个频道添加新的chat_item
function ChatMain:listViewAddChat(count, channel)
    if not self._chatListViewMap[channel] then
        return
    end
    local finish_count = 0
    local bottom_item_index = 0
    local bottom_item = self._chatListViewMap[channel]:getBottommostItemInCurrentView()
    if bottom_item then
        bottom_item_index = self._chatListViewMap[channel]:getIndex(bottom_item) + 1
    end
    local need_to_bottom = bottom_item_index == #self._chatListViewMap[channel]:getChildren()

    local total_height = 0
    while finish_count < count do
        local list_items_count = #self._chatListViewMap[channel]:getChildren()
        if list_items_count > 100 then
            self._chatListViewMap[channel]:removeItem(0)
        end
        local index = self:getChatDataCount(channel) - finish_count
        local item = self:getChatItem(index, channel)
        if item == nil then
            return
        end
        local width, height = self:getChatItemSize(index, channel)
        self:setChatItemPos(item, width, height, index, channel)
        local widget = ccui.Widget:create()
        widget:setContentSize(cc.size(width, height))
        widget:addChild(item)
        widget:setTouchEnabled(true)
        self._chatListViewMap[channel]:pushBackCustomItem(widget)

        finish_count = finish_count + 1
        total_height = total_height + height
    end

    if need_to_bottom then
        self._chatListViewMap[channel]:jumpToBottom()
    else
        local cur_pos_y = self._chatListViewMap[channel]:getInnerContainerPosition().y - total_height
        local offset_y = self._chatListViewMap[channel]:getContentSize().height - self._chatListViewMap[channel]:getInnerContainerSize().height - total_height
        local percent = offset_y == 0 and 100 or (offset_y - cur_pos_y) / offset_y
        if percent > 1 then
            percent = 1
        elseif percent < 0 then
            percent = 0
        end
        self._chatListViewMap[channel]:jumpToPercentVertical(percent * 100)
    end
end

--完整刷新某一个频道
function ChatMain:refreshListView()

    self._co = coroutine.create(function()
            if not self._chatListViewMap[self._curChannel] then
                return
            end
            self._chatListViewMap[self._curChannel]:removeAllItems()
            local count = 0
            local index = self:getChatDataCount()
            local limit = 0
            if self._curChannel == uq.config.constant.TYPE_CHAT_CHANNEL.CC_SYSTEM then
                limit = 0
            end
            local first_time = true
            while true do
                local list_items_count = #self._chatListViewMap[self._curChannel]:getChildren()
                if list_items_count > 100 then
                    return
                end
                local item = self:getChatItem(index)
                if item == nil then
                    return
                end
                local width, height = self:getChatItemSize(index)
                self:setChatItemPos(item, width, height, index)
                local widget = ccui.Widget:create()
                widget:setContentSize(cc.size(width, height))
                widget:addChild(item)
                widget:setTouchEnabled(true)
                self._chatListViewMap[self._curChannel]:insertCustomItem(widget, 0)
                table.insert(self._chatItemArray, item)
                index = index - 1
                count = count + 1
                local cur_pos = self._chatListViewMap[self._curChannel]:getInnerContainerPosition()
                local offset_y = self._chatListViewMap[self._curChannel]:getContentSize().height - self._chatListViewMap[self._curChannel]:getInnerContainerSize().height - height
                local percent = offset_y == 0 and 100 or (offset_y - cur_pos.y) / offset_y
                self._chatListViewMap[self._curChannel]:jumpToPercentVertical(percent > 1 and 100 or percent * 100)
                if count > limit then
                    count, limit = coroutine.yield()
                end
            end
        end)

    coroutine.resume(self._co)

    uq.TimerProxy:removeTimer("schedele_refresh_channel" .. tostring(self))
    uq.TimerProxy:addTimer("schedele_refresh_channel" .. tostring(self), function()
        if coroutine.resume(self._co, 0, 0) == false then
            uq.TimerProxy:removeTimer("schedele_refresh_channel" .. tostring(self))
        end
    end, 0.01 , -1)
end

function ChatMain:refreshPage()
    self._chatEditBox:setEnabled(true)
    self:setChatInputState()
    self._nodeFriend:setVisible(false)
    if self._curChannel == uq.config.constant.TYPE_CHAT_CHANNEL.CC_SYSTEM then
        self._nodeTalk:setVisible(false)
        self._imgShowExpress:setVisible(false)
        self._nodeEdit:setVisible(false)
        self._chatEditBox:setEnabled(false)
        self._imgBottomBg:setVisible(false)
    elseif self._curChannel == uq.config.constant.TYPE_CHAT_CHANNEL.CC_CONVERSATION then
        self._nodeFriend:setVisible(true)
    end
end

function ChatMain:setChatInputState()
    local is_open_speak = not self._isOpenTalk
    self._nodeTalk:setVisible(self._isOpenTalk)
    self._nodeEdit:setVisible(is_open_speak)
    self._imgShowExpress:setVisible(true)
    self._imgBottomBg:setVisible(true)
    self:changeBottomSize()
end

function ChatMain:scrollToBottom(listview)
    if listview:getContentSize().height < listview:getViewSize().height then
    else
        listview:setContentOffset(cc.p(0, 0))
    end
end

function ChatMain:ChannelChangedRefresh()
    self:refreshPage()
    if not self._chatListViewMap[self._curChannel] then
        self._chatListViewMap[self._curChannel] = ccui.ListView:create()
        self._chatListViewMap[self._curChannel]:setContentSize(cc.size(display.width - self._panelChatList:getPositionX() , self._panelChatList:getContentSize().height))
        self._chatListViewMap[self._curChannel]:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self._chatListViewMap[self._curChannel]:setBounceEnabled(true)
        self._chatListViewMap[self._curChannel]:setScrollBarEnabled(false)
        self._panelChatList:addChild(self._chatListViewMap[self._curChannel])
        self:refreshChannel()
    end
    for k, v in pairs(self._chatListViewMap) do
        v:setVisible(k == self._curChannel)
    end
    self:showChannelRed(self._curChannel)
end

function ChatMain:tableCellTouched(view, cell, touch)
    local index = cell:getIdx() + 1

    if self._curChannel == uq.config.constant.TYPE_CHAT_CHANNEL.CC_BOARD then
        local cell_item = cell:getChildByTag(1000)
        local bg = cell_item._imgRedPacketLeft
        local size = bg:getContentSize()
        local rect = cc.rect(0, 0, size.width, size.height)
        local click_pos = bg:convertToNodeSpace(touch:getLocation())

        if cc.rectContainsPoint(rect, click_pos) then
            if self._addBoardData[index].type == uq.config.constant.TYPE_CROP_RED_PACKET_SPECOES.COMMAND and cell_item._isExistEditBox then
                services:dispatchEvent({name = services.EVENT_NAMES.ON_CROP_REDBAG_COMMAND_EDITBOX_OPEN, data = self._addBoardData[index].id})
                return
            end
            self:_onCropRedbagTouch(index)
        end
    end
end

function ChatMain:_onCropRedbagTouch(index)
    if self._curChannel == uq.config.constant.TYPE_CHAT_CHANNEL.CC_BOARD then
        if self._addBoardData[index].content_type == uq.config.constant.TYPE_CHAT_CONTENT.CCT_CHAT_REDBAG then
            --已失效
            if self._addBoardData[index].expire_time == 0 then
                uq.fadeInfo(StaticData['local_text']['chat.red.packet.lose.efficacy'])
                return
            end
            --已抢过
            if self._addBoardData[index].has_picked == uq.config.constant.TYPE_CROP_RED_PACKET_HAS.HAS then
                self:showCropRedbagDetail(index)
            else
                --已抢完
                if self._addBoardData[index].left_num == 0 then
                    self:showCropRedbagDetail(index)
                    return
                end
                --抢普通红包
                if self._addBoardData[index].type == uq.config.constant.TYPE_CROP_RED_PACKET_SPECOES.ORIDINARY then
                    self:sendPacketByRedbagPick(self._addBoardData[index])
                end
            end
        end
    end
end

function ChatMain:showCropRedbagDetail(index)
    network:sendPacket(Protocol.C_2_S_CROP_REDBAG_DETAIL,{id = self._addBoardData[index].id})

    uq.ModuleManager:getInstance():show(uq.ModuleManager.CROP_REDBAG_RECEIVE_INFO, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
end

function ChatMain:setRichText(content, size)
    local rich_content = content
    --匹配表情
    for s in string.gmatch(content, '%/%l%l') do
        for i=101, 130 do
            local data = StaticData['chat']['emoji'][i]
            if s == data['name'] then
                rich_content = string.gsub(rich_content, s, "<img img/chat/"..data['icon']..">")
                break
            end
        end
    end
    size = size or cc.size(667, 50)
    self._richTextContentRight:setContentSize(size)
    self._richTextContentRight:setText(rich_content)
    self._richTextContentRight:formatText()
    self._richSize = self._richTextContentRight:getTextRealSize()
end

function ChatMain:getContentHeight(chat_data)
    local height = 0
    if self:getExpressType(chat_data.content) == 2 then
        height = 83 - 63 + 160
    else
        self:setRichText(chat_data.content)
        --63为chatCell中会话框默认的UI大小，160为(ChatCell层的大小120 + 富文本距离上下的间隔总和20 + 气泡的边框20)
        height = self._richSize.height - 63 + 160
    end
    if height <= 120 then
        height = 120
    end
    return height
end

function ChatMain:tableCellTouchedFriend(view, cell)
    local index = cell:getIdx() + 1
    local last_private_id = self._curPrivateId
    self._curPrivateId = self._chatPrivateList[index].contact_id
    uq.cache.chat._curChatPrivateInfoId = self._curPrivateId
    self._chatPrivate = self._chatPrivateList[index]
    self._chatData = self._chatPrivate.content
    if last_private_id ~= self._curPrivateId then
        self:refreshChannel()
    end
    for k, v in ipairs(self._friendItemArray) do
        v:setSelect(self._curPrivateId)
    end
end

function ChatMain:cellSizeForTableFriend(view, idx)
    return 318, 130
end

function ChatMain:numberOfCellsInTableViewFriend(view)
    return #self._chatPrivateList
end

function ChatMain:tableCellAtIndexFriend(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("chat.FriendCell")
        cell:addChild(cell_item)
        table.insert(self._friendItemArray, cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end

    local width, height = self:cellSizeForTableFriend(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))
    cell_item:setTag(1000)
    cell_item:setData(self._chatPrivateList[index])
    cell_item:setSelect(self._curPrivateId)

    return cell
end

function ChatMain:createEditBox()
    local size = self._panelEditBox:getContentSize()
    self._chatEditBox = ccui.EditBox:create(cc.size(size.width - 5, size.height - 5), '')
    self._chatEditBox:setAnchorPoint(cc.p(0, 0.5))
    self._chatEditBox:setFontName("font/fzlthjt.ttf")
    self._chatEditBox:setFontSize(20)
    self._chatEditBox:setFontColor(uq.parseColor("#63686A"))
    self._chatEditBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._chatEditBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self._chatEditBox:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end)
    self._chatEditBox:setPosition(cc.p(0, size.height / 2))
    self._chatEditBox:setPlaceholderFontName("font/fzlthjt.ttf")
    self._chatEditBox:setPlaceholderFontSize(20)
    self._chatEditBox:setPlaceHolder(StaticData['local_text']['chat.edit.des'])
    self._chatEditBox:setPlaceholderFontColor(uq.parseColor("#63686A"))
    self._panelEditBox:addChild(self._chatEditBox)
end

function ChatMain:editboxHandle(strEventName, sender)
    if strEventName == "began" then
    elseif strEventName == "ended" then
        if self._chatEditBox:getText() == '' then
        end
    elseif strEventName == 'ended' then
        self._chatExpress:setVisible(false)
    elseif strEventName == 'return' then
        self._chatExpress:setVisible(false)
    end
end

function ChatMain:_onEditBoxTextChange(msg)
    if msg.data.type == 1000 then
        self._chatEditBox:setText(self._chatEditBox:getText() .. msg.data.content)
    else
        self._chatContent = msg.data.content

        local info = {
            contact_id = 1,
            contact_name = '',
            server_id = '0'
        }
        if self._curChannel == uq.config.constant.TYPE_CHAT_CHANNEL.CC_CONVERSATION and #self._chatPrivateList > 0 then
            info.contact_id = self._chatPrivate.contact_id
            info.contact_name = self._chatPrivate.contact_name
        end
        self:sendChatMsg(info)
    end
end

function ChatMain:sendChatMsg(info)
    if CC_SHOW_FPS and self._chatContent == 'debug' then
        uq.ModuleManager:getInstance():createDebugView()
        return
    end

    if uq.cache.role:level() < 2 then
        uq.fadeInfo(string.format(StaticData['local_text']['fly.nail.module.des4'], 2))
        self:emptyEditBox()
        return
    elseif self._curChannel == uq.config.constant.TYPE_CHAT_CHANNEL.CC_BOARD then
        if not uq.cache.role:hasCrop() then
            uq.fadeInfo(StaticData['local_text']['arena.rank.crop.not'])
            self:emptyEditBox()
            return
        end

        if uq.cache.role:level() < 10 then
            uq.fadeInfo(string.format(StaticData['local_text']['fly.nail.module.des4'], 10))
            self:emptyEditBox()
            return
        end
    end

    if not self._chatPrivate.contact_id and self._curChannel == uq.config.constant.TYPE_CHAT_CHANNEL.CC_CONVERSATION then
        uq.fadeInfo(StaticData['local_text']['chat.private.person.not'])
        self:emptyEditBox()
        return
    end

    local chat_server_id = info.server_id
    local chat_name = info.contact_name
    local data = {
        msg_type = self._curChannel,
        server_id_len = string.len(chat_server_id),
        server_id = chat_server_id,
        contact_role_id = info.contact_id,
        contact_role_name_len = string.len(chat_name),
        contact_role_name = chat_name,
        content_type = uq.config.constant.TYPE_CHAT_CONTENT.CCT_CHAT_CONTENT,
        content = self._chatContent
    }
    network:sendPacket(Protocol.C_2_S_CHAT_MSG, data)

    self:emptyEditBox()
end

function ChatMain:emptyEditBox()
    self._chatEditBox:setText('')
end

function ChatMain:onSend(event)
    if event.name == "ended" then
        self._chatContent = self._chatEditBox:getText()
        if self._chatContent == '' then
            return
        end
        local str = string.gsub(self._chatContent, "[ \t\n\r]+$", "")
        if str == '' then
            self:emptyEditBox()
            uq.fadeInfo(StaticData["local_text"]["chat.nill.msg"])
            return
        end
        if uq.hasKeyWord(str) then
            uq.fadeInfo(StaticData["local_text"]["label.screen.word"])
            return
        end
        local info = {
            contact_id = 1,
            contact_name = '',
            server_id = '0'
        }
        if self._curChannel == uq.config.constant.TYPE_CHAT_CHANNEL.CC_CONVERSATION and #self._chatPrivateList > 0 then
            info.contact_id = self._chatPrivate.contact_id
            info.contact_name = self._chatPrivate.contact_name
        end

        self:sendChatMsg(info)
    end
end

function ChatMain:onChatClean(event)
    if event.name == "ended" then
        -- uq.ModuleManager:getInstance():show(uq.ModuleManager.CHAT_CLEAN, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
    end
end

function ChatMain:createPageView()
    self._chatExpress = uq.createPanelOnly("chat.ChatExpress")
    self._chatExpress:setVisible(false)
    self._nodeExpress:addChild(self._chatExpress)

    self._chatBubble = uq.createPanelOnly("chat.ChatBubble")
    self._chatBubble:setVisible(false)
    self._nodeBubble:addChild(self._chatBubble)
end

--聊天表情
function ChatMain:onShowExpress(event)
    if event.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    if self._chatExpress:isVisible() then
        self._chatExpress:setVisible(false)
    else
        self._chatExpress:setVisible(true)
        self._chatExpress:onOpen()
    end
end

function ChatMain:onSet(event)
    if event.name ~= "ended" then
        return
    end
    self._chatBubble:setVisible(true)
end

function ChatMain:getExpressType(content)
    for s in string.gmatch(content, '%/%l%l') do
        for i=101, 130 do
            if s == StaticData['chat']['emoji'][i]['name'] then
                return uq.config.constant.TYPE_CHAT_EXSIT_EXPRESS.EXPRESS
            end
        end

        for j=201, 206 do
            if s == StaticData['chat']['emoji'][j]['name'] then
                return uq.config.constant.TYPE_CHAT_EXSIT_EXPRESS.BUCKET
            end
        end
    end
    return uq.config.constant.TYPE_CHAT_EXSIT_EXPRESS.NONE
end

function ChatMain:onOpenRedPacket(event)
    if event.name ~= "ended" then
        return
    end

    uq.ModuleManager:getInstance():show(uq.ModuleManager.CROP_REDBAG, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
end

function ChatMain:initRedbagData()
    self._addBoardData = {}
    self._boardData = uq.cache.crop._allRedbag

    self:addTypeToData(uq.config.constant.TYPE_CHAT_CONTENT.CCT_CHAT_REDBAG, self._boardData)

    self:initBoardData(self._addBoardData, self._chatData)
    self:initBoardData(self._addBoardData, self._boardData)

    table.sort(self._addBoardData,  function(item1, item2)
        return item1.create_time < item2.create_time
    end)
end

function ChatMain:addTypeToData(type, data)
    for k, v in pairs(data) do
        v.content_type = type
    end
end

function ChatMain:initBoardData(board, data)
    for k, v in pairs(data) do
        table.insert(board, v)
    end
end

function ChatMain:sendPacketByRedbagPick(redbag)
    --已抢完
    if redbag.left_num <= 0 then
        network:sendPacket(Protocol.C_2_S_CROP_REDBAG_DETAIL,{id = redbag.id})

        uq.ModuleManager:getInstance():show(uq.ModuleManager.CROP_REDBAG_RECEIVE_INFO, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
        return
    end

    if uq.cache.crop._redbagPickNum >= StaticData['types']['EnvelopesType'][1]['Type'][2]['value'] then
        uq.fadeInfo(StaticData['local_text']['crop.redbag.send.num.not'])
        return
    end
    --普通红包
    local content = ''

    self:sendRedbagCommandPick(redbag.id, content)
end

function ChatMain:_onCropRedbagCommand(msg)
    local data = msg.data

    self:sendRedbagCommandPick(data.id, data.command)
end

function ChatMain:sendRedbagCommandPick(red_id, content)
    local data = {
        id = red_id,
        msg_len = string.len(content),
        msg = content
    }
    network:sendPacket(Protocol.C_2_S_CROP_REDBAG_PICK, data)
end

function ChatMain:_onCropRedbagPick(msg)
    local pick_data = msg.data

    if pick_data.ret == uq.config.constant.TYPE_CROP_REDBAG_PICK.OK then
        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.CROP_REDBAG_RECEIVE, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
        panel:_onRedBagPick(pick_data)
        self:refreshBoardData(msg.data.id)
    elseif pick_data.ret == uq.config.constant.TYPE_CROP_REDBAG_PICK.NONE_LEFT then
        uq.fadeInfo(StaticData['local_text']['chat.red.packet.none'])
    elseif pick_data.ret == uq.config.constant.TYPE_CROP_REDBAG_PICK.INVALID_PASSWD then
        uq.fadeInfo(StaticData['local_text']['crop.redbag.command.not'])
    end
end

function ChatMain:refreshBoardData(id)
    local pick_num = uq.cache.crop._redbagPickNum
    for k, v in pairs(self._boardData) do
        if v.id == id then
            v.left_num = v.left_num - 1
            v.has_picked = uq.config.constant.TYPE_CROP_RED_PACKET_HAS.HAS

            pick_num = pick_num + 1
            if v.left_num <= 0 then
                v.left_num = 0
            end
            break
        end
    end
    uq.cache.crop._redbagPickNum = pick_num

    self:refreshChannel()
end

function ChatMain:_onChatConversationRefresh(msg)
    self._curChannel = uq.config.constant.TYPE_CHAT_CHANNEL.CC_CONVERSATION
    self._chatPrivateList = uq.cache.chat._chatPrivateInfo
    self._chatPrivate = msg.data

    table.sort(self._chatPrivateList, function(a, b)
        return a.create_time > b.create_time
    end)

    for k, v in ipairs(self._tabModuleArray) do
        local tag = v:getTag()
        if tag == uq.config.constant.TYPE_CHAT_CHANNEL.CC_CONVERSATION then
            self:onTabChanged(v, true)
            break
        end
    end
end

return ChatMain