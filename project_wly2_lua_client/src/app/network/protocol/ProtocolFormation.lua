local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_FORMATION_INFO                   = Protocol.C_2_S_FORMATION_BASE + 0
Protocol.C_2_S_FORMATION_GENARAL_BATTLE         = Protocol.C_2_S_FORMATION_BASE + 1
Protocol.C_2_S_FORMATION_REMOVEGENARAL          = Protocol.C_2_S_FORMATION_BASE + 2
Protocol.C_2_S_SET_DEFAULTFORMATION             = Protocol.C_2_S_FORMATION_BASE + 3
Protocol.C_2_S_REINFORCED_SOLDIER               = Protocol.C_2_S_FORMATION_BASE + 4
Protocol.C_2_S_REINFORCED_SOLDIER_INFO          = Protocol.C_2_S_FORMATION_BASE + 5
Protocol.C_2_S_LOAD_ALL_BOSOM_FRIEND_BATTLE     = Protocol.C_2_S_FORMATION_BASE + 6
Protocol.C_2_S_BOSOM_FRIEND_BATTLE              = Protocol.C_2_S_FORMATION_BASE + 7
Protocol.C_2_S_AUTO_BOSOM_FRIEND_BATTLE         = Protocol.C_2_S_FORMATION_BASE + 8
Protocol.C_2_S_REBUILD_GENERAL                  = Protocol.C_2_S_FORMATION_BASE + 9
Protocol.C_2_S_REBUILD_GENERAL_INFO             = Protocol.C_2_S_FORMATION_BASE + 10
Protocol.C_2_S_GENERAL_REINFORCED_SOLDIER       = Protocol.C_2_S_FORMATION_BASE + 11
Protocol.C_2_S_GENERAL_BATTLE_DEMO              = Protocol.C_2_S_FORMATION_BASE + 12
Protocol.C_2_S_GENERAL_SKILL_LEVEL_UP           = Protocol.C_2_S_FORMATION_BASE + 13
Protocol.C_2_S_ATTACK_MUTI_NPC_REWARD           = Protocol.C_2_S_FORMATION_BASE + 15
Protocol.C_2_S_SWORN_CONDITION_INFO             = Protocol.C_2_S_FORMATION_BASE + 17
Protocol.C_2_S_SUDDEN_FIGHT_ONE_SKY             = Protocol.C_2_S_FORMATION_BASE + 19
Protocol.C_2_S_FORMATION_TOP                    = Protocol.C_2_S_FORMATION_BASE + 20

Protocol.S_2_C_ALL_FORMATION_INFOS              = Protocol.S_2_C_FORMATION_BASE + 0
Protocol.S_2_C_FORMATION_GENARAL_CHANGE_RES     = Protocol.S_2_C_FORMATION_BASE + 1
Protocol.S_2_C_SET_DEFAULTFORMATION_RES         = Protocol.S_2_C_FORMATION_BASE + 2
Protocol.S_2_C_BATTLE_REPORT                    = Protocol.S_2_C_FORMATION_BASE + 3
Protocol.S_2_C_MUTI_BATTLE_REP                  = Protocol.S_2_C_FORMATION_BASE + 4
Protocol.S_2_C_MUTI_BATTLE_EXCHANGE_POS_REP     = Protocol.S_2_C_FORMATION_BASE + 5
Protocol.S_2_C_MUTIL_BATTLE_INSPIRE_REP         = Protocol.S_2_C_FORMATION_BASE + 6
Protocol.S_2_C_BOSOM_FRIEND_OlD_BATTLE          = Protocol.S_2_C_FORMATION_BASE + 7
Protocol.S_2_C_MUTIL_BATTLER_PLAYER_CHANGE      = Protocol.S_2_C_FORMATION_BASE + 8
Protocol.S_2_C_MUTIL_BATTLER_PVP_ATTACKER_DATA  = Protocol.S_2_C_FORMATION_BASE + 9
Protocol.S_2_C_MUTIL_BATTLER_PVP_ADD_REP        = Protocol.S_2_C_FORMATION_BASE + 10
Protocol.S_2_C_MUTIL_BATTLER_PVE_LIST           = Protocol.S_2_C_FORMATION_BASE + 11
Protocol.S_2_C_MUTIL_BATTLER_PVE_REMOVE         = Protocol.S_2_C_FORMATION_BASE + 12
Protocol.S_2_C_MUTIL_BATTLER_PVE_PLAYERS_CHANGE = Protocol.S_2_C_FORMATION_BASE + 13
Protocol.S_2_C_MUTIL_BATTLE_REMOVE_PLAYER_REP   = Protocol.S_2_C_FORMATION_BASE + 14
Protocol.S_2_C_MUTIL_BATTLE_PVE_ADD_REP         = Protocol.S_2_C_FORMATION_BASE + 15
Protocol.S_2_C_BATTLE_RES                       = Protocol.S_2_C_FORMATION_BASE + 16
Protocol.S_2_C_BATTLE_FAILED                    = Protocol.S_2_C_FORMATION_BASE + 17
Protocol.S_2_C_MUTI_BATTLE_APPLY_RES            = Protocol.S_2_C_FORMATION_BASE + 18
Protocol.S_2_C_BATTLE_DROPED_INFO               = Protocol.S_2_C_FORMATION_BASE + 19
Protocol.S_2_C_FORMATION_TOP                    = Protocol.S_2_C_FORMATION_BASE + 20
Protocol.S_2_C_BOSOM_FRIEND_BATTLE              = Protocol.S_2_C_FORMATION_BASE + 21

Protocol.Packet_C2S_FormationGenaralBattle = {
    --C_2_S_FORMATION_GENARAL_BATTLE
    formation_id      = {type = Protocol.DataType.int},
    genaral_battle_id = {type = Protocol.DataType.int},
    formation_pos     = {type = Protocol.DataType.char},
    fields            = {'formation_id','genaral_battle_id','formation_pos'}
}
Protocol.structs[Protocol.C_2_S_FORMATION_GENARAL_BATTLE]  = Protocol.Packet_C2S_FormationGenaralBattle

Protocol.Packet_C2S_FormationRemoveGenaral = {
    --C_2_S_FORMATION_REMOVEGENARAL
    formation_id       = {type = Protocol.DataType.uint},
    genaral_battle_id  = {type = Protocol.DataType.uint},
    replace_genaral_id = {type = Protocol.DataType.uint},
    fields             = {'formation_id','genaral_battle_id','replace_genaral_id'}
}
Protocol.structs[Protocol.C_2_S_FORMATION_REMOVEGENARAL] = Protocol.Packet_C2S_FormationRemoveGenaral

Protocol.Packet_C2S_SetDafaultFormation = {
    --C_2_S_SET_DEFAULTFORMATION
    formation_id = {type = Protocol.DataType.uint},
    fields       = {'formation_id'}
}
Protocol.structs[Protocol.C_2_S_SET_DEFAULTFORMATION] = Protocol.Packet_C2S_SetDafaultFormation

Protocol.Packet_C2S_ReinforcedSoldier = {
    --C_2_S_REINFORCED_SOLDIER
    generalId = {type = Protocol.DataType.int},
    soldierId = {type = Protocol.DataType.int},
    fields    = {'generalId','soldierId'}
}
Protocol.structs[Protocol.C_2_S_REINFORCED_SOLDIER] = Protocol.Packet_C2S_ReinforcedSoldier

Protocol.Packet_C2S_ReinforcedSoldierInfo = {
    --C_2_S_REINFORCED_SOLDIER_INFO
    generalId = {type = Protocol.DataType.int},
    fields    = {'generalId'}
}
Protocol.structs[Protocol.C_2_S_REINFORCED_SOLDIER_INFO]  = Protocol.Packet_C2S_ReinforcedSoldierInfo

Protocol.Data_BosomFriendBattle = {
    pos       = {type = Protocol.DataType.short},
    bosom_id  = {type = Protocol.DataType.int},
    fields    = {'pos','bosom_id'}
}

Protocol.Packet_C2S_BosomFriendBattle = {
    --C_2_S_BOSOM_FRIEND_BATTLE
    formation_id       = {type = Protocol.DataType.int},
    count              = {type = Protocol.DataType.short},
    bosom_formation    = {type = Protocol.DataType.object, length = -1, clazz='Data_BosomFriendBattle'},
    fields             = {'formation_id','count','bosom_formation'}
}
Protocol.structs[Protocol.C_2_S_BOSOM_FRIEND_BATTLE]  = Protocol.Packet_C2S_BosomFriendBattle

Protocol.Packet_C2S_AutoBosomFriendBattle = {
    --C_2_S_AUTO_BOSOM_FRIEND_BATTLE
    formation_id = {type = Protocol.DataType.int},
    fields       = {'formation_id'}
}
Protocol.structs[Protocol.C_2_S_AUTO_BOSOM_FRIEND_BATTLE]  = Protocol.Packet_C2S_AutoBosomFriendBattle

Protocol.Packet_C2S_RebuildGeneral = {
    --C_2_S_REBUILD_GENERAL
    generalId = {type = Protocol.DataType.int},
    fields    = {'generalId'}
}
Protocol.structs[Protocol.C_2_S_REBUILD_GENERAL]  = Protocol.Packet_C2S_RebuildGeneral

Protocol.Packet_C2S_GeneralReinforcedSoldier = {
    -- C_2_S_GENERAL_REINFORCED_SOLDIER
    generalId = {type = Protocol.DataType.int},
    fields    = {'generalId'}
}
Protocol.structs[Protocol.C_2_S_GENERAL_REINFORCED_SOLDIER]  = Protocol.Packet_C2S_GeneralReinforcedSoldier

Protocol.Packet_C2S_GeneralBattleDemo = {
    --C_2_S_GENERAL_BATTLE_DEMO
    generalId = {type = Protocol.DataType.int},
    fields    = {'generalId'}
}
Protocol.structs[Protocol.C_2_S_GENERAL_BATTLE_DEMO]  = Protocol.Packet_C2S_GeneralBattleDemo

Protocol.Packet_C2S_GeneralSkillLevelUp = {
    --C_2_S_GENERAL_SKILL_LEVEL_UP
    generalId = {type = Protocol.DataType.int},
    isSpec    = {type = Protocol.DataType.char},
    fields    = {'generalId','isSpec'}
}
Protocol.structs[Protocol.C_2_S_GENERAL_SKILL_LEVEL_UP]  = Protocol.Packet_C2S_GeneralSkillLevelUp

Protocol.Packet_C2S_SwornConditionInfo = {
    --C_2_S_SWORN_CONDITION_INFO
    generalId = {type = Protocol.DataType.int},
    fields    = {'generalId'}
}
Protocol.structs[Protocol.C_2_S_SWORN_CONDITION_INFO]  = Protocol.Packet_C2S_SwornConditionInfo

--C_2_S_SUDDEN_FIGHT_ONE_SKY
Protocol.Packet_C2S_SuddenFightOneKey = {
    general_id    = {type = Protocol.DataType.int},
    transferTimes = {type = Protocol.DataType.int},
    fields        = {'general_id','transferTimes'}
}
Protocol.structs[Protocol.C_2_S_SUDDEN_FIGHT_ONE_SKY]  = Protocol.Packet_C2S_SuddenFightOneKey

Protocol.Data_FormationGenaralLoc  = {
    index       = {type = Protocol.DataType.short}, --阵型中的索引
    bosom_id    = {type = Protocol.DataType.int},
    general_id  = {type = Protocol.DataType.int},     --武将Id
    fields      = {'index','bosom_id','general_id'}
}

Protocol.Data_Formation_Info = {
    formation_id  = {type = Protocol.DataType.short},    --阵型id
    lvl           = {type = Protocol.DataType.short},  --阵型等级
    general_nums  = {type = Protocol.DataType.short},  --阵型中的武将数量
    general_loc   = {type = Protocol.DataType.object, length = -1, clazz='Data_FormationGenaralLoc'},
    fields        = {'formation_id','lvl','general_nums','general_loc'}
}

Protocol.Packet_S2C_AllFormationInfo = {
    --S_2_C_ALL_FORMATION_INFOS
    default_id = {type = Protocol.DataType.short},
    counts     = {type = Protocol.DataType.short},
    formations = {type = Protocol.DataType.object, length = -1, clazz='Data_Formation_Info'},
    fields     = {'default_id','counts','formations'}
}
Protocol.structs[Protocol.S_2_C_ALL_FORMATION_INFOS]  = Protocol.Packet_S2C_AllFormationInfo

Protocol.Packet_S2C_FormationGenaralChangeRes = {
    --S_2_C_FORMATION_GENARAL_CHANGE_RES
    formation_id         = {type = Protocol.DataType.int},
    general_id           = {type = Protocol.DataType.int},
    formation_pos        = {type = Protocol.DataType.char},
    old_general_id       = {type = Protocol.DataType.int},
    old_pos              = {type = Protocol.DataType.char},
    fields               = {'formation_id','general_id','formation_pos','old_general_id','old_pos'}
}
Protocol.structs[Protocol.S_2_C_FORMATION_GENARAL_CHANGE_RES]  = Protocol.Packet_S2C_FormationGenaralChangeRes

Protocol.Packet_S2C_SetDefaultFormationRes = {
    --S_2_C_SET_DEFAULTFORMATION_RES
    res        = {type = Protocol.DataType.char},
    formation_id = {type = Protocol.DataType.uint},
    fields     = {'res','formation_id'}
}
Protocol.structs[Protocol.S_2_C_SET_DEFAULTFORMATION_RES]  = Protocol.Packet_S2C_SetDefaultFormationRes

Protocol.Packet_S2C_BattleReport = {
    --S_2_C_BATTLE_REPORT
    len           = {type = Protocol.DataType.short},
    battle_report = {type = Protocol.DataType.char, length = -1},
    fields        = {'len','battle_report'}
}
Protocol.structs[Protocol.S_2_C_BATTLE_REPORT]  = Protocol.Packet_S2C_BattleReport

Protocol.Packet_S2C_MutiBattleRep = {
    --S_2_C_MUTI_BATTLE_REP
    battle_id = {type = Protocol.DataType.uint},
    fields    = {'battle_id'}
}
Protocol.structs[Protocol.S_2_C_MUTI_BATTLE_REP]  = Protocol.Packet_S2C_MutiBattleRep

Protocol.Packet_S2C_MutiBattleExchanePos = {
    --S_2_C_MUTI_BATTLE_EXCHANGE_POS_REP
    battle_id = {type = Protocol.DataType.uint},
    pos       = {type = Protocol.DataType.char},
    dst_pos   = {type = Protocol.DataType.char},
    fields    = {'battle_id','pos','dst_pos'}
}
Protocol.structs[Protocol.S_2_C_MUTI_BATTLE_EXCHANGE_POS_REP]  = Protocol.Packet_S2C_MutiBattleExchanePos

Protocol.Packet_S2C_MutiBattleInspire = {
    --S_2_C_MUTIL_BATTLE_INSPIRE_REP
    res       = {type = Protocol.DataType.char},
    buff_type = {type = Protocol.DataType.char},
    cool_time = {type = Protocol.DataType.uint},
    fields    = {'res','buff_type','cool_time'}
}
Protocol.structs[Protocol.S_2_C_MUTIL_BATTLE_INSPIRE_REP]  = Protocol.Packet_S2C_MutiBattleInspire

Protocol.Data_CropsBattle = {
    battle_id          = {type = Protocol.DataType.uint},
    year               = {type = Protocol.DataType.uint},
    season             = {type = Protocol.DataType.char},
    hour               = {type = Protocol.DataType.char},
    minite             = {type = Protocol.DataType.char},
    attack_crops_id    = {type = Protocol.DataType.uint},
    defence_crops_id   = {type = Protocol.DataType.uint},
    attack_corps_len   = {type = Protocol.DataType.short},
    attack_corps_name  = {type = Protocol.DataType.char, length = Protocol.MAX_CROPS_NAME_LEN},
    defence_corps_len  = {type = Protocol.DataType.short},
    defence_corps_name = {type = Protocol.DataType.char, length = Protocol.MAX_CROPS_NAME_LEN},
    fields             = {'battle_id','year','season','hour','minite','attack_crops_id','defence_crops_id','attack_corps_len','attack_corps_name','defence_corps_len','defence_corps_name'}
}

Protocol.Data_S2C_BosomFriendBattle = {
    pos                = {type = Protocol.DataType.short},
    bosom_id           = {type = Protocol.DataType.int},
    fields             = {'pos','bosom_id'}
}

Protocol.Packet_S2C_BosomFriendBattle = {
    --S_2_C_BOSOM_FRIEND_BATTLE
    ret                = {type = Protocol.DataType.short},
    formation_id       = {type = Protocol.DataType.int},
    count              = {type = Protocol.DataType.short},
    bosom_formation    = {type = Protocol.DataType.object, length = -1, clazz = 'Data_S2C_BosomFriendBattle'},
    fields             = {'ret','formation_id','count','bosom_formation'}
}
Protocol.structs[Protocol.S_2_C_BOSOM_FRIEND_BATTLE]  = Protocol.Packet_S2C_BosomFriendBattle

Protocol.Data_MutiBattlerAttackerData = {
    attack_name_len = {type = Protocol.DataType.short},
    attack_name     = {type = Protocol.DataType.char, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    attack_lvl      = {type = Protocol.DataType.char},
    defence_lvl     = {type = Protocol.DataType.char},
    fields          = {'attack_name_len','attack_name','attack_lvl','defence_lvl'}
}

Protocol.Packet_S2C_MutiBattleChage = {
    --S_2_C_MUTIL_BATTLER_PLAYER_CHANGE
    battleType    = {type = Protocol.DataType.char},
    op            = {type = Protocol.DataType.char},
    attacker      = {type = Protocol.DataType.char},
    attacker_data = {type = Protocol.DataType.object, clazz='Data_MutiBattlerAttackerData'},
    fields        = {'battleType','op','attacker','attacker_data'}
}
Protocol.structs[Protocol.S_2_C_MUTIL_BATTLER_PLAYER_CHANGE] = Protocol.Packet_S2C_MutiBattleChage

Protocol.Packet_S2C_MutiBattlerPVPAttackerData = {
    --S_2_C_MUTIL_BATTLER_PVP_ATTACKER_DATA
    battleType    = {type = Protocol.DataType.char},
    attacker      = {type = Protocol.DataType.char},
    counts        = {type = Protocol.DataType.char},
    attacker_data = {type = Protocol.DataType.object, length = -1, clazz='Data_MutiBattlerAttackerData'},
    fields        = {'battleType','attacker','counts','attacker_data'}
}
Protocol.structs[Protocol.S_2_C_MUTIL_BATTLER_PVP_ATTACKER_DATA]  = Protocol.Packet_S2C_MutiBattlerPVPAttackerData

Protocol.Packet_S2C_MutiBattlerPVPAddRep = {
    --S_2_C_MUTIL_BATTLER_PVP_ADD_REP
    res        = {type = Protocol.DataType.char},
    battle_id  = {type = Protocol.DataType.uint},
    buff_type  = {type = Protocol.DataType.char, length = 4},
    attack_lvl = {type = Protocol.DataType.char},
    def_lvl    = {type = Protocol.DataType.char},
    cool_time  = {type = Protocol.DataType.uint},
    deltaTime  = {type = Protocol.DataType.uint},
    fields     = {'res','battle_id','buff_type','attack_lvl','def_lvl','cool_time','deltaTime'}
}
Protocol.structs[Protocol.S_2_C_MUTIL_BATTLER_PVP_ADD_REP]  = Protocol.Packet_S2C_MutiBattlerPVPAddRep

Protocol.MutiBattlePVEInfo  = {
    battler_id      = {type = Protocol.DataType.uint},
    lvl             = {type = Protocol.DataType.short},
    attack_name_len = {type = Protocol.DataType.short},
    attack_name     = {type = Protocol.DataType.char, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    lvl_limit       = {type = Protocol.DataType.short},
    country_limit   = {type = Protocol.DataType.char},
    corps_id        = {type = Protocol.DataType.uint},
    players_counts  = {type = Protocol.DataType.char},
    fields          = {'battler_id','lvl','attack_name_len','attack_name','lvl_limit','country_limit','corps_id','players_counts'}
}

Protocol.Packet_S2C_BattleRes = {
    battle_type         = {type = Protocol.DataType.char},
    battle_report_name  = {type = Protocol.DataType.llstring},
    battle_cool_down    = {type = Protocol.DataType.uint},
    serverIdLen         = {type = Protocol.DataType.ushort},
    serverId            = {type = Protocol.DataType.string, length = -1},
    fields              = {'battle_type', 'battle_report_name', 'battle_cool_down', 'serverIdLen', 'serverId'}
}
Protocol.structs[Protocol.S_2_C_BATTLE_RES] = Protocol.Packet_S2C_BattleRes

Protocol.Packet_S2C_BattleDropedInfo = {
    --S_2_C_BATTLE_DROPED_INFO
    winType      = {type = Protocol.DataType.int},
    geste        = {type = Protocol.DataType.int},
    itemId       = {type = Protocol.DataType.int},
    jadeType     = {type = Protocol.DataType.int},
    materialId   = {type = Protocol.DataType.int},
    skillCardId  = {type = Protocol.DataType.int},
    skillCardNum = {type = Protocol.DataType.int},
    fields       = {'winType','geste','itemId','jadeType','materialId','skillCardId','skillCardNum'}
}
Protocol.structs[Protocol.S_2_C_BATTLE_DROPED_INFO]  = Protocol.Packet_S2C_BattleDropedInfo

