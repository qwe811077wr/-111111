local InstanceSoldier = class('InstanceSoldier', require('app.base.ChildViewBase'))

function InstanceSoldier:onCreate()
    InstanceSoldier.super.onCreate(self)
    self.ACTION = uq.config.constant.ACTION_TYPE
    self._data = nil
end

function InstanceSoldier:setData(instance_id, instance_data, action, fliped, file_name)
    self._instanceId = instance_id
    self._data = instance_data
    self._action = action
    self._fileName = file_name or 'soldier'
    self._animationGroup = uq.AnimationManager:getInstance():getAction(self._fileName, action)
    self._animation = require('app/modules/battle/ObjectAnimation'):create(self, self._animationGroup, fliped)

    self._delayPerUnit = {}
    for k, item in pairs(self._animationGroup) do
        self._delayPerUnit[k] = item:getDelayPerUnit()
    end
end

function InstanceSoldier:onExit()
    uq.AnimationManager:getInstance():dispose(self._fileName, self._action)

    InstanceSoldier.super:onExit()
end

function InstanceSoldier:playStand()
    self._animation:play(self.ACTION.ANIMATION_NAME_STAND, true)
end

function InstanceSoldier:playIdle()
    self._animation:play(self.ACTION.ANIMATION_NAME_IDLE, true)
end

function InstanceSoldier:playAttack(callback)
    self._animation:play(self.ACTION.ANIMATION_NAME_ATTACK, false, 1, callback)
end

function InstanceSoldier:setSpeed(speed)
    for k, item in pairs(self._animationGroup) do
        item:setDelayPerUnit(self._delayPerUnit[k] / speed)
    end
end

function InstanceSoldier:setDefaultSpeed(speed)
    for k, item in pairs(self._animationGroup) do
        self._delayPerUnit[k] = self._delayPerUnit[k] * speed
        item:setDelayPerUnit(self._delayPerUnit[k])
    end
end

function InstanceSoldier:setSoldierScale(scale)
    self._animation:setScale(scale)
end

return InstanceSoldier