local WorldTask = class("WorldTask", require('app.base.ChildViewBase'))

WorldTask.RESOURCE_FILENAME = "world/WorldTask.csb"
WorldTask.RESOURCE_BINDING = {
    ["Button_2"]              = {["varname"] = "_btnTask",["events"] = {{["event"] = "touch",["method"] = "onTask"}}},
    ["Node_1/task_img"]       = {["varname"] = "_taskImg",["events"] = {{["event"] = "touch",["method"] = "onTask"}}},
    ["Node_1"]                = {["varname"] = "_taskNode"},
    ["Node_1/task_name"]      = {["varname"] = "_taskNameLabel"},
    ["Node_1/task_time"]      = {["varname"] = "_taskTimeLabel"},
}

function WorldTask:onCreate()
    WorldTask.super.onCreate(self)
    self._taskDialogShow = true
    services:addEventListener(services.EVENT_NAMES.ON_BATTLE_TASK_UPDATE, handler(self, self._onUpdateTaskInfo), "onBattleTaskUpdateByWorldTask")
end

function WorldTask:_onUpdateTaskInfo()
    local war_task = StaticData['war_task'][uq.cache.world_war.world_enter_info.season_id]
    local battle_info =  uq.cache.world_war.battle_task_info.items[uq.cache.world_war.battle_task_info.now_id]
    local xml_info = war_task.Stage[battle_info.id]
    self._taskNameLabel:setString(xml_info.title)
    self._taskTime = xml_info.duration - (uq.cache.server_data:getServerTime() - battle_info.begin_time)
    self._taskTimeLabel:setString(uq.getTime2(self._taskTime))
end

function WorldTask:onExit()
    services:removeEventListenersByTag('onBattleTaskUpdateByWorldTask')
    WorldTask.super.onExit(self)
end

function WorldTask:onTask(event)
    if event.name ~= "ended" then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.WORLD_TRENDS_MAIN, {})
end

return WorldTask