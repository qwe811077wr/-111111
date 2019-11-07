local MapScene = class("MapScene", require('app.base.ChildViewBase'))

MapScene.ObjectZOrder = {
    EFFECT   = 1,
    CITY     = 2,
    LINE     = 3,
    ROLE     = 4,
    POP_MENU = 5,
}

function MapScene:onCreate()
    MapScene.super.onCreate(self)
    self._scalaScale = 1

    self:setPosition(display.center)
end

function MapScene:onExit()
    if self._bgLayer then
        self._bgLayer:dispose()
        self._bgLayer = nil
    end

    MapScene.super.onExit(self)
end

function MapScene:initData(bg_file, map_id, scale, init_pos)
    init_pos = init_pos or cc.p(0, 0)
    scale = scale or 1

    self._scalaScale = scale
    self._bgLayer = uq.ui.ScalableLayer:create(bg_file, map_id, scale, init_pos)
    self:addChild(self._bgLayer)
    self:addEffect()
end

function MapScene:addTouchLayer()
    self._popupLayer = ccui.Layout:create()
    self._popupLayer:setTouchEnabled(false)
    self._popupLayer:ignoreContentAdaptWithSize(false)
    self._popupLayer:setContentSize(cc.size(display.width * 10, display.height * 10))
    self._bgLayer:addChild(self._popupLayer)
    self._popupLayer:setVisible(false)
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self, self._onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
    local event_dispatcher = self._popupLayer:getEventDispatcher()
    event_dispatcher:addEventListenerWithSceneGraphPriority(listener, self._popupLayer)
end

function MapScene:_onTouchBegin(evt)
    return true
end

function MapScene:createMap(bg_file, map_id, init_pos)
    self._mapConfig = StaticData['map_config'][map_id]
    local map_scene = MapScene:create()
    map_scene:initData(bg_file, map_id, self._mapConfig.normal, init_pos)
    return map_scene
end

function MapScene:updateScale(scale, center_pos)
    self._bgLayer:updateScale(scale, center_pos)
end

function MapScene:changeScaleAction(scale, center_pos, speed)
    self._bgLayer:changeScaleAction(scale, center_pos, speed)
end

function MapScene:setMapScale(can_scale)
    local min_scale = self._mapConfig.small
    local max_scale = self._mapConfig.big

    if can_scale == nil then
        can_scale = false
    end

    min_scale = cc.p(min_scale, min_scale)
    max_scale = cc.p(max_scale, max_scale)

    self._bgLayer:minScale(min_scale.x, min_scale.y)
    self._bgLayer:maxScale(max_scale.x, max_scale.y)
    self._bgLayer:setCanScale(can_scale)
end

function MapScene:setTouchState(can_touch)
    if not can_touch and self._popupLayer == nil then
        self:addTouchLayer()
    elseif can_touch and self._popupLayer ~= nil then
        self._popupLayer:removeSelf()
        self._popupLayer = nil
    end
end

function MapScene:addMapClickEventListener(callback)
    self._bgLayer:addClickEventListener(callback)
end

function MapScene:addMapMoveEventListener(callback)
    self._bgLayer:addMoveEventListener(callback)
end

function MapScene:getMapContentSize()
    return self._bgLayer:getContentSize()
end

function MapScene:addMapChild(child)
    self._bgLayer:addChild(child)
end

function MapScene:returnToInit(center_point, ignore_limit)
    self._bgLayer:updateScale(self._scalaScale / self._bgLayer:getScale(), center_point, ignore_limit)
end

function MapScene:updateMapScale(scale, center_point, ignore_limit)
    self._bgLayer:updateScale(scale, center_point, ignore_limit)
end

function MapScene:updateMapPosition(delta_x, delta_y, move_action, speed, callback)
    if move_action then
        self._bgLayer:movePosition(delta_x, delta_y, speed, callback)
    else
        self._bgLayer:updatePosition(delta_x, delta_y)
    end
end

function MapScene:convertToMapWorldSpace(pt)
    return self._bgLayer:convertToWorldSpace(pt)
end

function MapScene:convertToMapNodeSpace(pt)
    return self._bgLayer:convertToNodeSpace(pt)
end

function MapScene:getMapPosition()
    return self._bgLayer:getPosition()
end

function MapScene:getInitScale()
    return self._scalaScale
end

function MapScene:getBgLayer()
    return self._bgLayer
end

function MapScene:addMapScaleEventListener(cb)
    self._bgLayer:addScaleEventListener(cb)
end

function MapScene:getInstercect(pt1, pt2, pt3, pt4)
    local s, t, ret = 0, 0, false
    ret, s, t = cc.pIsLineIntersect(pt1, pt2, pt3, pt4, s, t)
    if ret then
        local pt = cc.p(pt1.x + s * (pt2.x - pt1.x), pt1.y + s * (pt2.y - pt1.y))
        local x = pt1.x < pt2.x and pt1.x or pt2.x
        local y = pt1.y < pt2.y and pt1.y or pt2.y
        local rect = cc.rect(x, y, math.abs(pt2.x - pt1.x), math.abs(pt2.y - pt1.y))
        if cc.rectContainsPoint(rect, pt) then
            return pt
        end
    else
        return false
    end
    return false
end

--将位置调整的区域范围之内
function MapScene:adaptPosition(pos, range)
    local range = range or 0.6
    local center = self._bgLayer:convertToNodeSpace(display.center)

    local rect = cc.rect(center.x - display.width * range / 2, center.y - display.height  * range / 2, display.width * range, display.height  * range)
    if cc.rectContainsPoint(rect, pos) then
        return
    end

    local intersect = nil
    local intersect1 = self:getInstercect(center, pos, cc.p(rect.x, rect.y), cc.p(rect.x, rect.y + rect.height))
    local intersect2 = self:getInstercect(center, pos, cc.p(rect.x + rect.width, rect.y), cc.p(rect.x + rect.width, rect.y + rect.height))
    local intersect3 = self:getInstercect(center, pos, cc.p(rect.x, rect.y), cc.p(rect.x + rect.width, rect.y))
    local intersect4 = self:getInstercect(center, pos, cc.p(rect.x, rect.y + rect.height), cc.p(rect.x + rect.width, rect.y + rect.height))

    if intersect1 ~= false then
        intersect = intersect1
    elseif intersect2 ~= false then
        intersect = intersect2
    elseif intersect3 ~= false then
        intersect = intersect3
    elseif intersect4 ~= false then
        intersect = intersect4
    end
    if intersect then
        local pos = self:convertToMapWorldSpace(pos)
        local intersect = self:convertToMapWorldSpace(intersect)
        self:updateMapPosition(intersect.x - pos.x, intersect.y - pos.y, true, 2.5)
    end
end

function MapScene:getMapConfig()
    return self._mapConfig
end

function MapScene:addEffect()
    if not self._mapConfig or not self._mapConfig.Txs then
        return
    end

    local size = self:getMapContentSize()
    for k, item in ipairs(self._mapConfig.Txs) do
        local pos = cc.p(item.x - size.width / 2, -item.y + size.height / 2)
        local effect_node = uq:addEffectByNode(self._bgLayer, item.txs, -1, true, pos, nil, item.scale)
        effect_node:setLocalZOrder(self.ObjectZOrder.EFFECT)
    end
end

function MapScene:scaleCallback(func)
    self._bgLayer:scaleCallback(func)
end

return MapScene