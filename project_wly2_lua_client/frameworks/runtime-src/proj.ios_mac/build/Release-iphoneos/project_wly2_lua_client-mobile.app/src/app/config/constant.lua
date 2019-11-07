local constant = {
    TIME_TYPE = {
        HHMMSS = 1,
        MMSS = 2
    },

    COUNTRY = {
        NEUTRAL = 0,
        WEI = 1,
        SHU = 2,
        WU = 3,
        QUN = 4
    },
    CONFIRM_TYPE = {
        NULL                  = -1,                --不带选择框
        EQUIP_INJECTION       = 1,                --注入
        EQUIP_SELL            = 2,                --装备售卖
        WARE_HOUSE_CELL_ADD   = 3,                --开启仓库格子提示
        ANCIENT_CITY_SWEEP    = 4,                --古城探秘扫荡提示
        TRIALS_TOWER_INSPIRE  = 5,                --试炼塔鼓舞
        BOSOM_TALK            = 6,                --知己谈话
        BUILD_SPEED_UP        = 7,                --建筑加速
        BUILD_LEVEL_UP_CANCLE = 8,                --取消建筑升级
        SHOP_REFRESH          = 9,                --商店刷新
        PASS_CHECK_REFRESH    = 10,               --通行证任务刷新
        BUILD_OFFICER         = 11,               --建设官
        DRAFT_SOLDIER         = 12,               --兵营征兵
        CONFIRM_DRAFT         = 13,               --出战确认
    },

    EQUIPITEM_TYPE = {--区分显示equipitem时的类型
        NULL       = -2,       --空，只显示背景
        TYPES_ITEM = -1,       --装备阴影，在types表item内
    },

    ITEM_TYPE = {
        TYPE_WEAPON     = 1,        --武器
        TYPE_ARMOR      = 2,        --防具
        TYPE_MOUNTS     = 3,        --坐骑
        TYPE_BOOK       = 4,        --兵书
        TYPE_CLOAK      = 5,        --披风
        TYPE_SHIELD     = 6,        --盾牌
        TYPE_TREASURE   = 7,        --宝物
        TYPE_BOX        = 101,      --宝箱
        TYPE_STONE      = 102,      --合成石头
    },

    MATERIAL_TYPE = { --对应materials表
        PURPLE_DRAGON_JADE      = 1,--紫色龙玉
        ORANGE_DRAGON_JADE      = 2,--橙色龙玉
        REFRESH_ORDER           = 3,--刷新令
        SPEED_UP                = 4,--升级加速
        EPIPHANY_STONE          = 8,--顿悟石
        SOUL                    = 10, --将魂
        EQUIP_VOURCHER          = 11,-- 装备抽卡券
        MOIRE                   = 3161,    -- 云纹
    },

    --将type的cost内消耗的资源加一个表示
    COST_RES_TYPE = {
        GESTE                   = 1,--战功
        PEOPLE_HEART            = 2,--民心
        TECH_POINT              = 3,--科技点
        REDIF                   = 4,--征收预备兵
        FOOD                    = 5,--粮食
        IRON_MINE               = 6,--铁矿
        SOUL                    = 7,--将魂
        -- TRIAL_ORDER             = 8,--试炼令
        MILITORY_ORDER          = 9,--军令
        ACHIEVEMENTS            = 10,--政绩
        MILITARY_HOON           = 11,--军勋
        RT_DECREE               = 12,--官印
        -- REWARD_ORDER            = 12,--犒赏令
        -- CONTRIBUTION            = 13,--功绩
        -- ARMY_FOOD               = 14,--军粮
        -- GENERAL_LEADER          = 15,--武将统帅
        -- GENERAL_FORCE           = 16,--武将武力
        -- GENERAL_INTELLIGENCE    = 17,--武将智力
        -- GENERAL_SOLDIER_NUM     = 18,--武将兵力
        -- SILVER_INTERSECTING     = 19,--银贯
        -- SMELT_NUM               = 20,--冶炼次数
        -- TRAVEL_NUM              = 21,--游历次数
        ARENA_SCORE             = 22,--竞技场积分
        PRESTIGE                = 23,--威望
        -- CASH_GIFT               = 24,--礼金
        VIP_EXE                 = 25,--vip经验
        -- INTIMACY                = 26,--亲密度
        -- SOLDIER_NUM             = 27,--兵力
        ANCIENT_CITY_COIN       = 28,--古城币
        TRIALS_TOWER_ORDER      = 29,--试练塔币
        GLORY_BADGE             = 30,--荣耀徽章
        MONEY                   = 101,--银两
        GOLDEN                  = 102,--元宝
        PRESTIGE                = 103,--威望
        VIP_EXP                 = 104,--vip经验
        PASS_EXP                = 105,--通行证经验
        DECREE                  = 107,--官印
        MASTER_EXP              = 108,--主公经验
        -- DRAGON_SOUL             = 106,--青龙之魂
        -- BASALT_SOUL             = 107,--玄武之魂
        -- TIGER_SOUL              = 108,--白虎之魂
        -- FINCH_SOUL              = 109,--朱雀之魂
        -- ROC_SOUL                = 110,--鲲鹏之魂
        -- BUN                     = 111,--包子
        -- MEAT                    = 112,--肉
        -- WINE                    = 113,--酒
        -- PEARL                   = 114,--珍珠
        -- JADE                    = 115,--碧玉杯
        -- CENSER                  = 116,--金香炉
        -- AMBER                   = 117,--琥珀
        -- SAPPHIRE                = 118,--蓝宝石
        -- LANG_YA_LADE            = 119,--琅琊玉
        -- HORN                    = 120,--喇叭
        -- TAPPING                 = 121,--公纹
        -- ANTI_STRIPE             = 122,--防纹
        -- SOLDIER                 = 123,--兵纹
        MATERIAL                = 151,--材料
        EQUIP                   = 152,--装备
        GENERALS                = 153,--武将
        SPIRIT                  = 154,--武将英魂
        ORDER_MATERIAL          = 155,--品阶材料
        CLEAR_MATERIAL          = 156,--洗练材料
        TRANSFORMED_SPIRIT      = 157,--武将转化的碎片
        -- INTENSIVE_CONSUMPTION   = 157,--强化消耗
        -- COPY_CARD               = 158,--精英副本卡牌
        -- SEAFOOD_MATERIAL        = 159,--海鲜盛宴材料
        -- DEITY_STONE             = 161,--神石
    },
    --读取types表内，effect字段用
    TYPES_EFFECT = {
        QUALITY                         = -1,  --品质
        ATTACK                          = 1,
        ATTACK_DEF                      = 2,
        PLAN_ATTACK                     = 3,
        PLAN_DEF                        = 4,
        BATTLE_ATTACK                   = 5,
        BATTLE_DEF                      = 6,
        SOLDIER                         = 7,
        CRIT                            = 8,
        BEAT_BACK                       = 9,
        INJURY                          = 10,
        ATTACK_PERCENT                  = 11,
        ATTACK_DEF_PERCENT              = 12,
        PLAN_ATTACK_PERCENT             = 13,
        PLAN_DEF_PERCENT                = 14,
        BATTLE_ATTACK_PERCENT           = 15,
        BATTLE_DEF_PERCENT              = 16,
        LEGION_MEMBERS                  = 17,
        SOLDIER_RECOVER_PERCENT         = 18,
        COLLECTION_PERCENT              = 19,
        BATTLE_ACHIEVE_PERCENT          = 20,
        WORLD_RES_PRODUCTION_PERCENT    = 21,
        BATTLE_PRESTIGE_PERCENT         = 22,
        TRADE_INCOME_PERCENT            = 23,
        ONE_VS_ONE_HURT                 = 24,
        ONE_VS_ONE_FORCE                = 25,
        ONE_VS_ONE_BLOOD                = 26,
        CAPTAIN                         = 27,
        FORCE                           = 28,
        INTELLIGENCE                    = 29,
        PROMOTION_DEF                   = 30,
        PROMOTION_ATTACK                = 31,
        ACCELERATE_SPEED                = 32,
        CAPTAIN_RATIO                   = 33,
        FORCE_RATIO                     = 34,
        INTELLIGENCE_RATIO              = 35,
        IGNORE_DEF                      = 36,
        MELTING                         = 37,
        RES_PRODUCE                     = 38,
        CONFIDANT                       = 39,
        CHILDREN                        = 40,
        ORDERS_UPPER_LIMIT              = 41,
        BUILDING_TIME                   = 42,
        ALL_ATTACK                      = 43,
        ALL_DEF                         = 44,
        SIEGE_VALUE                     = 48,
    },
    --resource tyoe
    TYPES_RESOURCE = {
        MONEY    = 1,
        GOLD     = 2,
        FOOD     = 3,
        GESTE    = 4,
        PRESTIGE = 5,
        SOLDIER  = 6,
        MILITORY = 7,
    },

    TYPES_RESOURCE_SHOW = {
        MONEY_GOID       = 1,
        MONEY_GOID_GESTE = 2,
        MONEY_GOID_GESTE_MILITORY = 3,
        MONEY_GOID_MILITORY = 4,
        MONEY_GOID_FOOD = 5,
        MONEY_GOID_ARENASCORE = 6
    },
    --对应constant表内数据
    TYPE_CONSTANT = {
        GENERALS_FLIGHT = 1,        --武将突飞花费
        TRAIN_POSITION  = 2,        --训练位价格
        SOLDIER_REBUILD = 3,        --兵种重修
    },
    TYPE_BUILDING = {
        DRILL_GROUND            = 6,            --校场
        SOLDIER                 = 4,            --军营
        STRATEGY_MANSION        = 1,            --策略府
        ARMORY_MANSION          = 9,            --军械府
    },

    TYPE_REINCARNATION = {
        COMMON = 0,
        GOLDENCOINS = 1,
        GESTE = 2,
    },
    TYPE_TAIN_STYPE = {
        COMMON = 0,
        NAVY = 1,
    },
    TYPE_CHAT_CHANNEL = {
        CC_WORLD                = 0,
        CC_COUNTRY              = 1,
        -- CC_BOARD                = 3,
        CC_TEAM                 = 2,
        CC_CONVERSATION         = 4,
        CC_SYSTEM               = 5
    },

    TYPE_CHAT_CONTENT = {
        CCT_CHAT_CONTENT        = 0,   --普通聊天消息
        CCT_CHAT_BATTLE_SHARE   = 1, --分享战报消息
        CCT_CHAT_REDBAG         = 2,   --红包
        CCT_SYS_CONTENT         = 3, --系统消息
        CCT_SPECIAL_SYS_CONTENT = 4, --特殊颜色系统消息
        CCT_TIPS_PRIVATE        = 5, --私聊tips消息
        CCT_TIPS_TEAM           = 6, --战报tips消息
    },

    TYPE_CHAT_COUNTRY_BG = {
        WEI = 1001,
        SHU = 1002,
        WU  = 1003,
    },

    TYPE_CHAT_EXPRESS_STATE = {
        EXPRESS = 0,
        BUCKET  = 1,
    },

    TYPE_CHAT_EXSIT_EXPRESS = {
        NONE = 0,
        EXPRESS = 1,
        BUCKET = 2
    },

    TYPE_CROP_RED_PACKET_SPECOES = {
        ORIDINARY = 0,
        COMMAND = 1
    },

    TYPE_CROP_RED_PACKET_HAS = {
        NONE = 0,
        HAS = 1
    },

    TYPE_CROP_REDBAG_PICK = {
        OK = 0,
        NONE_LEFT = 1,
        INVALID_PASSWD = 2
    },

    TYPE_CROP_LEGION_BOSS_STATE = {
        NOT_KILL = 0,
        KILLING = 1,
        KILLED = 2
    },

    TYPE_MAIL = {
        MAIL_FROM_PC = 1,
        MAIL_FROM_GAME = 2,
        MAIL_FROM_BATTLE = 3,
        MAIL_FROM_REWARD = 4,
        MAIL_FROM_ARMY = 5,
    },

    TYPE_MAIL_CELL_STATE = {
        NEW = 0,
        READ = 1,
        GOT_REWARD = 2
    },

    CONMFRIM_BOX_STYLE = {
        CONFIRM_BTN_ONLY = 1,
    },

    RANK_TYPE = {
        LEVEL = 1,
        FIGHT = 2,
        GESTE = 5,
        CROP  = 6,
    },

    ACTION_TYPE = {
        ANIMATION_NAME_STAND   = 'stand',
        ANIMATION_NAME_IDLE    = 'idle',
        ANIMATION_NAME_DEATH   = 'death',
        ANIMATION_NAME_HIT     = 'hit',
        ANIMATION_NAME_ATTACK  = 'attack',
        ANIMATION_NAME_SKILL   = 'skill',
        ANIMATION_NAME_DEFAULT = 'action',
        ANIMATION_NAME_DEATH_M = 'death_m',
        ANIMATION_NAME_REPEL   = 'repel',
        ANIMATION_NAME_READY   = 'ready',
        ANIMATION_NAME_MOVE    = 'move',
        ANIMATION_NAME_MOVE_E  = 'move_5',
        ANIMATION_NAME_MOVE_N  = 'move_2',
        ANIMATION_NAME_MOVE_NE = 'move_3',
        ANIMATION_NAME_MOVE_NW = 'move_1',
        ANIMATION_NAME_MOVE_S  = 'move_7',
        ANIMATION_NAME_MOVE_SE = 'move_8',
        ANIMATION_NAME_MOVE_SW = 'move_6',
        ANIMATION_NAME_MOVE_W  = 'move_4',
        ANIMATION_NAME_RETREAT = 'retreat',
    },

    BATTLE_TYPE = {
        NORMAL = 1,
        ARENA = 2,
    },

    BATTLE_SIDE_TYPE = {
        BATTLE_ATK = 0,
        BATTLE_DEF = 1,
    },

    BOSOM_TYPE = {
        BEAUTY = 0,
        BOSOM = 1,
        WIFE = 2,
    },

    RETAINER_TYPE = {
        TASK = 1,           --宗属任务
        NEXUS = 2,          --成为宗属关系
        KEEP_HOUSE = 3,     --自立门户
        REVENGE = 4,        --复仇
        REVENGE_FINISH = 5, --完成复仇
        INTIMACY = 6,       --亲密度提升
    },

    RETAINER_LIST = {
        SUZERAIN_ADD = 0,
        COURTIER_ADD = 1,
        SUZERAIN_APPLY = 2,
        COURTIER_APPLY = 3,
    },

    TYPE_ACHIEVEMENT_STATE = {
        INIT = 0,           --未完成
        FINISHED = 1,       --领取奖励
        REWARD = 2          --已完成
     },

    TYPE_PASS_CARD_TASK_STATE = {
        ST_INIT = 0,        --未接取
        ST_ACCEPT = 1,      --已接取未完成
        ST_FINISHED = 2,    --已接取已完成未提交
        ST_DRAWD = 3,       --已接取已提交
        ST_ABANDON = 4,     --已放弃
    },

    TYPE_ACHIEVEMENT_CHAPTER = {
        MAIN = 1,
        BRANCH = 2,
        DAILY = 3
    },

    TYPE_ACHIEVEMENT_CHAPTER_FINISHED = {
        NONE = 0,
        FINISHED = 1
    },
    TYPE_ACHIEVEMENT_REWARD = {
        BOX = 0,
        TASK = 1
    },
    MODULE_ID = {
        LEVEL_UP           = 0,
        RESOURCE_COLLECT   = 1,
        NATIONAL_POLICY    = 2,
        BUILD_OFFICER      = 3,
        ROLE               = 9,
        SERVER_LIST        = 11,
        INSTANCE           = 21,
        ACHIEVEMENT        = 41,
        DAILY_TASK         = 42,
        ADD_GOLDEN         = 46,
        MAIL_MAIN          = 51,
        RANK               = 61,
        WAREHOURSE_MODULE  = 71,
        DECOMPOSE          = 75,
        EMABTTLE           = 81,
        MAIN_CITY          = 100,
        GENERAL_ATTRIBUTE  = 101,
        GENERAL_ARMS       = 103,
        GENERAL_INSIGHT    = 104,
        GENERAL_RANK       = 106,
        COLLECT_MODULE     = 107,
        GENERAL_EQUIP      = 108,
        MAP_GUIDE          = 105,
        MAP_GUIDE_INFO     = 109,
        FORMATION          = 124,
        ARRANGE_BEFORE_WAR = 125,
        BUY_MILITORY_ORDER = 211,
        GET_RESOURCE       = 212,
        FARM_LAND          = 251,
        CROP_MAIN          = 301,
        CROP_MY            = 302,
        CROP_TECH          = 303,
        LEGIN_CAMPAIGN     = 304,
        CROP_HELP          = 305,
        CROP_SIGN          = 306,
        WORLD_TREND        = 307,
        EQUIPMENT          = 602,
        SOLDIERDRAFT       = 700,
        STRATEGY_MODULE    = 802,
        EQUIP_POOL         = 901,
        FARM_COLLECT       = 1401,
        TRIALS_TOWER       = 1501,
        TAVERN_VIEW        = 1601,
        GENRAL_SHOP        = 2601,
        ATHLETICS_SHOP     = 2602,
        ANCIENT_CITY_SHOP  = 2603,
        TRIAL_TOWER_SHOP   = 2604,
        ANCIENT_CITY       = 2701,
        ARENA              = 2801,
        DAILY              = 2900,
        DAILY_INSTANCE     = 2901,
        FLY_NAIL_MODULE    = 3201,
        FLY_NAIL_BATTLE    = 3202,
        GENERALS_SELECT    = 3203,
        FLY_NAIL_NPC_INFO  = 3204,
        STRANGE_DOOR       = 3205,
        DRILL_GROUND       = 3211,
        ACTIVITY_MAIN      = 3301,
        TASK_DAY_SEVEN     = 3302,
        GROWTH_FUND        = 3304,
        ACTIVITY_LEVEL     = 3305,
        ACTIVITY_SIGN      = 3307,
        PASS_CHECK         = 3350,
        WORLD_TROOP        = 3400,
    },
    TYPE_ACTIVITY_TIME_LIMIT = {
        RESIDENT = 1,               --常驻
        CREATE_ROLE = 2,            --创角开始计时
        FIXED_TIME = 3,             --固定时间
        WAR_ORDER = 4               -- 战令
    },

    -- Module玩法规则
    MODULE_RULE_ID = {
        COLLECT         = 1,        -- 征收
        BUILD_OFFICE    = 11,       -- 建设官
        DECOMPOSE       = 21,       -- 分解
        EQUIP           = 101,      -- 装备
        ARENA           = 203,      -- 竞技场规则
        ANCIENT_CITY    = 301,      -- 古城说明
        GENERAL_COLLECT = 401,      -- 武将招募说明
        TASK_SEVEN_DAY  = 501,      -- 七天乐
        TRIALS_TOWER    = 601,      -- 试炼塔
        GENERAL_MODULE  = 411,      -- 武将界面
        RECRUIT         = 701,      -- 酒馆
        DECREE          = 801,      -- 政令
        WORLD           = 901,      -- 天下
    },

    COMMON_SOUND = {
        BUTTON = 1,                   --通用点击按钮
        RECEIVE_AWARDS = 2,           --通用领取奖励(按钮声音)
        FAIL = 3,                     --通用失败提示音效
        UNLOCK = 4,                   --通用解锁音效
        COST = 5                      --通用获得钱币
    },

    GOVERNMENT_POS = {
        COMMANDER = 0,                  --军团长
        SUB_COMMANDER = 1,              --副军团长
        WARLOAD = 2,                    --督军
        TATRAP = 3,                     --太守
        MEMBER = 4                      --民
    },

    TYPE_EMBATTLE = {
        INSTANCE_EMBATTLE     = 1,    --副本布阵
        NATIONAL_WAR_EMBATTLE = 2,    --国战布阵
        DRILL_GROUND_EMBATTLE = 3,    --百炼布阵
        ATHLETIC_EMBATTLE     = 4,    --竞技场布阵
        FLYNAIL_EMBATTLE      = 5,    --八门布阵
        CROP_SIGN             = 6,    --军团演武
    },

    MAP_IMAGE_SCALE = 1.2,
    MOVE_DISTANCE = 50,

    GUIDE_TYPE = {
        TALK = 1,                      --谈话引导
        FORCE = 2,                     --强制引导
        DEC = 3,                       --文字内容引导
        CHAPTER_OPNE = 4,              --功能开启
    },

    BAG_TYPE = {                       --宝箱类型
        MATERIAL            = 1,       --材料
        FAMOUS              = 2,       --名品
        CHEST               = 3,       --概率宝箱
        BUILD               = 4,
        WEIGHT              = 5,       --权重宝箱
        CHOOSABLE           = 6,       --可选宝箱
        FUNC                = 7,       --功能道具
    },
    OPEN_TIPS = {
        LV                  = 1,      --主城等级
        CARD                = 2,      --通关关卡id
    },
    GUIDE_BRANCH = {
        FORCE_GUIDE         = 1,      --强制类型引导
        TRIGGER_GUIDE       = 2,      --触发类型引导
    },
    GUIDE_TRIGGER = {
        CHAPTER_FINISH      = 1,      --章节任务结束
        CHAPTER_START       = 2,      --章节任务开启
        CARD_CLICK          = 3,      --点击关卡触发
        BATTLE_CLICK        = 4,      --战斗胜利触发
    },
    MATERIAL_ITEM = {
        MOIRE               = 3161,    -- 云纹
    },

    BUILD_TYPE = {
        MAIN_CITY = 0, --主城
        SOLDIER   = 1, --军营
        STRATEGY  = 2, --策略附
        IRON      = 3, --铁矿
        HOUSE     = 4, --民居
        FARM_LAND = 5, --农田
        SHIP      = 6, --商船
        JIUGUAN   = 7, --酒馆
        RANK      = 8, --排行榜
    },

    BUILD_ID = {
        MAIN            = 0, --主城
        STRATRGY        = 1, --策略府
        PRODUCE         = 9, --锻造所
        HOUSE_4         = 13, --民居4
        HOUSE_3         = 15, --民居3
        HOUSE_2         = 14, --民居2
        HOUSE_1         = 16, --民居1
        FARM_LAND_1     = 17, --农田1
        FARM_LAND_2     = 23, --农田2
        FARM_LAND_3     = 24, --农田3
        FARM_LAND_4     = 26, --农田4
    },

    BUILD_OFFICER_EFFECT = {
        TYPE_LEVEL_UP_TIME   = 1, --升级时间-
        TYPE_LEVEL_UP_COST   = 2, --升级消耗-
        TYPE_CONQUER_SOLDIER = 3, --征收预备兵-
        TYPE_CONQUER_COST    = 4, --征兵消耗-
        TYPE_STUDY_COST      = 5, --研究消耗-
        TYPE_TECH_PRO        = 6, --每分钟产出%s个科技点
        TYPE_STRENGTH_COST   = 7, --强化消耗-
        TYPE_PRO_IRON        = 8, --每小时铁矿增加
        TYPE_MONEY_ADD       = 9, --每小时征收银两+
        TYPE_FOOD_ADD        = 10, --每小时收获粮食+
        TYPE_UP_GENERAL_RATE = 11, --登庸武将概率+
    },

    POP_SHOW_TYPE = {
        CROP     = 1, --军团互助
        RES      = 2, --资源
        RELATION = 3, --人物关系
    },

    GENERAL_SHOP = {
        ANCIENT_CITY_SHOP = 1,  --古城商店
        ATHLETICS_SHOP    = 2,  --竞技商店
        TRIAL_TOWER_SHOP  = 3,  --试炼商店
        JADE_SHOP         = 4,  --龙玉商店
        GOLD_SHOP         = 5,  --元宝商店
    },
    SHOP_BUY_TYPE = {
        ANCIENT_CITY            = 1,  --古城商店购买
        JADE_SHOP               = 2,  --龙玉商店
        GOLD_SHOP               = 3,  --元宝商店
        TRIAL_SHOP              = 4,  --试炼塔商店
        TRIAL_REWARD            = 5,  --试炼塔奖励
        ATHLETICS_SHOP          = 6,  --竞技场商店
        ATHLETICS_REWARD        = 7,  --竞技场奖励
        PASS_STORE              = 8,  --通行证商店
        BUILD_OFFICER_STRENGTH  = 9,  --建设官体力
    },

    ROLE_SETTING = {
        SET_MUSIC       = 'set_music',
        SET_SOUND       = 'set_sound',
        SET_REPORT      = 'set_report',
        SET_MSG         = 'set_msg',
        SET_MUSIC_VOLUM = 'set_music_volum',
        SET_SOUND_VOLUM = 'set_sound_volum',
    },

    HEAD_TYPE = {
        NORMAL  = 1,
        GENERAL = 2,
        BUY_RES = 3,
    },

    STRATRGY_TYPE = {
        BUILD_TIME           = 19,
        BUILD_COST           = 21,
        STUDY_TIME           = 20,
        STUDY_COST           = 22
    },

    CROP_TECH = {
        CROP_LEVEL = 1,
    }
}

return constant