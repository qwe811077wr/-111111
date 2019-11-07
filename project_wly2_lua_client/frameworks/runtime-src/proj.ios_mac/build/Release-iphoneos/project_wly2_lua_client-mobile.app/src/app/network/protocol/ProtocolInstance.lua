local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_ENTER_INSTANCE            = Protocol.C_2_S_INSTANCE_BASE + 0
Protocol.C_2_S_INSTANCE_BATTLE           = Protocol.C_2_S_INSTANCE_BASE + 1
Protocol.C_2_S_LOOKUP_INSTANCE_NPC_GUIDE = Protocol.C_2_S_INSTANCE_BASE + 2
Protocol.C_2_S_CHANGE_POSITION           = Protocol.C_2_S_INSTANCE_BASE + 3
Protocol.C_2_S_INSTANCE_BUY_NUM          = Protocol.C_2_S_INSTANCE_BASE + 5
Protocol.C_2_S_INSTANCE_SWEEP            = Protocol.C_2_S_INSTANCE_BASE + 6
Protocol.C_2_S_DAILY_INSTANCE_LOAD       = Protocol.C_2_S_INSTANCE_BASE + 9
Protocol.C_2_S_DAILY_INSTANCE_BATTLE     = Protocol.C_2_S_INSTANCE_BASE + 11
Protocol.C_2_S_INSTANCE_LIST             = Protocol.C_2_S_INSTANCE_BASE + 12
Protocol.C_2_S_INSTANCE_DRAW             = Protocol.C_2_S_INSTANCE_BASE + 13
Protocol.C_2_S_INSTANCE_STRATEGY         = Protocol.C_2_S_INSTANCE_BASE + 14
Protocol.C_2_S_DAILY_INSTANCE_SWEEP      = Protocol.C_2_S_INSTANCE_BASE + 15

Protocol.S_2_C_INSTANCE_INFO             = Protocol.S_2_C_INSTANCE_BASE + 0
Protocol.S_2_C_INSTANCE_BATTLE           = Protocol.S_2_C_INSTANCE_BASE + 1
Protocol.S_2_C_ADD_PASS_NPCID            = Protocol.S_2_C_INSTANCE_BASE + 2
Protocol.S_2_C_ADD_NEW_INSTANCE          = Protocol.S_2_C_INSTANCE_BASE + 3
Protocol.S_2_C_INSTANCE_NPC_GUIDE        = Protocol.S_2_C_INSTANCE_BASE + 4
Protocol.S_2_C_INSTANCE_REFRESH_TIME     = Protocol.S_2_C_INSTANCE_BASE + 5
Protocol.S_2_C_INSTANCE_BUY_NUM          = Protocol.S_2_C_INSTANCE_BASE + 6
Protocol.S_2_C_INSTANCE_SWEEP            = Protocol.S_2_C_INSTANCE_BASE + 7
Protocol.S_2_C_INSTANCE_PASS_CHAPTER     = Protocol.S_2_C_INSTANCE_BASE + 8
Protocol.S_2_C_DEL_MEMBER_MUTI_BATTLE    = Protocol.S_2_C_INSTANCE_BASE + 10
Protocol.S_2_C_HAS_APPLYED_MUTI_BATTLE   = Protocol.S_2_C_INSTANCE_BASE + 11
Protocol.S_2_C_GET_CROPS_NAME            = Protocol.S_2_C_INSTANCE_BASE + 12
Protocol.S_2_C_GET_CD_TIME               = Protocol.S_2_C_INSTANCE_BASE + 13
Protocol.S_2_C_LOAD_REWARD_GENERAL_INFO  = Protocol.S_2_C_INSTANCE_BASE + 14
Protocol.S_2_C_DAILY_INSTANCE_LOAD       = Protocol.S_2_C_INSTANCE_BASE + 16
Protocol.S_2_C_DAILY_INSTANCE_BATTLE     = Protocol.S_2_C_INSTANCE_BASE + 18
Protocol.S_2_C_INSTANCE_LIST             = Protocol.S_2_C_INSTANCE_BASE + 19
Protocol.S_2_C_INSTANCE_DRAW             = Protocol.S_2_C_INSTANCE_BASE + 20
Protocol.S_2_C_INSTANCE_STRATEGY         = Protocol.S_2_C_INSTANCE_BASE + 21
Protocol.S_2_C_DAILY_INSTANCE_SWEEP         = Protocol.S_2_C_INSTANCE_BASE + 22

Protocol.MAX_GENERAL_STR_NUM          = 100

Protocol.Packet_C2S_DailyInstanceSweep = {
    group_id        = {type = Protocol.DataType.int},
    instance_id     = {type = Protocol.DataType.int},
    fields          = {'group_id','instance_id'}
}
Protocol.structs[Protocol.C_2_S_DAILY_INSTANCE_SWEEP]  = Protocol.Packet_C2S_DailyInstanceSweep

Protocol.Packet_S2C_DailyInstanceSweep = {
    ret             = {type = Protocol.DataType.short},
    group_id        = {type = Protocol.DataType.int},
    instance_id     = {type = Protocol.DataType.int},
    fields          = {'ret','group_id','instance_id'}
}
Protocol.structs[Protocol.S_2_C_DAILY_INSTANCE_SWEEP] = Protocol.Packet_S2C_DailyInstanceSweep

Protocol.Packet_C2S_InstanceStrategy = {
    npc_id   = {type = Protocol.DataType.int},
    fields = {'npc_id'}
}
Protocol.structs[Protocol.C_2_S_INSTANCE_STRATEGY]  = Protocol.Packet_C2S_InstanceStrategy

Protocol.Packet_S2C_LoadRewardGeneralInfo = {
    --S_2_C_LOAD_REWARD_GENERAL_INFO
    general_id  = {type = Protocol.DataType.int},
    lvl         = {type = Protocol.DataType.int},
    current_exp = {type = Protocol.DataType.int},
    fields      = {'general_id','lvl','current_exp'}
}
Protocol.structs[Protocol.S_2_C_LOAD_REWARD_GENERAL_INFO] = Protocol.Packet_S2C_LoadRewardGeneralInfo

Protocol.Packet_S2C_GetCdTime = {
    world_area_id = {type = Protocol.DataType.int},
    cd_time       = {type = Protocol.DataType.int},
    fields        = {'world_area_id','cd_time'}
}
Protocol.structs[Protocol.S_2_C_GET_CD_TIME] = Protocol.Packet_S2C_GetCdTime

Protocol.Packet_S2C_GetCropsName = {
    name_len   = {type = Protocol.DataType.short},
    crops_name = {type = Protocol.DataType.string, length = Protocol.MAX_CROPS_NAME_LEN},
    fields     = {'name_len','crops_name'}
}
Protocol.structs[Protocol.S_2_C_GET_CROPS_NAME] = Protocol.Packet_S2C_GetCropsName

Protocol.Packet_S2C_HasApplyedMutiBattle = {
    world_area_id = {type = Protocol.DataType.int},
    fields        = {'world_area_id'}
}
Protocol.structs[Protocol.S_2_C_HAS_APPLYED_MUTI_BATTLE] = Protocol.Packet_S2C_HasApplyedMutiBattle

Protocol.Packet_S2C_DelMemberMutiBattle = {
    accid         = {type = Protocol.DataType.longlong},
    world_area_id = {type = Protocol.DataType.int},
    hour          = {type = Protocol.DataType.char},
    minute        = {type = Protocol.DataType.char},
    fields        = {'accid','world_area_id','hour','minute'}
}
Protocol.structs[Protocol.S_2_C_DEL_MEMBER_MUTI_BATTLE] = Protocol.Packet_S2C_DelMemberMutiBattle

Protocol.Data_SweepReward = {
    count  = {type = Protocol.DataType.short},
    rwds   = {type = Protocol.DataType.object, length = -1, clazz = 'Packet_Data_RewardType'},
    fields = {'count','rwds'}
}

Protocol.Packet_S2C_InstanceSweep = {
    instance_id = {type = Protocol.DataType.int},
    npc_id      = {type = Protocol.DataType.int},
    sweep_count = {type = Protocol.DataType.int},
    items     = {type = Protocol.DataType.object, length = -1, clazz = 'Data_SweepReward'},
    fields      = {'instance_id','npc_id', 'sweep_count', 'items'}
}
Protocol.structs[Protocol.S_2_C_INSTANCE_SWEEP] = Protocol.Packet_S2C_InstanceSweep

Protocol.Packet_C2S_InstanceSweep = {
    instance_id = {type = Protocol.DataType.int},
    npc_id      = {type = Protocol.DataType.int},
    count       = {type = Protocol.DataType.int},
    fields      = {'instance_id','npc_id','count'}
}
Protocol.structs[Protocol.C_2_S_INSTANCE_SWEEP] = Protocol.Packet_C2S_InstanceSweep

Protocol.Packet_C2S_InstanceBuyNum = {
    instance_id = {type = Protocol.DataType.int},
    npc_id      = {type = Protocol.DataType.int},
    fields      = {'instance_id','npc_id'}
}
Protocol.structs[Protocol.C_2_S_INSTANCE_BUY_NUM] = Protocol.Packet_C2S_InstanceBuyNum

Protocol.Packet_C2S_ChangePosition = {
    --C_2_S_CHANGE_POSITION
    battle_id = {type = Protocol.DataType.int},
    crops_id  = {type = Protocol.DataType.int},
    fields    = {'battle_id','crops_id'}
}
Protocol.structs[Protocol.C_2_S_CHANGE_POSITION] = Protocol.Packet_C2S_ChangePosition

Protocol.Packet_C2S_EnterInstance = {
    instance_id = {type = Protocol.DataType.int},
    fields = {'instance_id'}
}
Protocol.structs[Protocol.C_2_S_ENTER_INSTANCE] = Protocol.Packet_C2S_EnterInstance

Protocol.Packet_C2S_InstanceBattle = {
    instance_id = {type = Protocol.DataType.int},
    npc_id      = {type = Protocol.DataType.int},
    fields      = {'instance_id', 'npc_id'}
}
Protocol.structs[Protocol.C_2_S_INSTANCE_BATTLE] = Protocol.Packet_C2S_InstanceBattle

Protocol.Data_NpcInfo = {
    id      = {type = Protocol.DataType.int},
    star    = {type = Protocol.DataType.short},
    atk_num = {type = Protocol.DataType.short},
    buy_num = {type = Protocol.DataType.short},
    fields  = {'id', 'star', 'atk_num', 'buy_num'}
}

Protocol.Packet_S2C_InstanceInfo = {
    instance_id = {type = Protocol.DataType.int},
    count       = {type = Protocol.DataType.short},
    npcs        = {type = Protocol.DataType.object, length = -1, clazz = 'Data_NpcInfo'},
    fields      = {'instance_id', 'count', 'npcs'}
}
Protocol.structs[Protocol.S_2_C_INSTANCE_INFO] = Protocol.Packet_S2C_InstanceInfo

Protocol.Packet_S2C_InstanceBattle = {
    instance_id = {type = Protocol.DataType.int},
    npc_id      = {type = Protocol.DataType.int},
    star        = {type = Protocol.DataType.short},
    report_id   = {type = Protocol.DataType.llstring},
    count       = {type = Protocol.DataType.short},
    rewards     = {type = Protocol.DataType.object, length = -1, clazz = 'Packet_Data_RewardType'},
    fields      = {'instance_id', 'npc_id', 'star', 'report_id', 'count', 'rewards'}
}
Protocol.structs[Protocol.S_2_C_INSTANCE_BATTLE] = Protocol.Packet_S2C_InstanceBattle

Protocol.Packet_C2S_DailyInstanceBattle = {
    group_id        = {type = Protocol.DataType.int},
    instance_id     = {type = Protocol.DataType.int},
    fields          = {'group_id', 'instance_id'}
}
Protocol.structs[Protocol.C_2_S_DAILY_INSTANCE_BATTLE] = Protocol.Packet_C2S_DailyInstanceBattle

Protocol.Packet_C2S_LookUpInstanceNpcGuide = {
    instance_id     = {type = Protocol.DataType.int},
    npc_id          = {type = Protocol.DataType.int},
    country_id      = {type = Protocol.DataType.int},
    fields          = {'instance_id', 'npc_id', 'country_id'}
}
Protocol.structs[Protocol.C_2_S_LOOKUP_INSTANCE_NPC_GUIDE] = Protocol.Packet_C2S_LookUpInstanceNpcGuide

Protocol.Data_InstanceNpcGuide = {
    attacker_name_len   = {type = Protocol.DataType.short},
    attacker_name       = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    lvl                 = {type = Protocol.DataType.short},
    report_id           = {type = Protocol.DataType.llstring},
    fields              = {'attacker_name_len', 'attacker_name', 'lvl', 'report_id'}
}
Protocol.Packet_S2C_InstanceNpcGuide = {
    instance_id     = {type = Protocol.DataType.int},
    npc_id          = {type = Protocol.DataType.int},
    count           = {type = Protocol.DataType.short},
    data            = {type = Protocol.DataType.object, length = -1, clazz='Data_InstanceNpcGuide'},
    fields          = {'instance_id', 'npc_id', 'count', 'data'}
}
Protocol.structs[Protocol.S_2_C_INSTANCE_NPC_GUIDE]         = Protocol.Packet_S2C_InstanceNpcGuide

Protocol.Packet_S2C_InstanceRefreshTime = {
    year            = {type = Protocol.DataType.int},
    season          = {type = Protocol.DataType.char},
    hour            = {type = Protocol.DataType.char},
    minute          = {type = Protocol.DataType.char},
    fields          = {'year', 'season', 'hour', 'minute'}
}
Protocol.structs[Protocol.S_2_C_INSTANCE_REFRESH_TIME]      = Protocol.Packet_S2C_InstanceRefreshTime

Protocol.Packet_Data_InstanceInfo = {
    id                      = {type = Protocol.DataType.int},
    num                     = {type = Protocol.DataType.short},
    fields                  = {'id','num'}
}

Protocol.Packet_Data_PassInfo = {
    id                      = {type = Protocol.DataType.int},
    count                   = {type = Protocol.DataType.short},
    ids                     = {type = Protocol.DataType.int, length = -1},
    fields                  = {'id','count','ids'}
}

Protocol.Packet_S2C_DailyInstanceLoad = {
    count           = {type = Protocol.DataType.short},
    nums            = {type = Protocol.DataType.object, length = -1, clazz='Packet_Data_InstanceInfo'},
    count1          = {type = Protocol.DataType.short},
    pass_ids        = {type = Protocol.DataType.object, length = -1, clazz='Packet_Data_PassInfo'},
    fields          = {'count', 'nums', 'count1', 'pass_ids'}
}
Protocol.structs[Protocol.S_2_C_DAILY_INSTANCE_LOAD]      = Protocol.Packet_S2C_DailyInstanceLoad

Protocol.Packet_S2C_DailyInstanceBattle = {
    group_id        = {type = Protocol.DataType.int},
    instance_id     = {type = Protocol.DataType.int},
    battle_ret      = {type = Protocol.DataType.short},
    report_id       = {type = Protocol.DataType.llstring},
    fields          = {'group_id', 'instance_id', 'battle_ret', 'report_id'}
}
Protocol.structs[Protocol.S_2_C_DAILY_INSTANCE_BATTLE]      = Protocol.Packet_S2C_DailyInstanceBattle

Protocol.Packet_S2C_AddPassNpcId = {
    instance_id     = {type = Protocol.DataType.int},
    npc_id          = {type = Protocol.DataType.int},
    fields          = {'instance_id', 'npc_id'}
}
Protocol.structs[Protocol.S_2_C_ADD_PASS_NPCID] = Protocol.Packet_S2C_AddPassNpcId

Protocol.Packet_S2C_NewInstance = {
    count       = {type = Protocol.DataType.short},
    instance_id = {type = Protocol.DataType.int, length = -1},
    ret         = {type = Protocol.DataType.short},
    fields      = {'count', 'instance_id', 'ret'}
}
Protocol.structs[Protocol.S_2_C_ADD_NEW_INSTANCE] = Protocol.Packet_S2C_NewInstance

Protocol.Packet_S2C_InstanceBuyNum = {
    instance_id = {type = Protocol.DataType.int},
    npc_id      = {type = Protocol.DataType.int},
    buy_num     = {type = Protocol.DataType.short},
    fields      = {'instance_id', 'npc_id', 'buy_num'}
}
Protocol.structs[Protocol.S_2_C_INSTANCE_BUY_NUM] = Protocol.Packet_S2C_InstanceBuyNum

Protocol.Packet_S2C_InstanceList = {
    cur_instance = {type = Protocol.DataType.int},
    count        = {type = Protocol.DataType.short},
    ids          = {type = Protocol.DataType.int, length = -1},
    fields       = {'cur_instance', 'count', 'ids'}
}
Protocol.structs[Protocol.S_2_C_INSTANCE_LIST] = Protocol.Packet_S2C_InstanceList

Protocol.Packet_PassCardRate = {
    id                        = {type = Protocol.DataType.int},
    rate                      = {type = Protocol.DataType.short},
    fields                    = {'id','rate'}
}

Protocol.Packet_Data_PassChapters = {
    id         = {type = Protocol.DataType.short},
    count      = {type = Protocol.DataType.short},
    npcs       = {type = Protocol.DataType.object, length = -1, clazz = 'Packet_PassCardRate'},
    count1     = {type = Protocol.DataType.short},
    reward_ids = {type = Protocol.DataType.int, length = -1},
    fields     = {'id','count','npcs','count1','reward_ids'}
}

Protocol.Packet_S2C_InstancePassChapter = {
    is_last      = {type = Protocol.DataType.short},
    count        = {type = Protocol.DataType.short},
    chapters     = {type = Protocol.DataType.object, length = -1, clazz = 'Packet_Data_PassChapters'},
    fields       = {'is_last','count','chapters'}
}
Protocol.structs[Protocol.S_2_C_INSTANCE_PASS_CHAPTER] = Protocol.Packet_S2C_InstancePassChapter


Protocol.Packet_C2S_InstanceDraw = {
    id         = {type = Protocol.DataType.int},
    chapter_id = {type = Protocol.DataType.int},
    fields     = {'id','chapter_id'}
}
Protocol.structs[Protocol.C_2_S_INSTANCE_DRAW] = Protocol.Packet_C2S_InstanceDraw

Protocol.Packet_S2C_InstanceDraw = {
    ret        = {type = Protocol.DataType.short},
    id         = {type = Protocol.DataType.int},
    chapter_id = {type = Protocol.DataType.int},
    fields     = {'ret','id','chapter_id'}
}
Protocol.structs[Protocol.S_2_C_INSTANCE_DRAW] = Protocol.Packet_S2C_InstanceDraw

Protocol.Packet_PassCardRateItems = {
    type                        = {type = Protocol.DataType.short},
    country_id                  = {type = Protocol.DataType.short},
    force_value                 = {type = Protocol.DataType.int},
    report_id                   = {type = Protocol.DataType.llstring},
    role_name_len               = {type = Protocol.DataType.short},
    role_name                   = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    general_str_len             = {type = Protocol.DataType.short},
    general_str                 = {type = Protocol.DataType.string, length = Protocol.MAX_GENERAL_STR_NUM},
    fields                      = {'type','country_id','force_value','report_id','role_name_len','role_name','general_str_len','general_str'}
}

Protocol.Packet_S2C_InstanceStrategy = {
    count             = {type = Protocol.DataType.short},
    items             = {type = Protocol.DataType.object, length = -1, clazz = 'Packet_PassCardRateItems'},
    fields            = {'count','items'}
}
Protocol.structs[Protocol.S_2_C_INSTANCE_STRATEGY] = Protocol.Packet_S2C_InstanceStrategy