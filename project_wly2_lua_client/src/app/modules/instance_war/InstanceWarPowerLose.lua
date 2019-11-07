local InstanceWarPowerLose = class("InstanceWarPowerLose", require('app.base.PopupBase'))

InstanceWarPowerLose.RESOURCE_FILENAME = "instance_war/InstanceWarPowerLose.csb"
InstanceWarPowerLose.RESOURCE_BINDING = {
    ["Text_2_0"]   = {["varname"] = "_txtRound"},
    ["Text_2_0_1"] = {["varname"] = "_txtCity"},
    ["Text_2_0_0"] = {["varname"] = "_txtPowerFight"},
    ["Text_2_0_2"] = {["varname"] = "_txtGeneral"},
    ["Button_1"]   = {["varname"] = "_btnConfirm",["events"] = {{["event"] = "touch",["method"] = "onConfirm"}}},
}

function InstanceWarPowerLose:onCreate()
    InstanceWarPowerLose.super.onCreate(self)
    self:centerView()
    self:parseView()
    self:setLayerColor()
end

function InstanceWarPowerLose:setData(data, call_back)
    self._txtRound:setString(data.round)
    self._txtCity:setString(data.city_num)
    self._txtPowerFight:setString(data.wipeout)
    self._txtGeneral:setString(data.general_num)
    self._callback = call_back
end

function InstanceWarPowerLose:onExit()
    InstanceWarPowerLose.super.onExit(self)
end

function InstanceWarPowerLose:onConfirm(event)
    if event.name ~= "ended" then
        return
    end
    if self._callback then
        self._callback()
    end
    self:disposeSelf()
end

return InstanceWarPowerLose