local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_CAMPAIGN_INFO_LOAD            = Protocol.C_2_S_CAMPAIGN_BASE + 1
Protocol.C_2_S_CAMPAIGN_CHALLENGE            = Protocol.C_2_S_CAMPAIGN_BASE + 2
Protocol.C_2_S_CAMPAIGN_EXPLORE              = Protocol.C_2_S_CAMPAIGN_BASE + 3
Protocol.C_2_S_CAMPAIGN_BATTLE               = Protocol.C_2_S_CAMPAIGN_BASE + 4
Protocol.C_2_S_CAMPAIGN_MOVE                 = Protocol.C_2_S_CAMPAIGN_BASE + 5
Protocol.C_2_S_CAMPAIGN_ROUND_END            = Protocol.C_2_S_CAMPAIGN_BASE + 6
Protocol.C_2_S_CAMPAIGN_GENERAL_LOAD         = Protocol.C_2_S_CAMPAIGN_BASE + 7
Protocol.C_2_S_CAMPAIGN_RESOURCE_LOAD        = Protocol.C_2_S_CAMPAIGN_BASE + 8
Protocol.C_2_S_CAMPAIGN_CITY_LOAD            = Protocol.C_2_S_CAMPAIGN_BASE + 9
Protocol.C_2_S_CAMPAIGN_ACTION_LOAD          = Protocol.C_2_S_CAMPAIGN_BASE + 10
Protocol.C_2_S_CAMPAIGN_BATTLE_RESULT_LOAD   = Protocol.C_2_S_CAMPAIGN_BASE + 11
Protocol.C_2_S_CAMPAIGN_DEFEND_BATTLE        = Protocol.C_2_S_CAMPAIGN_BASE + 12
Protocol.C_2_S_CAMPAIGN_SPY                  = Protocol.C_2_S_CAMPAIGN_BASE + 13
Protocol.C_2_S_CAMPAIGN_RECRUIT_CAPTURE      = Protocol.C_2_S_CAMPAIGN_BASE + 14
Protocol.C_2_S_CAMPAIGN_GENERAL_LEVEL_UP     = Protocol.C_2_S_CAMPAIGN_BASE + 15
Protocol.C_2_S_CAMPAIGN_SURRENDER            = Protocol.C_2_S_CAMPAIGN_BASE + 16
Protocol.C_2_S_CAMPAIGN_SOLDIER_SUPPLY       = Protocol.C_2_S_CAMPAIGN_BASE + 17
Protocol.C_2_S_CAMPAIGN_WIPE                 = Protocol.C_2_S_CAMPAIGN_BASE + 18

Protocol.S_2_C_CAMPAIGN_INFO_LOAD            = Protocol.S_2_C_CAMPAIGN_BASE + 1
Protocol.S_2_C_CAMPAIGN_CHALLENGE            = Protocol.S_2_C_CAMPAIGN_BASE + 2
Protocol.S_2_C_CAMPAIGN_EXPLORE              = Protocol.S_2_C_CAMPAIGN_BASE + 3
Protocol.S_2_C_CAMPAIGN_BATTLE               = Protocol.S_2_C_CAMPAIGN_BASE + 4
Protocol.S_2_C_CAMPAIGN_MOVE                 = Protocol.S_2_C_CAMPAIGN_BASE + 5
Protocol.S_2_C_CAMPAIGN_ROUND_END            = Protocol.S_2_C_CAMPAIGN_BASE + 6
Protocol.S_2_C_CAMPAIGN_GENERAL_LOAD         = Protocol.S_2_C_CAMPAIGN_BASE + 7
Protocol.S_2_C_CAMPAIGN_RESOURCE_LOAD        = Protocol.S_2_C_CAMPAIGN_BASE + 8
Protocol.S_2_C_CAMPAIGN_CITY_LOAD            = Protocol.S_2_C_CAMPAIGN_BASE + 9
Protocol.S_2_C_CAMPAIGN_ACTION_LOAD          = Protocol.S_2_C_CAMPAIGN_BASE + 10
Protocol.S_2_C_CAMPAIGN_EXPLORE_NOTIFY       = Protocol.S_2_C_CAMPAIGN_BASE + 11
Protocol.S_2_C_CAMPAIGN_MOVE_NOTIFY          = Protocol.S_2_C_CAMPAIGN_BASE + 12
Protocol.S_2_C_CAMPAIGN_CITY_UPDATE          = Protocol.S_2_C_CAMPAIGN_BASE + 13
Protocol.S_2_C_CAMPAIGN_BATTLE_RESULT_LOAD   = Protocol.S_2_C_CAMPAIGN_BASE + 14
Protocol.S_2_C_CAMPAIGN_DEFEND_BATTLE        = Protocol.S_2_C_CAMPAIGN_BASE + 15
Protocol.S_2_C_CAMPAIGN_ADD_GENERAL          = Protocol.S_2_C_CAMPAIGN_BASE + 17
Protocol.S_2_C_CAMPAIGN_RETREAT_NOTIFY       = Protocol.S_2_C_CAMPAIGN_BASE + 19
Protocol.S_2_C_CAMPAIGN_END                  = Protocol.S_2_C_CAMPAIGN_BASE + 20
Protocol.S_2_C_CAMPAIGN_PLAYER_BATTLE_NOTIFY = Protocol.S_2_C_CAMPAIGN_BASE + 21
Protocol.S_2_C_CAMPAIGN_SPY                  = Protocol.S_2_C_CAMPAIGN_BASE + 22
Protocol.S_2_C_CAMPAIGN_RECRUIT_CAPTURE      = Protocol.S_2_C_CAMPAIGN_BASE + 23
Protocol.S_2_C_CAMPAIGN_GENERAL_LEVEL_UP     = Protocol.S_2_C_CAMPAIGN_BASE + 24
Protocol.S_2_C_CAMPAIGN_SOLDIER_SUPPLY       = Protocol.S_2_C_CAMPAIGN_BASE + 25
Protocol.S_2_C_CAMPAIGN_WIPE                 = Protocol.S_2_C_CAMPAIGN_BASE + 26
Protocol.S_2_C_CAMPAIGN_UPDATE_CTIY_SOLDIER  = Protocol.S_2_C_CAMPAIGN_BASE + 27

Protocol.Data_CampaignData = {
    campaign_id = {type = Protocol.DataType.int},
    score       = {type = Protocol.DataType.short},
    fields      = {'campaign_id','score'}
}

Protocol.Packet_S2C_CampaignLoad = {
    campaign_id   = {type = Protocol.DataType.int},
    count         = {type = Protocol.DataType.short},
    campaign_list = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CampaignData'},
    fields        = {'campaign_id','count','campaign_list'}
}
Protocol.structs[Protocol.S_2_C_CAMPAIGN_INFO_LOAD]   = Protocol.Packet_S2C_CampaignLoad

Protocol.Packet_S2C_CampaignGeneralLoad = {
    count    = {type = Protocol.DataType.short},
    generals = {type = Protocol.DataType.object, length = -1, clazz = 'Data_SGeneralInfo'},
    fields   = {'count','generals'}
}
Protocol.structs[Protocol.S_2_C_CAMPAIGN_GENERAL_LOAD]   = Protocol.Packet_S2C_CampaignGeneralLoad

Protocol.Data_CampaignRes = {
    type   = {type = Protocol.DataType.int},
    value  = {type = Protocol.DataType.longlong},
    fields = {'type','value'}
}

Protocol.Packet_S2C_CampaignResourceLoad = {
    count     = {type = Protocol.DataType.short},
    resources = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CampaignRes'},
    fields    = {'count','resources'}
}
Protocol.structs[Protocol.S_2_C_CAMPAIGN_RESOURCE_LOAD]   = Protocol.Packet_S2C_CampaignResourceLoad

Protocol.Data_CampaignResLeft = {
    id     = {type = Protocol.DataType.int},
    num    = {type = Protocol.DataType.int},
    fields = {'id','num'}
}

Protocol.Data_CampaignCapture = {
    general_id = {type = Protocol.DataType.int},
    power      = {type = Protocol.DataType.int},
    fields     = {'general_id','power'}
}

Protocol.Data_CampaignCity = {
    city_id         = {type = Protocol.DataType.int},
    power           = {type = Protocol.DataType.int},
    soldier         = {type = Protocol.DataType.int},
    count1          = {type = Protocol.DataType.short},
    out_general     = {type = Protocol.DataType.int, length = -1},
    count2          = {type = Protocol.DataType.short},
    capture_general = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CampaignCapture'},
    count3          = {type = Protocol.DataType.short},
    generals        = {type = Protocol.DataType.int, length = -1},
    count4          = {type = Protocol.DataType.short},
    left_resource   = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CampaignResLeft'},
    count5          = {type = Protocol.DataType.short},
    troop_id        = {type = Protocol.DataType.int, length = -1},
    count6          = {type = Protocol.DataType.short},
    troops          = {type = Protocol.DataType.int, length = -1},
    fields          = {'city_id','power','soldier','count1','out_general','count2','capture_general','count3','generals','count4','left_resource','count5','troop_id','count6','troops'}
}

Protocol.Packet_S2C_CampaignCityLoad = {
    count  = {type = Protocol.DataType.short},
    cities = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CampaignCity'},
    fields = {'count','cities'}
}
Protocol.structs[Protocol.S_2_C_CAMPAIGN_CITY_LOAD]   = Protocol.Packet_S2C_CampaignCityLoad

Protocol.Data_CampaignActionExplore = {
    city_id = {type = Protocol.DataType.int},
    fields  = {'city_id'}
}

Protocol.Data_CampaignActionMove = {
    from_id  = {type = Protocol.DataType.int},
    to_id    = {type = Protocol.DataType.int},
    soldier  = {type = Protocol.DataType.int},
    count    = {type = Protocol.DataType.short},
    generals = {type = Protocol.DataType.int, length = -1},
    fields   = {'from_id','to_id','soldier','count','generals'}
}

Protocol.Data_CampaignActionGeneral = {
    general_id = {type = Protocol.DataType.int},
    pos        = {type = Protocol.DataType.short},
    fields     = {'general_id','pos'}
}

Protocol.Data_CampaignActionBattle = {
    from_id      = {type = Protocol.DataType.int},
    to_id        = {type = Protocol.DataType.int},
    formation_id = {type = Protocol.DataType.int},
    count        = {type = Protocol.DataType.short},
    generals     = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CampaignActionGeneral'},
    fields       = {'from_id','to_id','formation_id','count','generals'}
}

Protocol.Data_CampaignActionBattleCity = {
    from_city_id = {type = Protocol.DataType.int},
    to_city_id   = {type = Protocol.DataType.int},
    fields       = {'from_city_id','to_city_id'}
}

Protocol.Packet_S2C_CampaignActionLoad = {
    round          = {type = Protocol.DataType.int},
    battle_result  = {type = Protocol.DataType.short},
    count1         = {type = Protocol.DataType.short},
    explore_action = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CampaignActionExplore'},
    count          = {type = Protocol.DataType.short},
    battle_city    = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CampaignActionBattleCity'},
    fields         = {'round','battle_result','count1','explore_action','count','battle_city'}
}
Protocol.structs[Protocol.S_2_C_CAMPAIGN_ACTION_LOAD]   = Protocol.Packet_S2C_CampaignActionLoad

Protocol.Packet_C2S_CampaignChallenge = {
    campaign_id = {type = Protocol.DataType.int},
    fields      = {'campaign_id'}
}
Protocol.structs[Protocol.C_2_S_CAMPAIGN_CHALLENGE]   = Protocol.Packet_C2S_CampaignChallenge

Protocol.Packet_S2C_CampaignChallenge = {
    campaign_id = {type = Protocol.DataType.int},
    fields      = {'campaign_id'}
}
Protocol.structs[Protocol.S_2_C_CAMPAIGN_CHALLENGE]   = Protocol.Packet_S2C_CampaignChallenge

Protocol.Packet_C2S_CampaignExplore = {
    city_id = {type = Protocol.DataType.int},
    fields  = {'city_id'}
}
Protocol.structs[Protocol.C_2_S_CAMPAIGN_EXPLORE]   = Protocol.Packet_C2S_CampaignExplore

Protocol.Packet_S2C_CampaignExplore = {
    city_id = {type = Protocol.DataType.int},
    fields  = {'city_id'}
}
Protocol.structs[Protocol.S_2_C_CAMPAIGN_EXPLORE]   = Protocol.Packet_S2C_CampaignExplore

Protocol.Packet_C2S_CampaignBattle = {
    from_city_id = {type = Protocol.DataType.int},
    to_city_id   = {type = Protocol.DataType.int},
    formation_id = {type = Protocol.DataType.int},
    count        = {type = Protocol.DataType.short},
    generals     = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CampaignActionGeneral'},
    fields       = {'from_city_id','to_city_id','formation_id','count','generals'}
}
Protocol.structs[Protocol.C_2_S_CAMPAIGN_BATTLE]   = Protocol.Packet_C2S_CampaignBattle

Protocol.Packet_S2C_CampaignBattle = {
    city_id    = {type = Protocol.DataType.int},
    count      = {type = Protocol.DataType.short},
    generals   = {type = Protocol.DataType.int, length = -1},
    to_city_id = {type = Protocol.DataType.int},
    fields     = {'city_id','count','generals','to_city_id'}
}
Protocol.structs[Protocol.S_2_C_CAMPAIGN_BATTLE]   = Protocol.Packet_S2C_CampaignBattle

Protocol.Packet_C2S_CampaignMove = {
    from_city_id = {type = Protocol.DataType.int},
    to_city_id   = {type = Protocol.DataType.int},
    soldier      = {type = Protocol.DataType.int},
    count        = {type = Protocol.DataType.int},
    general_id   = {type = Protocol.DataType.int, length = -1},
    fields       = {'from_city_id','to_city_id','soldier','count','general_id'}
}
Protocol.structs[Protocol.C_2_S_CAMPAIGN_MOVE]   = Protocol.Packet_C2S_CampaignMove

Protocol.Packet_S2C_CampaignMove = {
    city_id  = {type = Protocol.DataType.int},
    soldier  = {type = Protocol.DataType.int},
    count    = {type = Protocol.DataType.short},
    generals = {type = Protocol.DataType.int, length = -1},
    fields   = {'city_id','soldier','count','generals'}
}
Protocol.structs[Protocol.S_2_C_CAMPAIGN_MOVE]   = Protocol.Packet_S2C_CampaignMove

Protocol.Packet_S2C_CampaignRoundEnd = {
    ret    = {type = Protocol.DataType.int},
    fields = {'ret'}
}
Protocol.structs[Protocol.S_2_C_CAMPAIGN_ROUND_END]   = Protocol.Packet_S2C_CampaignRoundEnd

Protocol.Data_CampaignExploreList = {
    city_id    = {type = Protocol.DataType.int},
    count      = {type = Protocol.DataType.short},
    resources  = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CampaignRes'},
    soldier    = {type = Protocol.DataType.int},
    count1     = {type = Protocol.DataType.short},
    general_id = {type = Protocol.DataType.int, length = -1},
    fields     = {'city_id','count','resources','soldier','count1','general_id'}
}

Protocol.Packet_S2C_CampaignExploreNotify = {
    count        = {type = Protocol.DataType.short},
    explore_list = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CampaignExploreList'},
    fields       = {'count','explore_list'}
}
Protocol.structs[Protocol.S_2_C_CAMPAIGN_EXPLORE_NOTIFY]   = Protocol.Packet_S2C_CampaignExploreNotify

Protocol.Data_MoveNotifyData = {
    type      = {type = Protocol.DataType.short},
    from_city = {type = Protocol.DataType.int},
    to_city   = {type = Protocol.DataType.int},
    soldier   = {type = Protocol.DataType.int},
    count     = {type = Protocol.DataType.short},
    generals  = {type = Protocol.DataType.int, length = -1},
    count1    = {type = Protocol.DataType.short},
    troop_id  = {type = Protocol.DataType.int, length = -1},
    fields    = {'type','from_city','to_city','soldier','count','generals','count1','troop_id'}
}

Protocol.Packet_S2C_CampaignMoveNotify = {
    count     = {type = Protocol.DataType.short},
    move_list = {type = Protocol.DataType.object, length = -1, clazz = 'Data_MoveNotifyData'},
    fields    = {'count','move_list'}
}
Protocol.structs[Protocol.S_2_C_CAMPAIGN_MOVE_NOTIFY]   = Protocol.Packet_S2C_CampaignMoveNotify

Protocol.Packet_S2C_CampaignCityUpdate = {
    count  = {type = Protocol.DataType.short},
    cities = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CampaignCity'},
    fields = {'count','cities'}
}
Protocol.structs[Protocol.S_2_C_CAMPAIGN_CITY_UPDATE]   = Protocol.Packet_S2C_CampaignCityUpdate

Protocol.Data_CampaignCityBattleArmyData = {
    type     = {type = Protocol.DataType.short},
    troop_id = {type = Protocol.DataType.int},
    count    = {type = Protocol.DataType.short},
    generals = {type = Protocol.DataType.int, length = -1},
    fields   = {'type','troop_id','count','generals'}
}

Protocol.Data_CampaignCityBattleList = {
    from_city = {type = Protocol.DataType.int},
    atk       = {type = Protocol.DataType.object, clazz = 'Data_CampaignCityBattleArmyData'},
    def       = {type = Protocol.DataType.object, clazz = 'Data_CampaignCityBattleArmyData'},
    result    = {type = Protocol.DataType.short},
    report    = {type = Protocol.DataType.llstring},
    fields    = {'from_city','atk','def','result','report'}
}

Protocol.Packet_S2C_CampaignBattleResultLoad = {
    attack_power = {type = Protocol.DataType.int},
    city_id      = {type = Protocol.DataType.int},
    att_win      = {type = Protocol.DataType.short},
    faild_power  = {type = Protocol.DataType.short},
    count        = {type = Protocol.DataType.short},
    battle_list  = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CampaignCityBattleList'},
    is_end       = {type = Protocol.DataType.short},
    round        = {type = Protocol.DataType.int},
    fields       = {'attack_power','city_id','att_win','faild_power','count','battle_list','is_end','round'}
}
Protocol.structs[Protocol.S_2_C_CAMPAIGN_BATTLE_RESULT_LOAD]   = Protocol.Packet_S2C_CampaignBattleResultLoad

Protocol.Data_DefendBattle = {
    formation_id = {type = Protocol.DataType.int},
    count        = {type = Protocol.DataType.short},
    generals     = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CampaignActionGeneral'},
    fields       = {'formation_id','count','generals'}
}

Protocol.Packet_C2S_CampaignDefendBattle = {
    city_id   = {type = Protocol.DataType.int},
    count     = {type = Protocol.DataType.short},
    formation = {type = Protocol.DataType.object, length = -1, clazz = 'Data_DefendBattle'},
    fields    = {'city_id','count','formation'}
}
Protocol.structs[Protocol.C_2_S_CAMPAIGN_DEFEND_BATTLE]   = Protocol.Packet_C2S_CampaignDefendBattle

Protocol.Packet_S2C_CampaignDefendBattle = {
    ret    = {type = Protocol.DataType.int},
    fields = {'ret'}
}
Protocol.structs[Protocol.S_2_C_CAMPAIGN_DEFEND_BATTLE]   = Protocol.Packet_S2C_CampaignDefendBattle

Protocol.Packet_S2C_CampaignAddGeneral = {
    count        = {type = Protocol.DataType.short},
    general_info = {type = Protocol.DataType.object, length = -1, clazz = 'Data_SGeneralInfo'},
    fields       = {'count','general_info'}
}
Protocol.structs[Protocol.S_2_C_CAMPAIGN_ADD_GENERAL]   = Protocol.Packet_S2C_CampaignAddGeneral

Protocol.Data_CampaignRetreatNotify = {
    army      = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CampaignCityBattleArmyData'},
    to_city   = {type = Protocol.DataType.int},
    from_city = {type = Protocol.DataType.int},
    fields    = {'army','to_city','from_city'}
}

Protocol.Packet_S2C_CampaignRetreatNotify = {
    count        = {type = Protocol.DataType.short},
    retreat_list = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CampaignRetreatNotify'},
    fields       = {'count','retreat_list'}
}
Protocol.structs[Protocol.S_2_C_CAMPAIGN_RETREAT_NOTIFY]   = Protocol.Packet_S2C_CampaignRoundEndNotify

Protocol.Packet_S2C_CampaignEnd = {
    campaign_id = {type = Protocol.DataType.int},
    score       = {type = Protocol.DataType.short},
    round_num   = {type = Protocol.DataType.short},
    city_num    = {type = Protocol.DataType.short},
    general_num = {type = Protocol.DataType.short},
    wipeout     = {type = Protocol.DataType.short},
    is_win      = {type = Protocol.DataType.short},
    count       = {type = Protocol.DataType.short},
    rwds        = {type = Protocol.DataType.object, length = -1, clazz = 'Packet_Data_RewardType'},
    fields      = {'campaign_id','score','round_num','city_num','general_num','wipeout','is_win','count','rwds'}
}
Protocol.structs[Protocol.S_2_C_CAMPAIGN_END]   = Protocol.Packet_S2C_CampaignEnd

Protocol.Packet_S2C_CampaignPlayerBattleNotify = {
    city_id  = {type = Protocol.DataType.int},
    count    = {type = Protocol.DataType.short},
    troop_id = {type = Protocol.DataType.int, length = -1},
    fields   = {'city_id','count','troop_id'}
}
Protocol.structs[Protocol.S_2_C_CAMPAIGN_PLAYER_BATTLE_NOTIFY]   = Protocol.Packet_S2C_CampaignPlayerBattleNotify

Protocol.Packet_C2S_CampaignSpy = {
    city_id = {type = Protocol.DataType.int},
    fields  = {'city_id'}
}
Protocol.structs[Protocol.C_2_S_CAMPAIGN_SPY]   = Protocol.Packet_C2S_CampaignSpy

Protocol.Packet_S2C_CampaignSpy = {
    city_id  = {type = Protocol.DataType.int},
    count    = {type = Protocol.DataType.short},
    troop_id = {type = Protocol.DataType.int, length = -1},
    fields   = {'city_id','count','troop_id'}
}
Protocol.structs[Protocol.S_2_C_CAMPAIGN_SPY]   = Protocol.Packet_S2C_CampaignSpy

Protocol.Packet_C2S_CampaignRecruitCapture = {
    city_id    = {type = Protocol.DataType.int},
    general_id = {type = Protocol.DataType.int},
    fields     = {'city_id','general_id'}
}
Protocol.structs[Protocol.C_2_S_CAMPAIGN_RECRUIT_CAPTURE]   = Protocol.Packet_C2S_CampaignRecruitCapture

Protocol.Packet_S2C_CampaignRecruitCapture = {
    city_id    = {type = Protocol.DataType.int},
    general_id = {type = Protocol.DataType.int},
    fields     = {'city_id','general_id'}
}
Protocol.structs[Protocol.S_2_C_CAMPAIGN_RECRUIT_CAPTURE]   = Protocol.Packet_S2C_CampaignRecruitCapture

Protocol.Packet_C2S_CampaignGeneralLevelUp = {
    general_id = {type = Protocol.DataType.int},
    level      = {type = Protocol.DataType.int},
    fields     = {'general_id','level'}
}
Protocol.structs[Protocol.C_2_S_CAMPAIGN_GENERAL_LEVEL_UP]   = Protocol.Packet_C2S_CampaignGeneralLevelUp

Protocol.Packet_S2C_CampaignGeneralLevelUp = {
    general_info = {type = Protocol.DataType.object, clazz = 'Data_SGeneralInfo'},
    fields       = {'general_info'}
}
Protocol.structs[Protocol.S_2_C_CAMPAIGN_GENERAL_LEVEL_UP]   = Protocol.Packet_S2C_CampaignGeneralLevelUp

Protocol.Data_CampaignSoldierData = {
    general_id = {type = Protocol.DataType.int},
    soldier    = {type = Protocol.DataType.int},
    fields     = {'general_id','soldier'}
}

Protocol.Packet_C2S_CampaignSoldierSupply = {
    count    = {type = Protocol.DataType.short},
    generals = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CampaignSoldierData'},
    fields   = {'count','generals'}
}
Protocol.structs[Protocol.C_2_S_CAMPAIGN_SOLDIER_SUPPLY]   = Protocol.Packet_C2S_CampaignSoldierSupply

Protocol.Data_CampaignSoldierCityData = {
    city_id = {type = Protocol.DataType.int},
    soldier = {type = Protocol.DataType.int},
    fields  = {'city_id','soldier'}
}

Protocol.Packet_S2C_CampaignGeneralLevelUp = {
    count    = {type = Protocol.DataType.short},
    generals = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CampaignSoldierData'},
    count1   = {type = Protocol.DataType.short},
    citys    = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CampaignSoldierCityData'},
    fields   = {'count','generals','count1','citys'}
}
Protocol.structs[Protocol.S_2_C_CAMPAIGN_SOLDIER_SUPPLY]   = Protocol.Packet_S2C_CampaignGeneralLevelUp

Protocol.Packet_C2S_CampaignWipe = {
    campaign_id = {type = Protocol.DataType.int},
    wipe_count  = {type = Protocol.DataType.int},
    fields      = {'campaign_id','wipe_count'}
}
Protocol.structs[Protocol.C_2_S_CAMPAIGN_WIPE]   = Protocol.Packet_C2S_CampaignWipe

Protocol.Packet_S2C_CampaignWipe = {
    campaign_id = {type = Protocol.DataType.int},
    wipe_count  = {type = Protocol.DataType.int},
    count       = {type = Protocol.DataType.short},
    rwds        = {type = Protocol.DataType.object, length = -1, clazz = 'Packet_Data_RewardType'},
    fields      = {'campaign_id','wipe_count','count','rwds'}
}
Protocol.structs[Protocol.S_2_C_CAMPAIGN_WIPE]   = Protocol.Packet_S2C_CampaignWipe

Protocol.Data_CampaignUpdateCitySoldier = {
    city_id = {type = Protocol.DataType.int},
    soldier = {type = Protocol.DataType.int},
    fields  = {'city_id','soldier'}
}

Protocol.Packet_S2C_CampaignUpdateCitySoldier = {
    count  = {type = Protocol.DataType.short},
    citys  = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CampaignUpdateCitySoldier'},
    fields = {'count','citys'}
}
Protocol.structs[Protocol.S_2_C_CAMPAIGN_UPDATE_CTIY_SOLDIER] = Protocol.Packet_S2C_CampaignUpdateCitySoldier
