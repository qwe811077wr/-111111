local FlyNail = class("FlyNail")

function FlyNail:ctor()
    self.flyNailInfo = nil
    self._fly_nail_red_tag = "update_fly_nail_time" .. tostring(self)
    network:addEventListener(Protocol.S_2_C_MIRACLE_FIGHT_LOAD, handler(self, self._onMiracleFightLoad))
    network:addEventListener(Protocol.S_2_C_MIRACLE_FIGHT_LEVEL_UP, handler(self, self._onMiracleFightLevelUp))
    network:addEventListener(Protocol.S_2_C_MIRACLE_FIGHT_DRAW_REWARD, handler(self, self._onMiracleFightDrawReward))
end

function FlyNail:_onMiracleFightLevelUp(evt)
    for k, v in ipairs(self.flyNailInfo.items) do
        if v.id == evt.data.id then
            self.flyNailInfo.items[k].lvl = evt.data.lvl
            break
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_FLYNAIL_LEVEL_UP, data = evt.data})
end

function FlyNail:getFlyNailInfo()
    return self.flyNailInfo
end

function FlyNail:checkGeneralIsInFormationById(id)
    if not self.flyNailInfo or next(self.flyNailInfo.generals) == nil then
        return false
    end
    for k, v in ipairs(self.flyNailInfo.generals) do
        if id == v.general_id then
            return true
        end
    end
    return false
end

function FlyNail:_onMiracleFightDrawReward(evt)
    if evt.data.ret == 1 then
        return
    end
    for k, v in ipairs(self.flyNailInfo.items) do
        if v.id == evt.data.id then
            v.left_time = 0
            v.time_id = 0
            v.general_id1 = 0
            v.general_id2 = 0
            break
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_FLYNAIL_DRAW_REWARD, data = evt.data})
    self:updateRed()
end

function FlyNail:_onMiracleFightLoad(evt)
    uq.log("_miracleFightLoad  ",evt.data)
    self.flyNailInfo = evt.data
    for k, v in pairs(self.flyNailInfo.items) do
        v.left_time = v.left_time + os.time()
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_FLYNAIL_LOAD})
    self:updateRed()
end

function FlyNail:setFormation(data)
    self.flyNailInfo.formation_id = data.formation_id
    self.flyNailInfo.generals = data.general_loc
end

function FlyNail:updateRed()
    local is_red = false
    local is_time = false
    local min_times = os.time()
    for k, v in pairs(self.flyNailInfo.items) do
        if v.left_time - os.time() <= 0 and v.general_id1 > 0 then
            is_red = true
            break
        end
        if v.left_time - os.time() > 0 then
            min_times = math.min(min_times, v.left_time - os.time())
            is_time = true
        end
    end
    if not is_red and is_time then
        local call_back = function()
            min_times = min_times - 1
            if min_times <= 0 then
                uq.TimerProxy:removeTimer(self._fly_nail_red_tag)
                uq.cache.hint_status.status[uq.cache.hint_status.RED_TYPE.FLY_NAIL] = is_red
                uq.cache.daily_activity:updateRed()
            end
        end
        if not uq.TimerProxy:hasTimer(self._fly_nail_red_tag) then
            uq.TimerProxy:addTimer(self._fly_nail_red_tag, call_back, 1, -1)
        end
    end
    uq.cache.hint_status.status[uq.cache.hint_status.RED_TYPE.FLY_NAIL] = is_red
    uq.cache.daily_activity:updateRed()
end

return FlyNail