local PassCheck = class("PassCheck")

function PassCheck:ctor()
    self._passCardInfo = {}
    self._passTask = {}
    self._passShop = {}
    self._reds = {}
    self._freeGift = {}
    self._passGift = {}
    self._seasonEndTime = 0
    self._welfareGiftTimes = 0

    network:addEventListener(Protocol.S_2_C_PASSCARD_INFO_LOAD, handler(self, self._onInfoLoad))
    network:addEventListener(Protocol.S_2_C_PASSCARD_UPDATE_INFO, handler(self, self._onInfoUpdate))
    network:addEventListener(Protocol.S_2_C_PASSCARD_UPDATE_LEVEL, handler(self, self._onInfoUpdate))
    network:addEventListener(Protocol.S_2_C_PASSCARD_BUY_LEVEL, handler(self, self._onBuyLevel))
    network:addEventListener(Protocol.S_2_C_PASSCARD_LEVEL_DRAW_REWARD, handler(self, self._onLevelReward))
    network:addEventListener(Protocol.S_2_C_PASSCARD_TASK_UPDATE, handler(self, self._onTaskUpdate))
    network:addEventListener(Protocol.S_2_C_PASSCARDTASK_DRAW_REWARD, handler(self, self._onTaskReward))
    network:addEventListener(Protocol.S_2_C_PASSCARDTASK_LIVENESS_DRAW_REWARD, handler(self, self._onTaskBoxAdd))
    network:addEventListener(Protocol.S_2_C_PASSCARD_CHECKIN, handler(self, self._onCheckIn))
    network:addEventListener(Protocol.S_2_C_PASSCARD_GET_CHECKIN_REWARD, handler(self, self._onCheckInAgain))
    network:addEventListener(Protocol.S_2_C_PASSCARD_STONE_LOAD, handler(self, self._onShopLoad))
    network:addEventListener(Protocol.S_2_C_PASSCARD_STONE_BUY, handler(self, self._onShopBuy))
    network:addEventListener(Protocol.S_2_C_PASSCARD_ACTIVATE, handler(self, self.onActive))
    network:addEventListener(Protocol.S_2_C_PASSCARD_ACCEPT_TASK, handler(self, self.onAccept))
    network:addEventListener(Protocol.S_2_C_PASSCARD_ABANDON_TASK, handler(self, self.onAbandon))
    network:addEventListener(Protocol.S_2_C_PASSCARD_REFRESH_TASK, handler(self, self.onRefresh))
    network:addEventListener(Protocol.S_2_C_PASSCARD_DRAW_DAILY_FREE_GIFT, handler(self, self.onWelfareGift))
end

function PassCheck:_onInfoLoad(evt)
    self._passCardInfo = evt.data
    self._seasonEndTime = self:getSeasonEndTime()
    self._welfareGiftTimes = self._passCardInfo.daily_free_gift
    self:updateRed()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_PASS_CHECK_RED_REFRESH})

    self._freeGift = {}
    for k, item in ipairs(self._passCardInfo.free_gift) do
        self._freeGift[item] = 1
    end
    self._passGift = {}
    for k, item in ipairs(self._passCardInfo.pass_gift) do
        self._passGift[item] = 1
    end
end

function PassCheck:isCanBuyWelfareGift()
    return self._welfareGiftTimes <= 0
end

function PassCheck:onWelfareGift(msg)
    if msg.data.ret ~= 0 then
        return
    end
    self._welfareGiftTimes = 1
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ACHIEVEMENT_WELFARE_GIFT})
    self:updateRed()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_PASS_CHECK_RED_REFRESH})
end

function PassCheck:setOneKeyFinish()
    if not self._passCardInfo or next(self._passCardInfo) == nil then
        return
    end
    self._freeGift = {}
    self._passGift = {}
    self._passCardInfo.pass_gift = {}
    self._passCardInfo.free_gift = {}
    for i = 1, self._passCardInfo.level do
        table.insert(self._passCardInfo.pass_gift, i)
        table.insert(self._passCardInfo.free_gift, i)
        self._freeGift[i] = 1
        self._passGift[i] = 1
    end
end

function PassCheck:isSignOrByid(id)
    if self._passCardInfo.can_checkin > 0 then
        return id == self._passCardInfo.checkin_idx + 1
    end
    if self._passCardInfo.left_repair_nums <= 0 or id ~= self._passCardInfo.checkin_idx + 1 then
        return false
    end
    local data = StaticData['pass']['Info'][self._passCardInfo.season_id]
    if not data or not data['Complement'] or not data['Complement'][self._passCardInfo.repair_times + 1] or not data['Complement'][self._passCardInfo.repair_times + 1].cost then
        return false
    end
    local cost_item = uq.RewardType.new(data['Complement'][self._passCardInfo.repair_times + 1].cost)
    return uq.cache.role:checkRes(cost_item:type(), cost_item:num(), cost_item:id())
end

function PassCheck:isCanOneKeyFinish()
    if not self._passCardInfo.pass_gift or not self._passCardInfo.free_gift or not self._passCardInfo.level then
        return false
    end
    return #self._passCardInfo.pass_gift < self._passCardInfo.level or #self._passCardInfo.free_gift < self._passCardInfo.level
end

function PassCheck:_onInfoUpdate(evt)
    local gift_type = 0
    local count = self:getGiftNum(self._passCardInfo.daily_gift)
    local count1 = self:getGiftNum(self._passCardInfo.spec_gift)
    if evt.data.daily_gift_count and (count ~= evt.data.daily_gift_count or
         self:compareGift(self._passCardInfo.daily_gift, evt.data.daily_gift)) then
        gift_type = 1
    elseif evt.data.spec_gift_count and (count1 ~= evt.data.spec_gift_count or
         self:compareGift(self._passCardInfo.spec_gift, evt.data.spec_gift)) then
        gift_type = 2
    end

    local info = {show_type = 0, level = evt.data.level, season_id = self._passCardInfo.season_id}
    if evt.data.state and self._passCardInfo.state ~= evt.data.state then
        info.show_type = 1
    elseif evt.data.state and self._passCardInfo.level < evt.data.level then
        info.show_type = 2
    end

    for k, v in pairs(evt.data) do
        self._passCardInfo[k] = v
    end
    if info.show_type ~= 0 then
        services:dispatchEvent({name = services.EVENT_NAMES.ON_PASS_CHECK_LEVEL_SHOW, data = info})
    end
    self:updateRed()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_REFRESH_PASS_CHECK_INFO, data = gift_type})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_PASS_CHECK_RED_REFRESH})
end

function PassCheck:compareGift(old_gift, new_gift)
    for k, v in pairs(old_gift) do
        if v.num ~= new_gift[k].num then
            return true
        end
    end
    return false
end

function PassCheck:_onBuyLevel(evt)
    if evt.data.ret == 0 then
        services:dispatchEvent({name = services.EVENT_NAMES.ON_PASS_CHECK_BUY_LEVEL})
    end
end

function PassCheck:_onLevelReward(evt)
    if evt.data.draw_type == 1 then
        table.insert(self._passCardInfo.free_gift, evt.data.id)
        self._freeGift[evt.data.id] = 1
    else
        table.insert(self._passCardInfo.pass_gift, evt.data.id)
        self._passGift[evt.data.id] = 1
    end
    self:setLevelRed()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_REFRESH_PASS_CHECK_INFO})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_PASS_CHECK_RED_REFRESH})
end

function PassCheck:_onTaskUpdate(evt)
    self._passTask = {}
    for k, v in ipairs(evt.data.items) do
        self._passTask[v.id] = v
    end
    if next(self._passCardInfo) then
        self:updateRed()
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_INIT_PASS_CARD_TASK})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_PASS_CHECK_RED_REFRESH})
end

function PassCheck:_onTaskReward(evt)
    if evt.data.ret ~= 0 then
        return
    end
    --接取任务
    self._passCardInfo.task_num = self._passCardInfo.task_num + 1
    self._passCardInfo.liveness = evt.data.liveness
    local xml_data = StaticData['pass']['Info'][self._passCardInfo.season_id].Task[evt.data.id]
    uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, {rewards = xml_data.reward})

    self._passTask[evt.data.id].state = uq.config.constant.TYPE_PASS_CARD_TASK_STATE.ST_DRAWD
    self:updateRed()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_PASS_CHECK_TASK_UPDATE})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_PASS_CHECK_RED_REFRESH})
end

function PassCheck:_onTaskBoxAdd(evt)
    if evt.data.ret ~= 0 then
        return
    end

    table.insert(self._passCardInfo.liviness_gift, evt.data.id)
    local xml_data = StaticData['pass']['Info'][self._passCardInfo.season_id].Total[evt.data.id]
    uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, {rewards = xml_data.reward})

    self:updateRed()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_PASS_CHECK_TASK_UPDATE})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_PASS_CHECK_RED_REFRESH})
end

function PassCheck:_onCheckIn(evt)
    if evt.data.ret ~= 0 then
        return
    end
    self._passCardInfo.state = evt.data.passcard_state
    self._passCardInfo.checkin_idx = evt.data.checkin_day
    self._passCardInfo.repair_times = evt.data.repair_times
    self._passCardInfo.last_checkin_time = evt.data.last_checkin_time
    self._passCardInfo.left_repair_nums = evt.data.left_repair_nums
    self._passCardInfo.can_checkin = evt.data.can_checkin
    self:setCheckInRed()
    self:updateRed()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_PASS_CHECK_RED_REFRESH})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_REFRESH_PASS_CHECK_INFO})
end

function PassCheck:onActive(evt)
    if evt.data.ret == 0 then
        --已经激活
        if self._passCardInfo.state == 0 then
            services:dispatchEvent({name = services.EVENT_NAMES.ON_PASS_CHECK_LEVEL_SHOW, data = {show_type = 1, season_id = self._passCardInfo.season_id}})
        end
        self._passCardInfo.state = 1
        self._passCardInfo.checkin_activated = 1
        self:setCheckInRed()
        self:updateRed()
        services:dispatchEvent({name = services.EVENT_NAMES.ON_PASS_CHECK_RED_REFRESH})
        services:dispatchEvent({name = services.EVENT_NAMES.ON_REFRESH_PASS_CHECK_INFO})
    end
end

function PassCheck:_onCheckInAgain(evt)
    if evt.data.ret ~= 0 then
        return
    end
    for k, v in pairs(self._passCardInfo.left_reward) do
        if v == evt.data.id then
            table.remove(self._passCardInfo.left_reward, k)
            break
        end
    end
    self:setCheckInRed()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_PASS_CHECK_RED_REFRESH})
end

function PassCheck:_onShopLoad(evt)
    self._passShop = evt.data.items
    services:dispatchEvent({name = services.EVENT_NAMES.ON_PASS_CHECK_LIMIT_SHOP_REFRESH})
end

function PassCheck:_onShopBuy(evt)
    if evt.data.ret ~= 0 then
        return
    end
    local is_first = true
    for k, v in pairs(self._passShop) do
        if v.id == evt.data.id then
            v.num = v.num + evt.data.num
            is_first = false
            break
        end
    end
    if is_first then
        table.insert(self._passShop, {id = evt.data.id, num = evt.data.num})
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_PASS_CHECK_LIMIT_SHOP_BUY, data = evt.data})
end

function PassCheck:updateRed()
    -- 考核等级
    self:setLevelRed()
    -- 签到
    self:setCheckInRed()

    self._reds[3] = false
    self._reds[4] = false
    self._reds[5] = false
    if self._passCardInfo.state == 0 then
        return
    end
    --考核任务
    self:setTaskRed()
    --每日特惠
    self:setDailyRed()
end

function PassCheck:isRedModule(id)
    return self._reds[id]
end

function PassCheck:getGiftNum(data)
    local count = 0
    for k, v in pairs(data) do
        count = count + 1
    end
    return count
end

function PassCheck:setLevelRed()
    self._reds[1] = false
    local count = self:getGiftNum(self._passCardInfo.free_gift)
    local count1 = self:getGiftNum(self._passCardInfo.pass_gift)
    if count < self._passCardInfo.level or (self._passCardInfo.state ~= 0 and count1 < self._passCardInfo.level) then
        self._reds[1] = true
    end
end

function PassCheck:setCheckInRed()
    self._reds[2] = self._passCardInfo.can_checkin > 0
end

function PassCheck:setTaskRed()
    local data = StaticData['pass']['Info'][self._passCardInfo.season_id]
    local rewards = data['Total']
    local is_exist_task = false
    for k, v in pairs(self._passTask) do
        if v.state == uq.config.constant.TYPE_PASS_CARD_TASK_STATE.ST_FINISHED then
            is_exist_task = true
        end
    end

    local max_box_id = 1
    for k, v in ipairs(rewards) do
        if self._passCardInfo.liveness < v.nums then
            max_box_id = v.ident - 1
            break
        end
    end
    local count = self:getGiftNum(self._passCardInfo.liviness_gift)
    if max_box_id ~= count or is_exist_task then
        self._reds[3] = true
    end
end

function PassCheck:setDailyRed()
    self._reds[4] = self:isCanBuyWelfareGift()
end

function PassCheck:getBuyTimes(data)
    local buy_times = 0
    local min_buy = 0
    local times_info = string.split(data.buyTimes, ';')
    for k, v in ipairs(times_info) do
        local info = string.split(v, ',')
        if tonumber(info[1]) <= self._passCardInfo.level then
            buy_times = tonumber(info[2])
        end
    end
    min_buy = buy_times

    for k, v in pairs(self._passCardInfo.spec_gift) do
        if v.id == data.ident then
            buy_times = buy_times - v.num
            break
        end
    end
    return buy_times, min_buy
end

function PassCheck:getSeasonEndTime()
    local tab = StaticData['pass']['Info'][self._passCardInfo.season_id]
    if tab and tab.durationDay then
        return self._passCardInfo.begin_time + tab.durationDay * 24 * 3600
    end
    return self._passCardInfo.begin_time or uq.cache.server_data:getServerTime()
end

function PassCheck:getSurplusTimeString()
    local surplus_time = math.max(self._seasonEndTime - uq.cache.server_data:getServerTime(), 0)
    local day = math.floor(surplus_time / 86400)
    local hour = math.floor((surplus_time - day * 86400) / 3600)
    local minutes = math.floor((surplus_time - day * 86400 - hour * 3600) / 60) + 1
    return string.format(StaticData["local_text"]["activity.sign.surplus.time"], day, hour, minutes)
end

function PassCheck:isTaskExist()
    for k, item in pairs(self._passTask) do
        if item.state == uq.config.constant.TYPE_PASS_CARD_TASK_STATE.ST_ACCEPT or item.state == uq.config.constant.TYPE_PASS_CARD_TASK_STATE.ST_FINISHED then
            return true, k
        end
    end
    return false
end

function PassCheck:onAccept(evt)
    if evt.data.ret == 0 then
        local xml_data = StaticData['pass']['Info'][self._passCardInfo.season_id].Task[evt.data.id]
        local task_data = self._passTask[evt.data.id]
        if xml_data.nums == task_data.num then
            self._passTask[evt.data.id].state = uq.config.constant.TYPE_PASS_CARD_TASK_STATE.ST_FINISHED
        else
            self._passTask[evt.data.id].state = uq.config.constant.TYPE_PASS_CARD_TASK_STATE.ST_ACCEPT
        end
        services:dispatchEvent({name = services.EVENT_NAMES.ON_PASS_CHECK_TASK_UPDATE})
        services:dispatchEvent({name = services.EVENT_NAMES.ON_PASS_CHECK_RED_REFRESH})
    end
end

function PassCheck:onAbandon(evt)
    if evt.data.ret == 0 then
        self._passTask[evt.data.id].state = uq.config.constant.TYPE_PASS_CARD_TASK_STATE.ST_ABANDON
        services:dispatchEvent({name = services.EVENT_NAMES.ON_PASS_CHECK_TASK_UPDATE})
        services:dispatchEvent({name = services.EVENT_NAMES.ON_PASS_CHECK_RED_REFRESH})
    end
end

function PassCheck:onRefresh(evt)
    if evt.data.ret == 0 then
        self._passCardInfo.task_refresh_nums = self._passCardInfo.task_refresh_nums + 1
        services:dispatchEvent({name = services.EVENT_NAMES.ON_PASS_CHECK_TASK_UPDATE})
    end
end

function PassCheck:getTaskRefreshCost()
    local num = self._passCardInfo.task_refresh_nums + 1
    local str = ''
    local xml_data = StaticData['constant'][16].Data
    if num >= #xml_data then
        str = xml_data[#xml_data].cost
    else
        str = xml_data[num].cost
    end
    local strs = string.split(str, ';')
    return tonumber(strs[2])
end

function PassCheck:isCanOpenPassCheck()
    return self._seasonEndTime > uq.curServerSecond()
end

return PassCheck