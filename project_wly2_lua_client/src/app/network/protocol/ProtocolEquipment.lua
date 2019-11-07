local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_EQUIPMENT_ACTION             = Protocol.C_2_S_EQUIPMENT_BASE + 0
Protocol.C_2_S_EQUIPMENT_LOADALL            = Protocol.C_2_S_EQUIPMENT_BASE + 1
Protocol.C_2_S_EQUIP_ITEM                   = Protocol.C_2_S_EQUIPMENT_BASE + 2
Protocol.C_2_S_UNEQUIP_ITEM                 = Protocol.C_2_S_EQUIPMENT_BASE + 3
Protocol.C_2_S_LOAD_SINGLE_EQUIPMENT_INFO   = Protocol.C_2_S_EQUIPMENT_BASE + 4
Protocol.C_2_S_COMPOSITE_PUTIN_ITEM         = Protocol.C_2_S_EQUIPMENT_BASE + 5
Protocol.C_2_S_COMPOSITE_TAKEOUT_ITEM       = Protocol.C_2_S_EQUIPMENT_BASE + 6
Protocol.C_2_S_COMPOSITE_ITEM               = Protocol.C_2_S_EQUIPMENT_BASE + 7
Protocol.C_2_S_EQUIP_GF_ITEM                = Protocol.C_2_S_EQUIPMENT_BASE + 8
Protocol.C_2_S_UNEQUIP_GF_ITEM              = Protocol.C_2_S_EQUIPMENT_BASE + 9
Protocol.C_2_S_EXCHANGE_ITEM                = Protocol.C_2_S_EQUIPMENT_BASE + 10
Protocol.C_2_S_EQUIP_BIND                   = Protocol.C_2_S_EQUIPMENT_BASE + 11
Protocol.C_2_S_ONE_KEY_COMPOSITE_ITEM       = Protocol.C_2_S_EQUIPMENT_BASE + 12
Protocol.C_2_S_EQUIPMENT_CASTING            = Protocol.C_2_S_EQUIPMENT_BASE + 13
Protocol.C_2_S_BATCH_EQUIP_ITEMS            = Protocol.C_2_S_EQUIPMENT_BASE + 15
Protocol.C_2_S_EQUIPMENT_SELL               = Protocol.C_2_S_EQUIPMENT_BASE + 17
Protocol.C_2_S_BUY_WAREHOUSE_CELL           = Protocol.C_2_S_EQUIPMENT_BASE + 18
Protocol.C_2_S_DRAW_EQUIPMENT               = Protocol.C_2_S_EQUIPMENT_BASE + 19
Protocol.C_2_S_LOAD_LOG_EQUIPMENT           = Protocol.C_2_S_EQUIPMENT_BASE + 20
Protocol.C_2_S_EQUIPMENT_MULTIPLE_SELL      = Protocol.C_2_S_EQUIPMENT_BASE + 21
Protocol.C_2_S_EQUIPMENT_BREAK_THROUGH      = Protocol.C_2_S_EQUIPMENT_BASE + 22

Protocol.S_2_C_EQUIPMENT_ACTION             = Protocol.S_2_C_EQUIPMENT_BASE + 0
Protocol.S_2_C_EQUIPMENT_LOADALL_BEGIN      = Protocol.S_2_C_EQUIPMENT_BASE + 1
Protocol.S_2_C_EQUIPMENT_LOADALL            = Protocol.S_2_C_EQUIPMENT_BASE + 2
Protocol.S_2_C_EQUIPMENT_LOADALL_END        = Protocol.S_2_C_EQUIPMENT_BASE + 3
Protocol.S_2_C_ITEM_CHAGE_RES               = Protocol.S_2_C_EQUIPMENT_BASE + 4
Protocol.S_2_C_ADD_NEW_EQUIPMENT            = Protocol.S_2_C_EQUIPMENT_BASE + 5
Protocol.S_2_C_UPDATE_INTERSIFY_RATE        = Protocol.S_2_C_EQUIPMENT_BASE + 6
Protocol.S_2_C_LOAD_SINGLE_EQUIPMENT_INFO   = Protocol.S_2_C_EQUIPMENT_BASE + 7
Protocol.S_2_C_RECEIVE_STORE_REWARD         = Protocol.S_2_C_EQUIPMENT_BASE + 8
Protocol.S_2_C_EQUIPMENT_DELETE             = Protocol.S_2_C_EQUIPMENT_BASE + 9
Protocol.S_2_C_EQUIPMENT_CASTING            = Protocol.S_2_C_EQUIPMENT_BASE + 10
Protocol.S_2_C_BATCH_EQUIP_ITEMS            = Protocol.S_2_C_EQUIPMENT_BASE + 12
Protocol.S_2_C_EQUIPMENT_SELL               = Protocol.S_2_C_EQUIPMENT_BASE + 14
Protocol.S_2_C_BUY_WAREHOUSE_CELL           = Protocol.S_2_C_EQUIPMENT_BASE + 15
Protocol.S_2_C_DRAW_EQUIPMENT               = Protocol.S_2_C_EQUIPMENT_BASE + 16
Protocol.S_2_C_LOAD_LOG_EQUIPMENT           = Protocol.S_2_C_EQUIPMENT_BASE + 17
Protocol.S_2_C_EQUIPMENT_MULTIPLE_SELL      = Protocol.S_2_C_EQUIPMENT_BASE + 18
Protocol.S_2_C_EQUIPMENT_BREAK_THROUGH      = Protocol.S_2_C_EQUIPMENT_BASE + 19



Protocol.S_2_C_COMPOSITE_PUTIN_ITEM             = Protocol.S_2_C_EQUIPMENT_EXT_BASE + 0
Protocol.S_2_C_COMPOSITE_TAKEOUT_ITEM           = Protocol.S_2_C_EQUIPMENT_EXT_BASE + 1
Protocol.S_2_C_COMPOSITE_ITEM                   = Protocol.S_2_C_EQUIPMENT_EXT_BASE + 2
Protocol.S_2_C_EQUIP_GF_ITEM                    = Protocol.S_2_C_EQUIPMENT_EXT_BASE + 3
Protocol.S_2_C_UNEQUIP_GF_ITEM                  = Protocol.S_2_C_EQUIPMENT_EXT_BASE + 4
Protocol.S_2_C_EXCHANGE_ITEM                    = Protocol.S_2_C_EQUIPMENT_EXT_BASE + 5
Protocol.S_2_C_EQUIP_BIND                       = Protocol.S_2_C_EQUIPMENT_EXT_BASE + 6
Protocol.S_2_C_UPDATE_ONE_KEY_COMPOSITE_ITEM    = Protocol.S_2_C_EQUIPMENT_EXT_BASE + 7
Protocol.S_2_C_RECEIVE_STORE_REWARD             = Protocol.S_2_C_EQUIPMENT_EXT_BASE + 8


------------------------------C_2_S------------------------------
Protocol.Packet_C2S_EquipmentAction = {
    equipmentId             = {type = Protocol.DataType.uint},
    actionId                = {type = Protocol.DataType.char},
    isForceIntersify        = {type = Protocol.DataType.char},
    upLevel                 = {type = Protocol.DataType.int},
    fields                  = {'equipmentId','actionId','isForceIntersify','upLevel'}
}
Protocol.structs[Protocol.C_2_S_EQUIPMENT_ACTION]           = Protocol.Packet_C2S_EquipmentAction

Protocol.Packet_C2S_EquipItem = {
    general_id      = {type = Protocol.DataType.uint},
    item_id         = {type = Protocol.DataType.uint},
    fields          = {'general_id','item_id'}
}
Protocol.structs[Protocol.C_2_S_EQUIP_ITEM]                 = Protocol.Packet_C2S_EquipItem

Protocol.Packet_C2S_UnEquitItem = {
    general_id      = {type = Protocol.DataType.uint},
    item_id         = {type = Protocol.DataType.uint},
    fields          = {'general_id','item_id'}
}
Protocol.structs[Protocol.C_2_S_UNEQUIP_ITEM]               = Protocol.Packet_C2S_UnEquitItem

Protocol.Packet_C2S_LoadSingleEquipmentInfo = {
    epDbId          = {type = Protocol.DataType.uint},
    fields          = {'epDbId'}
}
Protocol.structs[Protocol.C_2_S_LOAD_SINGLE_EQUIPMENT_INFO]               = Protocol.Packet_C2S_LoadSingleEquipmentInfo

Protocol.Packet_C2S_CompositePutInItem = {
    destPosType        = {type = Protocol.DataType.char},
    resPosType         = {type = Protocol.DataType.char},
    newItemId          = {type = Protocol.DataType.uint},
    fields             = {'destPosType','resPosType','newItemId'}
}
Protocol.structs[Protocol.C_2_S_COMPOSITE_PUTIN_ITEM]       = Protocol.Packet_C2S_CompositePutInItem

Protocol.Packet_C2S_CompositeTakeOutItem = {
    posType            = {type = Protocol.DataType.char},
    itemId             = {type = Protocol.DataType.uint},
    fields             = {'posType',"itemId"}
}
Protocol.structs[Protocol.C_2_S_COMPOSITE_TAKEOUT_ITEM]     = Protocol.Packet_C2S_CompositeTakeOutItem

Protocol.Packet_C2S_CompositeItem = {
    itemId1         = {type = Protocol.DataType.uint},
    itemId2         = {type = Protocol.DataType.uint},
    fields          = {'itemId1','itemId2'}
}
Protocol.structs[Protocol.C_2_S_COMPOSITE_ITEM]             = Protocol.Packet_C2S_CompositeItem

Protocol.Packet_C2S_EquipGFItem = {
    destPos         = {type = Protocol.DataType.char},
    resPos          = {type = Protocol.DataType.char},
    newItemId       = {type = Protocol.DataType.uint},
    fields          = {'destPos','resPos','newItemId'}
}
Protocol.structs[Protocol.C_2_S_EQUIP_GF_ITEM]              = Protocol.Packet_C2S_EquipGFItem

Protocol.Packet_C2S_DrawEquipment = {
    equipmentId                 = {type = Protocol.DataType.uint},
    fields                      = {'equipmentId'}
}
Protocol.structs[Protocol.C_2_S_DRAW_EQUIPMENT]                             = Protocol.Packet_C2S_DrawEquipment

Protocol.Packet_C2S_UnEquipGFItem = {
    pos             = {type = Protocol.DataType.char},
    fields          = {'pos'}
}
Protocol.structs[Protocol.C_2_S_UNEQUIP_GF_ITEM]            = Protocol.Packet_C2S_UnEquipGFItem

Protocol.Packet_C2S_ExchangeItem = {
    generalId1      = {type = Protocol.DataType.int},
    generalId2      = {type = Protocol.DataType.int},
    fields          = {'generalId1','generalId2'}
}
Protocol.structs[Protocol.C_2_S_EXCHANGE_ITEM]              = Protocol.Packet_C2S_ExchangeItem

Protocol.Packet_C2S_EquipBind = {
    eqid            = {type = Protocol.DataType.int},
    bind_type       = {type = Protocol.DataType.short},
    fields          = {'eqid','bind_type'}
}
Protocol.structs[Protocol.C_2_S_EQUIP_BIND]                 = Protocol.Packet_C2S_EquipBind

Protocol.Packet_C2S_OneKeyCompositeItem = {
    fields          = {}
}
Protocol.structs[Protocol.C_2_S_ONE_KEY_COMPOSITE_ITEM]     = Protocol.Packet_C2S_OneKeyCompositeItem

Protocol.Packet_C2S_EquipmentCasting = {
    eqid            = {type = Protocol.DataType.int},
    fields          = {'eqid'}
}
Protocol.structs[Protocol.C_2_S_EQUIPMENT_CASTING]     = Protocol.Packet_C2S_EquipmentCasting

Protocol.Packet_C2S_BatchEquipItems = {
    general_id      = {type = Protocol.DataType.int},
    equip_ids       = {type = Protocol.DataType.int, length = 7},
    fields          = {'general_id','equip_ids'}
}
Protocol.structs[Protocol.C_2_S_BATCH_EQUIP_ITEMS]     = Protocol.Packet_C2S_BatchEquipItems

Protocol.Packet_C2S_EquipmentSell = {
    id              = {type = Protocol.DataType.int},
    fields          = {'id'}
}
Protocol.structs[Protocol.C_2_S_EQUIPMENT_SELL]     = Protocol.Packet_C2S_EquipmentSell

Protocol.Packet_C2S_EquipmentMultipleSell = {
    count           = {type = Protocol.DataType.short},
    dbid            = {type = Protocol.DataType.longlong,length = -1},
    fields          = {'count','dbid'}
}
Protocol.structs[Protocol.C_2_S_EQUIPMENT_MULTIPLE_SELL]     = Protocol.Packet_C2S_EquipmentMultipleSell

Protocol.Packet_C2S_EquipmentBreakThrough = {
    db_id           = {type = Protocol.DataType.longlong},
    count           = {type = Protocol.DataType.short},
    db_ids          = {type = Protocol.DataType.longlong, length = -1},
    fields          = {"db_id", "count", "db_ids"}
}
Protocol.structs[Protocol.C_2_S_EQUIPMENT_BREAK_THROUGH]     = Protocol.Packet_C2S_EquipmentBreakThrough

------------------------------S_2_C------------------------------
Protocol.Packet_S2C_EquipmentAction = {
    ret                         = {type = Protocol.DataType.char},
    epId                        = {type = Protocol.DataType.uint},
    actionId                    = {type = Protocol.DataType.char},
    packetPara                  = {type = Protocol.DataType.uint},
    epLevel                     = {type = Protocol.DataType.int},
    fields                      = {'ret','epId','actionId','packetPara','epLevel'}
}
Protocol.structs[Protocol.S_2_C_EQUIPMENT_ACTION]               = Protocol.Packet_S2C_EquipmentAction

Protocol.Packet_S2C_EquipmentLoadBegin = {
    fields          = {}
}
Protocol.structs[Protocol.S_2_C_EQUIPMENT_LOADALL_BEGIN]        = Protocol.Packet_S2C_EquipmentLoadBegin

Protocol.Packet_S2C_EquipmentLoadEnd = {
    fields          = {}
}
Protocol.structs[Protocol.S_2_C_EQUIPMENT_LOADALL_END]          = Protocol.Packet_S2C_EquipmentLoadEnd

Protocol.Data_Equipments = {
    db_id                         = {type = Protocol.DataType.int},
    temp_id                       = {type = Protocol.DataType.int},
    general_id                    = {type = Protocol.DataType.int},
    expire_time                   = {type = Protocol.DataType.int},
    bind_type                     = {type = Protocol.DataType.char},
    lvl                           = {type = Protocol.DataType.short},
    add_count                     = {type = Protocol.DataType.short},
    attributes                    = {type = Protocol.DataType.object, length = -1, clazz = 'Data_GeneralAttrInfo'},
    star                          = {type = Protocol.DataType.int},
    fields                        = {'db_id','temp_id','general_id','expire_time','bind_type','lvl','add_count','attributes', 'star'}
}

Protocol.Packet_S2C_EquipmentLoadAllResult = {
    count                       = {type = Protocol.DataType.short},
    equipment_data              = {type = Protocol.DataType.object, length = -1, clazz='Data_Equipments'},
    fields                      = {'count','equipment_data'}
}
Protocol.structs[Protocol.S_2_C_EQUIPMENT_LOADALL]              = Protocol.Packet_S2C_EquipmentLoadAllResult

Protocol.Packet_S2C_ItemChangeRes = {
    res                         = {type = Protocol.DataType.char},
    general_id                  = {type = Protocol.DataType.int},
    req_item_id                 = {type = Protocol.DataType.int},
    res_item_pos                = {type = Protocol.DataType.char},
    effect_item_id              = {type = Protocol.DataType.int},
    effect_item_pos             = {type = Protocol.DataType.char},
    fields                      = {'res','general_id','req_item_id','res_item_pos','effect_item_id','effect_item_pos'}
}
Protocol.structs[Protocol.S_2_C_ITEM_CHAGE_RES]                 = Protocol.Packet_S2C_ItemChangeRes

Protocol.Packet_S2C_AddNewEquipment = {
    epId                        = {type = Protocol.DataType.uint},
    epTemplateId                = {type = Protocol.DataType.uint},
    epLevel                     = {type = Protocol.DataType.short},
    epValue                     = {type = Protocol.DataType.double},
    epSoldierNum                = {type = Protocol.DataType.uint},
    epCritRate                  = {type = Protocol.DataType.double},
    epBeatBackRate              = {type = Protocol.DataType.double},
    epDecInjureRate             = {type = Protocol.DataType.double},
    epFighterId                 = {type = Protocol.DataType.uint},
    epExpireTime                = {type = Protocol.DataType.int},
    etchedAttack                = {type = Protocol.DataType.int},
    etchedDefense               = {type = Protocol.DataType.int},
    etchSoldierNum              = {type = Protocol.DataType.int},
    fields                      = {'epId','epTemplateId','epLevel','epValue','epSoldierNum','epCritRate','epBeatBackRate','epDecInjureRate','epFighterId','epExpireTime',
                                    'etchedAttack','etchedDefense','etchSoldierNum'}
}
Protocol.structs[Protocol.S_2_C_ADD_NEW_EQUIPMENT]              = Protocol.Packet_S2C_AddNewEquipment

Protocol.Packet_S2C_UpdateIntersifyRate = {
    rate                        = {type = Protocol.DataType.char},
    gradeFlag                   = {type = Protocol.DataType.char},
    fields                      = {'rate','gradeFlag'}
}
Protocol.structs[Protocol.S_2_C_UPDATE_INTERSIFY_RATE]                = Protocol.Packet_S2C_UpdateIntersifyRate

Protocol.Packet_S2C_LoadSingleEquipmentInfo = {
    epDbId                      = {type = Protocol.DataType.uint},
    epLevel                     = {type = Protocol.DataType.short},
    epValue                     = {type = Protocol.DataType.double},
    epSoldierNum                = {type = Protocol.DataType.uint},
    epCritRate                  = {type = Protocol.DataType.double},
    epBeatBackRate              = {type = Protocol.DataType.double},
    epDecInjureRate             = {type = Protocol.DataType.double},
    leavetime                   = {type = Protocol.DataType.int},
    etchedAttack                = {type = Protocol.DataType.int},
    etchedDefense               = {type = Protocol.DataType.int},
    etchSoldierNum              = {type = Protocol.DataType.int},
    bindType                    = {type = Protocol.DataType.char},
    fields                      = {'epDbId','epLevel','epValue','epSoldierNum','epCritRate','epBeatBackRate','epDecInjureRate','leavetime',
                                    'etchedAttack','etchedDefense','etchSoldierNum','bindType'}
}
Protocol.structs[Protocol.S_2_C_LOAD_SINGLE_EQUIPMENT_INFO]                 = Protocol.Packet_S2C_LoadSingleEquipmentInfo

Protocol.Packet_S2C_ReceiveReward = {
    equipmentId                  = {type = Protocol.DataType.uint},
    equipmentTypeId              = {type = Protocol.DataType.uint},
    epCritRate                   = {type = Protocol.DataType.double},
    epBeatBackRate               = {type = Protocol.DataType.double},
    epDecInjureRate              = {type = Protocol.DataType.double},
    expireTime                   = {type = Protocol.DataType.uint},
    fields                       = {'equipmentId','equipmentTypeId','epCritRate','epBeatBackRate','epDecInjureRate','expireTime'}
}
Protocol.structs[Protocol.S_2_C_RECEIVE_STORE_REWARD]               = Protocol.Packet_S2C_ReceiveReward

Protocol.Packet_S2C_Equipment_Delete = {
    eqId                        = {type = Protocol.DataType.int},
    fields                     = {'eqId'}
}
Protocol.structs[Protocol.S_2_C_EQUIPMENT_DELETE]              = Protocol.Packet_S2C_Equipment_Delete

Protocol.Packet_S2C_EquipmentCasting = {
    src_equip_id               = {type = Protocol.DataType.int},
    new_equip_id               = {type = Protocol.DataType.int},
    new_temp_id                = {type = Protocol.DataType.int},
    level                      = {type = Protocol.DataType.short},
    fields                     = {'src_equip_id','new_equip_id','new_temp_id','level'}
}
Protocol.structs[Protocol.S_2_C_EQUIPMENT_CASTING]              = Protocol.Packet_S2C_EquipmentCasting

Protocol.Packet_S2C_BatchEquipItems = {
    general_id                 = {type = Protocol.DataType.int},
    count                      = {type = Protocol.DataType.short},
    equip_ids                  = {type = Protocol.DataType.int,length = -1},
    fields                     = {'general_id','count','equip_ids'}
}
Protocol.structs[Protocol.S_2_C_BATCH_EQUIP_ITEMS]              = Protocol.Packet_S2C_BatchEquipItems

Protocol.Packet_S2C_EquipmentSell = {
    ret                        = {type = Protocol.DataType.short},
    id                         = {type = Protocol.DataType.int},
    fields                     = {'ret','id'}
}
Protocol.structs[Protocol.S_2_C_EQUIPMENT_SELL]              = Protocol.Packet_S2C_EquipmentSell

Protocol.Packet_S2C_BuyWarehouseCell = {
    draw_time                  = {type = Protocol.DataType.int},
    total_warehouse_num        = {type = Protocol.DataType.short},
    fields                     = {'draw_time','total_warehouse_num'}
}
Protocol.structs[Protocol.S_2_C_BUY_WAREHOUSE_CELL]              = Protocol.Packet_S2C_BuyWarehouseCell


------------------------------S_2_C_EQUIPMENT_EXT_BASE------------------------------

Protocol.Packet_S2C_ExchangeItem = {
    ret                        = {type = Protocol.DataType.char},
    fields                     = {'ret'}
}
Protocol.structs[Protocol.S_2_C_EXCHANGE_ITEM]              = Protocol.Packet_S2C_ExchangeItem

Protocol.Packet_S2C_EquipBind = {
    eqid                       = {type = Protocol.DataType.int},
    bind_type                  = {type = Protocol.DataType.short},
    fields                     = {'eqid', 'bind_type'}
}
Protocol.structs[Protocol.S_2_C_EQUIP_BIND]                 = Protocol.Packet_S2C_EquipBind

Protocol.Packet_S2C_DrawEquipment = {
    ret                                 = {type = Protocol.DataType.short},
    equipmentId                         = {type = Protocol.DataType.uint},
    fields                              = {'ret','equipmentId'}
}
Protocol.structs[Protocol.S_2_C_DRAW_EQUIPMENT]                         = Protocol.Packet_S2C_DrawEquipment

Protocol.Packet_Data_EquipmentLogObj = {
    eqid                       = {type = Protocol.DataType.int},
    fields                     = {'eqid'}
}

Protocol.Packet_S2C_EquipmentLogLoad = {
    count                      = {type = Protocol.DataType.short},
    logs                       = {type = Protocol.DataType.object, length = -1, clazz='Packet_Data_EquipmentLogObj'},
    fields                     = {'count','logs'}
}
Protocol.structs[Protocol.S_2_C_LOAD_LOG_EQUIPMENT]                         = Protocol.Packet_S2C_EquipmentLogLoad

Protocol.Packet_S2C_EquipmentMultipleSell = {
    count                      = {type = Protocol.DataType.short},
    rwds                       = {type = Protocol.DataType.object, length = -1, clazz='Packet_Data_RewardType'},
    equip_count                = {type = Protocol.DataType.short},
    dbid                       = {type = Protocol.DataType.longlong, length = -1},
    fields                     = {'count','rwds','equip_count','dbid'}
}
Protocol.structs[Protocol.S_2_C_EQUIPMENT_MULTIPLE_SELL]                         = Protocol.Packet_S2C_EquipmentMultipleSell

Protocol.Packet_S2C_EquipmentBreakThrough = {
    db_id                      = {type = Protocol.DataType.longlong},
    star                       = {type = Protocol.DataType.int},
    count                      = {type = Protocol.DataType.short},
    db_ids                     = {type = Protocol.DataType.longlong, length = -1},
    fields                     = {"db_id", "star", "count", "db_ids"}
}
Protocol.structs[Protocol.S_2_C_EQUIPMENT_BREAK_THROUGH]                          = Protocol.Packet_S2C_EquipmentBreakThrough