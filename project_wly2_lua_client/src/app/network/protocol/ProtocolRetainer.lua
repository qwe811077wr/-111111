local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_ZONG_LOAD_INFO                  = Protocol.C_2_S_RELATION_BASE + 1 --info所有信息
Protocol.C_2_S_ZONG_LOAD_LIST                  = Protocol.C_2_S_RELATION_BASE + 3 --列表
Protocol.C_2_S_ZONG_APPLY                      = Protocol.C_2_S_RELATION_BASE + 5 --回复
Protocol.C_2_S_ZONG_HANDLE_APPLY               = Protocol.C_2_S_RELATION_BASE + 7 --操作申请列表
Protocol.C_2_S_ZONG_DISPART                    = Protocol.C_2_S_RELATION_BASE + 9 --删除
Protocol.C_2_S_ZONG_REFRESH                    = Protocol.C_2_S_RELATION_BASE + 11 --换一批
Protocol.C_2_S_ZONG_DRAW_EVENT                 = Protocol.C_2_S_RELATION_BASE + 13

Protocol.S_2_C_ZONG_LOAD_INFO                  = Protocol.S_2_C_RELATION_BASE + 2
Protocol.S_2_C_ZONG_LOAD_LIST                  = Protocol.S_2_C_RELATION_BASE + 4
Protocol.S_2_C_ZONG_APPLY                      = Protocol.S_2_C_RELATION_BASE + 6
Protocol.S_2_C_ZONG_HANDLE_APPLY               = Protocol.S_2_C_RELATION_BASE + 8
Protocol.S_2_C_ZONG_DISPART                    = Protocol.S_2_C_RELATION_BASE + 10
Protocol.S_2_C_ZONG_NOTIFY                     = Protocol.S_2_C_RELATION_BASE + 12
Protocol.S_2_C_ZONG_DISPART_NOTIFY             = Protocol.S_2_C_RELATION_BASE + 14
Protocol.S_2_C_ZONG_DRAW_EVENT                 = Protocol.S_2_C_RELATION_BASE + 16

Protocol.ZONG_LOAD_INFO_MAX_NUM                = 5
Protocol.ZONG_LOAD_LIST_MAX_NUM                = 10
Protocol.ZONG_LOAD_MAX_EVENT_NUM               = 5
--C2S

Protocol.Packet_C2S_ZongLoadList = {
    list_type                = {type = Protocol.DataType.short},--0 rand zong list, 1 rand apprentice list, 2 apply zong list, 3 apply apprentice list
    fields                   = {'list_type'}
}
Protocol.structs[Protocol.C_2_S_ZONG_LOAD_LIST]               = Protocol.Packet_C2S_ZongLoadList

Protocol.Packet_C2S_ZongApply = {
    apply_type               = {type = Protocol.DataType.short},
    role_id                  = {type = Protocol.DataType.longlong},
    fields                   = {'apply_type','role_id'}
}
Protocol.structs[Protocol.C_2_S_ZONG_APPLY]                   = Protocol.Packet_C2S_ZongApply

Protocol.Packet_C2S_ZongHandleApply = {
    op_type                  = {type = Protocol.DataType.short},
    apply_type               = {type = Protocol.DataType.short},
    role_id                  = {type = Protocol.DataType.longlong},
    fields                   = {'op_type','apply_type','role_id'}
}
Protocol.structs[Protocol.C_2_S_ZONG_HANDLE_APPLY]            = Protocol.Packet_C2S_ZongHandleApply

Protocol.Packet_C2S_ZongDispart = {
    dispart_type             = {type = Protocol.DataType.short},
    role_id                  = {type = Protocol.DataType.longlong},
    fields                   = {'dispart_type','role_id'}
}
Protocol.structs[Protocol.C_2_S_ZONG_DISPART]                 = Protocol.Packet_C2S_ZongDispart


Protocol.Packet_C2S_ZongRefresh = {
    refresh_type             = {type = Protocol.DataType.short}, --0 zong 1 apprentice
    fields                   = {'refresh_type'}
}
Protocol.structs[Protocol.C_2_S_ZONG_REFRESH]                 = Protocol.Packet_C2S_ZongRefresh

Protocol.Packet_C2S_ZongDrawEvent = {
    id                       = {type = Protocol.DataType.short},
    apprentice_id            = {type = Protocol.DataType.longlong},
    fields                   = {'id','apprentice_id'}
}
Protocol.structs[Protocol.C_2_S_ZONG_DRAW_EVENT]                 = Protocol.Packet_C2S_ZongDrawEvent

--S2C

Protocol.Data_ZongRoleInfo = {
    id                       = {type = Protocol.DataType.longlong},
    img_type                 = {type = Protocol.DataType.short},
    img_id                   = {type = Protocol.DataType.int},
    level                    = {type = Protocol.DataType.short},
    is_online                = {type = Protocol.DataType.short},
    offline_time             = {type = Protocol.DataType.int},
    force_value              = {type = Protocol.DataType.int},
    crop_id                  = {type = Protocol.DataType.int},
    name_len                 = {type = Protocol.DataType.short},
    name                     = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    fields                   = {'id','img_type','img_id','level','is_online','offline_time','force_value','crop_id','name_len','name'}
}
Protocol.Data_ZongEvent = {
    id                       = {type = Protocol.DataType.int},
    num                      = {type = Protocol.DataType.short},
    state                    = {type = Protocol.DataType.short},
    fields                   = {'id','num','state'}
}

Protocol.Data_ZongApprentices = {
    intimacy                 = {type = Protocol.DataType.int},
    count                    = {type = Protocol.DataType.short},
    events                   = {type = Protocol.DataType.object, length = -1, clazz='Data_ZongEvent'},
    info                     = {type = Protocol.DataType.object, length = 1, clazz='Data_ZongRoleInfo'},
    fields                   = {'intimacy','count','events','info'}
}

Protocol.Packet_S2C_ZongLoadInfo = {
    intimacy                 = {type = Protocol.DataType.int},
    count                    = {type = Protocol.DataType.short},
    events                   = {type = Protocol.DataType.object, length = -1, clazz='Data_ZongEvent'},
    zong_info                = {type = Protocol.DataType.object, length = 1, clazz='Data_ZongRoleInfo'},
    apprentice_count         = {type = Protocol.DataType.short},
    apprentices              = {type = Protocol.DataType.object, length = -1, clazz='Data_ZongApprentices'},
    fields                   = {'intimacy','count','events','zong_info','apprentice_count','apprentices'}
}
Protocol.structs[Protocol.S_2_C_ZONG_LOAD_INFO]                 = Protocol.Packet_S2C_ZongLoadInfo

Protocol.Packet_S2C_ZongLoadList = {
    list_type                = {type = Protocol.DataType.short},
    cd_time                  = {type = Protocol.DataType.int},
    count                    = {type = Protocol.DataType.short},
    roles                    = {type = Protocol.DataType.object, length = -1, clazz='Data_ZongRoleInfo'},
    fields                   = {'list_type','cd_time','count','roles'}
}
Protocol.structs[Protocol.S_2_C_ZONG_LOAD_LIST]                  = Protocol.Packet_S2C_ZongLoadList

Protocol.Packet_S2C_ZongApply = {
    ret                      = {type = Protocol.DataType.short},
    apply_type               = {type = Protocol.DataType.short}, -- 0 宗主 1 属臣
    role_id                  = {type = Protocol.DataType.longlong},
    fields                   = {'ret','apply_type','role_id'}
}
Protocol.structs[Protocol.S_2_C_ZONG_APPLY]                      = Protocol.Packet_S2C_ZongApply

Protocol.Packet_S2C_ZongHandleApply = {
    ret                      = {type = Protocol.DataType.short},
    op_type                  = {type = Protocol.DataType.short},
    apply_list               = {type = Protocol.DataType.short},
    role_id                  = {type = Protocol.DataType.longlong},
    fields                   = {'ret','op_type','apply_list','role_id'}
}
Protocol.structs[Protocol.S_2_C_ZONG_HANDLE_APPLY]                = Protocol.Packet_S2C_ZongHandleApply

Protocol.Packet_S2C_ZongDispart = {
    ret                      = {type = Protocol.DataType.short},
    dispart_type             = {type = Protocol.DataType.short},
    role_id                  = {type = Protocol.DataType.longlong},
    fields                   = {'ret','dispart_type','role_id'}
}
Protocol.structs[Protocol.S_2_C_ZONG_DISPART]                     = Protocol.Packet_S2C_ZongDispart

Protocol.Packet_S2C_ZongNotify = {
    notify_type              = {type = Protocol.DataType.short},
    info                     = {type = Protocol.DataType.object, length = 1, clazz='Data_ZongRoleInfo'},
    fields                   = {'notify_type','info'}
}
Protocol.structs[Protocol.S_2_C_ZONG_NOTIFY]                      = Protocol.Packet_S2C_ZongNotify

Protocol.Packet_S2C_ZongDispartNotify = {
    dispart_type             = {type = Protocol.DataType.short},
    role_id                  = {type = Protocol.DataType.longlong},
    fields                   = {'dispart_type','role_id'}
}
Protocol.structs[Protocol.S_2_C_ZONG_DISPART_NOTIFY]                = Protocol.Packet_S2C_ZongDispartNotify

Protocol.Packet_S2C_ZongDrawEvent = {
    ret                      = {type = Protocol.DataType.short},
    id                       = {type = Protocol.DataType.short},
    apprentice_id            = {type = Protocol.DataType.longlong},
    fields                   = {'dispart_type','role_id'}
}
Protocol.structs[Protocol.S_2_C_ZONG_DRAW_EVENT]                = Protocol.Packet_S2C_ZongDrawEvent