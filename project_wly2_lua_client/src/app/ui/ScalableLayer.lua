local ScalableLayer = class('ScalableLayer', function()
    return cc.Layer:create()
end)

function ScalableLayer:ctor(bg_file, map_id, scale, init_pos)
    scale = scale or 1
    init_pos = init_pos or cc.p(0, 0)
    -- local listener = cc.EventListenerTouchOneByOne:create()
    -- listener:setSwallowTouches(true)
    -- listener:registerScriptHandler(handler(self, self._onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
    -- listener:registerScriptHandler(handler(self, self._onTouchMove), cc.Handler.EVENT_TOUCH_MOVED)
    -- listener:registerScriptHandler(handler(self, self._onTouchEnd), cc.Handler.EVENT_TOUCH_ENDED)
    -- listener:registerScriptHandler(handler(self, self._onTouchCancelled), cc.Handler.EVENT_TOUCH_CANCELLED)
    -- self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)

    self:onTouch(handler(self, self.onLayerTouch), true, true)

    local listener = cc.EventListenerMouse:create()
    listener:registerScriptHandler(handler(self, self.mouseMove), cc.Handler.EVENT_MOUSE_MOVE)
    listener:registerScriptHandler(handler(self, self.mouseScroll), cc.Handler.EVENT_MOUSE_SCROLL)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)

    self:setAnchorPoint(cc.p(0, 0))
    self:setIgnoreAnchorPointForPosition(false)

    local scheduler = cc.Director:getInstance():getScheduler()
    self._timerId = scheduler:scheduleScriptFunc(handler(self, self.update), 0, false)

    self:setPosition(init_pos)
    if bg_file then
        local iv = ccui.ImageView:create(bg_file, ccui.TextureResType.localType)
        local size = iv:getContentSize()
        self:setContentSize(size)
        self:addChild(iv)
    else
        self._imageMap = uq.ui.MapImage:create()
        self:addChild(self._imageMap)

        self._imageMap:setData(map_id, scale)
        self:setContentSize(self._imageMap:getContentSize())
    end
    self:setScale(scale)

    self._maxScaleX = 1
    self._maxScaleY = 1
    self._clickCB = nil
    self._moveCB = nil
    self._scaleCB = nil
    self._touches = {}
    self._canScale = false
    self._moveActionSpeed = 3000
    self._offScaleMax = 0.1
    self._offScaleMin = 0.1
    self._scaleAction = false
    self._speedAdd = 500 --减速度
    self._speedTime = 8 --步长
    self._touchMoving = false
    self._moveAction = false
    self._limitSpeed = 400
end

function ScalableLayer:mouseMove(event)
end

function ScalableLayer:mouseScroll(event)
    if not self._canScale then
        return
    end

    local touch_pos = self:convertToNodeSpace(cc.p(event:getCursorX(), event:getCursorY()))
    if not self._scaleAction then
        if self._scaleDelayAction then
            self:stopAction(self._scaleDelayAction)
        end
        self:updateScale(1 + event:getScrollY() / 50, touch_pos)
        -- self._scaleDelayAction = self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()
        --     if self:getScaleX() < self._minScaleX then
        --         self:changeScaleAction(self._minScaleX, touch_pos)
        --     elseif self:getScaleX() > self._maxScaleX then
        --         self:changeScaleAction(self._maxScaleX, touch_pos)
        --     end
        --     self._scaleDelayAction = nil
        -- end)))
    end
end

function ScalableLayer:setCanScale(flag)
    self._canScale = flag
end

function ScalableLayer:addClickEventListener(cb)
    self._clickCB = cb
end

function ScalableLayer:addMoveEventListener(cb)
    self._moveCB = cb
end

function ScalableLayer:addScaleEventListener(cb)
    self._scaleCB = cb
end

function ScalableLayer:getTouchCount()
    local ret = 0
    for _, v in pairs(self._touches) do
        if v then
            ret = ret + 1
        end
    end
    return ret
end

function ScalableLayer:onLayerTouch(event)
    if event.name == "began" then
        self:arrayHandle(event.points, handler(self, self.onTouchBegin))
        return true
    elseif event.name == "moved" then
        if uq.cache.guide._closeMapMove then
            return
        end
        self:arrayHandle(event.points, handler(self, self.onTouchMove))
    elseif event.name == "ended" then
        self:arrayHandle(event.points, handler(self, self.onTouchEnd))
    elseif event.name == "canceled" then
        self:arrayHandle(event.points, handler(self, self.onTouchCancelled))
    end
end

function ScalableLayer:arrayHandle(points, callback)
    for k, item in pairs(points) do
        callback(item)
    end
end

function ScalableLayer:onTouchBegin(touch)
    self._touches[touch.id] = touch
    self:stopAllActions()
    self._moveTouch = nil
    self._beganWorldTouch = touch
    self._moveSlowDownData = nil
    if self:getTouchCount() == 1 then
        self._touchMoving = true
        self._lastMoveTime = uq.curMillSecond()
        self._startMoveTime = uq.curMillSecond()
        self._beganTouch = self._touches[touch.id]
    elseif self:getTouchCount() > 1 then
        self._touchMoving = false
        self._scaleTouch = true
    end
    return true
end

--限速
function ScalableLayer:limitSpeed(speed)
    if math.abs(speed.x) > self._limitSpeed and math.abs(speed.x) >= math.abs(speed.y) then
        local temp_x = speed.x
        speed.x = self._limitSpeed * speed.x / math.abs(speed.x)
        speed.y = speed.y * self._limitSpeed / math.abs(temp_x)
    elseif math.abs(speed.y) > self._limitSpeed and math.abs(speed.y) >= math.abs(speed.x) then
        local temp_y = speed.y
        speed.y = self._limitSpeed * speed.y / math.abs(speed.y)
        speed.x = speed.x * self._limitSpeed / math.abs(temp_y)
    end
    return speed
end

function ScalableLayer:onTouchMove(touch_pos)
    self._touches[touch_pos.id] = touch_pos
    if self:getTouchCount() == 1 then
        if self._touchMoving and not self._scaleTouch and not self._scaleAction and not self._moveAction then
            local delta = nil
            --根据世界坐标系转化
            if self._moveTouch then
                delta = cc.p(touch_pos.x - self._moveTouch.x, touch_pos.y - self._moveTouch.y)
            else
                delta = cc.p(touch_pos.x - self._beganTouch.x, touch_pos.y - self._beganTouch.y)
            end
            local delta_t = (uq.curMillSecond() - self._lastMoveTime) / 1000
            if delta_t > 0 then
                self._moveSlowDownData = {}
                self._moveSlowDownData.speed = cc.p(delta.x / delta_t * 2, delta.y / delta_t * 2)
                self._moveSlowDownData.speed = self:limitSpeed(self._moveSlowDownData.speed)
                self._moveSlowDownData.distance = cc.p(0, 0)
                self._moveSlowDownData.deltax = delta.x
                self._moveSlowDownData.deltay = delta.y
                local touch_speed = cc.pGetLength(self._moveSlowDownData.speed)
                self._moveSlowDownData.speed_add = self._speedAdd * math.floor(touch_speed / 1500) * 2 + self._speedAdd
                self._startMoveTime = uq.curMillSecond()
                self:updatePosition(delta.x, delta.y)
            end
        end
    elseif self:getTouchCount() >= 2 then
        self._scaleTouch = true
        local touch1 = nil
        local touch2 = nil
        for _, touch in pairs(self._touches) do
            if touch then
                if not touch1 then
                    touch1 = touch
                elseif not touch2 then
                    touch2 = touch
                end
            end
            if touch2 then
                break
            end
        end
        if touch1 and touch2 and self._canScale and not self._scaleAction and not self._moveAction then
            local delta_x = touch1.x - touch2.x
            local delta_y = touch1.y - touch2.y
            local center_x = (touch1.x + touch2.x) / 2
            local center_y = (touch1.y + touch2.y) / 2
            if not self._lastTouchDistance or self._lastTouchDistance == 0 then
                self._lastTouchDistance = cc.pGetLength(cc.p(delta_x, delta_y))
            else
                local ratio = cc.pGetLength(cc.p(delta_x, delta_y)) / self._lastTouchDistance
                if ratio > 1 then
                    ratio = 1 + (ratio - 1) / 10
                elseif ratio < 1 then
                    ratio = 1 - ratio / 10
                end
                local center_pos = self:convertToNodeSpace(cc.p(center_x, center_y))
                self:updateScale(ratio, center_pos)
                self._touchCenterPoint = center_pos
            end
        end
    end
    self._moveTouch = touch_pos
end

function ScalableLayer:onTouchEnd(touch)
    self._touchMoving = false
    self._scaleTouch = false
    self._lastTouchDistance = 0
    self._scaleAction = false
    --移动
    if self:getTouchCount() == 1 and self._beganTouch and self._clickCB then
        if not self._moveTouch then
            --没有移动
            self._clickCB(self:convertToNodeSpace(self._touches[touch.id]))
        else
            --经过移动
            local offx = math.abs(touch.x - self._beganWorldTouch.x)
            local offy = math.abs(touch.y - self._beganWorldTouch.y)
            if offx < 3 and offy < 3 then
                self._clickCB(self:convertToNodeSpace(self._touches[touch.id]))
            end
        end
    end
    self._touches = {}
    self._beganTouch = nil

    -- if self._canScale and self._touchCenterPoint then
    --     if self:getScaleX() < self._minScaleX then
    --         self:changeScaleAction(self._minScaleX, self._touchCenterPoint)
    --         self._moveSlowDownData = nil
    --     elseif self:getScaleX() > self._maxScaleX then
    --         self:changeScaleAction(self._maxScaleX, self._touchCenterPoint)
    --         self._moveSlowDownData = nil
    --     end
    -- end
end

function ScalableLayer:onTouchCancelled(touches)
    self:onTouchEnd(touches)
end

function ScalableLayer:minScale(scale_x, scale_y)
    self._minScaleX = scale_x
    self._minScaleY = scale_y
    self._offScaleMin = self._offScaleMin * self._minScaleX
end

function ScalableLayer:maxScale(scale_x, scale_y)
    self._maxScaleX = scale_x
    self._maxScaleY = scale_y
    self._offScaleMax = self._offScaleMax * self._maxScaleX
end

function ScalableLayer:update(dt)
    --crash
    if not self.moveSlowDown then
        return
    end
    self:moveSlowDown(dt)
    self:scaleAction(dt)
    self:moveAction(dt)
end

function ScalableLayer:changeScaleAction(scale, center_pos, speed)
    self._scaleAction = true
    self._destScale = scale
    self._centerPos = center_pos
    speed = speed or 0.2
    if self._destScale >= self:getScale() then
        self._scaleActionSpeed = speed
    else
        self._scaleActionSpeed = -speed
    end
end

function ScalableLayer:scaleAction(dt)
    if not self._scaleAction then
        return
    end

    local off_scale = dt * self._scaleActionSpeed
    self:updateScale(1 + off_scale, self._centerPos)
    if self._scaleActionSpeed >= 0 then
        if self:getScale() >= self._destScale then
            self:updateScale(self._destScale / self:getScale(), self._centerPos)
            self._scaleAction = false
        end
    else
        if self:getScale() < self._destScale then
            self:updateScale(self._destScale / self:getScale(), self._centerPos)
            self._scaleAction = false
        end
    end
    self._moveSlowDownData = nil
end

function ScalableLayer:moveSlowDown(dt)
    if not self._moveSlowDownData then
        return
    end

    if self._touchMoving or self._scaleTouch or self._scaleAction or self._moveAction then
        return
    end

    local move_speed = self._moveSlowDownData.speed
    local delta_x = 0
    local delta_y = 0

    local speed_add = self._moveSlowDownData.speed_add
    local speed_time = self._speedTime

    if self._moveSlowDownData.deltax == 0 then
        if self._moveSlowDownData.speed.y ~= 0 then
            local speed = move_speed.y
            delta_y = speed * dt * speed_time
            if speed > 0 then
                speed = speed - speed_add * dt
                speed = speed < 0 and 0 or speed
            else
                speed = speed + speed_add * dt
                speed = speed > 0 and 0 or speed
            end
            self._moveSlowDownData.speed.y = speed
            delta_x = 0
            self:updatePosition(delta_x, delta_y)
            return
        end
    elseif self._moveSlowDownData.deltay == 0 then
        if self._moveSlowDownData.speed.x ~= 0 then
            local speed = move_speed.x
            delta_x = speed * dt * speed_time
            if speed > 0 then
                speed = speed - speed_add * dt
                speed = speed < 0 and 0 or speed
            else
                speed = speed + speed_add * dt
                speed = speed > 0 and 0 or speed
            end
            self._moveSlowDownData.speed.x = speed
            delta_y = 0
            self:updatePosition(delta_x, delta_y)
            return
        end
    else
        if math.abs(self._moveSlowDownData.deltax) > math.abs(self._moveSlowDownData.deltay) then
            if self._moveSlowDownData.speed.x ~= 0 then
                local speed = move_speed.x
                delta_x = speed * dt * speed_time
                if speed > 0 then
                    speed = speed - speed_add * dt
                    speed = speed < 0 and 0 or speed
                else
                    speed = speed + speed_add * dt
                    speed = speed > 0 and 0 or speed
                end
                self._moveSlowDownData.speed.x = speed
                self._moveSlowDownData.distance.x = self._moveSlowDownData.distance.x + delta_x

                local distance_y = self._moveSlowDownData.distance.x * self._moveSlowDownData.deltay / self._moveSlowDownData.deltax
                delta_y = distance_y - self._moveSlowDownData.distance.y
                self._moveSlowDownData.distance.y = distance_y
                self:updatePosition(delta_x, delta_y)
                return
            end
        else
            if self._moveSlowDownData.speed.y ~= 0 then
                local speed = move_speed.y
                delta_y = speed * dt * speed_time
                if speed > 0 then
                    speed = speed - speed_add * dt
                    speed = speed < 0 and 0 or speed
                else
                    speed = speed + speed_add * dt
                    speed = speed > 0 and 0 or speed
                end
                self._moveSlowDownData.speed.y = speed
                self._moveSlowDownData.distance.y = self._moveSlowDownData.distance.y + delta_y

                local distance_x = self._moveSlowDownData.distance.y * self._moveSlowDownData.deltax / self._moveSlowDownData.deltay
                delta_x = distance_x - self._moveSlowDownData.distance.x
                self._moveSlowDownData.distance.x = distance_x
                self:updatePosition(delta_x, delta_y)
                return
            end
        end
    end
    self._moveSlowDownData = nil
end

function ScalableLayer:movePosition(deltax, deltay, speed, callback)
    speed = speed or 5
    self._moveSlowDownData = nil
    self._moveActionData = {deltax_left = deltax, deltay_left = deltay, deltax = deltax, deltay = deltay}
    self._moveActionData.speedx = deltax * speed
    self._moveActionData.speedy = deltay * speed
    self._moveAction = true
    self._moveCallback = callback
end

function ScalableLayer:moveAction(dt)
    if not self._moveActionData or not self._moveAction then
        return
    end

    local delta_x = 0
    local delta_y = 0
    if self._moveActionData.deltax == 0 then
        if self._moveActionData.deltay_left ~= 0 then
            delta_y = self._moveActionData.speedy * dt
            local distance = self._moveActionData.deltay_left - delta_y

            if distance * self._moveActionData.deltay < 0 then
                distance = 0
                delta_y = self._moveActionData.deltay_left
            end
            self._moveActionData.deltay_left = distance

            self:updatePosition(delta_x, delta_y)
            return
        end
    elseif self._moveActionData.deltay == 0 then
        if self._moveActionData.deltax_left ~= 0 then
            delta_x = self._moveActionData.speedx * dt
            local distance = self._moveActionData.deltax_left - delta_x

            if distance * self._moveActionData.deltax < 0 then
                distance = 0
                delta_x = self._moveActionData.deltax_left
            end
            self._moveActionData.deltax_left = distance

            self:updatePosition(delta_x, delta_y)
            return
        end
    else
        if math.abs(self._moveActionData.deltax_left) > math.abs(self._moveActionData.deltay_left) then
            if self._moveActionData.deltax_left ~= 0 then
                delta_x = self._moveActionData.speedx * dt
                local distance = self._moveActionData.deltax_left - delta_x

                if distance * self._moveActionData.deltax < 0 then
                    distance = 0
                    delta_x = self._moveActionData.deltax_left
                end
                self._moveActionData.deltax_left = distance

                local distance_y = (self._moveActionData.deltax - self._moveActionData.deltax_left) * self._moveActionData.deltay / self._moveActionData.deltax
                delta_y = distance_y + self._moveActionData.deltay_left - self._moveActionData.deltay
                self._moveActionData.deltay_left = self._moveActionData.deltay_left - delta_y

                self:updatePosition(delta_x, delta_y)
                return
            end
        else
            if self._moveActionData.deltay_left ~= 0 then
                delta_y = self._moveActionData.speedy * dt
                local distance = self._moveActionData.deltay_left - delta_y

                if distance * self._moveActionData.deltay < 0 then
                    distance = 0
                    delta_y = self._moveActionData.deltay_left
                end
                self._moveActionData.deltay_left = distance

                local distance_x = (self._moveActionData.deltay - self._moveActionData.deltay_left) * self._moveActionData.deltax / self._moveActionData.deltay
                delta_x = distance_x + self._moveActionData.deltax_left - self._moveActionData.deltax
                self._moveActionData.deltax_left = self._moveActionData.deltax_left - delta_x

                self:updatePosition(delta_x, delta_y)
                return
            end
        end
    end
    self._moveActionData = nil
    self._moveAction = false
    if self._moveCallback then
        self._moveCallback()
    end
end

function ScalableLayer:updatePosition(delta_x, delta_y)
    if delta_x == 0 and delta_y == 0 then
        return
    end
    local pos_x = self:getPositionX() + delta_x
    local pos_y = self:getPositionY() + delta_y
    local size = self:getContentSize()
    local width = size.width * self:getScaleX()
    local height = size.height * self:getScaleY()

    if width < display.width then
        pos_x = 0
    else
        local max_x = math.abs((width - display.width) / 2)
        if pos_x < -max_x then
            pos_x = -max_x
        end
        if pos_x > max_x then
            pos_x = max_x
        end
    end

    if height < display.height then
        pos_y = 0
    else
        local max_y = math.abs((height - display.height) / 2)
        if pos_y < -max_y then
            pos_y = -max_y
        end
        if pos_y > max_y then
            pos_y = max_y
        end
    end
    delta_x = pos_x - self:getPositionX()
    delta_y = pos_y - self:getPositionY()
    self:setPosition(cc.p(pos_x, pos_y))
    if self._moveCB then
        self._moveCB(cc.p(delta_x, delta_y))
    end
    if self._imageMap then
        self._imageMap:moveMap(cc.p(delta_x, delta_y))
    end
end

function ScalableLayer:setPositionLeft()
    local size = self:getContentSize()
    local width = size.width * self:getScaleX()
    local height = size.height * self:getScaleY()

    if width < display.width then
        self:setPositionX(0)
    else
        self:setPositionX((width - display.width) / 2)
    end
end

function ScalableLayer:updateScale(scale, center_point, ignore_limit)
    if uq.cache.guide._closeMapScale then
        return
    end
    ignore_limit = ignore_limit or false
    local pos_x = self:getPositionX()
    local pos_y = self:getPositionY()
    local size = self:getContentSize()

    local scale_x = scale * self:getScaleX()
    local scale_y = scale * self:getScaleY()
    if not ignore_limit then
        scale_x = math.min(scale_x, self._maxScaleX + self._offScaleMax)
        if self._minScaleX then
            scale_x = math.max(scale_x, self._minScaleX - self._offScaleMin)
        else
            local min_scale_x = display.width / size.width
            scale_x = math.max(scale_x, min_scale_x)
        end

        scale_y = math.min(scale_y, self._maxScaleY + self._offScaleMax)
        if self._minScaleY then
            scale_y = math.max(scale_y, self._minScaleY - self._offScaleMin)
        else
            local min_scale_y = display.height / size.height
            scale_y = math.max(scale_y, min_scale_y)
        end
    end

    local width = size.width * scale_x
    local height = size.height * scale_y
    local max_x = (width - display.width) / 2
    if pos_x < -max_x or pos_x > max_x then
        scale_x = (max_x * 2 + display.width) / size.width
    end
    local max_y = (height - display.height) / 2
    if pos_y < -max_y or pos_y > max_y then
        scale_y = (max_y * 2 + display.height) / size.height
    end
    local delta_x = (self:getScaleX() - scale_x) * center_point.x
    local delta_y = (self:getScaleY() - scale_y) * center_point.y
    self:setScaleX(scale_x)
    self:setScaleY(scale_y)
    self:updatePosition(delta_x, delta_y)

    if self._scaleCB then
        self._scaleCB(self:getScale())
    end
    if self._imageMap then
        self._imageMap:scaleCallback(self:getScale())
    end
    if self._scaleCallBack then
        self._scaleCallBack(self:getScale())
    end
end

function ScalableLayer:scaleCallback(func)
    self._scaleCallBack = func
end

function ScalableLayer:dispose()
    if self._timerId then
        local scheduler = cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(self._timerId)
        self._timerId = nil
    end
    self:removeSelf()
end

return ScalableLayer