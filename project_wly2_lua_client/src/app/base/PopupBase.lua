local PopupBase = class("PopupBase", require('app.base.ModuleBase'))

function PopupBase:ctor(name, args)
    PopupBase.super.ctor(self, name, args)
    local popup = ccui.Layout:create()
    popup:setTouchEnabled(false)
    popup:ignoreContentAdaptWithSize(false)
    popup:setContentSize(cc.size(display.width * 10, display.height * 10) )
    self:addChild(popup, -1)

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self, self._onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self._onTouchEnd), cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(handler(self, self._onTouchCancelled), cc.Handler.EVENT_TOUCH_CANCELLED)
    local event_dispatcher = popup:getEventDispatcher()
    event_dispatcher:addEventListenerWithSceneGraphPriority(listener, popup)

    self._func = nil
    self._exceptNodes = {}
    self._inTouch = false
    self._touchClose = false
    self._canTouchClose = true
    self._action = uq.ViewAction:create(self._view, args)
    if not args or not args.close_open_action then
        self._action:playOpenAction(handler(self,self.openActionCallBack))
    end
end

function PopupBase:_onTouchExit(event)
    if event.name ~= "ended" then
        return
    end
    self:runCloseAction()
end

function PopupBase:onCreate()
    PopupBase.super.onCreate(self)

    self:setBaseBgVisible(false)
end

function PopupBase:openActionCallBack()
    if not self._canTouchClose then
        return
    end

    self._touchClose = true
end

function PopupBase:setTouchClose(flag)
    self._canTouchClose = flag
    self._touchClose = flag
end

function PopupBase:addExceptNode(n)
    table.insert(self._exceptNodes, n)
end

function PopupBase:setLayerColor(opacity)
    opacity = opacity or 0.8
    local layer = self:getChildByName("layer_color")
    if not layer then
        layer = cc.LayerColor:create(cc.c3b(0, 0, 0), display.width * 10, display.height * 10)
        layer:setOpacity(255 * opacity)
        layer:setAnchorPoint(cc.p(0, 0))
        layer:setPosition(cc.p(-display.width / 2, -display.height / 2))
        layer:setName("layer_color")
        self:addChild(layer, -2)
    else
        layer:setOpacity(255 * opacity)
    end
end

function PopupBase:_onTouchBegin(evt)
    local touch_point = evt:getLocation()
    for _, v in pairs(self._exceptNodes) do
        local size = v:getContentSize()
        local pos = v:convertToNodeSpace(touch_point)
        local rect=cc.rect(0, 0, size.width, size.height)
        if cc.rectContainsPoint(rect, pos) then
            self._inTouch = false
            return true
        end
    end
    self._inTouch = true
    return true
end

function PopupBase:runCloseAction()
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BACK)
    self._action:playCloseAction(handler(self, self.runCloseActionCallback))
end

function PopupBase:runCloseActionCallback()
    if self._callback then
        self._callback()
    end

    self:disposeSelf()
end

function PopupBase:_onTouchEnd(evt)
    if not self._inTouch then
        return
    end

    if not self._touchClose then return false end

    self:runCloseAction()
end

function PopupBase:_onTouchCancelled(evt)
    self._inTouch = false
end

function PopupBase:dispose()
    PopupBase.super.dispose(self)
end

function PopupBase:setCallBack(func)
    self._callback = func
end

return PopupBase
