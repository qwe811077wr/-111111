local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_BUILD_LEVEL_UP             = Protocol.C_2_S_MAIN_CITY_BASE + 1
Protocol.C_2_S_BUILD_BUY_LIST             = Protocol.C_2_S_MAIN_CITY_BASE + 2
Protocol.C_2_S_BUILD_CD_LIST              = Protocol.C_2_S_MAIN_CITY_BASE + 3
Protocol.C_2_S_BUILD_FINISH_LEVEL_UP      = Protocol.C_2_S_MAIN_CITY_BASE + 4
Protocol.C_2_S_BUILD_CANCEL_LEVEL_UP      = Protocol.C_2_S_MAIN_CITY_BASE + 5
Protocol.C_2_S_BUILD_SPEED_UP             = Protocol.C_2_S_MAIN_CITY_BASE + 6
Protocol.C_2_S_BUILD_ADD_OFFICER          = Protocol.C_2_S_MAIN_CITY_BASE + 7
Protocol.C_2_S_BUILD_DEL_OFFICER          = Protocol.C_2_S_MAIN_CITY_BASE + 8
Protocol.C_2_S_BUILD_GET_RESOURCE         = Protocol.C_2_S_MAIN_CITY_BASE + 9
Protocol.C_2_S_BUILD_ONEKEY_ADD_OFFICER   = Protocol.C_2_S_MAIN_CITY_BASE + 10

Protocol.S_2_C_BUILD_LEVEL_UP             = Protocol.S_2_C_MAIN_CITY_BASE + 1
Protocol.S_2_C_BUILD_BUY_LIST             = Protocol.S_2_C_MAIN_CITY_BASE + 2
Protocol.S_2_C_BUILD_ALL_INFO             = Protocol.S_2_C_MAIN_CITY_BASE + 3
Protocol.S_2_C_BUILD_LIST_INFO            = Protocol.S_2_C_MAIN_CITY_BASE + 4
Protocol.S_2_C_BUILD_MAIN_INFO            = Protocol.S_2_C_MAIN_CITY_BASE + 5
Protocol.S_2_C_BUILD_CD_LIST              = Protocol.S_2_C_MAIN_CITY_BASE + 6
Protocol.S_2_C_BUILD_FINISH_LEVEL_UP      = Protocol.S_2_C_MAIN_CITY_BASE + 7
Protocol.S_2_C_BUILD_CANCEL_LEVEL_UP      = Protocol.S_2_C_MAIN_CITY_BASE + 8
Protocol.S_2_C_BUILD_SPEED_UP             = Protocol.S_2_C_MAIN_CITY_BASE + 9
Protocol.S_2_C_BUILD_ADD_OFFICER          = Protocol.S_2_C_MAIN_CITY_BASE + 10
Protocol.S_2_C_BUILD_DEL_OFFICER          = Protocol.S_2_C_MAIN_CITY_BASE + 11
Protocol.S_2_C_BUILD_OFFICER_STATE_UPDATE = Protocol.S_2_C_MAIN_CITY_BASE + 12
Protocol.S_2_C_BUILD_BUSY_GENERAL_UPDATE  = Protocol.S_2_C_MAIN_CITY_BASE + 13
Protocol.S_2_C_BUILD_RESOURCE_UPDATE      = Protocol.S_2_C_MAIN_CITY_BASE + 14
Protocol.S_2_C_BUILD_GET_RESOURCE         = Protocol.S_2_C_MAIN_CITY_BASE + 15
Protocol.S_2_C_BUILD_GENERAL_UNLOAD       = Protocol.S_2_C_MAIN_CITY_BASE + 16
Protocol.S_2_C_BUILD_ONEKEY_ADD_OFFICER   = Protocol.S_2_C_MAIN_CITY_BASE + 17

Protocol.Packet_C2S_BuildLevelUp = {
    build_id = {type = Protocol.DataType.int},
    fields   = {'build_id'}
}
Protocol.structs[Protocol.C_2_S_BUILD_LEVEL_UP] = Protocol.Packet_C2S_BuildLevelUp

Protocol.Packet_C2S_BuildCDList = {
    build_id = {type = Protocol.DataType.int},
    fields   = {'build_id'}
}
Protocol.structs[Protocol.C_2_S_BUILD_CD_LIST] = Protocol.Packet_C2S_BuildCDList

Protocol.Packet_S2C_BuildLevelUp = {
    ret         = {type = Protocol.DataType.short},
    build_id    = {type = Protocol.DataType.int},
    cd_time     = {type = Protocol.DataType.int},
    fields      = {'ret','build_id','cd_time'}
}
Protocol.structs[Protocol.S_2_C_BUILD_LEVEL_UP] = Protocol.Packet_S2C_BuildLevelUp

Protocol.Packet_S2C_BuildBuyList = {
    builder_num = {type = Protocol.DataType.short},
    fields      = {'builder_num'}
}
Protocol.structs[Protocol.S_2_C_BUILD_BUY_LIST] = Protocol.Packet_S2C_BuildBuyList

Protocol.Data_Officer = {
    general_id = {type = Protocol.DataType.int},
    lock_state = {type = Protocol.DataType.short},
    fields     = {'general_id','lock_state'}
}

Protocol.Data_Building = {
    build_id     = {type = Protocol.DataType.int},
    type         = {type = Protocol.DataType.short},
    level        = {type = Protocol.DataType.short},
    cd_time      = {type = Protocol.DataType.int},
    resource     = {type = Protocol.DataType.int},
    fields       = {'build_id','type','level','cd_time','resource'}
}

Protocol.Data_BuildingOfficer = {
    build_type   = {type = Protocol.DataType.short},
    count        = {type = Protocol.DataType.short},
    officer_list = {type = Protocol.DataType.object, length = -1, clazz = 'Data_Officer'},
    fields       = {'build_type','count','officer_list'}
}

Protocol.Packet_S2C_BuildAllInfo = {
    build_times    = {type = Protocol.DataType.short},
    count          = {type = Protocol.DataType.short},
    builds         = {type = Protocol.DataType.object, length = -1, clazz='Data_Building'},
    count1         = {type = Protocol.DataType.short},
    build_officier = {type = Protocol.DataType.object, length = -1, clazz='Data_BuildingOfficer'},
    fields         = {'build_times','count','builds','count1','build_officier'}
}
Protocol.structs[Protocol.S_2_C_BUILD_ALL_INFO] = Protocol.Packet_S2C_BuildAllInfo

Protocol.Packet_S2C_BulidListInfo = {
    count  = {type = Protocol.DataType.short},
    times  = {type = Protocol.DataType.uint, length = -1},
    fields = {'count','times'}
}
Protocol.structs[Protocol.S_2_C_BUILD_LIST_INFO] = Protocol.Packet_S2C_BulidListInfo

Protocol.Packet_S2C_BuildMainInfo = {
    build  = {type = Protocol.DataType.object, clazz='Data_Building'},
    fields = {'build'}
}
Protocol.structs[Protocol.S_2_C_BUILD_MAIN_INFO] = Protocol.Packet_S2C_BuildMainInfo

Protocol.Packet_S2C_BuildCDList = {
    ret         = {type = Protocol.DataType.short},
    build_id    = {type = Protocol.DataType.int},
    level       = {type = Protocol.DataType.short},
    build_times = {type = Protocol.DataType.short},
    fields      = {'ret', 'build_id', 'level', 'build_times'}
}
Protocol.structs[Protocol.S_2_C_BUILD_CD_LIST] = Protocol.Packet_S2C_BuildCDList

Protocol.Packet_C2S_BuildFinishLevelUp = {
    build_id = {type = Protocol.DataType.int},
    fields   = {'build_id'}
}
Protocol.structs[Protocol.C_2_S_BUILD_FINISH_LEVEL_UP] = Protocol.Packet_C2S_BuildFinishLevelUp

Protocol.Packet_S2C_BuildFinishLevelUp = {
    ret         = {type = Protocol.DataType.short},
    build_id    = {type = Protocol.DataType.int},
    level       = {type = Protocol.DataType.short},
    build_times = {type = Protocol.DataType.short},
    fields      = {'ret', 'build_id', 'level', 'build_times'}
}
Protocol.structs[Protocol.S_2_C_BUILD_FINISH_LEVEL_UP] = Protocol.Packet_S2C_BuildFinishLevelUp

Protocol.Packet_C2S_BuildSpeedUp = {
    build_id     = {type = Protocol.DataType.int},
    material_id  = {type = Protocol.DataType.int},
    material_num = {type = Protocol.DataType.int},
    fields       = {'build_id', 'material_id', 'material_num'}
}
Protocol.structs[Protocol.C_2_S_BUILD_SPEED_UP] = Protocol.Packet_C2S_BuildSpeedUp

Protocol.Packet_S2C_BuildSpeedUp = {
    ret          = {type = Protocol.DataType.short},
    build_id     = {type = Protocol.DataType.int},
    material_id  = {type = Protocol.DataType.int},
    material_num = {type = Protocol.DataType.int},
    fields       = {'ret', 'build_id', 'material_id', 'material_num'}
}
Protocol.structs[Protocol.S_2_C_BUILD_SPEED_UP] = Protocol.Packet_S2C_BuildSpeedUp

Protocol.Packet_C2S_BuildCancelLevelUp = {
    build_id = {type = Protocol.DataType.int},
    fields   = {'build_id'}
}
Protocol.structs[Protocol.C_2_S_BUILD_CANCEL_LEVEL_UP] = Protocol.Packet_C2S_BuildCancelLevelUp

Protocol.Packet_S2C_BuildCancelLevelUp = {
    ret      = {type = Protocol.DataType.short},
    build_id = {type = Protocol.DataType.int},
    level    = {type = Protocol.DataType.short},
    fields   = {'ret', 'build_id', 'level'}
}
Protocol.structs[Protocol.S_2_C_BUILD_CANCEL_LEVEL_UP] = Protocol.Packet_S2C_BuildCancelLevelUp

Protocol.Packet_C2S_BuildAddOfficer = {
    build_type  = {type = Protocol.DataType.short},
    general_id  = {type = Protocol.DataType.int},
    officer_pos = {type = Protocol.DataType.short},
    fields      = {'build_type', 'general_id', 'officer_pos'}
}
Protocol.structs[Protocol.C_2_S_BUILD_ADD_OFFICER] = Protocol.Packet_C2S_BuildAddOfficer

Protocol.Packet_S2C_BuildAddOfficer = {
    ret         = {type = Protocol.DataType.short},
    build_type  = {type = Protocol.DataType.short},
    general_id  = {type = Protocol.DataType.int},
    officer_pos = {type = Protocol.DataType.int},
    fields      = {'ret', 'build_type', 'general_id', 'officer_pos'}
}
Protocol.structs[Protocol.S_2_C_BUILD_ADD_OFFICER] = Protocol.Packet_S2C_BuildAddOfficer

Protocol.Packet_C2S_BuildDelOfficer = {
    build_type  = {type = Protocol.DataType.short},
    officer_pos = {type = Protocol.DataType.short},
    fields      = {'build_type', 'officer_pos'}
}
Protocol.structs[Protocol.C_2_S_BUILD_DEL_OFFICER] = Protocol.Packet_C2S_BuildDelOfficer

Protocol.Packet_S2C_BuildDelOfficer = {
    ret         = {type = Protocol.DataType.short},
    build_type  = {type = Protocol.DataType.short},
    general_id  = {type = Protocol.DataType.int},
    officer_pos = {type = Protocol.DataType.int},
    fields      = {'ret', 'build_type', 'general_id','officer_pos'}
}
Protocol.structs[Protocol.S_2_C_BUILD_DEL_OFFICER] = Protocol.Packet_S2C_BuildDelOfficer

Protocol.Packet_S2C_BuildOfficerStateUpdate = {
    build_type   = {type = Protocol.DataType.short},
    count        = {type = Protocol.DataType.short},
    officer_item = {type = Protocol.DataType.object, length = -1, clazz = 'Data_Officer'},
    fields       = {'build_type', 'count', 'officer_item'}
}
Protocol.structs[Protocol.S_2_C_BUILD_OFFICER_STATE_UPDATE] = Protocol.Packet_S2C_BuildOfficerStateUpdate

Protocol.Data_BuildBusyGeneralUpdate = {
    build_id   = {type = Protocol.DataType.int},
    count      = {type = Protocol.DataType.short},
    general_id = {type = Protocol.DataType.int, length = -1},
    fields     = {'build_id', 'count', 'general_id'}
}

Protocol.Packet_S2C_BuildBusyGeneralUpdate = {
    count  = {type = Protocol.DataType.short},
    builds = {type = Protocol.DataType.object, length = -1, clazz = 'Data_BuildBusyGeneralUpdate'},
    fields = {'count', 'builds'}
}
Protocol.structs[Protocol.S_2_C_BUILD_BUSY_GENERAL_UPDATE] = Protocol.Packet_S2C_BuildBusyGeneralUpdate

Protocol.Data_OfficerResource = {
    build_id = {type = Protocol.DataType.int},
    resource = {type = Protocol.DataType.int},
    fields   = {'build_id','resource'}
}

Protocol.Packet_S2C_BuildResourceUpdate = {
    count          = {type = Protocol.DataType.short},
    build_resource = {type = Protocol.DataType.object, length = -1, clazz = 'Data_OfficerResource'},
    fields         = {'count','build_resource'}
}
Protocol.structs[Protocol.S_2_C_BUILD_RESOURCE_UPDATE] = Protocol.Packet_S2C_BuildResourceUpdate

Protocol.Packet_C2S_BuildGetResource = {
    build_id = {type = Protocol.DataType.int},
    fields   = {'build_id'}
}
Protocol.structs[Protocol.C_2_S_BUILD_GET_RESOURCE] = Protocol.Packet_C2S_BuildGetResource

Protocol.Packet_S2C_BuildGetResource = {
    build_id = {type = Protocol.DataType.int},
    count    = {type = Protocol.DataType.short},
    rwds     = {type = Protocol.DataType.object, length = -1, clazz = 'Packet_Data_RewardType'},
    fields   = {'build_id','count','rwds'}
}
Protocol.structs[Protocol.S_2_C_BUILD_GET_RESOURCE] = Protocol.Packet_S2C_BuildGetResource

Protocol.Data_Unload = {
    build_type = {type = Protocol.DataType.short},
    general_id = {type = Protocol.DataType.int},
    fields     = {'build_type','general_id'}
}

Protocol.Packet_S2C_BuildGeneralUnLoad = {
    count  = {type = Protocol.DataType.short},
    unload = {type = Protocol.DataType.object, length = -1, clazz = 'Data_Unload'},
    fields = {'count','unload'}
}
Protocol.structs[Protocol.S_2_C_BUILD_GENERAL_UNLOAD] = Protocol.Packet_S2C_BuildGeneralUnLoad

Protocol.Packet_C2S_BuildOneKeyAddOfficer = {
    build_type = {type = Protocol.DataType.short},
    fields     = {'build_type'}
}
Protocol.structs[Protocol.C_2_S_BUILD_ONEKEY_ADD_OFFICER] = Protocol.Packet_C2S_BuildOneKeyAddOfficer

Protocol.Data_OneKeyOfficer = {
    general_id  = {type = Protocol.DataType.int},
    officer_pos = {type = Protocol.DataType.int},
    lock_state  = {type = Protocol.DataType.short},
    fields      = {'general_id','officer_pos','lock_state'}
}
Protocol.Packet_S2C_BuildOneKeyAddOfficer = {
    build_type = {type = Protocol.DataType.short},
    count      = {type = Protocol.DataType.short},
    officer    = {type = Protocol.DataType.object, length = -1, clazz = 'Data_OneKeyOfficer'},
    fields     = {'build_type','count','officer'}
}
Protocol.structs[Protocol.S_2_C_BUILD_ONEKEY_ADD_OFFICER] = Protocol.Packet_S2C_BuildOneKeyAddOfficer
