local Protocol         = cc.exports.Protocol or {}

Protocol.C_2_S_BASE             = 2000
Protocol.S_2_C_BASE             = 20000

Protocol.MD5_LEN                = 32
Protocol.IP_LEN                 = 45
Protocol.MAX_LOGIN_NAME_LEN     = 60
Protocol.MAX_PLATFORM_ID_LEN    = 20
Protocol.MAX_PEER_ID_LEN        = 30
Protocol.MAX_PEER_NAME_LEN      = 48
Protocol.MAX_REPORT_ADDRESS_LEN = 60
Protocol.MAX_SOURCE_LEN         = 30
Protocol.MAX_ACCOUNT_NAME_LEN   = 36
Protocol.MAX_FLAG_NAME_LEN      = 3 * 3

Protocol.C_2_S_KEEP_ALIVE       = 0
Protocol.S_2_C_KEEP_ALIVE       = 4

Protocol.MAX_GIFT_CARD_LEN      = 64
Protocol.MAX_NEW_TUTORIAL_LEN   = 200
Protocol.MAX_EXTRA_MO_COUNT     = 6
Protocol.MAX_COMP_ITEM_COUNT    = 2
Protocol.MAX_GF_ITEM_COUNT      = 3
Protocol.MAX_ACCOUNT_COUNT      = 20

-- Protocol.ST_ONLINE              = 1
-- Protocol.ST_OFFLINE             = 2
-- Protocol.ST_CORPS_BATTLE        = 3
-- Protocol.ST_CROSS_INS           = 4
Protocol.MASTER_NAME_INFO_NUM   = 5
Protocol.MAX_CROP_POWER_NAME_LEN = 3

Protocol.MAX_BOSOM_FRIEND_NUMS      = 5
Protocol.MAX_FOR_OFFICER_COUNT      = 5
Protocol.MAX_CROPS_NAME_LEN         = 30 --军团名称长度
Protocol.DEV_COUNT                  = 3
Protocol.MAX_BUILDER_COUNT          = 8
Protocol.MAX_MSG_CONTENT_LEN        = 910
Protocol.MAX_MAIL_TITLE             = 45 * 3
Protocol.MAX_MAIL_TIME              = 100
Protocol.MAX_MAIL_CONTEXT           = 455 * 3
Protocol.MAX_RECV_NUMS_PER          = 5
Protocol.MAX_MAIL_NUM               = 16
Protocol.MAX_CROPS_DECLARE_MSG_LEN  = 36 * 3
Protocol.MAX_CROPS_BOARD_MSG_LEN    = 45 * 3
Protocol.CROP_AUTO_JION_SETTING_LEN = 210
Protocol.MAX_LEAVE_MSG_LEN          = 30 * 3
Protocol.NETWORK_MAX_PACKET_BYTES   = 2048 * 2
Protocol.MAX_REWARD_LEN             = 2000
Protocol.MAX_SIZE                   = 1800
Protocol.MAX_ADVANCE_INFO           = 6
Protocol.MAX_EQUIP_LEN              = 6
Protocol.MAX_BROAD_MSG_LEN          = 210

Protocol.MAX_MAIL_TITLE_LEN         = 21
Protocol.MAX_MAIL_REWARD_STR_LEN    = 256
Protocol.MAX_MAIL_NUMS              = 50

Protocol.MAX_CROP_REDBAG_MSG_LEN    = 60
Protocol.MAX_CROP_REDBAG_PASSWD_LEN = 60
Protocol.MAX_CROP_NAME_LEN          = 30
Protocol.MAX_OFFICER_LEN            = 7

Protocol.Packet_Data_RewardType = {
    type                    = {type = Protocol.DataType.short},
    num                     = {type = Protocol.DataType.longlong},
    paraml                  = {type = Protocol.DataType.int},
    fields                  = {'type','num','paraml'}
}

--------------------------------------------------------------------------------------------
-- 心跳回包
Protocol.Packet_S2C_KEEP_ALIVE = {
    fields = {}
}
Protocol.structs[Protocol.S_2_C_KEEP_ALIVE] = Protocol.Packet_S2C_KEEP_ALIVE

------------------------------------C_2_S---------------------------------------------------
Protocol.C_2_S_ACCOUNT_BASE                     = Protocol.C_2_S_BASE                 --2000
Protocol.C_2_S_ACCOUNT_TOP                      = Protocol.C_2_S_ACCOUNT_BASE + 100

Protocol.C_2_S_CHAT_BASE                        = Protocol.C_2_S_ACCOUNT_TOP          --2100
Protocol.C_2_S_CHAT_TOP                         = Protocol.C_2_S_CHAT_BASE + 100

Protocol.C_2_S_CHAR_BASE                        = Protocol.C_2_S_CHAT_TOP             --2200
Protocol.C_2_S_CHAR_TOP                         = Protocol.C_2_S_CHAR_BASE + 100

Protocol.C_2_S_CITY_BASE                        = Protocol.C_2_S_CHAR_TOP             --2300
Protocol.C_2_S_CITY_TOP                         = Protocol.C_2_S_CITY_BASE + 100

Protocol.C_2_S_MAIL_BASE                        = Protocol.C_2_S_CITY_TOP + 0        --2400
Protocol.C_2_S_MAIL_TOP                         = Protocol.C_2_S_MAIL_BASE + 100

Protocol.C_2_S_WORLD_BASE                       = Protocol.C_2_S_MAIL_TOP + 0       --2500
Protocol.C_2_S_WORLD_TOP                        = Protocol.C_2_S_WORLD_BASE + 100

Protocol.C_2_S_EQUIPMENT_BASE                   = Protocol.C_2_S_WORLD_TOP + 0        --2600
Protocol.C_2_S_EQUIPMENT_TOP                    = Protocol.C_2_S_EQUIPMENT_BASE + 100

Protocol.C_2_S_GENERAL_BASE                     = Protocol.C_2_S_EQUIPMENT_TOP + 0        --2700
Protocol.C_2_S_GENERAL_TOP                      = Protocol.C_2_S_GENERAL_BASE + 100

Protocol.C_2_S_SCHOOL_FIELD_BASE                = Protocol.C_2_S_GENERAL_TOP + 0        --2800
Protocol.C_2_S_SCHOOL_FIELD_TOP                 = Protocol.C_2_S_SCHOOL_FIELD_BASE + 100

Protocol.C_2_S_APPOINT_BASE                       = Protocol.C_2_S_SCHOOL_FIELD_TOP + 0        --2900
Protocol.C_2_S_APPOINT_TOP                        = Protocol.C_2_S_APPOINT_BASE + 100

Protocol.C_2_S_FORMATION_BASE                   = Protocol.C_2_S_APPOINT_TOP + 0    --3000
Protocol.C_2_S_FORMATION_TOP                    = Protocol.C_2_S_FORMATION_BASE + 100

Protocol.C_2_S_BATTLE_BASE                      = Protocol.C_2_S_FORMATION_TOP + 0   --3100
Protocol.C_2_S_BATTLE_TOP                       = Protocol.C_2_S_BATTLE_BASE + 100

Protocol.C_2_S_TECHNOLOGY_BASE                  = Protocol.C_2_S_BATTLE_TOP + 0        --3200
Protocol.C_2_S_TECHNOLOGY_TOP                   = Protocol.C_2_S_TECHNOLOGY_BASE + 100

Protocol.C_2_S_CROPS_BASE                       = Protocol.C_2_S_TECHNOLOGY_TOP + 0   --3300
Protocol.C_2_S_CROPS_TOP                        = Protocol.C_2_S_CROPS_BASE + 100

Protocol.C_2_S_INSTANCE_BASE                    = Protocol.C_2_S_CROPS_TOP + 0        --3400
Protocol.C_2_S_INSTANCE_TOP                     = Protocol.C_2_S_INSTANCE_BASE + 100

Protocol.C_2_S_DRAFT_BASE                       = Protocol.C_2_S_INSTANCE_TOP + 0        --3500
Protocol.C_2_S_DRAFT_TOP                        = Protocol.C_2_S_DRAFT_BASE + 100

Protocol.C_2_S_OFFICIALPOSITION_BASE            = Protocol.C_2_S_DRAFT_TOP + 0     --3600
Protocol.C_2_S_OFFICIALPOSITION_TOP             = Protocol.C_2_S_OFFICIALPOSITION_BASE + 100

Protocol.C_2_S_MARKET_BASE                      = Protocol.C_2_S_OFFICIALPOSITION_TOP + 0        --3700
Protocol.C_2_S_MARKET_TOP                       = Protocol.C_2_S_MARKET_BASE + 100

Protocol.C_2_S_CD_TIME_BASE                     = Protocol.C_2_S_MARKET_TOP + 0     --3800
Protocol.C_2_S_CD_TIME_TOP                      = Protocol.C_2_S_CD_TIME_BASE + 100

Protocol.C_2_S_COLLECTION_BASE                  = Protocol.C_2_S_CD_TIME_TOP + 0        --3900
Protocol.C_2_S_COLLECTION_TOP                   = Protocol.C_2_S_COLLECTION_BASE + 100

Protocol.C_2_S_WORKSHOP_BASE                    = Protocol.C_2_S_COLLECTION_TOP + 0    --4000
Protocol.C_2_S_WORKSHOP_TOP                     = Protocol.C_2_S_WORKSHOP_BASE + 100

Protocol.C_2_S_TASK_BASE                        = Protocol.C_2_S_WORKSHOP_TOP + 0   --4100
Protocol.C_2_S_TASK_TOP                         = Protocol.C_2_S_TASK_BASE + 100

Protocol.C_2_S_ACTIVITY_BASE                    = Protocol.C_2_S_TASK_TOP + 0      --4200
Protocol.C_2_S_ACTIVITY_TOP                     = Protocol.C_2_S_ACTIVITY_BASE + 100

Protocol.C_2_S_NEW_TUTORIAL_BASE                = Protocol.C_2_S_ACTIVITY_TOP + 0        --4300
Protocol.C_2_S_NEW_TUTORIAL_TOP                 = Protocol.C_2_S_NEW_TUTORIAL_BASE + 100

Protocol.C_2_S_TAVERN_BASE                      = Protocol.C_2_S_NEW_TUTORIAL_TOP + 0    --4400
Protocol.C_2_S_TAVERN_TOP                       = Protocol.C_2_S_TAVERN_BASE + 100

Protocol.C_2_S_RANK_BASE                        = Protocol.C_2_S_TAVERN_TOP + 0        --4500
Protocol.C_2_S_RANK_TOP                         = Protocol.C_2_S_RANK_BASE + 100

Protocol.C_2_S_EXTERNAL_RUN_BASE                = Protocol.C_2_S_RANK_TOP + 0        --4600
Protocol.C_2_S_EXTERNAL_RUN_TOP                 = Protocol.C_2_S_EXTERNAL_RUN_BASE + 100

Protocol.C_2_S_ACHIEVEMENT_BASE                 = Protocol.C_2_S_EXTERNAL_RUN_TOP + 0        --4700
Protocol.C_2_S_ACHIEVEMENT_TOP                  = Protocol.C_2_S_ACHIEVEMENT_BASE + 100

Protocol.C_2_S_BATTLE_ABOUT_BASE                = Protocol.C_2_S_ACHIEVEMENT_TOP + 0        --4800
Protocol.C_2_S_BATTLE_ABOUT_TOP                 = Protocol.C_2_S_BATTLE_ABOUT_BASE + 100

Protocol.C_2_S_PATROL_BASE                      = Protocol.C_2_S_BATTLE_ABOUT_TOP + 0        --4900
Protocol.C_2_S_PATROL_TOP                       = Protocol.C_2_S_PATROL_BASE + 100

Protocol.C_2_S_CHALLENGE_CUP_BASE               = Protocol.C_2_S_PATROL_TOP + 0        --5000
Protocol.C_2_S_CHALLENGE_CUP_TOP                = Protocol.C_2_S_CHALLENGE_CUP_BASE + 100

Protocol.C_2_S_TRIALS_TOWER_BASE                = Protocol.C_2_S_CHALLENGE_CUP_TOP + 0        --5100
Protocol.C_2_S_TRIALS_TOWER_TOP                 = Protocol.C_2_S_TRIALS_TOWER_BASE + 100

Protocol.C_2_S_MEDAL_BASE                       = Protocol.C_2_S_TRIALS_TOWER_TOP + 0        --5200
Protocol.C_2_S_MEDAL_TOP                        = Protocol.C_2_S_MEDAL_BASE +100

Protocol.C_2_S_ONLINE_REWARD_BASE               = Protocol.C_2_S_MEDAL_TOP + 0        --5300
Protocol.C_2_S_ONLINE_REWARD_TOP                = Protocol.C_2_S_ONLINE_REWARD_BASE + 100

Protocol.C_2_S_REBUILD_EQUIPMENT_BASE           = Protocol.C_2_S_ONLINE_REWARD_TOP + 0        --5400
Protocol.C_2_S_REBUILD_EQUIPMENT_TOP            = Protocol.C_2_S_REBUILD_EQUIPMENT_BASE + 100

Protocol.C_2_S_MUTI_NPC_BATTLE_BASE             = Protocol.C_2_S_REBUILD_EQUIPMENT_TOP + 0        --5500
Protocol.C_2_S_MUTI_NPC_BATTLE_TOP              = Protocol.C_2_S_MUTI_NPC_BATTLE_BASE + 100

Protocol.C_2_S_CROSS_SERVER_BATTLE_BASE         = Protocol.C_2_S_MUTI_NPC_BATTLE_TOP + 0        --5600
Protocol.C_2_S_CROSS_SERVER_BATTLE_TOP          = Protocol.C_2_S_CROSS_SERVER_BATTLE_BASE + 100

Protocol.C_2_S_FESTIVAL_BASE                    = Protocol.C_2_S_CROSS_SERVER_BATTLE_TOP + 0        --5700
Protocol.C_2_S_FESTIVAL_TOP                     = Protocol.C_2_S_FESTIVAL_BASE + 100

Protocol.C_2_S_HUNTING_BASE                     = Protocol.C_2_S_FESTIVAL_TOP + 0        --5800
Protocol.C_2_S_HUNTING_TOP                      = Protocol.C_2_S_HUNTING_BASE + 100

Protocol.C_2_S_KING_BASE                        = Protocol.C_2_S_HUNTING_TOP + 0        --5900
Protocol.C_2_S_KING_TOP                         = Protocol.C_2_S_KING_BASE + 100

Protocol.C_2_S_GENERAL_SOUL_BASE                = Protocol.C_2_S_KING_TOP + 0   --6000
Protocol.C_2_S_GENERAL_SOUL_TOP                 = Protocol.C_2_S_GENERAL_SOUL_BASE + 100

Protocol.C_2_S_LIVENESS_BASE                    = Protocol.C_2_S_GENERAL_SOUL_TOP + 0        --6100
Protocol.C_2_S_LIVENESS_TOP                     = Protocol.C_2_S_LIVENESS_BASE + 100

Protocol.C_2_S_ACTIVITY_DAY_BASE                = Protocol.C_2_S_LIVENESS_TOP + 0        --6200
Protocol.C_2_S_ACTIVITY_DAY_TOP                 = Protocol.C_2_S_ACTIVITY_DAY_BASE + 100

Protocol.C_2_S_MAIN_CITY_BASE                   = Protocol.C_2_S_ACTIVITY_DAY_TOP + 0        --6300
Protocol.C_2_S_MAIN_CITY_TOP                    = Protocol.C_2_S_MAIN_CITY_BASE + 100

Protocol.C_2_S_MATERIALS_BASE                   = Protocol.C_2_S_MAIN_CITY_TOP + 0        --6400
Protocol.C_2_S_MATERIALS_TOP                    = Protocol.C_2_S_MATERIALS_BASE + 100

Protocol.C_2_S_SEA_TRADE_BASE                   = Protocol.C_2_S_MATERIALS_TOP + 0        --6500
Protocol.C_2_S_SEA_TRADE_TOP                    = Protocol.C_2_S_SEA_TRADE_BASE + 100

Protocol.C_2_S_PLAY_JAR_BASE                    = Protocol.C_2_S_SEA_TRADE_TOP + 0        --6600
Protocol.C_2_S_PLAY_JAR_TOP                     = Protocol.C_2_S_PLAY_JAR_BASE + 100

Protocol.C_2_S_SEA_AGGRESSION_BASE              = Protocol.C_2_S_PLAY_JAR_TOP + 0        --6700
Protocol.C_2_S_SEA_AGGRESSION_TOP               = Protocol.C_2_S_SEA_AGGRESSION_BASE + 100

Protocol.C_2_S_PAY_ACTIVITY_BASE                = Protocol.C_2_S_SEA_AGGRESSION_TOP + 0        --6800
Protocol.C_2_S_PAY_ACTIVITY_TOP                 = Protocol.C_2_S_PAY_ACTIVITY_BASE + 100

Protocol.C_2_S_FESTIVAL_ACTIVITY_BASE           = Protocol.C_2_S_PAY_ACTIVITY_TOP + 0        --6900
Protocol.C_2_S_FESTIVAL_ACTIVITY_TOP            = Protocol.C_2_S_FESTIVAL_ACTIVITY_BASE + 100

Protocol.C_2_S_ETCHED_HOUSE_BASE                = Protocol.C_2_S_FESTIVAL_ACTIVITY_TOP + 0        --7000
Protocol.C_2_S_ETCHED_HOUSE_TOP                 = Protocol.C_2_S_ETCHED_HOUSE_BASE + 100

Protocol.C_2_S_KNIGHT_TOWER_BASE                = Protocol.C_2_S_ETCHED_HOUSE_TOP + 0        --7100
Protocol.C_2_S_KNIGHT_TOWER_TOP                 = Protocol.C_2_S_KNIGHT_TOWER_BASE + 100

Protocol.C_2_S_CITY_DEFENSE_BATTLE_BASE         = Protocol.C_2_S_KNIGHT_TOWER_TOP + 0        --7200
Protocol.C_2_S_CITY_DEFENSE_BATTLE_TOP          = Protocol.C_2_S_CITY_DEFENSE_BATTLE_BASE + 100

Protocol.C_2_S_BOSOM_FRIEND_BASE                = Protocol.C_2_S_CITY_DEFENSE_BATTLE_TOP + 0        --7300
Protocol.C_2_S_BOSOM_FRIEND_TOP                 = Protocol.C_2_S_BOSOM_FRIEND_BASE + 100

Protocol.C_2_S_GENERAL_SCHOOL_BASE              = Protocol.C_2_S_BOSOM_FRIEND_TOP + 0        --7400
Protocol.C_2_S_GENERAL_SCHOOL_TOP               = Protocol.C_2_S_GENERAL_SCHOOL_BASE + 100

Protocol.C_2_S_EXTREME_VIP_BASE                 = Protocol.C_2_S_GENERAL_SCHOOL_TOP + 0        --7500
Protocol.C_2_S_EXTREME_VIP_TOP                  = Protocol.C_2_S_EXTREME_VIP_BASE + 100

Protocol.C_2_S_ELITE_INSTANCE_BASE              = Protocol.C_2_S_EXTREME_VIP_TOP + 0        --7600
Protocol.C_2_S_ELITE_INSTANCE_TOP               = Protocol.C_2_S_ELITE_INSTANCE_BASE + 100

Protocol.C_2_S_TRAVEL_BASE                      = Protocol.C_2_S_ELITE_INSTANCE_TOP + 0        --7700
Protocol.C_2_S_TRAVEL_TOP                       = Protocol.C_2_S_TRAVEL_BASE + 100

Protocol.C_2_S_COMPETITION_BASE                 = Protocol.C_2_S_TRAVEL_TOP + 0        --7800
Protocol.C_2_S_COMPETITION_TOP                  = Protocol.C_2_S_COMPETITION_BASE + 100

Protocol.C_2_S_CROSS_SERVER_COMPETITION_BASE    = Protocol.C_2_S_COMPETITION_TOP + 0        --7900
Protocol.C_2_S_CROSS_SERVER_COMPETITION_TOP     = Protocol.C_2_S_CROSS_SERVER_COMPETITION_BASE + 100

Protocol.C_2_S_NATION_BATTLE_BASE               = Protocol.C_2_S_CROSS_SERVER_COMPETITION_TOP + 0    --8000
Protocol.C_2_S_NATION_BATTLE_TOP                = Protocol.C_2_S_NATION_BATTLE_BASE + 100

Protocol.C_2_S_WORLD_CITY_BASE                  = 9000
Protocol.C_2_S_WORLD_CITY_TOP                   = Protocol.C_2_S_WORLD_CITY_BASE + 100

Protocol.C_2_S_ANCIENT_CITY_BASE                = Protocol.C_2_S_WORLD_CITY_TOP + 0     --9100
Protocol.C_2_S_ANCIENT_CITY_TOP                 = Protocol.C_2_S_ANCIENT_CITY_BASE + 100

Protocol.C_2_S_SHOP_ITEM_BASE                   = Protocol.C_2_S_ANCIENT_CITY_TOP + 0      --9200
Protocol.C_2_S_SHOP_ITEM_TOP                    = Protocol.C_2_S_SHOP_ITEM_BASE + 100

Protocol.C_2_S_SMELT_BASE                       = Protocol.C_2_S_SHOP_ITEM_TOP + 0    --9300
Protocol.C_2_S_SMELT_TOP                        = Protocol.C_2_S_SMELT_BASE + 100

Protocol.C_2_S_WAREHOUSE_CELL_BASE              = Protocol.C_2_S_SMELT_TOP + 0    --9400
Protocol.C_2_S_WAREHOUSE_CELL_TOP               = Protocol.C_2_S_WAREHOUSE_CELL_BASE + 100

Protocol.C_2_S_ATHLETICS_BASE                   = Protocol.C_2_S_WAREHOUSE_CELL_TOP + 0    --9500
Protocol.C_2_S_ATHLETICS_TOP                    = Protocol.C_2_S_ATHLETICS_BASE + 100

Protocol.C_2_S_CROSS_SERVER_ATHLETICS_BASE      = Protocol.C_2_S_ATHLETICS_TOP + 0    --9600
Protocol.C_2_S_CROSS_SERVER_ATHLETICS_TOP       = Protocol.C_2_S_CROSS_SERVER_ATHLETICS_BASE + 100

Protocol.C_2_S_MASTER_BASE                      = Protocol.C_2_S_CROSS_SERVER_ATHLETICS_TOP + 0    --9700
Protocol.C_2_S_MASTER_TOP                       = Protocol.C_2_S_MASTER_BASE + 100

Protocol.C_2_S_CROSS_SERVER_CORPS_BATTLE_BASE   = Protocol.C_2_S_MASTER_TOP + 0    --9800
Protocol.C_2_S_CROSS_SERVER_CORPS_BATTLE_TOP    = Protocol.C_2_S_CROSS_SERVER_CORPS_BATTLE_BASE + 100

Protocol.C_2_S_CROSS_SERVER_PLUNDER_WAR_BASE    = Protocol.C_2_S_CROSS_SERVER_CORPS_BATTLE_TOP + 0    --9900
Protocol.C_2_S_CROSS_SERVER_PLUNDER_WAR_TOP     = Protocol.C_2_S_CROSS_SERVER_PLUNDER_WAR_BASE + 100

Protocol.C_2_S_CROSS_INSTANCE_BASE              = Protocol.C_2_S_CROSS_SERVER_PLUNDER_WAR_TOP + 0     --10000
Protocol.C_2_S_CROSS_INSTANCE_TOP               = Protocol.C_2_S_CROSS_INSTANCE_BASE + 100

Protocol.C_2_S_RED_PACKETS_BASE                 = Protocol.C_2_S_CROSS_INSTANCE_TOP + 0     --10100
Protocol.C_2_S_RED_PACKETS_TOP                  = Protocol.C_2_S_RED_PACKETS_BASE + 100

Protocol.C_2_S_HORSE_BASE                       = Protocol.C_2_S_RED_PACKETS_TOP + 0     --10200
Protocol.C_2_S_HORSE_TOP                        = Protocol.C_2_S_HORSE_BASE + 100

Protocol.C_2_S_GENERAL_EVALUATE_BASE            = Protocol.C_2_S_HORSE_TOP + 0     --10300
Protocol.C_2_S_GENERAL_EVALUATE_TOP             = Protocol.C_2_S_GENERAL_EVALUATE_BASE + 100

Protocol.C_2_S_CROSS_SERVER_SHOP_BASE           = Protocol.C_2_S_GENERAL_EVALUATE_TOP + 0    --10400
Protocol.C_2_S_CROSS_SERVER_SHOP_TOP            = Protocol.C_2_S_CROSS_SERVER_SHOP_BASE + 100

Protocol.C_2_S_CROSS_SERVER_WORLD_BOSS_BASE     = Protocol.C_2_S_CROSS_SERVER_SHOP_TOP + 0    --10500
Protocol.C_2_S_CROSS_SERVER_WORLD_BOSS_TOP      = Protocol.C_2_S_CROSS_SERVER_WORLD_BOSS_BASE + 100

Protocol.C_2_S_GENERAL_SCHOOL_CHILD_BASE        = Protocol.C_2_S_CROSS_SERVER_WORLD_BOSS_TOP + 0    --10600
Protocol.C_2_S_GENERAL_SCHOOL_CHILD_TOP         = Protocol.C_2_S_GENERAL_SCHOOL_CHILD_BASE + 100

Protocol.C_2_S_CROP2_BASE                       = Protocol.C_2_S_GENERAL_SCHOOL_CHILD_TOP + 0     --10700
Protocol.C_2_S_CROP2_TOP                        = Protocol.C_2_S_CROP2_BASE + 100

Protocol.C_2_S_RELATION_BASE                    = Protocol.C_2_S_CROP2_TOP + 0    --10800
Protocol.C_2_S_RELATION_TOP                     = Protocol.C_2_S_RELATION_BASE + 100

Protocol.C_2_S_PASSCARD_BASE                    = 10900
Protocol.C_2_S_PASSCARD_TOP                     = Protocol.C_2_S_PASSCARD_BASE + 100

Protocol.C_2_S_RANDOM_EVENT_BASE                = 11000
Protocol.C_2_S_RANDOM_EVENT_TOP                 = Protocol.C_2_S_RANDOM_EVENT_BASE + 100

Protocol.C_2_S_DRILL_GROUND_BASE                = Protocol.C_2_S_RANDOM_EVENT_TOP + 0
Protocol.C_2_S_DRILL_GROUND_TOP                 = Protocol.C_2_S_DRILL_GROUND_BASE + 100

Protocol.C_2_S_CAMPAIGN_BASE                     = 11200
Protocol.C_2_S_CAMPAIGN_TOP                      = Protocol.C_2_S_CAMPAIGN_BASE + 100

------------------------------------S_2_C---------------------------------------------------
Protocol.S_2_C_ACCOUNT_BASE                     = Protocol.S_2_C_BASE             --20000
Protocol.S_2_C_ACCOUNT_TOP                      = Protocol.S_2_C_ACCOUNT_BASE + 100

Protocol.S_2_C_CHAT_BASE                        = Protocol.S_2_C_ACCOUNT_TOP          --20100
Protocol.S_2_C_CHAT_TOP                         = Protocol.S_2_C_CHAT_BASE + 100

Protocol.S_2_C_AREA_BASE                        = Protocol.S_2_C_CHAT_TOP             --20200
Protocol.S_2_C_AREA_TOP                         = Protocol.S_2_C_AREA_BASE + 100

Protocol.S_2_C_CITY_BASE                        = Protocol.S_2_C_AREA_TOP             --20300
Protocol.S_2_C_CITY_TOP                         = Protocol.S_2_C_CITY_BASE + 100

Protocol.S_2_C_CHAR_BASE                        = Protocol.S_2_C_CITY_TOP              --20400
Protocol.S_2_C_CHAR_TOP                         = Protocol.S_2_C_CHAR_BASE + 100

Protocol.S_2_C_MAIL_BASE                        = Protocol.S_2_C_CHAR_TOP + 0       --20500
Protocol.S_2_C_MAIL_TOP                         = Protocol.S_2_C_MAIL_BASE + 100

Protocol.S_2_C_EQUIPMENT_EXT_BASE               = Protocol.S_2_C_MAIL_TOP + 0       --20600
Protocol.S_2_C_EQUIPMENT_EXT_TOP                = Protocol.S_2_C_EQUIPMENT_EXT_BASE + 100

Protocol.S_2_C_WORLD_AREA_BASE                  = Protocol.S_2_C_EQUIPMENT_EXT_TOP + 0       --20700
Protocol.S_2_C_WORLD_AREA_TOP                   = Protocol.S_2_C_WORLD_AREA_BASE + 100

Protocol.S_2_C_UPDATE_GAMETIME_BASE             = Protocol.S_2_C_WORLD_AREA_TOP + 0              --20800
Protocol.S_2_C_UPDATE_GAMETIME_TOP              = Protocol.S_2_C_UPDATE_GAMETIME_BASE + 100

Protocol.S_2_C_GENARAL_BASE                     = Protocol.S_2_C_UPDATE_GAMETIME_TOP + 0 --20900
Protocol.S_2_C_GENERAL_TOP                      = Protocol.S_2_C_GENARAL_BASE + 100

Protocol.S_2_C_EQUIPMENT_BASE                   = Protocol.S_2_C_GENERAL_TOP + 0     --21000
Protocol.S_2_C_EQUIPMENT_TOP                    = Protocol.S_2_C_EQUIPMENT_BASE + 100

Protocol.S_2_C_APPOINT_BASE                     = Protocol.S_2_C_EQUIPMENT_TOP + 0     --21100
Protocol.S_2_C_APPOINT_TOP                      = Protocol.S_2_C_APPOINT_BASE + 100

Protocol.S_2_C_SCHOOL_FIELD_BASE                = Protocol.S_2_C_APPOINT_TOP + 0    --21200
Protocol.S_2_C_SCHOOL_FIELD_TOP                 = Protocol.S_2_C_SCHOOL_FIELD_BASE + 100

Protocol.S_2_C_FORMATION_BASE                   = Protocol.S_2_C_SCHOOL_FIELD_TOP + 0    --21300
Protocol.S_2_C_FORMATION_TOP                    = Protocol.S_2_C_FORMATION_BASE + 100

Protocol.S_2_C_TECHNOLOGY_BASE                  = Protocol.S_2_C_FORMATION_TOP + 0    --21400
Protocol.S_2_C_TECHNOLOGY_TOP                   = Protocol.S_2_C_TECHNOLOGY_BASE + 100

Protocol.S_2_C_CROPS_BASE                       = Protocol.S_2_C_TECHNOLOGY_TOP + 0    --21500
Protocol.S_2_C_CROPS_TOP                        = Protocol.S_2_C_CROPS_BASE + 100

Protocol.S_2_C_INSTANCE_BASE                    = Protocol.S_2_C_CROPS_TOP + 0    --21600
Protocol.S_2_C_INSTANCE_TOP                     = Protocol.S_2_C_INSTANCE_BASE + 100

Protocol.S_2_C_DRAFT_BASE                       = Protocol.S_2_C_INSTANCE_TOP + 0    --21700
Protocol.S_2_C_DRAFT_TOP                        = Protocol.S_2_C_DRAFT_BASE + 100

Protocol.S_2_C_OFFICIALPOSITION_BASE            = Protocol.S_2_C_DRAFT_TOP + 0    --21800
Protocol.S_2_C_OFFICIALPOSITION_TOP             = Protocol.S_2_C_OFFICIALPOSITION_BASE + 100

Protocol.S_2_C_MARKET_BASE                      = Protocol.S_2_C_OFFICIALPOSITION_TOP + 0    --21900
Protocol.S_2_C_MARKET_TOP                       = Protocol.S_2_C_MARKET_BASE + 100

Protocol.S_2_C_CD_TIME_BASE                     = Protocol.S_2_C_MARKET_TOP + 0    --22000
Protocol.S_2_C_CD_TIME_TOP                      = Protocol.S_2_C_CD_TIME_BASE + 100

Protocol.S_2_C_COLLECTION_BASE                  = Protocol.S_2_C_CD_TIME_TOP + 0    --22100
Protocol.S_2_C_COLLECTION_TOP                   = Protocol.S_2_C_COLLECTION_BASE + 100

Protocol.S_2_C_WORKSHOP_BASE                    = Protocol.S_2_C_COLLECTION_TOP + 0  --22200
Protocol.S_2_C_WORKSHOP_TOP                     = Protocol.S_2_C_WORKSHOP_BASE + 100

Protocol.S_2_C_TASK_BASE                        = Protocol.S_2_C_WORKSHOP_TOP + 0    --22300
Protocol.S_2_C_TASK_TOP                         = Protocol.S_2_C_TASK_BASE + 100

Protocol.S_2_C_ACTIVITY_BASE                    = Protocol.S_2_C_TASK_TOP + 0    --22400
Protocol.S_2_C_ACTIVITY_TOP                     = Protocol.S_2_C_ACTIVITY_BASE + 100

Protocol.S_2_C_NEW_TUTORIAL_BASE                = Protocol.S_2_C_ACTIVITY_TOP + 0    --22500
Protocol.S_2_C_NEW_TUTORIAL_TOP                 = Protocol.S_2_C_NEW_TUTORIAL_BASE + 100

Protocol.S_2_C_TAVERN_BASE                      = Protocol.S_2_C_NEW_TUTORIAL_TOP + 0    --22600
Protocol.S_2_C_TAVERN_TOP                       = Protocol.S_2_C_TAVERN_BASE + 100

Protocol.S_2_C_RANK_BASE                        = Protocol.S_2_C_TAVERN_TOP + 0    --22700
Protocol.S_2_C_RANK_TOP                         = Protocol.S_2_C_RANK_BASE + 100

Protocol.S_2_C_AVOID_SYSTEM_BASE                = Protocol.S_2_C_RANK_TOP + 0    --22800
Protocol.S_2_C_AVOID_SYSTEM_TOP                 = Protocol.S_2_C_AVOID_SYSTEM_BASE + 100

Protocol.S_2_C_EXTERNAL_RUN_BASE                = Protocol.S_2_C_AVOID_SYSTEM_TOP + 0    --22900
Protocol.S_2_C_EXTERNAL_RUN_TOP                 = Protocol.S_2_C_EXTERNAL_RUN_BASE + 100

Protocol.S_2_C_ACHIEVEMENT_BASE                 = Protocol.S_2_C_EXTERNAL_RUN_TOP + 0    --23000
Protocol.S_2_C_ACHIEVEMENT_TOP                  = Protocol.S_2_C_ACHIEVEMENT_BASE + 100

Protocol.S_2_C_BATTLE_ABOUT_BASE                = Protocol.S_2_C_ACHIEVEMENT_TOP + 0    --23100
Protocol.S_2_C_BATTLE_ABOUT_TOP                 = Protocol.S_2_C_BATTLE_ABOUT_BASE + 100

Protocol.S_2_C_PATROL_BASE                      = Protocol.S_2_C_BATTLE_ABOUT_TOP + 0    --23200
Protocol.S_2_C_PATROL_TOP                       = Protocol.S_2_C_PATROL_BASE + 100

Protocol.S_2_C_CHALLENGE_CUP_BASE               = Protocol.S_2_C_PATROL_TOP + 0    --23300
Protocol.S_2_C_CHALLENGE_CUP_TOP                = Protocol.S_2_C_CHALLENGE_CUP_BASE + 100

Protocol.S_2_C_PEER_BASE                        = Protocol.S_2_C_CHALLENGE_CUP_TOP + 0    --23400
Protocol.S_2_C_PEER_TOP                         = Protocol.S_2_C_PEER_BASE + 100

Protocol.S_2_C_TRIALS_TOWER_BASE                = Protocol.S_2_C_PEER_TOP + 0    --23500
Protocol.S_2_C_TRIALS_TOWER_TOP                 = Protocol.S_2_C_TRIALS_TOWER_BASE + 100

Protocol.S_2_C_MEDAL_BASE                       = Protocol.S_2_C_TRIALS_TOWER_TOP + 0    --23600
Protocol.S_2_C_MEDAL_TOP                        = Protocol.S_2_C_MEDAL_BASE + 100

Protocol.S_2_C_ONLINE_REWARD_BASE               = Protocol.S_2_C_MEDAL_TOP + 0    --23700
Protocol.S_2_C_ONLINE_REWARD_TOP                = Protocol.S_2_C_ONLINE_REWARD_BASE + 100

Protocol.S_2_C_REBUILD_EQUIPMENT_BASE           = Protocol.S_2_C_ONLINE_REWARD_TOP + 0    -- 23800
Protocol.S_2_C_REBUILD_EQUIPMENT_TOP            = Protocol.S_2_C_REBUILD_EQUIPMENT_BASE + 100

Protocol.S_2_C_MUTI_NPC_BATTLE_BASE             = Protocol.S_2_C_REBUILD_EQUIPMENT_TOP + 0    --23900
Protocol.S_2_C_MUTI_NPC_BATTLE_TOP              = Protocol.S_2_C_MUTI_NPC_BATTLE_BASE + 100

Protocol.S_2_C_CROSS_SERVER_BATTLE_BASE         = Protocol.S_2_C_MUTI_NPC_BATTLE_TOP    --24000
Protocol.S_2_C_CROSS_SERVER_BATTLE_TOP          = Protocol.S_2_C_CROSS_SERVER_BATTLE_BASE + 100

Protocol.S_2_C_FESTIVAL_BASE                    = Protocol.S_2_C_CROSS_SERVER_BATTLE_TOP + 0    --24100
Protocol.S_2_C_FESTIVAL_TOP                     = Protocol.S_2_C_FESTIVAL_BASE + 100

Protocol.S_2_C_HUNTING_BASE                     = Protocol.S_2_C_FESTIVAL_TOP + 0    --24200
Protocol.S_2_C_HUNTING_TOP                      = Protocol.S_2_C_HUNTING_BASE + 100

Protocol.S_2_C_KING_BASE                        = Protocol.S_2_C_HUNTING_TOP + 0    --24300
Protocol.S_2_C_KING_TOP                         = Protocol.S_2_C_KING_BASE + 100

Protocol.S_2_C_GENERAL_SOUL_BASE                = Protocol.S_2_C_KING_TOP + 0    --24400
Protocol.S_2_C_GENERAL_SOUL_TOP                 = Protocol.S_2_C_GENERAL_SOUL_BASE + 100

Protocol.S_2_C_LIVENESS_BASE                    = Protocol.S_2_C_GENERAL_SOUL_TOP + 0    --24500
Protocol.S_2_C_LIVENESS_TOP                     = Protocol.S_2_C_LIVENESS_BASE + 100

Protocol.S_2_C_ACTIVITY_DAY_BASE                = Protocol.S_2_C_LIVENESS_TOP + 0    --24600
Protocol.S_2_C_ACTIVITY_DAY_TOP                 = Protocol.S_2_C_ACTIVITY_DAY_BASE + 100

Protocol.S_2_C_MAIN_CITY_BASE                   = Protocol.S_2_C_ACTIVITY_DAY_TOP + 0    --24700
Protocol.S_2_C_MAIN_CITY_TOP                    = Protocol.S_2_C_MAIN_CITY_BASE + 100

Protocol.S_2_C_MATERIALS_BASE                   = Protocol.S_2_C_MAIN_CITY_TOP + 0    --24800
Protocol.S_2_C_MATERIALS_TOP                    = Protocol.S_2_C_MATERIALS_BASE + 100

Protocol.S_2_C_SEA_TRADE_BASE                   = Protocol.S_2_C_MATERIALS_TOP + 0    --24900
Protocol.S_2_C_SEA_TRADE_TOP                    = Protocol.S_2_C_SEA_TRADE_BASE + 100

Protocol.S_2_C_PLAY_JAR_BASE                    = Protocol.S_2_C_SEA_TRADE_TOP + 0    --25000
Protocol.S_2_C_PLAY_JAR_TOP                     = Protocol.S_2_C_PLAY_JAR_BASE + 100

Protocol.S_2_C_SEA_AGGRESSION_BASE              = Protocol.S_2_C_PLAY_JAR_TOP + 0    --25100
Protocol.S_2_C_SEA_AGGRESSION_TOP               = Protocol.S_2_C_SEA_AGGRESSION_BASE + 100

Protocol.S_2_C_PAY_ACTIVITY_BASE                = Protocol.S_2_C_SEA_AGGRESSION_TOP + 0    --25200
Protocol.S_2_C_PAY_ACTIVITY_TOP                 = Protocol.S_2_C_PAY_ACTIVITY_BASE + 100

Protocol.S_2_C_FESTIVAL_ACTIVITY_BASE           = Protocol.S_2_C_PAY_ACTIVITY_TOP + 0    --25300
Protocol.S_2_C_FESTIVAL_ACTIVITY_TOP            = Protocol.S_2_C_FESTIVAL_ACTIVITY_BASE + 100

Protocol.S_2_C_ETCHED_HOUSE_BASE                = Protocol.S_2_C_FESTIVAL_ACTIVITY_TOP + 0    --25400
Protocol.S_2_C_ETCHED_HOUSE_TOP                 = Protocol.S_2_C_ETCHED_HOUSE_BASE + 100

Protocol.S_2_C_KNIGHT_TOWER_BASE                = Protocol.S_2_C_ETCHED_HOUSE_TOP + 0    --25500
Protocol.S_2_C_KNIGHT_TOWER_TOP                 = Protocol.S_2_C_KNIGHT_TOWER_BASE + 100

Protocol.S_2_C_CITY_DEFENSE_BATTLE_BASE         = Protocol.S_2_C_KNIGHT_TOWER_TOP + 0    --25600
Protocol.S_2_C_CITY_DEFENSE_BATTLE_TOP          = Protocol.S_2_C_CITY_DEFENSE_BATTLE_BASE + 100

Protocol.S_2_C_BOSOM_FRIEND_BASE                = Protocol.S_2_C_CITY_DEFENSE_BATTLE_TOP + 0    --25700
Protocol.S_2_C_BOSOM_FRIEND_TOP                 = Protocol.S_2_C_BOSOM_FRIEND_BASE + 100

Protocol.S_2_C_GENERAL_SCHOOL_BASE              = Protocol.S_2_C_BOSOM_FRIEND_TOP + 0    --25800
Protocol.S_2_C_GENERAL_SCHOOL_TOP               = Protocol.S_2_C_GENERAL_SCHOOL_BASE + 100

Protocol.S_2_C_EXTREME_VIP_BASE                 = Protocol.S_2_C_GENERAL_SCHOOL_TOP + 0    --25900
Protocol.S_2_C_EXTREME_VIP_TOP                  = Protocol.S_2_C_EXTREME_VIP_BASE + 100

Protocol.S_2_C_ELITE_INSTANCE_BASE              = Protocol.S_2_C_EXTREME_VIP_TOP + 0    --26000
Protocol.S_2_C_ELITE_INSTANCE_TOP               = Protocol.S_2_C_ELITE_INSTANCE_BASE + 100

Protocol.S_2_C_TRAVEL_BASE                      = Protocol.S_2_C_ELITE_INSTANCE_TOP + 0    --26100
Protocol.S_2_C_TRAVEL_TOP                       = Protocol.S_2_C_TRAVEL_BASE + 100

Protocol.S_2_C_COMPETITION_BASE                 = Protocol.S_2_C_TRAVEL_TOP + 0          --26200
Protocol.S_2_C_COMPETITION_TOP                  = Protocol.S_2_C_COMPETITION_BASE + 100

Protocol.S_2_C_NATION_BATTLE_BASE               = Protocol.S_2_C_COMPETITION_TOP + 0    --26300
Protocol.S_2_C_NATION_BATTLE_TOP                = Protocol.S_2_C_NATION_BATTLE_BASE + 100

Protocol.S_2_C_WORLD_CITY_BASE                  = 27000--Protocol.S_2_C_TRAVEL_TOP +0
Protocol.S_2_C_WORLD_CITY_TOP                   = Protocol.S_2_C_WORLD_CITY_BASE + 100

Protocol.S_2_C_ANCIENT_CITY_BASE                = Protocol.S_2_C_WORLD_CITY_TOP + 0    --27100
Protocol.S_2_C_ANCIENT_CITY_TOP                 = Protocol.S_2_C_ANCIENT_CITY_BASE + 100

Protocol.S_2_C_SHOP_ITEM_BASE                   = Protocol.S_2_C_ANCIENT_CITY_TOP + 0    --27200
Protocol.S_2_C_SHOP_ITEM_TOP                    = Protocol.S_2_C_SHOP_ITEM_BASE + 100

Protocol.S_2_C_SMELT_BASE                       = Protocol.S_2_C_SHOP_ITEM_TOP + 0     --27300
Protocol.S_2_C_SMELT_TOP                        = Protocol.S_2_C_SMELT_BASE + 100

Protocol.S_2_C_WAREHOUSE_CELL_BASE              = Protocol.S_2_C_SMELT_TOP + 0     --27400
Protocol.S_2_C_WAREHOUSE_CELL_TOP               = Protocol.S_2_C_WAREHOUSE_CELL_BASE + 100

Protocol.S_2_C_ATHLETICS_BASE                   = Protocol.S_2_C_WAREHOUSE_CELL_TOP + 0    --27500
Protocol.S_2_C_ATHLETICS_TOP                    = Protocol.S_2_C_ATHLETICS_BASE + 100

Protocol.S_2_C_MASTER_BASE                      = Protocol.S_2_C_ATHLETICS_TOP + 0    --27600
Protocol.S_2_C_MASTER_TOP                       = Protocol.S_2_C_MASTER_BASE + 100

Protocol.S_2_C_CROSS_SERVER_CORPS_BATTLE_BASE   = Protocol.S_2_C_MASTER_TOP + 0    --27700
Protocol.S_2_C_CROSS_SERVER_CORPS_BATTLE_TOP    = Protocol.S_2_C_CROSS_SERVER_CORPS_BATTLE_BASE + 100

Protocol.S_2_C_CROSS_SERVER_PLUNDER_WAR_BASE    = Protocol.S_2_C_CROSS_SERVER_CORPS_BATTLE_TOP + 0    --27800
Protocol.S_2_C_CROSS_SERVER_PLUNDER_WAR_TOP     = Protocol.S_2_C_CROSS_SERVER_PLUNDER_WAR_BASE + 100

Protocol.S_2_C_CROSS_INSTANCE_BASE              = Protocol.S_2_C_CROSS_SERVER_PLUNDER_WAR_TOP + 0    --27900
Protocol.S_2_C_CROSS_INSTANCE_TOP               = Protocol.S_2_C_CROSS_INSTANCE_BASE + 100

Protocol.S_2_C_RED_PACKETS_BASE                 = Protocol.S_2_C_CROSS_INSTANCE_TOP + 0    --28000
Protocol.S_2_C_RED_PACKETS_TOP                  = Protocol.S_2_C_RED_PACKETS_BASE + 100

Protocol.S_2_C_HORSE_BASE                       = Protocol.S_2_C_RED_PACKETS_TOP + 0    --28100
Protocol.S_2_C_HORSE_TOP                        = Protocol.S_2_C_HORSE_BASE + 100

Protocol.S_2_C_GENERAL_EVALUATE_BASE            = Protocol.S_2_C_HORSE_TOP + 0    --28200
Protocol.S_2_C_GENERAL_EVALUATE_TOP             = Protocol.S_2_C_GENERAL_EVALUATE_BASE + 100

Protocol.S_2_C_CROSS_SERVER_SHOP_BASE           = Protocol.S_2_C_GENERAL_EVALUATE_TOP + 0    --28300
Protocol.S_2_C_CROSS_SERVER_SHOP_TOP            = Protocol.S_2_C_CROSS_SERVER_SHOP_BASE + 100    --

Protocol.S_2_C_CROSS_SERVER_WORLD_BOSS_BASE     = Protocol.S_2_C_CROSS_SERVER_SHOP_TOP + 0    --28400
Protocol.S_2_C_CROSS_SERVER_WORLD_BOSS_TOP      = Protocol.S_2_C_CROSS_SERVER_WORLD_BOSS_BASE + 100

Protocol.S_2_C_GENERAL_SCHOOL_CHILD_BASE        = Protocol.S_2_C_CROSS_SERVER_WORLD_BOSS_TOP + 0    --28500
Protocol.S_2_C_GENERAL_SCHOOL_CHILD_TOP         = Protocol.S_2_C_GENERAL_SCHOOL_CHILD_BASE + 100

Protocol.S_2_C_CROP2_BASE                       = Protocol.S_2_C_GENERAL_SCHOOL_CHILD_TOP + 0     --28600
Protocol.S_2_C_CROP2_TOP                        = Protocol.S_2_C_CROP2_BASE + 100

Protocol.S_2_C_RELATION_BASE                    = Protocol.S_2_C_CROP2_TOP + 0    --28700
Protocol.S_2_C_RELATION_TOP                     = Protocol.S_2_C_RELATION_BASE + 100

Protocol.S_2_C_PASSCARD_BASE                    = 28800
Protocol.S_2_C_PASSCARD_TOP                     = Protocol.S_2_C_PASSCARD_BASE + 100

Protocol.S_2_C_RANDOM_EVENT_BASE                = 28900
Protocol.S_2_C_RANDOM_EVENT_TOP                 = Protocol.S_2_C_RANDOM_EVENT_BASE + 100

Protocol.S_2_C_DRILL_GROUND_BASE                = Protocol.S_2_C_RANDOM_EVENT_TOP + 0
Protocol.S_2_C_DRILL_GROUND_TOP                 = Protocol.S_2_C_DRILL_GROUND_BASE + 100

Protocol.S_2_C_CAMPAIGN_BASE                    = 29100
Protocol.S_2_C_CAMPAIGN_TOP                     = Protocol.S_2_C_CAMPAIGN_BASE + 100

cc.exports.Protocol         = Protocol