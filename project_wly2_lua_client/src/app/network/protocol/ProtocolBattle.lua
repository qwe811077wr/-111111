local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_REQUEST_BATTLE_PVE = Protocol.C_2_S_BATTLE_BASE + 1 --245

Protocol.Packet_C2S_RequestBattle_PVE = {
    battleType   = {type = Protocol.DataType.char},
    instance_id  = {type = Protocol.DataType.int},
    npc_id       = {type = Protocol.DataType.int},
    is_force_atk = {type = Protocol.DataType.char},
    bShow        = {type = Protocol.DataType.char},
    fields       = {'battleType', 'instance_id', 'npc_id', 'is_force_atk', 'bShow'}
}
Protocol.structs[Protocol.C_2_S_REQUEST_BATTLE_PVE] = Protocol.Packet_C2S_RequestBattle_PVE