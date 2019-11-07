local LegionCampaignBossRank = class("LegionCampaignBossRank", require('app.base.PopupBase'))

LegionCampaignBossRank.RESOURCE_FILENAME = "crop/LegionCampaignBossRank.csb"
LegionCampaignBossRank.RESOURCE_BINDING = {
     ["g04_00009_2"]   = {["varname"] = "_imgRank"},
     ["back_btn"]      = {["varname"] = "_btnBack"},
     ["Node_1"]        = {["varname"] = "_nodeRank"}
}

function LegionCampaignBossRank:ctor(name, params)
    LegionCampaignBossRank.super.ctor(self, name, params)
end

function LegionCampaignBossRank:onCreate()
    LegionCampaignBossRank.super.onCreate(self)

    self._eventTag = services.EVENT_NAMES.ON_REFRESH_RANK_DATA .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_REFRESH_RANK_DATA, handler(self, self._onRefreshRankData), self._eventTag)
end

function LegionCampaignBossRank:dispose()
    services:removeEventListenersByTag(self._eventTag)
    LegionCampaignBossRank.super.dispose(self)
end

function LegionCampaignBossRank:init()
    self:parseView()
    self:centerView()

    self._imgRank:setPositionY(100)

    self._btnBack:addClickEventListenerWithSound(function()
        self:disposeSelf()
        end)

    for i = 880, 889 do
        local node = self._nodeRank:getChildByTag(i)
        node:getChildByName("Text_1_0"):setVisible(false)
        node:getChildByName("Text_2_0"):setVisible(false)
    end
end

function LegionCampaignBossRank:_onRefreshRankData(msg)
    --未有玩家攻打，排行榜暂无
    local data = msg.data
    if not data then
        return
    end

    for k, item in pairs(data.items) do
        local node = self._nodeRank:getChildByTag(880 + k - 1)
        local name = node:getChildByName("Text_1_0")
        name:setVisible(true)
        name:setString(item.name)

        local hurt = node:getChildByName("Text_2_0")
        hurt:setVisible(true)
        hurt:setString(item.hurt_hp)
    end
end

return LegionCampaignBossRank