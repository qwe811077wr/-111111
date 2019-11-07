local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_LOAD_ALL_CROP_INFO          = Protocol.C_2_S_CROPS_BASE + 1
Protocol.C_2_S_LOAD_CROP_INFO              = Protocol.C_2_S_CROPS_BASE + 2
Protocol.C_2_S_DO_CREATE_CROP              = Protocol.C_2_S_CROPS_BASE + 3
Protocol.C_2_S_LOAD_ALL_MEMBER             = Protocol.C_2_S_CROPS_BASE + 4
Protocol.C_2_S_LOAD_ALL_APPLY_MEMBER       = Protocol.C_2_S_CROPS_BASE + 5
Protocol.C_2_S_CROP_APPLY                  = Protocol.C_2_S_CROPS_BASE + 8
Protocol.C_2_S_CROP_APPROVE                = Protocol.C_2_S_CROPS_BASE + 9
Protocol.C_2_S_CROP_REJECT                 = Protocol.C_2_S_CROPS_BASE + 10
Protocol.C_2_S_CROP_KICKOUT                = Protocol.C_2_S_CROPS_BASE + 11
Protocol.C_2_S_CROP_QUIT                   = Protocol.C_2_S_CROPS_BASE + 12
Protocol.C_2_S_CROP_DISMISS                = Protocol.C_2_S_CROPS_BASE + 13
Protocol.C_2_S_CROP_CANCEL_DISMISS         = Protocol.C_2_S_CROPS_BASE + 14
Protocol.C_2_S_MODIFY_BOARD_MESSAGE        = Protocol.C_2_S_CROPS_BASE + 15
Protocol.C_2_S_JOIN_SETTING                = Protocol.C_2_S_CROPS_BASE + 16
Protocol.C_2_S_LOAD_TECHNOLOGY             = Protocol.C_2_S_CROPS_BASE + 17
Protocol.C_2_S_CANCEL_APPLY                = Protocol.C_2_S_CROPS_BASE + 18
Protocol.C_2_S_CROP_CONTRIBUTE             = Protocol.C_2_S_CROPS_BASE + 19
Protocol.C_2_S_CROP_INVITE                 = Protocol.C_2_S_CROPS_BASE + 20
Protocol.C_2_S_CROP_UPDATE_HEAD_ID         = Protocol.C_2_S_CROPS_BASE + 21
Protocol.C_2_S_CROP_APPOINT                = Protocol.C_2_S_CROPS_BASE + 22
Protocol.C_2_S_CROP_APPLY_HELP             = Protocol.C_2_S_CROPS_BASE + 23
Protocol.C_2_S_CROP_LOAD_HELP              = Protocol.C_2_S_CROPS_BASE + 24
Protocol.C_2_S_CROP_LOAD_HELP_LOG          = Protocol.C_2_S_CROPS_BASE + 25
Protocol.C_2_S_CROP_DO_HELP                = Protocol.C_2_S_CROPS_BASE + 26

Protocol.S_2_C_LOAD_ALL_CROP_INFO_BEGIN    = Protocol.S_2_C_CROPS_BASE + 0
Protocol.S_2_C_LOAD_ALL_CROP_INFO          = Protocol.S_2_C_CROPS_BASE + 1
Protocol.S_2_C_LOAD_ALL_CROP_INFO_END      = Protocol.S_2_C_CROPS_BASE + 2
Protocol.S_2_C_LOAD_CROP_INFO              = Protocol.S_2_C_CROPS_BASE + 3
Protocol.S_2_C_CREATE_CROP                 = Protocol.S_2_C_CROPS_BASE + 4
Protocol.S_2_C_LOAD_ALL_MEMBER_BEGIN       = Protocol.S_2_C_CROPS_BASE + 5
Protocol.S_2_C_LOAD_ALL_MEMBER             = Protocol.S_2_C_CROPS_BASE + 6
Protocol.S_2_C_LOAD_ALL_MEMBER_END         = Protocol.S_2_C_CROPS_BASE + 7
Protocol.S_2_C_LOAD_ALL_APPLY_MEMBER_BEGIN = Protocol.S_2_C_CROPS_BASE + 8
Protocol.S_2_C_LOAD_ALL_APPLY_MEMBER       = Protocol.S_2_C_CROPS_BASE + 9
Protocol.S_2_C_LOAD_ALL_APPLY_MEMBER_END   = Protocol.S_2_C_CROPS_BASE + 10
Protocol.S_2_C_CROP_APPLY                  = Protocol.S_2_C_CROPS_BASE + 11
Protocol.S_2_C_CROP_APPROVE                = Protocol.S_2_C_CROPS_BASE + 12
Protocol.S_2_C_CROP_APPROVE_NOTIFY         = Protocol.S_2_C_CROPS_BASE + 13
Protocol.S_2_C_CROP_REJECT                 = Protocol.S_2_C_CROPS_BASE + 14
Protocol.S_2_C_CROP_KICKOUT                = Protocol.S_2_C_CROPS_BASE + 15
Protocol.S_2_C_CROP_KICKOUT_NOTIFY         = Protocol.S_2_C_CROPS_BASE + 16
Protocol.S_2_C_CROP_QUIT                   = Protocol.S_2_C_CROPS_BASE + 17
Protocol.S_2_C_CROP_DISMISS                = Protocol.S_2_C_CROPS_BASE + 18
Protocol.S_2_C_CROP_CANCEL_DISMISS         = Protocol.S_2_C_CROPS_BASE + 19
Protocol.S_2_C_MODIFY_BOARD_MESSAGE        = Protocol.S_2_C_CROPS_BASE + 20
Protocol.S_2_C_CROP_JOIN_SETTING           = Protocol.S_2_C_CROPS_BASE + 21
Protocol.S_2_C_LOAD_TECHNOLOGY             = Protocol.S_2_C_CROPS_BASE + 22
Protocol.S_2_C_CANCEL_APPLY                = Protocol.S_2_C_CROPS_BASE + 23
Protocol.S_2_C_CROP_CONTRIBUTE             = Protocol.S_2_C_CROPS_BASE + 24
Protocol.S_2_C_CROP_INVITE                 = Protocol.S_2_C_CROPS_BASE + 25
Protocol.S_2_C_CROP_INVITE_NOTIEY          = Protocol.S_2_C_CROPS_BASE + 26
Protocol.S_2_C_CROP_UPDATE_HEAD_ID         = Protocol.S_2_C_CROPS_BASE + 27
Protocol.S_2_C_CROP_APPOINT_NOTIFY         = Protocol.S_2_C_CROPS_BASE + 28
Protocol.S_2_C_CROP_APPLY_HELP             = Protocol.S_2_C_CROPS_BASE + 29
Protocol.S_2_C_CROP_HELP_UPDATE            = Protocol.S_2_C_CROPS_BASE + 30
Protocol.S_2_C_CROP_LOAD_HELP              = Protocol.S_2_C_CROPS_BASE + 31
Protocol.S_2_C_CROP_LOAD_HELP_LOG          = Protocol.S_2_C_CROPS_BASE + 32
Protocol.S_2_C_CROP_DO_HELP                = Protocol.S_2_C_CROPS_BASE + 33
Protocol.S_2_C_CROP_HELP_DEL               = Protocol.S_2_C_CROPS_BASE + 34


Protocol.Packet_C2S_CropsAppoint = {
    role_id     = {type = Protocol.DataType.longlong},
    pos         = {type = Protocol.DataType.short},
    city_id     = {type = Protocol.DataType.short},
    fields      = {'role_id','pos','city_id'}
}
Protocol.structs[Protocol.C_2_S_CROP_APPOINT]  = Protocol.Packet_C2S_CropsAppoint

Protocol.Data_AppointNotify = {
    role_id     = {type = Protocol.DataType.longlong},
    pos         = {type = Protocol.DataType.short},
    pos_city    = {type = Protocol.DataType.short},
    fields      = {'role_id','pos','pos_city'}
}

Protocol.Packet_S2C_CropsAppointNotify = {
    count       = {type = Protocol.DataType.short},
    appoint     = {type = Protocol.DataType.object, length = -1, clazz = 'Data_AppointNotify'},
    fields      = {'count','appoint'}
}
Protocol.structs[Protocol.S_2_C_CROP_APPOINT_NOTIFY]  = Protocol.Packet_S2C_CropsAppointNotify

Protocol.Packet_C2S_LoadCropInfo = {
    id     = {type = Protocol.DataType.int},
    fields = {'id'}
}
Protocol.structs[Protocol.C_2_S_LOAD_CROP_INFO]  = Protocol.Packet_C2S_LoadCropInfo

Protocol.Packet_C2S_CreateCrop = {
    head_id   = {type = Protocol.DataType.short},
    len1      = {type = Protocol.DataType.short},
    name      = {type = Protocol.DataType.string, length = Protocol.MAX_CROPS_NAME_LEN},
    len2      = {type = Protocol.DataType.short},
    board_msg = {type = Protocol.DataType.string, length = Protocol.MAX_CROPS_DECLARE_MSG_LEN},
    fields    = {'head_id','len1','name','len2','board_msg'}
}
Protocol.structs[Protocol.C_2_S_DO_CREATE_CROP]  = Protocol.Packet_C2S_CreateCrop

Protocol.Packet_C2S_CropApply = {
     crop_id = {type = Protocol.DataType.int},
     fields  = {'crop_id'}
}
Protocol.structs[Protocol.C_2_S_CROP_APPLY]  = Protocol.Packet_C2S_CropApply

Protocol.Packet_C2S_CropApprove = {
    id     = {type = Protocol.DataType.longlong},
    fields = {'id'}
}
Protocol.structs[Protocol.C_2_S_CROP_APPROVE]  = Protocol.Packet_C2S_CropApprove

Protocol.Packet_C2S_CropReject = {
    id     = {type = Protocol.DataType.longlong},
    fields = {'id'}
}
Protocol.structs[Protocol.C_2_S_CROP_REJECT]  = Protocol.Packet_C2S_CropReject

Protocol.Packet_C2S_CropKickout = {
    id     = {type = Protocol.DataType.longlong},
    fields = {'id'}
}
Protocol.structs[Protocol.C_2_S_CROP_KICKOUT]  = Protocol.Packet_C2S_CropKickout

Protocol.Packet_C2S_ModifyBoardMessage = {
    len       = {type = Protocol.DataType.short},
    board_msg = {type = Protocol.DataType.string, length = Protocol.MAX_CROPS_DECLARE_MSG_LEN},
    fields    = {'len','board_msg'}
}
Protocol.structs[Protocol.C_2_S_MODIFY_BOARD_MESSAGE]  = Protocol.Packet_C2S_ModifyBoardMessage

Protocol.CROP_JOIN_LIMIT = {
    LEVEL = 1,
}

Protocol.Packet_C2S_CropJoinSetting = {
    auto_join   = {type = Protocol.DataType.short},
    limit_type  = {type = Protocol.DataType.short},
    limit_value = {type = Protocol.DataType.int},
    fields      = {'auto_join','limit_type','limit_value'}
}
Protocol.structs[Protocol.C_2_S_JOIN_SETTING]  = Protocol.Packet_C2S_CropJoinSetting

Protocol.Packet_C2S_CancelApply= {
    crop_id   = {type = Protocol.DataType.int},
    fields    = {'crop_id'}
}
Protocol.structs[Protocol.C_2_S_CANCEL_APPLY]  = Protocol.Packet_C2S_CancelApply

Protocol.Packet_C2S_CropInvite = {
    role_id   = {type = Protocol.DataType.longlong},
    fields    = {'role_id'}
}
Protocol.structs[Protocol.C_2_S_CROP_INVITE] = Protocol.Packet_C2S_CropInvite

Protocol.Packet_C2S_CropUpdateHeadId = {
    head_id   = {type = Protocol.DataType.short},
    fields    = {'head_id'}
}
Protocol.structs[Protocol.C_2_S_CROP_UPDATE_HEAD_ID] = Protocol.Packet_C2S_CropUpdateHeadId

Protocol.Packet_S2C_LoadAllCropInfoBegin = {
    my_crop_id     = {type = Protocol.DataType.int},
    join_cd        = {type = Protocol.DataType.int},
    count          = {type = Protocol.DataType.short},
    apply_crop_ids = {type = Protocol.DataType.int, length = -1},
    fields         = {'my_crop_id','join_cd','count','apply_crop_ids'}
}
Protocol.structs[Protocol.S_2_C_LOAD_ALL_CROP_INFO_BEGIN]  = Protocol.Packet_S2C_LoadAllCropInfoBegin

Protocol.Data_CropBaseInfo = {
    id          = {type = Protocol.DataType.int},
    len         = {type = Protocol.DataType.short},
    name        = {type = Protocol.DataType.string, length = Protocol.MAX_CROPS_NAME_LEN},
    level       = {type = Protocol.DataType.short},
    country_id  = {type = Protocol.DataType.short},
    mem_num     = {type = Protocol.DataType.short},
    max_mem_num = {type = Protocol.DataType.short},
    limit_type  = {type = Protocol.DataType.short},
    limit_value = {type = Protocol.DataType.int},
    disband_cd  = {type = Protocol.DataType.int},
    auto_join   = {type = Protocol.DataType.short},
    head_id     = {type = Protocol.DataType.short},
    power_id    = {type = Protocol.DataType.int},
    city_id     = {type = Protocol.DataType.int},
    color_id    = {type = Protocol.DataType.short},
    power_len   = {type = Protocol.DataType.short},
    power_name  = {type = Protocol.DataType.string, length = Protocol.MAX_CROP_POWER_NAME_LEN},
    leader_len  = {type = Protocol.DataType.short},
    leader_name = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    fields      = {'id','len','name','level','country_id','mem_num','max_mem_num','limit_type','limit_value','disband_cd','auto_join','head_id','power_id','city_id','color_id','power_len','power_name','leader_len','leader_name'}
}

Protocol.Data_CropMemberInfo = {
    id           = {type = Protocol.DataType.longlong},
    len          = {type = Protocol.DataType.short},
    name         = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    level        = {type = Protocol.DataType.short},
    pos          = {type = Protocol.DataType.short},
    contribution = {type = Protocol.DataType.int},
    power        = {type = Protocol.DataType.int},
    img_type     = {type = Protocol.DataType.short},
    img_id       = {type = Protocol.DataType.int},
    is_online    = {type = Protocol.DataType.short},
    logout_time  = {type = Protocol.DataType.int},
    pos_cityid   = {type = Protocol.DataType.short},
    country_id   = {type = Protocol.DataType.short},
    fields       = {'id','len','name','level','pos','contribution','power','img_type','img_id','is_online','logout_time','pos_cityid','country_id'}
}

Protocol.Data_CropApplyMemberInfo = {
    id          = {type = Protocol.DataType.longlong},
    len         = {type = Protocol.DataType.short},
    name        = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    level       = {type = Protocol.DataType.short},
    apply_time  = {type = Protocol.DataType.int},
    power       = {type = Protocol.DataType.int},
    img_type    = {type = Protocol.DataType.short},
    img_id      = {type = Protocol.DataType.int},
    is_online   = {type = Protocol.DataType.short},
    logout_time = {type = Protocol.DataType.int},
    fields      = {'id','len','name','level','apply_time','power','img_type','img_id','is_online','logout_time'}
}

Protocol.Packet_S2C_LoadAllCropInfo = {
    count  = {type = Protocol.DataType.short},
    crops  = {type = Protocol.DataType.object, length = -1 ,clazz = 'Data_CropBaseInfo'},
    fields = {'count','crops'}
}
Protocol.structs[Protocol.S_2_C_LOAD_ALL_CROP_INFO]  = Protocol.Packet_S2C_LoadAllCropInfo

Protocol.Packet_S2C_LoadAllCropInfoEnd = {
    fields = {}
}
Protocol.structs[Protocol.S_2_C_LOAD_ALL_CROP_INFO_END]  = Protocol.Packet_S2C_LoadAllCropInfoEnd

Protocol.Packet_S2C_LoadCropInfo = {
    id              = {type = Protocol.DataType.int},
    leader_id       = {type = Protocol.DataType.longlong},
    len1            = {type = Protocol.DataType.short},
    leader_name     = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    leader_lvl      = {type = Protocol.DataType.short},
    leader_img_type = {type = Protocol.DataType.short},
    leader_img_id   = {type = Protocol.DataType.int},
    len2            = {type = Protocol.DataType.short},
    board_msg       = {type = Protocol.DataType.string, length = Protocol.MAX_CROPS_BOARD_MSG_LEN},
    mem_num         = {type = Protocol.DataType.short},
    max_mem_num     = {type = Protocol.DataType.short},
    fields          = {'id','leader_id','len1','leader_name','leader_lvl','leader_img_type','leader_img_id','len2','board_msg','mem_num','max_mem_num'}
}
Protocol.structs[Protocol.S_2_C_LOAD_CROP_INFO]  = Protocol.Packet_S2C_LoadCropInfo

Protocol.CREATE_CROP_RET = {
    cr_ok = 0,
    cr_name_dup = 1,
    cr_has_crop = 2,
}

Protocol.Packet_S2C_CreateCrop = {
    ret    = {type = Protocol.DataType.short},
    id     = {type = Protocol.DataType.int},
    fields = {'ret','id'}
}
Protocol.structs[Protocol.S_2_C_CREATE_CROP]  = Protocol.Packet_S2C_CreateCrop

Protocol.Packet_S2C_LoadAllMemberBegin = {
    fields         = {}
}
Protocol.structs[Protocol.S_2_C_LOAD_ALL_MEMBER_BEGIN]  = Protocol.Packet_S2C_LoadAllMemberBegin

Protocol.Packet_S2C_LoadAllMember = {
    is_notify = {type = Protocol.DataType.short},
    count     = {type = Protocol.DataType.short},
    members   = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CropMemberInfo'},
    crop_id   = {type = Protocol.DataType.int},
    fields    = {'is_notify','count','members','crop_id'}
}
Protocol.structs[Protocol.S_2_C_LOAD_ALL_MEMBER]  = Protocol.Packet_S2C_LoadAllMember

Protocol.Packet_S2C_LoadAllMemberEnd = {
    fields         = {}
}
Protocol.structs[Protocol.S_2_C_LOAD_ALL_MEMBER_END]  = Protocol.Packet_S2C_LoadAllMemberEnd

Protocol.Packet_S2C_LoadAllApplyMemberBegin = {
    fields         = {}
}
Protocol.structs[Protocol.S_2_C_LOAD_ALL_APPLY_MEMBER_BEGIN]  = Protocol.Packet_S2C_LoadAllApplyMemberBegin

Protocol.Packet_S2C_LoadAllApplyMember = {
    is_notify = {type = Protocol.DataType.short},
    count   = {type = Protocol.DataType.short},
    members = {type = Protocol.DataType.object, length = -1, clazz = 'Data_CropApplyMemberInfo'},
    fields  = {'is_notify','count','members'}
}
Protocol.structs[Protocol.S_2_C_LOAD_ALL_APPLY_MEMBER] = Protocol.Packet_S2C_LoadAllApplyMember

Protocol.Packet_S2C_LoadAllApplyMemberEnd = {
    fields         = {}
}
Protocol.structs[Protocol.S_2_C_LOAD_ALL_APPLY_MEMBER_END]  = Protocol.Packet_S2C_LoadAllApplyMemberEnd

Protocol.CROP_APPLY_RET = {
    ar_ok = 0,
    ar_full = 1,
    ar_has_crop = 2,
    ar_no_crop = 3,
    ar_unkown = 4,
}

Protocol.Packet_S2C_CropApply = {
    ret     = {type = Protocol.DataType.short},
    crop_id = {type = Protocol.DataType.int},
    count   = {type = Protocol.DataType.short},
    apply_ids   = {type = Protocol.DataType.int, length = -1},
    fields  = {'ret','crop_id','count','apply_ids'}
}
Protocol.structs[Protocol.S_2_C_CROP_APPLY]  = Protocol.Packet_S2C_CropApply

Protocol.Packet_S2C_CropApprove = {
    count  = {type = Protocol.DataType.short},
    ids    = {type = Protocol.DataType.longlong, length = -1},
    fields = {'count','ids'}
}
Protocol.structs[Protocol.S_2_C_CROP_APPROVE]  = Protocol.Packet_S2C_CropApprove

Protocol.Packet_S2C_CropApproveNotify = {
    crop_id = {type = Protocol.DataType.int},
    fields  = {'crop_id'}
}
Protocol.structs[Protocol.S_2_C_CROP_APPROVE_NOTIFY]  = Protocol.Packet_S2C_CropApproveNotify

Protocol.Packet_S2C_CropReject = {
    count  = {type = Protocol.DataType.short},
    ids    = {type = Protocol.DataType.longlong, length = -1},
    fields = {'count','ids'}
}
Protocol.structs[Protocol.S_2_C_CROP_REJECT]  = Protocol.Packet_S2C_CropReject

Protocol.Packet_S2C_CropKickout = {
    ret    = {type = Protocol.DataType.short},
    id     = {type = Protocol.DataType.longlong},
    fields = {'ret','id'}
}
Protocol.structs[Protocol.S_2_C_CROP_KICKOUT]  = Protocol.Packet_S2C_CropKickout

Protocol.Packet_S2C_CropKickoutNotify = {
     crop_id = {type = Protocol.DataType.int},
     id      = {type = Protocol.DataType.longlong},
     fields  = {'crop_id','id'}
}
Protocol.structs[Protocol.S_2_C_CROP_KICKOUT_NOTIFY]  = Protocol.Packet_S2C_CropKickoutNotify

Protocol.Packet_S2C_CropQuit = {
    ret     = {type = Protocol.DataType.short},
    role_id = {type = Protocol.DataType.longlong},
    join_cd = {type = Protocol.DataType.int},
    fields  = {'ret','role_id','join_cd'}
}
Protocol.structs[Protocol.S_2_C_CROP_QUIT]  = Protocol.Packet_S2C_CropQuit

Protocol.Packet_S2C_ModifyBoardMessage = {
    ret    = {type = Protocol.DataType.short},
    fields = {'ret'}
}
Protocol.structs[Protocol.S_2_C_MODIFY_BOARD_MESSAGE]  = Protocol.Packet_S2C_ModifyBoardMessage

Protocol.Packet_S2C_CropDismiss = {
    ret        = {type = Protocol.DataType.short},
    dismiss_cd = {type = Protocol.DataType.int},
    fields     = {'ret','dismiss_cd'}
}
Protocol.structs[Protocol.S_2_C_CROP_DISMISS]  = Protocol.Packet_S2C_CropDismiss

Protocol.Packet_S2C_CropCancelDismiss = {
    ret    = {type = Protocol.DataType.short},
    fields = {'ret'}
}
Protocol.structs[Protocol.S_2_C_CROP_CANCEL_DISMISS]  = Protocol.Packet_S2C_CropCancelDismiss

Protocol.Packet_S2C_CropJoinSetting = {
    ret         = {type = Protocol.DataType.short},
    auto_join   = {type = Protocol.DataType.short},
    limit_type  = {type = Protocol.DataType.short},
    limit_value = {type = Protocol.DataType.int},
    fields = {'ret','auto_join','limit_type','limit_value'}
}
Protocol.structs[Protocol.S_2_C_CROP_JOIN_SETTING]  = Protocol.Packet_S2C_CropJoinSetting

Protocol.Packet_S2C_CancelApply = {
    ret        = {type = Protocol.DataType.short},
    crop_id    = {type = Protocol.DataType.int},
    fields     = {'ret','crop_id'}
}
Protocol.structs[Protocol.S_2_C_CANCEL_APPLY]  = Protocol.Packet_S2C_CancelApply

Protocol.Data_Tech = {
    id     = {type = Protocol.DataType.short},
    lvl    = {type = Protocol.DataType.short},
    exp    = {type = Protocol.DataType.int},
    fields = {'id','lvl', 'exp'}
}

Protocol.Packet_S2C_LoadTechnology = {
    num1   = {type = Protocol.DataType.short},
    num2   = {type = Protocol.DataType.short},
    count  = {type = Protocol.DataType.short},
    techs  = {type = Protocol.DataType.object, length = -1, clazz = 'Data_Tech'},
    fields = {'num1','num2','count','techs'}
}
Protocol.structs[Protocol.S_2_C_LOAD_TECHNOLOGY]  = Protocol.Packet_S2C_LoadTechnology

Protocol.Packet_C2S_CropContribute = {
    contribute_type = {type = Protocol.DataType.short}, -- 1, 2
    tech_id         = {type = Protocol.DataType.short},
    fields          = {'contribute_type','tech_id'}
}
Protocol.structs[Protocol.C_2_S_CROP_CONTRIBUTE]  = Protocol.Packet_C2S_CropContribute

Protocol.Packet_S2C_CropContribute = {
    contribute_type = {type = Protocol.DataType.short},
    num             = {type = Protocol.DataType.short},
    tech_id         = {type = Protocol.DataType.short},
    level           = {type = Protocol.DataType.short},
    exp             = {type = Protocol.DataType.int},
    fields          = {'contribute_type','num','tech_id','level','exp'}
}
Protocol.structs[Protocol.S_2_C_CROP_CONTRIBUTE]  = Protocol.Packet_S2C_CropContribute

Protocol.Packet_S2C_CropInvite = {
    ret        = {type = Protocol.DataType.short},        -- 0 ok, 1 offline
    role_id    = {type = Protocol.DataType.longlong},
    fields     = {'ret','role_id'}
}
Protocol.structs[Protocol.S_2_C_CROP_INVITE] = Protocol.Packet_S2C_CropInvite

Protocol.Packet_S2C_CropInviteNotify = {
    from_role_id       = {type = Protocol.DataType.longlong},
    from_name_len      = {type = Protocol.DataType.short},
    from_name          = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    crop_id            = {type = Protocol.DataType.int},
    fields             = {'from_role_id','from_name_len','from_name','crop_id'}
}
Protocol.structs[Protocol.S_2_C_CROP_INVITE_NOTIEY] = Protocol.Packet_S2C_CropInviteNotify

Protocol.Packet_S2C_CropUpdateHeadId = {
    ret          = {type = Protocol.DataType.short},
    head_id      = {type = Protocol.DataType.short},
    fields       = {'ret','head_id'}
}
Protocol.structs[Protocol.S_2_C_CROP_UPDATE_HEAD_ID] = Protocol.Packet_S2C_CropUpdateHeadId

Protocol.Packet_C2S_CropApplyHelp = {
    build_id = {type = Protocol.DataType.int},
    fields   = {'build_id'}
}
Protocol.structs[Protocol.C_2_S_CROP_APPLY_HELP]  = Protocol.Packet_C2S_CropApplyHelp

Protocol.Packet_S2C_CropApplyHelp = {
    ret      = {type = Protocol.DataType.short},
    build_id = {type = Protocol.DataType.int},
    fields   = {'ret','build_id'}
}
Protocol.structs[Protocol.S_2_C_CROP_APPLY_HELP]  = Protocol.Packet_S2C_CropApplyHelp

Protocol.Packet_C2S_CropDoHelp = {
    role_id  = {type = Protocol.DataType.longlong},
    build_id = {type = Protocol.DataType.int},
    fields   = {'role_id','build_id'}
}
Protocol.structs[Protocol.C_2_S_CROP_DO_HELP]  = Protocol.Packet_C2S_CropDoHelp

Protocol.Packet_S2C_CropDoHelp = {
    role_id     = {type = Protocol.DataType.longlong},
    build_id    = {type = Protocol.DataType.int},
    help_reward = {type = Protocol.DataType.int},
    fields      = {'role_id','build_id','help_reward'}
}
Protocol.structs[Protocol.S_2_C_CROP_DO_HELP]  = Protocol.Packet_S2C_CropDoHelp

Protocol.Packet_S2C_CropHelpUpdate = {
    member_id   = {type = Protocol.DataType.longlong},
    build_id    = {type = Protocol.DataType.int},
    build_level = {type = Protocol.DataType.short},
    cd_time     = {type = Protocol.DataType.int},
    count       = {type = Protocol.DataType.short},
    help_player = {type = Protocol.DataType.longlong, length = -1},
    fields      = {'member_id','build_id','build_level','cd_time','count','help_player'}
}
Protocol.structs[Protocol.S_2_C_CROP_HELP_UPDATE]  = Protocol.Packet_S2C_CropHelpUpdate

Protocol.Data_Help = {
    member_id   = {type = Protocol.DataType.longlong},
    build_id    = {type = Protocol.DataType.int},
    build_level = {type = Protocol.DataType.short},
    cd_time     = {type = Protocol.DataType.int},
    count       = {type = Protocol.DataType.short},
    help_player = {type = Protocol.DataType.longlong, length = -1},
    fields      = {'member_id','build_id','build_level','cd_time','count','help_player'}
}

Protocol.Packet_S2C_CropLoadHelp = {
    help_reward = {type = Protocol.DataType.int},
    is_last     = {type = Protocol.DataType.short},
    count       = {type = Protocol.DataType.short},
    help_list   = {type = Protocol.DataType.object, length = -1 ,clazz = 'Data_Help'},
    fields      = {'help_reward','is_last','count','help_list'}
}
Protocol.structs[Protocol.S_2_C_CROP_LOAD_HELP]  = Protocol.Packet_S2C_CropLoadHelp

Protocol.Data_HELP_Log = {
    role_id   = {type = Protocol.DataType.longlong},
    len       = {type = Protocol.DataType.short},
    name      = {type = Protocol.DataType.string, length = Protocol.MAX_ACCOUNT_NAME_LEN},
    build_id  = {type = Protocol.DataType.int},
    help_time = {type = Protocol.DataType.int},
    fields    = {'role_id','len','name','build_id','help_time'}
}

Protocol.Packet_S2C_CropLoadHelpLog = {
    count    = {type = Protocol.DataType.short},
    help_log = {type = Protocol.DataType.object, length = -1 ,clazz = 'Data_HELP_Log'},
    fields   = {'count','help_log'}
}
Protocol.structs[Protocol.S_2_C_CROP_LOAD_HELP_LOG]  = Protocol.Packet_S2C_CropLoadHelpLog

Protocol.Packet_S2C_CropHelpDel = {
    member_id   = {type = Protocol.DataType.longlong},
    build_id    = {type = Protocol.DataType.int},
    build_level = {type = Protocol.DataType.short},
    fields   = {'member_id','build_id','build_level'}
}
Protocol.structs[Protocol.S_2_C_CROP_HELP_DEL]  = Protocol.Packet_S2C_CropHelpDel

Protocol.Packet_C2S_LoadAllMember = {
    crop_id = {type = Protocol.DataType.int},
    fields  = {'crop_id'}
}
Protocol.structs[Protocol.C_2_S_LOAD_ALL_MEMBER]  = Protocol.Packet_C2S_LoadAllMember
