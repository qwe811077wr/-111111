local CropRedbagReceive = class("CropRedbagReceive", require('app.base.PopupBase'))

CropRedbagReceive.RESOURCE_FILENAME = "crop/CropRedbagReceive.csb"
CropRedbagReceive.RESOURCE_BINDING = {
    ["Image_3"]      = {["varname"] = "_imgHeadIcon"},
    ["Text_1"]       = {["varname"] = "_txtName"},
    ["Text_5"]       = {["varname"] = "_txtBlessing"},
    ["Image_6"]      = {["varname"] = "_imgRewardIcon"},
    ["Text_6"]       = {["varname"] = "_txtRewardNum"}
}

function CropRedbagReceive:ctor(name, params)
    CropRedbagReceive.super.ctor(self, name, params)
end

function CropRedbagReceive:onCreate()
    CropRedbagReceive.super.onCreate(self)
end

function CropRedbagReceive:init()
    self:centerView()
    self:parseView()
end

function CropRedbagReceive:_onRedBagPick(data)
    local red_bag = uq.cache.crop._allRedbag
    for k,v in pairs(red_bag) do
        if data.id == v.id then
            self._redbagData = v
            break
        end
    end
    self._txtName:setString(self._redbagData.role_name)

    local item = StaticData['legion_envelopes'][data.item_id]
    local reward = uq.RewardType:create(item.reward)
    local info = StaticData.getCostInfo(reward:type(), reward:id())
    local miniIcon = info and info.miniIcon or "03_0002.png"
    self._imgRewardIcon:loadTexture('img/common/ui/' .. miniIcon)
    self._imgRewardIcon:setScale(1.2)

    self._txtRewardNum:setString(reward:num())
    self:setHeadImg(data.img_id)
end

function CropRedbagReceive:setHeadImg(id)
    local data = StaticData['majesty_heads'][id]
    if not data then
        return
    end
    self._imgHeadIcon:loadTexture("img/common/player_head/" .. data.icon)
end

return CropRedbagReceive