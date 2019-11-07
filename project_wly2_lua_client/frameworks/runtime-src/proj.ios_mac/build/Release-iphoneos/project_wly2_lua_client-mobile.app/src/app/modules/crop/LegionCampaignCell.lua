local LegionCampaignCell = class("LegionCampaignCell", require('app.base.ChildViewBase'))
local EquipItem = require("app.modules.common.EquipItem")

LegionCampaignCell.RESOURCE_FILENAME = "crop/LegionCampaignCell.csb"
LegionCampaignCell.RESOURCE_BINDING = {
    ["Image_battle"]        = {["varname"] = "_imgBattle"},
    ["Image_1"]             = {["varname"] = "_imgBg"},
    ["Text_grade"]          = {["varname"] = "_txtGrade"},
    ["Text_7"]              = {["varname"] = "_txtInfo"},
    ["Panel_1"]             = {["varname"] = "_panelReward"},
    ["Node_1"]              = {["varname"] = "_node"},
    ["Button_start"]        = {["varname"] = "_btnStart", ["events"] = {{["event"] = "touch",["method"] = "onStart"}}},
    ["Button_return"]       = {["varname"] = "_btnReturn", ["events"] = {{["event"] = "touch",["method"] = "onReturn"}}},
}

function LegionCampaignCell:onCreate()
    LegionCampaignCell.super.onCreate(self)
end

function LegionCampaignCell:onStart(event)
    if event.name == "ended" then
        local function confirm()
            local instance = uq.cache.crop._allLegionCampaign
            local open_num = instance.open_num
            local cur_campaign_id = instance.cur_instance_id

            if open_num <= 0 and cur_campaign_id ~= self._campaignData.ident and cur_campaign_id ~= 0 then
                uq.fadeInfo(StaticData["local_text"]["legion.campaign.open.num.not"])
                return
            end

            open_num = open_num - 1
            instance.open_num = open_num

            uq.ModuleManager:getInstance():show(uq.ModuleManager.LEGION_CAMPAIGN_INFO, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
            network:sendPacket(Protocol.C_2_S_CROP_BOSS_OPEN, {instance_id = self._campaignData.ident})
            services:dispatchEvent({name = services.EVENT_NAMES.ON_CUR_LEGION_CAMPAIGN, data = self._campaignData.ident})
        end

        local des = nil
        des = StaticData['local_text']['legion.campaign.open']
        local data = {
            content = des,
            confirm_callback = confirm
        }
        uq.addConfirmBox(data)
    end
end

function LegionCampaignCell:onReturn(event)
    if event.name == "ended" then
        services:dispatchEvent({name = services.EVENT_NAMES.ON_LEGION_CAMPAIGN_BACK, {}})
    end
end

function LegionCampaignCell:setData(data)
    self._campaignData = data
    --战役图片
    self._imgBattle:loadTexture("img/common/battle_name/" .. self._campaignData.showName)
    self._imgBg:loadTexture("img/crop/" .. self._campaignData.showPic)

    --战役文字
    self._txtGrade:setString(self._campaignData.level .. StaticData['local_text']['legion.campaign.grade'])
    self._txtInfo:setString(self._campaignData.introduction)

    --战役奖励
    self._reward = self._campaignData.Reward

    local item_list = uq.RewardType.parseRewards(self._reward)
    for k, item in pairs(item_list) do
        local instance_item = EquipItem:create({info = item:toEquipWidget()})
        self._panelReward:addChild(instance_item)
        instance_item:setPosition(cc.p(-80 + k*150, 120))
    end
end

return LegionCampaignCell