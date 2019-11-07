local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_EXTREME_VIP_REWARD_DRAW                  = Protocol.C_2_S_EXTREME_VIP_BASE + 0
Protocol.C_2_S_EXTREME_VIP_BUY                          = Protocol.C_2_S_EXTREME_VIP_BASE + 1
Protocol.C_2_S_TENCENT_VIP_REWARD                       = Protocol.C_2_S_EXTREME_VIP_BASE + 2
Protocol.C_2_S_USE_CASH_GIFT                            = Protocol.C_2_S_EXTREME_VIP_BASE + 3


Protocol.S_2_C_EXTREME_VIP_REWARD_DRAW                  = Protocol.S_2_C_EXTREME_VIP_BASE + 0
Protocol.S_2_C_EXTREME_VIP_BUY                          = Protocol.S_2_C_EXTREME_VIP_BASE + 1
Protocol.S_2_C_TENCENT_VIP_REWARD                       = Protocol.S_2_C_EXTREME_VIP_BASE + 2
Protocol.S_2_C_TENCENT_VIP_INFO                         = Protocol.S_2_C_EXTREME_VIP_BASE + 3
Protocol.S_2_C_USE_CASH_GIFT                            = Protocol.S_2_C_EXTREME_VIP_BASE + 4


------------------------------C_2_S------------------------------
Protocol.Packet_C2S_ExtremeVipBuy = {
    ident               = {type = Protocol.DataType.int},
    fields              = {'ident'}
}
Protocol.structs[Protocol.C_2_S_EXTREME_VIP_BUY]                  = Protocol.Packet_C2S_ExtremeVipBuy

Protocol.Packet_C2S_TencentVipReward = {
    vipLevel            = {type = Protocol.DataType.int},
    rewardType          = {type = Protocol.DataType.int},
    fields              = {'vipLevel','rewardType'}
}
Protocol.structs[Protocol.C_2_S_TENCENT_VIP_REWARD]                = Protocol.Packet_C2S_TencentVipReward

------------------------------S_2_C------------------------------
Protocol.Packet_S2C_ExtremeVipBuy = {
    ident               = {type = Protocol.DataType.int},
    fields              = {'ident'}
}
Protocol.structs[Protocol.S_2_C_EXTREME_VIP_BUY]                    = Protocol.Packet_S2C_ExtremeVipBuy

Protocol.Packet_S2C_TencentVipReward = {
    vipLevel            = {type = Protocol.DataType.int},
    rewardType          = {type = Protocol.DataType.int},
    fields              = {'vipLevel','rewardType'}
}
Protocol.structs[Protocol.S_2_C_TENCENT_VIP_REWARD]                = Protocol.Packet_S2C_TencentVipReward

Protocol.Packet_S2C_TencentVipInfo = {
    dailyReward         = {type = Protocol.DataType.int},
    yearReward          = {type = Protocol.DataType.int},
    fields              = {'dailyReward','yearReward'}
}
Protocol.structs[Protocol.S_2_C_TENCENT_VIP_INFO]                   = Protocol.Packet_S2C_TencentVipInfo

Protocol.Packet_S2C_UseCashGift = {
    cashGift            = {type = Protocol.DataType.int},
    vip                 = {type = Protocol.DataType.int},
    fields              = {'cashGift','vip'}
}
Protocol.structs[Protocol.S_2_C_USE_CASH_GIFT]                      = Protocol.Packet_S2C_UseCashGift