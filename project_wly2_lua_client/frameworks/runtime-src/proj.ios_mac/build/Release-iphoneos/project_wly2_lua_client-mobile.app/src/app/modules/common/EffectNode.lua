local EffectNode = class("EffectNode", require('app.base.ChildViewBase'))

function EffectNode:onCreate()
    EffectNode.super.onCreate(self)
    self._liveNum = 0
    self._additive = false
    self._timerFlag = 'effect_update' .. tostring(self)
    self._frameNum = 0
end

function EffectNode:playEffectNormal(effect_id, repeated, finish_callback, async, loop_num, reserve)
    repeated = repeated or false
    self._finishCallback = finish_callback
    loop_num = loop_num or -1

    if async == nil then
        async = false
    end

    local effect_data = StaticData['effect'][effect_id]
    if not effect_data or effect_data.tx == "" then
        self:remove()
        return
    end
    self._effectName = effect_data.tx
    self._reserve = reserve

    if async then
        uq.AnimationManager:getInstance():loadEffectAsync(effect_data.tx, function (animation)
            if self._effectName == nil then --数据不对或者已被释放
                return
            end
            self._skillEffect = require('app/modules/battle/ObjectAnimation'):create(self, animation)
            self._animation = animation
            self._skillEffect:playEffect(repeated, loop_num, handler(self, self.remove))
            self._sprite = self._skillEffect:getSprite()
            uq.playSoundByID(tonumber(effect_data.sound))

            if effect_data.isAdd == 1 then
                self:setAdditive()
            end
        end)
    else
        self._animation = uq.AnimationManager:getInstance():loadEffectAsync(effect_data.tx)
        self._skillEffect = require('app/modules/battle/ObjectAnimation'):create(self, self._animation)
        self._skillEffect:playEffect(repeated, loop_num, handler(self, self.remove))
        self._sprite = self._skillEffect:getSprite()
        uq.playSoundByID(tonumber(effect_data.sound))

        if effect_data.isAdd == 1 then
            self:setAdditive()
        end
    end

    return true
end

function EffectNode:setAdditive()
    self._additive = true
    self:openAdditive()
    if not uq.TimerProxy:hasTimer(self._timerFlag) then
        uq.TimerProxy:addTimer(self._timerFlag, handler(self, self.frameCallback), 0, -1)
    end
end

function EffectNode:openAdditive()
    if self._additive == true and self._sprite then
        self._sprite:setBlendFunc({src = GL_DST_ALPHA, dst = GL_ONE})
    end
end

function EffectNode:playEffectFly(effect_id, repeated, finish_callback, loop_num, start_pos, end_pos)
    self:playEffectNormal(effect_id, repeated, finish_callback, false, loop_num)
    -- if self._skillEffect then
    --     local move_action = cc.MoveTo:create(0.01, end_pos)
    --     self:runAction(move_action)
    -- end
end

function EffectNode:setFlipX(flag)
    if self._sprite then
        self._sprite:setFlippedX(flag)
    end
end

function EffectNode:onExit()
    uq.TimerProxy:removeTimer(self._timerFlag)
    if not self._reserve then
        uq.AnimationManager:getInstance():releaseEffect(self._effectName)
    end
    EffectNode.super:onExit()
end

function EffectNode:remove()
    local finish_call = self._finishCallback
    self:removeSelf()
    if finish_call then
        finish_call()
    end
end

function EffectNode:setLiveNum(live_num)
    self._liveNum = live_num
end

function EffectNode:refreshLive()
    if self._liveNum > 0 then
        self._liveNum = self._liveNum - 1
    else
        self:remove()
    end
end

function EffectNode:getSprite()
    return self._sprite
end

function EffectNode:getAnimateAction()
    return self._skillEffect:getAnimateAction()
end

function EffectNode:setFrameCallback(callback)
    self._frameCallback = callback
    if not uq.TimerProxy:hasTimer(self._timerFlag) then
        uq.TimerProxy:addTimer(self._timerFlag, handler(self, self.frameCallback), 0, -1)
    end
end

function EffectNode:frameCallback()
    if not self.getAnimateAction or not self:getAnimateAction() then
        return
    end
    local frame_num = self:getAnimateAction():getCurrentFrameIndex()
    if self._frameCallback then
        self._frameCallback(frame_num)
    end

    if frame_num ~= self._frameNum then
        self:openAdditive()
        self._frameNum = frame_num
    end
end

function EffectNode:getSkillEffectNode()
    return self._skillEffect
end

function EffectNode:getAnimation()
    return self._animation
end

return EffectNode