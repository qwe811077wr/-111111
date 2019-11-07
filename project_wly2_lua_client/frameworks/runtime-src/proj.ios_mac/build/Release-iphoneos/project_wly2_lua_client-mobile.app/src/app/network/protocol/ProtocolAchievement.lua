local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_ACHIEVEMENT_LOAD         = Protocol.C_2_S_ACHIEVEMENT_BASE + 1
Protocol.C_2_S_ACHIEVEMENT_DRAW         = Protocol.C_2_S_ACHIEVEMENT_BASE + 3
Protocol.C_2_S_TASK_DAY7_LOAD           = Protocol.C_2_S_ACHIEVEMENT_BASE + 5
Protocol.C_2_S_TASK_DAY7_DRAW           = Protocol.C_2_S_ACHIEVEMENT_BASE + 7
Protocol.C_2_S_TASK_DAY7_STORE_BUY      = Protocol.C_2_S_ACHIEVEMENT_BASE + 9
Protocol.C_2_S_TASK_DAY7_DRAW_TOTAL     = Protocol.C_2_S_ACHIEVEMENT_BASE + 11
Protocol.C_2_S_LEVEL_GIFT_LOAD          = Protocol.C_2_S_ACHIEVEMENT_BASE + 12
Protocol.C_2_S_LEVEL_GIFT_DRAW          = Protocol.C_2_S_ACHIEVEMENT_BASE + 13

Protocol.S_2_C_ACHIEVEMENT_CHAPTER_LOAD = Protocol.S_2_C_ACHIEVEMENT_BASE + 0
Protocol.S_2_C_ACHIEVEMENT_TASK_BEGIN   = Protocol.S_2_C_ACHIEVEMENT_BASE + 1
Protocol.S_2_C_ACHIEVEMENT_TASK_LOAD    = Protocol.S_2_C_ACHIEVEMENT_BASE + 2
Protocol.S_2_C_ACHIEVEMENT_TASK_END     = Protocol.S_2_C_ACHIEVEMENT_BASE + 3
Protocol.S_2_C_ACHIEVEMENT_DRAW         = Protocol.S_2_C_ACHIEVEMENT_BASE + 4
Protocol.S_2_C_ACHIEVEMENT_ITEM_UPDATE  = Protocol.S_2_C_ACHIEVEMENT_BASE + 6
Protocol.S_2_C_TASK_DAY7_LOAD           = Protocol.S_2_C_ACHIEVEMENT_BASE + 8
Protocol.S_2_C_TASK_DAY7_DRAW           = Protocol.S_2_C_ACHIEVEMENT_BASE + 10
Protocol.S_2_C_TASK_DAY7_STORE_BUY      = Protocol.S_2_C_ACHIEVEMENT_BASE + 12
Protocol.S_2_C_TASK_DAY7_DRAW_TOTAL     = Protocol.S_2_C_ACHIEVEMENT_BASE + 14
Protocol.S_2_C_TASK_DAY7_ITEM_UPDATE    = Protocol.S_2_C_ACHIEVEMENT_BASE + 16
Protocol.S_2_C_LEVEL_GIFT_LOAD          = Protocol.S_2_C_ACHIEVEMENT_BASE + 17
Protocol.S_2_C_LEVEL_GIFT_DRAW          = Protocol.S_2_C_ACHIEVEMENT_BASE + 18
Protocol.S_2_C_LEVEL_GIFT_ITEM_UPDATE   = Protocol.S_2_C_ACHIEVEMENT_BASE + 19

Protocol.Packet_C2S_AchievementLoad = {
    fields          = {}
}
Protocol.structs[Protocol.C_2_S_ACHIEVEMENT_LOAD]     = Protocol.Packet_C2S_AchievementLoad

Protocol.Packet_C2S_LevelGiftDraw = {
    id              = {type = Protocol.DataType.short},
    gift_type       = {type = Protocol.DataType.short},
    fields          = {'id','gift_type'}
}
Protocol.structs[Protocol.C_2_S_LEVEL_GIFT_DRAW]     = Protocol.Packet_C2S_LevelGiftDraw

Protocol.Data_Chapters = {
    id              = {type = Protocol.DataType.int},
    count1          = {type = Protocol.DataType.short},
    ids             = {type = Protocol.DataType.int, length = -1},
    fields          = {'id', 'count1','ids'}
}

Protocol.Packet_S2C_AchievementChapterLoad = {
    count           = {type = Protocol.DataType.short},
    chapters        = {type = Protocol.DataType.object, length = -1, clazz = 'Data_Chapters'},
    fields          = {'count', 'chapters'}
}
Protocol.structs[Protocol.S_2_C_ACHIEVEMENT_CHAPTER_LOAD] = Protocol.Packet_S2C_AchievementChapterLoad

Protocol.Packet_S2C_AchievementTaskLoadBegin = {
    fields          = {}
}
Protocol.structs[Protocol.S_2_C_ACHIEVEMENT_TASK_BEGIN] = Protocol.Packet_S2C_AchievementTaskLoadBegin

Protocol.Data_Tasks = {
    id              = {type = Protocol.DataType.int},
    chapter_id      = {type = Protocol.DataType.int},
    state           = {type = Protocol.DataType.short},
    value           = {type = Protocol.DataType.int},
    fields          = {'id', 'chapter_id', 'state', 'value'}
}

Protocol.Packet_S2C_AchievementTaskLoad = {
    count           = {type = Protocol.DataType.short},
    tasks           = {type = Protocol.DataType.object, length = -1, clazz = 'Data_Tasks'},
    fields          = {'count','tasks'}
}
Protocol.structs[Protocol.S_2_C_ACHIEVEMENT_TASK_LOAD]     = Protocol.Packet_S2C_AchievementTaskLoad

Protocol.Packet_S2C_AchievementTaskLoadEnd = {
    fields          = {}
}
Protocol.structs[Protocol.S_2_C_ACHIEVEMENT_TASK_END] = Protocol.Packet_S2C_AchievementTaskLoadEnd

Protocol.Packet_C2S_AchievementDraw = {
    id              = {type = Protocol.DataType.int},
    chapter_id      = {type = Protocol.DataType.int},
    rwd_type        = {type = Protocol.DataType.short},     --0 task, 1 achieve
    fields          = {'id','chapter_id','rwd_type'}
}
Protocol.structs[Protocol.C_2_S_ACHIEVEMENT_DRAW]     = Protocol.Packet_C2S_AchievementDraw

Protocol.Packet_S2C_AchievementDraw = {
    ret             = {type = Protocol.DataType.short},
    id              = {type = Protocol.DataType.int},
    chapter_id      = {type = Protocol.DataType.int},
    rwd_type        = {type = Protocol.DataType.short},
    finished        = {type = Protocol.DataType.short},
    fields          = {'ret','id','chapter_id','rwd_type','finished'}
}
Protocol.structs[Protocol.S_2_C_ACHIEVEMENT_DRAW]     = Protocol.Packet_S2C_AchievementDraw

Protocol.Data_Items = {
    id              = {type = Protocol.DataType.int},
    state           = {type = Protocol.DataType.short},
    value           = {type = Protocol.DataType.short},
    fields          = {'id','state','value'}
}

Protocol.Packet_S2C_AchievementItemUpdate = {
    count           = {type = Protocol.DataType.short},
    items           = {type = Protocol.DataType.object, length = -1, clazz = 'Data_Items'},
    fields          = {'count','items'}
}
Protocol.structs[Protocol.S_2_C_ACHIEVEMENT_ITEM_UPDATE]     = Protocol.Packet_S2C_AchievementItemUpdate

Protocol.Packet_C2S_TaskDay7Load = {
    fields    = {}
}
Protocol.structs[Protocol.C_2_S_TASK_DAY7_LOAD] = Protocol.Packet_C2S_TaskDay7Load

Protocol.Data_StoreNums = {
    id     = {type = Protocol.DataType.int},
    num    = {type = Protocol.DataType.short},
    fields = {'id','num'}
}

Protocol.Packet_S2C_TaskDay7Load = {
    create_days      = {type = Protocol.DataType.short},
    finished_num     = {type = Protocol.DataType.short},
    count            = {type = Protocol.DataType.short},
    total_reward_ids = {type = Protocol.DataType.int, length = -1},
    count1           = {type = Protocol.DataType.short},
    store_nums       = {type = Protocol.DataType.object, length = -1, clazz = 'Data_StoreNums'},
    fields           = {'create_days','finished_num','count','total_reward_ids','count1','store_nums'}
}
Protocol.structs[Protocol.S_2_C_TASK_DAY7_LOAD] = Protocol.Packet_S2C_TaskDay7Load

Protocol.Packet_C2S_TaskDay7Draw = {
    id     = {type = Protocol.DataType.int},
    fields = {'id'}
}
Protocol.structs[Protocol.C_2_S_TASK_DAY7_DRAW] = Protocol.Packet_C2S_TaskDay7Draw

Protocol.Packet_S2C_TaskDay7Draw = {
    ret     = {type = Protocol.DataType.short},
    id      = {type = Protocol.DataType.int},
    fields  = {'ret','id'}
}
Protocol.structs[Protocol.S_2_C_TASK_DAY7_DRAW] = Protocol.Packet_S2C_TaskDay7Draw

Protocol.Packet_C2S_TaskDay7StoreBuy = {
    id      = {type = Protocol.DataType.int},
    fields  = {'id'}
}
Protocol.structs[Protocol.C_2_S_TASK_DAY7_STORE_BUY] = Protocol.Packet_C2S_TaskDay7StoreBuy

Protocol.Packet_S2C_TaskDay7StoreBuy = {
    id      = {type = Protocol.DataType.int},
    num     = {type = Protocol.DataType.short},
    fields  = {'id','num'}
}
Protocol.structs[Protocol.S_2_C_TASK_DAY7_STORE_BUY] = Protocol.Packet_S2C_TaskDay7StoreBuy

Protocol.Packet_C2S_TaskDay7DrawTotal = {
    id      = {type = Protocol.DataType.int},
    fields  = {'id'}
}
Protocol.structs[Protocol.C_2_S_TASK_DAY7_DRAW_TOTAL] = Protocol.Packet_C2S_TaskDay7DrawTotal

Protocol.Packet_S2C_TaskDay7DrawTotal = {
    ret     = {type = Protocol.DataType.short},
    id      = {type = Protocol.DataType.int},
    fields  = {'ret','id'}
}
Protocol.structs[Protocol.S_2_C_TASK_DAY7_DRAW_TOTAL] = Protocol.Packet_S2C_TaskDay7DrawTotal

Protocol.Data_TaskDayItems = {
    id     = {type = Protocol.DataType.int},
    state  = {type = Protocol.DataType.short},
    num    = {type = Protocol.DataType.int},
    fields = {'id','state','num'}
}

Protocol.Packet_S2C_TaskDay7ItemUpdate = {
    count   = {type = Protocol.DataType.short},
    items   = {type = Protocol.DataType.object, length = -1, clazz = 'Data_TaskDayItems'},
    fields  = {'count','items'}
}
Protocol.structs[Protocol.S_2_C_TASK_DAY7_ITEM_UPDATE] = Protocol.Packet_S2C_TaskDay7ItemUpdate

Protocol.Data_LevelGoods = {
    id              = {type = Protocol.DataType.short},
    num             = {type = Protocol.DataType.short},
    surplus         = {type = Protocol.DataType.int},
    fields          = {'id','num','surplus'}
}

Protocol.Packet_S2C_LevelGiftLoad = {
    id              = {type = Protocol.DataType.short},
    count           = {type = Protocol.DataType.short},
    ids             = {type = Protocol.DataType.short, length = -1},
    count1          = {type = Protocol.DataType.short},
    goods           = {type = Protocol.DataType.object, length = -1, clazz = 'Data_LevelGoods'},
    fields          = {'id','count','ids','count1','goods'}
}
Protocol.structs[Protocol.S_2_C_LEVEL_GIFT_LOAD]     = Protocol.Packet_S2C_LevelGiftLoad

Protocol.Packet_S2C_LevelGiftDraw = {
    ret             = {type = Protocol.DataType.short},
    id              = {type = Protocol.DataType.short},
    gift_type       = {type = Protocol.DataType.short},
    fields          = {'ret','id','gift_type'}
}
Protocol.structs[Protocol.S_2_C_LEVEL_GIFT_DRAW]     = Protocol.Packet_S2C_LevelGiftDraw

Protocol.Packet_S2C_LevelGiftItemUpdate = {
    id              = {type = Protocol.DataType.short},
    fields          = {'id'}
}
Protocol.structs[Protocol.S_2_C_LEVEL_GIFT_ITEM_UPDATE]     = Protocol.Packet_S2C_LevelGiftItemUpdate