local Protocol = cc.exports.Protocol or {}

Protocol.C_2_S_LOAD_MAIN_TASK                       = Protocol.C_2_S_TASK_BASE + 0
Protocol.C_2_S_LOAD_DAY_TASK                        = Protocol.C_2_S_TASK_BASE + 1
Protocol.C_2_S_DRAW_MAIN_TASK_REWARD                = Protocol.C_2_S_TASK_BASE + 2
Protocol.C_2_S_DRAW_DAY_TASK_REWARD                 = Protocol.C_2_S_TASK_BASE + 3
Protocol.C_2_S_COMPLETE_TASK_IMMEDIATELY            = Protocol.C_2_S_TASK_BASE + 4
Protocol.C_2_S_REFRESH_DAY_TASK                     = Protocol.C_2_S_TASK_BASE + 5
Protocol.C_2_S_ACCEPT_MAIN_TASK                     = Protocol.C_2_S_TASK_BASE + 6
Protocol.C_2_S_CANCEL_MAIN_TASK                     = Protocol.C_2_S_TASK_BASE + 7
Protocol.C_2_S_DRAW_NEW_TASK_REWARD                 = Protocol.C_2_S_TASK_BASE + 8
Protocol.C_2_S_LOAD_NEW_DAY_TASK                    = Protocol.C_2_S_TASK_BASE + 9
Protocol.C_2_S_DRAW_NEW_DAY_TASK_REWARD             = Protocol.C_2_S_TASK_BASE + 10
Protocol.C_2_S_TASK_SELECT_DOUBLE_REWARD            = Protocol.C_2_S_TASK_BASE + 11


Protocol.S_2_C_LOAD_MAIN_TASK                       = Protocol.S_2_C_TASK_BASE + 0
Protocol.S_2_C_LOAD_DAY_TASK                        = Protocol.S_2_C_TASK_BASE + 1
Protocol.S_2_C_DRAW_MAIN_TASK_REWARD                = Protocol.S_2_C_TASK_BASE + 2
Protocol.S_2_C_DRAW_DAY_TASK_REWARD                 = Protocol.S_2_C_TASK_BASE + 3
Protocol.S_2_C_COMPLETE_TASK_IMMEDIATELY            = Protocol.S_2_C_TASK_BASE + 4
Protocol.S_2_C_REFRESH_DAY_TASK                     = Protocol.S_2_C_TASK_BASE + 5
Protocol.S_2_C_ACCEPT_MAIN_TASK                     = Protocol.S_2_C_TASK_BASE + 6
Protocol.S_2_C_CANCEL_MAIN_TASK                     = Protocol.S_2_C_TASK_BASE + 7
Protocol.S_2_C_LOAD_NEW_TASK                        = Protocol.S_2_C_TASK_BASE + 8
Protocol.S_2_C_DRAW_NEW_TASK_REWARD                 = Protocol.S_2_C_TASK_BASE + 9
Protocol.S_2_C_LOAD_NEW_DAY_TASK                    = Protocol.S_2_C_TASK_BASE + 10
Protocol.S_2_C_DRAW_NEW_DAY_TASK_REWARD             = Protocol.S_2_C_TASK_BASE + 11
Protocol.S_2_C_NEW_DAY_TASK_NOTICE                  = Protocol.S_2_C_TASK_BASE + 12
Protocol.S_2_C_TASK_SELECT_DOUBLE_REWARD            = Protocol.S_2_C_TASK_BASE + 13


------------------------------C_2_S------------------------------
Protocol.Packet_C2S_DrawNewDayTaskReward = {
    task_type                   = {type = Protocol.DataType.int},
    fields                      = {'task_type'}
}
Protocol.structs[Protocol.C_2_S_DRAW_NEW_DAY_TASK_REWARD]                    = Protocol.Packet_C2S_DrawNewDayTaskReward

Protocol.Packet_C2S_DrawMainTaskReward = {
    taskId                      = {type = Protocol.DataType.ushort},
    fields                      = {'taskId'}
}
Protocol.structs[Protocol.C_2_S_DRAW_MAIN_TASK_REWARD]                      = Protocol.Packet_C2S_DrawMainTaskReward

------------------------------S_2_C------------------------------
Protocol.Packet_Data_TaskInfo = {
    taskId                      = {type = Protocol.DataType.ushort},
    isComplete                  = {type = Protocol.DataType.char},
    stat                        = {type = Protocol.DataType.char},
    fields                      = {'taskId','isComplete','stat'}
}

Protocol.Packet_Data_NewTaskInfo = {
    taskId                      = {type = Protocol.DataType.ushort},
    isComplete                  = {type = Protocol.DataType.char},
    fields                      = {'taskId','isComplete'}
}

Protocol.Packet_S2C_LoadMainTask = {
    taskCount                   = {type = Protocol.DataType.char},
    taskInfo                    = {type = Protocol.DataType.object, length = -1, clazz='Packet_Data_TaskInfo'},
    fields                      = {'taskCount','taskInfo'}
}
Protocol.structs[Protocol.S_2_C_LOAD_MAIN_TASK]                 = Protocol.Packet_S2C_LoadMainTask

Protocol.Packet_S2C_LoadNewTask = {
    taskCount                   = {type = Protocol.DataType.char},
    newTaskInfo                 = {type = Protocol.DataType.object, length = -1, clazz='Packet_Data_NewTaskInfo'},
    fields                      = {'taskCount','newTaskInfo'}
}
Protocol.structs[Protocol.S_2_C_LOAD_NEW_TASK]                 = Protocol.Packet_S2C_LoadNewTask

Protocol.Packet_S2C_DrawNewTaskReward = {
    taskId                      = {type = Protocol.DataType.ushort},
    fields                      = {'taskId'}
}
Protocol.structs[Protocol.S_2_C_DRAW_NEW_TASK_REWARD]                 = Protocol.Packet_S2C_DrawNewTaskReward

Protocol.Packet_S2C_LoadDayTask = {
    maxTaskLevelThisWeek        = {type = Protocol.DataType.char},
    taskId                      = {type = Protocol.DataType.ushort},
    taskLevel                   = {type = Protocol.DataType.char},
    curProgress                 = {type = Protocol.DataType.char},
    remainTaskNum               = {type = Protocol.DataType.char},
    remainFreeRefreshNum        = {type = Protocol.DataType.char},
    fields                      = {'maxTaskLevelThisWeek','taskId','taskLevel','curProgress','remainTaskNum','remainFreeRefreshNum'}
}
Protocol.structs[Protocol.S_2_C_LOAD_DAY_TASK]                 = Protocol.Packet_S2C_LoadDayTask

Protocol.Packet_S2C_AcceptMainTask = {
    fields                      = {}
}
Protocol.structs[Protocol.S_2_C_ACCEPT_MAIN_TASK]                 = Protocol.Packet_S2C_AcceptMainTask

Protocol.Packet_S2C_CancelMainTask = {
    fields                      = {}
}
Protocol.structs[Protocol.S_2_C_CANCEL_MAIN_TASK]                 = Protocol.Packet_S2C_CancelMainTask

Protocol.Packet_S2C_DrawMainTaskReward = {
    taskId                      = {type = Protocol.DataType.ushort},
    nextTaskCount               = {type = Protocol.DataType.char},
    taskInfo                    = {type = Protocol.DataType.object, length = -1, clazz='Packet_Data_TaskInfo'},
    fields                      = {'taskId','nextTaskCount','taskInfo'}
}
Protocol.structs[Protocol.S_2_C_DRAW_MAIN_TASK_REWARD]                 = Protocol.Packet_S2C_DrawMainTaskReward

Protocol.Packet_S2C_DrawDayTaskReward = {
    rewardCostType              = {type = Protocol.DataType.char},
    rewardValue                 = {type = Protocol.DataType.uint},
    rewardEtchedCostType        = {type = Protocol.DataType.char},
    etchedLevel                 = {type = Protocol.DataType.uint},
    newTaskId                   = {type = Protocol.DataType.ushort},
    taskLevel                   = {type = Protocol.DataType.char},
    maxTaskLevelThisWeek        = {type = Protocol.DataType.char},
    fields                      = {'rewardCostType','rewardValue','rewardEtchedCostType','etchedLevel','newTaskId','taskLevel','maxTaskLevelThisWeek'}
}
Protocol.structs[Protocol.S_2_C_DRAW_DAY_TASK_REWARD]                 = Protocol.Packet_S2C_DrawDayTaskReward

Protocol.Packet_S2C_CompleteTaskImmediately = {
    ret                         = {type = Protocol.DataType.char},
    maxTaskLevelThisWeek        = {type = Protocol.DataType.char},
    fields                      = {'ret','maxTaskLevelThisWeek'}
}
Protocol.structs[Protocol.S_2_C_COMPLETE_TASK_IMMEDIATELY]                 = Protocol.Packet_S2C_CompleteTaskImmediately

Protocol.Packet_S2C_RefreshDayTask = {
    taskId                      = {type = Protocol.DataType.ushort},
    taskLevel                   = {type = Protocol.DataType.char},
    fields                      = {'taskId','taskLevel'}
}
Protocol.structs[Protocol.S_2_C_REFRESH_DAY_TASK]                 = Protocol.Packet_S2C_RefreshDayTask

Protocol.Packet_Data_NewDayTask = {
    task_type                   = {type = Protocol.DataType.int},
    num                         = {type = Protocol.DataType.int},
    fields                      = {'task_type','num'}
}

Protocol.Packet_S2C_LoadNewDayTask = {
    select_double               = {type = Protocol.DataType.char},
    unfinish_task_num           = {type = Protocol.DataType.short},
    task                        = {type = Protocol.DataType.object, length = -1, clazz='Packet_Data_NewDayTask'},
    fields                      = {'select_double','unfinish_task_num','task'}
}
Protocol.structs[Protocol.S_2_C_LOAD_NEW_DAY_TASK]                 = Protocol.Packet_S2C_LoadNewDayTask

Protocol.Packet_S2C_DrawNewDayTaskReward = {
    task_type                   = {type = Protocol.DataType.int},
    res                         = {type = Protocol.DataType.char},
    fields                      = {'task_type','res'}
}
Protocol.structs[Protocol.S_2_C_DRAW_NEW_DAY_TASK_REWARD]                 = Protocol.Packet_S2C_DrawNewDayTaskReward

Protocol.Packet_S2C_NewDayTaskNotice = {
    task_type                   = {type = Protocol.DataType.int},
    num                         = {type = Protocol.DataType.int},
    fields                      = {'task_type','num'}
}
Protocol.structs[Protocol.S_2_C_NEW_DAY_TASK_NOTICE]                 = Protocol.Packet_S2C_NewDayTaskNotice

Protocol.Packet_S2C_SelectTaskDoubleReward = {
    select_double               = {type = Protocol.DataType.int},
    fields                      = {'select_double'}
}
Protocol.structs[Protocol.S_2_C_TASK_SELECT_DOUBLE_REWARD]                 = Protocol.Packet_S2C_SelectTaskDoubleReward