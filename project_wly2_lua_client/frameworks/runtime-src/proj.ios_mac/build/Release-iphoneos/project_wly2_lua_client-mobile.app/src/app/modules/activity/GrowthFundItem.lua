local GrowthFundItem = class("GrowthFundItem", require("app.base.ChildViewBase"))
local EquipItem = require("app.modules.common.EquipItem")

GrowthFundItem.RESOURCE_FILENAME = "activity/GrowthFundItem.csb"
GrowthFundItem.RESOURCE_BINDING = {
    ["Node_1"]                  = {["varname"] = "_nodeBase"},
    ["img_state_bg"]            = {["varname"] = "_imgState"},
    ["txt_state"]               = {["varname"] = "_txtState"},
    ["Image_5"]                 = {["varname"] = "_selectedBg"},
    ["Panel_1"]                 = {["varname"] = "_panelReward"},
    ["img_state"]               = {["varname"] = "_imgStateBg"},
}

function GrowthFundItem:ctor(params)
    GrowthFundItem.super.ctor(self)
    self._info = params.info
    self:initData()
end

function GrowthFundItem:initData()
    if not self._info then
        return
    end
    self._panelReward:removeAllChildren()
    self._txtState:setString(string.format(StaticData['local_text']['growth.item.level'], self._info.level))
    local reward_array = uq.RewardType.parseRewards(self._info.reward)
    local index = 1
    for _, item in ipairs(reward_array) do
        local euqip_item = EquipItem:create({info = item:toEquipWidget()})
        euqip_item:setPosition(cc.p(115 * index - 55, 45))
        euqip_item:setTouchEnabled(true)
        euqip_item:addClickEventListenerWithSound(function(sender)
            local info = sender:getEquipInfo()
            uq.showItemTips(info)
        end)
        self._panelReward:addChild(euqip_item)
        index = index + 1
    end
end

function GrowthFundItem:setInfo(info)
    self._info = info
    self:initData()
end

function GrowthFundItem:setSelectImgVisible(flag)
    self._selectedBg:setVisible(flag)
    if flag then
        self._imgState:loadTexture("img/activity/g03_0000727.png")
    else
        self._imgState:loadTexture("img/activity/g03_0000726.png")
    end
end

function GrowthFundItem:dispose()
    GrowthFundItem.super.dispose(self)
end

function GrowthFundItem:setIndex(index)
    self._index = index
end

function GrowthFundItem:getIndex()
    return self._index
end

function GrowthFundItem:showAction()
    uq.intoAction(self._nodeBase)
end

return GrowthFundItem