local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_BOSOM_FRIEND_INFO                  = Protocol.C_2_S_BOSOM_FRIEND_BASE + 0
Protocol.C_2_S_BOSOM_FRIEND_SEARCH                = Protocol.C_2_S_BOSOM_FRIEND_BASE + 1
Protocol.C_2_S_BOSOM_FRIEND_NPC_REWARD            = Protocol.C_2_S_BOSOM_FRIEND_BASE + 2
Protocol.C_2_S_BOSOM_FRIEND_PERSONAL_INFO         = Protocol.C_2_S_BOSOM_FRIEND_BASE + 3
Protocol.C_2_S_BOSOM_FRIEND_TALK                  = Protocol.C_2_S_BOSOM_FRIEND_BASE + 4
Protocol.C_2_S_BOSOM_FRIEND_FAMOUS_DEAL_WITH      = Protocol.C_2_S_BOSOM_FRIEND_BASE + 6
Protocol.C_2_S_BOSOM_FRIEND_SYS_INFO              = Protocol.C_2_S_BOSOM_FRIEND_BASE + 7
Protocol.C_2_S_BOSOM_FRIEND_MARRY                 = Protocol.C_2_S_BOSOM_FRIEND_BASE + 8
Protocol.C_2_S_BOSOM_FRIEND_DIVORCE               = Protocol.C_2_S_BOSOM_FRIEND_BASE + 11
Protocol.C_2_S_BOSOM_FRIEND_BIND                  = Protocol.C_2_S_BOSOM_FRIEND_BASE + 12
Protocol.C_2_S_BOSOM_FRIEND_BIND_GENERAL          = Protocol.C_2_S_BOSOM_FRIEND_BASE + 13
Protocol.C_2_S_BOSOM_FRIEND_BIND_GENERAL_NUM_INFO = Protocol.C_2_S_BOSOM_FRIEND_BASE + 14
Protocol.C_2_S_BOSOM_FRIEND_BIND_GENERAL_NUM_ADD  = Protocol.C_2_S_BOSOM_FRIEND_BASE + 15

Protocol.S_2_C_BOSOM_FRIEND_INFO              = Protocol.S_2_C_BOSOM_FRIEND_BASE + 0
Protocol.S_2_C_BOSOM_FRIEND_SEARCH            = Protocol.S_2_C_BOSOM_FRIEND_BASE + 1
Protocol.S_2_C_BOSOM_FRIEND_NPC_REWARD        = Protocol.S_2_C_BOSOM_FRIEND_BASE + 2
Protocol.S_2_C_BOSOM_FRIEND_PERSONAL_INFO     = Protocol.S_2_C_BOSOM_FRIEND_BASE + 3
Protocol.S_2_C_BOSOM_FRIEND_FAMOUS_DEAL_WITH  = Protocol.S_2_C_BOSOM_FRIEND_BASE + 4
Protocol.S_2_C_BOSOM_FRIEND_TALK              = Protocol.S_2_C_BOSOM_FRIEND_BASE + 5
Protocol.S_2_C_BOSOM_FRIEND_MARRY             = Protocol.S_2_C_BOSOM_FRIEND_BASE + 6
Protocol.S_2_C_BOSOM_FRIEND_PREGNANCY         = Protocol.S_2_C_BOSOM_FRIEND_BASE + 7
Protocol.S_2_C_BOSOM_FRIEND_SYS_INFO          = Protocol.S_2_C_BOSOM_FRIEND_BASE + 8
Protocol.S_2_C_BOSOM_FRIEND_MARRY_PROMISE     = Protocol.S_2_C_BOSOM_FRIEND_BASE + 9
Protocol.S_2_C_BOSOM_FRIEND_DIVORCE           = Protocol.S_2_C_BOSOM_FRIEND_BASE + 11
Protocol.S_2_C_BOSOM_FRIEND_WIFE              = Protocol.S_2_C_BOSOM_FRIEND_BASE + 12
Protocol.S_2_C_BOSOM_FRIEND_BIND              = Protocol.S_2_C_BOSOM_FRIEND_BASE + 13
Protocol.S_2_C_BOSOM_FRIEND_BIND_GENERAL      = Protocol.S_2_C_BOSOM_FRIEND_BASE + 14
Protocol.S_2_C_BOSOM_FRIEND_BIND_GENERAL_NUM  = Protocol.S_2_C_BOSOM_FRIEND_BASE + 15


Protocol.Packet_C2S_BosomFriendSearch = {
    is_advance   = {type = Protocol.DataType.short},
    fields       = {'is_advance'}
}
Protocol.structs[Protocol.C_2_S_BOSOM_FRIEND_SEARCH]  = Protocol.Packet_C2S_BosomFriendSearch

Protocol.Data_BosomFriendInfo = {
    id = {type = Protocol.DataType.int},
    type = {type = Protocol.DataType.short},
    lvl = {type = Protocol.DataType.short},
    exp = {type = Protocol.DataType.int},
    happy_lvl = {type = Protocol.DataType.short},
    fields = {'id', 'type', 'lvl', 'exp', 'happy_lvl'}
}

Protocol.Packet_S2C_BosomFriendInfo = {
    place_id = {type = Protocol.DataType.int},
    cd_time = {type = Protocol.DataType.int},
    talk_num = {type = Protocol.DataType.short},
    search_num = {type = Protocol.DataType.short},
    count = {type = Protocol.DataType.short},
    npc = {type = Protocol.DataType.int, length = -1},
    count1 = {type = Protocol.DataType.short},
    bosoms = {type = Protocol.DataType.object, clazz="Data_BosomFriendInfo", length = -1},
    fields = {'place_id', 'cd_time', 'talk_num', 'search_num', 'count', 'npc', 'count1', 'bosoms'}
}
Protocol.structs[Protocol.S_2_C_BOSOM_FRIEND_INFO] = Protocol.Packet_S2C_BosomFriendInfo

Protocol.Packet_S2C_BosomFriendSearch = {
    is_advance = {type = Protocol.DataType.short},
    advance_search_num = {type = Protocol.DataType.short},
    place_id = {type = Protocol.DataType.int},
    cd_time = {type = Protocol.DataType.int},
    count = {type = Protocol.DataType.short},
    npcs = {type = Protocol.DataType.int, length = -1},
    fields = {'is_advance', 'advance_search_num', 'place_id', 'cd_time', 'count', 'npcs'}
}
Protocol.structs[Protocol.S_2_C_BOSOM_FRIEND_SEARCH] = Protocol.Packet_S2C_BosomFriendSearch

Protocol.Packet_C2S_BosomFriendNpcReward = {
    npc_id = {type = Protocol.DataType.int},
    fields = {'npc_id'}
}
Protocol.structs[Protocol.C_2_S_BOSOM_FRIEND_NPC_REWARD] = Protocol.Packet_C2S_BosomFriendNpcReward

Protocol.Packet_S2C_BosomFriendNpcReward = {
    npc_id = {type = Protocol.DataType.int},
    fields = {'npc_id'}
}
Protocol.structs[Protocol.S_2_C_BOSOM_FRIEND_NPC_REWARD] = Protocol.Packet_S2C_BosomFriendNpcReward

Protocol.Packet_C2S_BosomFriendPersonalInfo = {
    npc_id = {type = Protocol.DataType.int},
    fields = {'npc_id'}
}
Protocol.structs[Protocol.C_2_S_BOSOM_FRIEND_PERSONAL_INFO] = Protocol.Packet_C2S_BosomFriendPersonalInfo

Protocol.Packet_S2C_BosomFriendPersonalInfo = {
    npc_id = {type = Protocol.DataType.int},
    level = {type = Protocol.DataType.short},
    exp = {type = Protocol.DataType.int},
    happy_level = {type = Protocol.DataType.short},
    lock_time = {type = Protocol.DataType.int},
    fields = {'npc_id', 'level', 'exp', 'happy_level', 'lock_time'}
}
Protocol.structs[Protocol.S_2_C_BOSOM_FRIEND_PERSONAL_INFO] = Protocol.Packet_S2C_BosomFriendPersonalInfo

Protocol.Packet_C2S_BosomFriendTalk = {
    npc_id = {type = Protocol.DataType.int},
    famous_id = {type = Protocol.DataType.int},
    famous_num = {type = Protocol.DataType.int},
    fields = {'npc_id', 'famous_id', 'famous_num'}
}
Protocol.structs[Protocol.C_2_S_BOSOM_FRIEND_TALK] = Protocol.Packet_C2S_BosomFriendTalk

Protocol.Packet_S2C_BosomFriendTalk = {
    npc_id = {type = Protocol.DataType.int},
    op = {type = Protocol.DataType.int},
    id = {type = Protocol.DataType.int},
    num = {type = Protocol.DataType.short},
    happy_level = {type = Protocol.DataType.int},
    add_exp = {type = Protocol.DataType.short},
    fields = {'npc_id', 'op', 'id', 'num', 'happy_level', 'add_exp'}
}
Protocol.structs[Protocol.S_2_C_BOSOM_FRIEND_TALK] =  Protocol.Packet_S2C_BosomFriendTalk

Protocol.Data_BosomFriendFamous = {
    ident = {type = Protocol.DataType.int},
    count = {type = Protocol.DataType.int},
    fields = {'ident', 'count'}
}

Protocol.Packet_C2S_BosomFriendDealWith = {
    op = {type = Protocol.DataType.short},
    npc_id = {type = Protocol.DataType.int},
    fields = {'op', 'npc_id'}
}
Protocol.structs[Protocol.C_2_S_BOSOM_FRIEND_FAMOUS_DEAL_WITH] = Protocol.Packet_C2S_BosomFriendDealWith

Protocol.Packet_S2C_BosomFriendDealWith = {
    op = {type = Protocol.DataType.short},
    npc_id = {type = Protocol.DataType.int},
    fields = {'op', 'npc_id'}
}
Protocol.structs[Protocol.S_2_C_BOSOM_FRIEND_FAMOUS_DEAL_WITH] = Protocol.Packet_S2C_BosomFriendDealWith

Protocol.Packet_S2C_BosomFriendSysInfo = {
    wife_id = {type = Protocol.DataType.int},
    child_num = {type = Protocol.DataType.int},
    fields = {'wife_id', 'child_num'}
}
Protocol.structs[Protocol.S_2_C_BOSOM_FRIEND_SYS_INFO] = Protocol.Packet_S2C_BosomFriendSysInfo

Protocol.Packet_S2C_BosomFriendMarryPromise = {
    ret = {type = Protocol.DataType.int},
    npc_id = {type = Protocol.DataType.int},
    fields = {'ret', 'npc_id'}
}
Protocol.structs[Protocol.S_2_C_BOSOM_FRIEND_MARRY_PROMISE] = Protocol.Packet_S2C_BosomFriendMarryPromise

Protocol.Packet_C2S_BosomFriendMarry = {
    ret = {type = Protocol.DataType.int},
    fields = {'ret'}
}
Protocol.structs[Protocol.C_2_S_BOSOM_FRIEND_MARRY] = Protocol.Packet_C2S_BosomFriendMarry

Protocol.Packet_S2C_BosomFriendMarry = {
    ret = {type = Protocol.DataType.int},
    npc_id = {type = Protocol.DataType.int},
    report_id = {type = Protocol.DataType.longlong},
    fields = {'ret', 'npc_id', 'report_id'}
}
Protocol.structs[Protocol.S_2_C_BOSOM_FRIEND_MARRY] = Protocol.Packet_S2C_BosomFriendMarry

Protocol.Data_BosomFriendNpcInfo = {
    id = {type = Protocol.DataType.int},
    exp = {type = Protocol.DataType.int},
    fields = {'id', 'exp'}
}

Protocol.Packet_C2S_BosomFriendDivorce = {
    use_gold = {type = Protocol.DataType.int},
    fields = {'use_gold'}
}
Protocol.structs[Protocol.C_2_S_BOSOM_FRIEND_DIVORCE] = Protocol.Packet_C2S_BosomFriendDivorce

Protocol.Packet_S2C_BosomFriendDivorce = {
    ret = {type = Protocol.DataType.short},
    use_gold = {type = Protocol.DataType.short},
    fields = {'ret', 'use_gold'}
}
Protocol.structs[Protocol.S_2_C_BOSOM_FRIEND_DIVORCE] = Protocol.Packet_S2C_BosomFriendDivorce

Protocol.Packet_C2S_BosomFriendBind = {
    npc_id = {type = Protocol.DataType.int},
    fields = {'npc_id'}
}
Protocol.structs[Protocol.Packet_C2S_BosomFriendBind] = Protocol.Packet_C2S_BosomFriendBind

Protocol.Packet_S2C_BosomFriendBind = {
    npc_id = {type = Protocol.DataType.int},
    lock_time = {type = Protocol.DataType.int},
    fields = {'npc_id', 'lock_time'}
}
Protocol.structs[Protocol.S_2_C_BOSOM_FRIEND_BIND] = Protocol.Packet_S2C_BosomFriendBind

Protocol.Packet_C2S_BosomFriendBindGeneral = {
    generalId = {type = Protocol.DataType.int},
    bosomFriendId = {type = Protocol.DataType.int},
    pos = {type = Protocol.DataType.int},
    fields = {'generalId', 'bosomFriendId', 'pos'}
}
Protocol.structs[Protocol.C_2_S_BOSOM_FRIEND_BIND_GENERAL] = Protocol.Packet_C2S_BosomFriendBindGeneral

Protocol.Data_BosomFriendBind = {
    generalId = {type = Protocol.DataType.int},
    bosomFriendId = {type = Protocol.DataType.int},
    fields = {'generalId', 'bosomFriendId'}
}
Protocol.Packet_S2C_BosomFriendBindGeneral = {
    count = {type = Protocol.DataType.int},
    bosomFriendBind = {type = Protocol.DataType.object, clazz="Data_BosomFriendBind", length = -1},
    fields = {'count', 'bosomFriendBind'}
}
Protocol.structs[Protocol.S_2_C_BOSOM_FRIEND_BIND_GENERAL] = Protocol.Packet_S2C_BosomFriendBindGeneral

Protocol.Packet_S2C_BosomFriendBindGeneralNum = {
    bindGeneralNum = {type = Protocol.DataType.int},
    fields = {'bindGeneralNum'}
}
Protocol.structs[Protocol.S_2_C_BOSOM_FRIEND_BIND_GENERAL_NUM] = Protocol.Packet_S2C_BosomFriendBindGeneralNum
