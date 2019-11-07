local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_ETCHED_HOUSE_CARAVAN_DISPATCH                = Protocol.C_2_S_ETCHED_HOUSE_BASE + 0
Protocol.C_2_S_ETCHED_HOUSE_CARAVAN_DISPATCH_INFO           = Protocol.C_2_S_ETCHED_HOUSE_BASE + 1
Protocol.C_2_S_ETCHED_HOUSE_CARAVAN_REFRESH                 = Protocol.C_2_S_ETCHED_HOUSE_BASE + 2
Protocol.C_2_S_ETCHED_HOUSE_MIX                             = Protocol.C_2_S_ETCHED_HOUSE_BASE + 3
Protocol.C_2_S_ETCHED_HOUSE_BRAND                           = Protocol.C_2_S_ETCHED_HOUSE_BASE + 4
Protocol.C_2_S_ETCHED_HOUSE_UNBRAND                         = Protocol.C_2_S_ETCHED_HOUSE_BASE + 5
Protocol.C_2_S_ETCHED_HOUSE_INFO                            = Protocol.C_2_S_ETCHED_HOUSE_BASE + 6
Protocol.C_2_S_ETCHED_HOUSE_DECOMPOSE                       = Protocol.C_2_S_ETCHED_HOUSE_BASE + 8
Protocol.C_2_S_ETCHED_HOUSE_STAMP_UPGRADE                   = Protocol.C_2_S_ETCHED_HOUSE_BASE + 9
Protocol.C_2_S_ETCHED_HOUSE_STAMP_DEGRADE                   = Protocol.C_2_S_ETCHED_HOUSE_BASE + 10
Protocol.C_2_S_ETCHED_HOUSE_AUTO_UPGRADE                    = Protocol.C_2_S_ETCHED_HOUSE_BASE + 11
Protocol.C_2_S_ETCHED_HOUSE_STAMP_COMBINE                   = Protocol.C_2_S_ETCHED_HOUSE_BASE + 12
Protocol.C_2_S_ETCHED_HOUSE_LOAD_ALL_EQUIP_ETCHED           = Protocol.C_2_S_ETCHED_HOUSE_BASE + 13
Protocol.C_2_S_ETCHED_HOUSE_CARAVAN_DISPATCH_BUY            = Protocol.C_2_S_ETCHED_HOUSE_BASE + 14


Protocol.S_2_C_ETCHED_HOUSE_CARAVAN_DISPATCH                = Protocol.S_2_C_ETCHED_HOUSE_BASE + 0
Protocol.S_2_C_ETCHED_HOUSE_CARAVAN_INFO                    = Protocol.S_2_C_ETCHED_HOUSE_BASE + 1
Protocol.S_2_C_ETCHED_HOUSE_MIX                             = Protocol.S_2_C_ETCHED_HOUSE_BASE + 2
Protocol.S_2_C_ETCHED_HOUSE_BRAND                           = Protocol.S_2_C_ETCHED_HOUSE_BASE + 3
Protocol.S_2_C_ETCHED_HOUSE_UNBRAND                         = Protocol.S_2_C_ETCHED_HOUSE_BASE + 4
Protocol.S_2_C_ETCHED_HOUSE_STAMP_UPGRADE                   = Protocol.S_2_C_ETCHED_HOUSE_BASE + 6
Protocol.S_2_C_ETCHED_HOUSE_STAMP_DEGRADE                   = Protocol.S_2_C_ETCHED_HOUSE_BASE + 7
Protocol.S_2_C_ETCHED_HOUSE_AUTO_UPGRADE                    = Protocol.S_2_C_ETCHED_HOUSE_BASE + 8
Protocol.S_2_C_ETCHED_HOUSE_STAMP_COMBINE                   = Protocol.S_2_C_ETCHED_HOUSE_BASE + 9
Protocol.S_2_C_ETCHED_HOUSE_LOAD_ALL_EQUIP_ETCHED           = Protocol.S_2_C_ETCHED_HOUSE_BASE + 10


------------------------------C_2_S------------------------------

Protocol.Packet_C2S_EtchedHouseMix = {
    etchedType                  = {type = Protocol.DataType.int},
    level                       = {type = Protocol.DataType.int},
    fields                      = {'etchedType','level'}
}
Protocol.structs[Protocol.C_2_S_ETCHED_HOUSE_MIX]                               = Protocol.Packet_C2S_EtchedHouseMix

Protocol.Packet_C2S_EtchedHouseBrand = {
    eqId                        = {type = Protocol.DataType.int},
    etchedType                  = {type = Protocol.DataType.int},
    level                       = {type = Protocol.DataType.int},
    fields                      = {'eqId','etchedType','level'}
}
Protocol.structs[Protocol.C_2_S_ETCHED_HOUSE_BRAND]                             = Protocol.Packet_C2S_EtchedHouseBrand

Protocol.Packet_C2S_EtchedHouseUnBrand = {
    eqId                        = {type = Protocol.DataType.int},
    etchedType                  = {type = Protocol.DataType.int},
    fields                      = {'eqId','etchedType'}
}
Protocol.structs[Protocol.C_2_S_ETCHED_HOUSE_UNBRAND]                           = Protocol.Packet_C2S_EtchedHouseUnBrand

------------------------------S_2_C------------------------------

Protocol.Data_EtchedInfo = {
    type                        = {type = Protocol.DataType.int},
    level                       = {type = Protocol.DataType.int},
    num                         = {type = Protocol.DataType.int},
    fields                      = {'type','level','num'}
}

Protocol.Packet_S2C_EtchedHouseCaravanDispatch = {
    etchedInfo                          = {type = Protocol.DataType.object, length = 1, clazz='Data_EtchedInfo'},
    fields                              = {'etchedInfo'}
}
Protocol.structs[Protocol.S_2_C_ETCHED_HOUSE_CARAVAN_DISPATCH]                  = Protocol.Packet_S2C_EtchedHouseCaravanDispatch