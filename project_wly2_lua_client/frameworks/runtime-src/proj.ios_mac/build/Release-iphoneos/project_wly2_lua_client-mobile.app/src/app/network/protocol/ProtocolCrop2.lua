local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_CROP_BOSS_LOAD               = Protocol.C_2_S_CROP2_BASE + 1
Protocol.C_2_S_CROP_BOSS_OPEN               = Protocol.C_2_S_CROP2_BASE + 3
Protocol.C_2_S_CROP_BOSS_CLOSE              = Protocol.C_2_S_CROP2_BASE + 5
Protocol.C_2_S_CROP_BOSS_FIGHT              = Protocol.C_2_S_CROP2_BASE + 7
Protocol.C_2_S_CROP_BOSS_RANK               = Protocol.C_2_S_CROP2_BASE + 9
Protocol.C_2_S_CROP_REDBAG_LOAD             = Protocol.C_2_S_CROP2_BASE + 11
Protocol.C_2_S_CROP_REDBAG_SEND             = Protocol.C_2_S_CROP2_BASE + 13
Protocol.C_2_S_CROP_REDBAG_PICK             = Protocol.C_2_S_CROP2_BASE + 15
Protocol.C_2_S_CROP_REDBAG_DETAIL           = Protocol.C_2_S_CROP2_BASE + 17
Protocol.C_2_S_CROP_INSTANCE_LOAD           = Protocol.C_2_S_CROP2_BASE + 18
Protocol.C_2_S_CROP_INSTANCE_BATTLE         = Protocol.C_2_S_CROP2_BASE + 19
Protocol.C_2_S_CROP_INSTANCE_DRAW           = Protocol.C_2_S_CROP2_BASE + 20
Protocol.C_2_S_CROP_INSTANCE_LOG_LOAD       = Protocol.C_2_S_CROP2_BASE + 21
Protocol.C_2_S_CROP_INSTANCE_FORMATION_LOAD = Protocol.C_2_S_CROP2_BASE + 22
Protocol.C_2_S_CROP_INSTANCE_FORMATION_SAVE = Protocol.C_2_S_CROP2_BASE + 23

Protocol.S_2_C_CROP_BOSS_LOAD               = Protocol.S_2_C_CROP2_BASE + 2
Protocol.S_2_C_CROP_BOSS_OPEN               = Protocol.S_2_C_CROP2_BASE + 4
Protocol.S_2_C_CROP_BOSS_CLOSE              = Protocol.S_2_C_CROP2_BASE + 6
Protocol.S_2_C_CROP_BOSS_FIGHT              = Protocol.S_2_C_CROP2_BASE + 8
Protocol.S_2_C_CROP_BOSS_RANK               = Protocol.S_2_C_CROP2_BASE + 10
Protocol.S_2_C_CROP_REDBAG_LOAD_BEGIN       = Protocol.S_2_C_CROP2_BASE + 12
Protocol.S_2_C_CROP_REDBAG_LOAD             = Protocol.S_2_C_CROP2_BASE + 14
Protocol.S_2_C_CROP_REDBAG_LOAD_END         = Protocol.S_2_C_CROP2_BASE + 16
Protocol.S_2_C_CROP_REDBAG_SEND             = Protocol.S_2_C_CROP2_BASE + 18
Protocol.S_2_C_CROP_REDBAG_PICK             = Protocol.S_2_C_CROP2_BASE + 20
Protocol.S_2_C_CROP_REDBAG_DETAIL           = Protocol.S_2_C_CROP2_BASE + 22
Protocol.S_2_C_CROP_REDBAG_OVER             = Protocol.S_2_C_CROP2_BASE + 24
Protocol.S_2_C_CROP_INSTANCE_LOAD           = Protocol.S_2_C_CROP2_BASE + 25
Protocol.S_2_C_CROP_INSTANCE_BATTLE         = Protocol.S_2_C_CROP2_BASE + 26
Protocol.S_2_C_CROP_INSTANCE_DRAW           = Protocol.S_2_C_CROP2_BASE + 27
Protocol.S_2_C_CROP_INSTANCE_LOG_LOAD       = Protocol.S_2_C_CROP2_BASE + 28
Protocol.S_2_C_CROP_INSTANCE_FORMATION_LOAD = Protocol.S_2_C_CROP2_BASE + 29
Protocol.S_2_C_CROP_INSTANCE_FORMATION_SAVE = Protocol.S_2_C_CROP2_BASE + 30

Protocol.Packet_C2S_CropBossLoad = {
    fields      = {}
}
Protocol.structs[Protocol.C_2_S_CROP_BOSS_LOAD]  = Protocol.Packet_C2S_CropBossLoad

Protocol.Packet_S2C_CropBossLoad = {
    cur_instance_id = {type = Protocol.DataType.int},
    cur_boss_id     = {type = Protocol.DataType.int},
    max_hp          = {type = Protocol.DataType.int},
    cur_hp          = {type = Protocol.DataType.int},
    open_num        = {type = Protocol.DataType.short},
    battle_num      = {type = Protocol.DataType.short},
    count           = {type = Protocol.DataType.short},
    boss_ids        = {type = Protocol.DataType.int, length = -1},
    count1          = {type = Protocol.DataType.short},
    instance_ids    = {type = Protocol.DataType.int, length = -1},
    fields          = {'cur_instance_id','cur_boss_id','max_hp','cur_hp','open_num','battle_num','count','boss_ids'
                        ,'count1','instance_ids'}
}
Protocol.structs[Protocol.S_2_C_CROP_BOSS_LOAD]  = Protocol.Packet_S2C_CropBossLoad

Protocol.Packet_C2S_CropBossOpen = {
    instance_id = {type = Protocol.DataType.int},
    fields      = {'instance_id'}
}
Protocol.structs[Protocol.C_2_S_CROP_BOSS_OPEN]  = Protocol.Packet_C2S_CropBossOpen

Protocol.Packet_S2C_CropBossOpen = {
    instance_id = {type = Protocol.DataType.int},
    boss_id     = {type = Protocol.DataType.int},
    max_hp      = {type = Protocol.DataType.int},
    fields      = {'instance_id','boss_id','max_hp'}
}
Protocol.structs[Protocol.S_2_C_CROP_BOSS_OPEN]  = Protocol.Packet_S2C_CropBossOpen

Protocol.Packet_C2S_CropBossClose = {
    fields      = {}
}
Protocol.structs[Protocol.C_2_S_CROP_BOSS_CLOSE]  = Protocol.Packet_C2S_CropBossClose

Protocol.Packet_S2C_CropBossClose = {
    instance_id = {type = Protocol.DataType.int},
    fields      = {'instance_id'}
}
Protocol.structs[Protocol.S_2_C_CROP_BOSS_CLOSE]  = Protocol.Packet_S2C_CropBossClose

Protocol.Packet_C2S_CropBossFight = {
    boss_id     = {type = Protocol.DataType.int},
    fields      = {'boss_id'}
}
Protocol.structs[Protocol.C_2_S_CROP_BOSS_FIGHT]  = Protocol.Packet_C2S_CropBossFight

Protocol.Packet_S2C_CropBossFight = {
    ret         = {type = Protocol.DataType.short},    --0 ok, 1 killed
    boss_id     = {type = Protocol.DataType.int},
    left_hp     = {type = Protocol.DataType.int},
    report_id   = {type = Protocol.DataType.llstring},
    battle_num  = {type = Protocol.DataType.short},
    fields      = {'ret','boss_id','left_hp','report_id','battle_num'}
}
Protocol.structs[Protocol.S_2_C_CROP_BOSS_FIGHT]  = Protocol.Packet_S2C_CropBossFight


Protocol.Packet_C2S_CropBossRank = {
    boss_id     = {type = Protocol.DataType.int},
    fields      = {'boss_id'}
}
Protocol.structs[Protocol.C_2_S_CROP_BOSS_RANK]  = Protocol.Packet_C2S_CropBossRank

Protocol.Data_CropBossRankItems = {
    id          = {type = Protocol.DataType.longlong},
    rank        = {type = Protocol.DataType.short},
    name_len    = {type = Protocol.DataType.short},
    name        = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    hurt_hp     = {type = Protocol.DataType.int},
    fields      = {'id','rank','name_len','name','hurt_hp'}
}

Protocol.Packet_S2C_CropBossRank = {
    count       = {type = Protocol.DataType.short},
    items       = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CropBossRankItems'},
    my_hurt     = {type = Protocol.DataType.int},
    fields      = {'count','items','my_hurt'}
}
Protocol.structs[Protocol.S_2_C_CROP_BOSS_RANK]  = Protocol.Packet_S2C_CropBossRank

Protocol.Data_CropRedbagInfo = {
    id                = {type = Protocol.DataType.longlong},
    type              = {type = Protocol.DataType.short},
    sender_id         = {type = Protocol.DataType.longlong},
    img_type          = {type = Protocol.DataType.short},
    img_id            = {type = Protocol.DataType.int},
    country_id        = {type = Protocol.DataType.short},
    role_name_len     = {type = Protocol.DataType.short},
    role_name         = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    msg_len           = {type = Protocol.DataType.short},
    msg               = {type = Protocol.DataType.string, length = Protocol.MAX_CROP_REDBAG_MSG_LEN},
    left_num          = {type = Protocol.DataType.short},
    total_num         = {type = Protocol.DataType.short},
    expire_time       = {type = Protocol.DataType.int},
    create_time       = {type = Protocol.DataType.int},
    has_picked        = {type = Protocol.DataType.short},
    fields            = {'id','type','sender_id','img_type','img_id','country_id','role_name_len','role_name'
                          ,'msg_len','msg','left_num','total_num','expire_time','create_time','has_picked'}
}

Protocol.Packet_C2S_CropRedbagLoad = {
    fields = {}
}
Protocol.structs[Protocol.C_2_S_CROP_REDBAG_LOAD] = Protocol.Packet_C2S_CropRedBagLoad

Protocol.Packet_S2C_CropRedbagLoadBegin = {
    send_num         = {type = Protocol.DataType.short},
    pick_num         = {type = Protocol.DataType.short},
    fields           = {'send_num','pick_num'}
}
Protocol.structs[Protocol.S_2_C_CROP_REDBAG_LOAD_BEGIN] = Protocol.Packet_S2C_CropRedbagLoadBegin

Protocol.Packet_S2C_CropRedbagLoad = {
    count            = {type = Protocol.DataType.short},
    redbags          = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CropRedbagInfo'},
    fields           = {'count','redbags'}
}
Protocol.structs[Protocol.S_2_C_CROP_REDBAG_LOAD] = Protocol.Packet_S2C_CropRedbagLoad

Protocol.Packet_S2C_CropRedbagLoadEnd = {
    fields           = {}
}
Protocol.structs[Protocol.S_2_C_CROP_REDBAG_LOAD_END] = Protocol.Packet_S2C_CropRedbagLoadEnd

Protocol.Packet_C2S_CropRedbagSend = {
    num             = {type = Protocol.DataType.short},
    redbag_type     = {type = Protocol.DataType.short},
    msg_len         = {type = Protocol.DataType.short},
    msg             = {type = Protocol.DataType.string, length = Protocol.MAX_CROP_REDBAG_MSG_LEN},
    fields          = {'num','redbag_type','msg_len','msg'}
}
Protocol.structs[Protocol.C_2_S_CROP_REDBAG_SEND] = Protocol.Packet_C2S_CropRedbagSend

Protocol.Packet_S2C_CropRedbagSend = {
    ret             = {type = Protocol.DataType.short},
    count           = {type = Protocol.DataType.short},
    ids             = {type = Protocol.DataType.longlong, length = -1},
    fields          = {'ret','count','ids'}
}
Protocol.structs[Protocol.S_2_C_CROP_REDBAG_SEND] = Protocol.Packet_S2C_CropRedbagSend

Protocol.Packet_C2S_CropRedbagPick = {
    id              = {type = Protocol.DataType.longlong},
    msg_len         = {type = Protocol.DataType.short},
    msg             = {type = Protocol.DataType.string, length = Protocol.MAX_CROP_REDBAG_MSG_LEN},
    fields          = {'id','msg_len','msg'}
}
Protocol.structs[Protocol.C_2_S_CROP_REDBAG_PICK] = Protocol.Packet_C2S_CropRedbagPick

Protocol.Packet_S2C_CropRedbagPick = {
    ret             = {type = Protocol.DataType.short},   --0 ok, 1 none left,2 invalid passwd
    id              = {type = Protocol.DataType.longlong},
    item_id         = {type = Protocol.DataType.short},
    fields          = {'ret','id','item_id'}
}
Protocol.structs[Protocol.S_2_C_CROP_REDBAG_PICK] = Protocol.Packet_S2C_CropRedbagPick

Protocol.Packet_C2S_CropRedbagDetail = {
    id              = {type = Protocol.DataType.longlong},
    fields          = {'id'}
}
Protocol.structs[Protocol.C_2_S_CROP_REDBAG_DETAIL] = Protocol.Packet_C2S_CropRedbagDetail

Protocol.Data_CropRedbagItems = {
    role_id         = {type = Protocol.DataType.longlong},
    name_len        = {type = Protocol.DataType.short},
    name            = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    lvl             = {type = Protocol.DataType.short},
    country_id      = {type = Protocol.DataType.short},
    img_type        = {type = Protocol.DataType.short},
    img_id          = {type = Protocol.DataType.int},
    item_id         = {type = Protocol.DataType.short},
    fields          = {'role_id','name_len','name','lvl','country_id','img_type','img_id','item_id'}
}

Protocol.Packet_S2C_CropRedbagDetail = {
    id              = {type = Protocol.DataType.longlong},
    count           = {type = Protocol.DataType.short},
    items           = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CropRedbagItems'},
    fields          = {'id','count','items'}
}
Protocol.structs[Protocol.S_2_C_CROP_REDBAG_DETAIL] = Protocol.Packet_S2C_CropRedbagDetail

Protocol.Packet_S2C_CropRedbagOver = {
    id              = {type = Protocol.DataType.longlong},
    fields          = {'id'}
}
Protocol.structs[Protocol.S_2_C_CROP_REDBAG_OVER] = Protocol.Packet_S2C_CropRedbagOver

Protocol.Data_InstanceLoad = {
    id       = {type = Protocol.DataType.short},
    troop_id = {type = Protocol.DataType.int},
    star     = {type = Protocol.DataType.short},
    fields   = {'id','troop_id','star'}
}

Protocol.Packet_S2C_CropInstanceLoad = {
    reward    = {type = Protocol.DataType.short}, --0: not reward 1:already reward
    times     = {type = Protocol.DataType.short},
    troop_id  = {type = Protocol.DataType.int},
    count     = {type = Protocol.DataType.short},
    instances = {type = Protocol.DataType.object, length = -1, clazz = 'Data_InstanceLoad'},
    fields    = {'reward','times','troop_id','count','instances'}
}
Protocol.structs[Protocol.S_2_C_CROP_INSTANCE_LOAD] = Protocol.Packet_S2C_CropInstanceLoad

Protocol.Packet_C2S_CropInstanceBattle = {
    id       = {type = Protocol.DataType.short},
    troop_id = {type = Protocol.DataType.int},
    fields   = {'id','troop_id'}
}
Protocol.structs[Protocol.C_2_S_CROP_INSTANCE_BATTLE] = Protocol.Packet_C2S_CropInstanceBattle

Protocol.Packet_S2C_CropInstanceBattle = {
    id         = {type = Protocol.DataType.short},
    troop_id   = {type = Protocol.DataType.int},
    battle_ret = {type = Protocol.DataType.short},
    report_id  = {type = Protocol.DataType.llstring},
    fields     = {'id','troop_id','battle_ret','report_id'}
}
Protocol.structs[Protocol.S_2_C_CROP_INSTANCE_BATTLE] = Protocol.Packet_S2C_CropInstanceBattle

Protocol.Packet_S2C_CropInstanceDraw = {
    ret    = {type = Protocol.DataType.short},
    fields = {'ret'}
}
Protocol.structs[Protocol.S_2_C_CROP_INSTANCE_DRAW] = Protocol.Packet_S2C_CropInstanceDraw

Protocol.Packet_C2S_CropInstanceLogLoad = {
    id     = {type = Protocol.DataType.short},
    fields = {'id'}
}
Protocol.structs[Protocol.C_2_S_CROP_INSTANCE_LOG_LOAD] = Protocol.Packet_C2S_CropInstanceLogLoad

Protocol.Data_InstanceLogLoad = {
    role_id      = {type = Protocol.DataType.longlong},
    len          = {type = Protocol.DataType.short},
    name         = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    battle_ret   = {type = Protocol.DataType.short},
    report_id    = {type = Protocol.DataType.llstring},
    legion_level = {type = Protocol.DataType.short},
    mode_id      = {type = Protocol.DataType.short},
    troop_id     = {type = Protocol.DataType.int},
    time         = {type = Protocol.DataType.int},
    power        = {type = Protocol.DataType.int},
    img_type     = {type = Protocol.DataType.short},
    img_id       = {type = Protocol.DataType.int},
    fields     = {'role_id','len','name','battle_ret','report_id','legion_level','mode_id','troop_id','time','power','img_type','img_id'}
}

Protocol.Packet_S2C_CropInstanceLogLoad = {
    id     = {type = Protocol.DataType.short},
    count  = {type = Protocol.DataType.short},
    logs   = {type = Protocol.DataType.object, length = -1, clazz = 'Data_InstanceLogLoad'},
    fields = {'id','count','logs'}
}
Protocol.structs[Protocol.S_2_C_CROP_INSTANCE_LOG_LOAD] = Protocol.Packet_S2C_CropInstanceLogLoad

Protocol.Data_Crop_Formation = {
    index      = {type = Protocol.DataType.short},
    general_id = {type = Protocol.DataType.int},
    fields     = {'index','general_id'}
}

Protocol.Packet_S2C_CropInstanceFormationLoad = {
    formation_id = {type = Protocol.DataType.short},
    count        = {type = Protocol.DataType.short},
    general_loc  = {type = Protocol.DataType.object, length = -1, clazz = 'Data_Crop_Formation'},
    fields       = {'formation_id','count','general_loc'}
}
Protocol.structs[Protocol.S_2_C_CROP_INSTANCE_FORMATION_LOAD] = Protocol.Packet_S2C_CropInstanceFormationLoad

Protocol.Packet_C2S_CropInstanceFormationSave = {
    formation_id = {type = Protocol.DataType.int},
    count        = {type = Protocol.DataType.short},
    generals     = {type = Protocol.DataType.object, length = -1, clazz = 'Data_Crop_Formation'},
    fields       = {'formation_id','count','generals'}
}
Protocol.structs[Protocol.C_2_S_CROP_INSTANCE_FORMATION_SAVE] = Protocol.Packet_C2S_CropInstanceFormationSave

Protocol.Packet_S2C_CropInstanceFormationSave = {
    ret    = {type = Protocol.DataType.short},
    fields = {'ret'}
}
Protocol.structs[Protocol.S_2_C_CROP_INSTANCE_FORMATION_SAVE] = Protocol.Packet_S2C_CropInstanceFormationSave
