local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_TECHNOLOGY_LOAD                          = Protocol.C_2_S_TECHNOLOGY_BASE + 0;
Protocol.C_2_S_TECHNOLOGY_INTERSIFY                     = Protocol.C_2_S_TECHNOLOGY_BASE + 1;
Protocol.C_2_S_TECHNOLOGY_UPDATE                        = Protocol.C_2_S_TECHNOLOGY_BASE + 2;
Protocol.C_2_S_TECHNOLOGY_CD_END                        = Protocol.C_2_S_TECHNOLOGY_BASE + 3;
Protocol.C_2_S_TECHNOLOGY_SPEED_UP                      = Protocol.C_2_S_TECHNOLOGY_BASE + 4;
Protocol.C_2_S_LOAD_ALL_MEMBER_INFO_FROM_MUTI_BATTLE    = Protocol.C_2_S_TECHNOLOGY_BASE + 5;
Protocol.C_2_S_LOAD_SINGLE_MEMBER_FROM_MUTI_BATTLE      = Protocol.C_2_S_TECHNOLOGY_BASE + 6;
Protocol.C_2_S_GET_MUTI_BATTLE_LIMIT                    = Protocol.C_2_S_TECHNOLOGY_BASE + 7;
Protocol.C_2_S_IS_APPLYED_MUTI_BATTLE                   = Protocol.C_2_S_TECHNOLOGY_BASE + 8;
Protocol.C_2_S_GET_CD_TIME_MUTI_BATTLE                  = Protocol.C_2_S_TECHNOLOGY_BASE + 9;


Protocol.S_2_C_TECHNOLOGY_LOAD                          = Protocol.S_2_C_TECHNOLOGY_BASE + 0
Protocol.S_2_C_TECHNOLOGY_INTERSIFY                     = Protocol.S_2_C_TECHNOLOGY_BASE + 1
Protocol.S_2_C_TECHNOLOGY_APPEAR                        = Protocol.S_2_C_TECHNOLOGY_BASE + 2
Protocol.S_2_C_TECHNOLOGY_UPDATE                        = Protocol.S_2_C_TECHNOLOGY_BASE + 3
Protocol.S_2_C_TECHNOLOGY_CD_END                        = Protocol.S_2_C_TECHNOLOGY_BASE + 4
Protocol.S_2_C_TECHNOLOGY_SPEED_UP                      = Protocol.S_2_C_TECHNOLOGY_BASE + 5
Protocol.S_2_C_MUTIL_BATTLER_PVE_LIST_BEGIN             = Protocol.S_2_C_TECHNOLOGY_BASE + 6
Protocol.S_2_C_MUTIL_BATTLER_PVE_LIST_END               = Protocol.S_2_C_TECHNOLOGY_BASE + 7
Protocol.S_2_C_GENERAL_EPIPHANY                         = Protocol.S_2_C_TECHNOLOGY_BASE + 8
Protocol.S_2_C_AUTO_REINCARNATION                       = Protocol.S_2_C_TECHNOLOGY_BASE + 9
Protocol.S_2_C_EXCHANGE_JADE_ORANGE                     = Protocol.S_2_C_TECHNOLOGY_BASE + 10
Protocol.S_2_C_EXCHANGE_JADE_INFO                       = Protocol.S_2_C_TECHNOLOGY_BASE + 11
Protocol.S_2_C_REINFORCED_SOLDIER_INFO                  = Protocol.S_2_C_TECHNOLOGY_BASE + 12
Protocol.S_2_C_REINFORCED_SOLDIER                       = Protocol.S_2_C_TECHNOLOGY_BASE + 13
Protocol.S_2_C_HANDLE_JOIN_OR_QUIT_RES                  = Protocol.S_2_C_TECHNOLOGY_BASE + 14
Protocol.S_2_C_ADD_MEMBER_MUTI_BATTLE                   = Protocol.S_2_C_TECHNOLOGY_BASE + 15
Protocol.S_2_C_LOAD_MEMBER_INFO_FROM_MUTI_BATTLE        = Protocol.S_2_C_TECHNOLOGY_BASE + 16
Protocol.S_2_C_LOAD_SINGLE_MEMBER_FROM_MUTI_BATTLE      = Protocol.S_2_C_TECHNOLOGY_BASE + 17
Protocol.S_2_C_GET_MUTI_BATTLE_LIMIT                    = Protocol.S_2_C_TECHNOLOGY_BASE + 18
Protocol.S_2_C_IS_APPLYED_MUTI_BATTLE                   = Protocol.S_2_C_TECHNOLOGY_BASE + 19
Protocol.S_2_C_TECHNOLOGY_TOP                           = Protocol.S_2_C_TECHNOLOGY_BASE + 20


------------------------------C_2_S------------------------------

Protocol.Packet_C2S_TechnologyLoad = {
     fields             = {}
}
Protocol.structs[Protocol.C_2_S_TECHNOLOGY_LOAD]                = Protocol.Packet_C2S_TechnologyLoad

Protocol.Packet_C2S_TechnologyIntersify = {
    id                  = {type = Protocol.DataType.short},
    fields              = {'id'}
}
Protocol.structs[Protocol.C_2_S_TECHNOLOGY_INTERSIFY]           = Protocol.Packet_C2S_TechnologyIntersify

Protocol.Packet_C2S_TechnologyUpdate = {
    id                 = {type = Protocol.DataType.short},
    fields             = {'id'}
};
Protocol.structs[Protocol.C_2_S_TECHNOLOGY_UPDATE]              = Protocol.Packet_C2S_TechnologyUpdate

Protocol.Packet_C2S_TechnologyCdEnd = {
    id                 = {type = Protocol.DataType.short},
    fields             = {'id'}
};
Protocol.structs[Protocol.C_2_S_TECHNOLOGY_CD_END]              = Protocol.Packet_C2S_TechnologyCdEnd

Protocol.Packet_C2S_TechnologySpeedUp = {
    id                 = {type = Protocol.DataType.int},
    material_id        = {type = Protocol.DataType.int},
    material_num       = {type = Protocol.DataType.int},
    fields             = {'id','material_id','material_num'}
};
Protocol.structs[Protocol.C_2_S_TECHNOLOGY_SPEED_UP]              = Protocol.Packet_C2S_TechnologySpeedUp

------------------------------S_2_C------------------------------
Protocol.Data_TechInfo = {
    id                  = {type = Protocol.DataType.short},
    lvl                 = {type = Protocol.DataType.short},
    cd_time             = {type = Protocol.DataType.int},
    fields              = {'id','lvl','cd_time'}
};

Protocol.Packet_S2C_TechnologyLoad = {
    count               = {type = Protocol.DataType.short},
    teches              = {type = Protocol.DataType.object, length = -1,clazz='Data_TechInfo'},
    fields              = {'count','teches'}
};
Protocol.structs[Protocol.S_2_C_TECHNOLOGY_LOAD]                = Protocol.Packet_S2C_TechnologyLoad

Protocol.Packet_S2C_TechnologyIntersify = {
    id                  = {type = Protocol.DataType.short},
    cd_time             = {type = Protocol.DataType.int},
    fields              = {'id','cd_time'}
};
Protocol.structs[Protocol.S_2_C_TECHNOLOGY_INTERSIFY]           = Protocol.Packet_S2C_TechnologyIntersify

Protocol.Data_AppearTechInfo = {
    id                  = {type = Protocol.DataType.short},
    level               = {type = Protocol.DataType.short},
    fields              = {'id','level'}
};

Protocol.Packet_S2C_TechnologyAppear = {
    count               = {type = Protocol.DataType.short},
    teches              = {type = Protocol.DataType.object, length = -1,clazz='Data_AppearTechInfo'},
    fields              = {'count','teches'}
};
Protocol.structs[Protocol.S_2_C_TECHNOLOGY_APPEAR]              = Protocol.Packet_S2C_TechnologyAppear

Protocol.Packet_S2C_ReinforcedSoldierInfo = {
    generalId           = {type = Protocol.DataType.int},
    infoLen             = {type = Protocol.DataType.ushort},
    reinforcedSoldier   = {type = Protocol.DataType.string, length = -1},
    fields              = {'generalId','infoLen','reinforcedSoldier'}
};
Protocol.structs[Protocol.S_2_C_REINFORCED_SOLDIER_INFO]              = Protocol.Packet_S2C_ReinforcedSoldierInfo

Protocol.Packet_S2C_ReinforcedSoldier = {
    generalId           = {type = Protocol.DataType.int},
    oriId               = {type = Protocol.DataType.int},
    curId               = {type = Protocol.DataType.int},
    fields              = {'generalId','oriId','curId'}
};
Protocol.structs[Protocol.S_2_C_REINFORCED_SOLDIER]              = Protocol.Packet_S2C_ReinforcedSoldier

Protocol.Packet_S2C_TechnologyUpdate = {
    ret                 = {type = Protocol.DataType.short},
    id                  = {type = Protocol.DataType.short},
    cd_time             = {type = Protocol.DataType.int},
    fields              = {'ret','id','cd_time'}
};
Protocol.structs[Protocol.S_2_C_TECHNOLOGY_UPDATE]              = Protocol.Packet_S2C_TechnologyUpdate

Protocol.Packet_S2C_TechnologyCdEnd = {
    ret                 = {type = Protocol.DataType.short},
    id                  = {type = Protocol.DataType.short},
    level               = {type = Protocol.DataType.short},
    fields              = {'ret','id','level'}
};
Protocol.structs[Protocol.S_2_C_TECHNOLOGY_CD_END]              = Protocol.Packet_S2C_TechnologyCdEnd

Protocol.Packet_S2C_TechnologySpeedUp = {
    ret                 = {type = Protocol.DataType.short},
    id                  = {type = Protocol.DataType.int},
    material_id         = {type = Protocol.DataType.int},
    material_num        = {type = Protocol.DataType.int},
    cd_time             = {type = Protocol.DataType.int},
    fields              = {'ret','id','material_id','material_num','cd_time'}
};
Protocol.structs[Protocol.S_2_C_TECHNOLOGY_SPEED_UP]              = Protocol.Packet_S2C_TechnologySpeedUp