local GuideTips = class("GuideTips", require("app.base.PopupBase"))

GuideTips.RESOURCE_FILENAME = "guide/GuideTips.csb"
GuideTips.RESOURCE_BINDING  = {
    ["clip_node"]                = {["varname"] = "_nodeClip"},
    ["Node_1"]                   = {["varname"] = "_nodeLeft"},
    ["Node_1/Text_1"]            = {["varname"] = "_txtLeft"},
    ["Node_1/Image_1"]           = {["varname"] = "_imgBgLeft"},
    ["Node_1_0"]                 = {["varname"] = "_nodeRight"},
    ["Node_1_0/Text_1"]          = {["varname"] = "_txtRight"},
    ["Node_1_0/Image_1"]         = {["varname"] = "_imgBgRight"},
    ["finger_spr"]               = {["varname"] = "_sprFinger"},
    ["Node_3"]                   = {["varname"] = "_nodeFinger"},
    ["action_node"]              = {["varname"] = "_nodeAction"},
}

function GuideTips:ctor(name, args)
    GuideTips.super.ctor(self, name, args)
    self._args = args or {}
    self._data = self._args.data or {}
    self._pox = self._args.pos or {}
end

function GuideTips:init()
    self:parseView()
    self._posX = 0
    self._posY = 0
    self._selClick = false
    self:createClip()
end

function GuideTips:createClip()
    local data = self._data
    if next(data) == nil then
        return
    end
    local clip = cc.ClippingNode:create()
    clip:setInverted(true)
    clip:setAlphaThreshold(0.0)
    if self._pox and next(self._pox) ~= nil then
        self._posX = self._pox.x
        self._posY = self._pox.y
    else
        if data.pos_center == 1 then
            self._posX = display.width / 2
            self._posY = display.height / 2
        end
    end
    self._posX = self._posX + data.pos_x_click
    self._posY = self._posY + data.pos_y_click
    local layer_color = cc.LayerColor:create(cc.c4b(0, 0, 0, 0), display.width * 10, display.height * 10)
    clip:addChild(layer_color, 8)

    self._nodeClose = cc.Node:create()
    local clip_type = data.clip_type or 0
    local spr_name = "img/guide/j03_000071_1.png"
    if data.clip_img and data.clip_img ~= "" then
        spr_name = data.clip_img
    end
    local spr_close = cc.Sprite:create(spr_name)
    spr_close:setScale(data.scale or 1)
    self._sprClose = spr_close
    self._nodeClose:addChild(spr_close)
    self._nodeClose:setPosition(cc.p(self._posX, self._posY))
    clip:setStencil(self._nodeClose)
    self._nodeClip:addChild(clip, 1)
    local effect_scale = data.effect_scale or 1
    uq:addEffectByNode(self._nodeAction, 900116, -1, false, cc.p(self._posX, self._posY), nil, effect_scale)
    self._sprFinger:setVisible(true)
    self._nodeFinger:setPosition(cc.p(self._posX, self._posY))
    local rotate = math.max(data.flag_rotate or 1, 1)
    self._nodeFinger:rotate((rotate - 1) * 90)
    if data.second_light and data.second_light ~= "" then
        local str_light = string.split(data.second_light, ",")
        local pos_x = tonumber(str_light[1]) or 0
        local pos_y = tonumber(str_light[2]) or 0
        self._sprFinger:runAction(cc.RepeatForever:create(
            cc.Sequence:create(
                cc.MoveBy:create(1, cc.p(pos_x - self._posX, pos_y - self._posY)),
                cc.CallFunc:create(function ()
                    self._sprFinger:setPosition(0, 0)
            end))))
        uq:addEffectByNode(self._nodeAction, 900116, -1, false, cc.p(pos_x, pos_y), nil, effect_scale)
    else
        self._sprFinger:runAction(cc.RepeatForever:create(
            cc.Sequence:create(
                cc.EaseExponentialOut:create(cc.MoveBy:create(1, cc.p(40, -40))),
                cc.EaseExponentialIn:create(cc.MoveBy:create(1, cc.p(-40, 40)))
            )
        ))
    end

    local node = cc.Node:create()
    self:addChild(node)
    self._nodeListener = node
    --用来屏幕除高亮区域外
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self, self._onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
    local event_dispatcher = self._nodeListener:getEventDispatcher()
    event_dispatcher:addEventListenerWithSceneGraphPriority(listener, self._nodeListener)
    --用来处理点击结束
    local node_end = cc.Node:create()
    self:addChild(node_end, 10)
    self._nodeListenerEnd = node_end
    local listener_end = cc.EventListenerTouchOneByOne:create()
    listener_end:setSwallowTouches(false)
    listener_end:registerScriptHandler(handler(self, self._onTouchBeginTwo), cc.Handler.EVENT_TOUCH_BEGAN)
    listener_end:registerScriptHandler(handler(self, self._onTouchEndTwo), cc.Handler.EVENT_TOUCH_ENDED)
    local event_dispatcher_end = self._nodeListenerEnd:getEventDispatcher()
    event_dispatcher_end:addEventListenerWithSceneGraphPriority(listener_end, self._nodeListenerEnd)
end

function GuideTips:refreshTips()
    local data = self._data
    if next(data) == nil then
        return
    end
    local is_right = self._posX <  display.width / 2
    self._nodeLeft:setVisible(not is_right)
    self._nodeRight:setVisible(is_right)
    local str = is_right and "Right" or "Left"
    self["_txt" .. str]:setString(data.dec)
    self["_txt" .. str]:setTextAreaSize(cc.size(230, 0))
    self["_node" .. str]:setPosition(cc.p(self._posX + data.tips_x, self._posY + data.tips_y))
    self["_imgBg" .. str]:setContentSize(cc.size(300, self["_txt" .. str]:getContentSize().height + 30))
end

function GuideTips:_onTouchBegin(evt)
    local touch_point = evt:getLocation()
    local size = self._sprClose:getContentSize()
    local pos = self._sprClose:convertToNodeSpace(touch_point)

    local rect = cc.rect(0, 0, size.width, size.height)
    if cc.rectContainsPoint(rect, pos) then
        self._selClick = true
        return false
    end
    return true
end

function GuideTips:_onTouchBeginTwo(evt)
    return true
end

function GuideTips:_onTouchEndTwo(evt)
    if not self._selClick then
        return true
    end

    if self._data.begin_click == 1 then
        self:disposeSelf()
        uq.cache.guide:setMainCityMapNotMove(false)
        uq.cache.guide:dealNextForceGuide()
        return true
    end

    local touch_point = evt:getLocation()
    local size = self._sprClose:getContentSize()
    local pos = self._sprClose:convertToNodeSpace(touch_point)
    local rect = cc.rect(0, 0, size.width, size.height)
    if cc.rectContainsPoint(rect, pos) then
        self:disposeSelf()
        uq.cache.guide:setMainCityMapNotMove(false)
        uq.cache.guide:dealNextForceGuide()
        return true
    end
    self._selClick = false
    return true
end

return GuideTips