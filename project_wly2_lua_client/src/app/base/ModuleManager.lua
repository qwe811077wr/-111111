local ModuleManager = {
    LOGIN_MODULE                        = 'app.modules.login.LoginModule',
    CREATE_ROLE_MODULE                  = 'app.modules.login.CreateRoleModule',
    SERVER_LIST_MODULE                  = 'app.modules.servers.ServerListModule',
    TIP_MODULE                          = 'app.modules.tips.ToastModule',
    TOAST_ITEM_INFO                     = 'app.modules.tips.ToastItemInfo',
    ATTRIBUTE_TIP_MODULE                = 'app.modules.tips.AttributeTipModule',
    MAIN_CITY_MODULE                    = 'app.modules.main_city.MainCityModule',
    BUILD_LEVEL_UP_MODULE               = 'app.modules.main_city.BuildLevelUpModule',
    BUILDER_LIST_MODULE                 = 'app.modules.main_city.BuilderListModule',
    MAIN_CITY_LEVEL_UP                  = 'app.modules.main_city.MainCityLevelUp',
    NEW_FUNCTION_OPEN                   = 'app.modules.main_city.NewFunctionOpen',
    BUILD_SOLDIER_DARFT_MODULE          = 'app.modules.soldier_draft.SoldierDraft',
    LOADING_MODULE                      = "app.modules.loading.LoadingModule",
    GENERALS_MODULE                     = "app.modules.generals.GeneralsModule",
    EMBATTLE_MODULE                     = "app.modules.embattle.EmbattleView",
    EMBATTLE_SOLDIER_SET_MODULE         = "app.modules.embattle.EmbattleSoldierSet",
    INSTANCE_MODULE                     = "app.modules.instance.InstanceModule",
    NPC_INFO_MODULE                     = "app.modules.instance.NPCInfoModule",
    NPC_WIN_MODULE                      = "app.modules.instance.NPCWinModule",
    NPC_DRILL_WIN_MODULE                = "app.modules.instance.NPCDrillWinModule",
    NPC_DRILL_LOST_MODULE               = "app.modules.instance.NPCDrillLostModule",
    NPC_LOST_MODULE                     = "app.modules.instance.NPCLostModule",
    NPC_GUIDE_MODULE                    = "app.modules.instance.NPCGuideModule",
    NPC_SWEEP_MODULE                    = "app.modules.instance.NpcSweep",
    NPC_LIST                            = "app.modules.instance.NpcList",
    COLLECT_MODULE                      = "app.modules.general_collect.GeneralCollectView",
    EUQIP_REPLACE_MODULE                = "app.modules.generals.EquipReplace",
    INSIGHT_RES_FROM_MODULE             = "app.modules.generals.InsightResFrom",
    INSIGHT_SUCCESS_MODULE              = "app.modules.generals.InsightSuccess",
    GENERALS_EQUIP_BAG_MODULE           = "app.modules.generals.GeneralsEquipBag",
    GENERALS_EQUIP_INFO_MODULE          = "app.modules.generals.GeneralsEquipInfo",
    GENERALS_ARMS_ADVANCE_MODULE        = "app.modules.generals.GeneralsArmsAdvance",
    GENERALS_ARMS_REBUILD_MODULE        = "app.modules.generals.GeneralsArmsRebuild",
    GENERALS_ARMS_STRENGTH_MODULE       = "app.modules.generals.GeneralsArmsStrength",
    GENERALS_QUALITY_UP                 = "app.modules.generals.QualityUp",
    ARMS_ADVANCE_SUCCESS_MODULE         = "app.modules.generals.ArmsAdvanceSuccess",
    ARMS_MODULE                         = "app.modules.generals.ArmsMain",
    ARMS_INFO_MODULE                    = "app.modules.generals.ArmsInfo",
    GENERAL_UNLOCKED_VIEW               = "app.modules.generals.UnlockedSuccessView",
    GENERAL_EQUIP_FILTER_LEVEL          = "app.modules.generals.JadeLevelFilter",
    GENERAL_EQUIP_RESOURCE_MODULE       = "app.modules.generals.EquipResourceModule",
    GENERAL_SKILL_MODULE                = "app.modules.generals.GeneralSkillModule",
    GENERAL_ATTRIBUTE_MODULE            = "app.modules.generals.GeneralAttributeModule",
    EQUIP_ATTRIBUTE_MODULE              = "app.modules.generals.EquipAttributeModule",
    RESOURCE_COLLECT_MODULE             = "app.modules.collect.CollectView",
    FRAM_COLLECT_MODULE                 = "app.modules.farm.FarmCollectView",
    OFFICIAL_MODULE                     = "app.modules.office.OfficeView",
    GENERAL_ONE_KEY_SUDDENFLY           = "app.modules.generals.GeneralLevelUp",
    GENERAL_REIN_STATE                  = "app.modules.generals.ReincarnationAttribute",
    CONFIRM_BOX_MODULE                  = "app.modules.common.ConfirmBoxList",
    POWER_PROMOTE_MODULE                = "app.modules.common.PowerPromoteModule",
    ARMS_STRENGTH_SUCCESS_MODULE        = "app.modules.generals.ArmsStrengthSuccess",
    WAREHOURSE_MODULE                   = "app.modules.ware_house.WareHouseModule",
    WAREHOURSE_LIST                     = "app.modules.ware_house.WareSelectList",
    SINGLE_BATTLE_MODULE                = "app.modules.battle.SingleBattleModule",
    ARRANGED_BEFORE_WAR                 = "app.modules.battle.ArrangedBeforeWar",
    SINGLE_BATTLE_BUFFS_MODULE          = "app.modules.battle.BuffPopList",
    CHAT_MAIN                           = "app.modules.chat.ChatMain",
    CHAT_INFO                           = "app.modules.chat.ChatInfo",
    CHAT_CLEAN                          = "app.modules.chat.ChatClean",
    CHAT_FRIEND                         = "app.modules.chat.FriendList",
    CHAT_EXPRESS                        = "app.modules.chat.ChatExpress",
    CHAT_BUBBLE                         = "app.modules.chat.ChatBubble",
    MAIL_MAIN                           = "app.modules.mail.MailMain",
    MAIL_INFO                           = "app.modules.mail.MailInfo",
    MAIL_WRITE                          = "app.modules.mail.MailWrite",
    ITEM_TIPS_MODULE                    = "app.modules.common.ItemTips",
    TOOL_TIPS_MODULE                    = "app.modules.common.ToolTips",
    AGAIN_CONFIRM                       = "app.modules.common.AgainConfirm",
    BOSOM_MODULE                        = "app.modules.bosom.BosomModule",
    BOSOM_SEARCH_MODULE                 = "app.modules.bosom.BosomSearchModule",
    BOSOM_LIST_MODULE                   = "app.modules.bosom.BosomListModule",
    BOSOM_INFO_MODULE                   = "app.modules.bosom.BosomInfoModule",
    BOSOM_FAMOUS_MODULE                 = "app.modules.bosom.BosomFamousModule",
    BOSOM_NORMAL_TALK_MODULE            = "app.modules.bosom.BosomNormalTalkModule",
    BOSOM_AUTO_TALK_MODULE              = "app.modules.bosom.BosomAutoSearchModule",
    BOSOM_ATTR_MODULE                   = "app.modules.bosom.BosomAttrModule",
    BOSOM_ALL_ATTR_MODULE               = 'app.modules.bosom.BosomAllAttrModule',
    BOSOM_MARRY_MODULE                  = 'app.modules.bosom.BosomMarryModule',
    BOSOM_RULE                          = "app.modules.bosom.BosomRuleModule",
    BOSOM_RULE_ADVANCE_SEARCH           = "app.modules.bosom.BosomRuleAdvanceAutoModule",
    BOSOM_QUALITY_UP                    = "app.modules.bosom.BosomQualityUp",
    STRATEGY_MODULE                     = "app.modules.strategy.StrategyModule",
    STRATEGY_UP_LEVEL                   = "app.modules.strategy.StrategyUpLevel",
    VIP_MODULE                          = "app.modules.vip.VipModule",
    CROP_MAIN                           = "app.modules.crop.CropMain",
    CROP_MY                             = "app.modules.crop.CropMy",
    CROP_CREATE                         = "app.modules.crop.CropCreate",
    CROP_POP                            = "app.modules.crop.CropPop",
    CROP_APPLY_LIST                     = "app.modules.crop.CropApplyList",
    CROP_INFO                           = "app.modules.crop.CropInfo",
    CROP_REDBAG                         = "app.modules.crop.CropRedbag",
    CROP_REDBAG_REWARD                  = "app.modules.crop.CropRedbagReward",
    CROP_REDBAG_RECEIVE                 = "app.modules.crop.CropRedbagReceive",
    CROP_REDBAG_RECEIVE_INFO            = "app.modules.crop.CropRedbagReceiveInfo",
    CROP_TECH                           = "app.modules.crop.CropTech",
    CROP_HEAD                           = "app.modules.crop.CropHead",
    LEGION_CAMPAIGN                     = "app.modules.crop.LegionCampaign",
    LEGION_CAMPAIGN_INFO                = "app.modules.crop.LegionCampaignInfo",
    LEGION_CAMPAIGN_BOSS                = "app.modules.crop.LegionCampaignBoss",
    LEGION_CAMPAIGN_BOSS_RANK           = "app.modules.crop.LegionCampaignBossRank",
    REWARD_PREVIEW_MODULE               = "app.modules.common.RewardPreview",
    SHOW_REWARD_MODULE                  = "app.modules.common.ShowReward",
    GENERIC_TIP_EFFECT                  = "app.modules.common.GenericTipEffect",
    GENERAL_COLLECT_HELP                = "app.modules.general_collect.GeneralCollectHelp",
    WORLD_MODULE                        = "app.modules.world.WorldModule",
    CITY_MODULE                         = "app.modules.world.CityView",
    AREA_MODULE                         = "app.modules.area.AreaModule",
    AREA_CITY_INFO                      = "app.modules.area.CityInfo",
    AREA_CITY_FACE                      = "app.modules.area.CityFace",
    AREA_REPLACE_FLAG                   = "app.modules.area.AreaReplaceFlag",
    AREA_FOLLOWER                       = "app.modules.area.AreaFollowerView",
    ANCIENT_CITY_MODULE                 = "app.modules.ancient_city.AncientCityModule",
    GENRAL_SHOP_MODULE                  = "app.modules.ancient_city.GeneralShopModule",
    ANCIENT_CITY_BUY_NUM_MODULE         = "app.modules.ancient_city.AncientCityBuyFightNum",
    ANCIENT_CITY_DAILY_REWARD_MODULE    = "app.modules.ancient_city.AncientCityDailyReward",
    ANCIENT_CITY_BATTLE_MODULE          = "app.modules.ancient_city.AncientCityBattleModule",
    ANCIENT_CITY_CHECK_POINT            = "app.modules.ancient_city.AncientCityCheckPoint",
    ANCIENT_CITY_CLEARANCE_REWARD       = "app.modules.ancient_city.AncientCityClearanceReward",
    ANCIENT_CITY_PLAYER                 = "app.modules.ancient_city.AncientCityPlayer",
    GENERAL_SHOP_REWARD                 = "app.modules.ancient_city.GeneralShopReward",
    ANCIENT_CITY_STRATEGY               = "app.modules.ancient_city.AncientCityStrategy",
    ANCIENT_CITY_SWEEP                  = "app.modules.ancient_city.AncientCitySweep",
    GENERAL_NUM_BUY_ITEM                = "app.modules.ancient_city.GeneralNumBuyItem",
    FIND_SECRET_ROOM                    = "app.modules.ancient_city.FindSecretRoom",
    SHOW_BOX_REWARD                     = "app.modules.ancient_city.ShowBoxReward",
    ANCIENT_CITY_RULE                   = "app.modules.ancient_city.AncientCityRule",
    GENERAL_SHOP_TALK                   = "app.modules.ancient_city.GeneralShopTalk",
    ANCIENT_CITY_TIPS                   = "app.modules.ancient_city.AncientCityTips",
    ANCIENT_CITY_BEFORE                 = "app.modules.ancient_city.AncientCityBefore",
    RETAINER_MAIN                       = "app.modules.retainer.RetainerMain",
    RETAINER_LIKE                       = "app.modules.retainer.RetainerLike",
    RANK_VIEW                           = "app.modules.rank.RankView",
    TAVERN_VIEW                         = "app.modules.tavern.TavernView",
    TAVERN_REWARD                       = "app.modules.tavern.TavernReward",
    TAVERN_REWARD_PREVIEW               = "app.modules.tavern.TavernRewardPreview",
    ARENA_VIEW                          = "app.modules.arena.ArenaView",
    ARENA_HELP                          = "app.modules.arena.ArenaHelp",
    ARENA_RANK                          = "app.modules.arena.ArenaRank",
    ARENA_TOP_FIGHT                     = "app.modules.arena.ArenaTopFight",
    ARENA_INFO                          = "app.modules.arena.ArenaInfo",
    ARENA_REPORT                        = "app.modules.arena.ArenaReport",
    ARENA_DAILY_REWARD                  = "app.modules.arena.ArenaDailyReward",
    ARENA_WIN_MODULE                    = "app.modules.arena.AreanWinModule",
    ARENA_LOST_MODULE                   = "app.modules.arena.ArenaLostModule",
    ROLE_VIEW                           = "app.modules.role.RoleView",
    ROLE_NAME                           = "app.modules.role.RoleName",
    ROLE_HEAD                           = "app.modules.role.RoleHead",
    ROLE_SETTING                        = "app.modules.role.RoleSetting",
    ROLE_CHANGE                         = "app.modules.role.RoleChange",
    ROLE_LEVEL_UP                       = "app.modules.role.RoleLevelUp",
    DAILY_ACTIVITY                      = "app.modules.daily_activity.DailyActivityModule",
    DAILY_INSTANCE                      = "app.modules.daily_instance.DailyInstanceModule",
    DAILY_INSTANCE_VIEW                 = "app.modules.daily_instance.DailyInstanceView",
    TRIALS_TOWER_MODULE                 = "app.modules.trials_tower.TrialsTowerModule",
    TRIALS_TOWER_REWARD                 = "app.modules.trials_tower.TrialslTowerBoxReward",
    TRIALS_TOWER_BATTLE                 = "app.modules.trials_tower.TrialslTowerBattle",
    TRIALS_TOWER_RANK                   = "app.modules.trials_tower.TrialslTowerRankView",
    MAP_GUIDE_SCREEN                    = "app.modules.map_guide.MapGuideScreen",
    MAP_GUIDE_SKILL                     = "app.modules.map_guide.MapGuideSkill",
    MAP_GUIDE_ATTR                      = "app.modules.map_guide.MapGuideAttr",
    MAP_GUIDE_INFO                      = "app.modules.map_guide.MapGuideInfo",
    MAP_GUIDE_LEVEL_UP                  = "app.modules.map_guide.MapGuideLevelUp",
    ACTIVITY_MAIN                       = "app.modules.activity.ActivityMain",
    ACTIVITY_LEVEL                      = "app.modules.activity.ActivityLevel",
    ACTIVITY_SIGN                       = "app.modules.activity.ActivitySign",
    GROWTH_FUND                         = "app.modules.activity.GrowthFundView",
    FLY_NAIL_MODULE                     = "app.modules.fly_nail.FlyNailModule",
    FLY_NAIL_BATTLE                     = "app.modules.fly_nail.FlyNailBattle",
    STRANGE_DOOR                        = "app.modules.fly_nail.StrangeDoor",
    GENERALS_SELECT                     = "app.modules.fly_nail.GeneralsSelect",
    FULL_SCREEN_SKILL_EFFECT            = "app.modules.battle.FullScreenSkillEffect",
    MAIN_TASK                           = "app.modules.achievement.MainTask",
    DAILY_TASK                          = "app.modules.task.DailyTask",
    ACHIEVEMENT_CHAPTER_OPEN            = "app.modules.achievement.AchievementChapterOpen",
    WORLD_TROOP                         = "app.modules.world.WorldTroop",
    WORLD_CITY_WAR                      = "app.modules.world.WorldCityWar",
    TASK_DAY_SEVEN                      = "app.modules.achievement.TaskDaySeven",
    TASK_DAY_SEVEN_HELP                 = "app.modules.achievement.TaskDaySevenHelp",
    WORLD_INFO                          = "app.modules.world.WorldCityInfo",
    BUILD_INFO                          = "app.modules.main_city.BuildInfoView",
    NETWORK_ERROR                       = "app.modules.common.NetworkError",
    PASS_CHECK_MAIN                     = "app.modules.pass_check.PassCheckMain",
    PASS_CHECK_GRADE_BUY_LEVEL          = "app.modules.pass_check.PassCheckBuyLevel",
    PASS_CHECK_LIMIT_STORE              = "app.modules.pass_check.PassCheckLimitStore",
    PASS_UP_LEVEL                       = "app.modules.pass_check.PassUpLevel",
    GENERALS_TIPS_MODULE                = "app.modules.common.GeneralsTips",
    NETWORK_LOADING                     = "app.modules.common.NetworkLoading",
    MAIN_CITY_SEASON                    = "app.modules.main_city.MainCitySeason",
    BUY_MILITORY_ORDER                  = "app.modules.main_city.BuyMilitoryOrder",
    GET_RESOURCE                        = "app.modules.main_city.GetResource",
    BUILD_SPEED_UP                      = "app.modules.main_city.BuildSpeedUp",
    GUIDE_PLOT                          = "app.modules.guide.GuidePlot",
    GUIDE_TIPS                          = "app.modules.guide.GuideTips",
    GUIDE_DEC                           = "app.modules.guide.GuideDec",
    RANDOM_REWARD                       = "app.modules.random_event.RandomReward",
    RANDOM_EGG                          = "app.modules.random_event.RandomEgg",
    RELATION_SHIP                       = "app.modules.random_event.RandomEventRelationShip",
    CREATE_POWER_MODULE                 = "app.modules.create_power.CreatePowerModule",
    CREATE_POWER_INFO                   = "app.modules.create_power.CreatePowerInfo",
    CREATE_POWER_SUCCESS                = "app.modules.create_power.CreatePowerSuccess",
    GOVERNMENT_MODULE                   = "app.modules.government.GovernmentMain",
    GOVERNMENT_INFO                     = "app.modules.government.GovernmentInfo",
    PRIVILEGE_INFO                      = "app.modules.government.PrivilegeInfo",
    GOVERNMENT_APPOINT_LIST             = "app.modules.government.GovernmentAppointList",
    SKILL_POP                           = "app.modules.battle.SkillPop",
    BATTLE_REPORT_INFO                  = "app.modules.world.BattleReportInfo",
    DRILL_MAIN                          = "app.modules.drill.DrillMainModule",
    DRILL_DIFFICULTY                    = "app.modules.drill.DrillDifficulty",
    DRILL_UP_LV                         = "app.modules.drill.DrillUpLv",
    DRILL_OPEN_BOXS                     = "app.modules.drill.DrillOpenBoxs",
    DRILL_CARD                          = "app.modules.drill.DrillCard",
    DRILL_OPEN_LEVEL_UP                 = "app.modules.drill.DrillLevelUp",
    DECREE_MAIN                         = "app.modules.decree.DecreeMain",
    DECREE_ISSUE                        = "app.modules.decree.DecreeIssue",
    WORLD_CITY_DEVELOP                  = "app.modules.world.WorldCityDevelop",
    WORLD_CITY_DEVELOP_UP               = "app.modules.world.WorldCityDevelopUp",
    SKILL_POP_FULL                      = "app.modules.battle.SkillPopFull",
    WORLD_MAP                           = "app.modules.world.WorldMap",
    WORLD_TRENDS_MAIN                   = "app.modules.world.WorldTrendsModule",
    WORLD_TRENDS_INFO                   = "app.modules.world.WorldTrendsInfo",
    WORLD_CITY_RANK                     = "app.modules.world.WorldCityWarRankItem",
    INSTANCE_REWARD_INFO                = "app.modules.instance.InstanceRewardInfo",
    BATTLE_REPORT_SHARE                 = "app.modules.instance.BattleReportShare",
    CROP_HELP                           = "app.modules.crop.CropHelp",
    CROP_HELP_LIST                      = "app.modules.crop.CropHelpList",
    BUILD_OFFICER_MAIN                  = "app.modules.build_officer.BuildOfficerMain",
    BUILD_OFFICER_SELECT                = "app.modules.build_officer.BuildOfficerSelect",
    BUILD_OFFICER_SORT                  = "app.modules.build_officer.BuildOfficerSort",
    BUILD_OFFICER_GIFT                  = "app.modules.build_officer.BuildOfficerGift",
    BUILD_OFFICER_TIP                   = "app.modules.build_officer.BuildOfficerTip",
    RECRUIT_FIGT                        = "app.modules.recruit.RecruitGift",
    RECRUIT_SUCCESS                     = "app.modules.recruit.RecruitSuccess",
    RECRUIT_MAIN                        = "app.modules.recruit.RecruitMain",
    GENERAL_INTERNAL                    = "app.modules.generals.GeneralsInternal",
    DRAFT_SELECT                        = "app.modules.soldier_draft.DraftSelect",
    COLLECT_EVENT_MODULE                = "app.modules.collect.CollectEventView",
    GM_VIEW                             = "app.modules.gm.GMView",
    RANK_INFO                           = "app.modules.rank.RankInfo",
    CROP_DETAIL                         = "app.modules.crop.CropDetail",
    CROP_SIGN                           = "app.modules.crop_sign.CropSign",
    CROP_SIGN_GET_REWARD                = "app.modules.crop_sign.CropSignGetReward",
    CROP_SIGN_BATTLE_REPORT             = "app.modules.crop_sign.CropSignBattleReport",
    WORLD_BATTLE_WIN                    = "app.modules.world.WorldBattleWin",
    WORLD_BATTLE_LOST                   = "app.modules.world.WorldBattleLost",
    WORLD_WAR_OPEN                      = "app.modules.world.WorldWarOpen",
    DECOMPOSE                           = "app.modules.decompose.DecomposeMain",
    DECOMPOSE_NUM                       = "app.modules.decompose.DecomposeNum",
    EQUIP_POOL_MODULE                   = "app.modules.equip.EquipPoolModule",
    EQUIP_BOUGHT_VOUCHERS               = "app.modules.equip.VouchersBougthModule",
    EQUIP_BOUGHT_TIPS                   = "app.modules.equip.EquipBoughtTips",
    EQUIP_EXTRACT_RESULT                = "app.modules.equip.ExtractResult",
    EQUIP_HANDBOOK_MODULE               = "app.modules.equip.EquipHandbook",
    EQUIP_POOL_PREVIEW_MODULE           = "app.modules.equip.EquipPoolPreViewModule",
    CITY_STATE_MODULE                   = "app.modules.world.CityStatePopList",
    EQUIP_SUIT_INFO                     = "app.modules.equip.EquipSuitInfo",
    EQUIP_RISING_MODULE                 = "app.modules.equip.EquipRisingSuccess",
    INSTANCE_WAR_CHAPTER_SELECT         = "app.modules.instance_war.InstanceWarChapterSelect",
    INSTANCE_WAR_MAIN                   = "app.modules.instance_war.InstanceWarMain",
    INSTANCE_WAR_EXPLORE_INFO           = "app.modules.instance_war.InstanceWarExploreInfo",
    INSTANCE_WAR_EXPLORE_RESULT         = "app.modules.instance_war.InstanceWarExploreResult",
    INSTANCE_WAR_MOVE                   = "app.modules.instance_war.InstanceWarCityMove",
    INSTANCE_WAR_ROUND                  = "app.modules.instance_war.InstanceWarRound",
    INSTANCE_WAR_DRAFT                  = "app.modules.instance_war.InstanceWarDraft",
    INSTANCE_WAR_WIN                    = "app.modules.instance_war.InstanceWarPowerWin",
    INSTANCE_WAR_LOSE                   = "app.modules.instance_war.InstanceWarPowerLose",
    INSTANCE_WAR_FAIL                   = "app.modules.instance_war.InstanceWarPowerFail",
    INSTANCE_WAR_INVESTIGATE            = "app.modules.instance_war.InstanceWarInvestigate",
    INSTANCE_WAR_ENEMY_DESC             = "app.modules.instance_war.InstanceWarEnemyDesc",
    INSTANCE_WAR_ENEMY_TIP              = "app.modules.instance_war.InstanceWarEnemyTip",
    INSTANCE_WAR_BATTLE                 = "app.modules.instance_war.InstanceWarBattle",
    INSTANCE_WAR_SWEEP                  = "app.modules.instance_war.InstanceWarSweep",
    INSTANCE_WAR_BATTLE_LIST            = "app.modules.instance_war.InstanceWarBattleList",

    GENERAL_POOL_MODULE                 = "app.modules.generals.GeneralPoolModule",
    GENERAL_POOL_PREVIEW_MODULE         = "app.modules.generals.GeneralPoolPreViewModule",
    GENERAL_POOL_EXTRACT_RESULT         = "app.modules.generals.GeneralExtractResult",
    GENERAL_POOL_OPEN                   = "app.modules.generals.GeneralPoolOpen",
    _modules = {},
}

ModuleManager.SHOW_TYPE_REPLACE_ALL = 1
ModuleManager.SHOW_TYPE_REPLACE = 2
ModuleManager.SHOW_TYPE_PUSH = 3
ModuleManager.SHOW_TYPE_UPDATE = 4
ModuleManager.SPECIAL_ZORDER = {
    MODULE_BASE_BG = -1000,
    CONFIRM_BOX_ZORDER = 2000,
    MSG_ZORDER   = 3000,
    TIP_ZORDER   = 4000,
    CLICK_ZORDER = 5000
}

function ModuleManager:init()
    self._popupNum = 0
    self._effectSwitch = true
    self._basePath = "app.modules"
    self._isChildBase = false

    local layer = cc.LayerColor:create(cc.c3b(10, 12, 10), display.width * 10, display.height * 10)
    layer:setAnchorPoint(cc.p(0, 0))
    layer:setPosition(cc.p(-display.width * 5, -display.height * 5))
    self._layer = layer
    self._layer:setLocalZOrder(self.SPECIAL_ZORDER.CLICK_ZORDER - 1)
    self._layer:setOpacity(0)

    self._scene = display.newScene()
    self._scene:addChild(self._layer)
    display.runScene(self._scene)
    self:initFullScreenEffect()
end

function ModuleManager:initFullScreenEffect()
    self._listener = cc.EventListenerTouchOneByOne:create()
    self._listener:registerScriptHandler(handler(self, self._onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self._listener, -1)
end

function ModuleManager:setClickSwitchState(state)
    self._effectSwitch = state
end

function ModuleManager:_onTouchBegin(event)
    if not self._effectSwitch then
        return true
    end
    local pos = event:getLocation()
    uq:addEffectByNode(self._scene, 900001, 1, true, pos)
    self._scene.effect:setLocalZOrder(self.SPECIAL_ZORDER.CLICK_ZORDER)
    return true
end

function ModuleManager:getCurScene()
    return self._scene
end

function ModuleManager:getInstance()
    return self
end

function ModuleManager:getModules()
    return self._modules
end

function ModuleManager:darkenToModule(name, params)
    --由于界面卡顿，暂时屏蔽相关功能
    --self._layer:runAction(cc.FadeIn:create(0.08))
    --self._listener:setSwallowTouches(true)
    --self._scene:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()
    self:show(name, params)
        --self._layer:runAction(cc.FadeOut:create(0.2))
        --self._listener:setSwallowTouches(false)
    --end)))
end

function ModuleManager:show(name, params)
    if not self._scene then
        return
    end
    local st = self.SHOW_TYPE_REPLACE
    if params ~= nil and params.moduleType then
        st = params.moduleType
    end
    if st == self.SHOW_TYPE_REPLACE_ALL then
        for i=1, #self._modules do
            local m = self._modules[i]
            m:dispose()
        end
        self._modules = {}
    elseif st == self.SHOW_TYPE_REPLACE then
        self:dispose(name)
        local zOrder = self:getzOrder()
        if params then
            params.zOrder = params.zOrder or zOrder
        else
            params = {zOrder = zOrder}
        end
    elseif st == self.SHOW_TYPE_UPDATE then
        local m = self:getModule(name)
        if m then
            m:update(params)
            return
        end
        self:dispose(name)
    else
        self:dispose(name)
    end
    return self:addModule(name, params)
end

function ModuleManager:addModule(name, params)
    local zOrder = 0
    if params and params.zOrder ~= nil then
        zOrder = params.zOrder
    else
        zOrder = self:getzOrder()
    end
    params.zOrder = zOrder
    local path = self:checkModule(name)
    local m = require(path).new(name, params)
    m:init()
    if m.enableViewEvents then
        m:enableViewEvents()
    end
    local view = m
    if zOrder ~= nil then
        self._scene:addChild(view, zOrder)
    else
        self._scene:addChild(view)
    end
    table.insert(self._modules, m)
    self:refreshTopGuide()
    return m
end

function ModuleManager:getModule(name)
    if name == nil then
        return self._modules[#self._modules]
    else
        for i,v in ipairs(self._modules) do
            if v:name() == name then
                return v
            end
        end
    end
end

function ModuleManager:getzOrder()
    local index = #self._modules
    if index == 0 then
        return 0
    end
    for i = index, 1, -1 do
        if self._modules[i] and self._modules[i]:zOrder() < 1000 then
            return self._modules[i]:zOrder() + 1
        end
    end
end

function ModuleManager:checkModule(name)
    if string.find(name, "app.") then
        return name
    end
    return self._basePath .. "." .. name
end

function ModuleManager:dispose(name, ...)
    if name == nil then
        if #self._modules == 0 then
            return 0
        end
        local i = #self._modules
        local m = self._modules[i]
        local _zOrder = m:zOrder()
        m:dispose()
        table.remove(self._modules, i)
        self._isChildBase = true
        self:refreshTopGuide()
        return _zOrder
    else
        self._isChildBase = false
        for i = 1, #self._modules do
            local m = self._modules[i]
            if m:name() == name then
                local _zOrder = m:zOrder()
                table.remove(self._modules, i)
                self:refreshTopGuide()
                m:dispose()
                return _zOrder
            end
        end
    end
    return #self._modules
end

function ModuleManager:refreshTopGuide()
    local name = self:getTopLayerName()
    if uq.cache.guide and name ~= "" then
        uq.cache.guide:sendGuideEvent(name)
    end
    local panel = uq.ModuleManager:getInstance():getModule(name)
    if panel then
        panel:refreshLayerFromTop()
    end
end

function ModuleManager:isCloseChildBase()
    return self._isChildBase
end

function ModuleManager:getTopLayerName()
    for i = #self._modules, 1, -1 do
        if self._modules[i]:name() ~= "app.modules.guide.GuidePlot" and self._modules[i]:name() ~= "app.modules.guide.GuideTips" then
            return self._modules[i]:name()
        end
    end
    return ""
end

function ModuleManager:debugInfo(info)
    if self._debugView then
        self._debugView:debugInfo(info)
    end
end

function ModuleManager:createDebugView()
    self._debugView = uq.ui.DebugView:create()
    self._scene:addChild(self._debugView)
end

uq.ModuleManager = ModuleManager