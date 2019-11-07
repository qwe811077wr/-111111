local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_CITY_GETINFOS      = Protocol.C_2_S_CITY_BASE + 0
Protocol.C_2_S_CITY_GETINFO       = Protocol.C_2_S_CITY_BASE + 1
Protocol.C_2_S_CITY_GETBUILDTIME  = Protocol.C_2_S_CITY_BASE + 2
Protocol.C_2_S_CITY_LVLUP         = Protocol.C_2_S_CITY_BASE + 3
Protocol.C_2_S_SELECT_COUNTRY     = Protocol.C_2_S_CITY_BASE + 4
Protocol.C_2_S_CHANGE_PALYER_FLAG = Protocol.C_2_S_CITY_BASE + 5
Protocol.C_2_S_CHANGE_LEAVE_MSG   = Protocol.C_2_S_CITY_BASE + 6
Protocol.C_2_S_CITY_SKIN_COST     = Protocol.C_2_S_CITY_BASE + 7
Protocol.C_2_S_CITY_SKIN_SELECT   = Protocol.C_2_S_CITY_BASE + 8
Protocol.C_2_S_CITY_SKIN_INFO     = Protocol.C_2_S_CITY_BASE + 9

Protocol.S_2_C_CITY_INFOS       = Protocol.S_2_C_CITY_BASE + 0
Protocol.S_2_C_CITY_INFO        = Protocol.S_2_C_CITY_BASE + 1
Protocol.S_2_C_CITY_BUILD_TIME  = Protocol.S_2_C_CITY_BASE + 2
Protocol.S_2_C_CITY_LVLUP       = Protocol.S_2_C_CITY_BASE + 3
Protocol.S_2_C_SELECT_RES       = Protocol.S_2_C_CITY_BASE + 4
Protocol.S_2_C_ATT_STONE_INFO   = Protocol.S_2_C_CITY_BASE + 5
Protocol.S_2_C_CITY_SKIN_RESET  = Protocol.S_2_C_CITY_BASE + 6
Protocol.S_2_C_CITY_SKIN_ADD    = Protocol.S_2_C_CITY_BASE + 7
Protocol.S_2_C_CITY_SKIN_SELECT = Protocol.S_2_C_CITY_BASE + 8
Protocol.S_2_C_CITY_SKIN_INFO   = Protocol.S_2_C_CITY_BASE + 9

Protocol.Packet_C2S_ChangePlayerFlag = {
    --C_2_S_CHANGE_PALYER_FLAG
    world_area_id   = {type = Protocol.DataType.uint},
    area_zone_index = {type = Protocol.DataType.uint},
    zone_index      = {type = Protocol.DataType.char},
    flag_len        = {type = Protocol.DataType.ushort},
    flag            = {type = Protocol.DataType.string, length = Protocol.MAX_FLAG_NAME_LEN},
    fields          = {'world_area_id', 'area_zone_index', 'zone_index', 'flag_len', 'flag'}
}
Protocol.structs[Protocol.C_2_S_CHANGE_PALYER_FLAG] = Protocol.Packet_C2S_ChangePlayerFlag

Protocol.Packet_C2S_ChangeLeaveMsg = {
    --C_2_S_CHANGE_LEAVE_MSG
    world_area_id   = {type = Protocol.DataType.uint},
    area_zone_index = {type = Protocol.DataType.uint},
    zone_index      = {type = Protocol.DataType.char},
    msg_len         = {type = Protocol.DataType.ushort},
    leave_msg       = {type = Protocol.DataType.string, length = Protocol.MAX_LEAVE_MSG_LEN},
    fields          = {'world_area_id', 'area_zone_index', 'zone_index', 'msg_len', 'leave_msg'}
}
Protocol.structs[Protocol.C_2_S_CHANGE_LEAVE_MSG] = Protocol.Packet_C2S_ChangeLeaveMsg

Protocol.Packet_C2S_CitySkinCost = {
    --C_2_S_CITY_SKIN_COST
    ident = {type = Protocol.DataType.int},
    fields  = {'ident'}
}
Protocol.structs[Protocol.C_2_S_CITY_SKIN_COST] = Protocol.Packet_C2S_CitySkinCost

Protocol.Packet_C2S_CitySkinSelect = {
    --C_2_S_CITY_SKIN_SELECT
    ident = {type = Protocol.DataType.int},
    fields  = {'ident'}
}
Protocol.structs[Protocol.C_2_S_CITY_SKIN_SELECT] = Protocol.Packet_C2S_CitySkinSelect

Protocol.Data_Packet_Building = {
    id      = {type = Protocol.DataType.uint},
    type    = {type = Protocol.DataType.ushort},
    cur_lvl = {type = Protocol.DataType.ushort},
    fields  = {'id', 'type', 'cur_lvl'}
}

Protocol.Packet_S2C_CitysInfo = {
    build_times = {type = Protocol.DataType.short},
    nums        = {type = Protocol.DataType.char},
    build       = {type = Protocol.DataType.object, length = -1, clazz='Data_Packet_Building'},
    fields      = {'build_times', 'nums', 'build'}
}
Protocol.structs[Protocol.S_2_C_CITY_INFOS] = Protocol.Packet_S2C_CitysInfo

Protocol.Packet_S2C_CityBuildTime = {
    nums   = {type = Protocol.DataType.char},
    times  = {type = Protocol.DataType.uint, length = Protocol.MAX_BUILDER_COUNT},
    fields = {'nums', 'times'}
}
Protocol.structs[Protocol.S_2_C_CITY_BUILD_TIME] = Protocol.Packet_S2C_CityBuildTime

Protocol.Packet_C2S_CityLvlUp = {
    build_id = {type = Protocol.DataType.int},
    fields   = {'build_id'}
}
Protocol.structs[Protocol.C_2_S_CITY_LVLUP] = Protocol.Packet_C2S_CityLvlUp

Protocol.Packet_S2C_CityLvlUp = {
    opType     = {type = Protocol.DataType.char},
    level      = {type = Protocol.DataType.short},
    build_time = {type = Protocol.DataType.short},
    build_id   = {type = Protocol.DataType.int},
    ret        = {type = Protocol.DataType.char},
    fields     = {'opType', 'level', 'build_time', 'build_id', 'ret'}
}
Protocol.structs[Protocol.S_2_C_CITY_LVLUP] = Protocol.Packet_S2C_CityLvlUp

Protocol.Data_AttStone = {
    ident  = {type = Protocol.DataType.int},
    count  = {type = Protocol.DataType.int},
    fields = {'ident', 'count'}
}

Protocol.Packet_S2C_AttStoneInfo = {
    count    = {type = Protocol.DataType.short},
    attStone = {type = Protocol.DataType.object, length = -1, clazz='Data_AttStone'},
    fields   = {'count', 'attStone'}
}
Protocol.structs[Protocol.S_2_C_ATT_STONE_INFO] = Protocol.Packet_S2C_AttStoneInfo

Protocol.Packet_S2C_CitySkinAdd = {
    ident   = {type = Protocol.DataType.int},
    addTime = {type = Protocol.DataType.int},
    fields  = {'ident', 'addTime'}
}
Protocol.structs[Protocol.S_2_C_CITY_SKIN_ADD] = Protocol.Packet_S2C_CitySkinAdd

Protocol.Packet_S2C_CitySkinSelect = {
    ident           = {type = Protocol.DataType.int},
    area_id         = {type = Protocol.DataType.uint},
    area_zone_index = {type = Protocol.DataType.uint},
    city_no         = {type = Protocol.DataType.char},
    fields          = {'ident', 'area_id', 'area_zone_index', 'city_no'}
}
Protocol.structs[Protocol.S_2_C_CITY_SKIN_SELECT] = Protocol.Packet_S2C_CitySkinSelect

Protocol.Packet_S2C_CitySkinInfo = {
    defaultId       = {type = Protocol.DataType.int},
    citySkinInfoLen = {type = Protocol.DataType.ushort},
    citySkinInfo    = {type = Protocol.DataType.string, length = -1},
    fields          = {'defaultId', 'citySkinInfoLen', 'citySkinInfo'}
}
Protocol.structs[Protocol.S_2_C_CITY_SKIN_INFO] = Protocol.Packet_S2C_CitySkinInfo
