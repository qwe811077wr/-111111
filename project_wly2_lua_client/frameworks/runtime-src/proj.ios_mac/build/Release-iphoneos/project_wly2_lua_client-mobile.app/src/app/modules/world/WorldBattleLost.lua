local WorldBattleLost = class("WorldBattleLost", require("app.base.PopupBase"))

WorldBattleLost.RESOURCE_FILENAME = "world/WorldBattleLost.csb"

WorldBattleLost.RESOURCE_BINDING  = {
    ["Node_effect"]                   ={["varname"] = "_nodeEffect"},
}
function WorldBattleLost:ctor(name, args)
    WorldBattleLost.super.ctor(self, name, args)
    uq.AnimationManager:getInstance():getEffect('txf_4_31', nil, nil, true)
end

function WorldBattleLost:init()
    self:parseView()
    self:setLayerColor()
    self:centerView()
    local delta = 1 / 12
    uq:addEffectByNode(self._nodeEffect, 900155, 1, false)
    self._nodeEffect:runAction(cc.Sequence:create(cc.DelayTime:create(3 * delta), cc.CallFunc:create(function()
        uq:addEffectByNode(self._nodeEffect, 900156, -1, true)
    end)))
end

function WorldBattleLost:dispose()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_WORLD_BATTLE_FIELD_END_BATTLE})
    WorldBattleLost.super.dispose(self)
end

return WorldBattleLost