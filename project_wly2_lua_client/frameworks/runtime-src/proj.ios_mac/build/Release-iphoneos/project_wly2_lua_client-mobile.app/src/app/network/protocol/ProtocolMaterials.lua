local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_MATERIALS_LOAD                          = Protocol.C_2_S_MATERIALS_BASE + 0;
Protocol.C_2_S_ADVANCE_ITEM_COMPOSE                    = Protocol.C_2_S_MATERIALS_BASE + 1;
Protocol.C_2_S_STONE_COMPOSE                           = Protocol.C_2_S_MATERIALS_BASE + 2;
Protocol.C_2_S_USE_CHEST                               = Protocol.C_2_S_MATERIALS_BASE + 3;
Protocol.C_2_S_DO_SELL                                 = Protocol.C_2_S_MATERIALS_BASE + 4;
Protocol.C_2_S_USE_FUNCPROPS                           = Protocol.C_2_S_MATERIALS_BASE + 5;
Protocol.C_2_S_MULTIPLE_DO_SELL                        = Protocol.C_2_S_MATERIALS_BASE + 6;

Protocol.S_2_C_MATERIALS_LOAD                           = Protocol.S_2_C_MATERIALS_BASE + 0;
Protocol.S_2_C_ADVANCE_ITEM_COMPOSE                     = Protocol.S_2_C_MATERIALS_BASE + 1;
Protocol.S_2_C_STONE_COMPOSE                            = Protocol.S_2_C_MATERIALS_BASE + 2;
Protocol.S_2_C_USE_CHEST                                = Protocol.S_2_C_MATERIALS_BASE + 3;
Protocol.S_2_C_DO_SELL                                  = Protocol.S_2_C_MATERIALS_BASE + 4;
Protocol.S_2_C_USE_FUNCPROPS                            = Protocol.S_2_C_MATERIALS_BASE + 5;
Protocol.S_2_C_MULTIPLE_DO_SELL                         = Protocol.S_2_C_MATERIALS_BASE + 6;

------------------------------C_2_S------------------------------
Protocol.Packet_C2S_AdvacneItemCompose= {
    item_id      = {type = Protocol.DataType.int},
    fields       = {'item_id'}
}
Protocol.structs[Protocol.C_2_S_ADVANCE_ITEM_COMPOSE]   = Protocol.Packet_C2S_AdvacneItemCompose

Protocol.Packet_C2S_StoneCompose = {
    id                          = {type = Protocol.DataType.int},
    num                         = {type = Protocol.DataType.short},
    fields                      = {'id','num'}
}
Protocol.structs[Protocol.C_2_S_STONE_COMPOSE]                              = Protocol.Packet_C2S_StoneCompose

Protocol.Packet_C2S_UseChest = {
    id                        = {type = Protocol.DataType.int},
    num                       = {type = Protocol.DataType.short},
    choose                    = {type = Protocol.DataType.short},
    fields                    = {'id','num','choose'}
}
Protocol.structs[Protocol.C_2_S_USE_CHEST]                                  = Protocol.Packet_C2S_UseChest

Protocol.Packet_C2S_DoSell = {
    id                        = {type = Protocol.DataType.int},
    num                       = {type = Protocol.DataType.short},
    fields                    = {'id', 'num'}
}
Protocol.structs[Protocol.C_2_S_DO_SELL]                                    = Protocol.Packet_C2S_DoSell

Protocol.Packet_C2S_UseFuncProps = {
    id                        = {type = Protocol.DataType.int},
    num                       = {type = Protocol.DataType.short},
    fields                    = {'id', 'num'}
}
Protocol.structs[Protocol.C_2_S_USE_FUNCPROPS]                                    = Protocol.Packet_C2S_UseFuncProps

Protocol.Data_MultipleDoSell = {
    id        = {type = Protocol.DataType.int},
    num       = {type = Protocol.DataType.short},
    fields    = {'id','num'}
}

Protocol.Packet_C2S_MultipleDoSell= {
    count          = {type = Protocol.DataType.short},
    sell_item      = {type = Protocol.DataType.object, length = -1, clazz='Data_MultipleDoSell'},
    fields         = {'count','sell_item'}
}
Protocol.structs[Protocol.C_2_S_MULTIPLE_DO_SELL]   = Protocol.Packet_C2S_MultipleDoSell
------------------------------S_2_C------------------------------
Protocol.Data_Materials = {
    type                = {type = Protocol.DataType.short},
    id                  = {type = Protocol.DataType.int},
    num                 = {type = Protocol.DataType.int},
    fields              = {'type','id','num'}
}

Protocol.Packet_S2C_MaterialsCount = {
    count               = {type = Protocol.DataType.short},
    materials           = {type = Protocol.DataType.object, length = -1, clazz = 'Data_Materials'},
    fields              = {'count','materials'}
}
Protocol.structs[Protocol.S_2_C_MATERIALS_LOAD]                    = Protocol.Packet_S2C_MaterialsCount

Protocol.Packet_S2C_StoneCompose = {
    id                  = {type = Protocol.DataType.int},
    left_num            = {type = Protocol.DataType.short},
    next_id             = {type = Protocol.DataType.int},
    next_id_num         = {type = Protocol.DataType.short},
    fields              = {'id','left_num','next_id','next_id_num'}
}
Protocol.structs[Protocol.S_2_C_STONE_COMPOSE]          = Protocol.Packet_S2C_StoneCompose

Protocol.Packet_S2C_AdvanceItemComPose = {
    ret                     = {type = Protocol.DataType.short},
    item_id                 = {type = Protocol.DataType.int},
    fields                  = {'ret','item_id'}
}
Protocol.structs[Protocol.S_2_C_ADVANCE_ITEM_COMPOSE]           = Protocol.Packet_S2C_AdvanceItemComPose

Protocol.Packet_S2C_UseChest = {
    id                      = {type = Protocol.DataType.int},
    num                     = {type = Protocol.DataType.short},
    choose                  = {type = Protocol.DataType.short},
    count                   = {type = Protocol.DataType.short},
    rwds                    = {type = Protocol.DataType.object, length = -1, clazz='Packet_Data_RewardType'},
    fields                  = {'id','num','choose','count','rwds'}
}
Protocol.structs[Protocol.S_2_C_USE_CHEST]              = Protocol.Packet_S2C_UseChest

Protocol.Packet_S2C_DoSell = {
    id                      = {type = Protocol.DataType.int},
    num                     = {type = Protocol.DataType.short},
    fields                  = {'id', 'num'}
}
Protocol.structs[Protocol.S_2_C_DO_SELL]                = Protocol.Packet_S2C_DoSell

Protocol.Packet_S2C_UseFuncProps = {
    id                      = {type = Protocol.DataType.int},
    num                     = {type = Protocol.DataType.short},
    fields                  = {'id', 'num'}
}
Protocol.structs[Protocol.S_2_C_USE_FUNCPROPS]                = Protocol.Packet_S2C_UseFuncProps

Protocol.Packet_S2C_MultipleDoSell = {
    count                      = {type = Protocol.DataType.short},
    rwds                       = {type = Protocol.DataType.object, length = -1, clazz='Packet_Data_RewardType'},
    fields                     = {'count', 'rwds'}
}
Protocol.structs[Protocol.S_2_C_MULTIPLE_DO_SELL]                = Protocol.Packet_S2C_MultipleDoSell


