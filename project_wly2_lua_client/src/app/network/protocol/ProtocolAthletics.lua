local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_ENTER_ATHLETICS                  = Protocol.C_2_S_ATHLETICS_BASE + 0
Protocol.C_2_S_LOAD_ATHLETICS_RANK              = Protocol.C_2_S_ATHLETICS_BASE + 1
Protocol.C_2_S_ATHLETICS_CHANGE_PLAYER          = Protocol.C_2_S_ATHLETICS_BASE + 2
Protocol.C_2_S_ATHLETICS_CHALLENGE_PLAYER       = Protocol.C_2_S_ATHLETICS_BASE + 3
Protocol.C_2_S_ATHLETICS_BUY_TIMES              = Protocol.C_2_S_ATHLETICS_BASE + 4
Protocol.C_2_S_ATHLETICS_COOL_DOWN              = Protocol.C_2_S_ATHLETICS_BASE + 5
Protocol.C_2_S_ATHLETICS_SAVE                   = Protocol.C_2_S_ATHLETICS_BASE + 6
Protocol.C_2_S_ATHLETICS_DRAW_REWARD            = Protocol.C_2_S_ATHLETICS_BASE + 7
Protocol.C_2_S_ATHLETICS_STORE_INFO_LOAD        = Protocol.C_2_S_ATHLETICS_BASE + 8
Protocol.C_2_S_ATHLETICS_EXCHANGE_ITEM          = Protocol.C_2_S_ATHLETICS_BASE + 10
Protocol.C_2_S_ATHLETICS_DRAW_RANK_REWARD       = Protocol.C_2_S_ATHLETICS_BASE + 11
Protocol.C_2_S_ATHLETICS_REFRESH_STORE          = Protocol.C_2_S_ATHLETICS_BASE + 13
Protocol.C_2_S_ATHLETICS_LOAD_LOG               = Protocol.C_2_S_ATHLETICS_BASE + 15
Protocol.C_2_S_ATHLETICS_LOAD_TOP_LOG           = Protocol.C_2_S_ATHLETICS_BASE + 17
Protocol.C_2_S_ATHLETICS_VIEW_FORMATION         = Protocol.C_2_S_ATHLETICS_BASE + 18
Protocol.C_2_S_ATHLETICS_SWEEP                  = Protocol.C_2_S_ATHLETICS_BASE + 19

Protocol.S_2_C_ENTER_ATHLETICS                  = Protocol.S_2_C_ATHLETICS_BASE + 0
Protocol.S_2_C_LOAD_ATHLETIC_RANK               = Protocol.S_2_C_ATHLETICS_BASE + 1
Protocol.S_2_C_ATHLETICS_CHANGE_PLAYER          = Protocol.S_2_C_ATHLETICS_BASE + 2
Protocol.S_2_C_ATHLETICS_CHALLENGE_PLAYER       = Protocol.S_2_C_ATHLETICS_BASE + 3
Protocol.S_2_C_ATHLETICS_BUY_TIMES              = Protocol.S_2_C_ATHLETICS_BASE + 4
Protocol.S_2_C_ATHLETICS_COOL_DOWN              = Protocol.S_2_C_ATHLETICS_BASE + 5
Protocol.S_2_C_ATHLETICS_BATTLE_DATA            = Protocol.S_2_C_ATHLETICS_BASE + 6
Protocol.S_2_C_ATHLETICS_SAVE                   = Protocol.S_2_C_ATHLETICS_BASE + 7
Protocol.S_2_C_ATHLETICS_DRAW_REWARD            = Protocol.S_2_C_ATHLETICS_BASE + 8
Protocol.S_2_C_ATHLETICS_STORE_INFO_LOAD        = Protocol.S_2_C_ATHLETICS_BASE + 9
Protocol.S_2_C_ATHLETICS_EXCHANGE_ITEM          = Protocol.S_2_C_ATHLETICS_BASE + 10
Protocol.S_2_C_ATHLETICS_DRAW_RANK_REWARD       = Protocol.S_2_C_ATHLETICS_BASE + 11
Protocol.S_2_C_ATHLETICS_UPDATE_REWARD_INTEGRAL = Protocol.S_2_C_ATHLETICS_BASE + 12
Protocol.S_2_C_ATHLETICS_REFRESH_STORE          = Protocol.S_2_C_ATHLETICS_BASE + 13
Protocol.S_2_C_ATHLETICS_RANK_BEGIN             = Protocol.S_2_C_ATHLETICS_BASE + 14
Protocol.S_2_C_ATHLETICS_RANK                   = Protocol.S_2_C_ATHLETICS_BASE + 16
Protocol.S_2_C_ATHLETICS_RANK_END               = Protocol.S_2_C_ATHLETICS_BASE + 18
Protocol.S_2_C_ATHLETICS_SWEEP                  = Protocol.S_2_C_ATHLETICS_BASE + 19
Protocol.S_2_C_ATHLETICS_LOAD_LOG               = Protocol.S_2_C_ATHLETICS_BASE + 20
Protocol.S_2_C_ATHLETICS_LOAD_TOP_LOG           = Protocol.S_2_C_ATHLETICS_BASE + 22
Protocol.S_2_C_ATHLETICS_VIEW_FORMATION         = Protocol.S_2_C_ATHLETICS_BASE + 23

Protocol.MAX_CHALLENGE_LEN                      = 14
Protocol.MAX_FORMATION_GENERAL_LEN              = 5
Protocol.MAX_REWARD_NUM                         = 7

Protocol.Packet_C2S_AthleticsChallengePlayer = {
    --C_2_S_ATHLETICS_CHALLENGE_PLAYER
    is_five  = {type = Protocol.DataType.short}, --0 none
    rank_pos = {type = Protocol.DataType.short},
    fields   = {'is_five', 'rank_pos'}
}
Protocol.structs[Protocol.C_2_S_ATHLETICS_CHALLENGE_PLAYER]  = Protocol.Packet_C2S_AthleticsChallengePlayer

Protocol.Data_General = {
    index      = {type = Protocol.DataType.short},
    general_id = {type = Protocol.DataType.int},
    fields     = {'index', 'general_id'}
}

Protocol.Packet_C2S_AthleticsSave = {
    --C_2_S_ATHLETICS_SAVE
    formation_id = {type = Protocol.DataType.int}, --if no fight general, there is 0
    count        = {type = Protocol.DataType.short},
    generals     = {type = Protocol.DataType.object, length = -1, clazz = 'Data_GeneralLoc'},
    fields       = {'formation_id', 'count', 'generals'}
}
Protocol.structs[Protocol.C_2_S_ATHLETICS_SAVE]  = Protocol.Packet_C2S_AthleticsSave

Protocol.Packet_C2S_AthleticsExchangeItem = {
    --C_2_S_ATHLETICS_EXCHANGE_ITEM
    id     = {type = Protocol.DataType.int},
    num    = {type = Protocol.DataType.short},
    fields = {'id', 'num'}
}
Protocol.structs[Protocol.C_2_S_ATHLETICS_EXCHANGE_ITEM]  = Protocol.Packet_C2S_AthleticsExchangeItem

Protocol.Packet_C2S_AthleticsSweepPlayer = {
    rank      = {type = Protocol.DataType.short},
    fields    = {'rank'}
}
Protocol.structs[Protocol.C_2_S_ATHLETICS_SWEEP] = Protocol.Packet_C2S_AthleticsSweepPlayer

Protocol.Packet_C2S_AthleticsDrawReward = {
    clear_time   = {type = Protocol.DataType.int},
    fields       = {'clear_time'}
}
Protocol.structs[Protocol.C_2_S_ATHLETICS_DRAW_REWARD] = Protocol.Packet_C2S_AthleticsDrawReward

Protocol.Data_AthleticsRankItem = {
    id            = {type = Protocol.DataType.longlong},
    type          = {type = Protocol.DataType.short},
    power         = {type = Protocol.DataType.int},
    rank          = {type = Protocol.DataType.int},
    img_type      = {type = Protocol.DataType.short},
    img_id        = {type = Protocol.DataType.int},
    country       = {type = Protocol.DataType.char},
    level         = {type = Protocol.DataType.short},
    name_len      = {type = Protocol.DataType.short},
    name          = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    crop_name_len = {type = Protocol.DataType.short},
    crop_name     = {type = Protocol.DataType.string, length = Protocol.MAX_CROP_NAME_LEN},
    crop_icon     = {type = Protocol.DataType.short},
    fields        = {'id','type','power','rank','img_type','img_id','country','level','name_len'
                    ,'name','crop_name_len','crop_name','crop_icon'}
}

Protocol.Data_AthleticsReward = {
    rank          = {type = Protocol.DataType.short},
    score         = {type = Protocol.DataType.int},
    state         = {type = Protocol.DataType.short},
    clear_time    = {type = Protocol.DataType.int},
    fields        = {'rank', 'score', 'state', 'clear_time'}
}

Protocol.Data_GeneralLoc = {
    index         = {type = Protocol.DataType.short},
    general_id    = {type = Protocol.DataType.int},
    fields        = {'index', 'general_id'}
}

Protocol.Data_AthleticsRankDetailItem = {
    id            = {type = Protocol.DataType.longlong},
    type          = {type = Protocol.DataType.short},
    power         = {type = Protocol.DataType.int},
    rank          = {type = Protocol.DataType.int},
    img_type      = {type = Protocol.DataType.short},
    img_id        = {type = Protocol.DataType.int},
    country       = {type = Protocol.DataType.char},
    level         = {type = Protocol.DataType.short},
    name_len      = {type = Protocol.DataType.short},
    name          = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    count         = {type = Protocol.DataType.short},
    generals      = {type = Protocol.DataType.object, length = -1, clazz = 'Data_Formation'},
    fields        = {'id', 'type', 'power', 'rank', 'img_type', 'img_id', 'country', 'level' , 'name_len','name', 'count', 'generals'}
}

-----------------------------C2S-----------------------------

Protocol.Packet_C2S_AthleticsDrawRankReward = {
    --C_2_S_ATHLETICS_DRAW_RANK_REWARD
    id     = {type = Protocol.DataType.int},
    num    = {type = Protocol.DataType.short},
    fields = {'id', 'num'}
}
Protocol.structs[Protocol.C_2_S_ATHLETICS_DRAW_RANK_REWARD]  = Protocol.Packet_C2S_AthleticsDrawRankReward

-- 查看玩家阵容
Protocol.Packet_C2S_AthleticsViewFormation = {
    --C_2_S_ATHLETICS_VIEW_FORMATION
    pos    = {type = Protocol.DataType.short},
    fields = {'pos'}
}
Protocol.structs[Protocol.C_2_S_ATHLETICS_VIEW_FORMATION]  = Protocol.Packet_C2S_AthleticsViewFormation

-----------------------------S2C-----------------------------

Protocol.Packet_S2C_LoadAthleticsInfo = {
    buy_times           = {type = Protocol.DataType.short},
    challenge_times     = {type = Protocol.DataType.short},
    refresh_num         = {type = Protocol.DataType.short},
    rank                = {type = Protocol.DataType.int},
    last_rank           = {type = Protocol.DataType.int},
    best_rank           = {type = Protocol.DataType.int},
    cd_time             = {type = Protocol.DataType.int},
    reward_integral     = {type = Protocol.DataType.int},
    cur_reward_integral = {type = Protocol.DataType.int},
    count               = {type = Protocol.DataType.short},
    challengers         = {type = Protocol.DataType.object, length = -1, clazz = 'Data_AthleticsRankItem'},
    formation_id        = {type = Protocol.DataType.int},
    general_num         = {type = Protocol.DataType.short},
    general_loc         = {type = Protocol.DataType.object, length = -1, clazz='Data_GeneralLoc'},
    reward_num          = {type = Protocol.DataType.short},
    rewards             = {type = Protocol.DataType.object, length = -1, clazz='Data_AthleticsReward'},
    fields              = {'buy_times','challenge_times','refresh_num','rank','last_rank','best_rank',
                            'cd_time','reward_integral','cur_reward_integral','count','challengers',
                            'formation_id','general_num','general_loc','reward_num','rewards'}
}
Protocol.structs[Protocol.S_2_C_ENTER_ATHLETICS]  = Protocol.Packet_S2C_LoadAthleticsInfo

Protocol.Packet_S2C_AthleticsChangePlayer = {
    count       = {type = Protocol.DataType.short},
    challengers = {type = Protocol.DataType.object, length = -1, clazz = 'Data_AthleticsRankItem'},
    rank        = {type = Protocol.DataType.short},
    fields      = {'count','challengers','rank'}
}
Protocol.structs[Protocol.S_2_C_ATHLETICS_CHANGE_PLAYER]  = Protocol.Packet_S2C_AthleticsChangePlayer

Protocol.Packet_S2C_AthleticsChallengePlayer = {
    ret             = {type = Protocol.DataType.short}, --0 ok, 1 busy
    battle_ret      = {type = Protocol.DataType.short},
    report_id       = {type = Protocol.DataType.llstring},
    challenge_times = {type = Protocol.DataType.short},
    new_rank        = {type = Protocol.DataType.int},
    cd_time         = {type = Protocol.DataType.int},
    is_five         = {type = Protocol.DataType.short},
    add_integral    = {type = Protocol.DataType.int},
    count           = {type = Protocol.DataType.short},
    rewards         = {type = Protocol.DataType.object, length = -1, clazz = 'Packet_Data_RewardType'},
    fields          = {'ret','battle_ret','report_id','challenge_times','new_rank','cd_time','is_five','add_integral','count','rewards'}
}
Protocol.structs[Protocol.S_2_C_ATHLETICS_CHALLENGE_PLAYER]  = Protocol.Packet_S2C_AthleticsChallengePlayer

Protocol.Packet_S2C_AthleticsBuyTimes = {
    buy_times       = {type = Protocol.DataType.short},
    challenge_times = {type = Protocol.DataType.short},
    fields          = {'buy_times','challenge_times'}
}
Protocol.structs[Protocol.S_2_C_ATHLETICS_BUY_TIMES]  = Protocol.Packet_S2C_AthleticsBuyTimes

Protocol.Packet_S2C_AthleticsCoolDown = {
    cdTime = {type = Protocol.DataType.int},
    fields = {'cdTime'}
}
Protocol.structs[Protocol.S_2_C_ATHLETICS_COOL_DOWN]  = Protocol.Packet_S2C_AthleticsCoolDown

Protocol.Packet_S2C_AthleticsBattleData = {
    selfRank = {type = Protocol.DataType.int},
    fields   = {'selfRank'}
}
Protocol.structs[Protocol.S_2_C_ATHLETICS_BATTLE_DATA]  = Protocol.Packet_S2C_AthleticsBattleData

Protocol.Packet_S2C_AthleticsSave = {
    ret    = {type = Protocol.DataType.short},
    fields = {'ret'}
}
Protocol.structs[Protocol.S_2_C_ATHLETICS_SAVE]  = Protocol.Packet_S2C_AthleticsSave

Protocol.Packet_S2C_AthleticsDrawReward = {
    clear_time  = {type = Protocol.DataType.int},
    fields      = {'clear_time'}
}
Protocol.structs[Protocol.S_2_C_ATHLETICS_DRAW_REWARD]  = Protocol.Packet_S2C_AthleticsDrawReward

Protocol.Data_Item = {
    id       = {type = Protocol.DataType.int},
    num      = {type = Protocol.DataType.short},
    discount = {type = Protocol.DataType.double},
    fields   = {'id','num','discount'}
}

Protocol.Data_Reward = {
    id       = {type = Protocol.DataType.int},
    num      = {type = Protocol.DataType.short},
    discount = {type = Protocol.DataType.double},
    fields   = {'id','num','discount'}
}

Protocol.Packet_S2C_AthleticsStoreInfoLoad = {
    count           = {type = Protocol.DataType.short},
    items           = {type = Protocol.DataType.object, length = -1, clazz = 'Data_Item'},
    count1          = {type = Protocol.DataType.short},
    rank_rwds       = {type = Protocol.DataType.object, length = -1, clazz = 'Data_Reward'},
    refresh_num     = {type = Protocol.DataType.short},
    refresh_buy_num = {type = Protocol.DataType.short},
    fields          = {'count','items','count1','rank_rwds','refresh_num','refresh_buy_num'}
}
Protocol.structs[Protocol.S_2_C_ATHLETICS_STORE_INFO_LOAD]  = Protocol.Packet_S2C_AthleticsStoreInfoLoad

Protocol.Packet_S2C_AthleticsExchangeItem = {
    id     = {type = Protocol.DataType.int},
    num    = {type = Protocol.DataType.short},
    fields = {'id','num'}
}
Protocol.structs[Protocol.S_2_C_ATHLETICS_EXCHANGE_ITEM]  = Protocol.Packet_S2C_AthleticsExchangeItem

Protocol.Packet_S2C_AthleticsDrawRankReward = {
    id     = {type = Protocol.DataType.int},
    num    = {type = Protocol.DataType.short},
    fields = {'id','num'}
}
Protocol.structs[Protocol.S_2_C_ATHLETICS_DRAW_RANK_REWARD]  = Protocol.Packet_S2C_AthleticsDrawRankReward

Protocol.Packet_S2C_AthleticsUpdateRewardIntegral = {
    rank         = {type = Protocol.DataType.short},
    add_integral = {type = Protocol.DataType.int},
    fields       = {'rank', 'add_integral'}
}
Protocol.structs[Protocol.S_2_C_ATHLETICS_UPDATE_REWARD_INTEGRAL] = Protocol.Packet_S2C_AthleticsUpdateRewardIntegral

Protocol.Packet_S2C_AthleticsRefreshStore = {
    ret    = {type = Protocol.DataType.short},
    fields = {'ret'}
}
Protocol.structs[Protocol.S_2_C_ATHLETICS_REFRESH_STORE]  = Protocol.Packet_S2C_AthleticsRefreshStore

Protocol.Packet_S2C_LoadThleticsRankBegin = {
    fields = {}
}
Protocol.structs[Protocol.S_2_C_ATHLETICS_RANK_BEGIN]  = Protocol.Packet_S2C_LoadThleticsRankBegin

Protocol.Packet_S2C_LoadAthleticsRank = {
    count  = {type = Protocol.DataType.short},
    items  = {type = Protocol.DataType.object, length = -1, clazz = 'Data_AthleticsRankDetailItem'},
    owner  = {type = Protocol.DataType.object, clazz = 'Data_AthleticsRankDetailItem'},
    fields = {'count', 'items', 'owner'}
}
Protocol.structs[Protocol.S_2_C_ATHLETICS_RANK]  = Protocol.Packet_S2C_LoadAthleticsRank

Protocol.Packet_S2C_LoadThleticsRankEnd = {
    --ret    = {type = Protocol.DataType.short},
    fields = {}
}
Protocol.structs[Protocol.S_2_C_ATHLETICS_RANK_END]  = Protocol.Packet_S2C_LoadThleticsRankEnd

Protocol.Data_Log = {
    type       = {type = Protocol.DataType.short},
    role_id    = {type = Protocol.DataType.longlong},
    len        = {type = Protocol.DataType.short},
    name       = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    time       = {type = Protocol.DataType.int},
    battle_ret = {type = Protocol.DataType.short},
    report_id  = {type = Protocol.DataType.llstring},
    rank_diff  = {type = Protocol.DataType.short},
    country_id = {type = Protocol.DataType.short},
    power      = {type = Protocol.DataType.int},
    rank       = {type = Protocol.DataType.int},
    fields     = {'type','role_id','len','name','time','battle_ret','report_id','rank_diff','country_id','power','rank'}
}

Protocol.Packet_S2C_AthleticsLoadLog = {
    count  = {type = Protocol.DataType.short},
    logs   = {type = Protocol.DataType.object, length = -1, clazz = 'Data_Log'},
    fields = {'count', 'logs'}
}
Protocol.structs[Protocol.S_2_C_ATHLETICS_LOAD_LOG]  = Protocol.Packet_S2C_AthleticsLoadLog

Protocol.Data_TopLog = {
    atk_id       = {type = Protocol.DataType.longlong},
    atk_img_type = {type = Protocol.DataType.short},
    atk_img_id   = {type = Protocol.DataType.int},
    atk_len      = {type = Protocol.DataType.short},
    atk_name     = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    atk_lvl      = {type = Protocol.DataType.short},
    atk_power    = {type = Protocol.DataType.int},
    atk_country  = {type = Protocol.DataType.short},
    atk_rank     = {type = Protocol.DataType.int},
    def_id       = {type = Protocol.DataType.longlong},
    def_img_type = {type = Protocol.DataType.short},
    def_img_id   = {type = Protocol.DataType.int},
    def_len      = {type = Protocol.DataType.short},
    def_name     = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    def_lvl      = {type = Protocol.DataType.short},
    def_power    = {type = Protocol.DataType.int},
    def_country  = {type = Protocol.DataType.short},
    def_rank     = {type = Protocol.DataType.int},
    time         = {type = Protocol.DataType.int},
    battle_ret   = {type = Protocol.DataType.short},
    report_id    = {type = Protocol.DataType.llstring},
    fields       = {'atk_id','atk_img_type','atk_img_id','atk_len','atk_name','atk_lvl','atk_power','atk_country',
                    'atk_rank','def_id','def_img_type','def_img_id','def_len','def_name','def_lvl','def_power',
                    'def_country','def_rank','time','battle_ret','report_id'}
}

Protocol.Packet_S2C_AthleticsLoadTopLog = {
    count  = {type = Protocol.DataType.short},
    logs   = {type = Protocol.DataType.object, length = -1, clazz = 'Data_TopLog'},
    fields = {'count', 'logs'}
}
Protocol.structs[Protocol.S_2_C_ATHLETICS_LOAD_TOP_LOG]  = Protocol.Packet_S2C_AthleticsLoadTopLog

Protocol.Packet_S2C_AthleticsSweepPlayer = {
    rank                = {type = Protocol.DataType.short},
    challenge_times     = {type = Protocol.DataType.short},
    add_integral        = {type = Protocol.DataType.int},
    count               = {type = Protocol.DataType.short},
    rewards             = {type = Protocol.DataType.object, lenght = -1, clazz = 'Packet_Data_RewardType'},
    fields              = {'rank', 'challenge_times', 'add_integral', 'count', 'rewards'}
}
Protocol.structs[Protocol.S_2_C_ATHLETICS_SWEEP]       = Protocol.Packet_S2C_AthleticsSweepPlayer

Protocol.Data_Formation = {
    index           = {type = Protocol.DataType.short},
    general_id      = {type = Protocol.DataType.int},
    soldier_id      = {type = Protocol.DataType.int},
    rtemp_id        = {type = Protocol.DataType.int},
    level           = {type = Protocol.DataType.int},
    grade           = {type = Protocol.DataType.short},
    name_len        = {type = Protocol.DataType.short},
    name            = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    skill_id        = {type = Protocol.DataType.int},
    cur_soldier_num = {type = Protocol.DataType.int},
    max_soldier_num = {type = Protocol.DataType.int},
    fields          = {'index', 'general_id', 'soldier_id', 'rtemp_id', 'level', 'grade', 'name_len', 'name',
                       'skill_id', 'cur_soldier_num', 'max_soldier_num'}
}
-- 查看玩家阵容
Protocol.Packet_S2C_AthleticsViewFormation = {
    -- S_2_C_ATHLETICS_VIEW_FORMATION
    pos             = {type = Protocol.DataType.short},
    formation_id    = {type = Protocol.DataType.int},
    count           = {type = Protocol.DataType.short},
    generals        = {type = Protocol.DataType.object, length = -1, clazz = 'Data_Formation'},
    crop_name_len   = {type = Protocol.DataType.short},
    crop_name       = {type = Protocol.DataType.string, length = Protocol.MAX_CROP_NAME_LEN},
    fields          = {'pos', 'formation_id', 'count', 'generals','crop_name_len','crop_name'}
}
Protocol.structs[Protocol.S_2_C_ATHLETICS_VIEW_FORMATION]  = Protocol.Packet_S2C_AthleticsViewFormation
