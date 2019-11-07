local InstanceWarArrow = class("InstanceWarArrow", require('app.base.ChildViewBase'))

InstanceWarArrow.RESOURCE_FILENAME = "instance_war/InstanceWarArrow.csb"
InstanceWarArrow.RESOURCE_BINDING = {
    ["Panel_1"] = {["varname"]="_panelBg"},
}

function InstanceWarArrow:onCreate()
    InstanceWarArrow.super.onCreate(self)
    self.ACTION = uq.config.constant.ACTION_TYPE
end

function InstanceWarArrow:setData(dest_pos, cur_pos)
    local pt_mid = cc.pMidpoint(dest_pos, cur_pos)
    self:setPosition(pt_mid)

    local normal = cc.pNormalize(cc.pSub(dest_pos, cur_pos))
    local angle = math.atan2(normal.y, normal.x) * 180 / math.pi + 180

    local len = cc.pGetDistance(dest_pos, cur_pos)
    local off_len = 115 - len
    if off_len > 0 then
        self._panelBg:setContentSize(cc.size(len, 21))
        self._panelBg:setPosition(cc.p(-57.50 + off_len / 2, 0))
    end

    self._animationPath = 'world_soldier'
    self._action = 'BZ2000_3'
    self._animationGroup = uq.AnimationManager:getInstance():getAction(self._animationPath, self._action)
    self._animation = require('app/modules/battle/ObjectAnimation'):create(self:getParent(), self._animationGroup, false)
    self._animation:setPosition(pt_mid)
    self:playActionByAngle(angle - 180)
end

function InstanceWarArrow:playActionByAngle(angle)
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

function InstanceWarArrow:removeEffect()
    if self._animation then
        self._animation:getSprite():removeSelf()
    end
end

function InstanceWarArrow:onExit()
    uq.AnimationManager:getInstance():dispose(self._animationPath, self._action)
    InstanceWarArrow.super:onExit()
end

return InstanceWarArrow