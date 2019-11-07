local Achievement = class("achievement")

function Achievement:ctor()
    self._chapters = {}
    self._tasks = {}
    self._mainTask = {}
    self._taskSearch = {}
    self._levelFreeBag = {}
    self._levelBuyBag = {}
    self._sevenOpenRed = {}
    self._checkinId = 0
    self._repairTimes = 0
    self._cycleTimes = 0
    self._canSign = 0
    self._isOpenChapter = false
    self._idOpenChapter = 1
    self._isExistAchieveReward = false
    self._signSurplusTime = 0

    self._taskDaySevenInfo = {}
    self._taskDaySevenItems = {}
    self._taskDaySevenItemsSearch = {}

    network:addEventListener(Protocol.S_2_C_ACHIEVEMENT_CHAPTER_LOAD, handler(self, self._onAchievementChapterLoad))
    network:addEventListener(Protocol.S_2_C_ACHIEVEMENT_TASK_LOAD, handler(self, self._onAchievementTaskLoad))
    network:addEventListener(Protocol.S_2_C_ACHIEVEMENT_TASK_END, handler(self, self._onAchievementTaskEnd))
    network:addEventListener(Protocol.S_2_C_ACHIEVEMENT_ITEM_UPDATE, handler(self, self._onAchievementItemUpdate))
    network:addEventListener(Protocol.S_2_C_ACHIEVEMENT_DRAW, handler(self, self._onAchievementDraw))

    network:addEventListener(Protocol.S_2_C_TASK_DAY7_LOAD, handler(self, self._onTaskDaySevenLoad))
    network:addEventListener(Protocol.S_2_C_TASK_DAY7_ITEM_UPDATE, handler(self, self._onTaskDaySevenItemUpdate))
    network:addEventListener(Protocol.S_2_C_TASK_DAY7_STORE_BUY, handler(self, self._onTaskDaySevenStoreBuy))
    network:addEventListener(Protocol.S_2_C_TASK_DAY7_DRAW_TOTAL, handler(self, self._onTaskDaySevenTotalReward))

    network:addEventListener(Protocol.S_2_C_LEVEL_GIFT_LOAD, handler(self, self._onLevelGiftLoad))
    network:addEventListener(Protocol.S_2_C_LEVEL_GIFT_ITEM_UPDATE, handler(self, self._onLevelGiftItemUpdate))
    network:addEventListener(Protocol.S_2_C_LEVEL_GIFT_DRAW, handler(self, self._onLevelGiftDraw))

    network:addEventListener(Protocol.S_2_C_ROLE_CHECKIN_LOAD, handler(self, self._onRoleCheckinLoad))
    network:addEventListener(Protocol.S_2_C_ROLE_CHECKIN, handler(self, self._onRoleCheckin))
    services:addEventListener(services.EVENT_NAMES.ON_ACHIEVEMENT_UPDATE_RED, handler(self, self.judgeExistReward))
end

function Achievement:_onAchievementChapterLoad(msg)
    for k, v in pairs(msg.data.chapters) do
        v.tasks = {}
        table.insert(self._chapters, v)
    end
end

function Achievement:_onAchievementTaskLoad(msg)
    for i, item in pairs(msg.data.tasks) do
        table.insert(self._tasks, item)
        self._taskSearch[item.id] = item

        for k, v in pairs(self._chapters) do
            if item.chapter_id == v.id then
                table.insert(v.tasks, item)
            end
        end
    end
end

function Achievement:_onAchievementTaskEnd(msg)
    self:getMainTask()
    self:judgeExistReward()
    table.sort(self._chapters, function(item1, item2)
        return item1.id < item2.id
    end)
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ACHIEVEMENT_REFRESH})
end

function Achievement:getMinTask()
    if next(self._mainTask) == nil then
        return
    end
    local sort_table = {2, 3, 1}
    if self._mainTask.tasks and #self._mainTask.tasks > 1 then
        table.sort(self._mainTask.tasks, function(a, b)
            if a.state == b.state then
                return a.id < b.id
            end
            return sort_table[a.state + 1] > sort_table[b.state + 1]
        end)
    end

    local total_num = #self._mainTask.tasks
    local cur_num = 0

    for k, v in ipairs(self._mainTask.tasks) do
        if v.state == uq.config.constant.TYPE_ACHIEVEMENT_STATE.REWARD then
            cur_num = total_num - k + 1
            break
        end
    end
    local xml_data = StaticData['achievements'][self._mainTask.id]
    local cache_data = self._mainTask.tasks[1]
    local min_data = xml_data['Task'][cache_data.id]
    local data = {
        chapter_num = xml_data.des,
        chapter_name = xml_data.des1,
        task_content = min_data.des,
        task_cur_num = cur_num,
        task_all_num = total_num
    }
    return data
end

function Achievement:getMainTask()
    for k, v in pairs(self._chapters) do
        if StaticData['achievements'][v.id] then
            local task_type = StaticData['achievements'][v.id]['type']
            if task_type == uq.config.constant.TYPE_ACHIEVEMENT_CHAPTER.MAIN then
                --主线
                self._mainTask = v
                table.remove(self._chapters, k)
            end
        end
    end
    if next(self._mainTask) ~= nil then
        return
    end
    self._mainTask = {}
    self._mainTask.ids = {}
    self._mainTask.tasks = {}
    self._mainTask.count1 = 0
    self._mainTask.id = -1
    local max_index = -1
    for k, v in pairs(StaticData['achievements']) do
        if self._mainTask.id < v.ident and v.type == uq.config.constant.TYPE_ACHIEVEMENT_CHAPTER.MAIN then
            self._mainTask.id = v.ident
            max_index = k
        end
    end
    if max_index == -1 then
        return
    end
    for k, v in pairs(StaticData['achievements'][self._mainTask.id].Task) do
        local temp_task = {}
        temp_task.id = v.ident
        temp_task.chapter_id = self._mainTask.id
        temp_task.state = uq.config.constant.TYPE_ACHIEVEMENT_STATE.REWARD
        temp_task.value = v.num
        table.insert(self._mainTask.tasks, temp_task)
    end
end

function Achievement:_onAchievementItemUpdate(msg)
    for k,v in pairs(msg.data.items) do
        for i, item in pairs(self._tasks) do
            if v.id == item.id then
                item.state = v.state
                item.value = v.value
                break
            end
        end
    end

    self:judgeExistReward()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ACHIEVEMENT_BOUNDARY_REFRESH})
end

function Achievement:judgeExistReward()
    self._isExistAchieveReward = false

    local info = StaticData['module'][uq.config.constant.MODULE_ID.ACHIEVEMENT]
    if info.openLevel and tonumber(info.openLevel) > uq.cache.role:level() then
        return
    end

    if info.openMission and math.floor(tonumber(info.openMission) / 100) ~= 0 then
        local instance_id = math.floor(tonumber(info.openMission) / 100)
        local instance_config =  StaticData['instance'][instance_id]
        if not instance_config then
            return
        end
        local map_config = StaticData.load('instance/' .. instance_config.fileId).Map[instance_id].Object[info.openMission]
        if not uq.cache.instance:isNpcPassed(info.openMission) then
            return
        end
    end

    if next(self._mainTask) == nil then
        services:dispatchEvent({name = services.EVENT_NAMES.ON_ACHIEVEMENT_MAIN_CITY_RED_REFRESH})
        return
    end
    self:isExistMainCityAchieveRed(self._mainTask)
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ACHIEVEMENT_MAIN_CITY_RED_REFRESH})
end

function Achievement:isExistMainCityAchieveRed(task)
    local is_has_achieve = self:isExistAchieveReward(task)
    if is_has_achieve then
        self._isExistAchieveReward = true
    end
end

function Achievement:isExistNotReceivedBox(id)
    local count = self:getCompleteNum(id)
    local xml_data = StaticData['achievements'][id]['Achieve']
    local end_id = self:getContinuityEndId(id, xml_data)
    for i = end_id, end_id + 2 do
        local achieve_data = xml_data[i] or {}
        if achieve_data.value and count >= achieve_data.value then
            local is_exsit = self:comparison(achieve_data.ident, id)
            if is_exsit then
                return true
            end
        end
    end
    return false
end

function Achievement:getContinuityEndId(chapter_id, xml_data)
    -- 得到第一个宝箱的id
    local ids = self:getIdsByChapterId(chapter_id)
    local prefix = self:getAchieveBoxIdPrefix(chapter_id)
    local end_id = xml_data[prefix + 1].ident

    table.sort(ids, function(a, b)
        return a < b
    end)

    --没有已领取的宝箱或第一个宝箱未领取
    if #ids < 1 or ids[1] ~= end_id then
        return  end_id
    end

    for i = 2, #ids do
        --处于最后三个宝箱
        if not xml_data[ids[i] + 2] then
            return end_id
        end

        --宝箱未连续，返回前一个宝箱id
        if ids[i] ~= ids[i - 1] + 1 then
            return end_id
        end

        end_id = ids[i]
    end
    return end_id
end

function Achievement:comparison(achieve_id, chapter_id)
    local cache_ids = self:getIdsByChapterId(chapter_id)
    if cache_ids ~= nil then
        for k, v in pairs(cache_ids) do
            if v == achieve_id then
                return false
            end
        end
        return true
    end
    return false
end

function Achievement:getIdsByChapterId(chapter_id)
    if chapter_id == self._mainTask.id then
        return self._mainTask.ids
    end

    for k, v in pairs(self._chapters) do
        if v.id == chapter_id then
            return v.ids
        end
    end
    return
end

function Achievement:getCompleteNum(id)
    local count = 0
    for k, v in pairs(self._tasks) do
        if v.chapter_id == id then
            local is_pre = self:isPreTaskAchieved(v.chapter_id, v.id)
            if v.state >= uq.config.constant.TYPE_ACHIEVEMENT_STATE.FINISHED and is_pre then
                count = count + 1
            end
        end
    end
    return count
end

function Achievement:getAchieveBoxIdPrefix(id)
    local chapter_type = StaticData['achievements'][id]['type']
    local achieve_id_prefix = 0
    if chapter_type == uq.config.constant.TYPE_ACHIEVEMENT_CHAPTER.MAIN then
        achieve_id_prefix = 10000 + id * 100
    elseif chapter_type == uq.config.constant.TYPE_ACHIEVEMENT_CHAPTER.BRANCH then
        achieve_id_prefix = 20000 + (id - 100) * 100
    end
    return achieve_id_prefix
end

function Achievement:isExistAchieveReward(task)
    local is_has_achieve = false
    local is_has = false
    local is_exist_box = self:isExistNotReceivedBox(task.id)
    for i, item in pairs(self._tasks) do
        if task.id == item.chapter_id then
            if (self:isPreTaskAchieved(item.chapter_id, item.id) and item.state == uq.config.constant.TYPE_ACHIEVEMENT_STATE.FINISHED) or is_exist_box then
                is_has = true
                is_has_achieve = true
                task.exist_reward = true
                self._isExistAchieveReward = true
                break
            end
        end
    end
    if not is_has then
        task.exist_reward = false
    end
    return is_has_achieve
end

function Achievement:isPreTaskAchieved(chapter_id, task_id)
    local task = StaticData['achievements'][chapter_id]['Task'][task_id]
    local pre_id = 0
    if task then
        pre_id = task['preTask']
    end
    return pre_id == 0 or self._taskSearch[pre_id].state == uq.config.constant.TYPE_ACHIEVEMENT_STATE.REWARD
end

function Achievement:_onAchievementTasksUpdate(data)
    if data.rwd_type == uq.config.constant.TYPE_ACHIEVEMENT_REWARD.TASK then
        for k, v in pairs(self._tasks) do
            if v.id == data.id then
                v.state = uq.config.constant.TYPE_ACHIEVEMENT_STATE.REWARD
                break
            end
        end
    elseif data.rwd_type == uq.config.constant.TYPE_ACHIEVEMENT_REWARD.BOX then
        if data.chapter_id == self._mainTask.id then
            table.insert(self._mainTask.ids, data.id)
        else
            for k, v in pairs(self._chapters) do
                if data.chapter_id == v.id then
                    table.insert(v.ids, data.id)
                end
            end
        end

        services:dispatchEvent({name = services.EVENT_NAMES.ON_ACHIEVEMENT_BOX_SHOW_REWARD, data = data.id})
    end

    self:judgeExistReward()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ACHIEVEMENT_BOUNDARY_REFRESH})
end

function Achievement:_onAchievementDraw(msg)
    if msg.data.finished == uq.config.constant.TYPE_ACHIEVEMENT_CHAPTER_FINISHED.FINISHED then
        self._isOpenChapter = true
        self._idOpenChapter = self._mainTask.id
    end

    self:_onAchievementTasksUpdate(msg.data)
end

function Achievement:showOpenChapter()
    if not self._isOpenChapter then
        return
    end
    self._isOpenChapter = false
    if uq.cache.guide:getUnopenTriggerGuide(uq.config.constant.GUIDE_TRIGGER.CHAPTER_FINISH, self._idOpenChapter) == 0 then
        services:dispatchEvent({name = services.EVENT_NAMES.ON_ACHIEVEMENT_OPEN, data = self._idOpenChapter + 1})
    else
        uq.cache.guide:openTriggerGuide(uq.config.constant.GUIDE_TRIGGER.CHAPTER_FINISH, self._idOpenChapter)
    end
end

function Achievement:_onTaskDaySevenLoad(msg)
    self._taskDaySevenInfo = msg.data
    self:updataSevenRed()
end

function Achievement:_onTaskDaySevenItemUpdate(msg)
    for i, item in pairs(msg.data.items) do
        local day_type = math.floor(item.id / 1000)

        if not self._taskDaySevenItems[day_type] then
            self._taskDaySevenItems[day_type] = {}
        end

        if not self._taskDaySevenItemsSearch[item.id] then
            self._taskDaySevenItemsSearch[item.id] = item
            table.insert(self._taskDaySevenItems[day_type], item)
        else
            local old_item = self._taskDaySevenItemsSearch[item.id]
            old_item.state = item.state
            old_item.num = item.num
        end
    end

    services:dispatchEvent({name = services.EVENT_NAMES.ON_TASK_DAY_ITEM_REFRESH})
    self:updataSevenRed()
end

function Achievement:_onTaskDaySevenStoreBuy(msg)
    for k, v in pairs(self._taskDaySevenInfo.store_nums) do
        if v.id == msg.data.id then
            v.num = msg.data.num
            services:dispatchEvent({name = services.EVENT_NAMES.ON_TASK_DAY_BUY_REFRESH})
            self:updataSevenRed()
            return
        end
    end

    local data = {
        id = msg.data.id,
        num = msg.data.num
    }
    table.insert(self._taskDaySevenInfo.store_nums, data)
    self:updataSevenRed()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_TASK_DAY_BUY_REFRESH})
end

function Achievement:_onTaskDaySevenTotalReward(msg)
    table.insert(self._taskDaySevenInfo.total_reward_ids, msg.data.id)
    services:dispatchEvent({name = services.EVENT_NAMES.ON_TASK_DAY_TOTAL_REFRESH, id = msg.data.id})
end
--等级礼包
function Achievement:_onLevelGiftLoad(evt)
    local data = evt.data
    self._levelFreeBag = data.ids or {}
    self._levelBuyBag = data.goods or {}
    for k, v in pairs(self._levelBuyBag) do
        v.surplus = v.surplus + uq.cache.server_data:getServerTime()
    end
    self:updataLevelRed()
end

function Achievement:_onLevelGiftItemUpdate(evt)
    local data = evt.data
    local tab = StaticData['level_gift']
    if tab and tab[data.id] and next(tab[data.id]) ~= nil then
        table.insert(self._levelFreeBag, data.id)
        local info = tab[data.id]
        table.insert(self._levelBuyBag, {id = data.id, num = 0, surplus = info.duration + uq.cache.server_data:getServerTime()})
    end
    self:updataLevelRed()
end

function Achievement:_onLevelGiftDraw(evt)
    local data = evt.data
    if data.ret ~= 0 then
        uq.fadeInfo(StaticData["local_text"]["activity.fail.buy"])
        return
    end
    if data.gift_type == 0 then
        for k, v in pairs(self._levelFreeBag) do
            if v == data.id then
                table.remove(self._levelFreeBag, k)
                break
            end
        end
    else
        for k, v in pairs(self._levelBuyBag) do
            if v.id == data.id then
                v.num = v.num + 1
                break
            end
        end
    end
    self:updataLevelRed()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_LEVEL_BUY_REFRESH, data = data})
end

function Achievement:isCanBuyFreeItems(id)
    for k, v in pairs(self._levelFreeBag) do
        if v == id then
            return true
        end
    end
    return false
end

function Achievement:getBuyInfoById(id)
    for k, v in pairs(self._levelBuyBag) do
        if v.id == id then
            return v
        end
    end
    return {}
end
--循环签到
function Achievement:_onRoleCheckin(msg)
    local data = msg.data
    if data.ret ~= 0 then
        local str = StaticData['local_text']['activity.sign.again.error']
        if ata.checkin_type == 0 then
            str = StaticData['local_text']['activity.sign.fail']
        end
        uq.fadeInfo(str)
        return
    end
    self._repairTimes = data.repair_times
    self._checkinId = data.checkin_id
    self._canSign = false
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ACHIEVEMENT_SIGN, data = data})
    self:updataSignRed()
end

function Achievement:_onRoleCheckinLoad(msg)
    local data = msg.data
    self._checkinId = data.checkin_id
    self._repairTimes = data.repair_times
    self._cycleTimes = data.cycle_id
    self._canSign = data.is_checkin
    self._signSurplusTime = data.surplus_times + uq.curServerSecond()
    self:updataSignRed()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ACHIEVEMENT_SIGN_ALL})
end

function Achievement:isCanSign()
    return self._canSign == 1
end

function Achievement:getSignIndex()
    return self._cycleTimes
end

function Achievement:getCanSignId()
    return self._checkinId
end

function Achievement:getAaginSignTimes()
    return self._repairTimes
end

function Achievement:getBageinCreateTime(time)
    if time == 0 then
        return 0
    end
    local tab = os.date("*t", time)
    if not tab or next(tab) == nil then
        return 0
    end
    if tab.hour >= 4 then
        return os.time({year = tab.year, month = tab.month, day = tab.day, hour = 4})
    end
    local tab_time = os.date("*t", time - 4 * 3600)
    if not tab_time or next(tab_time) == nil then
        return 0
    end
    return os.time({year = tab_time.year, month = tab_time.month, day = tab_time.day, hour = 4})
end

function Achievement:getSurplusTime()
    return self._signSurplusTime - uq.curServerSecond()
end

function Achievement:goToNextSign()
    network:sendPacket(Protocol.C_2_S_ROLE_CHECKIN_LOAD)
end

function Achievement:isNotBuyItem(id)
    local data = StaticData['level_gift'][id]
    if not data or next(data) == nil then
        return true
    end
    local info = self:getBuyInfoById(id)
    if next(info) == nil then
        return true
    end
    if not info.num or data.times - info.num <= 0 then
        return true
    end
    if not info.surplus or info.surplus - uq.cache.server_data:getServerTime() <= 0 then
        return true
    end
    return false
end

function Achievement:isFinishBuyItem(id)
    local data = StaticData['level_gift'][id]
    if not data or next(data) == nil then
        return false
    end
    local info = self:getBuyInfoById(id)
    if next(info) == nil then
        return false
    end
    return info.num and data.times <= info.num
end

function Achievement:getSevenSurplusTime()
    for k, v in pairs(StaticData['welfare']) do
        if v.ident == 1 then
            return self:getBageinCreateTime(uq.cache.role.create_time) + v.param * 24 * 3600 - uq.curServerSecond()
        end
    end
    return 0
end

function Achievement:isOpenRedSeven(day_id)
    for k, v in pairs(self._sevenOpenRed) do
        if v == day_id then
            return true
        end
    end
    return false
end

function Achievement:addOpenRedSeven(day_id)
    for k, v in pairs(self._sevenOpenRed) do
        if v == day_id then
            return
        end
    end
    table.insert(self._sevenOpenRed, day_id)
    self:updataSevenRed()
end

function Achievement:isSevenDiscountRed(day_id)
    if self:isOpenRedSeven(day_id) then
        return false
    end
    local info = self._taskDaySevenInfo or {}
    if not info or next(info) == nil or info.create_days < day_id then
        return false
    end
    if self:getSevenSurplusTime() <= 0 then
        return false
    end
    local id, surplus_num = self:getIdAndTimesSevenDiscount(day_id)
    if id == 0 then
        return false
    end
    for i, v in ipairs(info.store_nums) do
        if v.id == id then
            surplus_num = surplus_num -  v.num
            break
        end
    end
    return surplus_num > 0
end

function Achievement:getIdAndTimesSevenDiscount(day_id)
    local idx = day_id * 1000 + 401
    local tab_task = StaticData['seven_task'].SevenTask[day_id]
    if not tab_task or not tab_task.Discount or not tab_task.Discount[idx] or next(tab_task.Discount[idx]) == 0 then
        return 0, 0
    end
    return tab_task.Discount[idx].ident, tab_task.Discount[idx].times
end

function Achievement:isSevenRedDay(day_id)
    local days = self._taskDaySevenInfo.create_days or 0
    if day_id > days then
        return false
    end
    for i, v in ipairs(self._taskDaySevenItems) do
        if i == day_id then
            for _, iv in ipairs(v) do
                if iv.state == 1 then
                    return true
                end
            end
            break
        end
    end
    return self:isSevenDiscountRed(day_id)
end

function Achievement:isSevenRed()
    local days = self._taskDaySevenInfo.create_days or 0
    for i, v in ipairs(self._taskDaySevenItems) do
        if i <= days then
            for _, iv in ipairs(v) do
                if iv.state == 1 then
                    return true
                end
            end
        end
    end
    for i = 1, 7 do
        if self:isSevenDiscountRed(i) then
            return true
        end
    end
    return false
end

function Achievement:updataSevenRed()
    local is_red = self:isSevenRed()
    uq.cache.hint_status.status[uq.cache.hint_status.RED_TYPE.ACHIEVEMENT_SEVEN] = is_red
    self:updateRed()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ACHIEVEMENT_INSIDE_RED, data = uq.cache.hint_status.RED_TYPE.ACHIEVEMENT_SEVEN})
end

function Achievement:updataSignRed()
    local is_red = self:isCanSign()
    uq.cache.hint_status.status[uq.cache.hint_status.RED_TYPE.ACHIEVEMENT_SIGN] = is_red
    self:updateRed()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ACHIEVEMENT_INSIDE_RED, data = uq.cache.hint_status.RED_TYPE.ACHIEVEMENT_SIGN})
end

function Achievement:isRedStatusLevelById(id)
    for k, v in pairs(self._levelFreeBag) do
        if v == id then
            return true
        end
    end
    return false
end

function Achievement:updataLevelRed()
    local is_red = #self._levelFreeBag > 0
    uq.cache.hint_status.status[uq.cache.hint_status.RED_TYPE.ACHIEVEMENT_LEVEL] = is_red
    self:updateRed()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ACHIEVEMENT_INSIDE_RED, data = uq.cache.hint_status.RED_TYPE.ACHIEVEMENT_LEVEL})
end

function Achievement:updateRed()
    local red_type = {
        uq.cache.hint_status.RED_TYPE.ACHIEVEMENT_LEVEL,
        uq.cache.hint_status.RED_TYPE.ACHIEVEMENT_SIGN,
        uq.cache.hint_status.RED_TYPE.ACHIEVEMENT_SEVEN
    }
    local is_red = false
    for k, v in ipairs(red_type) do
        if is_red then
            break
        else
            is_red = uq.cache.hint_status.status[v]
        end
    end
    uq.cache.hint_status.status[uq.cache.hint_status.RED_TYPE.MAIN_CITY_ACHIEVEMENT] = is_red
    services:dispatchEvent({name = services.EVENT_NAMES.ON_MAIN_CITY_BOTTOM_SIDE_RED_CHANGES, data = uq.cache.hint_status.RED_TYPE.MAIN_CITY_ACHIEVEMENT})
end

return Achievement