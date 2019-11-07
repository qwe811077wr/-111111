local LegionCampaignInfoCell = class("LegionCampaignInfoCell", require('app.base.ChildViewBase'))
local EquipItem = require("app.modules.common.EquipItem")

LegionCampaignInfoCell.RESOURCE_FILENAME = "crop/LegionCampaignInfoCell.csb"
LegionCampaignInfoCell.RESOURCE_BINDING = {
    ["Image_6"]      = {["varname"] = "_imgBoss"},
    ["Text_1"]       = {["varname"] = "_txtPassNum"},
    ["Panel_1"]      = {["varname"] = "_panelReward"},
    ["Image_icon"]   = {["varname"] = "_imgKilled"},
    ["Image_15"]     = {["varname"] = "_imgHitAndKill"},
    ["Image_16"]     = {["varname"] = "_imgNoKill"},
}

function LegionCampaignInfoCell:onCreate()
    LegionCampaignInfoCell.super.onCreate(self)

    self._curBossState = uq.config.constant.TYPE_CROP_LEGION_BOSS_STATE.NOT_KILL
end

function LegionCampaignInfoCell:onExit()
    LegionCampaignInfoCell.super:onExit()
end

function LegionCampaignInfoCell:setData(data, index)
    self._imgBoss:loadTexture("img/crop/" .. data.showImage)
    self._txtPassNum:setString(StaticData['local_text']['legion.campaign.order'] .. self:getPassNum(index) .. StaticData['local_text']['legion.campaign.shut'])

    self._reward = data.showReward

    local item_list = uq.RewardType.parseRewards(self._reward)
    for k, item in pairs(item_list) do
        local show_item = EquipItem:create({info = item:toEquipWidget()})
        self._panelReward:addChild(show_item)
        show_item:setScale(0.6)
        show_item:setPosition(30 + 80 * (k - 1), 35)
    end
end

function LegionCampaignInfoCell:showState(data, index)
    self._imgKilled:setVisible(false)
    self._imgHitAndKill:setVisible(false)
    self._imgNoKill:setVisible(true)
    self._curBossState = uq.config.constant.TYPE_CROP_LEGION_BOSS_STATE.NOT_KILL

    if data.cur_boss_id == 0 then
        data.cur_boss_id = 1
    end

    --正在击杀
    if index == data.cur_boss_id then
        self._imgHitAndKill:setVisible(true)
        self._imgNoKill:setVisible(false)
        self._curBossState = uq.config.constant.TYPE_CROP_LEGION_BOSS_STATE.KILLING
        return
    end

    --全部击杀
    if 6 < data.cur_boss_id then
        self._imgKilled:setVisible(true)
        self._imgNoKill:setVisible(false)
        self._curBossState = uq.config.constant.TYPE_CROP_LEGION_BOSS_STATE.KILLED
        return
    end

    --部分击杀
    for k, item in pairs(data.boss_ids) do
        if item == index then
            self._imgKilled:setVisible(true)
            self._imgNoKill:setVisible(false)
            self._curBossState = uq.config.constant.TYPE_CROP_LEGION_BOSS_STATE.KILLED
            break
        end
    end
end

function LegionCampaignInfoCell:getPassNum(index)
    if index == 1 then
        return StaticData["local_text"]["legion.campaign.grade.one"]
    elseif index == 2 then
        return StaticData["local_text"]["legion.campaign.grade.two"]
    elseif index == 3 then
        return StaticData["local_text"]["legion.campaign.grade.three"]
    elseif index == 4 then
        return StaticData["local_text"]["legion.campaign.grade.four"]
    elseif index == 5 then
        return StaticData["local_text"]["legion.campaign.grade.five"]
    elseif index == 6 then
        return StaticData["local_text"]["legion.campaign.grade.six"]
    end
end

return LegionCampaignInfoCell