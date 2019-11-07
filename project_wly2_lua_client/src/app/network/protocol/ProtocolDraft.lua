local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_DRAFT_SPEED  = Protocol.C_2_S_DRAFT_BASE + 2

Protocol.S_2_C_DRAFT_SPEED  = Protocol.S_2_C_DRAFT_BASE + 2
Protocol.S_2_C_DRAFT_UPDATE = Protocol.S_2_C_DRAFT_BASE + 4

Protocol.Packet_C2S_DraftSpeed = {
    general_id = {type = Protocol.DataType.int},
    fields     = {'general_id'}
}
Protocol.structs[Protocol.C_2_S_DRAFT_SPEED]    = Protocol.Packet_C2S_DraftSpeed

Protocol.Packet_S2C_DraftSpeed = {
    general_id = {type = Protocol.DataType.int},
    speed_num  = {type = Protocol.DataType.int},
    fields     = {'general_id', 'speed_num'}
}
Protocol.structs[Protocol.S_2_C_DRAFT_SPEED]    = Protocol.Packet_S2C_DraftSpeed

Protocol.Data_DraftUpdate = {
    general_id     = {type = Protocol.DataType.int},
    cur_soldiernum = {type = Protocol.DataType.int},
    fields         = {'general_id', 'cur_soldiernum'}
}

Protocol.Packet_S2C_GeneralDraftUpdate = {
    count   = {type = Protocol.DataType.short},
    general = {type = Protocol.DataType.object, length = -1, clazz = 'Data_DraftUpdate'},
    fields  = {'count', 'general'}
}
Protocol.structs[Protocol.S_2_C_DRAFT_UPDATE]    = Protocol.Packet_S2C_GeneralDraftUpdate
