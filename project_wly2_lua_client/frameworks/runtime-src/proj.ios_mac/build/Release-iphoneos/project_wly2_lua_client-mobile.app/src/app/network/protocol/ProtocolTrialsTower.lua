local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_TRIAL_TOWER_LOAD_INFO                        = Protocol.C_2_S_TRIALS_TOWER_BASE + 0
Protocol.C_2_S_TRIAL_TOWER_ATTACK_NPC                       = Protocol.C_2_S_TRIALS_TOWER_BASE + 2
Protocol.C_2_S_TRIAL_TOWER_RESET                            = Protocol.C_2_S_TRIALS_TOWER_BASE + 4
Protocol.C_2_S_TRIAL_TOWER_SWEEP                            = Protocol.C_2_S_TRIALS_TOWER_BASE + 5
Protocol.C_2_S_TRIAL_TOWER_DRAW_REWARD_BOX                  = Protocol.C_2_S_TRIALS_TOWER_BASE + 7
Protocol.C_2_S_TRIAL_TOWER_INSPIRE                          = Protocol.C_2_S_TRIALS_TOWER_BASE + 9
Protocol.C_2_S_TRIAL_TOWER_STORE_LOAD                       = Protocol.C_2_S_TRIALS_TOWER_BASE + 11
Protocol.C_2_S_TRIAL_TOWER_STORE_BUY                        = Protocol.C_2_S_TRIALS_TOWER_BASE + 13
Protocol.C_2_S_TRIAL_TOWER_STORE_REFRESH                    = Protocol.C_2_S_TRIALS_TOWER_BASE + 15
Protocol.C_2_S_TRIAL_TOWER_DRAW_REWARD                      = Protocol.C_2_S_TRIALS_TOWER_BASE + 17
Protocol.C_2_S_TRIAL_TOWER_NPC_GUIDE                        = Protocol.C_2_S_TRIALS_TOWER_BASE + 19
Protocol.C_2_S_TRIAL_TOWER_MY_REPORT                        = Protocol.C_2_S_TRIALS_TOWER_BASE + 21
Protocol.C_2_S_TRIAL_TOWER_RANK_LOAD                        = Protocol.C_2_S_TRIALS_TOWER_BASE + 22
Protocol.C_2_S_TRIAL_TOWER_LOG_LOAD                         = Protocol.C_2_S_TRIALS_TOWER_BASE + 23



Protocol.S_2_C_TRIAL_TOWER_LOAD_INFO                        = Protocol.S_2_C_TRIALS_TOWER_BASE + 0
Protocol.S_2_C_TRIAL_TOWER_ATTACK_NPC                       = Protocol.S_2_C_TRIALS_TOWER_BASE + 1
Protocol.S_2_C_TRIAL_TOWER_RESET                            = Protocol.S_2_C_TRIALS_TOWER_BASE + 3
Protocol.S_2_C_TRIAL_TOWER_SWEEP                            = Protocol.S_2_C_TRIALS_TOWER_BASE + 4
Protocol.S_2_C_TRIAL_TOWER_DRAW_REWARD_BOX                  = Protocol.S_2_C_TRIALS_TOWER_BASE + 5
Protocol.S_2_C_TRIAL_TOWER_INSPIRE                          = Protocol.S_2_C_TRIALS_TOWER_BASE + 10
Protocol.S_2_C_TRIAL_TOWER_STORE_LOAD                       = Protocol.S_2_C_TRIALS_TOWER_BASE + 12
Protocol.S_2_C_TRIAL_TOWER_STORE_BUY                        = Protocol.S_2_C_TRIALS_TOWER_BASE + 14
Protocol.S_2_C_TRIAL_TOWER_STORE_REFRESH                    = Protocol.S_2_C_TRIALS_TOWER_BASE + 16
Protocol.S_2_C_TRIAL_TOWER_DRAW_REWARD                      = Protocol.S_2_C_TRIALS_TOWER_BASE + 18
Protocol.S_2_C_TRIAL_TOWER_NPC_GUIDE                        = Protocol.S_2_C_TRIALS_TOWER_BASE + 20
Protocol.S_2_C_TRIAL_TOWER_MY_REPORT                        = Protocol.S_2_C_TRIALS_TOWER_BASE + 22
Protocol.S_2_C_TRIAL_TOWER_RANK_LOAD                        = Protocol.S_2_C_TRIALS_TOWER_BASE + 24
Protocol.S_2_S_TRIAL_TOWER_LOG_LOAD                         = Protocol.S_2_C_TRIALS_TOWER_BASE + 26



------------------------------C_2_S------------------------------
Protocol.Packet_C2S_TrialTowerStoreBuy = {
    id                      = {type = Protocol.DataType.int},
    num                     = {type = Protocol.DataType.short},
    fields                  = {'id', 'num'}
}
Protocol.structs[Protocol.C_2_S_TRIAL_TOWER_STORE_BUY]               = Protocol.Packet_C2S_TrialTowerStoreBuy

Protocol.Packet_C2S_TrialTowerNpcGuide = {
    layer_id                = {type = Protocol.DataType.int},
    npc_id                  = {type = Protocol.DataType.int},
    country_id              = {type = Protocol.DataType.short},
    fields                  = {'layer_id','npc_id','country_id'}
}
Protocol.structs[Protocol.C_2_S_TRIAL_TOWER_NPC_GUIDE]                      = Protocol.Packet_C2S_TrialTowerNpcGuide

Protocol.Packet_C2S_TrialTowerDrawReward = {
    id                      = {type = Protocol.DataType.int},
    num                     = {type = Protocol.DataType.short},
    fields                  = {'id', 'num'}
}
Protocol.structs[Protocol.C_2_S_TRIAL_TOWER_DRAW_REWARD]                      = Protocol.Packet_C2S_TrialTowerDrawReward


------------------------------S_2_C------------------------------
Protocol.Packet_S2C_TrialTowerLoadInfo = {
    cur_layer_id                = {type = Protocol.DataType.int},
    cur_npc_id                  = {type = Protocol.DataType.int},
    max_layer_id                = {type = Protocol.DataType.int},
    max_npc_id                  = {type = Protocol.DataType.int},
    reward_box_layer            = {type = Protocol.DataType.int},
    reset_num                   = {type = Protocol.DataType.short},
    atk_lvl                     = {type = Protocol.DataType.short},
    def_lvl                     = {type = Protocol.DataType.short},
    fields                      = {'cur_layer_id','cur_npc_id','max_layer_id','max_npc_id','reward_box_layer','reset_num','atk_lvl','def_lvl'}
}
Protocol.structs[Protocol.S_2_C_TRIAL_TOWER_LOAD_INFO]                 = Protocol.Packet_S2C_TrialTowerLoadInfo

Protocol.Packet_S2C_TrialTowerAttackNpc = {
    battle_ret                  = {type = Protocol.DataType.short},
    report_id                   = {type = Protocol.DataType.llstring},
    layer_id                    = {type = Protocol.DataType.int},
    npc_id                      = {type = Protocol.DataType.int},
    pass_layer                  = {type = Protocol.DataType.short},
    count                       = {type = Protocol.DataType.short},
    reward                      = {type = Protocol.DataType.object, length = -1, clazz='Packet_Data_RewardType'},
    fields                      = {'battle_ret','report_id','layer_id','npc_id','pass_layer','count','reward'}
}
Protocol.structs[Protocol.S_2_C_TRIAL_TOWER_ATTACK_NPC]                 = Protocol.Packet_S2C_TrialTowerAttackNpc

Protocol.Packet_S2C_TrialTowerReset = {
    ret                         = {type = Protocol.DataType.short},
    fields                      = {'ret'}
}
Protocol.structs[Protocol.S_2_C_TRIAL_TOWER_RESET]                 = Protocol.Packet_S2C_TrialTowerReset

Protocol.Packet_S2C_TrialTowerSweep = {
    cur_layer_id                = {type = Protocol.DataType.int},
    cur_npc_id                  = {type = Protocol.DataType.int},
    count                       = {type = Protocol.DataType.short},
    rwds                        = {type = Protocol.DataType.object, length = -1, clazz='Packet_Data_RewardType'},
    fields                      = {'cur_layer_id','cur_npc_id','count','rwds'}
}
Protocol.structs[Protocol.S_2_C_TRIAL_TOWER_SWEEP]                 = Protocol.Packet_S2C_TrialTowerSweep

Protocol.Packet_S2C_TrialTowerDrawRewardBox = {
    reward_layer_id             = {type = Protocol.DataType.int},
    fields                      = {'reward_layer_id'}
}
Protocol.structs[Protocol.S_2_C_TRIAL_TOWER_DRAW_REWARD_BOX]                 = Protocol.Packet_S2C_TrialTowerDrawRewardBox

Protocol.Packet_S2C_TrialTowerInspire = {
    ret                         = {type = Protocol.DataType.short},
    is_atk                      = {type = Protocol.DataType.short},
    atk_lvl                     = {type = Protocol.DataType.short},
    def_lvl                     = {type = Protocol.DataType.short},
    fields                      = {'ret','is_atk','atk_lvl','def_lvl'}
}
Protocol.structs[Protocol.S_2_C_TRIAL_TOWER_INSPIRE]                 = Protocol.Packet_S2C_TrialTowerInspire

Protocol.Packet_S2C_TrialTowerStoreBuy = {
    id                          = {type = Protocol.DataType.int},
    num                         = {type = Protocol.DataType.short},
    fields                      = {'id','num'}
}
Protocol.structs[Protocol.S_2_C_TRIAL_TOWER_STORE_BUY]                 = Protocol.Packet_S2C_TrialTowerStoreBuy

Protocol.Packet_S2C_TrialTowerRefresh = {
    ret                         = {type = Protocol.DataType.short},
    fields                      = {'ret'}
}
Protocol.structs[Protocol.S_2_C_TRIAL_TOWER_STORE_REFRESH]                 = Protocol.Packet_S2C_TrialTowerRefresh

Protocol.Packet_S2C_TrialTowerDrawReward = {
    id                          = {type = Protocol.DataType.int},
    num                         = {type = Protocol.DataType.short},
    fields                      = {'id','num'}
}
Protocol.structs[Protocol.S_2_C_TRIAL_TOWER_DRAW_REWARD]                              = Protocol.Packet_S2C_TrialTowerDrawReward

Protocol.Packet_Data_TrialTowerGuide = {
    name_len                    = {type = Protocol.DataType.short},
    name                        = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    lvl                         = {type = Protocol.DataType.short},
    report_id                   = {type = Protocol.DataType.llstring},
    fields                      = {'name_len', 'name', 'lvl', 'report_id'}
}

Protocol.Packet_S2C_TrialTowerNpcGuide = {
    layer_id                    = {type = Protocol.DataType.int},
    npc_id                      = {type = Protocol.DataType.int},
    country_id                  = {type = Protocol.DataType.short},
    count                       = {type = Protocol.DataType.short},
    guides                      = {type = Protocol.DataType.object, length = -1, clazz='Packet_Data_TrialTowerGuide'},
    fields                      = {'layer_id','npc_id','country_id','count','guides'}
}
Protocol.structs[Protocol.S_2_C_TRIAL_TOWER_NPC_GUIDE]                        = Protocol.Packet_S2C_TrialTowerNpcGuide

Protocol.Packet_Data_TradeInfo = {
    id                      = {type = Protocol.DataType.int},
    num                     = {type = Protocol.DataType.short},
    discount                = {type = Protocol.DataType.double},
    fields                  = {'id','num','discount'}
}

Protocol.Packet_S2C_TrialTowerStoreLoad = {
    count           = {type = Protocol.DataType.short},
    items           = {type = Protocol.DataType.object, length = -1, clazz='Packet_Data_TradeInfo'},
    count1          = {type = Protocol.DataType.short},
    rank_rwds       = {type = Protocol.DataType.object, length = -1, clazz='Packet_Data_TradeInfo'},
    refresh_num     = {type = Protocol.DataType.short},
    refresh_buy_num = {type = Protocol.DataType.short},
    fields      = {'count','items','count1','rank_rwds','refresh_num','refresh_buy_num'}
}
Protocol.structs[Protocol.S_2_C_TRIAL_TOWER_STORE_LOAD]                 = Protocol.Packet_S2C_TrialTowerStoreLoad

Protocol.Packet_Data_TrialTowerReport = {
    layer_id                    = {type = Protocol.DataType.int},
    npc_id                      = {type = Protocol.DataType.int},
    battle_ret                  = {type = Protocol.DataType.short},
    report_id                   = {type = Protocol.DataType.llstring},
    fields                      = {'layer_id', 'npc_id', 'battle_ret', 'report_id'}
}

Protocol.Packet_S2C_TrialTowerMyReport = {
    count                       = {type = Protocol.DataType.short},
    guides                      = {type = Protocol.DataType.object, length = -1, clazz='Packet_Data_TrialTowerReport'},
    fields                      = {'count','guides'}
}
Protocol.structs[Protocol.S_2_C_TRIAL_TOWER_MY_REPORT]                        = Protocol.Packet_S2C_TrialTowerMyReport

Protocol.Data_TowersRankInfo = {
    role_id         = {type = Protocol.DataType.longlong},
    rank            = {type = Protocol.DataType.short},
    country_id      = {type = Protocol.DataType.short},
    power           = {type = Protocol.DataType.int},
    layer           = {type = Protocol.DataType.int},
    len1            = {type = Protocol.DataType.short},
    player_name     = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    general_str_len = {type = Protocol.DataType.short},
    general_str     = {type = Protocol.DataType.string, length = Protocol.MAX_GENERAL_STR_NUM},
    fields          = {'role_id','rank','country_id','power','layer','len1','player_name','general_str_len','general_str'}
}

Protocol.Packet_S2C_TrialTowerRankLoad = {
    my_rank                   = {type = Protocol.DataType.short},
    my_value                  = {type = Protocol.DataType.int},
    count                     = {type = Protocol.DataType.short},
    ranks                     = {type = Protocol.DataType.object, length = -1, clazz='Data_TowersRankInfo'},
    fields                    = {'my_rank','my_value','count','ranks'}
}
Protocol.structs[Protocol.S_2_C_TRIAL_TOWER_RANK_LOAD]                   = Protocol.Packet_S2C_TrialTowerRankLoad

Protocol.Packet_C2S_TrialTowerLogLoad = {
    npc_id          = {type = Protocol.DataType.int},
    fields          = {'npc_id'}
}
Protocol.structs[Protocol.C_2_S_TRIAL_TOWER_LOG_LOAD]  = Protocol.Packet_C2S_TrialTowerLogLoad

Protocol.Data_TowersLogInfo = {
    type            = {type = Protocol.DataType.short},
    country_id      = {type = Protocol.DataType.short},
    force_value     = {type = Protocol.DataType.int},
    report_id       = {type = Protocol.DataType.llstring},
    len1            = {type = Protocol.DataType.short},
    role_name       = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    general_str_len = {type = Protocol.DataType.short},
    general_str     = {type = Protocol.DataType.string, length = Protocol.MAX_GENERAL_STR_NUM},
    fields          = {'type','country_id','force_value','report_id','len1','role_name','general_str_len','general_str'}
}

Protocol.Packet_S2C_TrialTowerLogLoad = {
    count                     = {type = Protocol.DataType.short},
    items                     = {type = Protocol.DataType.object, length = -1, clazz='Data_TowersLogInfo'},
    fields                    = {'count','items'}
}
Protocol.structs[Protocol.S_2_S_TRIAL_TOWER_LOG_LOAD]  = Protocol.Packet_S2C_TrialTowerLogLoad
