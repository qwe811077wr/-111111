local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_MAIL_SEND                                = Protocol.C_2_S_MAIL_BASE + 0
Protocol.C_2_S_MAIL_LOAD                                = Protocol.C_2_S_MAIL_BASE + 1
Protocol.C_2_S_MAIL_DELETE                              = Protocol.C_2_S_MAIL_BASE + 2
Protocol.C_2_S_MAIL_REWARD                              = Protocol.C_2_S_MAIL_BASE + 3
Protocol.C_2_S_MAIL_READ                                = Protocol.C_2_S_MAIL_BASE + 4

Protocol.S_2_C_MAIL_SEND                                = Protocol.S_2_C_MAIL_BASE + 0
Protocol.S_2_C_MAIL_LOAD                                = Protocol.S_2_C_MAIL_BASE + 1
Protocol.S_2_C_MAIL_LOAD_BEGIN                          = Protocol.S_2_C_MAIL_BASE + 2
Protocol.S_2_C_MAIL_LOAD_END                            = Protocol.S_2_C_MAIL_BASE + 3
Protocol.S_2_C_MAIL_DELETE                              = Protocol.S_2_C_MAIL_BASE + 4
Protocol.S_2_C_MAIL_REWARD                              = Protocol.S_2_C_MAIL_BASE + 5
Protocol.S_2_C_MAIL_READ                                = Protocol.S_2_C_MAIL_BASE + 6


--ENUM
Protocol.MAIL_MAX_TITLE                                 = 45 * 3
Protocol.MAIL_MAX_TIME                                  = 100
Protocol.MAIL_MAX_CONTEXT                               = 455 * 3
------------------------------C_2_S------------------------------
Protocol.MAIL_FROM_WHERE = {
    MAIL_FROM_PLAYER    = 1,
    MAIL_FROM_GAME      = 2,
    MAIL_FROM_BATTLE    = 3,
    MAIL_FROM_REWARD    = 4,
}

Protocol.MAIL_PRIORITY = {
    MAIL_PRI_OTHER = 0,
    MAIL_PRI_BATTLE = 1,
    MAIL_PRI_REWARD = 2,
}

Protocol.Data_Mail = {
    id                  = {type = Protocol.DataType.longlong},
    title_len           = {type = Protocol.DataType.short},
    title               = {type = Protocol.DataType.string, length = Protocol.MAX_MAIL_TITLE_LEN},
    sender_id           = {type = Protocol.DataType.longlong},
    sender_len          = {type = Protocol.DataType.short},
    sender_name         = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    recver_id           = {type = Protocol.DataType.longlong},
    mail_type           = {type = Protocol.DataType.short},
    state               = {type = Protocol.DataType.short},
    create_time         = {type = Protocol.DataType.int},
    content_len         = {type = Protocol.DataType.short},
    content             = {type = Protocol.DataType.string, length = Protocol.MAX_MSG_CONTENT_LEN},
    content_type        = {type = Protocol.DataType.short},
    title_type          = {type = Protocol.DataType.short},
    reward_len          = {type = Protocol.DataType.short},
    reward              = {type = Protocol.DataType.string, length = Protocol.MAX_MAIL_REWARD_STR_LEN},
    year                = {type = Protocol.DataType.short},
    season              = {type = Protocol.DataType.short},
    reward_content_len  = {type = Protocol.DataType.short},
    reward_content      = {type = Protocol.DataType.string, length = Protocol.MAX_MAIL_REWARD_STR_LEN},
    fields              = {'id', 'title_len', 'title', 'sender_id', 'sender_len', 'sender_name', 'recver_id'
                            , 'mail_type', 'state', 'create_time', 'content_len', 'content', 'content_type'
                            , 'title_type', 'reward_len', 'reward', 'year', 'season', 'reward_content_len', 'reward_content'}
}

Protocol.MAIL_SEND = {
    SUCCESSED = 0,
    FAILED = 1,
}

Protocol.Packet_C2S_MailSend = {
    --C_2_S_MAIL_SEND
    recver_name_len     = {type = Protocol.DataType.short},
    recver_name         = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    title_len           = {type = Protocol.DataType.short},
    title               = {type = Protocol.DataType.string, length = Protocol.MAX_MAIL_TITLE_LEN},
    content_len         = {type = Protocol.DataType.short},
    content             = {type = Protocol.DataType.string, length = Protocol.MAX_MSG_CONTENT_LEN},
    fields              = {'recver_name_len', 'recver_name', 'title_len', 'title', 'content_len', 'content'}
}
Protocol.structs[Protocol.C_2_S_MAIL_SEND] = Protocol.Packet_C2S_MailSend

Protocol.Packet_C2S_MailDelete = {
    --C_2_S_MAIL_DELETE
    count               = {type = Protocol.DataType.short},
    mail_id             = {type = Protocol.DataType.longlong, length = -1},
    fields              = {'count', 'mail_id'}
}
Protocol.structs[Protocol.C_2_S_MAIL_DELETE] = Protocol.Packet_C2S_MailDelete

Protocol.Packet_C2S_MailReward = {
    --C_2_S_MAIL_REWARD
    mail_id             = {type = Protocol.DataType.longlong},
    fields              = {'mail_id'}
}
Protocol.structs[Protocol.C_2_S_MAIL_REWARD] = Protocol.Packet_C2S_MailReward

Protocol.MAIL_READ = {
    MAIL_NEW = 0,
    MAIL_READ = 1,
    MAIL_GOT_REWARD = 2,
}

Protocol.Packet_C2S_MailRead = {
    --C_2_S_MAIL_READ
    mail_id             = {type = Protocol.DataType.longlong},
    fields              = {'mail_id'}
}
Protocol.structs[Protocol.C_2_S_MAIL_READ] = Protocol.Packet_C2S_MailRead

------------------------------S_2_C------------------------------
Protocol.Packet_S2C_MailSend = {
    ret                 = {type = Protocol.DataType.short},
    fields              = {'ret'}
}
Protocol.structs[Protocol.S_2_C_MAIL_SEND] = Protocol.Packet_S2C_MailSend

Protocol.Packet_S2C_MailLoad = {
    count               = {type = Protocol.DataType.short},
    mails               = {type = Protocol.DataType.object, length = -1, clazz = 'Data_Mail'},
    fields              = {'count', 'mails'}
}
Protocol.structs[Protocol.S_2_C_MAIL_LOAD] = Protocol.Packet_S2C_MailLoad

Protocol.Packet_S2C_MailLoadBegin = {
    fields              = {}
}
Protocol.structs[Protocol.S_2_C_MAIL_LOAD_BEGIN] = Protocol.Packet_S2C_MailLoadBegin

Protocol.Packet_S2C_MailLoadEnd = {
    fields              = {}
}
Protocol.structs[Protocol.S_2_C_MAIL_LOAD_END] = Protocol.Packet_S2C_MailLoadEnd

Protocol.Packet_S2C_MailDelete = {
    ret                 = {type = Protocol.DataType.short},
    count               = {type = Protocol.DataType.short},
    mail_id             = {type = Protocol.DataType.longlong, length = -1},
    fields              = {'ret', 'count', 'mail_id'}
}
Protocol.structs[Protocol.S_2_C_MAIL_DELETE] = Protocol.Packet_S2C_MailDelete

Protocol.Packet_S2C_MailReward = {
    ret                 = {type = Protocol.DataType.short},
    count               = {type = Protocol.DataType.short},
    mail_id             = {type = Protocol.DataType.longlong, length = -1},
    fields              = {'ret', 'count', 'mail_id'}
}
Protocol.structs[Protocol.S_2_C_MAIL_REWARD] = Protocol.Packet_S2C_MailReward

Protocol.Packet_S2C_MailRead = {
    ret                 = {type = Protocol.DataType.short},
    mail_id             = {type = Protocol.DataType.longlong},
    fields              = {'ret', 'mail_id'}
}
Protocol.structs[Protocol.S_2_C_MAIL_READ] = Protocol.Packet_S2C_MailRead