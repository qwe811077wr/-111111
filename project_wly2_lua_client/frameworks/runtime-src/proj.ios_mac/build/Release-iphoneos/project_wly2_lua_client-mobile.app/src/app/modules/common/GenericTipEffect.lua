local GenericTipEffect = class("GenericTipEffect",require("app.base.PopupBase"))

GenericTipEffect.RESOURCE_FILENAME = "common/GenericTipEffect.csb"
GenericTipEffect.RESOURCE_BINDING = {
    ['Node_1']                  = {["varname"] = "_nodeTitle"},
    ['Node_3']                  = {["varname"] = "_nodeEffect"},
    ['Image_1']                 = {["varname"] = "_imgTitleLeft"},
    ['Image_2']                 = {["varname"] = "_imgTitleRight"},
}

function GenericTipEffect:ctor(name, params)
    GenericTipEffect.super.ctor(self, name, params)
    self._imgLeft = params._imgLeft
    self._imgRight = params._imgRight
    self._callback = params._callback
end

function GenericTipEffect:init()
    self:setLayerColor()
    self:parseView()
    self:centerView()
    self:changeMaterials()
    self:runOpenAction()
end

function GenericTipEffect:changeMaterials()
    if not self._imgRight or not self._imgLeft then
        return
    end
    self._imgTitleLeft:loadTexture("img/common/tip_text/" .. self._imgLeft)
    self._imgTitleRight:loadTexture("img/common/tip_text/" .. self._imgRight)
end

function GenericTipEffect:runOpenAction()
    local delay = cc.DelayTime:create(0.2)
    self._nodeTitle:setVisible(false)
    local fun1 = cc.CallFunc:create(function()
        self._nodeTitle:setVisible(true)
        local left_bg_size = self._imgTitleLeft:getContentSize()
        local move_left = cc.MoveTo:create(0.1, cc.p(-left_bg_size.width / 2 + 3, 0))
        self._imgTitleLeft:runAction(move_left)
        local right_bg_size = self._imgTitleRight:getContentSize()
        local move_right = cc.MoveTo:create(0.1, cc.p(right_bg_size.width / 2 - 3, 0))
        self._imgTitleRight:runAction(move_right)
        local delay_time = cc.DelayTime:create(0.1)
        local call_func = cc.CallFunc:create(function()
            uq:addEffectByNode(self._nodeEffect, 900122, 1, true, cc.p(0, 0))
        end)
        self._nodeEffect:runAction(cc.Sequence:create(delay_time, call_func))
    end)

    local fun2 = cc.CallFunc:create(function()
        uq:addEffectByNode(self._nodeEffect, 900123, -1, false, cc.p(0, 0))
    end)
    self._nodeEffect:runAction(cc.Sequence:create(delay, fun1, fun2))
end


function GenericTipEffect:dispose()
    GenericTipEffect.super.dispose(self)
end

return GenericTipEffect