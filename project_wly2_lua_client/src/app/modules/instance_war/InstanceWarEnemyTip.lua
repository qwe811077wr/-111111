local InstanceWarEnemyTip = class("InstanceWarEnemyTip", require('app.base.PopupBase'))

InstanceWarEnemyTip.RESOURCE_FILENAME = "instance_war/InstanceWarEnemyTip.csb"
InstanceWarEnemyTip.RESOURCE_BINDING = {
}

function InstanceWarEnemyTip:onCreate()
    InstanceWarEnemyTip.super.onCreate(self)
    self:centerView()
    self:parseView()
    self:setLayerColor()
end

function InstanceWarEnemyTip:onExit()
    if self._callBack then
        self._callBack()
    end
    InstanceWarEnemyTip.super.onExit(self)
end

function InstanceWarEnemyTip:setData(call_back)
    self._callBack = call_back
end

return InstanceWarEnemyTip