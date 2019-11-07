local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_LOAD_OFFICIALPOSITION           = Protocol.C_2_S_OFFICIALPOSITION_BASE + 0
Protocol.C_2_S_DRAW_SALARY                     = Protocol.C_2_S_OFFICIALPOSITION_BASE + 1
Protocol.C_2_S_GESTE_TO_PRESTIGE               = Protocol.C_2_S_OFFICIALPOSITION_BASE + 2
Protocol.C_2_S_LOAD_FOLLOWER_INFO_BY_ID        = Protocol.C_2_S_OFFICIALPOSITION_BASE + 3
Protocol.C_2_S_GIVE_UP_FOLLOWER                = Protocol.C_2_S_OFFICIALPOSITION_BASE + 4

Protocol.S_2_C_LOAD_OFFICIALPOSITION           = Protocol.S_2_C_OFFICIALPOSITION_BASE + 0
Protocol.S_2_C_DRAW_SALARY                     = Protocol.S_2_C_OFFICIALPOSITION_BASE + 1
Protocol.S_2_C_GESTE_TO_PRESTIGE               = Protocol.S_2_C_OFFICIALPOSITION_BASE + 2
Protocol.S_2_C_LOAD_FOLLOWER_INFO_BY_ID        = Protocol.S_2_C_OFFICIALPOSITION_BASE + 3
Protocol.S_2_C_GIVE_UP_FOLLOWER                = Protocol.S_2_C_OFFICIALPOSITION_BASE + 4
Protocol.S_2_C_UPDATE_AREA_PLAYER_NAME         = Protocol.S_2_C_OFFICIALPOSITION_BASE + 5
Protocol.S_2_C_GLOBAL_MAIL_COMPENSATION_NOTICE = Protocol.S_2_C_OFFICIALPOSITION_BASE + 6
Protocol.S_2_C_GLOBAL_COMPENSATION_MAIL_INFO   = Protocol.S_2_C_OFFICIALPOSITION_BASE + 7
Protocol.S_2_C_SUB_CITY_REWARD_DRAW            = Protocol.S_2_C_OFFICIALPOSITION_BASE + 8
Protocol.S_2_C_MAJESTY_REWARD_DRAW             = Protocol.S_2_C_OFFICIALPOSITION_BASE + 9

Protocol.Packet_S2C_LoadOfficialPosition = {
    IsDrawSalary      = {type = Protocol.DataType.char},
    curCanGetPrestige = {type = Protocol.DataType.uint},
    fields            = {'IsDrawSalary','curCanGetPrestige'}
}
Protocol.structs[Protocol.S_2_C_LOAD_OFFICIALPOSITION]  = Protocol.Packet_S2C_LoadOfficialPosition

Protocol.Packet_S2C_DrawSalary = {
    ret    = {type = Protocol.DataType.char},
    fields = {'ret'}
}
Protocol.structs[Protocol.S_2_C_DRAW_SALARY]  = Protocol.Packet_S2C_DrawSalary

Protocol.Packet_S2C_GesteToPrestige = {
    curCanGetPrestige = {type = Protocol.DataType.uint},
    refreshTime       = {type = Protocol.DataType.uint},
    fields            = {'curCanGetPrestige','refreshTime'}
}
Protocol.structs[Protocol.S_2_C_GESTE_TO_PRESTIGE]  = Protocol.Packet_S2C_GesteToPrestige

Protocol.Data_FollowerInfo = {
    followerId   = {type = Protocol.DataType.ulonglong},
    followerLen  = {type = Protocol.DataType.ushort},
    followerName = {type = Protocol.DataType.char, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    level        = {type = Protocol.DataType.int},
    worldAreaId  = {type = Protocol.DataType.int},
    areaId       = {type = Protocol.DataType.int},
    fields       = {'followerId','followerLen','followerName','level','worldAreaId','areaId',}
}

Protocol.Packet_S2C_LoadFollowerInfoById = {
    leftNum      = {type = Protocol.DataType.int},
    count        = {type = Protocol.DataType.int},
    followerInfo = {type = Protocol.DataType.object, length = -1, clazz='Data_FollowerInfo'},
    fields       = {'leftNum','count','followerInfo'}
}
Protocol.structs[Protocol.S_2_C_LOAD_FOLLOWER_INFO_BY_ID]  = Protocol.Packet_S2C_LoadFollowerInfoById

Protocol.Packet_S2C_GiveUpFollower = {
    ret    = {type = Protocol.DataType.char},
    fields = {'ret'}
}
Protocol.structs[Protocol.S_2_C_GIVE_UP_FOLLOWER]  = Protocol.Packet_S2C_GiveUpFollower

Protocol.Packet_S2C_UpdateAreaPlayerName = {
    world_area_id = {type = Protocol.DataType.int},
    area_id       = {type = Protocol.DataType.char},
    area_index    = {type = Protocol.DataType.int},
    old_name_len  = {type = Protocol.DataType.short},
    old_name      = {type = Protocol.DataType.char, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    new_name_len  = {type = Protocol.DataType.short},
    new_name      = {type = Protocol.DataType.char, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    fields        = {'world_area_id','area_id','area_index','old_name_len','old_name','new_name_len','new_name',}
}
Protocol.structs[Protocol.S_2_C_UPDATE_AREA_PLAYER_NAME]  = Protocol.Packet_S2C_UpdateAreaPlayerName

Protocol.Packet_S2C_GlobalMailCompensationNotice = {
    mail_type = {type = Protocol.DataType.char},
    id        = {type = Protocol.DataType.int},
    limitlv   = {type = Protocol.DataType.int},
    fields    = {'mail_type','id','limitlv'}
}
Protocol.structs[Protocol.S_2_C_GLOBAL_MAIL_COMPENSATION_NOTICE]  = Protocol.Packet_S2C_GlobalMailCompensationNotice

Protocol.Data_MailInfo = {
    id            = {type = Protocol.DataType.ulonglong},
    senderNameLen = {type = Protocol.DataType.short},
    senderName    = {type = Protocol.DataType.string, length = -1},
    state         = {type = Protocol.DataType.char},
    get_state     = {type = Protocol.DataType.char},
    type          = {type = Protocol.DataType.char},
    titleLen      = {type = Protocol.DataType.short},
    title         = {type = Protocol.DataType.string, length = -1},
    contentLen    = {type = Protocol.DataType.short},
    content       = {type = Protocol.DataType.string, length = -1},
    rewardLen     = {type = Protocol.DataType.short},
    reward        = {type = Protocol.DataType.string, length = -1},
    year          = {type = Protocol.DataType.int},
    season        = {type = Protocol.DataType.char},
    send_time     = {type = Protocol.DataType.int},
    fields        = {'id','senderNameLen','senderName','state','get_state','type','titleLen','title','contentLen','content','rewardLen','reward','year','season','send_time',}
}

Protocol.Packet_S2C_GlobalCompensationMailInfo = {
    id        = {type = Protocol.DataType.int},
    mail_data = {type = Protocol.DataType.object, clazz = 'Data_MailInfo'},
    fields    = {'id','mail_data'}
}
Protocol.structs[Protocol.S_2_C_GLOBAL_COMPENSATION_MAIL_INFO]  = Protocol.Packet_S2C_GlobalCompensationMailInfo

Protocol.Packet_S2C_SubCityRewardDraw = {
    rewardNum = {type = Protocol.DataType.int},
    leftNum   = {type = Protocol.DataType.int},
    fields    = {'rewardNum','leftNum'}
}
Protocol.structs[Protocol.S_2_C_SUB_CITY_REWARD_DRAW]  = Protocol.Packet_S2C_SubCityRewardDraw

Protocol.Packet_S2C_MajestyRewardDraw = {
    drawType  = {type = Protocol.DataType.int},
    rewardNum = {type = Protocol.DataType.int},
    leftNum   = {type = Protocol.DataType.int},
    fields    = {'drawType','rewardNum','leftNum'}
}
Protocol.structs[Protocol.S_2_C_MAJESTY_REWARD_DRAW]  = Protocol.Packet_S2C_MajestyRewardDraw
