local SpriteAnimation = class('SpriteAnimation')

SpriteAnimation.ACTION_TAG = 10001

function SpriteAnimation:ctor(sprite)
    self._sprite = sprite
end

function SpriteAnimation:play(animation, repeated, loop_num, finish_cb)
    if loop_num and loop_num == 0 then
        if finish_cb then
            finish_cb()
        end
        return
    end
    self._animation = animation
    local action = cc.Animate:create(animation)
    self._animateAction = action
    if loop_num and loop_num > 1 then
        action = cc.Repeat:create(action, loop_num)
    end
    if repeated == true then
        action = cc.RepeatForever:create(action)
    else
        action = cc.Sequence:create(action, cc.CallFunc:create(finish_cb))
    end
    self._sprite:runAction(action)

    self._sprite:stopActionByTag(self.ACTION_TAG)
    action:setTag(self.ACTION_TAG)
end

function SpriteAnimation:disappear(delay_time, disappear_time)
    uq.delayAction(self._sprite, delay_time, function()
        local action = cc.FadeOut:create(disappear_time)
        self._sprite:runAction(action)
    end)
end

----------------------------------------------------------------------------------
local ObjectAnimation = class('ObjectAnimation')

function ObjectAnimation:ctor(node, animations, flip_x)
    self._animations = animations
    flip_x           = flip_x or false

    local sprite = display.newSprite()
    sprite:setFlippedX(flip_x)
    node:addChild(sprite)

    self._sprite = sprite
    self._spriteAni = SpriteAnimation:create(sprite)

    self._actionFinishedCB = nil
end

function ObjectAnimation:getAnimateAction()
    return self._spriteAni._animateAction
end

function ObjectAnimation:play(name, repeated, loop_num, finish_cb)
    local animation = self._animations[name]
    self._actionFinishedCB = finish_cb
    if not animation then
        --没有动作，则直接完成
        self:_actionFinished()
        return
    end
    self._spriteAni:play(animation, repeated, loop_num, handler(self, self._actionFinished))
end

function ObjectAnimation:playEffect(repeated, loop_num, finish_cb)
    local animation = self._animations
    self._actionFinishedCB = finish_cb
    if not animation then
        --没有动作，则直接完成
        self:_actionFinished()
        return
    end
    self._spriteAni:play(animation, repeated, loop_num, handler(self, self._actionFinished))
end

function ObjectAnimation:_actionFinished()
    if self._actionFinishedCB then
        self._actionFinishedCB()
    end
end

function ObjectAnimation:disappear(delay_time, disappear_time)
    self._spriteAni:disappear(delay_time, disappear_time)
end

function ObjectAnimation:setPosition(pos)
    self._sprite:setPosition(pos)
end

function ObjectAnimation:setVisible(flag)
    self._sprite:setVisible(flag)
end

function ObjectAnimation:setScale(scale)
    self._sprite:setScale(scale)
end

function ObjectAnimation:getSprite()
    return self._sprite
end

function ObjectAnimation:getAnimationTime(name)
   return self._animations[name].total_time
end

function ObjectAnimation:getAnimation(name)
   return self._animations[name]
end

return ObjectAnimation