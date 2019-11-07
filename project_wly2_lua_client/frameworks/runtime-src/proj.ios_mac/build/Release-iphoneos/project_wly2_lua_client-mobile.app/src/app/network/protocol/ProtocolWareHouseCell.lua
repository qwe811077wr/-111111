local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_ACCELERATE_WAREHOUSE_CELL            = Protocol.C_2_S_WAREHOUSE_CELL_BASE + 0
Protocol.C_2_S_UNBIND_WAREHOUSE_CELL                = Protocol.C_2_S_WAREHOUSE_CELL_BASE + 1
Protocol.C_2_S_LOAD_RESOURCE_WAREHOUSE              = Protocol.C_2_S_WAREHOUSE_CELL_BASE + 2
Protocol.C_2_S_GET_WALLET_REWARD                    = Protocol.C_2_S_WAREHOUSE_CELL_BASE + 3


Protocol.S_2_C_LOAD_WAREHOUSE_CELL_INFO             = Protocol.S_2_C_WAREHOUSE_CELL_BASE + 0
Protocol.S_2_C_ACCELERATE_WAREHOUSE_CELL            = Protocol.S_2_C_WAREHOUSE_CELL_BASE + 1
Protocol.S_2_C_UNBIND_WAREHOUSE_CELL                = Protocol.S_2_C_WAREHOUSE_CELL_BASE + 2
Protocol.S_2_C_LOAD_RESOURCE_WAREHOUSE              = Protocol.S_2_C_WAREHOUSE_CELL_BASE + 3
Protocol.S_2_C_LOAD_WALLET_INFO                     = Protocol.S_2_C_WAREHOUSE_CELL_BASE + 4
Protocol.S_2_C_GET_WALLET_REWARD                    = Protocol.S_2_C_WAREHOUSE_CELL_BASE + 5
Protocol.S_2_C_RESOURCES_INFO                       = Protocol.S_2_C_WAREHOUSE_CELL_BASE + 6


------------------------------C_2_S------------------------------
Protocol.Packet_C2S_GetWalletReward = {
    index                       = {type = Protocol.DataType.int},
    fields                      = {'index'}
}
Protocol.structs[Protocol.C_2_S_GET_WALLET_REWARD]                          = Protocol.Packet_C2S_GetWalletReward


------------------------------S_2_C------------------------------
Protocol.Packet_S2C_LoadWarehouseCellInfo = {
    id                                 = {type = Protocol.DataType.int},
    online_second                      = {type = Protocol.DataType.int},
    cost                               = {type = Protocol.DataType.int},
    fields                             = {'id','online_second','cost'}
}
Protocol.structs[Protocol.S_2_C_LOAD_WAREHOUSE_CELL_INFO]                   = Protocol.Packet_S2C_LoadWarehouseCellInfo

Protocol.Packet_S2C_AccelerateWarehouseCell = {
    cost                               = {type = Protocol.DataType.int},
    fields                             = {'cost'}
}
Protocol.structs[Protocol.S_2_C_ACCELERATE_WAREHOUSE_CELL]                  = Protocol.Packet_S2C_AccelerateWarehouseCell

Protocol.Packet_S2C_UnbindWarehouseCell = {
    next_id                             = {type = Protocol.DataType.int},
    fields                              = {'next_id'}
}
Protocol.structs[Protocol.S_2_C_UNBIND_WAREHOUSE_CELL]                      = Protocol.Packet_S2C_UnbindWarehouseCell

Protocol.Packet_S2C_LoadResourceWarehouse = {
    len                                 = {type = Protocol.DataType.short},
    data                                = {type = Protocol.DataType.string,length = -1},
    fields                              = {'len','data'}
}
Protocol.structs[Protocol.S_2_C_LOAD_RESOURCE_WAREHOUSE]                    = Protocol.Packet_S2C_LoadResourceWarehouse

Protocol.Packet_S2C_ResourcesInfo = {
    cashGift                            = {type = Protocol.DataType.int},
    fields                              = {'cashGift'}
}
Protocol.structs[Protocol.S_2_C_RESOURCES_INFO]                             = Protocol.Packet_S2C_ResourcesInfo