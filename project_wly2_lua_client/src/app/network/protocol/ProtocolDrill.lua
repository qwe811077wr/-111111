local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_DRILL_GROUND_LOAD                        = Protocol.C_2_S_DRILL_GROUND_BASE + 0
Protocol.C_2_S_DRILL_GROUND_ENTER                       = Protocol.C_2_S_DRILL_GROUND_BASE + 1
Protocol.C_2_S_DRILL_GROUND_END                         = Protocol.C_2_S_DRILL_GROUND_BASE + 2
Protocol.C_2_S_DRILL_GROUND_BATTER                      = Protocol.C_2_S_DRILL_GROUND_BASE + 3
Protocol.C_2_S_DRILL_GROUND_REWARD                      = Protocol.C_2_S_DRILL_GROUND_BASE + 4
Protocol.C_2_S_DRILL_GROUND_SKILL_UP                    = Protocol.C_2_S_DRILL_GROUND_BASE + 5
Protocol.C_2_S_DRILL_GROUND_SKILL_RESET                 = Protocol.C_2_S_DRILL_GROUND_BASE + 6
Protocol.C_2_S_DRILL_GROUND_FORMATION_SAVE              = Protocol.C_2_S_DRILL_GROUND_BASE + 7

Protocol.S_2_C_DRILL_GROUND_LOAD                        = Protocol.S_2_C_DRILL_GROUND_BASE + 0
Protocol.S_2_C_DRILL_GROUND_ENTER                       = Protocol.S_2_C_DRILL_GROUND_BASE + 1
Protocol.S_2_C_DRILL_GROUND_END                         = Protocol.S_2_C_DRILL_GROUND_BASE + 2
Protocol.S_2_C_DRILL_GROUND_BATTER                      = Protocol.S_2_C_DRILL_GROUND_BASE + 3
Protocol.S_2_C_DRILL_GROUND_REWARD                      = Protocol.S_2_C_DRILL_GROUND_BASE + 4
Protocol.S_2_C_DRILL_GROUND_SKILL_UP                    = Protocol.S_2_C_DRILL_GROUND_BASE + 5
Protocol.S_2_C_DRILL_GROUND_SKILL_RESET                 = Protocol.S_2_C_DRILL_GROUND_BASE + 6
Protocol.S_2_C_DRILL_GROUND_FORMATION_SAVE              = Protocol.S_2_C_DRILL_GROUND_BASE + 7

---c2s----
Protocol.Packet_C2S_DrillGroundEnter = {
    id                      = {type = Protocol.DataType.int},
    mode                    = {type = Protocol.DataType.short},
    fields                  = {'id','mode'}
}
Protocol.structs[Protocol.C_2_S_DRILL_GROUND_ENTER]               = Protocol.Packet_C2S_DrillGroundEnter

Protocol.Packet_C2S_DrillGroundReward = {
    id                      = {type = Protocol.DataType.int},
    fields                  = {'id'}
}
Protocol.structs[Protocol.C_2_S_DRILL_GROUND_REWARD]               = Protocol.Packet_C2S_DrillGroundReward

Protocol.Packet_C2S_DrillGroundSkillUp = {
    id                      = {type = Protocol.DataType.int},
    fields                  = {'id'}
}
Protocol.structs[Protocol.C_2_S_DRILL_GROUND_SKILL_UP]               = Protocol.Packet_C2S_DrillGroundSkillUp

Protocol.Packet_C2S_DrillGroundSkillReset = {
    id                      = {type = Protocol.DataType.int},
    drill_type              = {type = Protocol.DataType.short},
    fields                  = {'id', 'drill_type'}
}
Protocol.structs[Protocol.C_2_S_DRILL_GROUND_SKILL_RESET]               = Protocol.Packet_C2S_DrillGroundSkillReset

Protocol.Packet_C2S_DrillGroundFormationSave = {
    formation_id             = {type = Protocol.DataType.int},
    drill_ground_id          = {type = Protocol.DataType.int},
    count                    = {type = Protocol.DataType.short},
    formations               = {type = Protocol.DataType.object, length = -1, clazz = "Drill_Save_FormationData"},
    fields                   = {'formation_id', 'drill_ground_id', 'count', 'formations'}
}
Protocol.structs[Protocol.C_2_S_DRILL_GROUND_FORMATION_SAVE]            = Protocol.Packet_C2S_DrillGroundFormationSave

Protocol.Drill_FormationData = {
    index                    = {type = Protocol.DataType.short},
    general_id               = {type = Protocol.DataType.int},
    fields                   = {'general_id', 'index'}
}

---s2c---
Protocol.Drill_GroundData = {
    id                       = {type = Protocol.DataType.int},
    num                      = {type = Protocol.DataType.short},
    fields                   = {'id','num'}
}

Protocol.Drill_Save_FormationData = {
    index                    = {type = Protocol.DataType.short},
    general_id               = {type = Protocol.DataType.int},
    fields                   = {'index', 'general_id'}
}

Protocol.Drill_LoadItems = {
    id                       = {type = Protocol.DataType.int},
    type                     = {type = Protocol.DataType.short},
    mode                     = {type = Protocol.DataType.short},
    cur_mode                 = {type = Protocol.DataType.short},
    level                    = {type = Protocol.DataType.short},
    exp                      = {type = Protocol.DataType.int},
    formation_id             = {type = Protocol.DataType.int},
    reward_count             = {type = Protocol.DataType.short},
    rewards                  = {type = Protocol.DataType.object, length = -1, clazz='Drill_GroundData'},
    skill_count              = {type = Protocol.DataType.short},
    skillls                  = {type = Protocol.DataType.object, length = -1, clazz='Drill_SkillData'},
    general_count            = {type = Protocol.DataType.short},
    formations               = {type = Protocol.DataType.object, length = -1, clazz='Drill_FormationData'},
    fields                   = {'id','type','mode','cur_mode','level','exp','formation_id','reward_count','rewards',
                            'general_count','formations','skill_count','skillls'}
}

Protocol.Drill_SkillData = {
    drill_type               = {type = Protocol.DataType.short},
    id                       = {type = Protocol.DataType.int},
    num                      = {type = Protocol.DataType.short},
    fields                   = {'drill_type','id','num'}
}

Protocol.Packet_S2C_DrillGroundLoad = {
    num                      = {type = Protocol.DataType.short},
    is_over                  = {type = Protocol.DataType.short},
    count                    = {type = Protocol.DataType.short},
    items                    = {type = Protocol.DataType.object, length = -1, clazz='Drill_LoadItems'},
    fields                   = {'num','is_over','count','items'}
}
Protocol.structs[Protocol.S_2_C_DRILL_GROUND_LOAD]                 = Protocol.Packet_S2C_DrillGroundLoad


Protocol.Packet_S2C_DrillGroundEnter = {
    ret                      = {type = Protocol.DataType.short},
    id                       = {type = Protocol.DataType.int},
    mode                     = {type = Protocol.DataType.short},
    fields                   = {'ret','id','mode'}
}
Protocol.structs[Protocol.S_2_C_DRILL_GROUND_ENTER]                 = Protocol.Packet_S2C_DrillGroundEnter

Protocol.Packet_S2C_DrillGroundEnd = {
    ret                      = {type = Protocol.DataType.short},
    id                       = {type = Protocol.DataType.int},
    cur_mode                 = {type = Protocol.DataType.short},
    mode                     = {type = Protocol.DataType.short},
    fields                   = {'ret', 'id', 'cur_mode', 'mode'}
}
Protocol.structs[Protocol.S_2_C_DRILL_GROUND_END]                 = Protocol.Packet_S2C_DrillGroundEnd

Protocol.Packet_S2C_DrillGroundBatter = {
    result                   = {type = Protocol.DataType.short},
    level                    = {type = Protocol.DataType.short},
    exp                      = {type = Protocol.DataType.int},
    add_exp                  = {type = Protocol.DataType.int},
    drill_ground_id          = {type = Protocol.DataType.int},
    troop_id                 = {type = Protocol.DataType.int},
    report_id                = {type = Protocol.DataType.llstring},
    fields                   = {'result','level','exp','add_exp','drill_ground_id','troop_id','report_id'}
}
Protocol.structs[Protocol.S_2_C_DRILL_GROUND_BATTER]                 = Protocol.Packet_S2C_DrillGroundBatter

Protocol.Packet_S2C_DrillGroundReward = {
    ret                      = {type = Protocol.DataType.short},
    id                       = {type = Protocol.DataType.int},
    count                    = {type = Protocol.DataType.short},
    rewards                  = {type = Protocol.DataType.object, length = -1, clazz = 'Packet_Data_RewardType'},
    fields                   = {'ret','id','count','rewards'}
}
Protocol.structs[Protocol.S_2_C_DRILL_GROUND_REWARD]                 = Protocol.Packet_S2C_DrillGroundReward

Protocol.Packet_S2C_DrillGroundSkillUp = {
    ret                      = {type = Protocol.DataType.short},
    id                       = {type = Protocol.DataType.int},
    level                    = {type = Protocol.DataType.short},
    fields                   = {'ret','id','level'}
}
Protocol.structs[Protocol.S_2_C_DRILL_GROUND_SKILL_UP]                 = Protocol.Packet_S2C_DrillGroundSkillUp

Protocol.Packet_S2C_DrillGroundSkillReset = {
    ret                      = {type = Protocol.DataType.short},
    id                       = {type = Protocol.DataType.int},
    drill_type               = {type = Protocol.DataType.short},
    fields                   = {'ret','id', 'drill_type'}
}
Protocol.structs[Protocol.S_2_C_DRILL_GROUND_SKILL_RESET]                 = Protocol.Packet_S2C_DrillGroundSkillReset

Protocol.Packet_S2C_DrillGroundFormationSave = {
    ret                      = {type = Protocol.DataType.short},
    fields                   = {'ret'}
}
Protocol.structs[Protocol.S_2_C_DRILL_GROUND_FORMATION_SAVE]              = Protocol.Packet_S2C_DrillGroundFormationSave