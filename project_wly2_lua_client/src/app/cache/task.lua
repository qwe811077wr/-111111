local Task = class("Task")

function Task:ctor()
    self._curMainTaskInfo = nil
    self._curDailyTaskInfo = {}
    self._isExistTaskReward = false
    network:addEventListener(Protocol.S_2_C_LOAD_MAIN_TASK, handler(self, self._onLoadMaintask))
    network:addEventListener(Protocol.S_2_C_DRAW_MAIN_TASK_REWARD, handler(self, self._onDrawMainTaskReward))
    network:addEventListener(Protocol.S_2_C_LIVENESS_LOAD, handler(self, self._onLoadVitalityInfo))
    network:addEventListener(Protocol.S_2_C_LIVENESS_LIST, handler(self, self._onLoadVitalityList))
    network:addEventListener(Protocol.S_2_C_LIVENESS_DRAW_REWARD, handler(self, self._onVitalityListChanged))
    network:addEventListener(Protocol.S_2_C_LIVENESS_DRAW_CREDIT, handler(self, self._onVitalityBoxChanged))
    services:addEventListener(services.EVENT_NAMES.ON_TASK_UPDATE_RED, handler(self, self.updateRed))
end

function Task:_onLoadVitalityInfo(evt)
    if not evt.data then
        return
    end
    self._curDailyTaskInfo.credit = evt.data.credit
    self._curDailyTaskInfo.count = evt.data.count
    local numbers = {}
    for k, v in pairs(evt.data.numbers) do
        numbers[v] = v
    end
    self._curDailyTaskInfo.numbers = numbers
    services:dispatchEvent({name = services.EVENT_NAMES.ON_LOAD_DAILY_TASK})
    self:updateRed()
end

function Task:_onLoadVitalityList(evt)
    if not self._curDailyTaskInfo.items then
        self._curDailyTaskInfo.items = {}
    end

    for k, v in pairs(evt.data.items) do
        self._curDailyTaskInfo.items[v.id] = v
    end

    services:dispatchEvent({name = services.EVENT_NAMES.ON_LOAD_DAILY_TASK_LIST})
    self:updateRed()
end

function Task:_onVitalityListChanged(evt)
    if evt.data.ret == 1 then
        return
    end

    self._curDailyTaskInfo.items[evt.data.ident].state = 2
    self._curDailyTaskInfo.credit = evt.data.credit
    self:updateRed()
end

function Task:_onVitalityBoxChanged(evt)
    if evt.data.ret == 1 then
        return
    end
    self._curDailyTaskInfo.count = self._curDailyTaskInfo.count + 1
    self._curDailyTaskInfo.numbers[evt.data.ident] = evt.data.ident
    self:updateRed()
end

function Task:getVitalityInfo()
    return self._curDailyTaskInfo
end

function Task:_onDrawMainTaskReward(evt)
    network:sendPacket(Protocol.C_2_S_LOAD_MAIN_TASK, {})
end

function Task:_onLoadMaintask(evt)
    uq.log("Task:_onLoadMaintask  ",evt.data)
    self._curMainTaskInfo = evt.data.taskInfo
end

function Task:sortTask()
    if self._curMainTaskInfo == nil or #self._curMainTaskInfo < 2 then
        return self._curMainTaskInfo
    end
    table.sort(self._curMainTaskInfo,function(a,b)
        if a.isComplete == b.isComplete then
            if a.xml.taskType == b.xml.taskType then
                return a.xml.ident < b.xml.ident
            else
                return a.xml.taskType < b.xml.taskType
            end
        else
            return a.isComplete > b.isComplete
        end
    end)
end

function Task:updateRed()
    local is_red = false
    self._isExistTaskReward = false
    local info = StaticData['module'][uq.config.constant.MODULE_ID.DAILY_TASK]
    if info.openLevel and tonumber(info.openLevel) > uq.cache.role:level() then
        return
    end

    if info.openMission and math.floor(tonumber(info.openMission) / 100) ~= 0 then
        local instance_id = math.floor(tonumber(info.openMission) / 100)
        local instance_config =  StaticData['instance'][instance_id]
        local map_config = StaticData.load('instance/' .. instance_config.fileId).Map[instance_id].Object[info.openMission]
        if not uq.cache.instance:isNpcPassed(info.openMission) then
            return
        end
    end

    for k, v in ipairs(self._curDailyTaskInfo.items) do
        if v.state == 1 then
            is_red = true
            break
        end
    end
    --检测下边宝箱是否有可领取状态
    if self._curDailyTaskInfo.credit then
        local data = StaticData['livenesses'].Liveness
        for i = 1, #data do
            local num = 2 ^ (i - 1)
            local info = data[i]
            if self._curDailyTaskInfo.credit < info.credit then
                is_red = is_red or self:isExistTaskBox(info.ident)
                break
            end
        end
    end
    self._isExistTaskReward = is_red
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ACHIEVEMENT_MAIN_CITY_RED_REFRESH})
end

function Task:isExistTaskBox(id)
    local max_id = 0
    local count = 0
    for k, v in pairs(self._curDailyTaskInfo.numbers) do
        count = count + 1
        if v > max_id then
            max_id = v
        end
    end
    return max_id ~= 0 and max_id ~= count
end

function Task:getMainTask()
    return self._curMainTaskInfo
end

return Task