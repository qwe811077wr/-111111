local CropRedbagReceiveInfoCell = class("CropRedbagReceiveInfoCell", require('app.base.ChildViewBase'))

CropRedbagReceiveInfoCell.RESOURCE_FILENAME = "crop/CropRedbagReceiveInfoCell.csb"
CropRedbagReceiveInfoCell.RESOURCE_BINDING = {
    ["Image_3_0"]    = {["varname"] = "_imgIcon"},
    ["Text_name"]    = {["varname"] = "_txtName"},
    ["Image_7"]      = {["varname"] = "_imgRewardIcon"},
    ["Text_14"]      = {["varname"] = "_txtRewardNum"}
}

function CropRedbagReceiveInfoCell:ctor(name, params)
    CropRedbagReceiveInfoCell.super.ctor(self, name, params)
end

function CropRedbagReceiveInfoCell:init()
    --self:parseView()
end

function CropRedbagReceiveInfoCell:setData(data)
    self._txtName:setString(data.name)

    local item = StaticData['legion_envelopes'][data.item_id]
    local reward = uq.RewardType:create(item.reward)
    local info = StaticData.getCostInfo(reward:type(), reward:id())
    local miniIcon = info and info.miniIcon or "03_0002.png"
    self._imgRewardIcon:loadTexture('img/common/ui/' .. miniIcon)

    self._txtRewardNum:setString(reward:num())
    self:setHeadImg(data.img_id)
end

function CropRedbagReceiveInfoCell:setHeadImg(id)
    local data = StaticData['majesty_heads'][id]
    if not data then
        return
    end
    self._imgIcon:loadTexture("img/common/player_head/" .. data.icon)
end

return CropRedbagReceiveInfoCell