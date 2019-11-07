local ViewAction = class('ViewAction')

function ViewAction:ctor(view,args,call_back)
    self._view = view
    self._isStopAction = args and args._isStopAction
    self._openActionId = args and (args._openActionId or 1)
    self._closeActionId = args and (args._closeActionId or 1)
end

function ViewAction:playOpenAction(call_back)
    if not self._isStopAction then
        local action = cc.Sequence:create(cc.ScaleTo:create(0.2, 1.15), cc.ScaleTo:create(0.15, 1), cc.DelayTime:create(0.2), cc.CallFunc:create(call_back))
        if self._openActionId == 1 then
            self._view:setScale(0.1)
        end
        self._view:stopAllActions()
        self._view:runAction(action)
    else
        if call_back then
            call_back()
        end
    end
end

function ViewAction:playCloseAction(call_back)
    if not self._isStopAction then
        local action = cc.Sequence:create(cc.ScaleTo:create(0.2,0.1),cc.CallFunc:create(call_back))
        self._view:stopAllActions()
        self._view:runAction(action)
    else
        if call_back then
            call_back()
        end
    end
end

uq.ViewAction = ViewAction