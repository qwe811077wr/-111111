local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_CHAT_MSG                 = Protocol.C_2_S_CHAT_BASE + 0
Protocol.C_2_S_CHAT_VIEW                = Protocol.C_2_S_CHAT_BASE + 1
Protocol.C_2_S_SHOW_EQUIPMENT           = Protocol.C_2_S_CHAT_BASE + 2
Protocol.C_2_S_SHOW_GENERAL             = Protocol.C_2_S_CHAT_BASE + 3
Protocol.C_2_S_SHOW_BOSOM_FRIEND        = Protocol.C_2_S_CHAT_BASE + 4
Protocol.C_2_S_INCOME_FIND              = Protocol.C_2_S_CHAT_BASE + 5
Protocol.C_2_S_GAME_CONFIG              = Protocol.C_2_S_CHAT_BASE + 6
Protocol.C_2_S_VIEW_PROMPT              = Protocol.C_2_S_CHAT_BASE + 7
Protocol.C_2_S_SHOW_MEDAL               = Protocol.C_2_S_CHAT_BASE + 8
Protocol.C_2_S_GlOBAL_COMPENSATION_DRAW = Protocol.C_2_S_CHAT_BASE + 9
Protocol.C_2_S_MONTH_CARD_DRAW_REWARD   = Protocol.C_2_S_CHAT_BASE + 10
Protocol.C_2_S_MAIN_CITY_LOCK           = Protocol.C_2_S_CHAT_BASE + 11
Protocol.C_2_S_SHOW_HORSE               = Protocol.C_2_S_CHAT_BASE + 12
Protocol.C_2_S_SHOW_DAILY_INFO          = Protocol.C_2_S_CHAT_BASE + 13
Protocol.C_2_S_CHAT_MSG_LOAD            = Protocol.C_2_S_CHAT_BASE + 14
Protocol.C_2_S_CHOOSE_BUBBLE            = Protocol.C_2_S_CHAT_BASE + 15

Protocol.S_2_C_CHAT_MSG                 = Protocol.S_2_C_CHAT_BASE + 0
Protocol.S_2_C_BROAD_MSG                = Protocol.S_2_C_CHAT_BASE + 1
Protocol.S_2_C_FILTER_WORD_LIST         = Protocol.S_2_C_CHAT_BASE + 2
Protocol.S_2_C_FILTER_WORD_DELETE       = Protocol.S_2_C_CHAT_BASE + 3
Protocol.S_2_C_CHAT_MSG_BOSOM_FRIEND    = Protocol.S_2_C_CHAT_BASE + 4
Protocol.S_2_C_INCOME_FIND              = Protocol.S_2_C_CHAT_BASE + 5
Protocol.S_2_C_INSTRUCTOR               = Protocol.S_2_C_CHAT_BASE + 6
Protocol.S_2_C_GAME_CONFIG              = Protocol.S_2_C_CHAT_BASE + 7
Protocol.S_2_C_PROMPT_INFO              = Protocol.S_2_C_CHAT_BASE + 8
Protocol.S_2_C_GlOBAL_COMPENSATION_DRAW = Protocol.S_2_C_CHAT_BASE + 9
Protocol.S_2_C_BROAD_MSG_BEGIN          = Protocol.S_2_C_CHAT_BASE + 10
Protocol.S_2_C_BROAD_MSG_END            = Protocol.S_2_C_CHAT_BASE + 11
Protocol.S_2_C_CHAT_MSG_LOAD_BEGIN      = Protocol.S_2_C_CHAT_BASE + 12
Protocol.S_2_C_CHAT_MSG_LOAD            = Protocol.S_2_C_CHAT_BASE + 13
Protocol.S_2_C_CHAT_MSG_LOAD_END        = Protocol.S_2_C_CHAT_BASE + 14
Protocol.S_2_C_CHOOSE_BUBBLE            = Protocol.S_2_C_CHAT_BASE + 15


Protocol.Packet_C2S_ChatMsg = {
    --C_2_S_CHAT_MSG
    msg_type                            = {type = Protocol.DataType.short},
    content_type                        = {type = Protocol.DataType.short},
    server_id_len                       = {type = Protocol.DataType.short},
    server_id                           = {type = Protocol.DataType.string, length = Protocol.MAX_PEER_ID_LEN},
    contact_role_id                     = {type = Protocol.DataType.longlong},
    contact_role_name_len               = {type = Protocol.DataType.short},
    contact_role_name                   = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    content_type_num                    = {type = Protocol.DataType.short},
    content                             = {type = Protocol.DataType.string, length = -1},
    fields                              = {'msg_type','content_type','server_id_len','server_id','contact_role_id'
                                            ,'contact_role_name_len','contact_role_name','content_type_num','content'}
}
Protocol.structs[Protocol.C_2_S_CHAT_MSG]                   = Protocol.Packet_C2S_ChatMsg

Protocol.Packet_S2C_ChatMsg = {
    --S_2_C_CHAT_MSG
    sender_id                           = {type = Protocol.DataType.longlong},
    img_type                            = {type = Protocol.DataType.short},                                         --1system 2sender 3accepter
    img_id                              = {type = Protocol.DataType.int},
    msg_type                            = {type = Protocol.DataType.short},
    content_type                        = {type = Protocol.DataType.short},
    country_id                          = {type = Protocol.DataType.short},
    title_type                          = {type = Protocol.DataType.short},                                         --1官职 2竞技场排行
    officer                             = {type = Protocol.DataType.short},
    commander                           = {type = Protocol.DataType.short},                                         --1是副团长,2是军团长,0不是
    create_time                         = {type = Protocol.DataType.int},
    server_id_len                       = {type = Protocol.DataType.short},
    server_id                           = {type = Protocol.DataType.string, length = Protocol.MAX_PEER_ID_LEN},
    server_name_len                     = {type = Protocol.DataType.short},
    server_name                         = {type = Protocol.DataType.string, length = Protocol.MAX_PEER_NAME_LEN},
    feed_back_info                      = {type = Protocol.DataType.short},
    player_type                         = {type = Protocol.DataType.short},
    bubble_id                           = {type = Protocol.DataType.short},
    role_name_len                       = {type = Protocol.DataType.short},
    role_name                           = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    crop_name_len                       = {type = Protocol.DataType.short},
    crop_name                           = {type = Protocol.DataType.string, length = Protocol.MAX_CROPS_NAME_LEN},
    contact_role_id                     = {type = Protocol.DataType.longlong},
    content_type_num                    = {type = Protocol.DataType.short},
    -- content                             = {type = Protocol.DataType.string, length = -1},
    fields                              = {'sender_id','img_type','img_id','msg_type','content_type','country_id','title_type','officer'
                                            ,'commander','create_time','server_id_len','server_id','server_name_len','server_name'
                                            ,'feed_back_info','player_type','bubble_id','role_name_len','role_name','crop_name_len','crop_name','contact_role_id'
                                            ,'content_type_num'}
}
Protocol.structs[Protocol.S_2_C_CHAT_MSG]                   = Protocol.Packet_S2C_ChatMsg

Protocol.Packet_C2S_ChatView = {
    --C_2_S_CHAT_VIEW
    type                                = {type = Protocol.DataType.char},
    Id                                  = {type = Protocol.DataType.uint},
    fields                              = {'type','Id'}
}
Protocol.structs[Protocol.C_2_S_CHAT_VIEW]                  = Protocol.Packet_C2S_ChatView

Protocol.Packet_C2S_ShowEquipment = {
    --C_2_S_SHOW_EQUIPMENT
    type                                = {type = Protocol.DataType.char},
    itemId                              = {type = Protocol.DataType.uint},
    fields                              = {'type','itemId'}
}
Protocol.structs[Protocol.C_2_S_SHOW_EQUIPMENT]             = Protocol.Packet_C2S_ShowEquipment

Protocol.Packet_C2S_ShowGeneral = {
    --C_2_S_SHOW_GENERAL
    type                                = {type = Protocol.DataType.char},
    generalId                           = {type = Protocol.DataType.int},
    fields                              = {'type','generalId'}
}
Protocol.structs[Protocol.C_2_S_SHOW_GENERAL]               = Protocol.Packet_C2S_ShowGeneral

Protocol.Packet_C2S_ShowBosomFriend = {
    --C_2_S_SHOW_BOSOM_FRIEND
    type                                = {type = Protocol.DataType.char},
    bosom_friend_id                     = {type = Protocol.DataType.uint},
    fields                              = {'type','bosom_friend_id'}
}
Protocol.structs[Protocol.C_2_S_SHOW_BOSOM_FRIEND]          = Protocol.Packet_C2S_ShowBosomFriend

Protocol.Packet_C2S_IncomeFind = {
    --C_2_S_INCOME_FIND
    incomeFindState                     = {type = Protocol.DataType.int},
    fields                              = {'incomeFindState'}
}
Protocol.structs[Protocol.C_2_S_INCOME_FIND]                = Protocol.Packet_C2S_IncomeFind

Protocol.Packet_S2C_IncomeFind = {
    --S_2_C_INCOME_FIND
    incomeFindState                     = {type = Protocol.DataType.int},
    fields                              = {'incomeFindState'}
}
Protocol.structs[Protocol.S_2_C_INCOME_FIND]                = Protocol.Packet_S2C_IncomeFind

Protocol.Packet_C2S_GameConfig = {
    --C_2_S_GAME_CONFIG
    cfgLen                              = {type = Protocol.DataType.short},
    cfgInfo                             = {type = Protocol.DataType.string, length = -1},
    fields                              = {'cfgLen','cfgInfo'}
}
Protocol.structs[Protocol.C_2_S_GAME_CONFIG]                = Protocol.Packet_C2S_GameConfig

Protocol.Packet_S2C_GameConfig = {
    --S_2_C_GAME_CONFIG
    cfgLen                              = {type = Protocol.DataType.short},
    cfgInfo                             = {type = Protocol.DataType.string, length = -1},
    fields                              = {'cfgLen','cfgInfo'}
}
Protocol.structs[Protocol.S_2_C_GAME_CONFIG]                = Protocol.Packet_S2C_GameConfig

Protocol.Packet_C2S_ShowMedal = {
    --C_2_S_SHOW_MEDAL
    type                                = {type = Protocol.DataType.char},
    itemId                              = {type = Protocol.DataType.uint},
    fields                              = {'type','itemId'}
}
Protocol.structs[Protocol.C_2_S_SHOW_MEDAL]                 = Protocol.Packet_C2S_ShowMedal

Protocol.Packet_C2S_MonthCardDrawReward = {
    --C_2_S_MONTH_CARD_DRAW_REWARD
    monthType                           = {type = Protocol.DataType.int},
    fields                              = {'monthType'}
}
Protocol.structs[Protocol.C_2_S_MONTH_CARD_DRAW_REWARD]     = Protocol.Packet_C2S_MonthCardDrawReward

Protocol.Packet_C2S_ShowHorse = {
    --C_2_S_SHOW_HORSE
    type                                = {type = Protocol.DataType.char},
    blood                               = {type = Protocol.DataType.uint},
    fields                              = {'type','blood'}
}
Protocol.structs[Protocol.C_2_S_SHOW_HORSE]                 = Protocol.Packet_C2S_ShowHorse

Protocol.Packet_C2S_ChatMsgLoad = {
    --C_2_s_CHAT_MSG_LOAD
    fields = {}
}
Protocol.structs[Protocol.C_2_S_CHAT_MSG_LOAD]              = Protocol.Packet_C2S_ChatMsgLoad

Protocol.Packet_S2C_ChatMsgLoadBegin = {
    fields  = {}
}
Protocol.structs[Protocol.S_2_C_CHAT_MSG_LOAD_BEGIN] = Protocol.Packet_S2C_ChatMsgLoadBegin

Protocol.Data_ChatMsg = {
    sender_id       = {type = Protocol.DataType.longlong},
    img_type        = {type = Protocol.DataType.short},
    img_id          = {type = Protocol.DataType.int},
    msg_type        = {type = Protocol.DataType.short},
    content_type    = {type = Protocol.DataType.short},
    country_id      = {type = Protocol.DataType.short},
    bubble_id       = {type = Protocol.DataType.short},
    title_type      = {type = Protocol.DataType.short},                                         --1官职 2竞技场排行
    officer         = {type = Protocol.DataType.short},
    commander       = {type = Protocol.DataType.short},  
    create_time     = {type = Protocol.DataType.int},
    role_name_len   = {type = Protocol.DataType.short},
    role_name       = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    crop_name_len   = {type = Protocol.DataType.short},
    crop_name       = {type = Protocol.DataType.string, length = Protocol.MAX_CROPS_NAME_LEN},
    content_len     = {type = Protocol.DataType.short},
    content         = {type = Protocol.DataType.string, length = Protocol.MAX_MSG_CONTENT_LEN},
    fields          = {'sender_id','img_type','img_id','msg_type','content_type','country_id','bubble_id','title_type','officer','commander',
                        'create_time','role_name_len','role_name','crop_name_len','crop_name','content_len','content'}
}

Protocol.Packet_S2C_ChatMsgLoad = {
    count                 = {type = Protocol.DataType.short},
    msgs                  = {type = Protocol.DataType.object, length = -1, clazz = 'Data_ChatMsg'},
    fields                = {'count', 'msgs'}
}
Protocol.structs[Protocol.S_2_C_CHAT_MSG_LOAD]        = Protocol.Packet_S2C_ChatMsgLoad

Protocol.Packet_S2C_ChatMsgLoadEnd = {
    fields = {}
}
Protocol.structs[Protocol.S_2_C_CHAT_MSG_LOAD_END]    = Protocol.Packet_S2C_ChatMsgLoadEnd

Protocol.Packet_C2S_ChooseBubble = {
    --C_2_S_CHOOSE_BUBBLE
    id                           = {type = Protocol.DataType.short},
    fields                       = {'id'}
}
Protocol.structs[Protocol.C_2_S_CHOOSE_BUBBLE]              = Protocol.Packet_C2S_ChooseBubble

Protocol.Packet_S2C_ChooseBubble = {
    ret                   = {type = Protocol.DataType.short},
    id                    = {type = Protocol.DataType.short},
    fields                = {'ret','id'}
}
Protocol.structs[Protocol.S_2_C_CHOOSE_BUBBLE]        = Protocol.Packet_S2C_ChooseBubble

Protocol.Packet_S2C_BroadMsgBegin = {
    fields = {}
}
Protocol.structs[Protocol.S_2_C_BROAD_MSG_BEGIN] = Protocol.Packet_S2C_BroadMsgBegin

Protocol.Data_BroadMsg = {
    id          = {type = Protocol.DataType.int},
    broad_type  = {type = Protocol.DataType.short},
    interval    = {type = Protocol.DataType.short},
    end_time    = {type = Protocol.DataType.int},
    content_len = {type = Protocol.DataType.short},
    content     = {type = Protocol.DataType.string, length = Protocol.MAX_BROAD_MSG_LEN},
    fields      = {'id','broad_type','interval','end_time','content_len','content'}
}

Protocol.Packet_S2C_BroadMsg = {
    --S_2_C_BROAD_MSG
    num    = {type = Protocol.DataType.short},
    msgs   = {type = Protocol.DataType.object, length = -1, clazz = 'Data_BroadMsg'},
    fields = {'num','msgs'}
}
Protocol.structs[Protocol.S_2_C_BROAD_MSG]                  = Protocol.Packet_S2C_BroadMsg

Protocol.Packet_S2C_BroadMsgEnd = {
    fields = {}
}
Protocol.structs[Protocol.S_2_C_BROAD_MSG_END] = Protocol.Packet_S2C_BroadMsgEnd

Protocol.Packet_S2C_FilterWordList = {
    --S_2_C_FILTER_WORD_LIST
    len                                 = {type = Protocol.DataType.ushort},
    filterWord                          = {type = Protocol.DataType.string, length = -1},
    fields                              = {'len','filterWord'}
}
Protocol.structs[Protocol.S_2_C_FILTER_WORD_LIST]           = Protocol.Packet_S2C_FilterWordList

Protocol.Packet_S2C_FilterWordDelete = {
    --S_2_C_FILTER_WORD_DELETE
    len                                 = {type = Protocol.DataType.ushort},
    filterWord                          = {type = Protocol.DataType.string, length = -1},
    fields                              = {'len','filterWord'}
}
Protocol.structs[Protocol.S_2_C_FILTER_WORD_DELETE]         = Protocol.Packet_S2C_FilterWordDelete

Protocol.Packet_S2C_Instructor = {
    --S_2_C_INSTRUCTOR
    isInstructor                        = {type = Protocol.DataType.char},
    fields                              = {'isInstructor'}
}
Protocol.structs[Protocol.S_2_C_INSTRUCTOR]                 = Protocol.Packet_S2C_Instructor

Protocol.Packet_S2C_PromptInfo = {
    --S_2_C_PROMPT_INFO
    promptInfoLen                       = {type = Protocol.DataType.short},
    promptInfo                          = {type = Protocol.DataType.string, length = -1},
    fields                              = {'promptInfoLen','promptInfo'}
}
Protocol.structs[Protocol.S_2_C_PROMPT_INFO]                = Protocol.Packet_S2C_PromptInfo

Protocol.Packet_S2C_GlobalCompensationDraw = {
    --S_2_C_GlOBAL_COMPENSATION_DRAW
    silver                              = {type = Protocol.DataType.int},
    gold                                = {type = Protocol.DataType.int},
    order                               = {type = Protocol.DataType.int},
    geste                               = {type = Protocol.DataType.int},
    soul                                = {type = Protocol.DataType.int},
    jade                                = {type = Protocol.DataType.int},
    bun                                 = {type = Protocol.DataType.int},
    meat                                = {type = Protocol.DataType.int},
    wine                                = {type = Protocol.DataType.int},
    purplejade                          = {type = Protocol.DataType.int},
    cityBattleCredit                    = {type = Protocol.DataType.int},
    insigniaNum                         = {type = Protocol.DataType.int},
    pear                                = {type = Protocol.DataType.int},
    newjade                             = {type = Protocol.DataType.int},
    censer                              = {type = Protocol.DataType.int},
    rewardorder                         = {type = Protocol.DataType.int},
    amber                               = {type = Protocol.DataType.int},
    sapphire                            = {type = Protocol.DataType.int},
    langyaJade                          = {type = Protocol.DataType.int},
    attriLeader                         = {type = Protocol.DataType.int},
    attriAttack                         = {type = Protocol.DataType.int},
    attriMentality                      = {type = Protocol.DataType.int},
    attriSoldierNum                     = {type = Protocol.DataType.int},
    athleticsIntegral                   = {type = Protocol.DataType.int},
    fields                              = {'silver','gold','order','geste','soul','jade','bun','meat','wine','purplejade','cityBattleCredit','insigniaNum'
                                            ,'pear','newjade','censer','rewardorder','amber','sapphire','langyaJade','attriLeader','attriAttack','attriMentality'
                                            ,'attriSoldierNum','athleticsIntegral'}
}
Protocol.structs[Protocol.S_2_C_GlOBAL_COMPENSATION_DRAW]   = Protocol.Packet_S2C_GlobalCompensationDraw