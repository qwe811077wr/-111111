local InstanceWarPowerFail = class("InstanceWarPowerFail", require('app.base.PopupBase'))

InstanceWarPowerFail.RESOURCE_FILENAME = "instance_war/InstanceWarPowerFail.csb"
InstanceWarPowerFail.RESOURCE_BINDING = {
    ["Text_1"]   = {["varname"] = "_txtResult"},
}

function InstanceWarPowerFail:onCreate()
    InstanceWarPowerFail.super.onCreate(self)
    self:centerView()
    self:parseView()
    self:setLayerColor()
end

function InstanceWarPowerFail:setData(power, call_back)
    local instance_id = uq.cache.instance_war:getCurInstanceId()
    local power_data = uq.cache.instance_war:getPowerConfig(instance_id, power)
    self._txtResult:setString(power_data.Name .. '势力覆灭')
    self._callBack = call_back
end

function InstanceWarPowerFail:onExit()
    if self._callBack then
        self._callBack()
    end
    InstanceWarPowerFail.super.onExit(self)
end

return InstanceWarPowerFail