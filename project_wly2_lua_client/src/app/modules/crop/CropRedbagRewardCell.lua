local CropRedbagRewardCell = class("CropRedbagRewardCell", require('app.base.ChildViewBase'))
local EquipItem = require("app.modules.common.EquipItem")

function CropRedbagRewardCell:onCreate()
    CropRedbagRewardCell.super.onCreate(self)
end

function CropRedbagRewardCell:setData(data)
    self:removeAllChildren()

    for k, item in pairs(data) do
        local reward = uq.RewardType:create(item.reward)
        local euqip_item = EquipItem:create({info = reward:toEquipWidget()})
        euqip_item:setScale(0.75)
        euqip_item:setPosition(50 + 100 * (k - 1), 50)
        self:addChild(euqip_item)
    end
end

return CropRedbagRewardCell