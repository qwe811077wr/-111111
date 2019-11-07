local LegionCampaignBoss = class("LegionCampaignBoss", require('app.modules.common.BaseViewWithHead'))

LegionCampaignBoss.RESOURCE_FILENAME = "crop/LegionCampaignBoss.csb"
LegionCampaignBoss.RESOURCE_BINDING = {
    ["Image_bg"]            = {["varname"] = "_imgBg"},
}

function LegionCampaignBoss:ctor(name, params)
    LegionCampaignBoss.super.ctor(self, name, params)
end

function LegionCampaignBoss:init()
    self:centerView()

    self:addShowCoinGroup({uq.config.constant.COST_RES_TYPE.GESTE, uq.config.constant.COST_RES_TYPE.MONEY, uq.config.constant.COST_RES_TYPE.GOLDEN})

    self:createLegionCampaign()
    self:parseView()
end

function LegionCampaignBoss:createLegionCampaign()
    self._legionCampaignInfo = uq.createPanelOnly("crop.LegionCampaignBossInfo")
    self._view:addChild(self._legionCampaignInfo)
end


function LegionCampaignBoss:dispose()
    self._legionCampaignInfo:dispose()
    LegionCampaignBoss.super.dispose(self)
end

function LegionCampaignBoss:setData(data, index)
    self._legionCampaignInfo:setData(data, index)
    self._imgBg:loadTexture("img/bosom/bg/" .. data.battleBg)
end

return LegionCampaignBoss