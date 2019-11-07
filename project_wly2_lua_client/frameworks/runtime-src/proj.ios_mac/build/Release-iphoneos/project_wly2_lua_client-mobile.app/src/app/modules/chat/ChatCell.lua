local ChatCell = class("ChatCell", require('app.base.ChildViewBase'))

ChatCell.RESOURCE_FILENAME = "chat/ChatCell.csb"

function ChatCell:onCreate()
    self._nodeLeft = self._view:getChildByName('Node_1')
    self._nodeRight = self._view:getChildByName('Node_1_0')
    self._nodeTips = self._view:getChildByName('Node_tips')
    self._imgTips = self._nodeTips:getChildByName('Image_tips')
    self._panelTitleLeft = self._nodeLeft:getChildByName('panelTitleLeft')
    self._panelTitleRight = self._nodeRight:getChildByName('panelTitleRight')
    self._imgBgLeft = self._nodeLeft:getChildByName('Panel_14')
    self._imgBgRight = self._nodeRight:getChildByName('Panel_14')
    self._imgLeft = self._nodeLeft:getChildByName('Image_bg_left')
    self._imgLeft:onTouch(handler(self, self.onOpenInfo))
    self._imgRight = self._nodeRight:getChildByName('Image_bg_right')
    self._imgRight:onTouch(handler(self, self.onOpenInfo))
    self._imgRedPacketLeft = self._nodeLeft:getChildByName('Image_red_left')
    self._spriteLeft = self._imgLeft:getChildByName('sprite_img')
    self._sPriteRight = self._imgRight:getChildByName('sprite_img_right')
    self._imgRedPacketRight = self._nodeRight:getChildByName('Image_red_right')
    self._txtRedLeft = self._imgRedPacketLeft:getChildByName('Text_3_left')
    self._txtRedRight = self._imgRedPacketRight:getChildByName('Text_3')
    self._txtReceiveLeft = self._imgRedPacketLeft:getChildByName('Text_1_left')
    self._txtReceiveRight = self._imgRedPacketRight:getChildByName('Text_1')
    self._txtRedTypeLeft = self._imgRedPacketLeft:getChildByName('Text_2_left')
    self._txtRedTypeRight = self._imgRedPacketRight:getChildByName('Text_2')
    self._nodeEditLeft = self._imgRedPacketLeft:getChildByName('Node_2')
    self._nodeEditRight = self._imgRedPacketRight:getChildByName('Node_2_0')
    self._panelShareLeft = self._nodeLeft:getChildByName('Panel_left')
    self._panelShareLeft:onTouch(handler(self, self.onEnterBattle))
    self._panelShareRight = self._nodeRight:getChildByName('Panel_right')
    self._panelShareRight:onTouch(handler(self, self.onEnterBattle))
end

function ChatCell:ctor()
    ChatCell.super.ctor(self)
    self._commanderPath = {
        "img/chat/s01_00035.png",
        "img/chat/s01_00031.png",
        "img/chat/s01_00036.png",
        "img/chat/s01_00034.png",
    }

    self._RICH_TEXT_TYPE = {
        TITLE = 1,
        CONTENT = 2,
        RED = 3,
    }

    self._isLeft = true
    self._curBubbleId = 0
    self._redbagContent = ''
    self._nodeRight:setVisible(false)

    self._imgBgLeft:setSwallowTouches(false)
    self._imgBgRight:setSwallowTouches(false)
    self._imgLeft:setSwallowTouches(false)
    self._imgRight:setSwallowTouches(false)
    self._imgRedPacketLeft:setSwallowTouches(false)
    self._imgRedPacketRight:setSwallowTouches(true)
    self._imgBgLeft:setTouchEnabled(true)
    self._imgBgLeft:addClickEventListener(function(sender)
        self:onOpenPersonalInfo()
    end)
    self._imgBgRight:setTouchEnabled(true)
    self._imgBgRight:addClickEventListener(function(sender)
        self:onOpenPersonalInfo()
    end)
end

function ChatCell:lineCallbackRight()
    self._richSizeRight = self._richTextContentRight:getTextRealSize()
    self._sPriteRight:setVisible(true)
    local data = StaticData['chat']['bubble'][self._curBubbleId]
    if data then
        self._imgRight:loadTexture("img/chat/" .. data['icon'])
        self._sPriteRight:setTexture("img/chat/" .. data['sprite_icon'])
        self._sPriteRight:setVisible(true)
    end
    self._imgRight:setVisible(true)
    self._imgRight:setContentSize(cc.size(self._richSizeRight.width + 60, self._richSizeRight.height + 30))
    self._sPriteRight:setPosition(cc.p(self._richSizeRight.width + 35, 15))
end

function ChatCell:lineCallbackLeft()
    self._richSizeLeft = self._richTextContentLeft:getTextRealSize()
    local data = StaticData['chat']['bubble'][self._curBubbleId]
    self._spriteLeft:setVisible(false)
    if data then
        self._imgLeft:loadTexture("img/chat/" .. data['icon'])
        self._spriteLeft:setTexture("img/chat/" .. data['sprite_icon'])
        self._spriteLeft:setVisible(true)
    end
    self._imgLeft:setContentSize(cc.size(self._richSizeLeft.width + 60, self._richSizeLeft.height + 30))
    self._imgLeft:setVisible(true)
    self._spriteLeft:setPosition(cc.p(self._richSizeLeft.width + 35, 15))
end

function ChatCell:getRichHeight()
    if self._isLeft then
        return self._richSizeLeft.height + 40
    else
        return self._richSizeRight.height + 40
    end
end

function ChatCell:getData()
    return self._chatData
end

function ChatCell:createRichText(parent, node_name, is_left, rich_text_type)
    if not parent then
        return
    end
    if self[node_name] then
        return
    end
    self[node_name] = uq.RichText:create()
    self[node_name]:setMultiLineMode(true)
    self[node_name]:setFontSize(24)
    self[node_name]:setWrapMode(1)

    if rich_text_type == self._RICH_TEXT_TYPE.CONTENT then
        self[node_name]:setDefaultFont("res/font/fzlthjt.ttf")
        self[node_name]:setContentSize(cc.size(667, 50))
        self[node_name]:setTextColor(uq.parseColor("#343a3f"))
        if is_left then
            self[node_name]:setAnchorPoint(cc.p(0, 1))
            self[node_name]:setPosition(cc.p(110, -60))
        else
            self[node_name]:setAnchorPoint(cc.p(1, 1))
            self[node_name]:setPosition(cc.p(-150, -60))
        end
    elseif rich_text_type == self._RICH_TEXT_TYPE.RED then
        self[node_name]:setAnchorPoint(cc.p(0, 1))
        self[node_name]:setDefaultFont("res/font/hwkt.ttf")
        self[node_name]:setFontSize(22)
        self[node_name]:setContentSize(parent:getContentSize())
        self[node_name]:setTextColor(uq.parseColor("#FEFDDD"))
        self[node_name]:setPosition(0, 50)
    else
        self[node_name]:setDefaultFont("res/font/fzzzhjt.ttf")
        self[node_name]:setContentSize(parent:getContentSize())
        self[node_name]:setTextColor(cc.c3b(255,255,255))
        if is_left then
            self[node_name]:setAnchorPoint(cc.p(0, 0.5))
            self[node_name]:setPosition(cc.p(0, parent:getContentSize().height * 0.5))
        else
            self[node_name]:setAnchorPoint(cc.p(1, 0.5))
            self[node_name]:setPosition(cc.p(parent:getContentSize().width, parent:getContentSize().height * 0.5))
        end
    end

    parent:addChild(self[node_name])
end

function ChatCell:createTips()
    if not self._richTips then
        self._richTips = uq.RichText:create()
        self._richTips:setAnchorPoint(cc.p(0, 0.5))
        self._richTips:setDefaultFont("res/font/fzlthjt.ttf")
        self._richTips:setFontSize(24)
        self._richTips:setContentSize(cc.size(800, 39))
        self._richTips:setPositionY(self._richTips:getContentSize().height * 0.5)
        self._richTips:setTextColor(cc.c3b(255,255,255))
        self._imgTips:addChild(self._richTips)
    end
end

function ChatCell:setTeamTipsData(data)
    self:createTips()
    self._chatData = data
    self._curBubbleId = self._chatData.bubble_id or 0
    self._imgRedPacketLeft:setVisible(false)
    self._imgRedPacketRight:setVisible(false)
    self._panelShareLeft:setVisible(false)
    self._panelShareRight:setVisible(false)
    self:setItemWidth()
    self._nodeLeft:setVisible(false)
    self._nodeRight:setVisible(false)
    self._nodeTips:setVisible(true)
    local str = StaticData['local_text']['chat.cell.title.private.des3']
    str = str .. string.format(StaticData['local_text']['chat.cell.title.des1'], 24, "#75b5bf", self._chatData.role_name)
    str = str .. string.format(StaticData['local_text']['chat.cell.title.des1'], 20, "#ffffff", StaticData['local_text']['chat.cell.title.private.des4'])
    self._richTips:setText(str)
    self._richTips:formatText()
    local size = self._richTips:getTextRealSize()
    self._imgTips:setContentSize(cc.size(size.width + 40, self._imgTips:getContentSize().height))
    self._richTips:setPositionX(20)
end

function ChatCell:setPrivateTipsData(data)
    self:createTips()
    self._chatData = data
    self._curBubbleId = self._chatData.bubble_id or 0
    self._imgRedPacketLeft:setVisible(false)
    self._imgRedPacketRight:setVisible(false)
    self._panelShareLeft:setVisible(false)
    self._panelShareRight:setVisible(false)
    self:setItemWidth()
    self._nodeLeft:setVisible(false)
    self._nodeRight:setVisible(false)
    self._nodeTips:setVisible(true)
    local str = StaticData['local_text']['chat.cell.title.private.des1']
    str = str .. self:getCropName() .. string.format(StaticData['local_text']['chat.cell.title.des1'], 24, "#75b5bf", self._chatData.contact_name)
    str = str .. string.format(StaticData['local_text']['chat.cell.title.des1'], 20, "#ffffff", StaticData['local_text']['chat.cell.title.private.des2'])
    self._richTips:setText(str)
    self._richTips:formatText()
    local size = self._richTips:getTextRealSize()
    self._imgTips:setContentSize(cc.size(size.width + 40, self._imgTips:getContentSize().height))
    self._richTips:setPositionX(20)
end

function ChatCell:setChatData(chat_data)
    self._chatData = chat_data
    self._curBubbleId = self._chatData.bubble_id
    self:_BubbleChange()
    self:judgePositionDir(chat_data)
    self._imgRedPacketLeft:setVisible(false)
    self._imgRedPacketRight:setVisible(false)
    self._panelShareLeft:setVisible(false)
    self._panelShareRight:setVisible(false)
    self._nodeTips:setVisible(false)
    self:setItemWidth()
    if self._isLeft then
        self:setRichText(self._richTextContentLeft, chat_data.content)
        self:lineCallbackLeft()
    else
        self:setRichText(self._richTextContentRight, chat_data.content)
        self:lineCallbackRight()
    end
end

function ChatCell:judgePositionDir(data)

    --判断方位
    if self._chatData.sender_id == uq.cache.role.id then
        self:createRichText(self._nodeRight, "_richTextContentRight", false, self._RICH_TEXT_TYPE.CONTENT)
        self:createRichText(self._panelTitleRight, "_richTextRight", false, self._RICH_TEXT_TYPE.TITLE)
        self:createRichText(self._txtRedRight, "_redRichTextRight", false, self._RICH_TEXT_TYPE.RED)
        self._isLeft = false
        self:setHeadImg(data.img_type, data.img_id, self._imgBgRight)
        self._nodeLeft:setVisible(false)
        self._nodeRight:setVisible(true)
        self._imgRight:setVisible(false)
        self:setTitleContent(self._richTextRight, false)
    else
        self:createRichText(self._nodeLeft, "_richTextContentLeft", true, self._RICH_TEXT_TYPE.CONTENT)
        self:createRichText(self._panelTitleLeft, "_richTextLeft", true, self._RICH_TEXT_TYPE.TITLE)
        self:createRichText(self._txtRedLeft, "_redRichTextLeft", true, self._RICH_TEXT_TYPE.RED)
        self._isLeft = true
        self:setHeadImg(data.img_type, data.img_id, self._imgBgLeft)
        self._nodeLeft:setVisible(true)
        self._nodeRight:setVisible(false)
        self:setTitleContent(self._richTextLeft, true)
        self._imgLeft:setVisible(false)
    end
end

function ChatCell:_BubbleChange()
    local data = StaticData['chat']['bubble'][self._chatData.bubble_id]
    if self._chatData.bubble_id ~= 0 then
        self._imgRight:loadTexture("img/chat/" .. data['icon'])
        self._imgLeft:loadTexture("img/chat/" .. data['icon'])
    else
        self._imgRight:loadTexture("img/chat/s01_00026.png")
        self._imgLeft:loadTexture("img/chat/s01_00026.png")
    end
end

function ChatCell:setRichText(rich_text, content)
    local rich_content = content
    --匹配表情，斗图
    for s in string.gmatch(content, '%/%l%l') do
        for i=101, 130 do
            local data = StaticData['chat']['emoji'][i]
            if s == data['name'] then
                rich_content = string.gsub(rich_content, s, "<img img/chat/"..data['icon']..">")
                break
            end
        end

        for j=201, 206 do
            local data = StaticData['chat']['emoji'][j]
            if s == data['name'] then
                rich_content = string.gsub(rich_content, s, "<img img/chat/"..data['icon']..">")
                break
            end
        end
    end
    rich_text:setContentSize(cc.size(667, 50))
    rich_text:setText(uq.filterWord(rich_content))
    rich_text:formatText()
    local size = rich_text:getTextRealSize()
    if size.width < 667 then
        rich_text:setContentSize(cc.size(size.width, size.height))
    end
    rich_text:setVisible(true)
end

function ChatCell:getTitleStr(is_left)
    local str = ''
    local bg_node = nil
    if is_left then
        for k, v in ipairs(self._titleArray) do
            str = str .. v
        end
        bg_node = self._panelTitleLeft:getChildByName("Image_country")
    else
        bg_node = self._panelTitleRight:getChildByName("Image_country")
        for i = #self._titleArray, 1, -1 do
            str = str .. self._titleArray[i]
        end
    end
    local img_bg = self:getCountryBg()
    bg_node:loadTexture(img_bg)
    return str
end

function ChatCell:setTitleContent(node, is_left)
    self._titleArray = {}
    if self._chatData.msg_type == uq.config.constant.TYPE_CHAT_CHANNEL.CC_CONVERSATION then
        table.insert(self._titleArray, self:getRoleName())
        table.insert(self._titleArray, self:getTime())
    else
        table.insert(self._titleArray, self:getTitle())
        if self._chatData.msg_type == uq.config.constant.TYPE_CHAT_CHANNEL.CC_TEAM then
            table.insert(self._titleArray, self:getCommander())
        else
            table.insert(self._titleArray, self:getCropName())
        end
        table.insert(self._titleArray, self:getRoleName())
        table.insert(self._titleArray, self:getTime())
    end
    local str = ''
    for k, v in ipairs(self._titleArray) do
        str = str .. v
    end

    node:setText(self:getTitleStr(is_left))
    node:formatText()
    node:setContentSize(cc.size(node:getTextRealSize().width, node:getContentSize().height))
end

function ChatCell:getRoleName()--获取名字
    local tab_server_time = os.date("*t", self._chatData.create_time)
    return string.format(StaticData['local_text']['chat.cell.title.name'], self._chatData.role_name)
end

function ChatCell:getTime()--获取时间
    local tab_server_time = os.date("*t", self._chatData.create_time)
    return string.format(StaticData['local_text']['chat.cell.time.des'],
        tab_server_time.month, tab_server_time.day, tab_server_time.hour, tab_server_time.min, tab_server_time.sec)
end

function ChatCell:getTitle()--获取爵位
    if self._chatData.title_type <= 0 then
        return ""
    end
    return string.format(StaticData['local_text']['chat.cell.title.presser'], StaticData['world_nation'][self._chatData.title_type].name)
end

function ChatCell:getCropName()--获取军团名字
    if self._chatData.crop_name == "" then
        return ""
    end
    return string.format(StaticData['local_text']['chat.cell.title.crop'], self._chatData.crop_name)
end

function ChatCell:getCommander()--获取军团职位
    if self._chatData.commander == -1 then
        return ""
    end
    local img_path = self._commanderPath[self._chatData.commander + 1]
    if img_path == nil then
        return string.format(StaticData['local_text']['chat.cell.title.name'], StaticData['local_text']["chat.cell.des4"])
    else
        return string.format(StaticData['local_text']["chat.cell.commander.path"], img_path)
    end
end

function ChatCell:getCountryBg()
    if self._chatData.country_id == uq.config.constant.COUNTRY.SHU then
        return 'img/common/ui/s03_00034.png'
    elseif self._chatData.country_id == uq.config.constant.COUNTRY.WU then
        return 'img/common/ui/s03_00035.png'
    else
        return 'img/common/ui/s03_00033.png'
    end
end

function ChatCell:onOpenPersonalInfo()
    local data = {
        id = self._chatData.sender_id
    }
    network:sendPacket(Protocol.C_2_S_LOAD_ROLE_INFO_BY_ID, data)
end

function ChatCell:onOpenInfo(event)
    if event.name == "ended" then
        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.CHAT_INFO, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
        local x,y = event.target:getPosition()
        local pos = event.target:convertToWorldSpace(cc.p(x, y))
        local size = event.target:getContentSize()
        local size_info = panel:getContentSize()

        local dest_pos = cc.p(pos.x - size.width, pos.y + size.height + size_info.height)
        if self._isLeft then
            dest_pos = cc.p(pos.x, pos.y + size.height + size_info.height)
        end

        panel:setPosition(dest_pos)
    end
end

function ChatCell:_onPlayReportEnd(report)
    if not report then
        return
    end
    uq.BattleReport:getInstance():showBattleResult(report)
end

function ChatCell:onEnterBattle(event)
    if event.name ~= "ended" then
        return
    end
    uq.BattleReport:getInstance():showBattleReport(self._chatData.report_id, handler(self, self._onPlayReportEnd))
end

function ChatCell:setData(data)
    self._id = data.id
    if data.content_type == uq.config.constant.TYPE_CHAT_CONTENT.CCT_CHAT_CONTENT then
        self:setChatData(data)
    elseif data.content_type == uq.config.constant.TYPE_CHAT_CONTENT.CCT_CHAT_BATTLE_SHARE then
        self:setBattleShareData(data)
    elseif data.content_type == uq.config.constant.TYPE_CHAT_CONTENT.CCT_TIPS_PRIVATE then
        self:setPrivateTipsData(data)
    elseif data.content_type == uq.config.constant.TYPE_CHAT_CONTENT.CCT_TIPS_TEAM then
        self:setTeamTipsData(data)
    else
        self:setRedbagData(data)
    end
end

function ChatCell:setHeadImg(img_type, img_id, head)
    local res_head = uq.getHeadRes(img_id, img_type)
    head:getChildByName("sprite_left"):setTexture(res_head)
end

function ChatCell:setBattleShareData(data)
    self._chatData = data
    if data.sender_id == uq.cache.role.id then
        self._isLeft = false
    else
        self._isLeft = true
    end
    self._imgRedPacketLeft:setVisible(false)
    self._imgRedPacketRight:setVisible(false)
    self._nodeTips:setVisible(false)
    self:setItemWidth()
    self:judgePositionDir(data)

    if self._isLeft then
        self._panelShareLeft:setVisible(true)
        self._richTextContentLeft:setVisible(false)
        self:setShareInfo(self._panelShareLeft, data)
    else
        self._panelShareRight:setVisible(true)
        self._richTextContentRight:setVisible(false)
        self:setShareInfo(self._panelShareRight, data)
    end

end

function ChatCell:setShareInfo(panel, info)
    local data = json.decode(info.content)
    if data.map_name ~= nil then
        panel:getChildByName("Text_addr"):setString(data.map_name)
    end
    local title_1 = "img/world/s04_00227.png"
    local title_2 = "img/world/s04_00228.png"
    if (data.is_atk == 1 and data.result > 0) or (data.is_atk == 0 and data.result <= 0) then
        title_1 = "img/world/s04_00228.png"
        title_2 = "img/world/s04_00227.png"
    end
    panel:getChildByName("img_result_1"):loadTexture(title_1)
    panel:getChildByName("img_result_2"):loadTexture(title_2)

    --自己信息
    panel:getChildByName("Node_1"):getChildByName("player_name"):setString(data.ower.player_name)
    local res_head1 = uq.getHeadRes(data.ower.img_id, data.ower.img_type)
    panel:getChildByName("Node_1"):getChildByName("Image_13"):loadTexture(res_head1)
    --对手信息
    panel:getChildByName("Node_2"):getChildByName("player_name"):setString(data.enemy.player_name)
    local res_head2 = uq.getHeadRes(data.enemy.img_id, data.enemy.img_type)
    panel:getChildByName("Node_2"):getChildByName("Image_13"):loadTexture(res_head2)

    self:setShareFlag(panel:getChildByName("Node_1"):getChildByName("Image_flag"), data.ower.country_id)

    self:setShareFlag(panel:getChildByName("Node_2"):getChildByName("Image_flag"), data.enemy.country_id)

    panel:getChildByName("Button_1"):addClickEventListener(function()
        self:onReplayReport(data)
    end)
end

function ChatCell:setShareFlag(node,coutry_id)
    if not node then
        return
    end
    node:setVisible(coutry_id ~= uq.config.constant.COUNTRY.NEUTRAL)
    local path = 'img/common/ui/s03_00033.png'
    if coutry_id == uq.config.constant.COUNTRY.SHU then
        path = 'img/common/ui/s03_00034.png'
    elseif coutry_id == uq.config.constant.COUNTRY.WU then
        path = 'img/common/ui/s03_00035.png'
    end
    node:loadTexture(path)
end

function ChatCell:onReplayReport(report)
    uq.BattleReport:getInstance():showBattleReport(report.report_id, handler(self, self._onPlayReportEnd), report.rewards, nil, report.bg_path)
end

function ChatCell:getBgImg(is_atk, is_win)
    if is_atk == 1 then
        if is_win > 0 then
            return "img/world/j03_00009687.png"
        else
            return "img/world/j03_00009686.png"
        end
    else
        if is_win > 0 then
            return "img/world/j03_00009688.png"
        else
            return "img/world/j03_00009689.png"
        end
    end
end

function ChatCell:setRedbagData(data)
    if data.role_name == uq.cache.role.name then
        self._isLeft = false
    else
        self._isLeft = true
    end
    self._panelShareLeft:setVisible(false)
    self._panelShareRight:setVisible(false)
    self._nodeTips:setVisible(false)
    self:showRedPacket(data)
end

function ChatCell:showRedPacket(data)
    self._chatData = data

    self:judgePositionDir(data)

    if self._isLeft then
        self._imgRedPacketLeft:setVisible(true)
        self._imgLeft:setVisible(false)
        self._richTextContentLeft:setVisible(false)
        self._richTextLeft:setPositionY(30)
        self:setRedInfo(self._redRichTextLeft, self._txtRedTypeLeft)
        self:setRedReceiveInfo(self._imgRedPacketLeft, self._txtReceiveLeft)
    else
        self._imgRedPacketRight:setVisible(true)
        self._imgRight:setVisible(false)
        self._richTextContentRight:setVisible(false)
        self._richTextRight:setPositionY(30)
        self:setRedInfo(self._redRichTextRight, self._txtRedTypeRight)
        self:setRedReceiveInfo(self._imgRedPacketRight, self._txtReceiveRight)
    end

end

function ChatCell:setRedInfo(red_txt, red_type_txt)
    if self._chatData.type == uq.config.constant.TYPE_CROP_RED_PACKET_SPECOES.ORIDINARY then
        red_type_txt:setString(StaticData['local_text']['chat.red.packet.ordinary'])
    else
        red_type_txt:setString(StaticData['local_text']['chat.red.packet.command'])
    end
    local str = uq.filterWord(self._chatData.msg)
    red_txt:setText(str)

    if string.utfLen(str) > 9 then
        red_txt:setPositionY(50)
    end
end

function ChatCell:setRedReceiveInfo(node, receive_txt)
    node:loadTexture("img/chat/g03_0000393.png")
    --失效
    if self._chatData.expire_time == 0 then
        receive_txt:setString(StaticData['local_text']['chat.red.packet.lose.efficacy'])
        node:getChildByName('Image_state'):setColor(uq.parseColor("#d6d6d6"))
        node:loadTexture("img/chat/g03_0000395.png")
        return
    end

    if self._chatData.has_picked == uq.config.constant.TYPE_CROP_RED_PACKET_HAS.NONE then
        if self._chatData.left_num == 0 then
            receive_txt:setString(StaticData['local_text']['chat.red.packet.none'])
            node:loadTexture("img/chat/g03_0000394.png")
        else
            receive_txt:setString(StaticData['local_text']['chat.red.packet.has.not'])
        end
    else
        receive_txt:setString(StaticData['local_text']['chat.red.packet.has'])
    end

    self:initRedbagCommandEditBox()
end

function ChatCell:initRedbagCommandEditBox()
    self._nodeEditLeft:removeAllChildren()
    self._nodeEditRight:removeAllChildren()
    self._isExistEditBox = false
    if self._chatData.type == uq.config.constant.TYPE_CROP_RED_PACKET_SPECOES.COMMAND then
        --已抢过
        if self._chatData.has_picked == uq.config.constant.TYPE_CROP_RED_PACKET_HAS.HAS then
            return
        end

        --已抢完
        if self._chatData.left_num == 0 then
            return
        end

        if self._isLeft then
            self:createEditBox(self._nodeEditLeft, self._imgRedPacketLeft)
        else
            self:createEditBox(self._nodeEditRight, self._imgRedPacketRight)
        end
    end
end

function ChatCell:createEditBox(parent, bg)
    local size = bg:getContentSize()
    self._isExistEditBox = true
    self._redbagPasswdEditBox = ccui.EditBox:create(cc.size(size.width, size.height), '')
    self._redbagPasswdEditBox:setAnchorPoint(cc.p(0.5, 0.5))
    self._redbagPasswdEditBox:setFontName("Arial")
    self._redbagPasswdEditBox:setFontSize(20)
    self._redbagPasswdEditBox:setVisible(false)
    self._redbagPasswdEditBox:setFontColor(uq.parseColor("#FEFDDD"))
    self._redbagPasswdEditBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._redbagPasswdEditBox:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
    self._redbagPasswdEditBox:registerScriptEditBoxHandler(function(eventname, sender) self:passwdLeftEditBoxHandle(eventname, sender) end)
    parent:addChild(self._redbagPasswdEditBox)

    services:addEventListener(services.EVENT_NAMES.ON_CROP_REDBAG_COMMAND_EDITBOX_OPEN, handler(self, self._onCropRedbagCommandOpen), self._eventTag)
end

function ChatCell:passwdLeftEditBoxHandle(event, sender)
    if event == "began" then
    elseif event == "ended" then
        self._redbagContent = self._redbagPasswdEditBox:getText()
        if self._redbagContent == '' then
            return
        end
        if uq.hasKeyWord(self._redbagContent) then
            uq.fadeInfo(StaticData["local_text"]["label.screen.word"])
            return
        end
        local content = {
            id = self._id,
            command = self._redbagContent
        }
        services:dispatchEvent({name = services.EVENT_NAMES.ON_CROP_REDBAG_COMMAND, data = content})

        self._redbagPasswdEditBox:setVisible(false)
        self._redbagPasswdEditBox:setText('')
    end
end

function ChatCell:_onCropRedbagCommandOpen(msg)
    if msg.data == self._id then
        self._redbagPasswdEditBox:setVisible(true)
    end
end

function ChatCell:setItemWidth()
    if self._chatData.msg_type == uq.config.constant.TYPE_CHAT_CHANNEL.CC_CONVERSATION then
        self._nodeRight:setPositionX(display.width - 440)
        self._nodeTips:setPositionX((display.width - 440) / 2)
    else
        self._nodeRight:setPositionX(display.width - 120)
        self._nodeTips:setPositionX((display.width - 120) / 2)
    end
end

return ChatCell