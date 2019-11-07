local NetworkLoading = class("NetworkLoading", require('app.base.PopupBase'))

NetworkLoading.RESOURCE_FILENAME = "common/NetworkLoading.csb"
NetworkLoading.RESOURCE_BINDING = {
    ["Panel_1"]              = {["varname"] = "_panel"},
    ["Image_11"]             = {["varname"] = "_image"},
}

function NetworkLoading:ctor(name, args)
    NetworkLoading.super.ctor(self, name, args)
    self._callBack = args.call_back
    self._tickTag = "network_loading" .. tostring(self)
    self._tickNums = 0
    self:init()
end

function NetworkLoading:init()
    self:setLayerColor()
    self:centerView()
    self._panel:setContentSize(display.size)
    self._image:runAction(cc.RepeatForever:create(cc.RepeatForever:create(cc.RotateBy:create(1, 360))))
    uq.TimerProxy:addTimer(self._tickTag, handler(self, self.tickCallBack), 1, -1)
end

function NetworkLoading:tickCallBack()
    self._tickNums = self._tickNums + 1
    if self._callBack then
        self._callBack()
    end
    if self._tickNums > 4 then
        network:connectError()
        self:disposeSelf()
    end
end

function NetworkLoading:dispose()
    uq.TimerProxy:removeTimer(self._tickTag)
    NetworkLoading.super.dispose(self)
end

return NetworkLoading