local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_LOAD_RANK_INFO        = Protocol.C_2_S_RANK_BASE + 0
Protocol.C_2_S_RANK_POWER_SELF_INFO  = Protocol.C_2_S_RANK_BASE + 1
Protocol.C_2_S_RANK_POWER_PROGRESS   = Protocol.C_2_S_RANK_BASE + 2
Protocol.C_2_S_LOAD_ROLE_INFO_BY_ID  = Protocol.C_2_S_RANK_BASE + 3
Protocol.C_2_S_LOAD_CROP_RANK_INFO   = Protocol.C_2_S_RANK_BASE + 4

Protocol.S_2_C_LOAD_RANK_INFO        = Protocol.S_2_C_RANK_BASE + 0
Protocol.S_2_C_RANK_SELF_INFO        = Protocol.S_2_C_RANK_BASE + 1
Protocol.S_2_C_RANK_POWER_SELF_INFO  = Protocol.S_2_C_RANK_BASE + 2
Protocol.S_2_C_RANK_POWER_ATTRI_INFO = Protocol.S_2_C_RANK_BASE + 3
Protocol.S_2_C_RANK_POWER_PROGRESS   = Protocol.S_2_C_RANK_BASE + 4
Protocol.S_2_C_LOAD_ROLE_INFO_BY_ID  = Protocol.S_2_C_RANK_BASE + 5
Protocol.S_2_C_LOAD_RANK_BEGIN       = Protocol.S_2_C_RANK_BASE + 6
Protocol.S_2_C_LOAD_RANK_END         = Protocol.S_2_C_RANK_BASE + 7
Protocol.S_2_C_LOAD_CROP_RANK_INFO   = Protocol.S_2_C_RANK_BASE + 8

Protocol.Packet_C2S_LoadRankInfo = {
    rankType = {type = Protocol.DataType.short},
    fields   = {'rankType'}
}
Protocol.structs[Protocol.C_2_S_LOAD_RANK_INFO]  = Protocol.Packet_C2S_LoadRankInfo

Protocol.Data_RankInfo = {
    id            = {type = Protocol.DataType.longlong},
    playerNameLen = {type = Protocol.DataType.short},
    playerName    = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    countryId     = {type = Protocol.DataType.int},
    attackValue   = {type = Protocol.DataType.int},
    crop_name_len = {type = Protocol.DataType.short},
    crop_name     = {type = Protocol.DataType.string, length = Protocol.MAX_CROPS_NAME_LEN},
    img_type      = {type = Protocol.DataType.short},
    img_id        = {type = Protocol.DataType.int},
    crop_icon     = {type = Protocol.DataType.short},
    fields        = {'id', 'playerNameLen','playerName', 'countryId', 'attackValue', 'crop_name_len', 'crop_name','img_type','img_id','crop_icon'}
}

Protocol.Packet_S2C_LoadRankInfo = {
    rankCount      = {type = Protocol.DataType.short},
    rankInfo       = {type = Protocol.DataType.object, length = -1, clazz = 'Data_RankInfo'},
    fields         = {'rankCount','rankInfo'}
}
Protocol.structs[Protocol.S_2_C_LOAD_RANK_INFO]  = Protocol.Packet_S2C_LoadRankInfo

Protocol.Packet_C2S_LoadRoleInfoByID = {
    id     = {type = Protocol.DataType.longlong},
    fields = {'id'}
}
Protocol.structs[Protocol.C_2_S_LOAD_ROLE_INFO_BY_ID]  = Protocol.Packet_C2S_LoadRoleInfoByID

Protocol.Packet_S2C_RankSelfInfo = {
    value  = {type = Protocol.DataType.int},
    rank   = {type = Protocol.DataType.int},
    fields = {'value','rank'}
}
Protocol.structs[Protocol.S_2_C_RANK_SELF_INFO]  = Protocol.Packet_S2C_RankSelfInfo

Protocol.Packet_S2C_RankPowerSelfInfo = {
    value  = {type = Protocol.DataType.int},
    rank   = {type = Protocol.DataType.int},
    fields = {'value','rank'}
}
Protocol.structs[Protocol.S_2_C_RANK_POWER_SELF_INFO]  = Protocol.Packet_S2C_RankPowerSelfInfo

Protocol.Data_GeneralPowerInfo = {
    generalId = {type = Protocol.DataType.int},
    value     = {type = Protocol.DataType.int},
    fields    = {'generalId','value'}
}

Protocol.Packet_S2C_RankPowerAttriInfo = {
    allPowerValue       = {type = Protocol.DataType.int},
    medalVal            = {type = Protocol.DataType.int},
    bosomFriendVal      = {type = Protocol.DataType.int},
    generalSoulVal      = {type = Protocol.DataType.int},
    horseLeaderAttri    = {type = Protocol.DataType.int},
    horseAttackAttri    = {type = Protocol.DataType.int},
    horseMentalityAttri = {type = Protocol.DataType.int},
    horseEqAttri        = {type = Protocol.DataType.int},
    horseExAttri        = {type = Protocol.DataType.int},
    medalRate           = {type = Protocol.DataType.double},
    techRate            = {type = Protocol.DataType.double},
    bosomFriendRate     = {type = Protocol.DataType.double},
    officialRate        = {type = Protocol.DataType.double},
    horseRateAttri      = {type = Protocol.DataType.double},
    count               = {type = Protocol.DataType.short},
    generalPowerInfo    = {type = Protocol.DataType.object, length = -1, clazz = 'Data_GeneralPowerInfo'},
    fields              = {'allPowerValue','medalVal','bosomFriendVal','generalSoulVal','horseLeaderAttri','horseAttackAttri','horseMentalityAttri','horseEqAttri','horseExAttri','medalRate','techRate','bosomFriendRate','officialRate','horseRateAttri','count','generalPowerInfo'}
}
Protocol.structs[Protocol.S_2_C_RANK_POWER_ATTRI_INFO]  = Protocol.Packet_S2C_RankPowerAttriInfo

Protocol.Packet_S2C_RankPowerProgress = {
    generalNum           = {type = Protocol.DataType.int},
    generalLv            = {type = Protocol.DataType.int},
    generalNavyLevel     = {type = Protocol.DataType.int},
    eqAttriEx            = {type = Protocol.DataType.int},
    transferSoldierTimes = {type = Protocol.DataType.int},
    generalsoul          = {type = Protocol.DataType.int},
    eqLv                 = {type = Protocol.DataType.int},
    medalLv              = {type = Protocol.DataType.int},
    controlSoldierLvl    = {type = Protocol.DataType.int},
    techLv               = {type = Protocol.DataType.int},
    bosomFriendLv        = {type = Protocol.DataType.int},
    bosomFriendRate      = {type = Protocol.DataType.int},
    horsePower           = {type = Protocol.DataType.int},
    skillLv              = {type = Protocol.DataType.int},
    fields               = {'generalNum','generalLv','generalNavyLevel','eqAttriEx','transferSoldierTimes','generalsoul','eqLv','medalLv','controlSoldierLvl','techLv','bosomFriendLv','bosomFriendRate','horsePower','skillLv'}
}
Protocol.structs[Protocol.S_2_C_RANK_POWER_PROGRESS]  = Protocol.Packet_S2C_RankPowerProgress

Protocol.Data_RoleGeneral = {
    general_id = {type = Protocol.DataType.int},
    rtemp_id   = {type = Protocol.DataType.int},
    level      = {type = Protocol.DataType.int},
    grade      = {type = Protocol.DataType.short},
    len        = {type = Protocol.DataType.short},
    name       = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    fields     = {'general_id','rtemp_id','level','grade','len','name'}
}

Protocol.Packet_S2C_LoadRoleInfoByID = {
    role_name_len = {type = Protocol.DataType.short},
    role_name     = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    crop_name_len = {type = Protocol.DataType.short},
    crop_name     = {type = Protocol.DataType.string, length = Protocol.MAX_CROPS_NAME_LEN},
    prestige      = {type = Protocol.DataType.int}, --威望（官职）
    area_id       = {type = Protocol.DataType.int}, --区域ID
    seq_no        = {type = Protocol.DataType.int}, --区域位置编号
    role_lvl      = {type = Protocol.DataType.int},
    master_lvl    = {type = Protocol.DataType.int},
    img_type      = {type = Protocol.DataType.int}, --头像类型
    img_id        = {type = Protocol.DataType.int}, --头像id
    country_id    = {type = Protocol.DataType.int},
    power         = {type = Protocol.DataType.int}, --战力
    crop_icon     = {type = Protocol.DataType.short},
    general_num   = {type = Protocol.DataType.short},
    generals      = {type = Protocol.DataType.object, length = -1, clazz = 'Data_RoleGeneral'},
    role_id       = {type = Protocol.DataType.longlong},
    fields        = {'role_name_len','role_name','crop_name_len','crop_name','prestige','area_id','seq_no','role_lvl','master_lvl','img_type','img_id','country_id','power','crop_icon','general_num','generals','role_id'}
}
Protocol.structs[Protocol.S_2_C_LOAD_ROLE_INFO_BY_ID]  = Protocol.Packet_S2C_LoadRoleInfoByID

Protocol.Packet_S2C_LoadRankInfoBegin = {
    rankType       = {type = Protocol.DataType.short},
    playertotalNum = {type = Protocol.DataType.int},
    myValue        = {type = Protocol.DataType.int},
    myRank         = {type = Protocol.DataType.int},
    fields         = {'rankType','playertotalNum','myValue','myRank'}
}
Protocol.structs[Protocol.S_2_C_LOAD_RANK_BEGIN]  = Protocol.Packet_S2C_LoadRankInfoBegin

Protocol.Packet_S2C_LoadRankInfoEnd = {
    fields   = {}
}
Protocol.structs[Protocol.S_2_C_LOAD_RANK_END]  = Protocol.Packet_S2C_LoadRankInfoEnd

Protocol.Packet_C2S_LoadCropRankInfo = {
    rank_type = {type = Protocol.DataType.short},
    fields    = {'rank_type'}
}
Protocol.structs[Protocol.C_2_S_LOAD_CROP_RANK_INFO]  = Protocol.Packet_C2S_LoadCropRankInfo

Protocol.Data_CropRankInfo = {
    crop_id     = {type = Protocol.DataType.int},
    len1        = {type = Protocol.DataType.short},
    player_name = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    country_id  = {type = Protocol.DataType.int},
    value       = {type = Protocol.DataType.int},
    len2        = {type = Protocol.DataType.short},
    crop_name   = {type = Protocol.DataType.string, length = Protocol.MAX_CROPS_NAME_LEN},
    img_type    = {type = Protocol.DataType.short},
    img_id      = {type = Protocol.DataType.int},
    crop_icon   = {type = Protocol.DataType.short},
    fields      = {'crop_id','len1','player_name','country_id','value','len2','crop_name','img_type','img_id','crop_icon'}
}

Protocol.Packet_S2C_LoadCropRankInfo = {
    rank_type = {type = Protocol.DataType.short},
    my_value  = {type = Protocol.DataType.int},
    my_rank   = {type = Protocol.DataType.int},
    count     = {type = Protocol.DataType.short},
    rank_info = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CropRankInfo'},
    fields    = {'rank_type','my_value','my_rank','count','rank_info'}
}
Protocol.structs[Protocol.S_2_C_LOAD_CROP_RANK_INFO]  = Protocol.Packet_S2C_LoadCropRankInfo
