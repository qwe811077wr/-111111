local RewardPreviewItems = class("RewardPreviewItems", require('app.base.ChildViewBase'))
local EquipItem = require("app.modules.common.EquipItem")

RewardPreviewItems.RESOURCE_FILENAME = "common/RewardPreviewItems.csb"
RewardPreviewItems.RESOURCE_BINDING = {
    ["Node_1"]                 = {["varname"] = "_nodeItems"},
    ["name_txt"]               = {["varname"] = "_txtName"},
    ["num_txt"]                = {["varname"] = "_txtNum"},
}

function RewardPreviewItems:onCreate()
    RewardPreviewItems.super.onCreate(self)
    self:parseView()
end

function RewardPreviewItems:setData(data)
    if not data or next(data) == nil then
        return
    end
    self._txtNum:setString("x" .. data.num)
    local info = StaticData.getCostInfo(data.type, data.id)
    if info and info.name then
       self._txtName:setString(info.name)
    end
    local euqip_item = EquipItem:create({info = data})
    euqip_item:setTouchEnabled(true)
    euqip_item:setScale(0.7)
    euqip_item:showName(false)
    euqip_item:addClickEventListenerWithSound(function(sender)
        local info = sender:getEquipInfo()
        uq.showItemTips(info)
    end)
    self._nodeItems:addChild(euqip_item)
end


return RewardPreviewItems