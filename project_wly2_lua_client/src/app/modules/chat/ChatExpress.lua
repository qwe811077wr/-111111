local ChatExpress = class("ChatExpress", require('app.base.ChildViewBase'))

ChatExpress.RESOURCE_FILENAME = "chat/ChatExpress.csb"
ChatExpress.RESOURCE_BINDING = {
    ["Node_pic"]             = {["varname"] = "_nodePic"},
    ["Node_expression"]      = {["varname"] = "_nodeExpress"},
    ["Node_bucket_chart"]    = {["varname"] = "_nodeBucket"},
    ["Panel_10"]             = {["varname"] = "_panelExpressBg"},
    ["Node_spot"]            = {["varname"] = "_nodeSpot"},
}

function ChatExpress:onCreate()
    ChatExpress.super.onCreate(self)
    self._curPageViewState = uq.config.constant.TYPE_CHAT_EXPRESS_STATE.EXPRESS
    self._curPageViewTag = 1000
    self:setPosition(262, 105)
    self:parseView()
    self:createPageView()
    self:addTouchEventListener()
    self:refreshChannelBtn()
    self._nodeExpress:getChildByName('Image_normal'):setTouchEnabled(true)
    self._nodeExpress:getChildByName('Image_normal'):addClickEventListener(function(sender)
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.CHANGE)
        self:onExpressShow()
    end)

    self._nodeBucket:getChildByName('Image_normal'):setTouchEnabled(true)
    self._nodeBucket:getChildByName('Image_normal'):addClickEventListener(function(sender)
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.CHANGE)
        self:onBucketShow()
    end)
end

function ChatExpress:onExit()
    ChatExpress.super:onExit()
end

function ChatExpress:onOpen()
    self._curPageViewState = uq.config.constant.TYPE_CHAT_EXPRESS_STATE.EXPRESS
    self._curPageViewTag = 1000
    self:refreshChannelBtn()
    self._expressView:setVisible(true)
    self._expressView:setCurrentPageIndex(0)
    self._bucketView:setVisible(false)
    self:onPageChange()
end

function ChatExpress:addTouchEventListener()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self, self._onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
    local event_dispatcher = self:getEventDispatcher()
    event_dispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function ChatExpress:_onTouchBegin(touch,event)
    self:setVisible(false)
end

function ChatExpress:createPageView()
    local size = self._panelExpressBg:getContentSize()
    --表情
    self._expressView = ccui.PageView:create()
    self._expressView:setContentSize(size)
    self._expressView:setTag(1000)
    self._panelExpressBg:addChild(self._expressView)

    self:initPageView(1000)
    self:setExpressPos()
    self._nodeSpot:getChildByTag(210):loadTexture("img/chat/g03_000054.png")
    self._expressView:addEventListener(handler(self, self.onPageChange))

    --斗图
    self._bucketView = ccui.PageView:create()
    self._bucketView:setVisible(false)
    self._bucketView:setContentSize(size)
    self._bucketView:setTag(1001)
    self._panelExpressBg:addChild(self._bucketView)

    self:initPageView(1001)
    self:setBucketPos()
    self._bucketView:addEventListener(handler(self, self.onPageChange))
end

function ChatExpress:initPageView(view_tag)
    local size = self._panelExpressBg:getContentSize()

    local page_view = nil
    local num = 0
    if view_tag == 1000 then
        page_view = self._expressView
        num = math.floor((StaticData['chat']['Parameter'][1]['num'] + 29) / 30)
    else
        page_view = self._bucketView
        num = math.floor((StaticData['chat']['Parameter'][2]['num'] + 20) / 21)
    end

    for i = 1, num do
        local layout = ccui.Layout:create()
        layout:setContentSize(size)
        page_view:addPage(layout)
    end
    page_view:addEventListener(handler(self, self.onPageChange))
end

function ChatExpress:setExpressPos()
    local cur_row = 1
    local cur_row_num = 1  --只限于1-row_num之间
    local cur_page_element_num = 1
    local cur_page_index = 0
    local num = StaticData['chat']['Parameter'][1]['num']

    for i = 1, num do
        local element = ccui.ImageView:create(string.format("img/chat/BQ0000%02d.png", i))
        self:setElementData(element, 100 + i, 1000)
        self._expressView:getItem(cur_page_index):addChild(element)

        local pos_x = 60 + 70 * (cur_row_num - 1)
        local pos_y = 300 - 70 * cur_row
        cur_row_num = cur_row_num + 1
        cur_page_element_num = cur_page_element_num + 1
        if i % 10 == 0 then
            cur_row_num = 1
            cur_row = cur_row + 1
        end
        if cur_page_element_num > 30 then
            cur_row = 1
            cur_page_element_num = 1
            cur_page_index = cur_page_index + 1
        end
        element:setPosition(pos_x, pos_y)
    end
end

function ChatExpress:setBucketPos()
    local cur_row = 1
    local cur_row_num = 1  --只限于1-一行的元素个数之间
    local cur_page_element_num = 1
    local cur_page_index = 0
    local num = StaticData['chat']['Parameter'][2]['num']
    local data = StaticData['chat']['emoji']

    for i = 1, num do
        local express_data = data[200 + i]
        local element = ccui.ImageView:create("img/chat/" .. express_data.icon)
        self:setElementData(element, 200 + i, 1001)
        self._bucketView:getItem(cur_page_index):addChild(element)

        local pos_x = 60 + 100 * (cur_row_num - 1)
        local pos_y = 250 - 90 * (cur_row - 1)
        cur_row_num = cur_row_num + 1
        cur_page_element_num = cur_page_element_num + 1
        if i % 7 == 0 then
            cur_row_num = 1
            cur_row = cur_row + 1
        end
        if cur_page_element_num > 21 then
            cur_row = 1
            cur_page_element_num = 1
            cur_page_index = cur_page_index + 1
        end
        element:setPosition(pos_x, pos_y)
    end
end

function ChatExpress:setElementData(element, element_tag, view_tag)
    element:setAnchorPoint(cc.p(0.5, 1))
    element:setTag(element_tag)

    element:setTouchEnabled(true)
    element:addClickEventListenerWithSound(function(sender)
        local data = StaticData['chat']['emoji'][sender:getTag()]
        local chat_data = {
            type = view_tag,
            content = data['name']
        }
        services:dispatchEvent({name = services.EVENT_NAMES.ON_CHAT_EDITBOX_TEXT_CHANGE, data = chat_data})
    end)
end

function ChatExpress:onPageChange()
    local  curIndex = nil
    local  curNodeSpot = self._nodeSpot
    local num = 1
    if self._curPageViewTag == 1001 then
        curIndex = self._bucketView:getCurrentPageIndex()
        num = math.floor((StaticData['chat']['Parameter'][2]['num'] + 20) / 21)
    elseif self._curPageViewTag == 1000 then
        curIndex = self._expressView:getCurrentPageIndex()
        num = math.floor((StaticData['chat']['Parameter'][1]['num'] + 29) / 30)
    end
    local index = 1
    for i = 210, 213 do
        if i == 210 + curIndex then
            self._nodeSpot:getChildByTag(i):loadTexture("img/chat/g03_000054.png")
        else
            self._nodeSpot:getChildByTag(i):loadTexture("img/chat/g03_000053.png")
        end
        self._nodeSpot:getChildByTag(i):setVisible(index <= num)
        index = index + 1
    end
end

function ChatExpress:onExpressShow()
    if self._curPageViewState == uq.config.constant.TYPE_CHAT_EXPRESS_STATE.EXPRESS then
        return
    end
    self._curPageViewState = uq.config.constant.TYPE_CHAT_EXPRESS_STATE.EXPRESS
    self._curPageViewTag = 1000

    self._expressView:setVisible(true)
    self._expressView:setCurrentPageIndex(0)
    self._bucketView:setVisible(false)
    self:refreshChannelBtn()
    self:onPageChange()
end

function ChatExpress:onBucketShow()
    if self._curPageViewState == uq.config.constant.TYPE_CHAT_EXPRESS_STATE.BUCKET then
        return
    end
    self._curPageViewState = uq.config.constant.TYPE_CHAT_EXPRESS_STATE.BUCKET
    self._curPageViewTag = 1001

    self._expressView:setVisible(false)
    self._bucketView:setVisible(true)
    self._bucketView:setCurrentPageIndex(0)
    self:refreshChannelBtn()
    self:onPageChange()
end

function ChatExpress:refreshChannelBtn()
    if self._curPageViewState == uq.config.constant.TYPE_CHAT_EXPRESS_STATE.EXPRESS then
        self:setChannelBtnState(self._nodeExpress, true)
        self:setChannelBtnState(self._nodeBucket, false)
    elseif self._curPageViewState == uq.config.constant.TYPE_CHAT_EXPRESS_STATE.BUCKET then
        self:setChannelBtnState(self._nodeBucket, true)
        self:setChannelBtnState(self._nodeExpress, false)
    end
end

function ChatExpress:setChannelBtnState(btn,selected)
    btn:getChildByName('Image_select'):setVisible(selected)
end

return ChatExpress