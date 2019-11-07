local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_PASSCARD_INFO_LOAD                = Protocol.C_2_S_PASSCARD_BASE + 1
Protocol.C_2_S_PASSCARD_CHECKIN                  = Protocol.C_2_S_PASSCARD_BASE + 2
Protocol.C_2_S_PASSCARDTASK_DRAW_REWARD          = Protocol.C_2_S_PASSCARD_BASE + 3
Protocol.C_2_S_PASSCARDTASK_LIVENESS_DRAW_REWARD = Protocol.C_2_S_PASSCARD_BASE + 4
Protocol.C_2_S_PASSCARD_LEVEL_DRAW_REWARD        = Protocol.C_2_S_PASSCARD_BASE + 5
Protocol.C_2_S_PASSCARD_BUY_LEVEL                = Protocol.C_2_S_PASSCARD_BASE + 6
Protocol.C_2_S_PASSCARD_GET_CHECKIN_REWARD       = Protocol.C_2_S_PASSCARD_BASE + 7
Protocol.C_2_S_PASSCARD_STONE_LOAD               = Protocol.C_2_S_PASSCARD_BASE + 8
Protocol.C_2_S_PASSCARD_STONE_BUY                = Protocol.C_2_S_PASSCARD_BASE + 9
Protocol.C_2_S_PASSCARD_LEVEL_ONEKEY_DRAW_REWARD = Protocol.C_2_S_PASSCARD_BASE + 10
Protocol.C_2_S_PASSCARD_ACTIVATE                 = Protocol.C_2_S_PASSCARD_BASE + 11
Protocol.C_2_S_PASSCARD_ACCEPT_TASK              = Protocol.C_2_S_PASSCARD_BASE + 12
Protocol.C_2_S_PASSCARD_ABANDON_TASK             = Protocol.C_2_S_PASSCARD_BASE + 13
Protocol.C_2_S_PASSCARD_REFRESH_TASK             = Protocol.C_2_S_PASSCARD_BASE + 14
Protocol.C_2_S_PASSCARD_DRAW_DAILY_FREE_GIFT     = Protocol.C_2_S_PASSCARD_BASE + 15

Protocol.S_2_C_PASSCARD_INFO_LOAD                = Protocol.S_2_C_PASSCARD_BASE + 1
Protocol.S_2_C_PASSCARD_CHECKIN                  = Protocol.S_2_C_PASSCARD_BASE + 2
Protocol.S_2_C_PASSCARD_TASK_UPDATE              = Protocol.S_2_C_PASSCARD_BASE + 3
Protocol.S_2_C_PASSCARDTASK_DRAW_REWARD          = Protocol.S_2_C_PASSCARD_BASE + 4
Protocol.S_2_C_PASSCARDTASK_LIVENESS_DRAW_REWARD = Protocol.S_2_C_PASSCARD_BASE + 5
Protocol.S_2_C_PASSCARD_LEVEL_DRAW_REWARD        = Protocol.S_2_C_PASSCARD_BASE + 6
Protocol.S_2_C_PASSCARD_BUY_LEVEL                = Protocol.S_2_C_PASSCARD_BASE + 7
Protocol.S_2_C_PASSCARD_GET_CHECKIN_REWARD       = Protocol.S_2_C_PASSCARD_BASE + 8
Protocol.S_2_C_PASSCARD_UPDATE_INFO              = Protocol.S_2_C_PASSCARD_BASE + 9
Protocol.S_2_C_PASSCARD_STONE_LOAD               = Protocol.S_2_C_PASSCARD_BASE + 10
Protocol.S_2_C_PASSCARD_STONE_BUY                = Protocol.S_2_C_PASSCARD_BASE + 11
Protocol.S_2_C_PASSCARD_UPDATE_LEVEL             = Protocol.S_2_C_PASSCARD_BASE + 12
Protocol.S_2_C_PASSCARD_LEVEL_ONEKEY_DRAW_REWARD = Protocol.S_2_C_PASSCARD_BASE + 13
Protocol.S_2_C_PASSCARD_ACTIVATE                 = Protocol.S_2_C_PASSCARD_BASE + 14
Protocol.S_2_C_PASSCARD_ACCEPT_TASK              = Protocol.S_2_C_PASSCARD_BASE + 15
Protocol.S_2_C_PASSCARD_ABANDON_TASK             = Protocol.S_2_C_PASSCARD_BASE + 16
Protocol.S_2_C_PASSCARD_REFRESH_TASK             = Protocol.S_2_C_PASSCARD_BASE + 17
Protocol.S_2_C_PASSCARD_DRAW_DAILY_FREE_GIFT     = Protocol.S_2_C_PASSCARD_BASE + 18

Protocol.Packet_C2S_PasscardInfoLoad = {
    fields = {}
}
Protocol.structs[Protocol.C_2_S_PASSCARD_INFO_LOAD] = Protocol.Packet_C2S_PasscardInfoLoad

Protocol.Data_PasscardInfo = {
    id     = {type = Protocol.DataType.short},
    num    = {type = Protocol.DataType.short},
    fields = {'id', 'num'}
}

Protocol.Data_PasscardCheckinInfo = {
    id     = {type = Protocol.DataType.short},
    state  = {type = Protocol.DataType.short},
    num    = {type = Protocol.DataType.short},
    fields = {'id','state','num'}
}

Protocol.Packet_S2C_PasscardInfoLoad = {
    season_id                  = {type = Protocol.DataType.int},
    begin_time                 = {type = Protocol.DataType.int},
    level                      = {type = Protocol.DataType.short},
    exp                        = {type = Protocol.DataType.int},
    liveness                   = {type = Protocol.DataType.int},
    state                      = {type = Protocol.DataType.short},    -- 0 未激活，1激活
    last_checkin_time          = {type = Protocol.DataType.int},
    checkin_idx                = {type = Protocol.DataType.short},
    repair_times               = {type = Protocol.DataType.short},
    left_repair_nums           = {type = Protocol.DataType.short},
    can_checkin                = {type = Protocol.DataType.char}, -- 0 已签到，1 未签到
    left_reward_count          = {type = Protocol.DataType.short},
    left_reward                = {type = Protocol.DataType.short, length = -1},
    liviness_count             = {type = Protocol.DataType.short},
    liviness_gift              = {type = Protocol.DataType.short, length = -1},
    free_gift_count            = {type = Protocol.DataType.short},
    free_gift                  = {type = Protocol.DataType.short, length = -1},
    pass_gift_count            = {type = Protocol.DataType.short},
    pass_gift                  = {type = Protocol.DataType.short, length = -1},
    daily_gift_count           = {type = Protocol.DataType.short},
    daily_gift                 = {type = Protocol.DataType.object, length = -1, clazz = 'Data_PasscardInfo'},
    spec_gift_count            = {type = Protocol.DataType.short},
    spec_gift                  = {type = Protocol.DataType.object, length = -1, clazz = 'Data_PasscardInfo'},
    daily_free_gift            = {type = Protocol.DataType.short},
    task_num                   = {type = Protocol.DataType.short},
    task_refresh_nums          = {type = Protocol.DataType.short},
    checkin_activated          = {type = Protocol.DataType.short},
    fields                     = {'season_id','begin_time','level','exp','liveness','state','last_checkin_time'
                                ,'checkin_idx','repair_times','left_repair_nums','can_checkin','left_reward_count'
                                ,'left_reward','liviness_count','liviness_gift','free_gift_count'
                                ,'free_gift','pass_gift_count','pass_gift','daily_gift_count','daily_gift'
                                ,'spec_gift_count','spec_gift','daily_free_gift','task_num','task_refresh_nums','checkin_activated'}
}
Protocol.structs[Protocol.S_2_C_PASSCARD_INFO_LOAD] = Protocol.Packet_S2C_PasscardInfoLoad

Protocol.Packet_C2S_PasscardCheckin = {
    checkin_type = {type = Protocol.DataType.short},
    fields       = {'checkin_type'}
}
Protocol.structs[Protocol.C_2_S_PASSCARD_CHECKIN] = Protocol.Packet_C2S_PasscardCheckin

Protocol.Packet_S2C_PasscardCheckin = {
    ret                     = {type = Protocol.DataType.short},
    checkin_type            = {type = Protocol.DataType.short},
    checkin_day             = {type = Protocol.DataType.short},
    repair_times            = {type = Protocol.DataType.short},
    last_checkin_time       = {type = Protocol.DataType.int},
    passcard_state          = {type = Protocol.DataType.short},
    left_repair_nums        = {type = Protocol.DataType.short},
    can_checkin             = {type = Protocol.DataType.char},
    fields                  = {'ret','checkin_type','checkin_day','repair_times','last_checkin_time','passcard_state','left_repair_nums','can_checkin'}
}
Protocol.structs[Protocol.S_2_C_PASSCARD_CHECKIN] = Protocol.Packet_S2C_PasscardCheckin

Protocol.Data_PasscardTaskItem = {
    id     = {type = Protocol.DataType.short},
    state  = {type = Protocol.DataType.short},
    num    = {type = Protocol.DataType.int},
    fields = {'id','state','num'}
}
Protocol.Packet_S2C_PasscardTaskUpdate = {
    count            = {type = Protocol.DataType.short},
    items            = {type = Protocol.DataType.object, length = -1, clazz = 'Data_PasscardTaskItem'},
    fields           = {'count','items'}
}
Protocol.structs[Protocol.S_2_C_PASSCARD_TASK_UPDATE] = Protocol.Packet_S2C_PasscardTaskUpdate

Protocol.Packet_C2S_PasscardTaskDrawReward = {
    id               = {type = Protocol.DataType.short},
    fields           = {'id'}
}
Protocol.structs[Protocol.C_2_S_PASSCARDTASK_DRAW_REWARD] = Protocol.Packet_C2S_PasscardTaskDrawReward

Protocol.Packet_S2C_PasscardTaskDrawReward = {
    ret             = {type = Protocol.DataType.short},
    id              = {type = Protocol.DataType.short},
    liveness        = {type = Protocol.DataType.int},
    fields          = {'ret','id','liveness'}
}
Protocol.structs[Protocol.S_2_C_PASSCARDTASK_DRAW_REWARD] = Protocol.Packet_S2C_PasscardTaskDrawReward

Protocol.Packet_C2S_PasscardTaskLivenessDrawReward = {
    id     = {type = Protocol.DataType.short},
    fields = {'id'}
}
Protocol.structs[Protocol.C_2_S_PASSCARDTASK_LIVENESS_DRAW_REWARD] = Protocol.Packet_C2S_PasscardTaskLivenessDrawReward

Protocol.Packet_S2C_PasscardTaskLivenessDrawReward = {
    ret    = {type = Protocol.DataType.short},
    id     = {type = Protocol.DataType.short},
    fields = {'ret','id'}
}
Protocol.structs[Protocol.S_2_C_PASSCARDTASK_LIVENESS_DRAW_REWARD] = Protocol.Packet_S2C_PasscardTaskLivenessDrawReward

Protocol.Packet_C2S_PasscardLevelDrawReward = {
    id        = {type = Protocol.DataType.short},    -- level
    drawtype  = {type = Protocol.DataType.short},     -- 1,free 2,passcard
    fields    = {'id','drawtype'}
}
Protocol.structs[Protocol.C_2_S_PASSCARD_LEVEL_DRAW_REWARD] = Protocol.Packet_C2S_PasscardLevelDrawReward

Protocol.Packet_S2C_PasscardLevelDrawReward = {
    ret       = {type = Protocol.DataType.short},
    id        = {type = Protocol.DataType.short},
    draw_type = {type = Protocol.DataType.short},
    fields    = {'ret','id','draw_type'}
}
Protocol.structs[Protocol.S_2_C_PASSCARD_LEVEL_DRAW_REWARD] = Protocol.Packet_S2C_PasscardLevelDrawReward

Protocol.Packet_C2S_PasscardBuyLevel = {
    id        = {type = Protocol.DataType.short},
    fields    = {'id'}
}
Protocol.structs[Protocol.C_2_S_PASSCARD_BUY_LEVEL] = Protocol.Packet_C2S_PasscardBuyLevel

Protocol.Packet_S2C_PasscardBuyLevel = {
    ret       = {type = Protocol.DataType.short},
    id        = {type = Protocol.DataType.short},
    fields    = {'ret','id'}
}
Protocol.structs[Protocol.S_2_C_PASSCARD_BUY_LEVEL] = Protocol.Packet_S2C_PasscardBuyLevel

Protocol.Packet_C2S_PasscardGetCheckinReward = {
    id        = {type = Protocol.DataType.short},
    fields    = {'id'}
}
Protocol.structs[Protocol.C_2_S_PASSCARD_GET_CHECKIN_REWARD] = Protocol.Packet_C2S_PasscardGetCheckinReward

Protocol.Packet_S2C_PasscardGetCheckinReward = {
    ret       = {type = Protocol.DataType.short},
    id        = {type = Protocol.DataType.short},
    fields    = {'ret','id'}
}
Protocol.structs[Protocol.S_2_C_PASSCARD_GET_CHECKIN_REWARD] = Protocol.Packet_S2C_PasscardGetCheckinReward

Protocol.Packet_S2C_PasscardUpdateInfo = {
    daily_gift_count = {type = Protocol.DataType.short},
    daily_gift       = {type = Protocol.DataType.object, length = -1, clazz = 'Data_PasscardInfo'},
    spec_gift_count  = {type = Protocol.DataType.short},
    spec_gift        = {type = Protocol.DataType.object, length = -1, clazz = 'Data_PasscardInfo'},
    fields           = {'daily_gift_count','daily_gift','spec_gift_count','spec_gift'}
}
Protocol.structs[Protocol.S_2_C_PASSCARD_UPDATE_INFO] = Protocol.Packet_S2C_PasscardUpdateInfo

Protocol.Data_PasscardStoneItems = {
    id            = {type = Protocol.DataType.int},
    num           = {type = Protocol.DataType.short},
    fields        = {'id','num'}
}

Protocol.Packet_S2C_PasscardStoneLoad = {
    count            = {type = Protocol.DataType.short},
    items            = {type = Protocol.DataType.object, length = -1, clazz = 'Data_PasscardStoneItems'},
    fields           = {'count','items'}
}
Protocol.structs[Protocol.S_2_C_PASSCARD_STONE_LOAD] = Protocol.Packet_S2C_PasscardStoneLoad

Protocol.Packet_C2S_PasscardStoneBuy = {
    id               = {type = Protocol.DataType.short},
    num              = {type = Protocol.DataType.short},
    fields           = {'id','num'}
}
Protocol.structs[Protocol.C_2_S_PASSCARD_STONE_BUY] = Protocol.Packet_C2S_PasscardStoneBuy

Protocol.Packet_S2C_PasscardStoneBuy = {
    ret              = {type = Protocol.DataType.short},
    id               = {type = Protocol.DataType.short},
    num              = {type = Protocol.DataType.short},
    fields           = {'ret','id','num'}
}
Protocol.structs[Protocol.S_2_C_PASSCARD_STONE_BUY] = Protocol.Packet_S2C_PasscardStoneBuy

Protocol.Packet_S2C_PasscardUpdateLevel = {
    level            = {type = Protocol.DataType.short},
    exp              = {type = Protocol.DataType.int},
    state            = {type = Protocol.DataType.short}, -- 0 未激活，1 激活
    fields           = {'level','exp','state'}
}
Protocol.structs[Protocol.S_2_C_PASSCARD_UPDATE_LEVEL] = Protocol.Packet_S2C_PasscardUpdateLevel

Protocol.Packet_S2C_PasscardLevelOneKeyDrawReward = {
    is_over         = {type = Protocol.DataType.char},
    count           = {type = Protocol.DataType.short},
    rwds            = {type = Protocol.DataType.object, length = -1, clazz='Packet_Data_RewardType'},
    fields          = {'is_over','count','rwds'}
}
Protocol.structs[Protocol.S_2_C_PASSCARD_LEVEL_ONEKEY_DRAW_REWARD] = Protocol.Packet_S2C_PasscardLevelOneKeyDrawReward

Protocol.Packet_S2C_PasscardActivate = {
    ret    = {type = Protocol.DataType.short},
    fields = {'ret'}
}
Protocol.structs[Protocol.S_2_C_PASSCARD_ACTIVATE] = Protocol.Packet_S2C_PasscardActivate

Protocol.Packet_C2S_PasscardAcceptTask = {
    id     = {type = Protocol.DataType.short},
    fields = {'id'}
}
Protocol.structs[Protocol.C_2_S_PASSCARD_ACCEPT_TASK] = Protocol.Packet_C2S_PasscardAcceptTask

Protocol.Packet_S2C_PasscardAcceptTask = {
    ret    = {type = Protocol.DataType.short},
    id     = {type = Protocol.DataType.short},
    fields = {'ret','id'}
}
Protocol.structs[Protocol.S_2_C_PASSCARD_ACCEPT_TASK] = Protocol.Packet_S2C_PasscardAcceptTask

Protocol.Packet_C2S_PasscardAbandonTask = {
    id     = {type = Protocol.DataType.short},
    fields = {'id'}
}
Protocol.structs[Protocol.C_2_S_PASSCARD_ABANDON_TASK] = Protocol.Packet_C2S_PasscardAbandonTask

Protocol.Packet_S2C_PasscardAbandonTask = {
    ret    = {type = Protocol.DataType.short},
    id     = {type = Protocol.DataType.short},
    fields = {'ret','id'}
}
Protocol.structs[Protocol.S_2_C_PASSCARD_ABANDON_TASK] = Protocol.Packet_S2C_PasscardAbandonTask

Protocol.Packet_S2C_PasscardRefreshTask = {
    ret     = {type = Protocol.DataType.short},
    fields = {'ret'}
}
Protocol.structs[Protocol.S_2_C_PASSCARD_REFRESH_TASK] = Protocol.Packet_S2C_PasscardRefreshTask

Protocol.Packet_S2C_PasscardDrawDailyFreeGift = {
    ret    = {type = Protocol.DataType.short},
    state  = {type = Protocol.DataType.short},
    fields = {'ret','state'}
}
Protocol.structs[Protocol.S_2_C_PASSCARD_DRAW_DAILY_FREE_GIFT] = Protocol.Packet_S2C_PasscardDrawDailyFreeGift

