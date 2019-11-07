local InstanceWarRoundItem = class("InstanceWarRoundItem", require('app.base.ChildViewBase'))

InstanceWarRoundItem.RESOURCE_FILENAME = "instance_war/InstanceWarRoundItem.csb"
InstanceWarRoundItem.RESOURCE_BINDING = {
}

function InstanceWarRoundItem:onCreate()
    InstanceWarRoundItem.super.onCreate(self)
end

function InstanceWarRoundItem:setData(data, channel)
end

return InstanceWarRoundItem