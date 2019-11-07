local Protocol = cc.exports.Protocol or {}

Protocol.S_2_C_UPDATE_GAMETIME               = Protocol.S_2_C_UPDATE_GAMETIME_BASE + 0

Protocol.Packet_S2C_GameTimeUpdate = {
    year           = {type = Protocol.DataType.int},
    season         = {type = Protocol.DataType.char},
    server_time    = {type = Protocol.DataType.int},
    fields         = {'year','season','server_time'}
}
Protocol.structs[Protocol.S_2_C_UPDATE_GAMETIME] = Protocol.Packet_S2C_GameTimeUpdate