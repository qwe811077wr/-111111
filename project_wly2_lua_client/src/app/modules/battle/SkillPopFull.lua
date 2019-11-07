local SkillPopFull = class("SkillPopFull", require('app.base.ModuleBase'))

SkillPopFull.RESOURCE_FILENAME = "battle/SkillPopFull.csb"
SkillPopFull.RESOURCE_BINDING = {
    ["Panel_1"]   = {["varname"] = "_panelBg"},
    ["Node_1"]    = {["varname"] = "_nodeEffect"},
    ["Panel_1_0"] = {["varname"] = "_panelClip"},
}

function SkillPopFull:onCreate()
    SkillPopFull.super.onCreate(self)
    self:setBaseBgVisible(false)
    self:centerView()

    self._panelBg:setContentSize(display.size)
    self._panelBg:setPosition(display.center)
    uq:addEffectByNode(self._nodeEffect, 600002, -1, false, cc.p(-display.width / 4, 0), nil, 2)

    self._panelClip:setContentSize(cc.size(display.width, CC_DESIGN_RESOLUTION.height))
    self._panelClip:setPosition(display.center)
end

function SkillPopFull:onExit()
    SkillPopFull.super:onExit()
end

function SkillPopFull:setData(data, callback)
    local general_config = StaticData['general'][data.id]
    local anim_id = general_config.imageId
    local pre_path = "animation/spine/" .. anim_id .. '/' .. anim_id
    local anim = sp.SkeletonAnimation:createWithBinaryFile(pre_path .. '.skel', pre_path .. '.atlas', 1)
    self._panelClip:addChild(anim)
    anim:setScale(general_config.imageRatio)
    anim:setAnimation(0, 'idle', true)
    anim:setPosition(cc.p(-display.width / 2, -CC_DESIGN_RESOLUTION.height / 2))
    local action1 = cc.EaseBackInOut:create(cc.MoveBy:create(0.2, cc.p(display.width / 4 * 3, 0)))
    local action2 = cc.DelayTime:create(1.5)
    local action3 = cc.EaseBackInOut:create(cc.MoveBy:create(0.2, cc.p(-display.width / 4 * 3, 0)))
    anim:runAction(cc.Sequence:create(action1, action2, action3, cc.CallFunc:create(function()
        self:disposeSelf()
        callback()
    end)))
end

return SkillPopFull