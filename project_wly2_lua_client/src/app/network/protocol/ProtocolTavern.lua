local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_APPOINT_INFO                  = Protocol.C_2_S_APPOINT_BASE + 1
Protocol.C_2_S_APPOINT_EQUIPMENT             = Protocol.C_2_S_APPOINT_BASE + 2
Protocol.C_2_S_APPOINT_DO                    = Protocol.C_2_S_APPOINT_BASE + 3
Protocol.C_2_S_JIUGUAN_RECRUIT               = Protocol.C_2_S_APPOINT_BASE + 4
Protocol.C_2_S_JIUGUAN_LOAD                  = Protocol.C_2_S_APPOINT_BASE + 5
Protocol.C_2_S_JIUGUAN_REFRESH               = Protocol.C_2_S_APPOINT_BASE + 6
Protocol.C_2_S_GENERAL_DELETE                = Protocol.C_2_S_APPOINT_BASE + 7
Protocol.C_2_S_BUY_APPOINT_TIMES             = Protocol.C_2_S_APPOINT_BASE + 8
Protocol.C_2_S_APPOINT_GENERAL_INFO          = Protocol.C_2_S_APPOINT_BASE + 9
Protocol.C_2_S_APPOINT_GENERAL               = Protocol.C_2_S_APPOINT_BASE + 10

Protocol.S_2_C_APPOINT_INFO                  = Protocol.S_2_C_APPOINT_BASE + 2
Protocol.S_2_C_APPOINT_EQUIPMENT             = Protocol.S_2_C_APPOINT_BASE + 3
Protocol.S_2_C_APPOINT_DO                    = Protocol.S_2_C_APPOINT_BASE + 4
Protocol.S_2_C_JIUGUAN_RECRUIT               = Protocol.S_2_C_APPOINT_BASE + 5
Protocol.S_2_C_JIUGUAN_LOAD                  = Protocol.S_2_C_APPOINT_BASE + 6
Protocol.S_2_C_JIUGUAN_RECRUIT_END           = Protocol.S_2_C_APPOINT_BASE + 7
Protocol.S_2_C_JIUGUAN_REFRESH               = Protocol.S_2_C_APPOINT_BASE + 8
Protocol.S_2_C_GENEERAL_DELETE               = Protocol.S_2_C_APPOINT_BASE + 9
Protocol.S_2_C_BUY_APPOINT_TIMES             = Protocol.S_2_C_APPOINT_BASE + 10
Protocol.S_2_C_APPOINT_GENERAL_INFO          = Protocol.S_2_C_APPOINT_BASE + 12
Protocol.S_2_C_APPOINT_GENERAL               = Protocol.S_2_C_APPOINT_BASE + 13
Protocol.S_2_C_APPOINT_GENERAL_CHANGE        = Protocol.S_2_C_APPOINT_BASE + 14

--c2s
Protocol.Packet_C2S_AppointDo = {
    --C_2_S_APPOINT_DO
    pool_id         = {type = Protocol.DataType.short},
    is_ten          = {type = Protocol.DataType.short},
    fields          = {'pool_id', 'is_ten'}
}
Protocol.structs[Protocol.C_2_S_APPOINT_DO]       = Protocol.Packet_C2S_AppointDo

Protocol.Packet_C2S_JiuGuanRecruit = {
    general_index       = {type = Protocol.DataType.short},
    rate_index          = {type = Protocol.DataType.short},
    fields              = {'general_index', 'rate_index'}
}
Protocol.structs[Protocol.C_2_S_JIUGUAN_RECRUIT]       = Protocol.Packet_C2S_JiuGuanRecruit

Protocol.Packet_C2S_AppointEquipment = {
    pool_id              = {type = Protocol.DataType.short},
    is_ten               = {type = Protocol.DataType.short},
    fields               = {'pool_id', 'is_ten'}
}
Protocol.structs[Protocol.C_2_S_APPOINT_EQUIPMENT]      = Protocol.Packet_C2S_AppointEquipment

Protocol.Packet_C2S_GeneralDelete = {
    general_id          = {type = Protocol.DataType.int},
    fields              = {'general_id'}
}
Protocol.structs[Protocol.C_2_S_GENERAL_DELETE]       = Protocol.Packet_C2S_GeneralDelete

Protocol.Packet_C2S_BuyAppointTimes = {
    id                  = {type = Protocol.DataType.int},
    buy_num             = {type = Protocol.DataType.short},
    is_ten              = {type = Protocol.DataType.short},
    fields              = {'id', 'buy_num', 'is_ten'}
}
Protocol.structs[Protocol.C_2_S_BUY_APPOINT_TIMES]  = Protocol.Packet_C2S_BuyAppointTimes

--s2c
Protocol.Data_Appoint = {
    id              = {type = Protocol.DataType.short},
    num             = {type = Protocol.DataType.short},
    cd_time         = {type = Protocol.DataType.int},
    secure          = {type = Protocol.DataType.short},
    fields          = {'id','num','cd_time','secure'}
}

Protocol.Packet_S2C_AppointInfo = {
    --S_2_C_APPOINT_INFO
    count           = {type = Protocol.DataType.short},
    items           = {type = Protocol.DataType.object, length = -1, clazz='Data_Appoint'},
    dailynum        = {type = Protocol.DataType.short},
    fields          = {'count','items','dailynum'}
}
Protocol.structs[Protocol.S_2_C_APPOINT_INFO]            = Protocol.Packet_S2C_AppointInfo

Protocol.Data_AppointDo = {
    id              = {type = Protocol.DataType.short},
    item_id         = {type = Protocol.DataType.int},
    fields          = {'id','item_id'}
}

Protocol.Packet_S2C_AppointDo = {
    --S_2_C_APPOINT_DO
    pool_id         = {type = Protocol.DataType.short},
    is_ten          = {type = Protocol.DataType.short},
    num             = {type = Protocol.DataType.short},
    cd_time         = {type = Protocol.DataType.int},
    count           = {type = Protocol.DataType.short},
    items           = {type = Protocol.DataType.object, length = -1, clazz='Data_AppointDo'},
    dailynum        = {type = Protocol.DataType.short},
    fields          = {'pool_id','is_ten','num','cd_time','count','items','dailynum'}
}
Protocol.structs[Protocol.S_2_C_APPOINT_DO]            = Protocol.Packet_S2C_AppointDo

Protocol.Data_RecruitGeneral = {
    name_len         = {type = Protocol.DataType.short},
    name             = {type = Protocol.DataType.string, length = 15},
    quality_type     = {type = Protocol.DataType.short},
    rtemp_id         = {type = Protocol.DataType.int},
    skill_id         = {type = Protocol.DataType.int},
    rate             = {type = Protocol.DataType.int},
    left_time        = {type = Protocol.DataType.int},
    index            = {type = Protocol.DataType.int},
    count            = {type = Protocol.DataType.short},
    attr             = {type = Protocol.DataType.int, length = -1},
    fields           = {'name_len','name','quality_type','rtemp_id','skill_id','rate','left_time','index','count','attr'}
}

Protocol.Data_ExtractEquipment = {
    equip_id         = {type = Protocol.DataType.int},
    equip_db_id      = {type = Protocol.DataType.longlong},
    state            = {type = Protocol.DataType.short},
    fields           = {'equip_id', 'equip_db_id', 'state'}
}

Protocol.Packet_S2C_AppointEquipment = {
    pool_id          = {type = Protocol.DataType.short},
    is_ten           = {type = Protocol.DataType.short},
    num              = {type = Protocol.DataType.short},
    cd_time          = {type = Protocol.DataType.int},
    secure           = {type = Protocol.DataType.short},
    count            = {type = Protocol.DataType.short},
    items            = {type = Protocol.DataType.object, length = -1, clazz = 'Data_ExtractEquipment'},
    daily_num        = {type = Protocol.DataType.short},
    fields           = {'pool_id', 'is_ten', 'num', 'cd_time', 'secure', 'count', 'items', 'daily_num'}
}
Protocol.structs[Protocol.S_2_C_APPOINT_EQUIPMENT]             = Protocol.Packet_S2C_AppointEquipment

Protocol.Data_JiuGuanData = {
    refresh_times    = {type = Protocol.DataType.short},
    count            = {type = Protocol.DataType.short},
    generals         = {type = Protocol.DataType.object, length = -1, clazz='Data_RecruitGeneral'},
    hasbegin         = {type = Protocol.DataType.short},
    begin_general    = {type = Protocol.DataType.object, length = 1, clazz='Data_RecruitGeneral'},
    fields           = {'refresh_times','count','generals','hasbegin','begin_general'}
}

Protocol.Packet_S2C_JiuGuanLoad = {
    data                               = {type = Protocol.DataType.object, length = 1, clazz='Data_JiuGuanData'},
    fields                             = {'data'}
}
Protocol.structs[Protocol.S_2_C_JIUGUAN_LOAD]                   = Protocol.Packet_S2C_JiuGuanLoad

Protocol.Packet_S2C_JiuGuanRecruit = {
    general_index                      = {type = Protocol.DataType.short},
    rate_index                         = {type = Protocol.DataType.short},
    left_time                          = {type = Protocol.DataType.int},
    fields                             = {'general_index','rate_index','left_time'}
}
Protocol.structs[Protocol.S_2_C_JIUGUAN_RECRUIT]                   = Protocol.Packet_S2C_JiuGuanRecruit

Protocol.Packet_S2C_JiuGuanRefresh = {
    data                               = {type = Protocol.DataType.object, length = 1, clazz='Data_JiuGuanData'},
    fields                             = {'data'}
}
Protocol.structs[Protocol.S_2_C_JIUGUAN_REFRESH]                   = Protocol.Packet_S2C_JiuGuanRefresh

Protocol.Packet_S2C_JiuGuanRecruitEnd = {
    general_index                      = {type = Protocol.DataType.short},
    succeed                            = {type = Protocol.DataType.short},
    count                              = {type = Protocol.DataType.short},
    info                               = {type = Protocol.DataType.object, length = -1, clazz='Data_SGeneralInfo'},
    fields                             = {'general_index','succeed','count','info'}
}
Protocol.structs[Protocol.S_2_C_JIUGUAN_RECRUIT_END]                   = Protocol.Packet_S2C_JiuGuanRecruitEnd


Protocol.Packet_S2C_GeneralDelete = {
    general_id                         = {type = Protocol.DataType.int},
    fields                             = {'general_id'}
}
Protocol.structs[Protocol.S_2_C_GENEERAL_DELETE]                   = Protocol.Packet_S2C_GeneralDelete

Protocol.Packet_S2C_BuyAppointTimes = {
    id                                  = {type = Protocol.DataType.int},
    buy_num                             = {type = Protocol.DataType.short},
    is_ten                              = {type = Protocol.DataType.short},
    fields                              = {'buy_num', 'is_ten'}
}
Protocol.structs[Protocol.S_2_C_BUY_APPOINT_TIMES]              = Protocol.Packet_S2C_BuyAppointTimes

Protocol.Data_Appoint_General = {
    id              = {type = Protocol.DataType.int},
    num             = {type = Protocol.DataType.short},
    cd_time         = {type = Protocol.DataType.int},
    secure          = {type = Protocol.DataType.short},
    duration        = {type = Protocol.DataType.int},
    fields          = {'id','num','cd_time','secure','duration'}
}

Protocol.Packet_S2C_AppointGeneralInfo = {
    --S_2_C_APPOINT_INFO
    count           = {type = Protocol.DataType.short},
    items           = {type = Protocol.DataType.object, length = -1, clazz='Data_Appoint_General'},
    fields          = {'count','items'}
}
Protocol.structs[Protocol.S_2_C_APPOINT_GENERAL_INFO]            = Protocol.Packet_S2C_AppointGeneralInfo

Protocol.Packet_C2S_AppointGeneral = {
    pool_id              = {type = Protocol.DataType.short},
    is_ten               = {type = Protocol.DataType.short},
    fields               = {'pool_id', 'is_ten'}
}
Protocol.structs[Protocol.C_2_S_APPOINT_GENERAL]      = Protocol.Packet_C2S_AppointGeneral

Protocol.Packet_S2C_AppointGeneral = {
    pool_id          = {type = Protocol.DataType.short},
    is_ten           = {type = Protocol.DataType.short},
    num              = {type = Protocol.DataType.short},
    cd_time          = {type = Protocol.DataType.int},
    secure           = {type = Protocol.DataType.short},
    count            = {type = Protocol.DataType.short},
    rws              = {type = Protocol.DataType.object, length = -1, clazz='Packet_Data_RewardType'},
    fields           = {'pool_id', 'is_ten', 'num', 'cd_time', 'secure', 'count', 'rws'}
}
Protocol.structs[Protocol.S_2_C_APPOINT_GENERAL]             = Protocol.Packet_S2C_AppointGeneral

Protocol.Data_ChangeGeneral = {
    id               = {type = Protocol.DataType.short},
    end_time         = {type = Protocol.DataType.int},
    fields           = {'id', 'end_time'}
}

Protocol.Packet_S2C_AppointGeneralChange = {
    count            = {type = Protocol.DataType.short},
    items            = {type = Protocol.DataType.object, length = -1, clazz = 'Data_ChangeGeneral'},
    fields           = {'count', 'items'}
}
Protocol.structs[Protocol.S_2_C_APPOINT_GENERAL_CHANGE]             = Protocol.Packet_S2C_AppointGeneralChange

--S_2_C_GENEERAL_DELETE
