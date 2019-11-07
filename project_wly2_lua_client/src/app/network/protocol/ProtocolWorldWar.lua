local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_NATION_BATTLE_ENTER                      = Protocol.C_2_S_NATION_BATTLE_BASE + 1
Protocol.C_2_S_NATION_BATTLE_CREATE_POWER               = Protocol.C_2_S_NATION_BATTLE_BASE + 2
Protocol.C_2_S_NATION_BATTLE_WOLRD_INFO                 = Protocol.C_2_S_NATION_BATTLE_BASE + 3
Protocol.C_2_S_NATION_BATTLE_MOVING_LIST                = Protocol.C_2_S_NATION_BATTLE_BASE + 4
Protocol.C_2_S_NATION_BATTLE_DO_MOVE                    = Protocol.C_2_S_NATION_BATTLE_BASE + 5
Protocol.C_2_S_NATION_BATTLE_LOAD_ARMY                  = Protocol.C_2_S_NATION_BATTLE_BASE + 6
Protocol.C_2_S_NATION_BATTLE_UPDATE_FORMATION           = Protocol.C_2_S_NATION_BATTLE_BASE + 7
Protocol.C_2_S_NATION_BATTLE_FIELD_INFO                 = Protocol.C_2_S_NATION_BATTLE_BASE + 8
Protocol.C_2_S_NATION_BATTLE_FIELD_MOVING_LIST          = Protocol.C_2_S_NATION_BATTLE_BASE + 9
Protocol.C_2_S_NATION_BATTLE_FIELD_MOVE                 = Protocol.C_2_S_NATION_BATTLE_BASE + 11
Protocol.C_2_S_NATION_BATTLE_VIEW                       = Protocol.C_2_S_NATION_BATTLE_BASE + 12
Protocol.C_2_S_NATION_BATTLE_LOAD_TITLE                 = Protocol.C_2_S_NATION_BATTLE_BASE + 13
Protocol.C_2_S_NATION_BATTLE_REPORT_LOAD                = Protocol.C_2_S_NATION_BATTLE_BASE + 14
Protocol.C_2_S_NATION_BATTLE_DEVELOP                    = Protocol.C_2_S_NATION_BATTLE_BASE + 15
Protocol.C_2_S_NATION_BATTLE_LOAD_FIRSTRANK             = Protocol.C_2_S_NATION_BATTLE_BASE + 16
Protocol.C_2_S_NATION_BATTLE_DRAW_TASK                  = Protocol.C_2_S_NATION_BATTLE_BASE + 17
Protocol.C_2_S_NATION_BATTLE_LOAD_INIT_CITY             = Protocol.C_2_S_NATION_BATTLE_BASE + 18
Protocol.C_2_S_NATION_BATTLE_MOVE_CITY                  = Protocol.C_2_S_NATION_BATTLE_BASE + 19

Protocol.S_2_C_NATION_BATTLE_ENTER                      = Protocol.S_2_C_NATION_BATTLE_BASE + 1
Protocol.S_2_C_NATION_BATTLE_CREATE_POWER               = Protocol.S_2_C_NATION_BATTLE_BASE + 2
Protocol.S_2_C_NATION_BATTLE_WORLD_INFO                 = Protocol.S_2_C_NATION_BATTLE_BASE + 3
Protocol.S_2_C_NATION_BATTLE_MOVING_LIST                = Protocol.S_2_C_NATION_BATTLE_BASE + 4
Protocol.S_2_C_NATION_BATTLE_DO_MOVE                    = Protocol.S_2_C_NATION_BATTLE_BASE + 5
Protocol.S_2_C_NATION_BATTLE_MOVE_END                   = Protocol.S_2_C_NATION_BATTLE_BASE + 6
Protocol.S_2_C_NATION_BATTLE_LOAD_ARMY                  = Protocol.S_2_C_NATION_BATTLE_BASE + 7
Protocol.S_2_C_NATION_BATTLE_UPDATE_FORMATION           = Protocol.S_2_C_NATION_BATTLE_BASE + 8
Protocol.S_2_C_NATION_BATTLE_FIELD_INFO                 = Protocol.S_2_C_NATION_BATTLE_BASE + 9
Protocol.S_2_C_NATION_BATTLE_FIELD_POINT_ARMYS          = Protocol.S_2_C_NATION_BATTLE_BASE + 10
Protocol.S_2_C_NATION_BATTLE_FIELD_MOVING_LIST          = Protocol.S_2_C_NATION_BATTLE_BASE + 11
Protocol.S_2_C_NATION_BATTLE_FIELD_MOVE                 = Protocol.S_2_C_NATION_BATTLE_BASE + 12
Protocol.S_2_C_NATION_BATTLE_FIELD_NOTIFY               = Protocol.S_2_C_NATION_BATTLE_BASE + 13
Protocol.S_2_C_NATION_BATTLE_FIELD_WALL_HP              = Protocol.S_2_C_NATION_BATTLE_BASE + 14
Protocol.S_2_C_NATION_BATTLE_FIELD_OCCUPY_NOTIFY        = Protocol.S_2_C_NATION_BATTLE_BASE + 15
Protocol.S_2_C_NATION_BATTLE_DECLARE_BATTLE             = Protocol.S_2_C_NATION_BATTLE_BASE + 16;
Protocol.S_2_C_NATION_BATTLE_START_BATTLE               = Protocol.S_2_C_NATION_BATTLE_BASE + 17;
Protocol.S_2_C_NATION_BATTLE_END_BATTLE                 = Protocol.S_2_C_NATION_BATTLE_BASE + 18;
Protocol.S_2_C_NATION_BATTLE_FIELD_MOVE_END             = Protocol.S_2_C_NATION_BATTLE_BASE + 19;
Protocol.S_2_C_NATION_BATTLE_RANK_NOTIFY                = Protocol.S_2_C_NATION_BATTLE_BASE + 20;
Protocol.S_2_C_NATION_BATTLE_LOAD_TITLE                 = Protocol.S_2_C_NATION_BATTLE_BASE + 21;
Protocol.S_2_C_NATION_BATTLE_REPORT_NOTIFY              = Protocol.S_2_C_NATION_BATTLE_BASE + 22;
Protocol.S_2_C_NATION_BATTLE_REPORT_LOAD                = Protocol.S_2_C_NATION_BATTLE_BASE + 23;
Protocol.S_2_C_NATION_BATTLE_DEVELOP                    = Protocol.S_2_C_NATION_BATTLE_BASE + 24;
Protocol.S_2_C_NATION_BATTLE_LOAD_FIRSTRANK             = Protocol.S_2_C_NATION_BATTLE_BASE + 25;
Protocol.S_2_C_NATION_BATTLE_CITY_CHANGE_NOTIFY         = Protocol.S_2_C_NATION_BATTLE_BASE + 26;
Protocol.S_2_C_NATION_BATTLE_TASK_UPDATE                = Protocol.S_2_C_NATION_BATTLE_BASE + 27;
Protocol.S_2_C_NATION_BATTLE_DRAW_TASK                  = Protocol.S_2_C_NATION_BATTLE_BASE + 28;
Protocol.S_2_C_NATION_BATTLE_LOAD_INIT_CITY             = Protocol.S_2_C_NATION_BATTLE_BASE + 29;
Protocol.S_2_C_NATION_BATTLE_FIELD_POINT_HP_UPDATE      = Protocol.S_2_C_NATION_BATTLE_BASE + 30;
Protocol.S_2_C_NATION_BATTLE_FIELD_POINT_NPC_UPDATE     = Protocol.S_2_C_NATION_BATTLE_BASE + 31;
Protocol.S_2_C_NATION_BATTLE_ARMY_ENTER_FIELD           = Protocol.S_2_C_NATION_BATTLE_BASE + 32;
Protocol.S_2_C_NATION_BATTLE_ARMY_UPDATE                = Protocol.S_2_C_NATION_BATTLE_BASE + 33;
Protocol.S_2_C_NATION_BATTLE_MOVE_CITY                  = Protocol.S_2_C_NATION_BATTLE_BASE + 34;

Protocol.Packet_S2C_NationBattleEnter = {
    city_id             = {type = Protocol.DataType.int},
    develop_count       = {type = Protocol.DataType.int},
    season_id           = {type = Protocol.DataType.int},
    season_begin_time   = {type = Protocol.DataType.int},
    count               = {type = Protocol.DataType.short},
    task_id             = {type = Protocol.DataType.short, length = -1},
    night_battle        = {type = Protocol.DataType.int},
    move_times          = {type = Protocol.DataType.int},
    fields              = {'city_id','develop_count','season_id','season_begin_time','count','task_id','night_battle','move_times'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_ENTER]          = Protocol.Packet_S2C_NationBattleEnter

Protocol.Packet_C2S_NationBattleCreatePower = {
    init_city_id = {type = Protocol.DataType.int},
    color_id     = {type = Protocol.DataType.short},
    len          = {type = Protocol.DataType.short},
    power_name   = {type = Protocol.DataType.string, length = Protocol.MAX_CROP_POWER_NAME_LEN},
    fields       = {'init_city_id','color_id','len','power_name'}
}
Protocol.structs[Protocol.C_2_S_NATION_BATTLE_CREATE_POWER]          = Protocol.Packet_C2S_NationBattleCreatePower

Protocol.Packet_S2C_NationBattleCreatePower = {
    ret             = {type = Protocol.DataType.short}, --0 ok, 1 city occupied, 2 color dup
    init_city_id    = {type = Protocol.DataType.int},
    color_id        = {type = Protocol.DataType.short},
    power_id        = {type = Protocol.DataType.int},
    power_len       = {type = Protocol.DataType.short},
    power_name      = {type = Protocol.DataType.string, length = Protocol.MAX_CROP_POWER_NAME_LEN},
    fields          = {'ret','init_city_id','color_id','power_id','power_len','power_name'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_CREATE_POWER]          = Protocol.Packet_S2C_NationBattleCreatePower

Protocol.Packet_C2S_NationBattleWorldInfo = {
    city_id         = {type = Protocol.DataType.int},
    fields          = {'city_id'}
}
Protocol.structs[Protocol.C_2_S_NATION_BATTLE_WOLRD_INFO]          = Protocol.Packet_C2S_NationBattleWorldInfo

Protocol.Data_Develop = {
    id              = {type = Protocol.DataType.short},
    level           = {type = Protocol.DataType.int},
    exp             = {type = Protocol.DataType.int},
    fields          = {'id','level','exp'}
}

Protocol.Data_CityInfo = {
    city_id         = {type = Protocol.DataType.int},
    state           = {type = Protocol.DataType.short},
    crop_id         = {type = Protocol.DataType.int},
    declare_crop_id = {type = Protocol.DataType.int},
    declare_time    = {type = Protocol.DataType.int},
    battle_time     = {type = Protocol.DataType.int},
    occupy_num      = {type = Protocol.DataType.short},
    is_open         = {type = Protocol.DataType.short},
    def_num         = {type = Protocol.DataType.int},
    atk_num         = {type = Protocol.DataType.int},
    develop          = {type = Protocol.DataType.object, length = 3, clazz = 'Data_Develop'},
    fields          = {'city_id','state','crop_id','declare_crop_id','declare_time','battle_time','occupy_num','is_open','def_num','atk_num','develop'}
}

Protocol.Packet_S2C_NationBattleWorldInfo = {
    is_last         = {type = Protocol.DataType.short},
    count           = {type = Protocol.DataType.short},
    cities          = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CityInfo'},
    fields          = {'is_last','count','cities'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_WORLD_INFO]          = Protocol.Packet_S2C_NationBattleWorldInfo

Protocol.Data_MovingArmyInfo = {
    role_id         = {type = Protocol.DataType.longlong},
    army_id         = {type = Protocol.DataType.short},
    len             = {type = Protocol.DataType.short},
    name            = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    crop_id         = {type = Protocol.DataType.int},
    level           = {type = Protocol.DataType.short},
    move_cd         = {type = Protocol.DataType.int},
    move_goal       = {type = Protocol.DataType.short},
    from_city       = {type = Protocol.DataType.int},
    to_city         = {type = Protocol.DataType.int},
    count           = {type = Protocol.DataType.short},
    path_ids        = {type = Protocol.DataType.int, length = -1},
    general_id      = {type = Protocol.DataType.int},
    power_id        = {type = Protocol.DataType.int},
    fields          = {'role_id','army_id','len','name','crop_id','level','move_cd','move_goal','from_city','to_city','count','path_ids','general_id','power_id'}
}

Protocol.Packet_S2C_NationBattleMovingList = {
    is_last         = {type = Protocol.DataType.short},
    count           = {type = Protocol.DataType.short},
    armies          = {type = Protocol.DataType.object, length = -1, clazz = 'Data_MovingArmyInfo'},
    fields          = {'is_last','count','armies'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_MOVING_LIST]          = Protocol.Packet_S2C_NationBattleMovingList

Protocol.Packet_C2S_NationBattleDoMove = {
    army_id         = {type = Protocol.DataType.short},
    is_declare      = {type = Protocol.DataType.short},
    count           = {type = Protocol.DataType.short},
    path_ids        = {type = Protocol.DataType.int, length = -1},
    fields          = {'army_id','is_declare','count','path_ids'}
}
Protocol.structs[Protocol.C_2_S_NATION_BATTLE_DO_MOVE]          = Protocol.Packet_C2S_NationBattleDoMove

Protocol.Packet_S2C_NationBattleDoMove = {
    ret             = {type = Protocol.DataType.short},
    army_id         = {type = Protocol.DataType.short},
    is_declare      = {type = Protocol.DataType.short},
    dst_city_id     = {type = Protocol.DataType.int},
    fields          = {'ret','army_id','is_declare','dst_city_id'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_DO_MOVE]          = Protocol.Packet_S2C_NationBattleDoMove

Protocol.Data_BattleMoveArmy = {
    role_id         = {type = Protocol.DataType.longlong},
    army_id         = {type = Protocol.DataType.short},
    city_id         = {type = Protocol.DataType.int},
    fields          = {'role_id','army_id','city_id'}
}

Protocol.Packet_S2C_NationBattleMoveEnd = {
    count           = {type = Protocol.DataType.short},
    armys           = {type = Protocol.DataType.object, length = -1, clazz = 'Data_BattleMoveArmy'},
    fields          = {'count','armys'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_MOVE_END]          = Protocol.Packet_S2C_NationBattleMoveEnd

Protocol.Data_General = {
    pos             = {type = Protocol.DataType.short},
    general_id      = {type = Protocol.DataType.int},
    fields          = {'pos','general_id'}
}

Protocol.Data_LoadArmy = {
    id              = {type = Protocol.DataType.short},
    state           = {type = Protocol.DataType.short},
    cur_city        = {type = Protocol.DataType.int},
    main_general_id = {type = Protocol.DataType.int},
    formation_id    = {type = Protocol.DataType.int},
    count           = {type = Protocol.DataType.short},
    generals        = {type = Protocol.DataType.object, length = -1, clazz = 'Data_General'},
    fields          = {'id','state','cur_city','main_general_id','formation_id','count','generals'}
}

Protocol.Packet_S2C_NationBattleLoadArmy = {
    count           = {type = Protocol.DataType.short},
    armies          = {type = Protocol.DataType.object, length = -1, clazz = 'Data_LoadArmy'},
    fields          = {'count','armies'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_LOAD_ARMY]          = Protocol.Packet_S2C_NationBattleLoadArmy

Protocol.Packet_C2S_NationBattleUpdateFormation = {
    army_id         = {type = Protocol.DataType.short},
    formation_id    = {type = Protocol.DataType.int},
    count           = {type = Protocol.DataType.short},
    generals        = {type = Protocol.DataType.object, length = -1, clazz = 'Data_General'},
    fields          = {'army_id','formation_id','count','generals'}
}
Protocol.structs[Protocol.C_2_S_NATION_BATTLE_UPDATE_FORMATION]          = Protocol.Packet_C2S_NationBattleUpdateFormation

Protocol.Packet_S2C_NationBattleUpdateFormation = {
    ret             = {type = Protocol.DataType.short}, --0 ok, 1 general dup
    army_id         = {type = Protocol.DataType.short},
    main_general_id = {type = Protocol.DataType.int},
    fields          = {'ret','army_id','main_general_id'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_UPDATE_FORMATION]          = Protocol.Packet_S2C_NationBattleUpdateFormation

Protocol.Packet_C2S_NationBattleFieldInfo = {
    city_id         = {type = Protocol.DataType.int},
    fields          = {'city_id'}
}
Protocol.structs[Protocol.C_2_S_NATION_BATTLE_FIELD_INFO]          = Protocol.Packet_C2S_NationBattleFieldInfo

Protocol.Data_Point = {
    id              = {type = Protocol.DataType.short},
    hp              = {type = Protocol.DataType.int},
    crop_id         = {type = Protocol.DataType.int},
    wall_time       = {type = Protocol.DataType.int},
    def_time        = {type = Protocol.DataType.int},
    fields          = {'id','hp','crop_id','wall_time','def_time'}
}

Protocol.Packet_S2C_NationBattleFieldInfo = {
    count           = {type = Protocol.DataType.short},
    points          = {type = Protocol.DataType.object, length = -1, clazz = 'Data_Point'},
    attack_num      = {type = Protocol.DataType.short},
    defend_num      = {type = Protocol.DataType.short},
    fields          = {'count','points','attack_num','defend_num'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_FIELD_INFO]          = Protocol.Packet_S2C_NationBattleFieldInfo

Protocol.Data_PointArmy = {
    point_id        = {type = Protocol.DataType.short},
    type            = {type = Protocol.DataType.short},
    id              = {type = Protocol.DataType.longlong},
    army_id         = {type = Protocol.DataType.short},
    img_type        = {type = Protocol.DataType.short},
    img_id          = {type = Protocol.DataType.int},
    len             = {type = Protocol.DataType.short},
    name            = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    fields          = {'point_id','type','id','army_id','img_type','img_id','len','name'}
}

Protocol.Packet_S2C_NationBattleFieldPointArmys = {
    is_last         = {type = Protocol.DataType.short},
    count           = {type = Protocol.DataType.short},
    armys           = {type = Protocol.DataType.object, length = -1, clazz = 'Data_PointArmy'},
    fields          = {'is_last','count','armys'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_FIELD_POINT_ARMYS]          = Protocol.Packet_S2C_NationBattleFieldPointArmys

Protocol.Packet_C2S_NationBattleMovingList = {
    city_id         = {type = Protocol.DataType.int},
    fields          = {'city_id'}
}
Protocol.structs[Protocol.C_2_S_NATION_BATTLE_FIELD_MOVING_LIST]          = Protocol.Packet_C2S_NationBattleMovingList

Protocol.Data_FieldMovingArmyInfo = {
    from_point_id   = {type = Protocol.DataType.short},
    to_point_id     = {type = Protocol.DataType.short},
    move_cd         = {type = Protocol.DataType.int},
    id              = {type = Protocol.DataType.longlong},
    army_id         = {type = Protocol.DataType.short},
    move_goal       = {type = Protocol.DataType.short},
    img_type        = {type = Protocol.DataType.short},
    img_id          = {type = Protocol.DataType.int},
    crop_id         = {type = Protocol.DataType.int},
    len             = {type = Protocol.DataType.short},
    name            = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    fields          = {'from_point_id','to_point_id','move_cd','id','army_id','move_goal','img_type','img_id','crop_id','len','name'}
}

Protocol.Packet_S2C_NationBattleFieldMovingList = {
    is_last         = {type = Protocol.DataType.short},
    count           = {type = Protocol.DataType.short},
    armys           = {type = Protocol.DataType.object, length = -1, clazz = 'Data_FieldMovingArmyInfo'},
    fields          = {'is_last','count','armys'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_FIELD_MOVING_LIST]          = Protocol.Packet_S2C_NationBattleFieldMovingList

Protocol.Packet_C2S_NationBattleFieldMove = {
    army_id         = {type = Protocol.DataType.short},
    to_point_id     = {type = Protocol.DataType.short},
    fields          = {'army_id','to_point_id'}
}
Protocol.structs[Protocol.C_2_S_NATION_BATTLE_FIELD_MOVE]          = Protocol.Packet_C2S_NationBattleFieldMove

Protocol.Packet_S2C_NationBattleFieldMove = {
    from_point_id   = {type = Protocol.DataType.short},
    to_point_id     = {type = Protocol.DataType.short},
    cd_time         = {type = Protocol.DataType.int},
    fields          = {'from_point_id','to_point_id','cd_time'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_FIELD_MOVE]          = Protocol.Packet_S2C_NationBattleFieldMove

Protocol.Packet_C2S_NationBattleView = {
    op_type         = {type = Protocol.DataType.short},
    city_id         = {type = Protocol.DataType.int},
    fields          = {'op_type','city_id'}
}
Protocol.structs[Protocol.C_2_S_NATION_BATTLE_VIEW]          = Protocol.Packet_C2S_NationBattleView

Protocol.Data_BattleObject = {
    type            = {type = Protocol.DataType.short},
    id              = {type = Protocol.DataType.longlong},
    army_id         = {type = Protocol.DataType.short},
    win_num         = {type = Protocol.DataType.short},
    len             = {type = Protocol.DataType.short},
    name            = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    fields          = {'type','id','army_id','win_num','len','name'}
}

Protocol.Data_Report = {
    atk             = {type = Protocol.DataType.object, clazz = 'Data_BattleObject'},
    def             = {type = Protocol.DataType.object, clazz = 'Data_BattleObject'},
    result          = {type = Protocol.DataType.short},
    report_id       = {type = Protocol.DataType.llstring},
    fields          = {'atk','def','result','report_id'}
}

Protocol.Packet_S2C_NationBattleFieldNotify = {
    city_id         = {type = Protocol.DataType.int},
    point_id        = {type = Protocol.DataType.short},
    count           = {type = Protocol.DataType.short},
    reports         = {type = Protocol.DataType.object, length = -1, clazz = 'Data_Report'},
    def_time         = {type = Protocol.DataType.int},
    wall_time         = {type = Protocol.DataType.int},
    fields          = {'city_id','point_id','count','reports','def_time','wall_time'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_FIELD_NOTIFY]          = Protocol.Packet_S2C_NationBattleFieldNotify

Protocol.Packet_S2C_NationBattleFieldWallHP = {
    atk_id          = {type = Protocol.DataType.longlong},
    atk_army_id     = {type = Protocol.DataType.short},
    len             = {type = Protocol.DataType.short},
    atk_name        = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    city_id         = {type = Protocol.DataType.int},
    point_id        = {type = Protocol.DataType.short},
    result          = {type = Protocol.DataType.short},
    report_id       = {type = Protocol.DataType.llstring},
    fields          = {'atk_id','atk_army_id','len','atk_name','city_id','point_id','result','report_id'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_FIELD_WALL_HP]          = Protocol.Packet_S2C_NationBattleFieldWallHP

Protocol.Packet_S2C_NationBattleFieldOccupyNotify = {
    city_id         = {type = Protocol.DataType.int},
    point_id        = {type = Protocol.DataType.short},
    old_crop_id     = {type = Protocol.DataType.int},
    crop_id         = {type = Protocol.DataType.int},
    fields          = {'city_id','point_id','old_crop_id','crop_id'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_FIELD_OCCUPY_NOTIFY]          = Protocol.Packet_S2C_NationBattleFieldOccupyNotify

Protocol.Packet_S2C_NationBattleDeclareBattle = {
    crop_id         = {type = Protocol.DataType.int},
    city_id         = {type = Protocol.DataType.int},
    fields          = {'crop_id','city_id'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_DECLARE_BATTLE]          = Protocol.Packet_S2C_NationBattleDeclareBattle

Protocol.Packet_S2C_NationBattleStartBattle = {
    crop_id         = {type = Protocol.DataType.int},
    def_crop_id     = {type = Protocol.DataType.int},
    city_id         = {type = Protocol.DataType.int},
    fields          = {'crop_id','def_crop_id','city_id'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_START_BATTLE]          = Protocol.Packet_S2C_NationBattleStartBattle

Protocol.Packet_S2C_NationBattleEndBattle = {
    city_id         = {type = Protocol.DataType.int},
    is_win          = {type = Protocol.DataType.short},
    atk_crop_id     = {type = Protocol.DataType.int},
    def_crop_id     = {type = Protocol.DataType.int},
    fields          = {'city_id','is_win','atk_crop_id','def_crop_id'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_END_BATTLE]          = Protocol.Packet_S2C_NationBattleEndBattle

Protocol.Data_Armys = {
    id             = {type = Protocol.DataType.longlong},
    army_id        = {type = Protocol.DataType.short},
    point_id       = {type = Protocol.DataType.short},
    fields         = {'id','army_id','point_id'}
}

Protocol.Packet_S2C_NationBattleFieldMoveEnd = {
    count           = {type = Protocol.DataType.short},
    armys           = {type = Protocol.DataType.object, length = -1, clazz = 'Data_Armys'},
    fields          = {'count','armys'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_FIELD_MOVE_END]          = Protocol.Packet_S2C_NationBattleFieldMoveEnd

Protocol.Data_ScoreRank = {
    role_id         = {type = Protocol.DataType.longlong},
    country_id      = {type = Protocol.DataType.short},
    img_type        = {type = Protocol.DataType.short},
    img_id          = {type = Protocol.DataType.int},
    name_len        = {type = Protocol.DataType.short},
    role_name       = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    crop_len        = {type = Protocol.DataType.short},
    crop_name       = {type = Protocol.DataType.string, length = Protocol.MAX_CROPS_NAME_LEN},
    crop_id         = {type = Protocol.DataType.int},
    value           = {type = Protocol.DataType.int},
    fields          = {'role_id','country_id','img_type','img_id','name_len','role_name','crop_len','crop_name','crop_id','value'}
}

Protocol.Data_CropsRank = {
    crop_id         = {type = Protocol.DataType.int},
    name_len        = {type = Protocol.DataType.short},
    name            = {type = Protocol.DataType.string, length = Protocol.MAX_CROPS_NAME_LEN},
    value           = {type = Protocol.DataType.int},
    is_atk          = {type = Protocol.DataType.short},
    fields          = {'crop_id','name_len','name','value','is_atk'}
}

Protocol.Packet_S2C_NationBattleRankNotify = {
    own_score           = {type = Protocol.DataType.int},
    own_dechp           = {type = Protocol.DataType.int},
    own_cropscore       = {type = Protocol.DataType.int},
    score_count         = {type = Protocol.DataType.short},
    score_rank          = {type = Protocol.DataType.object, length = -1, clazz = 'Data_ScoreRank'},
    dechp_count         = {type = Protocol.DataType.short},
    dechp_rank          = {type = Protocol.DataType.object, length = -1, clazz = 'Data_ScoreRank'},
    crops_count         = {type = Protocol.DataType.short},
    crops_rank          = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CropsRank'},
    fields              = {'own_score','own_dechp','own_cropscore','score_count','score_rank','dechp_count','dechp_rank','crops_count','crops_rank'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_RANK_NOTIFY]          = Protocol.Packet_S2C_NationBattleRankNotify

Protocol.Data_Title = {
    title_id            = {type = Protocol.DataType.int},
    role_id             = {type = Protocol.DataType.longlong},
    player_len          = {type = Protocol.DataType.short},
    player_name         = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    country_id          = {type = Protocol.DataType.int},
    name_len            = {type = Protocol.DataType.short},
    crop_name           = {type = Protocol.DataType.string, length = Protocol.MAX_CROPS_NAME_LEN},
    img_type            = {type = Protocol.DataType.short},
    img_id              = {type = Protocol.DataType.int},
    fields              = {'title_id','role_id','player_len','player_name','country_id','name_len','crop_name','img_type','img_id'}
}

Protocol.Packet_S2C_NationBattleLoadTitle = {
    count           = {type = Protocol.DataType.short},
    title           = {type = Protocol.DataType.object, length = -1, clazz = 'Data_Title'},
    fields          = {'count','title'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_LOAD_TITLE]          = Protocol.Packet_S2C_NationBattleLoadTitle

Protocol.Data_BattleReportEnemy = {
    type            = {type = Protocol.DataType.short},
    role_id         = {type = Protocol.DataType.longlong},
    army_id         = {type = Protocol.DataType.short},
    player_len      = {type = Protocol.DataType.short},
    player_name     = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    crop_id         = {type = Protocol.DataType.int},
    name_len        = {type = Protocol.DataType.short},
    crop_name       = {type = Protocol.DataType.string, length = Protocol.MAX_CROPS_NAME_LEN},
    power           = {type = Protocol.DataType.int},
    img_type        = {type = Protocol.DataType.short},
    img_id          = {type = Protocol.DataType.int},
    fields          = {'type','role_id','army_id','player_len','player_name','crop_id','name_len','crop_name','power','img_type','img_id'}
}

Protocol.Data_BattleReportSelf = {
    army_id         = {type = Protocol.DataType.short},
    power           = {type = Protocol.DataType.int},
    fields          = {'army_id','power'}
}

Protocol.Data_BattleReport = {
    enemy           = {type = Protocol.DataType.object,length = 1, clazz = 'Data_BattleReportEnemy'},
    owned           = {type = Protocol.DataType.object,length = 1, clazz = 'Data_BattleReportSelf'},
    is_atk          = {type = Protocol.DataType.short},
    result          = {type = Protocol.DataType.short},
    report_id       = {type = Protocol.DataType.llstring},
    city_id         = {type = Protocol.DataType.int},
    point_id        = {type = Protocol.DataType.short},
    time            = {type = Protocol.DataType.int},
    fields          = {'enemy','owned','is_atk','result','report_id','city_id','point_id','time'}
}

Protocol.Packet_S2C_NationBattleReportNotify = {
    count           = {type = Protocol.DataType.short},
    reports         = {type = Protocol.DataType.object, length = -1, clazz = 'Data_BattleReport'},
    fields          = {'count','reports'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_REPORT_NOTIFY]          = Protocol.Packet_S2C_NationBattleReportNotify

Protocol.Packet_S2C_NationBattleReportLoad = {
    is_last         = {type = Protocol.DataType.short},
    count           = {type = Protocol.DataType.short},
    reports         = {type = Protocol.DataType.object, length = -1, clazz = 'Data_BattleReport'},
    fields          = {'is_last','count','reports'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_REPORT_LOAD]          = Protocol.Packet_S2C_NationBattleReportLoad

Protocol.Packet_C2S_NationBattleDevelop = {
    city_id         = {type = Protocol.DataType.int},
    choice          = {type = Protocol.DataType.short},
    option          = {type = Protocol.DataType.short},
    fields          = {'city_id','choice','option'}
}
Protocol.structs[Protocol.C_2_S_NATION_BATTLE_DEVELOP]          = Protocol.Packet_C2S_NationBattleDevelop

Protocol.Packet_S2C_NationBattleDevelop = {
    city_id         = {type = Protocol.DataType.int},
    choice          = {type = Protocol.DataType.short},
    option          = {type = Protocol.DataType.short},
    level           = {type = Protocol.DataType.int},
    exp             = {type = Protocol.DataType.int},
    fields          = {'city_id','choice','option','level','exp'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_DEVELOP]          = Protocol.Packet_S2C_NationBattleDevelop

Protocol.Packet_C2S_NationBattleLoadFirstRank = {
    city_id         = {type = Protocol.DataType.int},
    fields          = {'city_id'}
}
Protocol.structs[Protocol.C_2_S_NATION_BATTLE_LOAD_FIRSTRANK]          = Protocol.Packet_C2S_NationBattleLoadFirstRank

Protocol.Packet_S2C_NationBattleLoadFristRank = {
    city_id          = {type = Protocol.DataType.int},
    score_count      = {type = Protocol.DataType.short},
    score_rank       = {type = Protocol.DataType.object, length = -1, clazz = 'Data_ScoreRank'},
    dechp_count      = {type = Protocol.DataType.short},
    dechp_rank       = {type = Protocol.DataType.object, length = -1, clazz = 'Data_ScoreRank'},
    crop_count       = {type = Protocol.DataType.short},
    crops_rank       = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CropsRank'},
    fields           = {'city_id','score_count','score_rank','dechp_count','dechp_rank','crop_count','crops_rank'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_LOAD_FIRSTRANK]          = Protocol.Packet_S2C_NationBattleLoadFristRank

Protocol.Packet_S2C_NationBattleCityChangeNotify = {
    city_id         = {type = Protocol.DataType.int},
    fields          = {'city_id'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_CITY_CHANGE_NOTIFY]          = Protocol.Packet_S2C_NationBattleCityChangeNotify

Protocol.Data_BattleTaskRank = {
    id              = {type = Protocol.DataType.int},
    value           = {type = Protocol.DataType.longlong},
    rank            = {type = Protocol.DataType.short},
    name_len        = {type = Protocol.DataType.ushort},
    name            = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    fields          = {'id','value','rank','name_len','name'}
}

Protocol.Data_BattleTaskInfo = {
    id              = {type = Protocol.DataType.short},
    state           = {type = Protocol.DataType.short},
    num             = {type = Protocol.DataType.short},
    begin_time      = {type = Protocol.DataType.int},
    end_time        = {type = Protocol.DataType.int},
    rank_count      = {type = Protocol.DataType.short},
    crops           = {type = Protocol.DataType.object, length = -1, clazz = 'Data_BattleTaskRank'},
    fields          = {'id','state','num','begin_time','end_time','rank_count','crops'}
}

Protocol.Packet_S2C_NationBattleTaskUpdate = {
    now_id          = {type = Protocol.DataType.short},
    count           = {type = Protocol.DataType.short},
    items           = {type = Protocol.DataType.object, length = -1, clazz = 'Data_BattleTaskInfo'},
    fields          = {'now_id','count','items'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_TASK_UPDATE]          = Protocol.Packet_S2C_NationBattleTaskUpdate

Protocol.Packet_C2S_NationBattDrawTask = {
    task_id         = {type = Protocol.DataType.int},
    fields          = {'task_id'}
}
Protocol.structs[Protocol.C_2_S_NATION_BATTLE_DRAW_TASK]          = Protocol.Packet_C2S_NationBattDrawTask

Protocol.Packet_S2C_NationBattDrawTask = {
    task_id         = {type = Protocol.DataType.int},
    fields          = {'task_id'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_DRAW_TASK]          = Protocol.Packet_S2C_NationBattDrawTask

Protocol.Data_BattleInitCity = {
    city_id         = {type = Protocol.DataType.int},
    crop_id         = {type = Protocol.DataType.int},
    fields          = {'city_id','crop_id'}
}

Protocol.Packet_S2C_NationBattDrawTask = {
    count          = {type = Protocol.DataType.short},
    init_citys     = {type = Protocol.DataType.object, length = -1, clazz = 'Data_BattleInitCity'},
    fields          = {'count','init_citys'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_LOAD_INIT_CITY]          = Protocol.Packet_S2C_NationBattDrawTask

Protocol.Data_HpUpdate = {
    city_id         = {type = Protocol.DataType.int},
    point_id        = {type = Protocol.DataType.int},
    wall_time       = {type = Protocol.DataType.int},
    wall_hp         = {type = Protocol.DataType.int},
    fields          = {'city_id','point_id','wall_time','wall_hp'}
}

Protocol.Packet_S2C_NationBattleFieldPointHpUpdate = {
    count           = {type = Protocol.DataType.short},
    point           = {type = Protocol.DataType.object, length = -1, clazz = 'Data_HpUpdate'},
    fields          = {'count','point'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_FIELD_POINT_HP_UPDATE]          = Protocol.Packet_S2C_NationBattleFieldPointHpUpdate

Protocol.Data_NpcUpdate = {
    city_id         = {type = Protocol.DataType.int},
    point_id        = {type = Protocol.DataType.int},
    def_time       = {type = Protocol.DataType.int},
    count           = {type = Protocol.DataType.short},
    armys           = {type = Protocol.DataType.object, length = -1, clazz = 'Data_PointArmy'},
    fields          = {'city_id','point_id','def_time','count','armys'}
}

Protocol.Packet_S2C_NationBattleFieldPointNpcUpdate = {
    count           = {type = Protocol.DataType.short},
    point           = {type = Protocol.DataType.object, length = -1, clazz = 'Data_NpcUpdate'},
    fields          = {'count','point'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_FIELD_POINT_NPC_UPDATE]          = Protocol.Packet_S2C_NationBattleFieldPointNpcUpdate

Protocol.Packet_S2C_NationBattleFieldPointArmys = {
    is_last         = {type = Protocol.DataType.short},
    count           = {type = Protocol.DataType.short},
    armys           = {type = Protocol.DataType.object, length = -1, clazz = 'Data_PointArmy'},
    fields          = {'is_last','count','armys'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_FIELD_POINT_ARMYS]          = Protocol.Packet_S2C_NationBattleFieldPointArmys

Protocol.Packet_S2C_NationBattleArmyEnterField = {
    attack_num      = {type = Protocol.DataType.short},
    defend_num      = {type = Protocol.DataType.short},
    army            = {type = Protocol.DataType.object, length = 1, clazz = 'Data_PointArmy'},
    fields          = {'attack_num','defend_num','army'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_ARMY_ENTER_FIELD]          = Protocol.Packet_S2C_NationBattleArmyEnterField

Protocol.Data_CityArmy = {
    city_id         = {type = Protocol.DataType.int},
    attack_num      = {type = Protocol.DataType.short},
    defend_num      = {type = Protocol.DataType.short},
    fields          = {'city_id','attack_num','defend_num'}
}

Protocol.Packet_S2C_NationBattleArmyUpdate = {
    count           = {type = Protocol.DataType.short},
    citys            = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CityArmy'},
    fields          = {'count','citys'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_ARMY_UPDATE]          = Protocol.Packet_S2C_NationBattleArmyUpdate

Protocol.Packet_C2S_NationBattleMoveCity = {
    city_id           = {type = Protocol.DataType.int},
    fields          = {'city_id'}
}
Protocol.structs[Protocol.C_2_S_NATION_BATTLE_MOVE_CITY]          = Protocol.Packet_C2S_NationBattleMoveCity

Protocol.Packet_S2C_NationBattleMoveCity = {
    ret             = {type = Protocol.DataType.short},
    city_id         = {type = Protocol.DataType.short},
    fields          = {'ret','city_id'}
}
Protocol.structs[Protocol.S_2_C_NATION_BATTLE_MOVE_CITY]          = Protocol.Packet_S2C_NationBattleMoveCity

