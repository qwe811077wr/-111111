local TaskUi = class("TaskUi", require('app.base.ChildViewBase'))

TaskUi.RESOURCE_FILENAME = "main_city/TasksUI.csb"
TaskUi.RESOURCE_BINDING = {
    ["Panel_press"]     = {["varname"] = "_panelPress",["events"] = {{["event"] = "touch",["method"] = "onOpenTask"}}},
    ["img_icon"]        = {["varname"] = "_imgIcon"},
    ["img_select"]      = {["varname"] = "_imgSelect"},
    ["label_des"]       = {["varname"] = "_desLabel"},
    ["img_over"]        = {["varname"] = "_imgOver"},
}

function TaskUi:onCreate()
    TaskUi.super.onCreate(self)
    self:parseView()
    self:initProtocal()
    self:initUi()
end

function TaskUi:initProtocal()
    services:addEventListener(services.EVENT_NAMES.ON_LOAD_MAIN_TASK, handler(self, self._onLoadMainTask), '_onLoadMainTaskByTaskUi')
end

function TaskUi:_onLoadMainTask()
    self:initUi()
end

function TaskUi:initUi()
    local info_array = uq.cache.task:getMainTask()
    if not info_array or #info_array == 0 then
        self:removeFromParent()
        return
    end
    local info = info_array[1]
    self._desLabel:setString(info.xml.Title[1].Title)
    if info.isComplete == 1 then
        self._imgSelect:setVisible(true)
        self._imgOver:setVisible(true)
    else
        self._imgSelect:setVisible(false)
        self._imgOver:setVisible(false)
    end
end

function TaskUi:onOpenTask(event)
    if event.name == "ended" then
        uq.ModuleManager:getInstance():show(uq.ModuleManager.TASKS_MODULE, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
    end
end

function TaskUi:onExit()
    services:removeEventListenersByTag("_onLoadMainTaskByTaskUi")
    TaskUi.super:onExit()
end

return TaskUi