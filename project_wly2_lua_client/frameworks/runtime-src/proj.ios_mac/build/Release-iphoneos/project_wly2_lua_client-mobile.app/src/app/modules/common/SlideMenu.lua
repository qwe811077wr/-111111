local SlideMenu = class("SlideMenu", require('app.base.ChildViewBase'))

SlideMenu.RESOURCE_FILENAME = "common/LeftSideItem.csb"

SlideMenu.RESOURCE_BINDING = {
    ["Panel_tab"]                   = {["varname"] = "_panelMenu"},
    ["Panel_tab/Node_2"]            = {["varname"] = "_nodeMenu"},
    ["Panel_tab/Node_2/tab"]        = {["varname"] = "_menuItem"},
}

function SlideMenu:ctor(name, args)
    SlideMenu.super.ctor(self, name, args)

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self, self._onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self._onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, self._onTouchEnd), cc.Handler.EVENT_TOUCH_ENDED)
    local event_dispatcher = self._panelMenu:getEventDispatcher()
    event_dispatcher:addEventListenerWithSceneGraphPriority(listener, self._panelMenu)
end

function SlideMenu:setData(data)
    self._redArray = {}
    self._normalPngArray = data.noraml_img
    self._selectedPngArray = data.selected_img
    self._menuText = data.tab_txt
    self._menuTag = data.tab_tag
    self._interval = data.interval
    self._num = #self._menuTag
    self._selectedItem = math.ceil(self._num / 2)
    self._tabIndex = data.tab_index and data.tab_index or nil
    self._sizeY = self._num * self._interval + 70 - self._interval
    self._scrollState = false
    self._panelMenu:setContentSize(cc.size(240, self._sizeY))
    self._centerPos = cc.p(60, self._sizeY - (self._selectedItem * self._interval + 35 - self._interval))

    local up_vector = cc.p(-50, self._sizeY - 35 - self._centerPos.y)
    self._upScope = up_vector.y / up_vector.x
    self._upAdd = self._centerPos.y - self._upScope * self._centerPos.x

    local down_vector = cc.p(-50, 35 - self._centerPos.y)
    self._downScope = down_vector.y / down_vector.x
    self._downAdd = self._centerPos.y - self._downScope * self._centerPos.x

    self:addMenus()
end

function SlideMenu:addMenus()
    self._menuInfo = {}
    for i = 1, self._num + 1 do
        local menu_item = self._nodeMenu:getChildByName("tab")
        if i ~= 1 then
            menu_item = self._menuItem:clone()
            self._nodeMenu:addChild(menu_item)
        end
        menu_item.index = i
        table.insert(self._menuInfo, menu_item)
        self:setItemData(i)

        local item_pos_y = self._sizeY - self._interval * (i - 1) - 35
        if i < self._selectedItem then
            menu_item:setPosition(cc.p((item_pos_y - self._upAdd) / self._upScope, item_pos_y))
        elseif i > self._selectedItem then
            menu_item:setPosition(cc.p((item_pos_y - self._downAdd) / self._downScope, item_pos_y))
        else
            menu_item:setPosition(cc.p(self._centerPos.x, self._centerPos.y))
        end
    end

    if self._tabIndex and self._tabIndex ~= self._selectedItem then
        self:setSelectItem(self._tabIndex)
    else
        uq:addEffectByNode(self._menuInfo[self._selectedItem]:getChildByName("img"), 900002, -1, true, cc.p(76, 25))
        self._callBack(self._menuTag[self._selectedItem])
    end
    self._menuInfo[self._selectedItem]:setBackGroundImage("img/common/ui/g02_000003.png")
    self._menuInfo[self._selectedItem]:getChildByName("txt"):setColor(cc.c3b(112, 82, 12))
    self._menuInfo[self._selectedItem]:getChildByName("img"):loadTexture(self._selectedPngArray[self._menuTag[self._selectedItem]])
end

function SlideMenu:_onTouchBegin(touch, event)
    if self._scrollState then
        return false
    end
    self._move = false
    local pos = touch:getLocation()
    self._nextItem = 0
    self._touchPos = self._panelMenu:convertToNodeSpace(pos)
    if not cc.rectContainsPoint(self._panelMenu:getBoundingBox(), self._view:convertToNodeSpace(pos)) then
        return false
    end
    local node_pos = self._nodeMenu:convertToNodeSpace(pos)
    for i = 1, self._num + 1 do
        if cc.rectContainsPoint(self._menuInfo[i]:getBoundingBox(), node_pos) then
            self._nextItem = i
            return true
        end
    end
    return true
end

function SlideMenu:_onTouchMoved(touch, event)
    local delta = touch:getDelta()
    if not delta then
        return false
    end
    local moved_pos = self._panelMenu:convertToNodeSpace(touch:getLocation())
    if moved_pos.y < 0 or moved_pos.y > self._sizeY then
        return
    end
    if not self._move and math.abs(moved_pos.y - self._touchPos.y) < 10 then
        return
    end
    self._move = true
    if not self._movedPos then
        self._movedPos = self._touchPos
    end

    self._nodeMenu:setPositionY(moved_pos.y - self._touchPos.y)
    self:moveSlideItem(self._movedPos.y < moved_pos.y)
    self._movedPos = moved_pos
end

function SlideMenu:moveSlideItem(state)
    if state then
        self._dir = -1
        self:setItemData(self._num + 1, self._menuInfo[1].value)
        if self._menuInfo[1]:getPositionY() + self._nodeMenu:getPositionY() > self._sizeY + 40 then
            self._menuInfo[1]:setPositionY(self._menuInfo[self._num + 1]:getPositionY() - self._interval)
            self:resetItem(-1)
        end
    else
        self._dir = 1
        if self._menuInfo[self._num + 1]:getPositionY() + self._nodeMenu:getPositionY() < -self._interval - 10 then
            self:setItemData(self._num + 1, self._menuInfo[self._num].value)
            self._menuInfo[self._num + 1]:setPositionY(self._menuInfo[1]:getPositionY() + self._interval)
            self:resetItem(1)
        end
    end

    for i = 1, self._num + 1 do
        local pos_y = self._menuInfo[i]:getPositionY() + self._nodeMenu:getPositionY()
        if pos_y > self._centerPos.y then
            self._menuInfo[i]:setPositionX((pos_y - self._upAdd) / self._upScope)
        else
            self._menuInfo[i]:setPositionX((pos_y - self._downAdd) / self._downScope)
        end
    end
end

function SlideMenu:scrollToCenter()
    if self._selectedItem == self._nextItem or self._nextItem == 0 then
        return
    end
    local total_delta = (self._nextItem - self._selectedItem) * self._interval
    local pre_delte = total_delta / 10
    local times = 0
    self._scrollState = true

    uq.TimerProxy:removeTimer("scroll_to_center")
    uq.TimerProxy:addTimer("scroll_to_center", function()
        self._nodeMenu:setPositionY(self._nodeMenu:getPositionY() + pre_delte)

        self:moveSlideItem(total_delta > 0)
        times = times + 1
        if times == 10 then
            self:resetItemPosition()
            self._scrollState = false
        end
    end, 0.01, 10)
end

function SlideMenu:resetItemPosition()
    self._selectedItem = math.ceil(self._num / 2)
    for i = 1, self._num + 1 do
        local item_pos_y = self._sizeY - self._interval * (i - 1) - 35
        if i < self._selectedItem then
            self._menuInfo[i]:setPosition(cc.p((item_pos_y - self._upAdd) / self._upScope, item_pos_y))
        elseif i > self._selectedItem then
            self._menuInfo[i]:setPosition(cc.p((item_pos_y - self._downAdd) / self._downScope, item_pos_y))
        else
            self._menuInfo[i]:setPosition(cc.p(self._centerPos.x, self._centerPos.y))
        end
    end
    self._callBack(self._menuTag[self._menuInfo[self._selectedItem].value])
    self._nodeMenu:setPositionY(0)
end

function SlideMenu:setSelectItem(index)
    if index then
        self._nextItem = index
    end
    if self._selectedItem == self._nextItem or self._nextItem == 0 then
        return
    end
    self:resetItemData(self._nextItem - self._selectedItem)
    self._callBack(self._menuTag[self._menuInfo[self._selectedItem].value])
end

function SlideMenu:_onTouchEnd(touch, event)
    if not self._move then
        self:scrollToCenter()
        return
    end
    self:resetItemPosition()
end

function SlideMenu:resetItem(dir)
    for i = 1, self._num + 1 do
        self._menuInfo[i].index = self._menuInfo[i].index + dir
        if self._menuInfo[i].index <= 0 then
            self._menuInfo[i].index = self._num + self._menuInfo[i].index + 1
        end
        if self._menuInfo[i].index > self._num + 1 then
            self._menuInfo[i].index = self._menuInfo[i].index - self._num - 1
        end
    end
    table.sort(self._menuInfo, function(a, b)
        return a.index < b.index
    end)
    self:setItemState(self._selectedItem)
end

function SlideMenu:resetItemData(init_index)
    if self._menuInfo[1].value == init_index + 1 then
        return
    end
    for i = 1, self._num + 1 do
        self:setItemData(i, i + init_index)
    end
end

function SlideMenu:showRed(value, is_red)
    for k, v in ipairs(self._menuInfo) do
        if v.value == value then
            self._redArray[value] = is_red
            uq.showRedStatus(v, is_red, -v:getContentSize().width * 0.5 + 10, v:getContentSize().height * 0.5 - 10)
        end
    end
end

function SlideMenu:setItemData(index, value)
    if value and self._menuInfo[index].value == value then
        return
    end
    if not value then
        value = index
    end
    if value > self._num then
        value = value - self._num
    elseif value < 1 then
        value = value + self._num
    end
    self._menuInfo[index]:getChildByName("img"):loadTexture(self._normalPngArray[self._menuTag[value]])
    self._menuInfo[index]:getChildByName("txt"):setString(self._menuText[self._menuTag[value]])
    self._menuInfo[index].value = value
    local is_red = self._redArray[value] == nil and false or self._redArray[value]
    uq.showRedStatus(self._menuInfo[index], is_red, -self._menuInfo[index]:getContentSize().width * 0.5 + 10, self._menuInfo[index]:getContentSize().height * 0.5 - 10)
end

function SlideMenu:setItemState(index)
    for i = 1, self._num + 1 do
        self._menuInfo[i]:setBackGroundImage("img/common/ui/g02_000004.png")
        self._menuInfo[i]:getChildByName("txt"):setColor(cc.c3b(191, 240, 231))
        self._menuInfo[i]:getChildByName("img"):loadTexture(self._normalPngArray[self._menuTag[self._menuInfo[i].value]])
        self._menuInfo[i]:getChildByName("img"):removeAllChildren()
    end

    self._menuInfo[index]:setBackGroundImage("img/common/ui/g02_000003.png")
    self._menuInfo[index]:getChildByName("txt"):setColor(cc.c3b(112, 82, 12))
    self._menuInfo[index]:getChildByName("img"):loadTexture(self._selectedPngArray[self._menuTag[self._menuInfo[index].value]])
    uq:addEffectByNode(self._menuInfo[index]:getChildByName("img"), 900002, -1, true, cc.p(76, 25))
    self._selectedItem = index
end

function SlideMenu:setCallback(call_back)
    self._callBack = call_back
end

function SlideMenu:alternatOperate(info)
    -- 另类操作:通行证界面需求
    for k, v in pairs(self._menuInfo) do
        v:getChildByName("img"):setVisible(info.img_view)
        local txt = v:getChildByName("txt")
        txt:setFontSize(info.txt_font)

        if info.txt_pos == 'center' then
            local center_size = v:getContentSize()
            txt:setPosition(cc.p(center_size.width / 2, center_size.height / 2))
        end
    end
end

return SlideMenu