local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_REBUILD_EQUIPMENT_LOAD_INFO                  = Protocol.C_2_S_REBUILD_EQUIPMENT_BASE + 0
Protocol.C_2_S_REBUILD_EQUIPMENT_REBUILD                    = Protocol.C_2_S_REBUILD_EQUIPMENT_BASE + 1
Protocol.C_2_S_REBUILD_EQUIPMENT_UPDATE                     = Protocol.C_2_S_REBUILD_EQUIPMENT_BASE + 3
Protocol.C_2_S_REBUILD_EQUIPMENT_RESET                      = Protocol.C_2_S_REBUILD_EQUIPMENT_BASE + 4
Protocol.C_2_S_REBUILD_EQUIPMENT_INJECT_STONE               = Protocol.C_2_S_REBUILD_EQUIPMENT_BASE + 7


Protocol.S_2_C_REBUILD_EQUIPMENT_LOAD_INFO                  = Protocol.S_2_C_REBUILD_EQUIPMENT_BASE + 0
Protocol.S_2_C_REBUILD_EQUIPMENT_REBUILD_RET                = Protocol.S_2_C_REBUILD_EQUIPMENT_BASE + 1
Protocol.S_2_C_REBUILD_EQUIPMENT_UPDATE_RET                 = Protocol.S_2_C_REBUILD_EQUIPMENT_BASE + 3
Protocol.S_2_C_REBUILD_EQUIPMENT_RESET                      = Protocol.S_2_C_REBUILD_EQUIPMENT_BASE + 4
Protocol.S_2_C_REBUILD_EQUIPMENT_INJECT_STONE               = Protocol.S_2_C_REBUILD_EQUIPMENT_BASE + 7


------------------------------C_2_S------------------------------

Protocol.Packet_C2S_RebuildEquip = {
    epid                            = {type = Protocol.DataType.longlong},
    rebuild_type                    = {type = Protocol.DataType.short},
    oblation_epid                   = {type = Protocol.DataType.longlong},
    lockAttri1                      = {type = Protocol.DataType.short},
    lockAttri2                      = {type = Protocol.DataType.short},
    fields                          = {'epid','rebuild_type','oblation_epid','lockAttri1','lockAttri2'}
}
Protocol.structs[Protocol.C_2_S_REBUILD_EQUIPMENT_REBUILD]                      = Protocol.Packet_C2S_RebuildEquip

Protocol.Packet_C2S_InjectStone = {
    equip_id                         = {type = Protocol.DataType.int},
    stone_id                         = {type = Protocol.DataType.int},
    fields                          = {'equip_id','stone_id'}
}
Protocol.structs[Protocol.C_2_S_REBUILD_EQUIPMENT_INJECT_STONE]                    = Protocol.Packet_C2S_InjectStone


------------------------------S_2_C------------------------------

Protocol.Packet_S2C_LoadRebuildInfo = {
    epid                            = {type = Protocol.DataType.longlong},
    epcritrate                      = {type = Protocol.DataType.double},
    epbeatbackrate                  = {type = Protocol.DataType.double},
    epdecinjurerate                 = {type = Protocol.DataType.double},
    gold_rebuild_num                = {type = Protocol.DataType.short},
    fields                          = {'epid','epcritrate','epbeatbackrate','epdecinjurerate','gold_rebuild_num'}
}
Protocol.structs[Protocol.S_2_C_REBUILD_EQUIPMENT_LOAD_INFO]                    = Protocol.Packet_S2C_LoadRebuildInfo

Protocol.Packet_S2C_RebuildResult = {
    ret                             = {type = Protocol.DataType.char},
    rebuild_type                    = {type = Protocol.DataType.short},
    epcritrate                      = {type = Protocol.DataType.double},
    epbeatbackrate                  = {type = Protocol.DataType.double},
    epdecinjurerate                 = {type = Protocol.DataType.double},
    lockAttri1                      = {type = Protocol.DataType.short},
    lockAttri2                      = {type = Protocol.DataType.short},
    goldRebuildNum                  = {type = Protocol.DataType.short},
    fields                          = {'ret','rebuild_type','epcritrate','epbeatbackrate','epdecinjurerate','lockAttri1','lockAttri2','goldRebuildNum'}
}
Protocol.structs[Protocol.S_2_C_REBUILD_EQUIPMENT_REBUILD_RET]                  = Protocol.Packet_S2C_RebuildResult

Protocol.Packet_S2C_UpdateRebuild = {
    ret                             = {type = Protocol.DataType.char},
    fields                          = {'ret'}
}
Protocol.structs[Protocol.S_2_C_REBUILD_EQUIPMENT_UPDATE_RET]                   = Protocol.Packet_S2C_UpdateRebuild

Protocol.Packet_S2C_ResetRebuild = {
    ret                             = {type = Protocol.DataType.short},
    fields                          = {'ret'}
}
Protocol.structs[Protocol.S_2_C_REBUILD_EQUIPMENT_RESET]                   = Protocol.Packet_S2C_ResetRebuild

Protocol.Packet_S2C_RebuildEqAttStone = {
    equip_id                        = {type = Protocol.DataType.int},
    stone_id                        = {type = Protocol.DataType.int},
    add_value                       = {type = Protocol.DataType.int},
    fields                          = {'equip_id','stone_id','add_value'}
}
Protocol.structs[Protocol.S_2_C_REBUILD_EQUIPMENT_INJECT_STONE]                    = Protocol.Packet_S2C_RebuildEqAttStone
