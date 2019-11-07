local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_LOGIN                                = Protocol.C_2_S_ACCOUNT_BASE + 0
Protocol.C_2_S_LOGOFF                               = Protocol.C_2_S_ACCOUNT_BASE + 1
Protocol.C_2_S_ACCOUNT_CREATENAME                   = Protocol.C_2_S_ACCOUNT_BASE + 2
Protocol.C_2_S_ACCOUNT_CREATE                       = Protocol.C_2_S_ACCOUNT_BASE + 3
Protocol.C_2_S_ACCOUNT_NEWBIE                       = Protocol.C_2_S_ACCOUNT_BASE + 4
Protocol.C_2_S_ACCOUNT_SELECT_CITY                  = Protocol.C_2_S_ACCOUNT_BASE + 5
Protocol.C_2_S_ACCONT_CANCEL_FCM                    = Protocol.C_2_S_ACCOUNT_BASE + 6
Protocol.C_2_S_LOAD_CHAR_INFO                       = Protocol.C_2_S_ACCOUNT_BASE + 7
Protocol.C_2_S_RAND_NAME                            = Protocol.C_2_S_ACCOUNT_BASE + 8
Protocol.C_2_S_ACCONT_RESET_FCM                     = Protocol.C_2_S_ACCOUNT_BASE + 9
Protocol.C_2_S_ACCOUNT_CHANGENAME                   = Protocol.C_2_S_ACCOUNT_BASE + 10
Protocol.C_2_S_ENTER_GAME                           = Protocol.C_2_S_ACCOUNT_BASE + 11
Protocol.C_2_S_LOAD_MULTI_ACCOUNT                   = Protocol.C_2_S_ACCOUNT_BASE + 12
Protocol.C_2_S_ASSISTANT_SETTING                    = Protocol.C_2_S_ACCOUNT_BASE + 13
Protocol.C_2_S_UPDATE_DEFAULT_ACCOUNT               = Protocol.C_2_S_ACCOUNT_BASE + 15
Protocol.C_2_S_BIND_MOBILE                          = Protocol.C_2_S_ACCOUNT_BASE + 16
Protocol.C_2_S_UNBIND_MOBILE                        = Protocol.C_2_S_ACCOUNT_BASE + 17
Protocol.C_2_S_BIND_MOBILE_INFO                     = Protocol.C_2_S_ACCOUNT_BASE + 18
Protocol.C_2_S_MODITY_ACCOUNT_NAME                  = Protocol.C_2_S_ACCOUNT_BASE + 19
Protocol.C_2_S_SWAP_SESSION                         = Protocol.C_2_S_ACCOUNT_BASE + 20

Protocol.S_2_C_GATE_STATE                           = Protocol.S_2_C_ACCOUNT_BASE + 0
Protocol.S_2_C_LOGIN_RESULT                         = Protocol.S_2_C_ACCOUNT_BASE + 1
Protocol.S_2_C_GAMESERVER_OFFLINE                   = Protocol.S_2_C_ACCOUNT_BASE + 2
Protocol.S_2_C_UPDATE_LOGIN_NAME                    = Protocol.S_2_C_ACCOUNT_BASE + 3
Protocol.S_2_C_BIND_MOBILE                          = Protocol.S_2_C_ACCOUNT_BASE + 4
Protocol.S_2_C_UNBIND_MOBILE                        = Protocol.S_2_C_ACCOUNT_BASE + 5
Protocol.S_2_C_BIND_MOBILE_INFO                     = Protocol.S_2_C_ACCOUNT_BASE + 6
Protocol.S_2_C_MODITY_ACCOUNT_NAME                  = Protocol.S_2_C_ACCOUNT_BASE + 7
Protocol.S_2_C_MODITY_ACCNAME_COST                  = Protocol.S_2_C_ACCOUNT_BASE + 8
Protocol.S_2_C_ACCOUNT_INFO                         = Protocol.S_2_C_ACCOUNT_BASE + 10
Protocol.S_2_C_ACCOUNT_CREATENAME                   = Protocol.S_2_C_ACCOUNT_BASE + 11
Protocol.S_2_C_ACCOUNT_CREATE                       = Protocol.S_2_C_ACCOUNT_BASE + 12
Protocol.S_2_C_RAND_NAME                            = Protocol.S_2_C_ACCOUNT_BASE + 13
Protocol.S_2_C_ACCOUNT_MULTI_INFO                   = Protocol.S_2_C_ACCOUNT_BASE + 14
Protocol.S_2_C_ACCOUNT_CHANGENAME                   = Protocol.S_2_C_ACCOUNT_BASE + 15
Protocol.S_2_C_ENTER_GAME                           = Protocol.S_2_C_ACCOUNT_BASE + 16
-- Protocol.S_2_C_ASSISTANT_SETTING                    = Protocol.S_2_C_ACCOUNT_BASE + 17
Protocol.S_2_C_SWAP_SESSION                         = Protocol.S_2_C_ACCOUNT_BASE + 17
Protocol.S_2_C_UPDATE_DEFAULT_ACCOUNT               = Protocol.S_2_C_ACCOUNT_BASE + 18
Protocol.S_2_C_GlOBAL_COMPENSATION_INFO             = Protocol.S_2_C_ACCOUNT_BASE + 19


------------------------------C_2_S------------------------------
Protocol.Packet_C2S_Login = {
    --C_2_S_LOGIN
    acc_id                      = {type = Protocol.DataType.ulonglong},
    name_len                    = {type = Protocol.DataType.ushort},
    login_name                  = {type = Protocol.DataType.string, length = Protocol.MAX_LOGIN_NAME_LEN},
    server_id_len               = {type = Protocol.DataType.ushort},
    server_id                   = {type = Protocol.DataType.string, length = Protocol.MAX_PEER_ID_LEN},
    source_len                  = {type = Protocol.DataType.ushort},
    source                      = {type = Protocol.DataType.string, length = Protocol.MAX_SOURCE_LEN},
    timestamp                   = {type = Protocol.DataType.uint},
    fcm                         = {type = Protocol.DataType.char},
    ticket                      = {type = Protocol.DataType.binary, length = Protocol.MD5_LEN},
    version                     = {type = Protocol.DataType.uint},
    fields                      = {'acc_id', 'name_len', 'login_name', 'server_id_len', 'server_id'
                                    ,'source_len', 'source', 'timestamp', 'fcm', 'ticket', 'version'}
}
Protocol.structs[Protocol.C_2_S_LOGIN]                              = Protocol.Packet_C2S_Login

Protocol.Packet_C2S_AccountCreate = {
    --C_2_S_ACCOUNT_CREATE
    name_len                    = {type = Protocol.DataType.ushort},
    name                        = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    country_id                  = {type = Protocol.DataType.uint},
    appearance_id               = {type = Protocol.DataType.char},
    fields                      = {'name_len', 'name', 'country_id', 'appearance_id'}
}
Protocol.structs[Protocol.C_2_S_ACCOUNT_CREATE]                     = Protocol.Packet_C2S_AccountCreate

Protocol.Packet_C2S_ModityAccountName = {
    name_len                    = {type = Protocol.DataType.short},
    name                        = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    fields                      = {'name_len','name'}
}
Protocol.structs[Protocol.C_2_S_MODITY_ACCOUNT_NAME]                     = Protocol.Packet_C2S_ModityAccountName

Protocol.Packet_C2S_SWAP_SESSION = {
    -- Protocol.C_2_S_SWAP_SESSION
    session_seed                = {type = Protocol.DataType.int},
    role_id                     = {type = Protocol.DataType.longlong},
    fields                      = {'session_seed','role_id'}
}
Protocol.structs[Protocol.C_2_S_SWAP_SESSION]                     = Protocol.Packet_C2S_SWAP_SESSION

------------------------------S_2_C------------------------------
Protocol.Packet_S2C_GateState = {
    --S_2_C_GATE_STATE
    state                       = {type = Protocol.DataType.char},
    key                         = {type = Protocol.DataType.longlong},
    fields                      = {'state', 'key'}
}
Protocol.structs[Protocol.S_2_C_GATE_STATE]                         = Protocol.Packet_S2C_GateState

Protocol.Packet_S2C_LoginResult = {
    --S_2_C_LOGIN_RESULT
    result                      = {type = Protocol.DataType.char},
    is_new                      = {type = Protocol.DataType.char},
    name_len                    = {type = Protocol.DataType.ushort},
    name                        = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    fields                      = {'result', 'is_new', "name_len", 'name'}
}
Protocol.structs[Protocol.S_2_C_LOGIN_RESULT]                       = Protocol.Packet_S2C_LoginResult

Protocol.Packet_S2C_AccountInfo = {
    --S_2_C_ACCOUNT_INFO
    acc_name_len                 = {type = Protocol.DataType.ushort},
    acc_name                     = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    diamond                     = {type = Protocol.DataType.uint},
    vip_lvl                     = {type = Protocol.DataType.char},
    createTime                  = {type = Protocol.DataType.int},
    fields                      = {'acc_name_len','acc_name','diamond','vip_lvl','createTime'}
}
Protocol.structs[Protocol.S_2_C_ACCOUNT_INFO]                       = Protocol.Packet_S2C_AccountInfo

Protocol.Packet_S2C_CreateNameResult = {
    --S_2_C_ACCOUNT_CREATENAME
    ret                         = {type = Protocol.DataType.char},
    fields                      = {'ret'}
}
Protocol.structs[Protocol.S_2_C_ACCOUNT_CREATENAME]                 = Protocol.Packet_S2C_CreateNameResult

Protocol.Packet_S2C_CreateResult = {
    --S_2_C_ACCOUNT_CREATE
    ret                         = {type = Protocol.DataType.char},
    country_id                  = {type = Protocol.DataType.int},
    fields                      = {'ret', 'country_id'}
}
Protocol.structs[Protocol.S_2_C_ACCOUNT_CREATE]                     = Protocol.Packet_S2C_CreateResult

Protocol.Packet_S2C_RandName = {
    --S_2_C_RAND_NAME
    name_len                    = {type = Protocol.DataType.ushort},
    name                        = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    fields                      = {'name_len', 'name'}
}
Protocol.structs[Protocol.S_2_C_RAND_NAME]                          = Protocol.Packet_S2C_RandName

Protocol.Data_AccountInfo = {
    server_id_len               = {type = Protocol.DataType.ushort},
    server_id                   = {type = Protocol.DataType.char, length = -1},
    acc_id                      = {type = Protocol.DataType.ulonglong},
    name_len                    = {type = Protocol.DataType.ushort},
    name                        = {type = Protocol.DataType.char, length = -1},
    country_id                  = {type = Protocol.DataType.char},
    level                       = {type = Protocol.DataType.short},
    soul                        = {type = Protocol.DataType.uint},
    prestige                    = {type = Protocol.DataType.uint},
    vip_lvl                     = {type = Protocol.DataType.short},
    gold                        = {type = Protocol.DataType.uint},
    isDefault                   = {type = Protocol.DataType.char},
    fields                      = {'server_id_len', 'server_id','acc_id','name_len','name','country_id','level','soul','prestige','vip_lvl','gold','isDefault'}
}
Protocol.Packet_S2C_AccountMultiInfo = {
    --S_2_C_ACCOUNT_MULTI_INFO
    accCount                    = {type = Protocol.DataType.ushort},
    accInfo                     = {type = Protocol.DataType.object, length = -1, clazz='Data_AccountInfo'},
    fields                      = {'accCount', 'accInfo'}
}
Protocol.structs[Protocol.S_2_C_ACCOUNT_MULTI_INFO]                 = Protocol.Packet_S2C_AccountMultiInfo

Protocol.Packet_S2C_ChangeNameResult = {
    --S_2_C_ACCOUNT_CHANGENAME
    ret                         = {type = Protocol.DataType.char},          --1-repeat 2-success
    fields                      = {'ret'}
}
Protocol.structs[Protocol.S_2_C_ACCOUNT_CHANGENAME]                 = Protocol.Packet_S2C_ChangeNameResult

Protocol.Packet_S2C_EnterGame = {
    --S_2_C_ENTER_GAME
    ret                         = {type = Protocol.DataType.char},          --1-ok 2-failed
    fields                      = {'ret'}
}
Protocol.structs[Protocol.S_2_C_ENTER_GAME]                         = Protocol.Packet_S2C_EnterGame

Protocol.Packet_S2C_UpdateDefaultAccount = {
    --S_2_C_UPDATE_DEFAULT_ACCOUNT
    ret                         = {type = Protocol.DataType.char},
    fields                      = {'ret'}
}
Protocol.structs[Protocol.S_2_C_UPDATE_DEFAULT_ACCOUNT]             = Protocol.Packet_S2C_UpdateDefaultAccount

Protocol.Packet_S2C_ModityAccountName = {
    ret                         = {type = Protocol.DataType.short},
    rename_times                = {type = Protocol.DataType.int},
    name_len                    = {type = Protocol.DataType.short},
    name                        = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    fields                      = {'ret','rename_times','name_len','name'}
}
Protocol.structs[Protocol.S_2_C_MODITY_ACCOUNT_NAME]             = Protocol.Packet_S2C_ModityAccountName

Protocol.Packet_S2C_GlobalCompensationInfo = {
    --S_2_C_GlOBAL_COMPENSATION_INFO
    deadline                    = {type = Protocol.DataType.int},
    fields                      = {'deadline'}
}
Protocol.structs[Protocol.S_2_C_GlOBAL_COMPENSATION_INFO]           = Protocol.Packet_S2C_GlobalCompensationInfo

Protocol.Packet_S2C_SWAP_SESSION = {
    -- S_2_C_SWAP_SESSION
    ret                    = {type = Protocol.DataType.short}, -- ret 0 成功，1 在别的设备上登录
    fields                 = {'ret'}
}
Protocol.structs[Protocol.S_2_C_SWAP_SESSION]           = Protocol.Packet_S2C_SWAP_SESSION

-- Protocol.Packet_S2C_AssistantSetting = {
--     --S_2_C_ASSISTANT_SETTING
--     setting_len                 = {type = Protocol.DataType.ushort},
--     settingInfo                 = {type = Protocol.DataType.char, length = -1},
--     isDrawSalary                = {type = Protocol.DataType.char},
--     patrol_nums                 = {type = Protocol.DataType.int},
--     voyage_nums                 = {type = Protocol.DataType.int},
--     produce_nums                = {type = Protocol.DataType.int},
--     talk_counts                 = {type = Protocol.DataType.int},
--     free_soldier_nums           = {type = Protocol.DataType.int},
--     perDayCollectionTotalNum    = {type = Protocol.DataType.int},
--     perDayCollectionNum         = {type = Protocol.DataType.int},
--     huntingNum                  = {type = Protocol.DataType.int},
--     towerOrderNum               = {type = Protocol.DataType.int},
--     playJarNum                  = {type = Protocol.DataType.int},
--     dayTaskNum                  = {type = Protocol.DataType.int},
--     dispatchNum                 = {type = Protocol.DataType.int},
--     perDayContribute            = {type = Protocol.DataType.int},
--     isOfficerSelectDay          = {type = Protocol.DataType.int},
--     questTimes                  = {type = Protocol.DataType.int},
--     extraQuestTimes             = {type = Protocol.DataType.int},
--     autoRepair                  = {type = Protocol.DataType.int},
--     cityBattle                  = {type = Protocol.DataType.int},
--     appointNum                  = {type = Protocol.DataType.int},
--     appointCd                   = {type = Protocol.DataType.int},
--     fields                      = {'setting_len','settingInfo','isDrawSalary','patrol_nums','voyage_nums','produce_nums','talk_counts','free_soldier_nums'
--                                     ,'perDayCollectionTotalNum','perDayCollectionNum','huntingNum','towerOrderNum','playJarNum','dayTaskNum','dispatchNum'
--                                     ,'perDayContribute','isOfficerSelectDay','questTimes','extraQuestTimes','autoRepair','cityBattle','appointNum','appointCd'}
-- }
-- Protocol.structs[Protocol.S_2_C_ASSISTANT_SETTING]                  = Protocol.Packet_S2C_AssistantSetting





