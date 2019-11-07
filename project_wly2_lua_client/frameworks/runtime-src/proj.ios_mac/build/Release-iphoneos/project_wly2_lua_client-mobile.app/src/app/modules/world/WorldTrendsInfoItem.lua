local WorldTrendsInfoItem = class("WorldTrendsInfoItem", require('app.base.ChildViewBase'))
local EquipItem = require("app.modules.common.EquipItem")

WorldTrendsInfoItem.RESOURCE_FILENAME = "world/WorldTrendsInfoItem.csb"
WorldTrendsInfoItem.RESOURCE_BINDING = {
    ["Image_1"]             = {["varname"] = "_rankImg"},
    ["crop_name"]           = {["varname"] = "_nameLabel"},
    ["city_rank"]           = {["varname"] = "_rankLabel"},
    ["crop_des"]            = {["varname"] = "_desLabel"},
    ["country"]             = {["varname"] = "_countryImg"},
    ["txt_name1"]           = {["varname"] = "_countryName"},
    ["Image_2"]             = {["varname"] = "_rankBgImg"},
    ["Panel_item"]          = {["varname"] = "_panelItem"},
}

WorldTrendsInfoItem._RANK_BG_PATH = {
    "img/common/ui/xsj03_0191.png",
    "img/common/ui/xsj03_0192.png",
    "img/common/ui/xsj03_0190.png",
}

WorldTrendsInfoItem._RANK_PATH = {
    "img/common/ui/xsj03_0196.png",
    "img/common/ui/xsj03_0197.png",
    "img/common/ui/xsj03_0198.png",
}

function WorldTrendsInfoItem:onCreate()
    WorldTrendsInfoItem.super.onCreate(self)
end

function WorldTrendsInfoItem:setData(data)
    self._info = data
    if not self._info then
        return
    end
    local crop_data = uq.cache.crop:getCropDataById(self._info.id)
    self._countryImg:setVisible(false)
    self._countryName:setVisible(false)
    if next(crop_data) ~= nil then
        local flag_info = StaticData['world_flag'][crop_data.color_id]
        if flag_info then
            self._countryImg:setVisible(true)
            self._countryName:setVisible(true)
            self._countryImg:setTexture("img/create_power/" .. flag_info.color)
            self._countryName:setString(crop_data.power_name)
        end
    end
    self._rankBgImg:setVisible(self._info.rank < 4)
    self._rankImg:setVisible(self._info.rank < 4)
    self._rankLabel:setVisible(self._info.rank > 3)
    self._rankLabel:setString(self._info.rank)
    if self._info.rank < 4 then
        self._rankImg:setTexture(self._RANK_PATH[self._info.rank])
        self._rankBgImg:loadTexture(self._RANK_BG_PATH[self._info.rank])
    end
    self._nameLabel:setString(self._info.name)
    local reward_items = uq.RewardType.parseRewards(self._info.reward)
    local pos_x = 35
    local pos_y = 30
    self._panelItem:removeAllChildren()
    for k, item in ipairs(reward_items) do
        local info = item:toEquipWidget()
        local euqip_item = EquipItem:create({info = info})
        euqip_item:setTouchEnabled(true)
        euqip_item:setScale(0.6)
        euqip_item:addClickEventListener(function(sender)
            local info = sender:getEquipInfo()
            uq.showItemTips(info)
        end)
        euqip_item:setPosition(cc.p(pos_x, pos_y))
        pos_x = pos_x + 70
        self._panelItem:addChild(euqip_item)
    end
    self._desLabel:setString(self._info.value)
end

return WorldTrendsInfoItem