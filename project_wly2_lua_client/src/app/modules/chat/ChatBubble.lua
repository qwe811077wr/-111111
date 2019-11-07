local ChatBubble = class("ChatBubble", require('app.base.ChildViewBase'))

ChatBubble.RESOURCE_FILENAME = "chat/ChatBubble.csb"
ChatBubble.RESOURCE_BINDING = {
    ["Node_bubble"]          = {["varname"] = "_nodeBubble"},
    ["Panel_11"]             = {["varname"] = "_panelBubble"},
    ["Node_curBubble"]       = {["varname"] = "_nodeCurBubble"},
    ["Image_31"]             = {["varname"] = "_imgCurBubble"},
    ["Text_24"]              = {["varname"] = "_txtCurBubble"},
    ["sprite_img"]           = {["varname"] = "_sprite"},
    ["btn_ok"]               = {["varname"] = "_btnOk",["events"] = {{["event"] = "touch",["method"] = "onBtnOk"}}},
    ["Image_bubble_bg"]      = {["varname"] = "_imageBg"}
}

function ChatBubble:onCreate()
    ChatBubble.super.onCreate(self)
    self._curBubble = uq.cache.role.bubble_id
    self._itemArray = {}
    self:parseView()
    self:initTabView()
    self:addTouchEventListener()
    self:refreshCurBubble()
end

function ChatBubble:onExit()
    ChatBubble.super:onExit()
end

function ChatBubble:onBtnOk(event)
    if event.name ~= "ended" then
        return
    end
    if self._curBubble == uq.cache.role.bubble_id then
        uq.fadeInfo(StaticData['local_text']['chat.bubble.des'])
        return
    end
    network:sendPacket(Protocol.C_2_S_CHOOSE_BUBBLE, {id = self._curBubble})
    self:refreshCurBubble(self._curBubble)
    self:setVisible(false)
end

function ChatBubble:addTouchEventListener()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self, self._onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
    local event_dispatcher = self._imageBg:getEventDispatcher()
    event_dispatcher:addEventListenerWithSceneGraphPriority(listener, self._imageBg)
end

function ChatBubble:_onTouchBegin(touch, event)
    local size = self._imageBg:getContentSize()
    local rect = cc.rect(0, 0, size.width, size.height)
    local clickPos = self._imageBg:convertToNodeSpace(touch:getLocation())

    if not cc.rectContainsPoint(rect, clickPos) then
        self:setVisible(false)
    end
end

function ChatBubble:initTabView()
    self._curTabInfoArray = {}
    local num = StaticData['chat']['Parameter'][3]['num']
    for i = 1, num do
        local data = StaticData['chat']['bubble'][i]
        table.insert(self._curTabInfoArray, data)
    end
    local size = self._panelBubble:getContentSize()
    self._tableView = cc.TableView:create(cc.size(size.width,size.height))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setAnchorPoint(cc.p(0,0))
    self._tableView:setDelegate()
    self._panelBubble:addChild(self._tableView)

    self._tableView:registerScriptHandler(handler(self,self.tableCellTouched2), cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(handler(self,self.cellSizeForTable2), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.tableCellAtIndex2), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView2), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:reloadData()
end

function ChatBubble:cellSizeForTable2(view, idx)
    return 580, 122
end

function ChatBubble:numberOfCellsInTableView2(view)
    return math.floor((#self._curTabInfoArray + 1) / 2)
end

function ChatBubble:tableCellTouched2(view, cell, touch)
    local touch_point = touch:getLocation()
    local index = cell:getIdx() * 2 + 1
    for i = 0, 1 do
        local item = cell:getChildByName("item" .. i)
        if item == nil or not item:isVisible() then
            return
        end
        local pos = item:convertToNodeSpace(touch_point)
        local bg_size = item:getContentSize()
        local rect = cc.rect(0, 0, bg_size.width, bg_size.height)
        if cc.rectContainsPoint(rect, pos) then
            uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
            local info = self._curTabInfoArray[index]
            if item['lock_state'] then
                uq.fadeInfo(info.des)
                return
            end
            self._curBubble = info.ident
            self:refreshState()
            break
        end
        index = index + 1
    end
end

function ChatBubble:tableCellAtIndex2(view, idx)
    local cell = view:dequeueCell()
    local index = idx * 2 + 1
    if not cell then
        cell = cc.TableViewCell:new()
        for i = 0, 1 do
            local info = self._curTabInfoArray[index]
            local element = cc.CSLoader:createNode('chat/BubbleNode.csb'):getChildByName('Panel_1')
            self:setElementData(element, info)
            element:removeSelf()
            element:setName("item" .. i)
            element:setPositionX(290 * i)
            cell:addChild(element)
            element:setVisible(info ~= nil)
            index = index + 1
            table.insert(self._itemArray, element)
        end
    else
        for i = 0, 1 do
            local info = self._curTabInfoArray[index]
            local element = cell:getChildByName("item" .. i)
            element:setVisible(info ~= nil)
            if info ~= nil then
                self:setElementData(element, info)
            end
            index = index + 1
        end
    end
    return cell
end

function ChatBubble:setElementData(element, data)
    if data == nil then
        return
    end
    element:getChildByName('Image_select'):setVisible(data.ident == self._curBubble)
    element['ident'] = data.ident
    local module_image = element:getChildByName("Image_bg")
    module_image:loadTexture("img/chat/" .. data['icon'])

    local sprite_img = module_image:getChildByName("sprite_img")
    sprite_img:setTexture("img/chat/" .. data['sprite_icon'])

    local module_txt = element:getChildByName("Text_des")
    module_txt:setString(data['name'])

    local module_txt = element:getChildByName("Text_name")
    module_txt:setString(data['name'])
    module_txt:setTextColor(uq.parseColor(data['color']))
    element['lock_state'] = (data['type'] == 2 and uq.cache.role:level() < tonumber(data['num']))
    element:getChildByName("Panel_lock"):setVisible(element['lock_state'])
end

function ChatBubble:refreshState()
    for k, v in ipairs(self._itemArray) do
        v:getChildByName('Image_select'):setVisible(v['ident'] == self._curBubble)
    end
end

function ChatBubble:refreshCurBubble(bubble_id)
    bubble_id = bubble_id or uq.cache.role.bubble_id
    local data = StaticData['chat']['bubble'][bubble_id]
    self._imgCurBubble:loadTexture("img/chat/"..data['icon'])
    self._sprite:setTexture("img/chat/"..data['sprite_icon'])
    self._txtCurBubble:setString(data['name'])
    self._txtCurBubble:setTextColor(uq.parseColor(data['color']))
end

return ChatBubble