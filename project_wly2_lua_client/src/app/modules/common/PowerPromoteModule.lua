local PowerPromoteModule = class("PowerPromoteModule", require("app.base.ModuleBase"))

PowerPromoteModule.RESOURCE_FILENAME = "common/FightingPowerPromote.csb"
PowerPromoteModule.RESOURCE_BINDING  = {
    ["Text_1"]                                       ={["varname"] = "_txtPower"},
    ["Text_2"]                                       ={["varname"] = "_txtAdd"},
    ["Node_1"]                                       ={["varname"] = "_nodeEffect"},
    ["Sprite_4"]                                     ={["varname"] = "_sprite4"},
    ["Sprite_3"]                                     ={["varname"] = "_sprite3"},
    ["Sprite_2"]                                     ={["varname"] = "_sprite2"},
    ["Sprite_1"]                                     ={["varname"] = "_sprite1"},
}

function PowerPromoteModule:ctor(name, params)
    PowerPromoteModule.super.ctor(self, name, params)
    self._addPower = params.add_power
    uq.AnimationManager:getInstance():getEffect('zhanlitisheng', nil, nil, true)
end

function PowerPromoteModule:init()
    self:setPosition(cc.p(display.size.width / 2, CC_DESIGN_RESOLUTION.height))
    self._txtAdd:setOpacity(0)
    self._txtPower:setString(uq.cache.role.power)
    self._txtAdd:setString("+" .. self._addPower)
    self:runOpenAction()
    self:setSwallowBgTouch(false)
    self:setBaseBgVisible(false)
end

function PowerPromoteModule:runOpenAction()
    self._delta = 1 / 12
    self._sprite3:setVisible(true)
    self._txtPower:setVisible(false)
    self._sprite1:setOpacity(0)
    local spawn = cc.Spawn:create(cc.ScaleTo:create(self._delta * 5, 3.5), cc.FadeOut:create(self._delta * 5))
    self._sprite3:runAction(cc.Sequence:create(cc.ScaleTo:create(self._delta * 2, 3), spawn))
    self._nodeEffect:runAction(cc.Sequence:create(cc.DelayTime:create(self._delta * 2), cc.CallFunc:create(function()
        self._sprite4:setVisible(true)
        self._sprite4:runAction(cc.Spawn:create(cc.ScaleTo:create(self._delta * 6, 1.8, 1), cc.FadeOut:create(self._delta * 6)))
        self._sprite2:setVisible(true)
        self._sprite2:runAction(cc.ScaleTo:create(self._delta * 8, 5, 1))
        self._sprite1:runAction(cc.FadeOut:create(self._delta))
        self._txtAdd:setOpacity(0.4 * 255)
        self._txtPower:setVisible(true)

        local action1 = cc.Sequence:create(cc.FadeTo:create(self._delta * 2, 255), cc.DelayTime:create(self._delta * 5), cc.FadeOut:create(self._delta * 9))
        self._txtAdd:runAction(cc.Spawn:create(cc.MoveBy:create(self._delta * 16, cc.p(0, 50)), action1))
        self._txtPower:runAction(cc.Sequence:create(cc.FadeOut:create(self._delta * 17), cc.FadeOut:create(self._delta * 5)))
    end)))
    uq:addEffectByNode(self._nodeEffect, 900189, 1, true, nil, function()
        self:disposeSelf()
    end)
end

function PowerPromoteModule:dispose()
    PowerPromoteModule.super.dispose(self)
end

return PowerPromoteModule