local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_BUY_MILITY_ORDERS       = Protocol.C_2_S_CHAR_BASE + 0
Protocol.C_2_S_GUIDE_LOAD              = Protocol.C_2_S_CHAR_BASE + 1
Protocol.C_2_S_FINISH_GUIDE            = Protocol.C_2_S_CHAR_BASE + 2
Protocol.C_2_S_LOAD_RESOURCE_REFRESH   = Protocol.C_2_S_CHAR_BASE + 3

Protocol.S_2_C_CHAR_INFO               = Protocol.S_2_C_CHAR_BASE + 0
Protocol.S_2_C_CHAR_TIMELIST_INFO      = Protocol.S_2_C_CHAR_BASE + 1
Protocol.S_2_C_CHAR_LOAD_END           = Protocol.S_2_C_CHAR_BASE + 2
Protocol.S_2_C_UPDATE_BENEFIT          = Protocol.S_2_C_CHAR_BASE + 3
Protocol.S_2_C_UPDATE_RES_NUMS         = Protocol.S_2_C_CHAR_BASE + 4
Protocol.S_2_C_BUY_BUILD_LIST_RES      = Protocol.S_2_C_CHAR_BASE + 5
Protocol.S_2_C_BUY_MILITYORDER_RES     = Protocol.S_2_C_CHAR_BASE + 6
Protocol.S_2_C_EXTRA_ORDERS_CHANGE     = Protocol.S_2_C_CHAR_BASE + 7
Protocol.S_2_C_CITY_DOOR               = Protocol.S_2_C_CHAR_BASE + 8
Protocol.S_2_C_ORDER_UPPER_LIMIT       = Protocol.S_2_C_CHAR_BASE + 9
Protocol.S_2_C_ROLE_UPDATE_RESOURCE    = Protocol.S_2_C_CHAR_BASE + 10
Protocol.S_2_C_ROLE_UPDATE_FORCE_VALUE = Protocol.S_2_C_CHAR_BASE + 11
Protocol.S_2_C_GUIDE_LOAD              = Protocol.S_2_C_CHAR_BASE + 12
Protocol.S_2_C_FINISH_GUIDE            = Protocol.S_2_C_CHAR_BASE + 13
Protocol.S_2_C_LOAD_RESOURCE_REFRESH   = Protocol.S_2_C_CHAR_BASE + 14
Protocol.S_2_C_LOAD_ROLE_RESOURCE      = Protocol.S_2_C_CHAR_BASE + 15

Protocol.Packet_C2S_FinishGuide = {
    id              = {type = Protocol.DataType.short},
    fields          = {'id'}
}
Protocol.structs[Protocol.C_2_S_FINISH_GUIDE]       = Protocol.Packet_C2S_FinishGuide

Protocol.Packet_Data_LoadResourceRefresh = {
    id              = {type = Protocol.DataType.short},
    fields          = {'id'}
}
Protocol.structs[Protocol.C_2_S_LOAD_RESOURCE_REFRESH] = Protocol.Packet_Data_LoadResourceRefresh


------------------------------S_2_C------------------------------
Protocol.Packet_S2C_CharInfo = {
    --S_2_C_CHAR_INFO
    role_id                             = {type = Protocol.DataType.longlong},
    name_len                            = {type = Protocol.DataType.ushort},
    name                                = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    country_id                          = {type = Protocol.DataType.char},                                          --国家ID
    vip_lvl                             = {type = Protocol.DataType.short},                                         --VIP等级
    vip_exp                             = {type = Protocol.DataType.int},                                           --VIP经验
    vip_reward_lvl                      = {type = Protocol.DataType.int},                                           --每日vip奖励
    init_general_id                     = {type = Protocol.DataType.int},                                           --初始武将id
    current_instance_id                 = {type = Protocol.DataType.int},                                           --当前所处的FB_ID
    used_warehouse_num                  = {type = Protocol.DataType.short},                                         --已使用的仓库位
    total_warehouse_num                 = {type = Protocol.DataType.short},                                         --仓库位数量
    warehouse_draw_time                 = {type = Protocol.DataType.int},                                           --仓库格子上一次解锁时的玩家累计在线时间
    total_online_time                   = {type = Protocol.DataType.int},                                           --玩家累计在线时间
    crop_id                             = {type = Protocol.DataType.int},                                           --军团ID
    create_time                         = {type = Protocol.DataType.int},                                           --创建角色时间
    train_nums                          = {type = Protocol.DataType.short},                                         --校场训练位置的数量
    max_general_num                     = {type = Protocol.DataType.short},                                         --最大武将数量
    bubble_id                           = {type = Protocol.DataType.short},
    rename_times                        = {type = Protocol.DataType.int},
    buy_militory_order_num              = {type = Protocol.DataType.short},
    fields                              = {'role_id','name_len','name','country_id','vip_lvl','vip_exp','vip_reward_lvl','init_general_id','current_instance_id'
                                            ,'used_warehouse_num','total_warehouse_num','warehouse_draw_time','total_online_time','crop_id','create_time'
                                            ,'train_nums','max_general_num','bubble_id','rename_times','buy_militory_order_num'}

}
Protocol.structs[Protocol.S_2_C_CHAR_INFO]                          = Protocol.Packet_S2C_CharInfo

Protocol.Packet_S2C_CharTimeInfo = {
    --S_2_C_CHAR_TIMELIST_INFO
    fightTime                           = {type = Protocol.DataType.uint},                                          --战斗冷却
    collectTime                         = {type = Protocol.DataType.uint},                                          --征收冷却
    techTime                            = {type = Protocol.DataType.uint},                                          --科技冷却
    suddenFlightTime                    = {type = Protocol.DataType.uint},                                          --武将突飞时间
    intersify_cd_time                   = {type = Protocol.DataType.uint},                                          --强化CD
    appoint_cd_time                     = {type = Protocol.DataType.uint},                                          --委派CD
    spin_cd_time                        = {type = Protocol.DataType.uint},                                          --纺织CD
    move_house_cd_time                  = {type = Protocol.DataType.uint},                                          --搬家CD
    join_crops_cd_time                  = {type = Protocol.DataType.uint},                                          --加入军团CD（退出军团后产生）
    draft_cd_time                       = {type = Protocol.DataType.uint},                                          --征义兵CD
    battle_protect_cd_time              = {type = Protocol.DataType.uint},                                          --对战保护CD
    geste_to_prestige_cd_time           = {type = Protocol.DataType.uint},                                          --军功换威望CD
    city_farm_cd_time                   = {type = Protocol.DataType.uint},                                          --城内农田CD
    invest_cd_time                      = {type = Protocol.DataType.uint},                                          --投资cd
    world_res_gains_cd                  = {type = Protocol.DataType.uint},                                          --世界资源收获cd
    plunder_cd_time                     = {type = Protocol.DataType.uint},
    dare_chall_cd_time                  = {type = Protocol.DataType.uint},
    plunder_war_cd_time                 = {type = Protocol.DataType.uint},
    join_super_member_cd_time           = {type = Protocol.DataType.uint},
    rob_cd_time                         = {type = Protocol.DataType.uint},
    be_robbed_cd_time                   = {type = Protocol.DataType.uint},
    accelerate_cd_time                  = {type = Protocol.DataType.uint},
    pirate_aggress_cd_time              = {type = Protocol.DataType.uint},
    pirate_aggress_fix_cd_time          = {type = Protocol.DataType.uint},
    bosom_friend_cd_time                = {type = Protocol.DataType.uint},
    auto_join_muti_battle_cd_time       = {type = Protocol.DataType.uint},                                          --军团自动报名缓冲时间
    travel_cd_time                      = {type = Protocol.DataType.uint},                                          --游历系统行动CD
    fields                              = {'fightTime','collectTime','techTime','suddenFlightTime','intersify_cd_time','appoint_cd_time','spin_cd_time','move_house_cd_time'
                                            ,'join_crops_cd_time','draft_cd_time','battle_protect_cd_time','geste_to_prestige_cd_time','city_farm_cd_time','invest_cd_time'
                                            ,'world_res_gains_cd','plunder_cd_time','dare_chall_cd_time','plunder_war_cd_time','join_super_member_cd_time','rob_cd_time'
                                            ,'be_robbed_cd_time','accelerate_cd_time','pirate_aggress_cd_time','pirate_aggress_fix_cd_time','bosom_friend_cd_time'
                                            ,'auto_join_muti_battle_cd_time','travel_cd_time'}
}
Protocol.structs[Protocol.S_2_C_CHAR_TIMELIST_INFO]                 = Protocol.Packet_S2C_CharTimeInfo

Protocol.Packet_S2C_CharLoadEnd = {
    --S_2_C_CHAR_LOAD_END
    session_seed            = {type = Protocol.DataType.int},
    fields                  = {"session_seed"}
}
Protocol.structs[Protocol.S_2_C_CHAR_LOAD_END]                      = Protocol.Packet_S2C_CharLoadEnd

Protocol.Packet_S2C_UpdateBenefit = {
    --S_2_C_UPDATE_BENEFIT
    money                               = {type = Protocol.DataType.uint},
    goldenCoins                         = {type = Protocol.DataType.uint},
    geste                               = {type = Protocol.DataType.uint},
    prestige                            = {type = Protocol.DataType.uint},
    militoryOrder                       = {type = Protocol.DataType.uint},
    food                                = {type = Protocol.DataType.uint},
    soldier_num                         = {type = Protocol.DataType.uint},
    tower_order                         = {type = Protocol.DataType.int},
    soul_num                            = {type = Protocol.DataType.uint},
    insignia_num                        = {type = Protocol.DataType.uint},
    silver_cross                        = {type = Protocol.DataType.int},
    athletics_integral                  = {type = Protocol.DataType.int},
    fields                              = {'money','goldenCoins','geste','prestige','militoryOrder','food','soldier_num','tower_order','soul_num','insignia_num'
                                            ,'silver_cross','athletics_integral'}
}
Protocol.structs[Protocol.S_2_C_UPDATE_BENEFIT]                     = Protocol.Packet_S2C_UpdateBenefit

Protocol.Packet_S2C_UpdateResNums = {
    --S_2_C_UPDATE_RES_NUMS
    fram_nums                           = {type = Protocol.DataType.char},
    silver_nums                         = {type = Protocol.DataType.char},
    fields                              = {'fram_nums','silver_nums'}
}
Protocol.structs[Protocol.S_2_C_UPDATE_RES_NUMS]                    = Protocol.Packet_S2C_UpdateResNums

Protocol.Packet_S2C_BuyBuildListNumsRes = {
    --S_2_C_BUY_BUILD_LIST_RES
    res                                 = {type = Protocol.DataType.char},
    build_list_nums                     = {type = Protocol.DataType.char},
    fields                              = {'res','build_list_nums'}
}
Protocol.structs[Protocol.S_2_C_BUY_BUILD_LIST_RES]                 = Protocol.Packet_S2C_BuyBuildListNumsRes

Protocol.Packet_S2C_BuyMilityOrderRes = {
    --S_2_C_BUY_MILITYORDER_RES
    ret       = {type = Protocol.DataType.short},                              --0 success, 1 failed
    buy_times = {type = Protocol.DataType.short},
    fields    = {'ret','buy_times'}
}
Protocol.structs[Protocol.S_2_C_BUY_MILITYORDER_RES]                = Protocol.Packet_S2C_BuyMilityOrderRes

Protocol.Packet_S2C_ExtraOrdersChange = {
    --S_2_C_EXTRA_ORDERS_CHANGE
    extra                               = {type = Protocol.DataType.char, length = Protocol.MAX_EXTRA_MO_COUNT},
    fields                              = {'extra'}
}
Protocol.structs[Protocol.S_2_C_EXTRA_ORDERS_CHANGE]                = Protocol.Packet_S2C_ExtraOrdersChange

Protocol.Packet_S2C_OrderUpperLimit = {
    --S_2_C_ORDER_UPPER_LIMIT
    orderLimit                          = {type = Protocol.DataType.short},
    fields                              = {'orderLimit'}
}
Protocol.structs[Protocol.S_2_C_ORDER_UPPER_LIMIT]                  = Protocol.Packet_S2C_OrderUpperLimit

Protocol.Packet_S2C_CityDoor = {
    --S_2_C_CITY_DOOR
    ret                                 = {type = Protocol.DataType.chat},
    fields                              = {'ret'}
}
Protocol.structs[Protocol.S_2_C_CITY_DOOR]                          = Protocol.Packet_S2C_CityDoor

Protocol.Packet_S2C_RoleUpdateResource = {
    count                               = {type = Protocol.DataType.short},
    rwds                                = {type = Protocol.DataType.object, length = -1, clazz='Packet_Data_RewardType'},
    fields                              = {'count','rwds'}
}
Protocol.structs[Protocol.S_2_C_ROLE_UPDATE_RESOURCE]                          = Protocol.Packet_S2C_RoleUpdateResource
Protocol.structs[Protocol.S_2_C_LOAD_ROLE_RESOURCE]                            = Protocol.Packet_S2C_RoleUpdateResource

Protocol.Packet_S2C_UpdateForceValue = {
    force_value   = {type = Protocol.DataType.int},
    athletic_rank = {type = Protocol.DataType.int},
    fields        = {'force_value', 'athletic_rank'}
}
Protocol.structs[Protocol.S_2_C_ROLE_UPDATE_FORCE_VALUE] = Protocol.Packet_S2C_UpdateForceValue

Protocol.Packet_S2C_GuideLoad = {
    count       = {type = Protocol.DataType.short},
    ids         = {type = Protocol.DataType.short, length = -1},
    fields      = {'count','ids'}
}
Protocol.structs[Protocol.S_2_C_GUIDE_LOAD] = Protocol.Packet_S2C_GuideLoad

Protocol.Packet_S2C_FinishGuide = {
    ret         = {type = Protocol.DataType.short},
    id          = {type = Protocol.DataType.short},
    fields      = {'ret','id'}
}
Protocol.structs[Protocol.S_2_C_FINISH_GUIDE] = Protocol.Packet_S2C_FinishGuide

Protocol.Packet_S2C_LoadResourceRefresh = {
    ret         = {type = Protocol.DataType.short},
    id          = {type = Protocol.DataType.short},
    num         = {type = Protocol.DataType.int},
    cd_time     = {type = Protocol.DataType.int},
    fields      = {'ret', 'id', 'num', 'cd_time'}
}
Protocol.structs[Protocol.S_2_C_LOAD_RESOURCE_REFRESH] = Protocol.Packet_S2C_LoadResourceRefresh
