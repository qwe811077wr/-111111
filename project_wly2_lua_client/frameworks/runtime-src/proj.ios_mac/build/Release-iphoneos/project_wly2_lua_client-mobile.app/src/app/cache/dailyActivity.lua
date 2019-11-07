local DailyActivity = class("DailyActivity")

function DailyActivity:ctor()
    self.daily_instance_info = nil
    network:addEventListener(Protocol.S_2_C_DAILY_INSTANCE_LOAD, handler(self, self._onDailyInstanceLoad))
    network:addEventListener(Protocol.S_2_C_DAILY_INSTANCE_SWEEP, handler(self, self._onDailyInstanceSweep))
end

function DailyActivity:_onDailyInstanceSweep(evt)
    if evt.data.ret ~= 0 then
        return
    end
    local find_state = false
    for k, v in ipairs(self.daily_instance_info.nums) do
        if v.id == evt.data.group_id then
            self.daily_instance_info.nums[k].num = v.num + 1
            find_state = true
            break
        end
    end
    if not find_state then
        table.insert(self.daily_instance_info.nums, {id = evt.data.group_id, num = 1})
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_DAILY_INSTANCE_SWEEP, data = evt.data})
end

function DailyActivity:getDailyInstanceBattleNum(index)
    for k,v in ipairs(self.daily_instance_info.nums) do
        if v.id == index then
            return v.num
        end
    end
    return 0
end

function DailyActivity:_onDailyInstanceLoad(evt)
    self.daily_instance_info = evt.data
    services:dispatchEvent({name = services.EVENT_NAMES.ON_DAILY_INSTANCE_LOAD})
end

function DailyActivity:getPassInfo(index)
    if self.daily_instance_info.pass_ids == nil or #self.daily_instance_info.pass_ids == 0 then
        return nil
    end
    for k, v in pairs(self.daily_instance_info.pass_ids) do
        if v.id == index then
            return v
        end
    end
    return nil
end

function DailyActivity:getMaxTabDifficulty(index)
    local pass_info = self:getPassInfo(index)
    if pass_info == nil then
        return 0
    end
    if #pass_info.ids > 1 then
        table.sort(pass_info.ids, function(a, b)
            return a < b
        end)
    end
    if #pass_info.ids > 0 then
        return pass_info.ids[#pass_info.ids]
    end
    return 0
end

function DailyActivity:updateRed()
    local red_type = {
        uq.cache.hint_status.RED_TYPE.ANCIENT,
        uq.cache.hint_status.RED_TYPE.FLY_NAIL,
    }
    local is_red = false
    for k, v in ipairs(red_type) do
        if is_red then
            break
        else
            is_red = uq.cache.hint_status.status[v]
        end
    end
    uq.cache.hint_status.status[uq.cache.hint_status.RED_TYPE.MAIN_CITY_DAILY_ACTIVITY] = is_red
    services:dispatchEvent({name = services.EVENT_NAMES.ON_MAIN_CITY_TOP_SIDE_RED_CHANGES, data = uq.cache.hint_status.RED_TYPE.MAIN_CITY_DAILY_ACTIVITY})
end

return DailyActivity