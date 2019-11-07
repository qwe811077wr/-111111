local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_APPOINT_INFO                  = Protocol.C_2_S_APPOINT_BASE + 1
Protocol.C_2_S_APPOINT_EQUIPMENT             = Protocol.C_2_S_APPOINT_BASE + 2
Protocol.C_2_S_APPOINT_DO                    = Protocol.C_2_S_APPOINT_BASE + 3
Protocol.C_2_S_JIUGUAN_RECRUIT               = Protocol.C_2_S_APPOINT_BASE + 4
Protocol.C_2_S_JIUGUAN_LOAD                  = Protocol.C_2_S_APPOINT_BASE + 5
Protocol.C_2_S_JIUGUAN_REFRESH               = Protocol.C_2_S_APPOINT_BASE + 6
Protocol.C_2_S_GENERAL_DELETE                = Protocol.C_2_S_APPOINT_BASE + 7
Protocol.C_2_S_BUY_EQUIPMENT_VOUCHERS        = Protocol.C_2_S_APPOINT_BASE + 8

Protocol.S_2_C_APPOINT_INFO                  = Protocol.S_2_C_APPOINT_BASE + 2
Protocol.S_2_C_APPOINT_EQUIPMENT             = Protocol.S_2_C_APPOINT_BASE + 3
Protocol.S_2_C_APPOINT_DO                    = Protocol.S_2_C_APPOINT_BASE + 4
Protocol.S_2_C_JIUGUAN_RECRUIT               = Protocol.S_2_C_APPOINT_BASE + 5
Protocol.S_2_C_JIUGUAN_LOAD                  = Protocol.S_2_C_APPOINT_BASE + 6
Protocol.S_2_C_JIUGUAN_RECRUIT_END           = Protocol.S_2_C_APPOINT_BASE + 7
Protocol.S_2_C_JIUGUAN_REFRESH               = Protocol.S_2_C_APPOINT_BASE + 8
Protocol.S_2_C_GENEERAL_DELETE               = Protocol.S_2_C_APPOINT_BASE + 9
Protocol.S_2_C_BUY_EQUIPMENT_VOCHERS         = Protocol.S_2_C_APPOINT_BASE + 10

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

Protocol.Packet_C2S_BuyEquipmentVouchers = {
    buy_num             = {type = Protocol.DataType.short},
    is_ten              = {type = Protocol.DataType.short},
    fields              = {'buy_num', 'is_ten'}
}
Protocol.structs[Protocol.C_2_S_BUY_EQUIPMENT_VOUCHERS]  = Protocol.Packet_C2S_BuyEquipmentVouchers

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

Protocol.Packet_S2C_BuyEquipmentVouchers = {
    buy_num                             = {type = Protocol.DataType.short},
    is_ten                              = {type = Protocol.DataType.short},
    fields                              = {'buy_num', 'is_ten'}
}
Protocol.structs[Protocol.S_2_C_BUY_EQUIPMENT_VOCHERS]              = Protocol.Packet_S2C_BuyEquipmentVouchers



--S_2_C_GENEERAL_DELETE
