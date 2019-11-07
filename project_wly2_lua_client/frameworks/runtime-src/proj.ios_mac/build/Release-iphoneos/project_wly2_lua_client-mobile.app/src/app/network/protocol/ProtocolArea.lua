local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_AREA_PARTLOAD                    = Protocol.C_2_S_AREA_BASE + 0
Protocol.C_2_S_AREA_GETMAXSEQNO                 = Protocol.C_2_S_AREA_BASE + 1
Protocol.C_2_S_AREA_ADDCITY                     = Protocol.C_2_S_AREA_BASE + 2
Protocol.C_2_S_AREA_MOVECITY                    = Protocol.C_2_S_AREA_BASE + 3
Protocol.C_2_S_AREA_DELCITY                     = Protocol.C_2_S_AREA_BASE + 4
Protocol.C_2_S_AREA_CITYINFO                    = Protocol.C_2_S_AREA_BASE + 5
Protocol.C_2_S_FOLLOWER_INFO                    = Protocol.C_2_S_AREA_BASE + 6

Protocol.S_2_C_AREA_REQUEST_PARTLOAD            = Protocol.S_2_C_AREA_BASE + 0
Protocol.S_2_C_AREA_PARTINFO                    = Protocol.S_2_C_AREA_BASE + 1
Protocol.S_2_C_AREA_MAXSEQNO                    = Protocol.S_2_C_AREA_BASE + 2
Protocol.S_2_C_AREA_REQUEST_MAXREQ              = Protocol.S_2_C_AREA_BASE + 3
Protocol.S_2_C_AREA_INFO                        = Protocol.S_2_C_AREA_BASE + 4
Protocol.S_2_C_AREA_PLAYER_DEL                  = Protocol.S_2_C_AREA_BASE + 5
Protocol.S_2_C_AREA_ZONE_ADD                    = Protocol.S_2_C_AREA_BASE + 6
Protocol.S_2_C_AREA_ZONE_INFO                   = Protocol.S_2_C_AREA_BASE + 7
Protocol.S_2_C_FOLLOWER_INFO                    = Protocol.S_2_C_AREA_BASE + 8
Protocol.S_2_C_FOLLOWER_CHANGE                  = Protocol.S_2_C_AREA_BASE + 9

------------------------------C_2_S------------------------------
Protocol.Packet_C2S_AreaPartLoad = {
    --C_2_S_AREA_PARTLOAD
    area_id = {type = Protocol.DataType.uint},
    part_id = {type = Protocol.DataType.uint},
    fields  = {'area_id','part_id'}
}
Protocol.structs[Protocol.C_2_S_AREA_PARTLOAD]               = Protocol.Packet_C2S_AreaPartLoad

Protocol.Packet_C2S_AreaGetMaxSeqNo = {
    area_id = {type = Protocol.DataType.uint},
    fields  = {'area_id'}
}
Protocol.structs[Protocol.C_2_S_AREA_GETMAXSEQNO]               = Protocol.Packet_C2S_AreaGetMaxSeqNo

Protocol.Packet_C2S_AreaMoveCity = {
    area_id_R           = {type = Protocol.DataType.uint},
    area_id_D           = {type = Protocol.DataType.uint},
    fields              = {'area_id_R','area_id_D'}
}
Protocol.structs[Protocol.C_2_S_AREA_MOVECITY]               = Protocol.Packet_C2S_AreaMoveCity

Protocol.Packet_C2S_AreaCityInfo = {
    --C_2_S_AREA_CITYINFO
    world_area_id   = {type = Protocol.DataType.uint},
    area_zone_index = {type = Protocol.DataType.uint},
    zone_index      = {type = Protocol.DataType.char},
    name_len        = {type = Protocol.DataType.ushort},
    player_name     = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    fields          = {'world_area_id','area_zone_index','zone_index','name_len','player_name'}
}
Protocol.structs[Protocol.C_2_S_AREA_CITYINFO]               = Protocol.Packet_C2S_AreaCityInfo

Protocol.Packet_C2S_FollowerInfo = {
    --C_2_S_FOLLOWER_INFO
    name_len    = {type = Protocol.DataType.ushort},
    player_name = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    fields  = {'name_len','player_name'}
}
Protocol.structs[Protocol.C_2_S_FOLLOWER_INFO]               = Protocol.Packet_C2S_FollowerInfo

------------------------------S_2_C------------------------------
Protocol.Data_AreaInfo_S2C = {
    seq_no        = {type = Protocol.DataType.char},                --zone在区域中的位置
    playerNameLen = {type = Protocol.DataType.ushort},           --名字
    playerName    = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    flagNameLen   = {type = Protocol.DataType.ushort},   --旗帜
    flagName      = {type = Protocol.DataType.string, length = Protocol.MAX_FLAG_NAME_LEN},
    isRefuseFight = {type = Protocol.DataType.char},          --是佛免战
    appeance_type = {type = Protocol.DataType.char},--c玩家城池外貌
    country_type  = {type = Protocol.DataType.char},--所属国家
    attackVal     = {type = Protocol.DataType.uint},--攻击值
    protectTime   = {type = Protocol.DataType.uint},--对战保护时间
    officer       = {type = Protocol.DataType.char}, --官职信息
    city_skin     = {type = Protocol.DataType.int},
    owner_lvl     = {type = Protocol.DataType.int},
    fields        = {'seq_no','playerNameLen','playerName','flagNameLen','flagName','isRefuseFight','appeance_type','country_type','attackVal','protectTime','officer','city_skin','owner_lvl'}
}

Protocol.Packet_S2C_AreaPartInfo = {
    area_id         = {type = Protocol.DataType.char},
    area_zone_index = {type = Protocol.DataType.uint},
    city_count      = {type = Protocol.DataType.char},
    city            = {type = Protocol.DataType.object, length = -1, clazz = 'Data_AreaInfo_S2C'},
    fields          = {'area_id','area_zone_index','city_count','city'}
}
Protocol.structs[Protocol.S_2_C_AREA_PARTINFO]               = Protocol.Packet_S2C_AreaPartInfo

Protocol.Packet_S2C_AreaMaxSeqNo = {
    area_id     = {type = Protocol.DataType.char},
    city_seq_no = {type = Protocol.DataType.uint},
    fields      = {'area_id','city_seq_no'}
}
Protocol.structs[Protocol.S_2_C_AREA_MAXSEQNO]               = Protocol.Packet_S2C_AreaMaxSeqNo

Protocol.Packet_S2C_AreaPlayerDel = {
    area_id         = {type = Protocol.DataType.char},
    area_zone_index = {type = Protocol.DataType.uint},
    zone_index      = {type = Protocol.DataType.char},
    fields          = {'area_id','area_zone_index','zone_index'}
}
Protocol.structs[Protocol.S_2_C_AREA_PLAYER_DEL]               = Protocol.Packet_S2C_AreaPlayerDel

Protocol.Packet_S2C_AreaZoneAdd = {
    --S_2_C_AREA_ZONE_ADD
    area_id         = {type = Protocol.DataType.char},
    area_zone_index = {type = Protocol.DataType.uint},
    area_zone       = {type = Protocol.DataType.object, clazz = 'Data_AreaInfo_S2C'},
    fields          = {'area_id','area_zone_index','area_zone'}
}
Protocol.structs[Protocol.S_2_C_AREA_ZONE_ADD]               = Protocol.Packet_S2C_AreaZoneAdd

Protocol.Data_MasterNameInfo = {
    feudatory_NameLen = {type = Protocol.DataType.ushort},         --臣属
    feudatory_Name    = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    fields            = {'feudatory_NameLen','feudatory_Name'}
}

Protocol.Data_AreaZoneMasterInfo = {
    master_NameLen  = {type = Protocol.DataType.ushort},           --主公名
    master_Name     = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    master_name_info = {type = Protocol.DataType.object, length = Protocol.MASTER_NAME_INFO_NUM, clazz = 'Data_MasterNameInfo'},
    fields           = {'master_NameLen','master_Name','master_name_info'}
}

Protocol.Packet_S2C_AreaZoneInfo = {
    --S_2_C_AREA_ZONE_INFO
    leaveMsgLen   = {type = Protocol.DataType.ushort},
    leaveMsg      = {type = Protocol.DataType.string, length = Protocol.MAX_LEAVE_MSG_LEN},
    world_area_id = {type = Protocol.DataType.uint},
    area_zone_id  = {type = Protocol.DataType.uint},
    zone_index    = {type = Protocol.DataType.char},
    charac_lvl    = {type = Protocol.DataType.char},
    master_info   = {type = Protocol.DataType.object, clazz = 'Data_AreaZoneMasterInfo'},
    cropsId       = {type = Protocol.DataType.uint},
    img_type      = {type = Protocol.DataType.char},
    img_id        = {type = Protocol.DataType.int},
    fields        = {'leaveMsgLen','leaveMsg','world_area_id','area_zone_id','zone_index','charac_lvl','master_info','cropsId','img_type','img_id'}
}
Protocol.structs[Protocol.S_2_C_AREA_ZONE_INFO]               = Protocol.Packet_S2C_AreaZoneInfo

Protocol.Packet_S2C_FollowerInfo = {
    --S_2_C_FOLLOWER_INFO
    name_len        = {type = Protocol.DataType.ushort},
    player_name     = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    lvl             = {type = Protocol.DataType.ushort},
    honor           = {type = Protocol.DataType.uint},
    corp_id         = {type = Protocol.DataType.uint},
    world_area_id   = {type = Protocol.DataType.uint},
    area_zone_index = {type = Protocol.DataType.uint},
    img_type        = {type = Protocol.DataType.char},
    img_id          = {type = Protocol.DataType.int},
    corpsNameLen    = {type = Protocol.DataType.ushort},
    corpsName       = {type = Protocol.DataType.string, length = Protocol.MAX_CROPS_NAME_LEN},
    fields          = {'name_len','player_name','lvl','honor','corp_id','world_area_id','area_zone_index','img_type','img_id','corpsNameLen','corpsName'}
}
Protocol.structs[Protocol.S_2_C_FOLLOWER_INFO]               = Protocol.Packet_S2C_FollowerInfo
