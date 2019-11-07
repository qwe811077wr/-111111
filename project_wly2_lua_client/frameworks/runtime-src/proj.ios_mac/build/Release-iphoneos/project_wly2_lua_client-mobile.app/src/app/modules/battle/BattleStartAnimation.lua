local BattleStartAnimation = class("BattleStartAnimation", require('app.base.ChildViewBase'))

BattleStartAnimation.RESOURCE_FILENAME = "battle/BattleStartAnimation.csb"
BattleStartAnimation.RESOURCE_BINDING = {
    ["Panel_2"]    = {["varname"] = "_panelBg"},
}

function BattleStartAnimation:onCreate()
    BattleStartAnimation.super.onCreate(self)
    uq.playSoundByID(57)
    self._panelBg:setContentSize(display.size)

    uq:addEffectByNode(self, 900132, 1, false, cc.p(0, 0), handler(self, self.animationEvent), 1)
end

function BattleStartAnimation:setData(report)
end

function BattleStartAnimation:animationEvent()
    local callback = self._endCallback
    self:removeSelf()
    if callback then
        callback()
    end
end

function BattleStartAnimation:setEndCallback(callback)
    self._endCallback = callback
end

return BattleStartAnimation