local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_WORLD_DATA                   = Protocol.C_2_S_WORLD_BASE + 0
Protocol.C_2_S_WORLD_INVEST                 = Protocol.C_2_S_WORLD_BASE + 1
Protocol.C_2_S_WORLD_AREA_INFO              = Protocol.C_2_S_WORLD_BASE + 2
Protocol.C_2_S_ATTACK_WORLDAREA             = Protocol.C_2_S_WORLD_BASE + 3


Protocol.S_2_C_WORLD_AREA_OPENED            = Protocol.S_2_C_WORLD_AREA_BASE + 0
Protocol.S_2_C_WORLD_AREA_INFO              = Protocol.S_2_C_WORLD_AREA_BASE + 1
Protocol.S_2_C_ATTACK_WORLDAREA_RES         = Protocol.S_2_C_WORLD_AREA_BASE + 2
Protocol.S_2_C_ADD_NEW_OPEN_WORLDAREA       = Protocol.S_2_C_WORLD_AREA_BASE + 3
Protocol.S_2_C_MOVEIN_RES                   = Protocol.S_2_C_WORLD_AREA_BASE + 4
Protocol.S_2_C_AREA_RES_INFO                = Protocol.S_2_C_WORLD_AREA_BASE + 5
Protocol.S_2_C_RES_OWNER_INFO               = Protocol.S_2_C_WORLD_AREA_BASE + 6
Protocol.S_2_C_INVEST_RES                   = Protocol.S_2_C_WORLD_AREA_BASE + 7
Protocol.S_2_C_CONQUER_RES                  = Protocol.S_2_C_WORLD_AREA_BASE + 8
Protocol.S_2_C_PLUNDER_RES_TIME_ADD         = Protocol.S_2_C_WORLD_AREA_BASE + 9

------------------------------C_2_S------------------------------
Protocol.Packet_C2S_WorldData = {
    fields          = {}
}
Protocol.structs[Protocol.C_2_S_WORLD_DATA]                 = Protocol.Packet_C2S_WorldData

Protocol.Packet_C2S_WorldInvest = {
    world_area_id       = {type = Protocol.DataType.uint},
    dev_type            = {type = Protocol.DataType.char},
    invest_type         = {type = Protocol.DataType.char},
    fields              = {'world_area_id','dev_type','invest_type'}
}
Protocol.structs[Protocol.C_2_S_WORLD_INVEST]               = Protocol.Packet_C2S_WorldInvest

Protocol.Packet_C2S_WorldAreaInfo = {
    world_area_id      = {type = Protocol.DataType.uint},
    fields             = {'world_area_id'}
}
Protocol.structs[Protocol.C_2_S_WORLD_AREA_INFO]            = Protocol.Packet_C2S_WorldAreaInfo

Protocol.Packet_C2S_AttackWorldArea = {
    world_area_id      = {type = Protocol.DataType.uint},
    fields             = {'world_area_id'}
}
Protocol.structs[Protocol.C_2_S_ATTACK_WORLDAREA]           = Protocol.Packet_C2S_AttackWorldArea

------------------------------S_2_C------------------------------
Protocol.Data_WorldData = {
    world_area_id             = {type = Protocol.DataType.uint},
    countroy                  = {type = Protocol.DataType.char},
    flag_len                  = {type = Protocol.DataType.ushort},
    flag                      = {type = Protocol.DataType.string, length = Protocol.MAX_FLAG_NAME_LEN},
    can_move_in               = {type = Protocol.DataType.char},
    fields                    = {'world_area_id','countroy','flag_len','flag','can_move_in'}
}

Protocol.Packet_S2C_WorldArea_Opend = {
    counts                    = {type = Protocol.DataType.char},
    world_data                = {type = Protocol.DataType.object, length = -1, clazz='Data_WorldData'},
    fields                    = {'counts','world_data'}
}
Protocol.structs[Protocol.S_2_C_WORLD_AREA_OPENED]          = Protocol.Packet_S2C_WorldArea_Opend

Protocol.Packet_S2C_WorldAreaInfo = {
    world_area_id             = {type = Protocol.DataType.char},
    is_open                   = {type = Protocol.DataType.char},
    keep_time                 = {type = Protocol.DataType.uint},
    legionId                  = {type = Protocol.DataType.uint},
    legionLv                  = {type = Protocol.DataType.uint},
    prosperity                = {type = Protocol.DataType.double},
    weekProsperity            = {type = Protocol.DataType.double},
    legion_name_len           = {type = Protocol.DataType.ushort},
    legion_name               = {type = Protocol.DataType.string,length = Protocol.MAX_CROPS_NAME_LEN},
    dev_val                   = {type = Protocol.DataType.double,length = Protocol.DEV_COUNT},
    fields                    = {'world_area_id','is_open','keep_time','legionId','legionLv','prosperity','weekProsperity','legion_name_len','legion_name','dev_val'}
}
Protocol.structs[Protocol.S_2_C_WORLD_AREA_INFO]            = Protocol.Packet_S2C_WorldAreaInfo

Protocol.Packet_S2C_MoveinRes = {
    res                       = {type = Protocol.DataType.char},
    new_world_id              = {type = Protocol.DataType.uint},
    new_world_zone_index      = {type = Protocol.DataType.uint},
    new_zone_index            = {type = Protocol.DataType.char},
    cd_time                   = {type = Protocol.DataType.uint},
    fields                    = {'res','new_world_id','new_world_zone_index','new_zone_index','cd_time'}
}
Protocol.structs[Protocol.S_2_C_MOVEIN_RES]                 = Protocol.Packet_S2C_MoveinRes

Protocol.Data_AreaResInfo = {
    id                        = {type = Protocol.DataType.uint},
    owner_name_len            = {type = Protocol.DataType.ushort},
    owner_name                = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    flag_len                  = {type = Protocol.DataType.ushort},
    flag                      = {type = Protocol.DataType.string, length = Protocol.MAX_FLAG_NAME_LEN},
    plunderFlag               = {type = Protocol.DataType.char},
    plunderCDTime             = {type = Protocol.DataType.uint},
    fields                    = {'id','owner_name_len','owner_name','flag_len','flag','plunderFlag','plunderCDTime'}
}

Protocol.Packet_S2C_AreaResInfo = {
    world_id                  = {type = Protocol.DataType.uint},
    world_zone_id             = {type = Protocol.DataType.uint},
    res_counts                = {type = Protocol.DataType.char},
    res_info                  = {type = Protocol.DataType.object, length = -1, clazz='Data_AreaResInfo'},
    fields                    = {'world_id','world_zone_id','res_counts','res_info'}
}
Protocol.structs[Protocol.S_2_C_AREA_RES_INFO]              = Protocol.Packet_S2C_AreaResInfo

Protocol.Packet_S2C_ResOwnerInfo = {
    world_id                  = {type = Protocol.DataType.uint},
    world_zone_id             = {type = Protocol.DataType.uint},
    zone_index                = {type = Protocol.DataType.char},
    addtion_yield             = {type = Protocol.DataType.uint},
    keep_time                 = {type = Protocol.DataType.uint},
    add_time_num              = {type = Protocol.DataType.uint},
    lvl                       = {type = Protocol.DataType.ushort},
    owner_name_len            = {type = Protocol.DataType.ushort},
    owner_name                = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    countryId                 = {type = Protocol.DataType.uint},
    plunderCdTime             = {type = Protocol.DataType.uint},
    plunderFlag               = {type = Protocol.DataType.char},
    fields                    = {'world_id','world_zone_id','zone_index','addtion_yield','keep_time','add_time_num','lvl','owner_name_len','owner_name','countryId','plunderCdTime','plunderFlag'}
}
Protocol.structs[Protocol.S_2_C_RES_OWNER_INFO]             = Protocol.Packet_S2C_ResOwnerInfo

Protocol.Packet_S2C_InvestRes = {
    world_area_id             = {type = Protocol.DataType.uint},
    cool_time                 = {type = Protocol.DataType.uint},
    cur_invest_val            = {type = Protocol.DataType.double,length = Protocol.DEV_COUNT},
    prosperity                = {type = Protocol.DataType.double},
    prestige                  = {type = Protocol.DataType.int},
    soul                      = {type = Protocol.DataType.int},
    credit                    = {type = Protocol.DataType.int},
    insignia                  = {type = Protocol.DataType.int},
    masterExp                 = {type = Protocol.DataType.int},
    bun                       = {type = Protocol.DataType.int},
    meat                      = {type = Protocol.DataType.int},
    wine                      = {type = Protocol.DataType.int},
    pearl                     = {type = Protocol.DataType.int},
    jade                      = {type = Protocol.DataType.int},
    censer                    = {type = Protocol.DataType.int},
    amber                     = {type = Protocol.DataType.int},
    sapphire                  = {type = Protocol.DataType.int},
    langyaJade                = {type = Protocol.DataType.int},
    fields                    = {'world_area_id','cool_time','cur_invest_val','prosperity','prestige','soul','credit','insignia','masterExp','bun',
                                'meat','wine','pearl','jade','censer','amber','sapphire','langyaJade'}
}
Protocol.structs[Protocol.S_2_C_INVEST_RES]                 = Protocol.Packet_S2C_InvestRes

Protocol.Packet_S2C_ConquerRes = {
    ret                        = {type = Protocol.DataType.char},
    fields                     = {'ret'}
}
Protocol.structs[Protocol.S_2_C_CONQUER_RES]                = Protocol.Packet_S2C_ConquerRes

Protocol.Packet_S2C_PLunderResTimeAdd = {
    worldAreaId                = {type = Protocol.DataType.uint},
    areaZoneId                 = {type = Protocol.DataType.uint},
    zoneIndex                  = {type = Protocol.DataType.char},
    keep_time                  = {type = Protocol.DataType.int},
    use_num                    = {type = Protocol.DataType.int},
    fields                     = {'worldAreaId','areaZoneId','zoneIndex','keep_time','use_num'}
}
Protocol.structs[Protocol.S_2_C_PLUNDER_RES_TIME_ADD]       = Protocol.Packet_S2C_PLunderResTimeAdd