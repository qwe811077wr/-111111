local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_LOAD_EVENT                   = Protocol.C_2_S_COLLECTION_BASE + 0
Protocol.C_2_S_COLLECTION_MONEY             = Protocol.C_2_S_COLLECTION_BASE + 1
Protocol.C_2_S_EVENT_SELECT                 = Protocol.C_2_S_COLLECTION_BASE + 2
Protocol.C_2_S_LOAD_INFO                    = Protocol.C_2_S_COLLECTION_BASE + 3
Protocol.C_2_S_FRAM_HARVEST                 = Protocol.C_2_S_COLLECTION_BASE + 4
Protocol.C_2_S_DECREE                       = Protocol.C_2_S_COLLECTION_BASE + 6
Protocol.C_2_S_COLLECTION_IRON              = Protocol.C_2_S_COLLECTION_BASE + 7
Protocol.C_2_S_COLLECTION_REDIF             = Protocol.C_2_S_COLLECTION_BASE + 8

Protocol.S_2_C_LOAD_EVENT                   = Protocol.S_2_C_COLLECTION_BASE + 0
Protocol.S_2_C_COLLECTION_MONEY             = Protocol.S_2_C_COLLECTION_BASE + 1
Protocol.S_2_C_EVENT_SELECT                 = Protocol.S_2_C_COLLECTION_BASE + 3
Protocol.S_2_C_LOAD_INFO                    = Protocol.S_2_C_COLLECTION_BASE + 4
Protocol.S_2_C_FRAM_HARVEST                 = Protocol.S_2_C_COLLECTION_BASE + 5
Protocol.S_2_C_SWORN_CONDITION_INFO         = Protocol.S_2_C_COLLECTION_BASE + 7
Protocol.S_2_C_REQUEST_BATTLE_HARD_PVE      = Protocol.S_2_C_COLLECTION_BASE + 8
Protocol.S_2_C_DECREE                       = Protocol.S_2_C_COLLECTION_BASE + 10
Protocol.S_2_C_COLLECTION_IRON              = Protocol.S_2_C_COLLECTION_BASE + 11
Protocol.S_2_C_COLLECTION_REDIF             = Protocol.S_2_C_COLLECTION_BASE + 12

Protocol.Packet_C2S_EventSelect = {
    index         = {type = Protocol.DataType.short}, --选择编号
    event_index   = {type = Protocol.DataType.short},  --答案数组编号
    fields        = {'event_index','index'}
}
Protocol.structs[Protocol.C_2_S_EVENT_SELECT] = Protocol.Packet_C2S_EventSelect

Protocol.Packet_C2S_Decreee = {
  id              = {type = Protocol.DataType.int},
  count           = {type = Protocol.DataType.short},
  fields          = {'id','count'}
}
Protocol.structs[Protocol.C_2_S_DECREE] = Protocol.Packet_C2S_Decreee

Protocol.Packet_S2C_LoadEvent = {
      count                            = {type = Protocol.DataType.short},
      event_ids                        = {type = Protocol.DataType.short, length = -1},
      fields                           = {'count','event_ids'}
}
Protocol.structs[Protocol.S_2_C_LOAD_EVENT]  = Protocol.Packet_S2C_LoadEvent

Protocol.Packet_S2C_CollectionMoney = {
     gold_num            = {type = Protocol.DataType.int},
     count               = {type = Protocol.DataType.short},
     event_ids           = {type = Protocol.DataType.short, length = -1},
     fields              = {'gold_num', 'count', 'event_ids'}
}
Protocol.structs[Protocol.S_2_C_COLLECTION_MONEY]  = Protocol.Packet_S2C_CollectionMoney

Protocol.Packet_S2C_EventSelect = {
    ret         = {type = Protocol.DataType.short},
    index       = {type = Protocol.DataType.short},
    event_index = {type = Protocol.DataType.short},
    fields      = {'ret','index','event_index'}
}
Protocol.structs[Protocol.S_2_C_EVENT_SELECT]  = Protocol.Packet_S2C_EventSelect

Protocol.Data_LoadInfo = {
    type_build    = {type = Protocol.DataType.short},
    value         = {type = Protocol.DataType.int},
    fields        = {'type_build','value'}
}

Protocol.Packet_S2C_LoadInfo = {
    count       = {type = Protocol.DataType.short},
    items       = {type = Protocol.DataType.object, length = -1, clazz='Data_LoadInfo'},
    fields      = {'count', 'items'}
}
Protocol.structs[Protocol.S_2_C_LOAD_INFO] = Protocol.Packet_S2C_LoadInfo

Protocol.Packet_S2C_FramHarvest = {
    ret         = {type = Protocol.DataType.short},
    food        = {type = Protocol.DataType.int},
    fields      = {'ret','food'}
}
Protocol.structs[Protocol.S_2_C_FRAM_HARVEST]  = Protocol.Packet_S2C_FramHarvest


Protocol.Data_SwornCondition = {
    ident    = {type = Protocol.DataType.int},
    progress = {type = Protocol.DataType.int},
    fields   = {'ident','progress'}
}

Protocol.Packet_S2C_SwornConditionInfo = {
    generalId      = {type = Protocol.DataType.int},
    count          = {type = Protocol.DataType.int},
    swornCondition = {type = Protocol.DataType.object, length = -1, clazz='Data_SwornCondition'},
    fields         = {'generalId','count','swornCondition'}
}
Protocol.structs[Protocol.S_2_C_SWORN_CONDITION_INFO]  = Protocol.Packet_S2C_SwornConditionInfo

Protocol.Packet_S2C_RequestBattleHard_PVE = {
    npcid       = {type = Protocol.DataType.int},
    instance_id = {type = Protocol.DataType.int},
    ret         = {type = Protocol.DataType.int}, --0 成功, 1 军令不
    fields      = {'npcid','instance_id','ret'}
}
Protocol.structs[Protocol.S_2_C_REQUEST_BATTLE_HARD_PVE]  = Protocol.Packet_S2C_RequestBattleHard_PVE

Protocol.Data_BuildDecree = {
    build_id      = {type = Protocol.DataType.short},
    rate          = {type = Protocol.DataType.short},
    fields        = {'build_id','rate'}
}

Protocol.Data_Decree = {
    build_count    = {type = Protocol.DataType.short},
    builds         = {type = Protocol.DataType.object, length = -1, clazz='Data_BuildDecree'},
    fields         = {'build_count','builds'}
}

Protocol.Packet_S2C_Decree = {
    id             = {type = Protocol.DataType.int},
    count          = {type = Protocol.DataType.short},
    items          = {type = Protocol.DataType.object, length = -1, clazz='Data_Decree'},
    fields         = {'id','count','items'}
}
Protocol.structs[Protocol.S_2_C_DECREE]  = Protocol.Packet_S2C_Decree

Protocol.Packet_S2C_CollectionIron = {
    ret            = {type = Protocol.DataType.short},
    iron           = {type = Protocol.DataType.int},
    fields         = {'ret','iron'}
}
Protocol.structs[Protocol.S_2_C_COLLECTION_IRON]  = Protocol.Packet_S2C_CollectionIron

Protocol.Packet_S2C_CollectionRedif = {
    ret    = {type = Protocol.DataType.short},
    redif  = {type = Protocol.DataType.int},
    fields = {'ret','redif'}
}
Protocol.structs[Protocol.S_2_C_COLLECTION_REDIF]  = Protocol.Packet_S2C_CollectionRedif
