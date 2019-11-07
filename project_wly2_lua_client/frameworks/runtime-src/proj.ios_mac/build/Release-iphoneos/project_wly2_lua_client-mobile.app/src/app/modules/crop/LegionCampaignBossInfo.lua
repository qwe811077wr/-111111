local LegionCampaignBossInfo = class("LegionCampaignBossInfo", require('app.base.ChildViewBase'))
local EquipItem = require("app.modules.common.EquipItem")

LegionCampaignBossInfo.RESOURCE_FILENAME = 'crop/LegionCampaignBossInfo.csb'
LegionCampaignBossInfo.RESOURCE_BINDING = {
    ["LoadingBar_1"]      = {["varname"] = "_prgHp"},
    ["talk_txt"]          = {["varname"] = "_txtTalk"},
    ["drop_item_list"]    = {["varname"] = "_panelList"},
    ["half_body_icon"]    = {["varname"] = "_spriteBodyIcon"},
    ["sprite_name"]       = {["varname"] = "_spriteName"},
    ["g04_000072_11"]     = {["varname"] = "_spriteArmName"},
    ["left_num_txt"]      = {["varname"] = "_txtLeftNum"},
    ["atk_btn"]           = {["varname"] = "_btnAtk", ["events"] = {{["event"] = "touch",["method"] = "onAttack"}}},
    ["guide_btn"]         = {["varname"] = "_btnRank", ["events"] = {{["event"] = "touch",["method"] = "onRank"}}},
}

function LegionCampaignBossInfo:onCreate()
    LegionCampaignBossInfo.super.onCreate(self)

    self:setPosition(667,375)

    self._eventTag1 = services.EVENT_NAMES.ON_REFRESH_HP_BAR .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_REFRESH_HP_BAR, handler(self, self._onAttackReport), self._eventTag1)

    self._eventTag2 = services.EVENT_NAMES.ON_SHOW_REWARD .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_SHOW_REWARD, handler(self, self._onShowReward), self._eventTag2)
end

function LegionCampaignBossInfo:dispose()
    services:removeEventListenersByTag(self._eventTag1)
    services:removeEventListenersByTag(self._eventTag2)
end

function LegionCampaignBossInfo:onAttack(event)
    if event.name ~= "ended" then
        return
    end

    if self._battleNum >= 3 then
        uq.fadeInfo(StaticData['local_text']['crop.redbag.send.num.not'])
        return
    end

    if self:isDeath() then
        uq.fadeInfo(StaticData['local_text']['legion.campaign.boss.killed'])
        return
    end
    network:sendPacket(Protocol.C_2_S_CROP_BOSS_FIGHT, {boss_id = self._bossId})
end

function LegionCampaignBossInfo:isDeath()
    for k, item in pairs(self._campaign.boss_ids) do
        if item == self._bossId then
            return true
        end
    end

    return false
end

function LegionCampaignBossInfo:onRank(event)
    if event.name ~= "ended" then
        return
    end

    network:sendPacket(Protocol.C_2_S_CROP_BOSS_RANK, {boss_id = self._bossId})

    uq.ModuleManager:getInstance():show(uq.ModuleManager.LEGION_CAMPAIGN_BOSS_RANK, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
end

function LegionCampaignBossInfo:setData(data, index)
    self._bossId = index
    --图片
    self._spriteBodyIcon:setTexture("img/common/general_body/" .. data.bossImage)
    self._spriteName:setTexture("img/common/general_name/" .. data.showname)
    self._spriteArmName:setTexture("img/instance_name/" .. data.showImage)
    --文字
    self._txtTalk:setString(data.conversation)
    self._battleNum = uq.cache.crop._allLegionCampaign.battle_num
    self._txtLeftNum:setString(self._battleNum .. string.format(StaticData['local_text']['crop.campaign.boss.num'], 3))
    --奖励
    self._reward = data.killReward
    self._damageReward = data.damageReward

    local item_list = uq.RewardType.parseRewards(self._reward)
    for k, item in pairs(item_list) do
        local boss_item = EquipItem:create({info = item:toEquipWidget()})
        self._panelList:addChild(boss_item)
    end

    self:initHpBar()
end

function LegionCampaignBossInfo:initHpBar()
    self._campaign = uq.cache.crop._allLegionCampaign
    local cur_boss_id = self._campaign.cur_boss_id
    local boss_ids = self._campaign.boss_ids
    local cur_hp = self._campaign.cur_hp
    self._maxHp = self._campaign.max_hp

    if self._maxHp == 0 then
        self._maxHp = uq.cache.crop._openInstance.max_hp
        self._campaign.max_hp = self._maxHp
    end

    --正在击杀
    if cur_boss_id == self._bossId then
        self._prgHp:setPercent(cur_hp * 100 / self._maxHp)
        return
    end

    --已击杀
    for k,v in pairs(boss_ids) do
        if v == self._bossId then
            self._prgHp:setPercent(0)
            return
        end
    end

    --待击杀
    self._prgHp:setPercent(100)
end

function LegionCampaignBossInfo:_onRefreshHpBar(left_hp)
    self._prgHp:setPercent(left_hp * 100 / self._maxHp)

    self._campaign.cur_hp = left_hp

    if left_hp <= 0 then
        table.insert(self._campaign.boss_ids, self._bossId)

        self._campaign.cur_hp = self._campaign.max_hp

        if self._campaign.cur_boss_id < 6 then
            self._campaign.cur_boss_id = self._campaign.cur_boss_id + 1
        else
            self._campaign.cur_boss_id = 7
        end
    end

    services:dispatchEvent({name = services.EVENT_NAMES.ON_REFRESH_BOSS_STATE})
end

function LegionCampaignBossInfo:_onAttackReport(msg)
    local tab = {}
    local tab_reward = uq.RewardType.parseRewards(self._damageReward)
    for i, v in ipairs(tab_reward) do
        local tab_reward = v:toEquipWidget()
        tab_reward.paraml = tab_reward.id
        table.insert(tab, tab_reward)
    end
    uq.BattleReport:getInstance():showBattleReport(msg.data.report_id, handler(self, self.onPlayReportEnd), tab)

    self:_onRefreshHpBar(msg.data.left_hp)
    self._battleNum = uq.cache.crop._allLegionCampaign.battle_num
    self._txtLeftNum:setString(self._battleNum .. string.format(StaticData['local_text']['crop.campaign.boss.num'], 3))
end

function LegionCampaignBossInfo:onPlayReportEnd(report)
    if not report then
        return
    end
    uq.BattleReport:getInstance():showBattleResult(report)
end

function LegionCampaignBossInfo:_onShowReward()
    if self._reportRewards then
        uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE,{rewards = self._damageReward})
    end
end

return LegionCampaignBossInfo