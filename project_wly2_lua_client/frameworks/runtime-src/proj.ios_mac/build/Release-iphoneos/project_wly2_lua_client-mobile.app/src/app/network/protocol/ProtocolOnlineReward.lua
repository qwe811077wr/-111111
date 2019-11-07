local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_ONLINE_REWARD_INDEX                      = Protocol.C_2_S_ONLINE_REWARD_BASE + 0
Protocol.C_2_S_ONLINE_REWARD                            = Protocol.C_2_S_ONLINE_REWARD_BASE + 1
Protocol.C_2_S_ONLINE_REWARD_BETA_INDEX                 = Protocol.C_2_S_ONLINE_REWARD_BASE + 2
Protocol.C_2_S_DRAW_SEVEN_TASK_NUM_REWARD               = Protocol.C_2_S_ONLINE_REWARD_BASE + 3
Protocol.C_2_S_ONLINE_REWARD_FIRST_PAY                  = Protocol.C_2_S_ONLINE_REWARD_BASE + 4
Protocol.C_2_S_DRAW_ONLINE_REWARD                       = Protocol.C_2_S_ONLINE_REWARD_BASE + 5
Protocol.C_2_S_DRAW_VIP_REWARD                          = Protocol.C_2_S_ONLINE_REWARD_BASE + 6
Protocol.C_2_S_BUY_VIP_REWARD                           = Protocol.C_2_S_ONLINE_REWARD_BASE + 7
Protocol.C_2_S_DRAW_SEVEN_REWARD                        = Protocol.C_2_S_ONLINE_REWARD_BASE + 8
Protocol.C_2_S_SEVEN_TASK_INFO                          = Protocol.C_2_S_ONLINE_REWARD_BASE + 9
Protocol.C_2_S_ROLE_CHECKIN_LOAD                        = Protocol.C_2_S_ONLINE_REWARD_BASE + 10
Protocol.C_2_S_ROLE_CHECKIN                             = Protocol.C_2_S_ONLINE_REWARD_BASE + 11


Protocol.S_2_C_ONLINE_REWARD_INDEX                      = Protocol.S_2_C_ONLINE_REWARD_BASE + 0
Protocol.S_2_C_ONLINE_REWARD_OK                         = Protocol.S_2_C_ONLINE_REWARD_BASE + 1
Protocol.S_2_C_ONLINE_REWARD_STATUS                     = Protocol.S_2_C_ONLINE_REWARD_BASE + 2
Protocol.S_2_C_DRAW_ONLINE_REWARD                       = Protocol.S_2_C_ONLINE_REWARD_BASE + 3
Protocol.S_2_C_DRAW_VIP_REWARD                          = Protocol.S_2_C_ONLINE_REWARD_BASE + 4
Protocol.S_2_C_BUY_VIP_REWARD_INFO                      = Protocol.S_2_C_ONLINE_REWARD_BASE + 5
Protocol.S_2_C_DRAW_SEVEN_REWARD                        = Protocol.S_2_C_ONLINE_REWARD_BASE + 6
Protocol.S_2_C_SEVEN_TASK_INFO                          = Protocol.S_2_C_ONLINE_REWARD_BASE + 7
Protocol.S_2_C_DRAW_SEVEN_TASK_NUM_REWARD               = Protocol.S_2_C_ONLINE_REWARD_BASE + 8
Protocol.S_2_C_DRAW_SEVEN_TASK_NUM_INFO                 = Protocol.S_2_C_ONLINE_REWARD_BASE + 9
Protocol.S_2_C_ROLE_CHECKIN_LOAD                        = Protocol.S_2_C_ONLINE_REWARD_BASE + 10
Protocol.S_2_C_ROLE_CHECKIN                             = Protocol.S_2_C_ONLINE_REWARD_BASE + 11

------------------------------C_2_S------------------------------
Protocol.Packet_C2S_OnlineReward = {
    --C_2_S_ONLINE_REWARD
    rewardType          = {type = Protocol.DataType.int},
    fields              = {'rewardType'}
}
Protocol.structs[Protocol.C_2_S_ONLINE_REWARD]                  = Protocol.Packet_C2S_OnlineReward

Protocol.Packet_C2S_BuyVipReward = {
    vipLevel            = {type = Protocol.DataType.int},
    fields              = {'vipLevel'}
}
Protocol.structs[Protocol.C_2_S_BUY_VIP_REWARD]                 = Protocol.Packet_C2S_BuyVipReward

Protocol.Packet_C2S_RoleCheckin = {
    checkin_type        = {type = Protocol.DataType.short},
    fields              = {'checkin_type'}
}
Protocol.structs[Protocol.C_2_S_ROLE_CHECKIN]                 = Protocol.Packet_C2S_RoleCheckin
------------------------------S_2_C------------------------------

Protocol.Packet_S2C_OnlineRewardIndex = {
    --S_2_C_ONLINE_REWARD_INDEX
    rewardType          = {type = Protocol.DataType.int},
    ident               = {type = Protocol.DataType.int},
    leaveTime           = {type = Protocol.DataType.leaveTime},
    fields              = {'rewardType','ident','leaveTime'}
}
Protocol.structs[Protocol.S_2_C_ONLINE_REWARD_INDEX]            = Protocol.Packet_S2C_OnlineRewardIndex

Protocol.Packet_S2C_OnlineRewardOK = {
    --S_2_C_ONLINE_REWARD_OK
    rewardType          = {type = Protocol.DataType.int},
    ident               = {type = Protocol.DataType.int},
    fields              = {'rewardType','ident'}
}
Protocol.structs[Protocol.S_2_C_ONLINE_REWARD_OK]               = Protocol.Packet_S2C_OnlineRewardOK

Protocol.Packet_S2C_OnlineRewardStatus = {
    --S_2_C_ONLINE_REWARD_STATUS
    minute              = {type = Protocol.DataType.int},
    online_second       = {type = Protocol.DataType.int},
    fields              = {'minute','online_second'}
}
Protocol.structs[Protocol.S_2_C_ONLINE_REWARD_STATUS]           = Protocol.Packet_S2C_OnlineRewardStatus

Protocol.Packet_S2C_DrawOnlineReward = {
    --S_2_C_DRAW_ONLINE_REWARD
    minute              = {type = Protocol.DataType.int},
    fields              = {'minute'}
}
Protocol.structs[Protocol.S_2_C_DRAW_ONLINE_REWARD]             = Protocol.Packet_S2C_DrawOnlineReward

Protocol.Packet_S2C_DrawOnlineVipReward = {
    --S_2_C_DRAW_VIP_REWARD
    vipLv               = {type = Protocol.DataType.int},
    fields              = {'vipLv'}
}
Protocol.structs[Protocol.S_2_C_DRAW_VIP_REWARD]                = Protocol.Packet_S2C_DrawOnlineVipReward

Protocol.Packet_S2C_BuyVipRewardInfo = {
    --S_2_C_BUY_VIP_REWARD_INFO
    rewardInfo          = {type = Protocol.DataType.int},
    fields              = {'rewardInfo'}
}
Protocol.structs[Protocol.S_2_C_BUY_VIP_REWARD_INFO]            = Protocol.Packet_S2C_BuyVipRewardInfo

Protocol.Packet_S2C_DrawSevenReward = {
    --S_2_C_DRAW_SEVEN_REWARD
    day                 = {type = Protocol.DataType.int},
    taskId              = {type = Protocol.DataType.int},
    fields              = {'day','taskId'}
}
Protocol.structs[Protocol.S_2_C_DRAW_SEVEN_REWARD]              = Protocol.Packet_S2C_DrawSevenReward

Protocol.Data_SevenTask = {
    id                  = {type = Protocol.DataType.int},
    value               = {type = Protocol.DataType.int},
    fields              = {'id','value'}
}

Protocol.Packet_S2C_DrawSevenTaskInfo = {
    --S_2_C_SEVEN_TASK_INFO
    endTime             = {type = Protocol.DataType.int},
    day                 = {type = Protocol.DataType.int},
    count               = {type = Protocol.DataType.int},
    sevenTask           = {type = Protocol.DataType.object, length = -1,clazz='Data_SevenTask'},
    fields              = {'endTime','day','count','sevenTask'}
}
Protocol.structs[Protocol.S_2_C_SEVEN_TASK_INFO]                = Protocol.Packet_S2C_DrawSevenTaskInfo

Protocol.Packet_S2C_DrawSevenTaskNumReward = {
    --S_2_C_DRAW_SEVEN_TASK_NUM_REWARD
    taskNum             = {type = Protocol.DataType.int},
    fields              = {'taskNum'}
}
Protocol.structs[Protocol.S_2_C_DRAW_SEVEN_TASK_NUM_REWARD]     = Protocol.Packet_S2C_DrawSevenTaskNumReward

Protocol.Packet_S2C_DrawSevenTaskNumInfo = {
    --S_2_C_DRAW_SEVEN_TASK_NUM_INFO
    count               = {type = Protocol.DataType.int},
    drawTaskNum         = {type = Protocol.DataType.int, length = -1},
    fields              = {'count','drawTaskNum'}
}
Protocol.structs[Protocol.S_2_C_DRAW_SEVEN_TASK_NUM_INFO]       = Protocol.Packet_S2C_DrawSevenTaskNumInfo

Protocol.Packet_S2C_RoleCheckinLoad = {
    cycle_id            = {type = Protocol.DataType.short},
    is_checkin          = {type = Protocol.DataType.short},
    checkin_id          = {type = Protocol.DataType.short},
    repair_times        = {type = Protocol.DataType.short},
    surplus_times       = {type = Protocol.DataType.int},
    fields              = {'cycle_id','is_checkin','checkin_id','repair_times','surplus_times'}
}
Protocol.structs[Protocol.S_2_C_ROLE_CHECKIN_LOAD]       = Protocol.Packet_S2C_RoleCheckinLoad

Protocol.Packet_S2C_RoleCheckin = {
    --S_2_C_ROLE_CHECKIN
    ret                 = {type = Protocol.DataType.short},
    checkin_type        = {type = Protocol.DataType.short},
    cycle_id            = {type = Protocol.DataType.short},
    checkin_id          = {type = Protocol.DataType.short},
    repair_times        = {type = Protocol.DataType.short},
    fields              = {'ret','checkin_type','cycle_id','checkin_id','repair_times'}
}
Protocol.structs[Protocol.S_2_C_ROLE_CHECKIN]       = Protocol.Packet_S2C_RoleCheckin