local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_RANDOM_EVENT_INFO_LOAD                 = Protocol.C_2_S_RANDOM_EVENT_BASE + 1
Protocol.C_2_S_RANDOM_EVENT_DRAW_BOX                  = Protocol.C_2_S_RANDOM_EVENT_BASE + 2
Protocol.C_2_S_RANDOM_EVENT_DRAW_EGG                  = Protocol.C_2_S_RANDOM_EVENT_BASE + 3
Protocol.C_2_S_RANDOM_EVENT_BUILD_DRAW                = Protocol.C_2_S_RANDOM_EVENT_BASE + 4

Protocol.S_2_C_RANDOM_EVENT_INFO_LOAD                 = Protocol.S_2_C_RANDOM_EVENT_BASE + 1
Protocol.S_2_C_RANDOM_EVENT_UPDATE_INFO               = Protocol.S_2_C_RANDOM_EVENT_BASE + 2
Protocol.S_2_C_RANDOM_EVENT_DRAW_BOX                  = Protocol.S_2_C_RANDOM_EVENT_BASE + 3
Protocol.S_2_C_RANDOM_EVENT_DRAW_EGG                  = Protocol.S_2_C_RANDOM_EVENT_BASE + 4
Protocol.S_2_C_RANDOM_EVENT_NOTICE_BUILD              = Protocol.S_2_C_RANDOM_EVENT_BASE + 5
Protocol.S_2_C_RANDOM_EVENT_BUILD_DRAW                = Protocol.S_2_C_RANDOM_EVENT_BASE + 6

Protocol.Data_RandomBox = {
    id        = {type = Protocol.DataType.short},
    draw_time = {type = Protocol.DataType.int},
    fields    = {'id', 'draw_time'}
}

Protocol.Data_Relation = {
    build_type = {type = Protocol.DataType.short},
    event_id   = {type = Protocol.DataType.int},
    fields     = {'build_type', 'event_id'}
}

Protocol.Data_Egg = {
    id        = {type = Protocol.DataType.short},
    draw_time = {type = Protocol.DataType.int},
    choose    = {type = Protocol.DataType.short},
    fields    = {'id', 'draw_time', 'choose'}
}

Protocol.Packet_S2C_RandomEventInfoLoad = {
    box_count      = {type = Protocol.DataType.short},
    box            = {type = Protocol.DataType.object, length = -1, clazz = 'Data_RandomBox'},
    egg_count      = {type = Protocol.DataType.short},
    egg            = {type = Protocol.DataType.object, length = -1, clazz = 'Data_Egg'},
    relation_count = {type = Protocol.DataType.short},
    relation       = {type = Protocol.DataType.object, length = -1, clazz = 'Data_Relation'},
    fields         = {'box_count', 'box', 'egg_count', 'egg', 'relation_count', 'relation'}
}
Protocol.structs[Protocol.S_2_C_RANDOM_EVENT_INFO_LOAD] = Protocol.Packet_S2C_RandomEventInfoLoad

-- 0.egg, 1.box
Protocol.Packet_S2C_RandomEventUpdateInfo = {
    event_type = {type = Protocol.DataType.short},
    event_id   = {type = Protocol.DataType.short},
    fields     = {'event_type', 'event_id'}
}
Protocol.structs[Protocol.S_2_C_RANDOM_EVENT_UPDATE_INFO] = Protocol.Packet_S2C_RandomEventUpdateInfo

Protocol.Packet_C2S_RandomEventDrawBox = {
    id     = {type = Protocol.DataType.short},
    fields = {'id'}
}
Protocol.structs[Protocol.C_2_S_RANDOM_EVENT_DRAW_BOX] = Protocol.Packet_C2S_RandomEventDrawBox

Protocol.Packet_S2C_RandomEventDrawBox = {
    id     = {type = Protocol.DataType.short},
    multi  = {type = Protocol.DataType.short},
    count  = {type = Protocol.DataType.short},
    rwds   = {type = Protocol.DataType.object, length = -1, clazz = 'Packet_Data_RewardType'},
    fields = {'id', 'multi', 'count', 'rwds'}
}
Protocol.structs[Protocol.S_2_C_RANDOM_EVENT_DRAW_BOX] = Protocol.Packet_S2C_RandomEventDrawBox

Protocol.Packet_C2S_RandomEventDrawEgg = {
    id       = {type = Protocol.DataType.short},
    answerid = {type = Protocol.DataType.short},
    fields   = {'id', 'answerid'}
}
Protocol.structs[Protocol.C_2_S_RANDOM_EVENT_DRAW_EGG] = Protocol.Packet_C2S_RandomEventDrawEgg

Protocol.Packet_S2C_RandomEventDrawEgg = {
    id       = {type = Protocol.DataType.short},
    answerid = {type = Protocol.DataType.short},
    multi    = {type = Protocol.DataType.short},
    count    = {type = Protocol.DataType.short},
    rwds     = {type = Protocol.DataType.object, length = -1, clazz = 'Packet_Data_RewardType'},
    fields   = {'id', 'answerid', 'multi', 'count', 'rwds'}
}
Protocol.structs[Protocol.S_2_C_RANDOM_EVENT_DRAW_EGG] = Protocol.Packet_S2C_RandomEventDrawEgg

Protocol.Packet_S2C_RandomEventNoticeBuild = {
    count     = {type = Protocol.DataType.short},
    relations = {type = Protocol.DataType.object, length = -1, clazz = 'Data_Relation'},
    fields    = {'count', 'relations'}
}
Protocol.structs[Protocol.S_2_C_RANDOM_EVENT_NOTICE_BUILD] = Protocol.Packet_S2C_RandomEventNoticeBuild

Protocol.Packet_C2S_RandomEventBuildDraw = {
    build_type = {type = Protocol.DataType.short},
    fields     = {'build_type'}
}
Protocol.structs[Protocol.C_2_S_RANDOM_EVENT_BUILD_DRAW] = Protocol.Packet_C2S_RandomEventBuildDraw

Protocol.Packet_S2C_RandomEventBuildDraw = {
    ret        = {type = Protocol.DataType.short},
    build_type = {type = Protocol.DataType.short},
    fields     = {'ret', 'build_type'}
}
Protocol.structs[Protocol.S_2_C_RANDOM_EVENT_BUILD_DRAW] = Protocol.Packet_S2C_RandomEventBuildDraw
