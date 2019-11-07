local Protocol = cc.exports.Protocol or {}
Protocol.S_2_C_PEER_STATE                               = Protocol.S_2_C_PEER_BASE + 0;
Protocol.S_2_C_PEER_LOCAL_SERVERID                      = Protocol.S_2_C_PEER_BASE + 1;


------------------------------C_2_S------------------------------

------------------------------S_2_C------------------------------

Protocol.Packet_S2C_PeerState = {
    --S_2_C_PEER_STATE
    msg_type            = {type = Protocol.DataType.char},
    id_len              = {type = Protocol.DataType.short},
    id                  = {type = Protocol.DataType.string, length = Protocol.MAX_PEER_ID_LEN},
    name_len            = {type = Protocol.DataType.short},
    name                = {type = Protocol.DataType.string, length = Protocol.MAX_PEER_NAME_LEN},
    report_address_len  = {type = Protocol.DataType.short},
    report_address      = {type = Protocol.DataType.string, length = Protocol.MAX_REPORT_ADDRESS_LEN},
    fields              = {'msg_type','id_len','id','name_len','name','report_address_len','report_address'}
}
Protocol.structs[Protocol.S_2_C_PEER_STATE]              = Protocol.Packet_S2C_PeerState

Protocol.Packet_S2C_PeerLocalServerId = {
    --S_2_C_PEER_LOCAL_SERVERID
    serverIdLen         = {type = Protocol.DataType.short},
    serverId            = {type = Protocol.DataType.string, length = Protocol.MAX_PEER_ID_LEN},
    serverNameLen       = {type = Protocol.DataType.short},
    serverName          = {type = Protocol.DataType.string, length = Protocol.MAX_PEER_NAME_LEN},
    fields              = {'serverIdLen','serverId','serverNameLen','serverName'}
}
Protocol.structs[Protocol.S_2_C_PEER_LOCAL_SERVERID]              = Protocol.Packet_S2C_PeerLocalServerId