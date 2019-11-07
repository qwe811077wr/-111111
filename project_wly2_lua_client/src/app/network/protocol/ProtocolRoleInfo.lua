local Protocol = cc.exports.Protocol or {}

Protocol.MAX_SKILL_TYPE = 5

Protocol.C_2_S_MASTER_LOAD_ALL_INFO               = Protocol.C_2_S_MASTER_BASE + 0
Protocol.C_2_S_MASTER_SET_HEAD_PORTRAIT           = Protocol.C_2_S_MASTER_BASE + 6

Protocol.S_2_C_MASTER_LOAD_ALL_INFO               = Protocol.S_2_C_MASTER_BASE + 0
Protocol.S_2_C_MASTER_LEVEL_UP_NOTIFY             = Protocol.S_2_C_MASTER_BASE + 1
Protocol.S_2_C_MASTER_LOAD_EXP                    = Protocol.S_2_C_MASTER_BASE + 3
Protocol.S_2_C_MASTER_SEND_IMG                    = Protocol.S_2_C_MASTER_BASE + 7
------------------------------C_2_S------------------------------
Protocol.Packet_C2S_MasterSetHeadPortrait = {
    img_type                            = {type = Protocol.DataType.short},
    img_id                              = {type = Protocol.DataType.int},
    fields                              = {'img_type','img_id'}
}
Protocol.structs[Protocol.C_2_S_MASTER_SET_HEAD_PORTRAIT]                    = Protocol.Packet_C2S_MasterSetHeadPortrait
------------------------------S_2_C------------------------------
Protocol.Data_LevelUpInfo = {
    level       = {type = Protocol.DataType.short},
    count       = {type = Protocol.DataType.short},
    reward      = {type = Protocol.DataType.object, length = -1, clazz='Packet_Data_RewardType'},
    fields = {'level','count','reward'}
}

Protocol.Packet_S2C_MasterLoadAllInfo = {
    characLvl                       = {type = Protocol.DataType.short},
    masterLvl                       = {type = Protocol.DataType.short},
    exp                             = {type = Protocol.DataType.int},
    power                           = {type = Protocol.DataType.int},
    fields                          = {'characLvl','masterLvl','exp','power'}
}
Protocol.structs[Protocol.S_2_C_MASTER_LOAD_ALL_INFO]      = Protocol.Packet_S2C_MasterLoadAllInfo

Protocol.Packet_S2C_LoadMasterExp = {
    lvl                             = {type = Protocol.DataType.short},
    exp                             = {type = Protocol.DataType.int},
    fields                          = {'lvl','exp'}
}
Protocol.structs[Protocol.S_2_C_MASTER_LOAD_EXP]      = Protocol.Packet_S2C_LoadMasterExp

Protocol.Packet_S2C_MasterLevelUpNotify = {
    level_count                     = {type = Protocol.DataType.short},
    level_up                        = {type = Protocol.DataType.object, length = -1, clazz='Data_LevelUpInfo'},
    fields                          = {'level_count','level_up'}
}
Protocol.structs[Protocol.S_2_C_MASTER_LEVEL_UP_NOTIFY]      = Protocol.Packet_S2C_MasterLevelUpNotify

Protocol.Packet_S2C_MasterSendImg = {
    img_type                            = {type = Protocol.DataType.short},
    img_id                              = {type = Protocol.DataType.int},
    fields                              = {'img_type','img_id'}
}
Protocol.structs[Protocol.S_2_C_MASTER_SEND_IMG]      = Protocol.Packet_S2C_MasterSendImg