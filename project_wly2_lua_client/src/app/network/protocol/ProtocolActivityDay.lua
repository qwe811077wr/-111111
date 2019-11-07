local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_ACTIVITY_ROTARY_DRAW_THIRD_CFG         = Protocol.C_2_S_ACTIVITY_DAY_BASE + 1
Protocol.C_2_S_ACTIVITY_WELFARE_REWARD                = Protocol.C_2_S_ACTIVITY_DAY_BASE + 2
Protocol.C_2_S_ACTIVITY_INSTANCE_INFO                 = Protocol.C_2_S_ACTIVITY_DAY_BASE + 3
Protocol.C_2_S_ACTIVITY_DRAW_REWARD                   = Protocol.C_2_S_ACTIVITY_DAY_BASE + 4
Protocol.C_2_S_ACTIVITY_PAY_REWARD                    = Protocol.C_2_S_ACTIVITY_DAY_BASE + 5
Protocol.C_2_S_ACTIVITY_PAY_REWARD_RECEIVE            = Protocol.C_2_S_ACTIVITY_DAY_BASE + 6
Protocol.C_2_S_ACTIVITY_ROTARY_DRAW_LOAD              = Protocol.C_2_S_ACTIVITY_DAY_BASE + 7
Protocol.C_2_S_ACTIVITY_MASTER_LV_TARGET_REWARD       = Protocol.C_2_S_ACTIVITY_DAY_BASE + 8
Protocol.C_2_S_ACTIVITY_ROTARY_DRAW_TIMES             = Protocol.C_2_S_ACTIVITY_DAY_BASE + 9
Protocol.C_2_S_ACTIVITY_ROTARY_DRAW_THIRD             = Protocol.C_2_S_ACTIVITY_DAY_BASE + 10
Protocol.C_2_S_ACTIVITY_DAILY_REWARD_DRAW             = Protocol.C_2_S_ACTIVITY_DAY_BASE + 11
Protocol.C_2_S_ACTIVITY_ROTARY_DRAW_OPEN_CHEST        = Protocol.C_2_S_ACTIVITY_DAY_BASE + 12
Protocol.C_2_S_ACTIVITY_INFO                          = Protocol.C_2_S_ACTIVITY_DAY_BASE + 13
Protocol.C_2_S_ACTIVITY_LV_TARGET_REWARD              = Protocol.C_2_S_ACTIVITY_DAY_BASE + 14
Protocol.C_2_S_ACTIVITY_PRESTIGE_TARGET_REWARD        = Protocol.C_2_S_ACTIVITY_DAY_BASE + 15
Protocol.C_2_S_ACTIVITY_LV_RANK_REWARD                = Protocol.C_2_S_ACTIVITY_DAY_BASE + 16
Protocol.C_2_S_ACTIVITY_POWER_RANK_REWARD             = Protocol.C_2_S_ACTIVITY_DAY_BASE + 17
Protocol.C_2_S_ACTIVITY_TOWER_RANK_REWARD             = Protocol.C_2_S_ACTIVITY_DAY_BASE + 18
Protocol.C_2_S_ACTIVITY_LOGIN_DAY_REWARD              = Protocol.C_2_S_ACTIVITY_DAY_BASE + 19



Protocol.S_2_C_ACTIVITY_DAY                          = Protocol.S_2_C_ACTIVITY_DAY_BASE + 1
Protocol.S_2_C_ACTIVITY_SPEAKER_NUM                  = Protocol.S_2_C_ACTIVITY_DAY_BASE + 2
Protocol.S_2_C_ACTIVITY_WELFARE_REWARD               = Protocol.S_2_C_ACTIVITY_DAY_BASE + 3
Protocol.S_2_C_ACTIVITY_INSTANCE_INFO                = Protocol.S_2_C_ACTIVITY_DAY_BASE + 4
Protocol.S_2_C_ACTIVITY_USE_CHEST                    = Protocol.S_2_C_ACTIVITY_DAY_BASE + 5
Protocol.S_2_C_ACTIVITY_DAY_ITEM_DROP                = Protocol.S_2_C_ACTIVITY_DAY_BASE + 6
Protocol.S_2_C_ACTIVITY_PAY_REWARD                   = Protocol.S_2_C_ACTIVITY_DAY_BASE + 7
Protocol.S_2_C_ACTIVITY_PAY_REWARD_RECEIVE           = Protocol.S_2_C_ACTIVITY_DAY_BASE + 8
Protocol.S_2_C_ACTIVITY_ROTARY_DRAW_LOAD             = Protocol.S_2_C_ACTIVITY_DAY_BASE + 9
Protocol.S_2_C_ACTIVITY_ROTARY_DRAW                  = Protocol.S_2_C_ACTIVITY_DAY_BASE + 10
Protocol.S_2_C_ACTIVITY_ROTARY_DRAW_REMIND           = Protocol.S_2_C_ACTIVITY_DAY_BASE + 11
Protocol.S_2_C_ACTIVITY_ROTARY_DRAW_INFO             = Protocol.S_2_C_ACTIVITY_DAY_BASE + 12
Protocol.S_2_C_ACTIVITY_PAY_REWARD_APPSTORE          = Protocol.S_2_C_ACTIVITY_DAY_BASE + 13
Protocol.S_2_C_ACTIVITY_DAILY_REWARD_DRAW            = Protocol.S_2_C_ACTIVITY_DAY_BASE + 14
Protocol.S_2_C_ACTIVITY_INFO                         = Protocol.S_2_C_ACTIVITY_DAY_BASE + 15
Protocol.S_2_C_ACTIVITY_STATUS_INFO                  = Protocol.S_2_C_ACTIVITY_DAY_BASE + 16
Protocol.S_2_C_ACTIVITY_REWAERD_INFO                 = Protocol.S_2_C_ACTIVITY_DAY_BASE + 17
Protocol.S_2_C_ACTIVITY_ROTARY_DRAW_THIRD_LOAD       = Protocol.S_2_C_ACTIVITY_DAY_BASE + 18
Protocol.S_2_C_ACTIVITY_ROTARY_DRAW_THIRD            = Protocol.S_2_C_ACTIVITY_DAY_BASE + 19


------------------------------C_2_S------------------------------

------------------------------S_2_C------------------------------
Protocol.Packet_S2C_ActivityStatusInfo = {
    statusInfo          = {type = Protocol.DataType.int},
    activityType        = {type = Protocol.DataType.char},
    fields              = {'statusInfo','activityType'}
}
Protocol.structs[Protocol.S_2_C_ACTIVITY_STATUS_INFO]                    = Protocol.Packet_S2C_ActivityStatusInfo