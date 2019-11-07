local WorldCityInfoItem = class("WorldCityInfoItem", require('app.base.ChildViewBase'))
local EquipItem = require("app.modules.common.EquipItem")

WorldCityInfoItem.RESOURCE_FILENAME = "world/WorldCityInfoListItem.csb"
WorldCityInfoItem.RESOURCE_BINDING = {
    ["text_name"]         = {["varname"] = "_nameLabel"},
    ["text_num"]          = {["varname"] = "_scoreLabel"},
    ["img_rank"]          = {["varname"] = "_rankImg"},
    ["Text_rank"]         = {["varname"] = "_rankLabel"},
    ["Node_item"]         = {["varname"] = "_nodeItem"},
    ["crop_name"]         = {["varname"] = "_cropName"},
    ["Image_7"]           = {["varname"] = "_headImg"},
}

function WorldCityInfoItem:onCreate()
    WorldCityInfoItem.super.onCreate(self)
end

function WorldCityInfoItem:setData(data)
    self._info = data
    if not self._info then
        return
    end
    local rank_icon = {'xsj03_0196.png', 'xsj03_0197.png', 'xsj03_0198.png'}
    self._nameLabel:setString(self._info.role_name)
    self._cropName:setString(self._info.crop_name)
    self._scoreLabel:setString(self._info.value)
    local res_head = uq.getHeadRes(self._info.img_id, self._info.img_type)
    self._headImg:loadTexture(res_head)
    if self._info.rank == 0 then
        self._rankImg:setVisible(false)
        self._rankLabel:setString(StaticData["local_text"]["world.rank.des"])
    elseif self._info.rank > 3 then
        self._rankImg:setVisible(false)
        self._rankLabel:setString(self._info.rank)
    else
        self._rankImg:setVisible(true)
        self._rankImg:setTexture('img/common/ui/' .. rank_icon[self._info.rank])
        self._rankLabel:setString("")
    end
    self._nodeItem:removeAllChildren()
    local city_info = StaticData['world_city'][self._info.country_id]
    local reward = StaticData['world_type'][city_info.type].Reward
    local str_reward = ""
    for k, v in ipairs(reward) do
        if v.type == self._info.data_type and v.rank == self._info.rank then
            str_reward = v.rankReward
            break
        end
    end
    if str_reward == "" then
        return
    end
    local cost_array = uq.RewardType.parseRewards(str_reward)
    local pos_x = 0
    if #cost_array % 2 == 0 then
        pos_x = -60 - math.floor((#cost_array - 1) / 2) * 120
    else
        pos_x = -math.floor(#cost_array / 2) * 120
    end
    for k, t in ipairs(cost_array) do
        local euqip_item = EquipItem:create({info = t:toEquipWidget()})
        euqip_item:setTouchEnabled(true)
        euqip_item:setScale(0.8)
        euqip_item:addClickEventListener(function(sender)
            local info = sender:getEquipInfo()
            uq.showItemTips(info)
        end)
        euqip_item:setPosition(cc.p(pos_x, 0))
        pos_x = pos_x + 120
        self._nodeItem:addChild(euqip_item)
    end
end

return WorldCityInfoItem