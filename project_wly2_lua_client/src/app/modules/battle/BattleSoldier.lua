local BattleSoldier = class('BattleSoldier', require('app.base.ChildViewBase'))

function BattleSoldier:onCreate()
    BattleSoldier.super.onCreate(self)
    self.ACTION = uq.config.constant.ACTION_TYPE
    self._finishCB = nil
    self._isDead = false
    self._animationPath = 'soldier'
end

function BattleSoldier:setData(obj, side, flip_x, index, dir, path)
    self._dir = dir
    self._animationPath = path or 'soldier'
    self._template = StaticData[self._animationPath][obj.soldier_id] or StaticData[self._animationPath][1]
    self._action = self._template.action
    local prefix = string.format('animation/' .. self._animationPath .. '/%s', self._template.action)
    local png_file = string.format('%s_%d.png', prefix, side)
    if cc.FileUtils:getInstance():isFileExist(png_file) then
        self._action = string.format('%s_%d', self._action, side)
    end
    self._animationGroup = uq.AnimationManager:getInstance():getAction(self._animationPath, self._action)
    self._animation = require('app/modules/battle/ObjectAnimation'):create(self, self._animationGroup, flip_x)

    self._delayPerUnit = {}
    for k, item in pairs(self._animationGroup) do
        self._delayPerUnit[k] = item:getDelayPerUnit()
    end
end

function BattleSoldier:onExit()
    uq.AnimationManager:getInstance():dispose(self._animationPath, self._action)

    local animations = uq.AnimationManager:getInstance():getAnimation(self._animationPath, self._action)
    if animations then
        for k, item in pairs(animations) do
            item:setDelayPerUnit(self._delayPerUnit[k])
        end
    end

    BattleSoldier.super:onExit()
end

function BattleSoldier:playActionByAngle(angle)
    if angle > -22.5 and angle <= 22.5 then
        self._animation:play(self.ACTION.ANIMATION_NAME_MOVE_E, true)
    elseif angle > 22.5 and angle <= 67.5 then
        self._animation:play(self.ACTION.ANIMATION_NAME_MOVE_NE, true)
    elseif angle > 67.5 and angle <= 112.5 then
        self._animation:play(self.ACTION.ANIMATION_NAME_MOVE_N, true)
    elseif angle > 112.5 and angle <= 157.5 then
        self._animation:play(self.ACTION.ANIMATION_NAME_MOVE_NW, true)
    elseif angle <= -22.5 and angle > -67.5 then
        self._animation:play(self.ACTION.ANIMATION_NAME_MOVE_SE, true)
    elseif angle <= -67.5 and angle > -112.5 then
        self._animation:play(self.ACTION.ANIMATION_NAME_MOVE_S, true)
    elseif angle <= -112.5 and angle > -157.5 then
        self._animation:play(self.ACTION.ANIMATION_NAME_MOVE_SW, true)
    else
        self._animation:play(self.ACTION.ANIMATION_NAME_MOVE_W, true)
    end
end

function BattleSoldier:playIdle()
    self._animation:play(self.ACTION.ANIMATION_NAME_IDLE, true)
end

function BattleSoldier:playWalkLeft()
    if self._animation:getAnimation(self.ACTION.ANIMATION_NAME_MOVE) then
        self._animation:play(self.ACTION.ANIMATION_NAME_MOVE, true)
    else
        self._animation:play(self.ACTION.ANIMATION_NAME_MOVE_SW, true)
    end
end

function BattleSoldier:playWalkRight()
    self._animation:play(self.ACTION.ANIMATION_NAME_RETREAT, true)
    if self._animation:getAnimation(self.ACTION.ANIMATION_NAME_RETREAT) then
        self._animation:play(self.ACTION.ANIMATION_NAME_RETREAT, true)
    else
        self._animation:play(self.ACTION.ANIMATION_NAME_MOVE_NE, true)
    end
end

function BattleSoldier:playAttack(finishCB)
    self._finishCB = finishCB
    self._animation:play(self.ACTION.ANIMATION_NAME_ATTACK, false, 1, handler(self, self.actionFinished))
end

function BattleSoldier:playHurt(finishCB)
    if self._animation:getAnimation(self.ACTION.ANIMATION_NAME_REPEL) then
        local rand_num = math.random(0, 1)
        if rand_num == 1 then
            self:playRepel(finishCB)
        else
            self._finishCB = finishCB
            self._animation:play(self.ACTION.ANIMATION_NAME_HIT, false, 1, handler(self, self.actionFinished))
        end
    else
        self._finishCB = finishCB
        self._animation:play(self.ACTION.ANIMATION_NAME_HIT, false, 1, handler(self, self.actionFinished))
    end
end

function BattleSoldier:playRepel(finishCB)
    self._finishCB = finishCB
    self._animation:play(self.ACTION.ANIMATION_NAME_REPEL, false, 1, handler(self, self.actionFinished))
end

function BattleSoldier:playReady(finishCB)
    self._finishCB = finishCB
    if self._animation:getAnimation(self.ACTION.ANIMATION_NAME_READY) then
        self._animation:play(self.ACTION.ANIMATION_NAME_READY, false, 1, handler(self, self.actionFinished))
    else
        self._animation:play(self.ACTION.ANIMATION_NAME_SKILL, false, 1, handler(self, self.actionFinished))
    end
end

function BattleSoldier:playSkill(finishCB)
    self._finishCB = finishCB
    self._animation:play(self.ACTION.ANIMATION_NAME_SKILL, false, 1, handler(self, self.actionFinished))
end

function BattleSoldier:disappear(delay_time, disappear_time)
    self._animation:disappear(delay_time, disappear_time)
end

function BattleSoldier:playDie(finishCB)
    self._deadfinishCB = finishCB
    self._animation:play(self.ACTION.ANIMATION_NAME_DEATH, false, 1, handler(self, self.actionFinished))
end

function BattleSoldier:playDieDir(finishCB)
    -- self._deadfinishCB = finishCB
    -- self._animation:play(self.ACTION.ANIMATION_NAME_DEATH_M .. self:getDir(), false, 1, handler(self, self.actionFinished))
    self:playDie(finishCB)
end

function BattleSoldier:actionFinished()
    if self._finishCB then
        self._finishCB(self)
        self._finishCB = nil
    end
    if self._deadfinishCB then
        self._deadfinishCB(self)
        self._deadfinishCB = nil
    end
end

function BattleSoldier:isDead()
    return self._isDead
end

function BattleSoldier:setDead(flag)
    self._isDead = flag
end

function BattleSoldier:setSpeed(speed)
    for k, item in pairs(self._animationGroup) do
        item:setDelayPerUnit(self._delayPerUnit[k] / speed)
    end
end

function BattleSoldier:setDefaultSpeed(speed)
    for k, item in pairs(self._animationGroup) do
        self._delayPerUnit[k] = self._delayPerUnit[k] * speed
        item:setDelayPerUnit(self._delayPerUnit[k])
    end
end

function BattleSoldier:getAnimationTime(name)
    return self._animation:getAnimationTime(name)
end

function BattleSoldier:getAnimation(name)
    return self._animation:getAnimation(name)
end

function BattleSoldier:getDir()
    return self._dir
end

function BattleSoldier:setHightLight(flag)
    if flag then
        uq.ShaderEffect:addHightLightNode(self._animation:getSprite())
    else
        uq.ShaderEffect:removeHightLight(self._animation:getSprite())
    end
end

return BattleSoldier