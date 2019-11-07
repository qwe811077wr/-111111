local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_ALLGENERAL_INFO            = Protocol.C_2_S_GENERAL_BASE + 0
Protocol.C_2_S_REBUILD_SOLDIER            = Protocol.C_2_S_GENERAL_BASE + 1
Protocol.C_2_S_REBUILD_SOLDIER_RES        = Protocol.C_2_S_GENERAL_BASE + 2
Protocol.C_2_S_TRANSFER_SOLDIER           = Protocol.C_2_S_GENERAL_BASE + 3
Protocol.C_2_S_REINCARNATION              = Protocol.C_2_S_GENERAL_BASE + 4
Protocol.C_2_S_GETRECRUIT_GENERAL_IDS     = Protocol.C_2_S_GENERAL_BASE + 5
Protocol.C_2_S_RECRUIT_GENRAL             = Protocol.C_2_S_GENERAL_BASE + 6
Protocol.C_2_S_GENERAL_ATTR_INFO          = Protocol.C_2_S_GENERAL_BASE + 7
Protocol.C_2_S_GENERAL_INFOS              = Protocol.C_2_S_GENERAL_BASE + 8
Protocol.C_2_S_GENARAL_SET_BATTLE_SOLDIER = Protocol.C_2_S_GENERAL_BASE + 9
Protocol.C_2_S_ADD_GENERAL_NUMS           = Protocol.C_2_S_GENERAL_BASE + 10
Protocol.C_2_S_GENERAL_EPIPHANY           = Protocol.C_2_S_GENERAL_BASE + 11
Protocol.C_2_S_REBUILD_GENERAL_BY_ITEM    = Protocol.C_2_S_GENERAL_BASE + 13
Protocol.C_2_S_GENERAL_LIMIT_SOLDIER_NUM  = Protocol.C_2_S_GENERAL_BASE + 14
Protocol.C_2_S_ILLUSTRATION_LOAD          = Protocol.C_2_S_GENERAL_BASE + 15
Protocol.C_2_S_ILLUSTRATION_ACTIVE        = Protocol.C_2_S_GENERAL_BASE + 17
Protocol.C_2_S_EQUIP_ADVANCE_ITEM         = Protocol.C_2_S_GENERAL_BASE + 19
Protocol.C_2_S_MIRACLE_SET_FORMATION      = Protocol.C_2_S_GENERAL_BASE + 20
Protocol.C_2_S_GENERAL_ADVANCE            = Protocol.C_2_S_GENERAL_BASE + 21
Protocol.C_2_S_MIRACLE_FIGHT_LOAD         = Protocol.C_2_S_GENERAL_BASE + 22
Protocol.C_2_S_MIRACLE_FIGHT_BATTLE       = Protocol.C_2_S_GENERAL_BASE + 23
Protocol.C_2_S_MIRACLE_FIGHT_LEVEL_UP     = Protocol.C_2_S_GENERAL_BASE + 24
Protocol.C_2_S_MIRACLE_FIGHT_HANGUP       = Protocol.C_2_S_GENERAL_BASE + 25
Protocol.C_2_S_MIRACLE_FIGHT_DRAW_REWARD  = Protocol.C_2_S_GENERAL_BASE + 26
Protocol.C_2_S_GENERAL_PIECE_NUM          = Protocol.C_2_S_GENERAL_BASE + 27
Protocol.C_2_S_GENERAL_COMPOSE            = Protocol.C_2_S_GENERAL_BASE + 28
Protocol.C_2_S_ILLUSTRATION_DRAW          = Protocol.C_2_S_GENERAL_BASE + 29
Protocol.C_2_S_ILLUSTRATION_ACTIVE_GROWTH = Protocol.C_2_S_GENERAL_BASE + 30
Protocol.C_2_S_GENERAL_CLEAR_TIRED        = Protocol.C_2_S_GENERAL_BASE + 31
Protocol.C_2_S_BUY_TIRED_MATERIAL         = Protocol.C_2_S_GENERAL_BASE + 32

Protocol.S_2_C_ALLGENERAL_INFO            = Protocol.S_2_C_GENARAL_BASE + 0
Protocol.S_2_C_TRANSFER_SOLDIER_RES       = Protocol.S_2_C_GENARAL_BASE + 1
Protocol.S_2_C_REBUILD_SOLDIER_IDS        = Protocol.S_2_C_GENARAL_BASE + 2
Protocol.S_2_C_REBUILD_SOLDIER_RES        = Protocol.S_2_C_GENARAL_BASE + 3
Protocol.S_2_CREINCARNATION_RES           = Protocol.S_2_C_GENARAL_BASE + 4
Protocol.S_2_C_CRUITEGENRALIDS            = Protocol.S_2_C_GENARAL_BASE + 5
Protocol.S_2_C_CRUITEGENERAL_RES          = Protocol.S_2_C_GENARAL_BASE + 6
Protocol.S_2_C_GENERAL_ATTR_INFO          = Protocol.S_2_C_GENARAL_BASE + 7
Protocol.S_2_C_GENERALINFOS               = Protocol.S_2_C_GENARAL_BASE + 8
Protocol.S_2_C_UPDATE_GENARALINFO         = Protocol.S_2_C_GENARAL_BASE + 9
Protocol.S_2_C_GENERAL_EPIPHANY           = Protocol.S_2_C_GENARAL_BASE + 10
Protocol.S_2_C_ADD_GENERAL_NUMS           = Protocol.S_2_C_GENARAL_BASE + 11
Protocol.S_2_C_REBUILD_GENERAL_BY_ITEM    = Protocol.S_2_C_GENARAL_BASE + 12
Protocol.S_2_C_GENERAL_LIMIT_SOLDIER_NUM  = Protocol.S_2_C_GENARAL_BASE + 13
Protocol.S_2_C_REBUILD_GENERAL_INFO       = Protocol.S_2_C_GENARAL_BASE + 14
Protocol.S_2_C_REBUILD_GENERAL            = Protocol.S_2_C_GENARAL_BASE + 15
Protocol.S_2_C_ILLUSTRATION_LOAD          = Protocol.S_2_C_GENARAL_BASE + 16
Protocol.S_2_C_ILLUSTRATION_NEW_ACTIVE    = Protocol.S_2_C_GENARAL_BASE + 18
Protocol.S_2_C_ILLUSTRATION_ACTIVE        = Protocol.S_2_C_GENARAL_BASE + 20
Protocol.S_2_C_EQUIP_ADVANCE_ITEM         = Protocol.S_2_C_GENARAL_BASE + 22
Protocol.S_2_C_GENERAL_ADVANCE            = Protocol.S_2_C_GENARAL_BASE + 24
Protocol.S_2_C_MIRACLE_FIGHT_LOAD         = Protocol.S_2_C_GENARAL_BASE + 25
Protocol.S_2_C_MIRACLE_FIGHT_BATTLE       = Protocol.S_2_C_GENARAL_BASE + 26
Protocol.S_2_C_MIRACLE_FIGHT_LEVEL_UP     = Protocol.S_2_C_GENARAL_BASE + 27
Protocol.S_2_C_MIRACLE_FIGHT_HANGUP       = Protocol.S_2_C_GENARAL_BASE + 28
Protocol.S_2_C_MIRACLE_SET_FORMATION      = Protocol.S_2_C_GENARAL_BASE + 29
Protocol.S_2_C_MIRACLE_FIGHT_DRAW_REWARD  = Protocol.S_2_C_GENARAL_BASE + 30
Protocol.S_2_C_GENERAL_PIECE_NUM          = Protocol.S_2_C_GENARAL_BASE + 31
Protocol.S_2_C_GENERAL_COMPOSE            = Protocol.S_2_C_GENARAL_BASE + 32
Protocol.S_2_C_UPDATE_GENERAL_SOLDIER     = Protocol.S_2_C_GENARAL_BASE + 33
Protocol.S_2_C_ILLUSTRATION_DRAW          = Protocol.S_2_C_GENARAL_BASE + 34
Protocol.S_2_C_ILLUSTRATION_ACTIVE_GROWTH = Protocol.S_2_C_GENARAL_BASE + 35
Protocol.S_2_C_ILLUSTRATION_NEW_GROWTH    = Protocol.S_2_C_GENARAL_BASE + 36
Protocol.S_2_C_UPDATE_GENERAL_INTERNAL    = Protocol.S_2_C_GENARAL_BASE + 37
Protocol.S_2_C_GENERAL_CLEAR_TIRED        = Protocol.S_2_C_GENARAL_BASE + 38
Protocol.S_2_C_BUY_TIRED_MATERIAL         = Protocol.S_2_C_GENARAL_BASE + 39
Protocol.S_2_C_GET_NEW_GENERAL            = Protocol.S_2_C_GENARAL_BASE + 40

------------------------------C_2_S------------------------------
Protocol.Packet_C2S_AllGeneralInfo = {
    fields          = {}
}
Protocol.structs[Protocol.C_2_S_ALLGENERAL_INFO]              = Protocol.Packet_C2S_AllGeneralInfo

Protocol.Packet_C2S_GeneralLimitSoldierNum = {
    --C_2_S_GENERAL_LIMIT_SOLDIER_NUM
    generalId  = {type = Protocol.DataType.int},
    soldierNum = {type = Protocol.DataType.int},
    fields     = {'generalId','soldierNum'}
}
Protocol.structs[Protocol.C_2_S_GENERAL_LIMIT_SOLDIER_NUM]  = Protocol.Packet_C2S_GeneralLimitSoldierNum

Protocol.Packet_C2S_RebuildSoldier = {
    general_id      = {type = Protocol.DataType.uint},
    fields          = {'general_id'}
}
Protocol.structs[Protocol.C_2_S_REBUILD_SOLDIER]              = Protocol.Packet_C2S_RebuildSoldier

Protocol.Packet_C2S_RebuildSoldier_Res = {
    general_id      = {type = Protocol.DataType.uint},
    op              = {type = Protocol.DataType.char},
    fields          = {'general_id', 'op'}
}
Protocol.structs[Protocol.C_2_S_REBUILD_SOLDIER_RES]          = Protocol.Packet_C2S_RebuildSoldier_Res

Protocol.Packet_C2S_TransferSoldier = {
    general_id      = {type = Protocol.DataType.int},
    fields          = {'general_id'}
}
Protocol.structs[Protocol.C_2_S_TRANSFER_SOLDIER]             = Protocol.Packet_C2S_TransferSoldier

Protocol.Packet_C2S_Reincarnation = {
    general_id      = {type = Protocol.DataType.uint},
    fields          = {'general_id'}
}
Protocol.structs[Protocol.C_2_S_REINCARNATION]                = Protocol.Packet_C2S_Reincarnation

Protocol.Packet_C2S_GetRecruitGeneral_Ids = {
    fields          = {}
}
Protocol.structs[Protocol.C_2_S_GETRECRUIT_GENERAL_IDS]       = Protocol.Packet_C2S_GetRecruitGeneral_Ids

Protocol.Packet_C2S_RecruitGeneral = {
    general_id      = {type = Protocol.DataType.uint},
    fields          = {'general_id'}
}
Protocol.structs[Protocol.C_2_S_RECRUIT_GENRAL]               = Protocol.Packet_C2S_RecruitGeneral

Protocol.Packet_C2S_GeneralAttrInfo = {
    general_id      = {type = Protocol.DataType.int},
    fields          = {'general_id'}
}
Protocol.structs[Protocol.C_2_S_GENERAL_ATTR_INFO]               = Protocol.Packet_C2S_GeneralAttrInfo

Protocol.Packet_C2S_GeneralInfos = {
    general_id      = {type = Protocol.DataType.int},
    fields          = {'general_id'}
}
Protocol.structs[Protocol.C_2_S_GENERAL_INFOS]                = Protocol.Packet_C2S_GeneralInfos

Protocol.Packet_C2S_SetGenaralBattleSoldier = {
    general_id      = {type = Protocol.DataType.uint},
    soldier_id      = {type = Protocol.DataType.uint},
    fields          = {'general_id', 'soldier_id'}
}
Protocol.structs[Protocol.C_2_S_GENARAL_SET_BATTLE_SOLDIER]   = Protocol.Packet_C2S_SetGenaralBattleSoldier

Protocol.Packet_C2S_GeneralEpiphany = {
    general_id = {type = Protocol.DataType.int},
    fields     = {'general_id'}
}
Protocol.structs[Protocol.C_2_S_GENERAL_EPIPHANY]  = Protocol.Packet_C2S_GeneralEpiphany

Protocol.Packet_C2S_RebuildGeneralByItem = {
    eqId      = {type = Protocol.DataType.int},
    generalId = {type = Protocol.DataType.int},
    fields    = {'eqId','generalId'}
}
Protocol.structs[Protocol.C_2_S_REBUILD_GENERAL_BY_ITEM]  = Protocol.Packet_C2S_RebuildGeneralByItem

Protocol.Packet_C2S_IllustrationActive = {
    id          = {type = Protocol.DataType.int},
    fields      = {'id'}
}
Protocol.structs[Protocol.C_2_S_ILLUSTRATION_ACTIVE]  = Protocol.Packet_C2S_IllustrationActive

Protocol.Packet_C2S_EquipAdvanceItem= {
    general_id      = {type = Protocol.DataType.int},
    equip_len       = {type = Protocol.DataType.short},
    equip_pos       = {type = Protocol.DataType.short, length = Protocol.MAX_EQUIP_LEN},
    fields          = {'general_id', 'equip_len', 'equip_pos'}
}
Protocol.structs[Protocol.C_2_S_EQUIP_ADVANCE_ITEM]   = Protocol.Packet_C2S_EquipAdvanceItem

Protocol.Packet_C2S_GeneralAdvance= {
    general_id      = {type = Protocol.DataType.int},
    fields          = {'general_id'}
}
Protocol.structs[Protocol.C_2_S_GENERAL_ADVANCE]   = Protocol.Packet_C2S_GeneralAdvance

Protocol.Packet_C2S_MiracleFightBattle= {
    id              = {type = Protocol.DataType.short},
    fields          = {'id'}
}
Protocol.structs[Protocol.C_2_S_MIRACLE_FIGHT_BATTLE]   = Protocol.Packet_C2S_MiracleFightBattle

Protocol.Packet_C2S_MiracleFightLevelUp= {
    id              = {type = Protocol.DataType.short},
    fields          = {'id'}
}
Protocol.structs[Protocol.C_2_S_MIRACLE_FIGHT_LEVEL_UP]   = Protocol.Packet_C2S_MiracleFightLevelUp

Protocol.Packet_C2S_MiracleFightHangup= {
    id              = {type = Protocol.DataType.short},
    time_id         = {type = Protocol.DataType.short},
    general_id1     = {type = Protocol.DataType.int},
    general_id2     = {type = Protocol.DataType.int},
    fields          = {'id','time_id','general_id1','general_id2'}
}
Protocol.structs[Protocol.C_2_S_MIRACLE_FIGHT_HANGUP]   = Protocol.Packet_C2S_MiracleFightHangup

Protocol.Packet_C2S_MiracleFightDrawReward= {
    id              = {type = Protocol.DataType.short},
    fields          = {'id'}
}
Protocol.structs[Protocol.C_2_S_MIRACLE_FIGHT_DRAW_REWARD]   = Protocol.Packet_C2S_MiracleFightDrawReward

Protocol.Packet_C2S_GeneralCompose = {
    temp_id         = {type = Protocol.DataType.int},
    fields          = {'temp_id'}
}
Protocol.structs[Protocol.C_2_S_GENERAL_COMPOSE]      = Protocol.Packet_C2S_GeneralCompose

Protocol.Packet_C2S_SetFormation = {
    formation_id    = {type = Protocol.DataType.int},
    count           = {type = Protocol.DataType.short},
    generals        = {type = Protocol.DataType.object, length = -1, clazz = 'Data_GeneralLoc'},
    fields          = {'formation_id', 'count', 'generals'}
}
Protocol.structs[Protocol.C_2_S_MIRACLE_SET_FORMATION]   = Protocol.Packet_C2S_SetFormation

Protocol.Data_Tire = {
    level  = {type = Protocol.DataType.int},
    exp    = {type = Protocol.DataType.int},
    attr   = {type = Protocol.DataType.int},
    fields = {'level','exp','attr'}
}

------------------------------S_2_C------------------------------
Protocol.Data_SGeneralInfo = {
    id                     = {type = Protocol.DataType.int},
    lvl                    = {type = Protocol.DataType.short},
    leader                 = {type = Protocol.DataType.short},
    attack                 = {type = Protocol.DataType.short},
    mental                 = {type = Protocol.DataType.short},
    current_soldiers       = {type = Protocol.DataType.int},
    max_soldiers           = {type = Protocol.DataType.int},
    soldierId1             = {type = Protocol.DataType.int},
    soldierId2             = {type = Protocol.DataType.int},
    rebuildSoldierId1      = {type = Protocol.DataType.int},
    rebuildSoldierId2      = {type = Protocol.DataType.int},
    current_exp            = {type = Protocol.DataType.int},
    train_time             = {type = Protocol.DataType.int},
    reincarnation_tims     = {type = Protocol.DataType.char},
    next_reincarnation_lvl = {type = Protocol.DataType.short},
    battle_soldier_id      = {type = Protocol.DataType.int},
    train_time_type        = {type = Protocol.DataType.char},
    train_type             = {type = Protocol.DataType.char},
    auto_reincarnation     = {type = Protocol.DataType.char},
    skill_id               = {type = Protocol.DataType.int},
    name_len               = {type = Protocol.DataType.short},
    name                   = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    wound_type             = {type = Protocol.DataType.short},
    leader_atk             = {type = Protocol.DataType.short},
    leader_atk_def         = {type = Protocol.DataType.short},
    policy_atk             = {type = Protocol.DataType.short},
    policy_atk_def         = {type = Protocol.DataType.short},
    attack_atk             = {type = Protocol.DataType.short},
    attack_atk_def         = {type = Protocol.DataType.short},
    crit_rate              = {type = Protocol.DataType.short},
    beat_back_rate         = {type = Protocol.DataType.short},
    dec_injury_rate        = {type = Protocol.DataType.short},
    siege                  = {type = Protocol.DataType.int},
    dragon_soul            = {type = Protocol.DataType.short},
    tiger_soul             = {type = Protocol.DataType.short},
    basaitic_soul          = {type = Protocol.DataType.short},
    transferSoldierTimes   = {type = Protocol.DataType.char},
    skill_level            = {type = Protocol.DataType.int},
    limitSoldierNum        = {type = Protocol.DataType.int},
    power                  = {type = Protocol.DataType.int},
    advanceLevel           = {type = Protocol.DataType.short},
    advanceInfo            = {type = Protocol.DataType.short, length = Protocol.MAX_ADVANCE_INFO},
    tired                  = {type = Protocol.DataType.int},
    internal_attr          = {type = Protocol.DataType.object, length = Protocol.MAX_OFFICER_LEN, clazz = 'Data_Tire'},
    rtemp_id               = {type = Protocol.DataType.int},
    grade                  = {type = Protocol.DataType.int},

    fields          = {'id','lvl','leader','attack','mental','current_soldiers','max_soldiers','soldierId1','soldierId2','rebuildSoldierId1','rebuildSoldierId2',
                       'current_exp','train_time','reincarnation_tims','next_reincarnation_lvl','battle_soldier_id','train_time_type','train_type',
                       'auto_reincarnation','skill_id','name_len','name','wound_type','leader_atk','leader_atk_def','policy_atk','policy_atk_def','attack_atk','attack_atk_def',
                       'crit_rate','beat_back_rate','dec_injury_rate','siege','dragon_soul','tiger_soul','basaitic_soul','transferSoldierTimes','skill_level','limitSoldierNum','power','advanceLevel','advanceInfo','tired','internal_attr','rtemp_id','grade'}
}

Protocol.Packet_S2C_AllGeneralInfo = {
    isRebuildSoldierFree      = {type = Protocol.DataType.char},
    rebuildSoldierNums        = {type = Protocol.DataType.int},
    goldSuddenNums            = {type = Protocol.DataType.int},
    mainGeneralId             = {type = Protocol.DataType.int},
    isOver                    = {type = Protocol.DataType.char},
    counts                    = {type = Protocol.DataType.char},
    generals                   = {type = Protocol.DataType.object, length = -1, clazz='Data_SGeneralInfo'},
    fields                    = {'isRebuildSoldierFree','rebuildSoldierNums','goldSuddenNums','mainGeneralId','isOver','counts','generals'}
}
Protocol.structs[Protocol.S_2_C_ALLGENERAL_INFO]           = Protocol.Packet_S2C_AllGeneralInfo

Protocol.Packet_S2C_GeneralLimitSoldierNum = {
    --S_2_C_GENERAL_LIMIT_SOLDIER_NUM
    generalId           = {type = Protocol.DataType.int},
    soldierNum          = {type = Protocol.DataType.int},
    cur_soldier_num     = {type = Protocol.DataType.int},
    role_soldier_num    = {type = Protocol.DataType.int},
    fields              = {'generalId','soldierNum','cur_soldier_num','role_soldier_num'}
}
Protocol.structs[Protocol.S_2_C_GENERAL_LIMIT_SOLDIER_NUM]          = Protocol.Packet_S2C_GeneralLimitSoldierNum

Protocol.Packet_S2C_TransferRes = {
    ret                       = {type = Protocol.DataType.char},
    failed_type               = {type = Protocol.DataType.char},
    genaral_id                = {type = Protocol.DataType.int},
    new_soldier_id1           = {type = Protocol.DataType.int},
    new_soldier_id2           = {type = Protocol.DataType.int},
    transfer_soldier_times    = {type = Protocol.DataType.short},
    fields                    = {'ret','failed_type','genaral_id','new_soldier_id1','new_soldier_id2','transfer_soldier_times'}
}
Protocol.structs[Protocol.S_2_C_TRANSFER_SOLDIER_RES]            = Protocol.Packet_S2C_TransferRes

Protocol.Packet_S2C_RebuildSoldierIds = {
    genaral_id                = {type = Protocol.DataType.uint},
    soldier_id1               = {type = Protocol.DataType.short},
    soldier_id2               = {type = Protocol.DataType.short},
    fields                    = {'genaral_id','soldier_id1','soldier_id2'}
}
Protocol.structs[Protocol.S_2_C_REBUILD_SOLDIER_IDS]            = Protocol.Packet_S2C_RebuildSoldierIds

Protocol.Packet_S2C_RebuildRes = {
    genaral_id                = {type = Protocol.DataType.uint},
    res                       = {type = Protocol.DataType.char},
    soldier_id1               = {type = Protocol.DataType.short},
    soldier_id2               = {type = Protocol.DataType.short},
    fields                    = {'genaral_id','res','soldier_id1','soldier_id2'}
}
Protocol.structs[Protocol.S_2_C_REBUILD_SOLDIER_RES]            = Protocol.Packet_S2C_RebuildRes

Protocol.Packet_S2C_ReincarnationRes = {
    genaral_id                = {type = Protocol.DataType.uint},
    reincarnation_nums        = {type = Protocol.DataType.char},
    next_lvl                  = {type = Protocol.DataType.short},
    fields                    = {'genaral_id','reincarnation_nums','next_lvl'}
}
Protocol.structs[Protocol.S_2_CREINCARNATION_RES]                = Protocol.Packet_S2C_ReincarnationRes

Protocol.Data_CruiteGeneralId = {
    id     = {type = Protocol.DataType.int},
    level  = {type = Protocol.DataType.short},
    fields = {'id','level'}
}

Protocol.Packet_S2C_CruiteGeneralIds = {
    counts                     = {type = Protocol.DataType.int},
    ids                        = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CruiteGeneralId'},
    fields                     = {'counts','ids'}
}
Protocol.structs[Protocol.S_2_C_CRUITEGENRALIDS]                 = Protocol.Packet_S2C_CruiteGeneralIds

Protocol.Packet_S2C_CruiteGeneral_Res = {
    res                        = {type = Protocol.DataType.char},
    genaral_id                 = {type = Protocol.DataType.uint},
    fields                     = {'res','genaral_id'}
}
Protocol.structs[Protocol.S_2_C_CRUITEGENERAL_RES]               = Protocol.Packet_S2C_CruiteGeneral_Res

Protocol.Data_GeneralAttrInfo = {
    attr_type                 = {type = Protocol.DataType.short},
    value                     = {type = Protocol.DataType.double},
    fields                    = {'attr_type', 'value'}
}

Protocol.Data_GeneralsAttr = {
    general_id                 = {type = Protocol.DataType.int},
    power                      = {type = Protocol.DataType.int},
    count                      = {type = Protocol.DataType.short},
    attr_list                  = {type = Protocol.DataType.object, length = -1, clazz = 'Data_GeneralAttrInfo'},
    fields                     = {'general_id','power','count', 'attr_list'}
}

Protocol.Packet_S2C_GeneralAttrInfo = {
    count                      = {type = Protocol.DataType.short},
    arr_infos                  = {type = Protocol.DataType.object, length = -1, clazz = 'Data_GeneralsAttr'},
    fields                     = {'count', 'arr_infos'}
}
Protocol.structs[Protocol.S_2_C_GENERAL_ATTR_INFO]              = Protocol.Packet_S2C_GeneralAttrInfo

Protocol.Packet_S2C_GeneralInfo = {
    res                        = {type = Protocol.DataType.char},
    data                       = {type = Protocol.DataType.object, clazz='Data_SGeneralInfo'},
    fields                     = {'res','data'}
}
Protocol.structs[Protocol.S_2_C_GENERALINFOS]                    = Protocol.Packet_S2C_GeneralInfo

Protocol.Packet_S2C_UpdateGeneralInfo = {
    general_id                  = {type = Protocol.DataType.int},
    exp                         = {type = Protocol.DataType.int},
    lvl                         = {type = Protocol.DataType.short},
    leader                      = {type = Protocol.DataType.int},
    attack                      = {type = Protocol.DataType.int},
    mental                      = {type = Protocol.DataType.int},
    current_soldiers            = {type = Protocol.DataType.int},
    max_soldiers                = {type = Protocol.DataType.int},
    battle_soldier_id           = {type = Protocol.DataType.int},
    power                       = {type = Protocol.DataType.int},
    fields                      = {'general_id','exp','lvl','leader','attack','mental','current_soldiers','max_soldiers','battle_soldier_id','power'}
}
Protocol.structs[Protocol.S_2_C_UPDATE_GENARALINFO]                = Protocol.Packet_S2C_UpdateGeneralInfo

Protocol.Packet_S2C_GeneralEpiphany = {
    id                  = {type = Protocol.DataType.int},
    old_temp_id         = {type = Protocol.DataType.int},
    new_temp_id         = {type = Protocol.DataType.int},
    data                = {type = Protocol.DataType.object, length = 1,clazz='Data_SGeneralInfo'},
    fields              = {'id', 'old_temp_id','new_temp_id','data'}
}
Protocol.structs[Protocol.S_2_C_GENERAL_EPIPHANY]              = Protocol.Packet_S2C_GeneralEpiphany

Protocol.Packet_S2C_RebuildGeneralByItem = {
    eqId                            = {type = Protocol.DataType.int},
    rmGeneralId                     = {type = Protocol.DataType.int},
    mainGeneral                     = {type = Protocol.DataType.int},
    data                            = {type = Protocol.DataType.object, length = 1, clazz='Data_SGeneralInfo'},
    fields                          = {'eqId','rmGeneralId','mainGeneral','data'}
}
Protocol.structs[Protocol.S_2_C_REBUILD_GENERAL_BY_ITEM]                        = Protocol.Packet_S2C_RebuildGeneralByItem

Protocol.Data_IllustrationGrowth = {
    growth_id       = {type = Protocol.DataType.short},
    growth_state    = {type = Protocol.DataType.short},
    fields          = {'growth_id','growth_state'}
}

Protocol.Data_IllustrationInfo = {
    id              = {type = Protocol.DataType.int},
    state           = {type = Protocol.DataType.short},
    draw            = {type = Protocol.DataType.short},
    growth_count    = {type = Protocol.DataType.short},
    growth          = {type = Protocol.DataType.object, length = -1, clazz='Data_IllustrationGrowth'},
    fields = {'id','state','draw','growth_count','growth'}
}

Protocol.Packet_S2C_IllustrationLoad = {
    total_exp                       = {type = Protocol.DataType.int},
    count                           = {type = Protocol.DataType.short},
    items                           = {type = Protocol.DataType.object, length = -1, clazz='Data_IllustrationInfo'},
    fields                          = {'total_exp','count','items'}
}
Protocol.structs[Protocol.S_2_C_ILLUSTRATION_LOAD]                        = Protocol.Packet_S2C_IllustrationLoad

Protocol.Packet_S2C_IllustrationNewAcieve = {
    count                           = {type = Protocol.DataType.short},
    ids                             = {type = Protocol.DataType.int, length = -1},
    fields                          = {'count','ids'}
}
Protocol.structs[Protocol.S_2_C_ILLUSTRATION_NEW_ACTIVE]                        = Protocol.Packet_S2C_IllustrationNewAcieve

Protocol.Packet_S2C_IllustrationActive = {
    ret                             = {type = Protocol.DataType.short},
    id                              = {type = Protocol.DataType.int},
    exp                             = {type = Protocol.DataType.int},
    fields                          = {'ret','id','exp'}
}
Protocol.structs[Protocol.S_2_C_ILLUSTRATION_ACTIVE]                        = Protocol.Packet_S2C_IllustrationActive

Protocol.Packet_S2C_EquipAdvanceItem = {
    ret                     = {type = Protocol.DataType.short},
    general_id              = {type = Protocol.DataType.int},
    equip_len               = {type = Protocol.DataType.short},
    equip_pos               = {type = Protocol.DataType.short, length = -1},
    fields                  = {'ret','general_id','equip_len','equip_pos'}
}
Protocol.structs[Protocol.S_2_C_EQUIP_ADVANCE_ITEM]             = Protocol.Packet_S2C_EquipAdvanceItem

Protocol.Packet_S2C_GeneralAdvance = {
    ret                     = {type = Protocol.DataType.short},
    general_id              = {type = Protocol.DataType.int},
    advance_level           = {type = Protocol.DataType.short},
    fields                  = {'ret','general_id','advance_level'}
}
Protocol.structs[Protocol.S_2_C_GENERAL_ADVANCE]                = Protocol.Packet_S2C_GeneralAdvance

Protocol.Data_MiracleInfo = {
    id                      = {type = Protocol.DataType.short},
    lvl                     = {type = Protocol.DataType.short},
    time_id                 = {type = Protocol.DataType.short},
    left_time               = {type = Protocol.DataType.int},
    general_id1             = {type = Protocol.DataType.int},
    general_id2             = {type = Protocol.DataType.int},
    fields                  = {'id','lvl','time_id','left_time','general_id1','general_id2'}
}

Protocol.Packet_S2C_SetFormation = {
    ret                     = {type = Protocol.DataType.short},
    fields                  = {'ret'}
}
Protocol.structs[Protocol.S_2_C_MIRACLE_SET_FORMATION]               = Protocol.Packet_S2C_SetFormation

Protocol.Packet_S2C_MiracleFightLoad = {
    count                   = {type = Protocol.DataType.short},
    items                   = {type = Protocol.DataType.object, length = -1, clazz='Data_MiracleInfo'},
    formation_id            = {type = Protocol.DataType.int},
    num                     = {type = Protocol.DataType.short},
    generals                = {type = Protocol.DataType.object, length = -1, clazz = 'Data_GeneralLoc'},
    fields                  = {'count','items','formation_id','num','generals'}
}
Protocol.structs[Protocol.S_2_C_MIRACLE_FIGHT_LOAD]                = Protocol.Packet_S2C_MiracleFightLoad

Protocol.Packet_S2C_MiracleFightBattle = {
    ret                     = {type = Protocol.DataType.short},
    report_id               = {type = Protocol.DataType.llstring},
    is_first                = {type = Protocol.DataType.short},
    id                      = {type = Protocol.DataType.short},
    fields                  = {'ret','report_id','is_first','id'}
}
Protocol.structs[Protocol.S_2_C_MIRACLE_FIGHT_BATTLE]                = Protocol.Packet_S2C_MiracleFightBattle

Protocol.Packet_S2C_MiracleFightHangup = {
    id                      = {type = Protocol.DataType.short},
    time_id                 = {type = Protocol.DataType.short},
    left_time               = {type = Protocol.DataType.int},
    general_id1             = {type = Protocol.DataType.int},
    general_id2             = {type = Protocol.DataType.int},
    fields                  = {'id','time_id','left_time','general_id1','general_id2'}
}
Protocol.structs[Protocol.S_2_C_MIRACLE_FIGHT_HANGUP]                = Protocol.Packet_S2C_MiracleFightHangup

Protocol.Packet_S2C_MiracleFightLevelUp = {
    id                      = {type = Protocol.DataType.short},
    lvl                     = {type = Protocol.DataType.short},
    fields                  = {'id','lvl'}
}
Protocol.structs[Protocol.S_2_C_MIRACLE_FIGHT_LEVEL_UP]                = Protocol.Packet_S2C_MiracleFightLevelUp

Protocol.Packet_S2C_AddGeneralNums = {
    generalNums                      = {type = Protocol.DataType.int},
    fields                           = {'generalNums'}
}
Protocol.structs[Protocol.S_2_C_ADD_GENERAL_NUMS]              = Protocol.Packet_S2C_AddGeneralNums

Protocol.Packet_S2C_MiracleFightDrawReward= {
    ret             = {type = Protocol.DataType.short},
    id              = {type = Protocol.DataType.short},
    count           = {type = Protocol.DataType.short},
    reward          = {type = Protocol.DataType.object, length = -1, clazz='Packet_Data_RewardType'},
    fields          = {'ret','id','count','reward'}
}
Protocol.structs[Protocol.S_2_C_MIRACLE_FIGHT_DRAW_REWARD]   = Protocol.Packet_S2C_MiracleFightDrawReward

Protocol.Packet_S2C_GeneralCompose = {
    ret             = {type = Protocol.DataType.short},
    temp_id         = {type = Protocol.DataType.int},
    info            = {type = Protocol.DataType.object, length = 1, clazz='Data_SGeneralInfo'},
    fields          = {'ret', 'temp_id', 'info'}
}
Protocol.structs[Protocol.S_2_C_GENERAL_COMPOSE]             = Protocol.Packet_S2C_GeneralCompose

Protocol.Data_Piece_Info = {
    id             = {type = Protocol.DataType.int},
    num            = {type = Protocol.DataType.int},
    fields         = {'id', 'num'}
}

Protocol.Packet_S2C_GeneralPieceNum = {
    count           = {type = Protocol.DataType.short},
    pieces          = {type = Protocol.DataType.object, length = -1, clazz='Data_Piece_Info'},
    fields          = {'count', 'pieces'}
}
Protocol.structs[Protocol.S_2_C_GENERAL_PIECE_NUM]           = Protocol.Packet_S2C_GeneralPieceNum

Protocol.Data_GeneralSoldier = {
    general_id       = {type = Protocol.DataType.int},
    cur_soldier_num  = {type = Protocol.DataType.int},
    fields           = {'general_id','cur_soldier_num'}
}

Protocol.Packet_S2C_MiracleFightLoad = {
    role_soldier_num = {type = Protocol.DataType.int},
    count            = {type = Protocol.DataType.short},
    general          = {type = Protocol.DataType.object, length = -1, clazz='Data_GeneralSoldier'},
    fields           = {'role_soldier_num','count','general'}
}
Protocol.structs[Protocol.S_2_C_UPDATE_GENERAL_SOLDIER]                = Protocol.Packet_S2C_MiracleFightLoad

Protocol.Packet_C2S_IllustrationDraw = {
    ill_id           = {type = Protocol.DataType.short},
    fields           = {'ill_id'}
}
Protocol.structs[Protocol.C_2_S_ILLUSTRATION_DRAW]                = Protocol.Packet_C2S_IllustrationDraw

Protocol.Packet_S2C_IllustrationDraw = {
    ill_id           = {type = Protocol.DataType.short},
    fields           = {'ill_id'}
}
Protocol.structs[Protocol.S_2_C_ILLUSTRATION_DRAW]                = Protocol.Packet_S2C_IllustrationDraw

Protocol.Packet_C2S_IllustrationActiveGrowth = {
    ill_id          = {type = Protocol.DataType.short},
    growth_id       = {type = Protocol.DataType.short},
    fields          = {'ill_id','growth_id'}
}
Protocol.structs[Protocol.C_2_S_ILLUSTRATION_ACTIVE_GROWTH]                = Protocol.Packet_C2S_IllustrationActiveGrowth

Protocol.Packet_S2C_IllustrationActiveGrowth = {
    ill_id          = {type = Protocol.DataType.short},
    growth_id       = {type = Protocol.DataType.short},
    fields          = {'ill_id','growth_id'}
}
Protocol.structs[Protocol.S_2_C_ILLUSTRATION_ACTIVE_GROWTH]                = Protocol.Packet_S2C_IllustrationActiveGrowth

Protocol.Packet_S2C_MiracleFightLoad = {
    general_id = {type = Protocol.DataType.int},
    count      = {type = Protocol.DataType.short},
    growth     = {type = Protocol.DataType.object, length = -1, clazz='Data_IllustrationGrowth'},
    fields     = {'general_id','count','growth'}
}
Protocol.structs[Protocol.S_2_C_ILLUSTRATION_NEW_GROWTH]                = Protocol.Packet_S2C_MiracleFightLoad

Protocol.Data_TireUpdate = {
    level  = {type = Protocol.DataType.int},
    exp    = {type = Protocol.DataType.int},
    fields = {'level','exp'}
}

Protocol.Data_GeneralIOfficer = {
    general_id    = {type = Protocol.DataType.int},
    tired         = {type = Protocol.DataType.int},
    internal_attr = {type = Protocol.DataType.object, length = Protocol.MAX_OFFICER_LEN, clazz = 'Data_TireUpdate'},
    fields        = {'general_id','tired','internal_attr'}
}

Protocol.Packet_S2C_UpdateGeneralInternal = {
    count   = {type = Protocol.DataType.short},
    general = {type = Protocol.DataType.object, length = -1, clazz = 'Data_GeneralIOfficer'},
    fields  = {'count','general'}
}
Protocol.structs[Protocol.S_2_C_UPDATE_GENERAL_INTERNAL]                = Protocol.Packet_S2C_UpdateGeneralInternal

Protocol.Packet_C2S_GeneralClearTired = {
    general_id = {type = Protocol.DataType.int},
    ident      = {type = Protocol.DataType.short},
    num        = {type = Protocol.DataType.short},
    fields     = {'general_id','ident','num'}
}
Protocol.structs[Protocol.C_2_S_GENERAL_CLEAR_TIRED]                = Protocol.Packet_C2S_GeneralClearTired

Protocol.Packet_S2C_GeneralClearTired = {
    general_id = {type = Protocol.DataType.int},
    ident      = {type = Protocol.DataType.short},
    num        = {type = Protocol.DataType.short},
    tired      = {type = Protocol.DataType.int},
    fields     = {'general_id','ident','num','tired'}
}
Protocol.structs[Protocol.S_2_C_GENERAL_CLEAR_TIRED]                = Protocol.Packet_S2C_GeneralClearTired

Protocol.Packet_C2S_BuyTiredMaterial = {
    ident  = {type = Protocol.DataType.short},
    num    = {type = Protocol.DataType.short},
    fields = {'ident','num'}
}
Protocol.structs[Protocol.C_2_S_BUY_TIRED_MATERIAL]                = Protocol.Packet_C2S_BuyTiredMaterial

Protocol.Packet_S2C_BuyTiredMaterial = {
    ident  = {type = Protocol.DataType.short},
    num    = {type = Protocol.DataType.short},
    fields = {'ident','num'}
}
Protocol.structs[Protocol.S_2_C_BUY_TIRED_MATERIAL]                = Protocol.Packet_S2C_BuyTiredMaterial

Protocol.Packet_S2C_GetNewGeneral = {
    count  = {type = Protocol.DataType.short},
    info   = {type = Protocol.DataType.object, length = -1, clazz = 'Data_SGeneralInfo' },
    fields = {'count', 'info'}
}
Protocol.structs[Protocol.S_2_C_GET_NEW_GENERAL]                    = Protocol.Packet_S2C_GetNewGeneral
