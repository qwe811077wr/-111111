local Drill = class('Drill')

function Drill:ctor()
    self._finishNum = 0
    self._drill = {}
    network:addEventListener(Protocol.S_2_C_DRILL_GROUND_LOAD, handler(self, self._onGroundLoad), '_onGroundLoad')
    network:addEventListener(Protocol.S_2_C_DRILL_GROUND_ENTER, handler(self, self._onGroundEnter), '_onGroundEnter')
    network:addEventListener(Protocol.S_2_C_DRILL_GROUND_SKILL_UP, handler(self, self._onGroundUp), '_onGroundUp')
    network:addEventListener(Protocol.S_2_C_DRILL_GROUND_SKILL_RESET, handler(self, self._onGroundReset), '_onGroundReset')
    network:addEventListener(Protocol.S_2_C_DRILL_GROUND_END, handler(self, self._onGroundEnd), '_onGroundEnd')
    network:addEventListener(Protocol.S_2_C_DRILL_GROUND_BATTER, handler(self, self._onGroundBattle), '_onEventBattle')
    network:addEventListener(Protocol.S_2_C_DRILL_GROUND_REWARD, handler(self, self._onGroundReward), '_onEventReward')
    network:addEventListener(Protocol.S_2_C_DRILL_GROUND_FORMATION_SAVE, handler(self, self._onFormationSave), '_onFormationSave')
end

function Drill:_onGroundLoad(msg)
    local data = msg.data
    if not data.items or next(data.items) == nil then
        return
    end
    for i, v in ipairs(data.items) do
        self._drill[v.id] = v
    end
    self._finishNum = data.num
end

function Drill:checkGeneralIsInFormationById(id)
    if next(self._drill) == nil then
        return false
    end
    for k, v in pairs(self._drill) do
        for _, item in ipairs(v.formations) do
            if id == general_id then
                return true
            end
        end
    end
    return false
end

function Drill:_onFormationSave(msg)
    if msg.data.ret ~= 0 then
        return
    end
    local id = self:getDrillIdOperation()
    self._drill[id].formations = self._arrangedToSaveData.formations
    self._drill[id].general_count = self._arrangedToSaveData.count
    self._drill[id].formation_id = self._arrangedToSaveData.formation_id
end

function Drill:saveFormation(data)
    self._arrangedToSaveData = data
end

function Drill:checkDrillStateByDay(open_day)
    local today = uq.getWeekByTimeStamp(uq.curServerSecond())
    local tab_open = string.split(open_day, ",")
    for i, v in ipairs(tab_open) do
        if today == tonumber(v) then
            return true
        end
    end
    return false
end

function Drill:getFormationData()
    local id = self:getDrillIdOperation()
    return self._drill[id]
end

function Drill:_onGroundEnter(msg)
    local data = msg.data
    if data.ret ~= 0 then
        return
    end
    for k,v in pairs(self._drill) do
        if v.id == data.id then
            v.cur_mode = data.mode
            v.type = 1
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_DRILL_GROUND_ENTER, data = data})
end

function Drill:getAllDrillInfo()
    return self._drill
end

function Drill:_onGroundUp(msg)
    local data = msg.data
    if data.ret ~= 0 then
        return
    end
    local drill_id, skill_type = self:getSkillDrillId(data.id)
    if drill_id == 0 then
        return
    end
    local tab_drill = self._drill[drill_id] or {}
    if tab_drill and tab_drill.skillls then
        local is_fix = false
        for k, v in pairs(tab_drill.skillls) do
            if v.id == data.id then
                v.num = data.level
                is_fix = true
            end
        end
        if not is_fix then
            table.insert(tab_drill.skillls, {id = data.id, num = data.level, drill_type = skill_type})
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_DRILL_SKILL_CHANGE})
end

function Drill:_onGroundReset(msg)
    local data = msg.data
    if data.ret ~= 0 then
        return
    end
    local materials = {}
    local tab_drill = self._drill[data.id] or {}
    local info = self:getSkillTree(data.id, data.drill_type)
    if tab_drill and tab_drill.skillls then
        local index = 1
        while index <= #tab_drill.skillls do
            if tab_drill.skillls[index].drill_type == data.drill_type then
                for i = 1, tab_drill.skillls[index].num do
                    local material = info.SkillTree[tab_drill.skillls[index].id].SkillLevel[i].cost
                    if material and material ~= '' then
                        materials = uq.RewardType:mergeRewardToMap(materials, uq.RewardType.parseRewards(material))
                    end
                end
                table.remove(tab_drill.skillls, index)
                index = index - 1
            end
            index = index + 1
        end
    end

    if next(materials) ~= nil then
        local info = uq.RewardType:convertMapToTable(materials)
        uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, {rewards = info})
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_DRILL_SKILL_CHANGE})
end

function Drill:_onGroundEnd(msg)
    local data = msg.data
    if data.ret ~= 0 then
        return
    end
    self._drill[data.id].mode = data.mode
    self._drill[data.id].cur_mode = data.cur_mode
    self._drill[data.id].rewards = {}
    self._drill[data.id].type = 0
    self._finishNum = self._finishNum + 1
    services:dispatchEvent({name = services.EVENT_NAMES.ON_DRILL_SKILL_END})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_DRILL_SKILL_CHANGE})
end

function Drill:_onGroundReward(msg)
    local data = msg.data
    if data.ret ~= 0 then
        return
    end
    local drill_id = self:getDrillIdOperation()
    if drill_id == 0 then
        return
    end
    local tab_drill = self._drill[drill_id] or {}
    if tab_drill and tab_drill.rewards then
        for k, v in pairs(tab_drill.rewards) do
            if v.id == data.id then
                v.num = v.num + 1
                break
            end
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_DRILL_CARD_CHANGE})
end

function Drill:_onGroundBattle(msg)
    local data = msg.data
    if data.result <= 0 then
        return
    end
    local tab_drill = self._drill[data.drill_ground_id] or {}
    if not tab_drill or next(tab_drill) == nil then
        return
    end
    tab_drill.exp = data.exp
    tab_drill.level = data.level
    table.insert(tab_drill.rewards, {id = data.troop_id, num = 0})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_DRILL_BATTLE_END, data = data.drill_ground_id})
end

function Drill:getSkillDrillId(id)
    for _, v in pairs(StaticData['drill_skill']) do
        if v.SkillTree then
            for k, iv in pairs(v.SkillTree) do
                if iv.ident == id then
                    return v.drillGroundId, v.type
                end
            end
        end
    end
    return 0
end

function Drill:getDrillIdOperation()
    for k, v in pairs(self._drill) do
        if v.type ~= 0 then
            return v.id
        end
    end
    return 0
end

function Drill:getDrillInfoById(id)
    return self._drill[id] or {}
end

function Drill:getFinishTimes()
    return self._finishNum or 0
end

function Drill:getFinishMaxCardByid(id)
    if not self._drill[id] or next(self._drill[id]) == nil then
        return 0
    end
    return self._drill[id].mode
end

function Drill:getLoadingCardByid(id)
    if not self._drill[id] or next(self._drill[id]) == nil then
        return 0
    end
    return self._drill[id].cur_mode
end

function Drill:getAllAttAddByDrillId(id)
    local drill_info = self._drill[id]
    if not drill_info or not drill_info.skillls or next(drill_info.skillls) == nil then
        return {}
    end
    local arr_info = {}
    for k, v in pairs(drill_info.skillls) do
        local id, num = self:getSkillAddAtt(v.id, v.num)
        if id ~= 0 then
            if not arr_info[id] then
                arr_info[id] = num
            else
                arr_info[id] = arr_info[id] + num
            end
        end
    end
    return arr_info
end

function Drill:getSkillAddAtt(id, lv)
    local info = StaticData['drill_skill']
    for _, v in pairs(info) do
        if v.SkillTree then
            for _, iv in pairs(v.SkillTree) do
                if iv.ident == id and iv.SkillLevel[lv + 1] and iv.SkillLevel[lv + 1].effectValue and iv.SkillLevel[lv + 1].effectValue ~= "" then
                    local tab_split = string.split(iv.SkillLevel[lv + 1].effectValue, ",")
                    return tonumber(tab_split[1]), tonumber(tab_split[2])
                end
            end
        end
    end
    return 0, 0
end

function Drill:getSkillTree(index, drill_type)
    local info = StaticData['drill_skill']
    for k, v in ipairs(info) do
        if v.drillGroundId == index and v.type == drill_type then
            return v
        end
    end
    return {}
end

function Drill:checkDrillCouldLvl(info, lvl, drill_index)
    lvl = lvl or self:getDrillInfoById(drill_index).level
    local is_skill_open = true
    if info.preSkillLimit and info.preSkillLimit ~= '' then
        is_skill_open = false
        local arr_info = string.split(info.preSkillLimit, ';')
        for k, v in ipairs(arr_info) do
            local tab_str = string.split(v, ",")
            if tab_str[1] then
                local att_lv = self:getSkillInfoById(tonumber(tab_str[1]), drill_index)
                if att_lv >= tonumber(tab_str[2]) then
                    is_skill_open = true
                    break
                end
            end
        end
    end

    local is_ground_open = true
    if info.groundLimit then
        is_ground_open =  lvl >= info.groundLimit
    end

    local cost_state = true
    local array_cost = uq.RewardType.parseRewards(info.cost)
    for k, v in ipairs(array_cost) do
        local data = v:toEquipWidget()
        if not uq.cache.role:checkRes(data.type, data.num, data.id) then
            cost_state = false
            break
        end
    end

    return is_skill_open and is_ground_open and cost_state
end

function Drill:checkDrillTypeCouldLvl(drill_index, drill_type)
    local info = self:getSkillTree(drill_index, drill_type).SkillTree
    if not info or next(info) == nil then
        return false
    end
    for k, v in pairs(info) do
        local level = self:getSkillInfoById(v.ident, drill_index)
        if level < 5 and self:checkDrillCouldLvl(v.SkillLevel[level + 1], nil, drill_index) then
            return true
        end
    end
    return false
end

function Drill:checkDrillSoldierCouldLvl(drill_index)
    for i = 1, 3 do
        if self:checkDrillTypeCouldLvl(drill_index, i) then
            return true
        end
    end
    return false
end

function Drill:getDrillXmlById(drill_index)
    return StaticData['drill_ground'].DrillGround[drill_index]
end

function Drill:getSkillTypePrecent(drill_id, drill_type)
    local skill_info = self:getSkillTree(drill_id, drill_type)
    local info = skill_info.SkillTree
    local cur_info = self:getDrillInfoById(drill_id)
    local total_num = 0
    local cur_num = 0
    if not info or next(info) == nil then
        return cur_num, total_num
    end
    for k, v in pairs(info) do
        total_num = total_num + #v.SkillLevel - 1
    end
    if next(cur_info.skillls) == nil then
        return cur_num, total_num
    end
    for k, v in pairs(cur_info.skillls) do
        if v.drill_type == drill_type then
            cur_num = cur_num + v.num
        end
    end
    return cur_num, total_num
end

function Drill:getSkillInfoById(id, drill_id)
    local skill_info = self:getDrillInfoById(drill_id)
    if next(skill_info.skillls) == nil then
        return 0
    end
    for k, v in pairs(skill_info.skillls) do
        if v.id == id then
            return v.num
        end
    end
    return 0
end

return Drill