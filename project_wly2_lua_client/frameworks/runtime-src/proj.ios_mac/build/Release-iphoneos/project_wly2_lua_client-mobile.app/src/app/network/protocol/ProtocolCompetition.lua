local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_COMPETITION_SIGNUP                 = Protocol.C_2_S_COMPETITION_BASE + 0
Protocol.C_2_S_COMPETITION_INSPIRE                = Protocol.C_2_S_COMPETITION_BASE + 1
Protocol.C_2_S_COMPETITION_SAVE                   = Protocol.C_2_S_COMPETITION_BASE + 2
Protocol.C_2_S_COMPETITION_ROB_ATTACK_SIDE        = Protocol.C_2_S_COMPETITION_BASE + 3
Protocol.C_2_S_COMPETITION_CHEER                  = Protocol.C_2_S_COMPETITION_BASE + 4
Protocol.C_2_S_COMPETITION_GET_FIGHT_PAIR         = Protocol.C_2_S_COMPETITION_BASE + 5
Protocol.C_2_S_COMPETITION_CHANGE_FIGHT_PAIR      = Protocol.C_2_S_COMPETITION_BASE + 6
Protocol.C_2_S_COMPETITION_GET_FIGHT_HISTORY      = Protocol.C_2_S_COMPETITION_BASE + 7
Protocol.C_2_S_COMPETITION_GET_CHEER_HISTORY      = Protocol.C_2_S_COMPETITION_BASE + 8
Protocol.C_2_S_COMPETITION_GET_SIGNUP_NUM         = Protocol.C_2_S_COMPETITION_BASE + 9
Protocol.C_2_S_COMPETITION_GET_SERVER_TIME        = Protocol.C_2_S_COMPETITION_BASE + 10
Protocol.C_2_S_COMPETITION_GET_CHEER_PAIR         = Protocol.C_2_S_COMPETITION_BASE + 11
Protocol.C_2_S_COMPETITION_GET_CONFIG             = Protocol.C_2_S_COMPETITION_BASE + 12
Protocol.C_2_S_COMPETITION_GET_BATTLE_RECORD      = Protocol.C_2_S_COMPETITION_BASE + 13
Protocol.C_2_S_COMPETITION_GET_SELF_FIGHT_HISTORY = Protocol.C_2_S_COMPETITION_BASE + 14

Protocol.S_2_C_COMPETITION_OPEN_SIGNUP            = Protocol.S_2_C_COMPETITION_BASE + 0
Protocol.S_2_C_COMPETITION_CLOSE                  = Protocol.S_2_C_COMPETITION_BASE + 1
Protocol.S_2_C_COMPETITION_SIGNUP_RES             = Protocol.S_2_C_COMPETITION_BASE + 2
Protocol.S_2_C_COMPETITION_INSPIRE_RES            = Protocol.S_2_C_COMPETITION_BASE + 3
Protocol.S_2_C_COMPETITION_SAVE_RES               = Protocol.S_2_C_COMPETITION_BASE + 4
Protocol.S_2_C_COMPETITION_OPPONENT_NOTICE        = Protocol.S_2_C_COMPETITION_BASE + 5
Protocol.S_2_C_COMPETITION_ROB_ATTACK_SIDE_NOTICE = Protocol.S_2_C_COMPETITION_BASE + 6
Protocol.S_2_C_COMPETITION_CHEER_RES              = Protocol.S_2_C_COMPETITION_BASE + 7
Protocol.S_2_C_COMPETITION_FIGHT_RES              = Protocol.S_2_C_COMPETITION_BASE + 8
Protocol.S_2_C_COMPETITION_FIGHT_PAIR             = Protocol.S_2_C_COMPETITION_BASE + 9
Protocol.S_2_C_COMPETITION_FIGHT_PLAYERS          = Protocol.S_2_C_COMPETITION_BASE + 10
Protocol.S_2_C_COMPETITION_FIGHT_PLAYERS_END      = Protocol.S_2_C_COMPETITION_BASE + 11
Protocol.S_2_C_COMPETITION_STATUS                 = Protocol.S_2_C_COMPETITION_BASE + 12
Protocol.S_2_C_COMPETITION_FIGHT_HISTORY          = Protocol.S_2_C_COMPETITION_BASE + 13
Protocol.S_2_C_COMPETITION_CHEER_HISTORY          = Protocol.S_2_C_COMPETITION_BASE + 14
Protocol.S_2_C_COMPETITION_CHEER_HISTORY_END      = Protocol.S_2_C_COMPETITION_BASE + 15
Protocol.S_2_C_COMPETITION_SIGNUP_NUM             = Protocol.S_2_C_COMPETITION_BASE + 16
Protocol.S_2_C_COMPETITION_SERVER_TIME            = Protocol.S_2_C_COMPETITION_BASE + 17
Protocol.S_2_C_COMPETITION_CONFIG                 = Protocol.S_2_C_COMPETITION_BASE + 18
Protocol.S_2_C_COMPETITION_BATTLE_RECORD          = Protocol.S_2_C_COMPETITION_BASE + 19
Protocol.S_2_C_COMPETITION_BATTLE_RECORD_END      = Protocol.S_2_C_COMPETITION_BASE + 20

Protocol.Packet_C2S_CompetitionSignup = {
    --C_2_S_COMPETITION_SIGNUP
}
Protocol.structs[Protocol.C_2_S_COMPETITION_SIGNUP]  = Protocol.Packet_C2S_CompetitionSignup

Protocol.Packet_C2S_CompetitionInspire = {
    --C_2_S_COMPETITION_INSPIRE
    type   = {type = Protocol.DataType.char},
    fields = {'type'}
}
Protocol.structs[Protocol.C_2_S_COMPETITION_INSPIRE]  = Protocol.Packet_C2S_CompetitionInspire

Protocol.Packet_C2S_CompetitionSave = {
    --C_2_S_COMPETITION_SAVE
    type   = {type = Protocol.DataType.char},
    fields = {'type'}
}
Protocol.structs[Protocol.C_2_S_COMPETITION_SAVE]  = Protocol.Packet_C2S_CompetitionSave

Protocol.Packet_C2S_CompetitionRobAttackSide = {
    --C_2_S_COMPETITION_ROB_ATTACK_SIDE
    type   = {type = Protocol.DataType.char},
    fields = {'type'}
}
Protocol.structs[Protocol.C_2_S_COMPETITION_ROB_ATTACK_SIDE]  = Protocol.Packet_C2S_CompetitionRobAttackSide

Protocol.Packet_C2S_CompetitionCheer = {
    --C_2_S_COMPETITION_CHEER
    type           = {type = Protocol.DataType.char},
    serverIdLen    = {type = Protocol.DataType.short},
    serverId       = {type = Protocol.DataType.string, length = Protocol.MAX_PEER_NAME_LEN},
    accountNameLen = {type = Protocol.DataType.short},
    accountName    = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    fields         = {'type','serverIdLen','serverId','accountNameLen','accountName',}
}
Protocol.structs[Protocol.C_2_S_COMPETITION_CHEER]  = Protocol.Packet_C2S_CompetitionCheer

Protocol.Packet_C2S_CompetitionGetFightPair = {
    --C_2_S_COMPETITION_GET_FIGHT_PAIR
    type   = {type = Protocol.DataType.char},
    fields = {'type'}
}
Protocol.structs[Protocol.C_2_S_COMPETITION_GET_FIGHT_PAIR]  = Protocol.Packet_C2S_CompetitionGetFightPair

Protocol.Packet_C2S_CompetitionChangeFightPair = {
    --C_2_S_COMPETITION_CHANGE_FIGHT_PAIR
    type   = {type = Protocol.DataType.char},
    fields = {'type'}
}
Protocol.structs[Protocol.C_2_S_COMPETITION_CHANGE_FIGHT_PAIR]  = Protocol.Packet_C2S_CompetitionChangeFightPair

Protocol.Packet_C2S_CompetitionGetFightHistory = {
    --C_2_S_COMPETITION_GET_FIGHT_HISTORY
    serverIdLen    = {type = Protocol.DataType.short},
    serverId       = {type = Protocol.DataType.string, length = Protocol.MAX_PEER_NAME_LEN},
    accountNameLen = {type = Protocol.DataType.short},
    accountName    = {type = Protocol.DataType.string, Protocol.MAX_ACCOUNT_NAME_LEN},
    fields         = {'serverIdLen','serverId','accountNameLen','accountName',}
}
Protocol.structs[Protocol.C_2_S_COMPETITION_GET_FIGHT_HISTORY]  = Protocol.Packet_C2S_CompetitionGetFightHistory

Protocol.Packet_C2S_CompetitionGetCheerHistory = {
    --C_2_S_COMPETITION_GET_CHEER_HISTORY
}
Protocol.structs[Protocol.C_2_S_COMPETITION_GET_CHEER_HISTORY]  = Protocol.Packet_C2S_CompetitionGetCheerHistory

Protocol.Packet_C2S_CompetitionGetSignupNum = {
    --C_2_S_COMPETITION_GET_SIGNUP_NUM
    type   = {type = Protocol.DataType.char},
    fields = {'type'}
}
Protocol.structs[Protocol.C_2_S_COMPETITION_GET_SIGNUP_NUM]  = Protocol.Packet_C2S_CompetitionGetSignupNum

Protocol.Packet_C2S_CompetitionGetServerTime = {
    --C_2_S_COMPETITION_GET_SERVER_TIME
}
Protocol.structs[Protocol.C_2_S_COMPETITION_GET_SERVER_TIME]  = Protocol.Packet_C2S_CompetitionGetServerTime

Protocol.Packet_C2S_CompetitionGetCheerPair = {
    --C_2_S_COMPETITION_GET_CHEER_PAIR
    type     = {type = Protocol.DataType.char},
    serialNO = {type = Protocol.DataType.int},
    fields   = {'type','serialNO'}
}
Protocol.structs[Protocol.C_2_S_COMPETITION_GET_CHEER_PAIR]  = Protocol.Packet_C2S_CompetitionGetCheerPair

Protocol.Packet_C2S_CompetitionGetConfig = {
    --C_2_S_COMPETITION_GET_CONFIG
}
Protocol.structs[Protocol.C_2_S_COMPETITION_GET_CONFIG]  = Protocol.Packet_C2S_CompetitionGetConfig

Protocol.Packet_C2S_CompetitionGetBattleRecord = {
    --C_2_S_COMPETITION_GET_BATTLE_RECORD
    type   = {type = Protocol.DataType.char},
    fields = {'type'}
}
Protocol.structs[Protocol.C_2_S_COMPETITION_GET_BATTLE_RECORD]  = Protocol.Packet_C2S_CompetitionGetBattleRecord

Protocol.Packet_C2S_CompetitionGetSelfFightHistory = {
    --C_2_S_COMPETITION_GET_SELF_FIGHT_HISTORY
}
Protocol.structs[Protocol.C_2_S_COMPETITION_GET_SELF_FIGHT_HISTORY]  = Protocol.Packet_C2S_CompetitionGetSelfFightHistory

Protocol.Packet_S2C_CompetitionOpenSignup = {
    isLocal = {type = Protocol.DataType.char},
    fields  = {'isLocal'}
}
Protocol.structs[Protocol.S_2_C_COMPETITION_OPEN_SIGNUP]  = Protocol.Packet_S2C_CompetitionOpenSignup

Protocol.Packet_S2C_CompetitionClose = {
    isLocal = {type = Protocol.DataType.char},
    fields  = {'isLocal'}
}
Protocol.structs[Protocol.S_2_C_COMPETITION_CLOSE]  = Protocol.Packet_S2C_CompetitionClose

Protocol.Packet_S2C_CompetitionSignupRes = {
    -- 1 for success, 0 for failure
    res    = {type = Protocol.DataType.char},
    fields = {'res'}
}
Protocol.structs[Protocol.S_2_C_COMPETITION_SIGNUP_RES]  = Protocol.Packet_S2C_CompetitionSignupRes

Protocol.Packet_S2C_CompetitionInspireRes = {
    -- 0 for attack, 1 for defense, 2 for failure
    res    = {type = Protocol.DataType.char},
    fields = {'res'}
}
Protocol.structs[Protocol.S_2_C_COMPETITION_INSPIRE_RES]  = Protocol.Packet_S2C_CompetitionInspireRes

Protocol.Packet_S2C_CompetitionSaveRes = {
    -- 1 for success, 0 for failure
    res    = {type = Protocol.DataType.char},
    fields = {'res'}
}
Protocol.structs[Protocol.S_2_C_COMPETITION_SAVE_RES]  = Protocol.Packet_S2C_CompetitionSaveRes

Protocol.Packet_S2C_CompetitionOpponentNotice = {
    nameLen    = {type = Protocol.DataType.short},
    name       = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    isAttacker = {type = Protocol.DataType.char},
    fields     = {'nameLen','name','isAttacker',}
}
Protocol.structs[Protocol.S_2_C_COMPETITION_OPPONENT_NOTICE]  = Protocol.Packet_S2C_CompetitionOpponentNotice

Protocol.Packet_S2C_CompetitionRobAttackSideNotice = {
    nameLen = {type = Protocol.DataType.short},
    name    = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    fields  = {'nameLen','name'}
}
Protocol.structs[Protocol.S_2_C_COMPETITION_ROB_ATTACK_SIDE_NOTICE]  = Protocol.Packet_S2C_CompetitionRobAttackSideNotice

Protocol.Packet_S2C_CompetitionCheerRes = {
    -- 1 for success, 0 for failure
    res    = {type = Protocol.DataType.char},
    fields = {'res'}
}
Protocol.structs[Protocol.S_2_C_COMPETITION_CHEER_RES]  = Protocol.Packet_S2C_CompetitionCheerRes

Protocol.Packet_S2C_CompetitionFightRes = {
    nameLen = {type = Protocol.DataType.short},
    name    = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    result  = {type = Protocol.DataType.char},
    fields  = {'nameLen','name','result'}
}
Protocol.structs[Protocol.S_2_C_COMPETITION_FIGHT_RES]  = Protocol.Packet_S2C_CompetitionFightRes

Protocol.Data_PlayerDetail = {
    nameLen      = {type = Protocol.DataType.short},
    name         = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    serverIdLen  = {type = Protocol.DataType.short},
    serverId     = {type = Protocol.DataType.string, length = Protocol.MAX_PEER_NAME_LEN},
    level        = {type = Protocol.DataType.short},
    country      = {type = Protocol.DataType.char},
    power        = {type = Protocol.DataType.int},
    winHistory   = {type = Protocol.DataType.short},
    loseHistory  = {type = Protocol.DataType.short},
    roundStatus  = {type = Protocol.DataType.char},
    setCount     = {type = Protocol.DataType.char},
    attackLevel  = {type = Protocol.DataType.char},
    defenseLevel = {type = Protocol.DataType.char},
    robLoss      = {type = Protocol.DataType.char},
    isAttacker   = {type = Protocol.DataType.char},
    cheerNum     = {type = Protocol.DataType.short},
    fields       = {'nameLen','name','serverIdLen','serverId','level','country','power','winHistory','loseHistory','roundStatus','setCount','attackLevel','defenseLevel','robLoss','isAttacker','cheerNum',}
}

Protocol.Packet_S2C_CompetitionFightPair = {
    currentRound = {type = Protocol.DataType.char},
    totalRound   = {type = Protocol.DataType.char},
    firstPlayer  = {type = Protocol.DataType.object, length = -1, clazz = 'Data_PlayerDetail'},
    secondPlayer = {type = Protocol.DataType.object, length = -1, clazz = 'Data_PlayerDetail'},
    canCheer     = {type = Protocol.DataType.char},
    fields       = {'currentRound','totalRound','firstPlayer','secondPlayer','canCheer'}
}
Protocol.structs[Protocol.S_2_C_COMPETITION_FIGHT_PAIR]  = Protocol.Packet_S2C_CompetitionFightPair

Protocol.Data_SimplePlayerData = {
    nameLen     = {type = Protocol.DataType.short},
    name        = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    serverIdLen = {type = Protocol.DataType.short},
    serverId    = {type = Protocol.DataType.string, length = Protocol.MAX_PEER_NAME_LEN},
    serialNO    = {type = Protocol.DataType.int},
    round       = {type = Protocol.DataType.char},
    isDead      = {type = Protocol.DataType.char},
    fields      = {'nameLen','name','serverIdLen','serverId','serialNO','round','isDead',}
}

Protocol.Packet_S2C_CompetitionFightPlayers = {
    currentRound = {type = Protocol.DataType.char},
    totalRound   = {type = Protocol.DataType.char},
    playerNumber = {type = Protocol.DataType.short},
    players      = {type = Protocol.DataType.object, length = -1, clazz = 'Data_SimplePlayerData'},
    fields       = {'currentRound','totalRound','playerNumber','players'}
}
Protocol.structs[Protocol.S_2_C_COMPETITION_FIGHT_PLAYERS]  = Protocol.Packet_S2C_CompetitionFightPlayers

Protocol.Packet_S2C_CompetitionFightPlayersEnd = {
}
Protocol.structs[Protocol.S_2_C_COMPETITION_FIGHT_PLAYERS_END]  = Protocol.Packet_S2C_CompetitionFightPlayersEnd

Protocol.Packet_S2C_CompetitionStatus = {
    isLocal            = {type = Protocol.DataType.char},
    status             = {type = Protocol.DataType.char}, -- 0 open, 1 started, 2 closed = {type = Protocol.DataType.char},
    openTime           = {type = Protocol.DataType.int},
    closeTime          = {type = Protocol.DataType.int},
    hasSignedup        = {type = Protocol.DataType.char},
    master_address_len = {type = Protocol.DataType.short},
    master_address     = {type = Protocol.DataType.string, length = Protocol.MAX_REPORT_ADDRESS_LEN},
    fields             = {'isLocal','status','openTime','closeTime','hasSignedup','master_address_len','master_address',}
}
Protocol.structs[Protocol.S_2_C_COMPETITION_STATUS]  = Protocol.Packet_S2C_CompetitionStatus

Protocol.Data_FightRecord = {
    roundNumber          = {type = Protocol.DataType.char},
    accountNameLen       = {type = Protocol.DataType.short},
    accountName          = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    serverIdLen          = {type = Protocol.DataType.short},
    serverId             = {type = Protocol.DataType.string, length = Protocol.MAX_PEER_NAME_LEN},
    cheerNum             = {type = Protocol.DataType.int},
    firstBattleResult    = {type = Protocol.DataType.char},
    -- if the battle doesn't take place, the report id is 0
    firstBattleReportId  = {type = Protocol.DataType.longlong},
    secondBattleResult   = {type = Protocol.DataType.char},
    secondBattleReportId = {type = Protocol.DataType.longlong},
    thirdBattleResult    = {type = Protocol.DataType.char},
    thirdBattleReportId  = {type = Protocol.DataType.longlong},
    forthBattleResult    = {type = Protocol.DataType.char},
    forthBattleReportId  = {type = Protocol.DataType.longlong},
    fifthBattleResult    = {type = Protocol.DataType.char},
    fifthBattleReportId  = {type = Protocol.DataType.longlong},
    fields               = {'roundNumber','accountNameLen','accountName','serverIdLen','serverId','cheerNum','firstBattleResult','firstBattleReportId','secondBattleResult','secondBattleReportId','thirdBattleResult','thirdBattleReportId','forthBattleResult','forthBattleReportId','fifthBattleResult','fifthBattleReportId',}
}

Protocol.Packet_S2C_CompetitionFightHistory = {
    totalRound = {type = Protocol.DataType.char},
    number     = {type = Protocol.DataType.char},
    records    = {type = Protocol.DataType.object, length = -1, clazz = 'Data_FightRecord'},
    fields     = {'totalRound','number','records'}
}
Protocol.structs[Protocol.S_2_C_COMPETITION_FIGHT_HISTORY]  = Protocol.Packet_S2C_CompetitionFightHistory

Protocol.Data_CheerRecord  = {
    roundNumber    = {type = Protocol.DataType.char},
    totalRound     = {type = Protocol.DataType.char},
    accountNameLen = {type = Protocol.DataType.short},
    accountName    = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    serverIdLen    = {type = Protocol.DataType.short},
    serverId       = {type = Protocol.DataType.string, length = Protocol.MAX_PEER_NAME_LEN},
    result         = {type = Protocol.DataType.char},
    fields         = {'roundNumber','totalRound','accountNameLen','accountName','serverIdLen','serverId','result',}
}

Protocol.Packet_S2C_CompetitionCheerHistory = {
    number  = {type = Protocol.DataType.char},
    records = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CheerRecord'},
    fields  = {'number','records'}
}
Protocol.structs[Protocol.S_2_C_COMPETITION_CHEER_HISTORY]  = Protocol.Packet_S2C_CompetitionCheerHistory

Protocol.Packet_S2C_CompetitionCheerHistoryEnd = {
}
Protocol.structs[Protocol.S_2_C_COMPETITION_CHEER_HISTORY_END]  = Protocol.Packet_S2C_CompetitionCheerHistoryEnd

Protocol.Packet_S2C_CompetitionSignupNum = {
    num    = {type = Protocol.DataType.int},
    fields = {'num'}
}
Protocol.structs[Protocol.S_2_C_COMPETITION_SIGNUP_NUM]  = Protocol.Packet_S2C_CompetitionSignupNum

Protocol.Packet_S2C_CompetitionServerTime = {
    timestamp = {type = Protocol.DataType.int},
    fields    = {'timestamp'}
}
Protocol.structs[Protocol.S_2_C_COMPETITION_SERVER_TIME]  = Protocol.Packet_S2C_CompetitionServerTime

Protocol.Packet_S2C_CompetitionConfig = {
    isCheerFree  = {type = Protocol.DataType.char},
    rewardStrLen = {type = Protocol.DataType.short},
    rewardStr    = {type = Protocol.DataType.string, length = Protocol.MAX_REWARD_LEN},
    fields       = {'isCheerFree','rewardStrLen','rewardStr'}
}
Protocol.structs[Protocol.S_2_C_COMPETITION_CONFIG]  = Protocol.Packet_S2C_CompetitionConfig

Protocol.Data_BattleRecord = {
    roundNumber    = {type = Protocol.DataType.char},
    setNumber      = {type = Protocol.DataType.char},
    pass           = {type = Protocol.DataType.string},
    winnerName     = {type = Protocol.DataType.string},
    winnerServerId = {type = Protocol.DataType.string},
    loserName      = {type = Protocol.DataType.string},
    loserServerId  = {type = Protocol.DataType.char},
    reportId       = {type = Protocol.DataType.ulonglong},
    fields         = {'roundNumber','setNumber','pass','winnerName','winnerServerId','loserName','loserServerId','reportId',}
}

Protocol.Packet_S2C_CompetitionBattleRecord = {
    totalRound = {type = Protocol.DataType.char},
    dataLen    = {type = Protocol.DataType.short},
    data       = {type = Protocol.DataType.string, length = Protocol.MAX_SIZE},
    fields     = {'totalRound','dataLen','data'}
}
Protocol.structs[Protocol.S_2_C_COMPETITION_BATTLE_RECORD]  = Protocol.Packet_S2C_CompetitionBattleRecord

Protocol.Packet_S2C_CompetitionBattleRecordEnd = {
}
Protocol.structs[Protocol.S_2_C_COMPETITION_BATTLE_RECORD_END]  = Protocol.Packet_S2C_CompetitionBattleRecordEnd