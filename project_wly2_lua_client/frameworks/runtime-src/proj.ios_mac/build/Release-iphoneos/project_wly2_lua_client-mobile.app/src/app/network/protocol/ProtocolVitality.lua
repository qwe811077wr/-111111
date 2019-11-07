local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_LIVENESS_LOAD                        = Protocol.C_2_S_LIVENESS_BASE + 1
Protocol.C_2_S_LIVENESS_DRAW_REWARD                 = Protocol.C_2_S_LIVENESS_BASE + 3
Protocol.C_2_S_LIVENESS_DRAW_CREDIT                 = Protocol.C_2_S_LIVENESS_BASE + 5



Protocol.S_2_C_LIVENESS_LOAD                        = Protocol.S_2_C_LIVENESS_BASE + 2
Protocol.S_2_C_LIVENESS_LIST                        = Protocol.S_2_C_LIVENESS_BASE + 4
Protocol.S_2_C_LIVENESS_DRAW_REWARD                 = Protocol.S_2_C_LIVENESS_BASE + 6
Protocol.S_2_C_LIVENESS_DRAW_CREDIT                 = Protocol.S_2_C_LIVENESS_BASE + 8


------------------------------C_2_S------------------------------
Protocol.Packet_C2S_LoadVitality = {
    fields                      = {}
}
Protocol.structs[Protocol.C_2_S_LIVENESS_LOAD]                          = Protocol.Packet_C2S_LoadVitality

Protocol.Packet_C2S_TakeCheckinReward = {
    ident                        = {type = Protocol.DataType.short},
    fields                       = {'ident'}
}
Protocol.structs[Protocol.C_2_S_LIVENESS_DRAW_REWARD]           = Protocol.Packet_C2S_TakeCheckinReward

Protocol.Packet_C2S_TaskReward = {
    ident                       = {type = Protocol.DataType.int},
    fields                      = {'ident'}
}
Protocol.structs[Protocol.C_2_S_LIVENESS_DRAW_CREDIT]                   = Protocol.Packet_C2S_TaskReward

------------------------------S_2_C------------------------------
Protocol.Packet_Data_VitalityItem = {
    id                          = {type = Protocol.DataType.short},
    state                       = {type = Protocol.DataType.short},
    number                      = {type = Protocol.DataType.short},
    fields                      = {'id','state','number'}
}

Protocol.Packet_S2C_VitalityInfo = {
    credit                      = {type = Protocol.DataType.int},
    count                       = {type = Protocol.DataType.short},
    numbers                     = {type = Protocol.DataType.short, length = -1},
    fields                      = {'credit','count','numbers'}
}
Protocol.structs[Protocol.S_2_C_LIVENESS_LOAD]                          = Protocol.Packet_S2C_VitalityInfo

Protocol.Packet_S2C_VitalityList = {
    count                       = {type = Protocol.DataType.short},
    items                       = {type = Protocol.DataType.object, length = -1, clazz = "Packet_Data_VitalityItem"},
    fields                      = {'count', 'items'}
}
Protocol.structs[Protocol.S_2_C_LIVENESS_LIST]                          = Protocol.Packet_S2C_VitalityList

Protocol.Packet_S2C_VitalityTaskReward = {
    ret                         = {type = Protocol.DataType.short},
    ident                       = {type = Protocol.DataType.short},
    fields                      = {'ret', 'ident'}
}
Protocol.structs[Protocol.S_2_C_LIVENESS_DRAW_CREDIT]                   = Protocol.Packet_S2C_VitalityTaskReward

Protocol.Packet_S2C_VitalityTakeReward = {
    ret                         = {type = Protocol.DataType.short},
    ident                       = {type = Protocol.DataType.short},
    credit                      = {type = Protocol.DataType.int},
    fields                      = {'ret', 'ident', 'credit'}
}
Protocol.structs[Protocol.S_2_C_LIVENESS_DRAW_REWARD]                   = Protocol.Packet_S2C_VitalityTakeReward