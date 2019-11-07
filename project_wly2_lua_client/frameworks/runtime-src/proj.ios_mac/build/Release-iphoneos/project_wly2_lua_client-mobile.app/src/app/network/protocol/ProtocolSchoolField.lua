local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_SCHOOL_FIELD_INFO             = Protocol.C_2_S_SCHOOL_FIELD_BASE + 0
Protocol.C_2_S_ADD_TRAIN_GENERAL             = Protocol.C_2_S_SCHOOL_FIELD_BASE + 1
Protocol.C_2_S_OVER_TRAIN_GENERAL            = Protocol.C_2_S_SCHOOL_FIELD_BASE + 2
Protocol.C_2_S_SUDDEN_FLIGHT                 = Protocol.C_2_S_SCHOOL_FIELD_BASE + 3
Protocol.C_2_S_ADD_TRAIN_SOLT                = Protocol.C_2_S_SCHOOL_FIELD_BASE + 4
Protocol.C_2_S_SET_MAIN_GENERAL              = Protocol.C_2_S_SCHOOL_FIELD_BASE + 5


Protocol.S_2_C_SCHOOL_FIELD_INFO             = Protocol.S_2_C_SCHOOL_FIELD_BASE + 0
Protocol.S_2_C_ADD_GENERAL_RES               = Protocol.S_2_C_SCHOOL_FIELD_BASE + 1
Protocol.S_2_C_OVER_GENERAL_RES              = Protocol.S_2_C_SCHOOL_FIELD_BASE + 2
Protocol.S_2_C_ADD_TRAINSOLT_RES             = Protocol.S_2_C_SCHOOL_FIELD_BASE + 3
Protocol.S_2_C_ADD_GENARAL_CRUITED           = Protocol.S_2_C_SCHOOL_FIELD_BASE + 4
Protocol.S_2_C_SUDDLEN_RES                   = Protocol.S_2_C_SCHOOL_FIELD_BASE + 5
Protocol.S_2_C_SET_MAIN_GENERAL              = Protocol.S_2_C_SCHOOL_FIELD_BASE + 6
Protocol.S_2_C_END_TRAINING                  = Protocol.S_2_C_SCHOOL_FIELD_BASE + 8


------------------------------C_2_S------------------------------
Protocol.Packet_C2S_SchoolFieldInfo = {
    fields          = {}
}
Protocol.structs[Protocol.C_2_S_SCHOOL_FIELD_INFO]              = Protocol.Packet_C2S_SchoolFieldInfo

Protocol.Packet_C2S_AddTrainGeneral = {
    general_id                  = {type = Protocol.DataType.int},
    train_type                  = {type = Protocol.DataType.char},
    train_time_type             = {type = Protocol.DataType.char},
    fields                      = {'general_id','train_type','train_time_type'}
}
Protocol.structs[Protocol.C_2_S_ADD_TRAIN_GENERAL]              = Protocol.Packet_C2S_AddTrainGeneral

Protocol.Packet_C2S_OverGeneralTrain = {
    general_id                  = {type = Protocol.DataType.int},
    fields                      = {'general_id'}
}
Protocol.structs[Protocol.C_2_S_OVER_TRAIN_GENERAL]          = Protocol.Packet_C2S_OverGeneralTrain

Protocol.Packet_C2S_SuddenFlight = {
    general_id                  = {type = Protocol.DataType.int},
    level                       = {type = Protocol.DataType.int},
    fields                      = {'general_id','level'}
}
Protocol.structs[Protocol.C_2_S_SUDDEN_FLIGHT]             = Protocol.Packet_C2S_SuddenFlight

Protocol.Packet_C2S_AddTrainSolt = {
    nums                        = {type = Protocol.DataType.char},
    fields                      = {'nums'}
}
Protocol.structs[Protocol.C_2_S_ADD_TRAIN_SOLT]                = Protocol.Packet_C2S_AddTrainSolt

Protocol.Packet_C2S_SetMainGeneral = {
    general_id                  = {type = Protocol.DataType.int},
    fields                      = {'general_id'}
}
Protocol.structs[Protocol.C_2_S_SET_MAIN_GENERAL]       = Protocol.Packet_C2S_SetMainGeneral

------------------------------S_2_C------------------------------

Protocol.Packet_S2C_SchoolFieldInfo = {
    train_num             = {type = Protocol.DataType.short},
    golden_sudden_fly_num = {type = Protocol.DataType.short},
    fields                = {'train_num', 'golden_sudden_fly_num'}
}
Protocol.structs[Protocol.S_2_C_SCHOOL_FIELD_INFO]           = Protocol.Packet_S2C_SchoolFieldInfo

Protocol.Packet_S2C_AddGeneralRes = {
    general_id                       = {type = Protocol.DataType.int},
    res                              = {type = Protocol.DataType.char},
    training_num                     = {type = Protocol.DataType.char},
    fields                           = {'general_id','res','training_num'}
}
Protocol.structs[Protocol.S_2_C_ADD_GENERAL_RES]            = Protocol.Packet_S2C_AddGeneralRes

Protocol.Packet_S2C_OverGeneralRes = {
    genaral_id                       = {type = Protocol.DataType.int},
    res                              = {type = Protocol.DataType.char},
    fields                           = {'genaral_id','res'}
}
Protocol.structs[Protocol.S_2_C_OVER_GENERAL_RES]            = Protocol.Packet_S2C_OverGeneralRes

Protocol.Packet_S2C_AddTrainSoltRes = {
    res                              = {type = Protocol.DataType.char},
    nums                             = {type = Protocol.DataType.char},
    fields                           = {'res','nums'}
}
Protocol.structs[Protocol.S_2_C_ADD_TRAINSOLT_RES]            = Protocol.Packet_S2C_AddTrainSoltRes

Protocol.Packet_S2C_AddCruitedGenaral = {
    genaral_id                       = {type = Protocol.DataType.int},
    fields                           = {'genaral_id'}
}
Protocol.structs[Protocol.S_2_C_ADD_GENARAL_CRUITED]                = Protocol.Packet_S2C_AddCruitedGenaral

Protocol.Packet_S2C_SuddlenRes = {
    genaral_id            = {type = Protocol.DataType.int},
    level                 = {type = Protocol.DataType.int},
    fields                = {'genaral_id','level'}
}
Protocol.structs[Protocol.S_2_C_SUDDLEN_RES]                 = Protocol.Packet_S2C_SuddlenRes

Protocol.Packet_S2C_SetMainGeneral = {
    ret                              = {type = Protocol.DataType.char},
    genaral_id                       = {type = Protocol.DataType.int},
    fields                           = {'ret','genaral_id'}
}
Protocol.structs[Protocol.S_2_C_SET_MAIN_GENERAL]               = Protocol.Packet_S2C_SetMainGeneral

Protocol.Packet_S2C_EndTraining = {
    general_id             = {type = Protocol.DataType.int},
    fields                 = {'general_id'}
}
Protocol.structs[Protocol.S_2_C_END_TRAINING]           = Protocol.Packet_S2C_EndTraining
