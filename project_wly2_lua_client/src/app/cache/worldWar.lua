local WorldWar = class("WorldWar")

function WorldWar:ctor()
    self.world_city_info = {}
    self.map_moving_list = {}
    self.world_enter_info = {}
    self.move_city_id = 0
    self.cur_army_info = {}
    self.battle_city_info = nil  --记录当前进入城池的城池信息
    self.field_city_info = nil  --记录当前内部城池各个寨的信息
    self.point_armys_array = {} --记录战场内部部队信息
    self.delete_armys_array = {} --记录暂时移除的战场内部部队信息
    self.battle_field_info = {} --记录战场信息hp drop_id
    self.field_moving_list = {} --记录战场内部移动列表
    self._isLeaderMoving = false
    self.battle_rank_info = {}
    self.battle_title_info = {}
    self.battle_report_info = {}
    self.battle_task_info = {}
    self.not_read_nums = 0
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_CREATE_POWER, handler(self, self._onBattleCreatePower))
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_WORLD_INFO, handler(self, self._onBattleWorldInfo))
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_ENTER, handler(self, self._onBattleWorldEnter))
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_MOVING_LIST, handler(self, self._onBattleWorldMovingList))
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_DO_MOVE, handler(self, self._onBattleWorldDoMove))
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_MOVE_END, handler(self, self._onBattleWorldMoveEnd))
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_LOAD_ARMY, handler(self, self._onBattleWorldLoadArmy))
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_UPDATE_FORMATION, handler(self, self._onBattleWorldUpdateFormation))
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_START_BATTLE, handler(self, self._onBattleStartBattle))

    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_FIELD_INFO, handler(self, self._onBattleFieldInfo))
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_FIELD_POINT_ARMYS, handler(self, self._onBattleFieldPointArmys))
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_FIELD_MOVING_LIST, handler(self, self._onBattleFieldMovingList))
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_FIELD_MOVE, handler(self, self._onBattleFieldMove))
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_FIELD_NOTIFY, handler(self, self._onBattleFieldNotify))
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_FIELD_WALL_HP, handler(self, self._onBattleFieldWallHp))
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_FIELD_OCCUPY_NOTIFY, handler(self, self._onBattleFieldOccupyNotify))
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_DECLARE_BATTLE, handler(self, self._onBattleDeclareBattle))
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_END_BATTLE, handler(self, self._onBattleEndBattle))
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_FIELD_MOVE_END, handler(self, self._onFieldBattleMoveEnd))
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_RANK_NOTIFY, handler(self, self._onBattleRankNotify))
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_LOAD_TITLE, handler(self, self._onBattleLoadTitle))
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_REPORT_NOTIFY, handler(self, self._onBattleReportNotify))
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_REPORT_LOAD, handler(self, self._onBattleReportLoad))
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_DEVELOP, handler(self, self._onBattleDevelop))
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_LOAD_FIRSTRANK, handler(self, self._onBattleLoadFirstRank))
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_CITY_CHANGE_NOTIFY, handler(self, self._onBattleCityChangeNotify))
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_TASK_UPDATE, handler(self, self._onBattleTaskUpdate))
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_DRAW_TASK, handler(self, self._onBattleDrawTask))
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_FIELD_POINT_NPC_UPDATE, handler(self, self._onbattleFiledNpcUpdate))
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_FIELD_POINT_HP_UPDATE, handler(self, self._onbattleFiledHpUpdate))
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_ARMY_ENTER_FIELD, handler(self, self._onbattleFiledEnter))
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_ARMY_UPDATE, handler(self, self._onbattleArmyUpdate))
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_MOVE_CITY, handler(self, self._onBattleMoveCity))
end

function WorldWar:_onBattleMoveCity(msg)
    uq.fadeInfo(StaticData["local_text"]["world.city.move.des1"])
    self.world_enter_info.city_id = msg.data.city_id
    self.world_enter_info.move_times = self.world_enter_info.move_times + 1
    services:dispatchEvent({name = services.EVENT_NAMES.ON_WORLD_CITY_CLOSE})
end

function WorldWar:_onBattleTaskUpdate(msg)
    self.battle_task_info = msg.data
    services:dispatchEvent({name = services.EVENT_NAMES.ON_BATTLE_TASK_UPDATE})
end

function WorldWar:_onBattleDrawTask(msg)
    table.insert(self.world_enter_info.task_id, msg.data.task_id)
    services:dispatchEvent({name = services.EVENT_NAMES.ON_BATTLE_DRAW_TASK, id = msg.data.task_id})
end

function WorldWar:_onBattleCityChangeNotify(msg)
    self.world_enter_info.city_id = msg.data.city_id
    uq.fadeInfo(StaticData["local_text"]["world.city.change.des"])
end

function WorldWar:checkGeneralIsInFormationById(id)
    if next(self.cur_army_info) == nil then
        return false
    end

    for k, v in pairs(self.cur_army_info) do
        for _, item in ipairs(v.generals) do
            if id == item.general_id then
                return true
            end
        end
    end
    return false
end

function WorldWar:_onBattleDevelop(msg)
    local info = msg.data
    local city_info = self:getCityData(info.city_id)
    city_info.develop[info.choice].level = info.level
    city_info.develop[info.choice].exp = info.exp
    self.world_enter_info.develop_count = self.world_enter_info.develop_count + 1
    services:dispatchEvent({name = services.EVENT_NAMES.ON_BATTLE_DEVELOP, data = msg.data})
end

function WorldWar:_onBattleLoadFirstRank(msg)
    self.first_rank = msg.data
    services:dispatchEvent({name = services.EVENT_NAMES.ON_BATTLE_LOAD_FIRST_RANK})
end

function WorldWar:_onBattleReportNotify(msg)
    for k, v in ipairs(msg.data.reports) do
        table.insert(self.battle_report_info, v)
    end
    self.not_read_nums = self.not_read_nums + #msg.data.reports
    services:dispatchEvent({name = services.EVENT_NAMES.ON_BATTLE_REPORT_NOTIFY})
end

function WorldWar:_onBattleReportLoad(msg)
    self.not_read_nums = 0
    self.battle_report_info = msg.data.reports
    services:dispatchEvent({name = services.EVENT_NAMES.ON_BATTLE_REPORT_LOAD})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_BATTLE_REPORT_NOTIFY})
end

function WorldWar:getRoadPath(role_id, crops_id)
    if role_id == uq.cache.role.id  then
        return "img/world/s03_000661.png"
    end
    if crops_id == uq.cache.role.cropsId then
        return "img/world/s03_000663.png"
    elseif uq.cache.crop:isFriendly() then
        return "img/world/s03_000667.png"
    else
        return "img/world/s03_000665.png"
    end
end

function WorldWar:_onBattleLoadTitle(msg)
    self.battle_title_info = {}
    for k, v in pairs(msg.data.title) do
        self.battle_title_info[v.title_id] = v
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_BATTLE_TITLE_NOTIFY})
end

function WorldWar:_onBattleRankNotify(msg)
    self.battle_rank_info = msg.data
    services:dispatchEvent({name = services.EVENT_NAMES.ON_BATTLE_RANK_NOTIFY})
end

function WorldWar:_onBattleStartBattle(msg)
    uq.log("_onBattleStart  ", msg.data)
    local city_info = self:getCityData(msg.data.city_id)
    if not city_info or next(city_info) == nil then
        return
    end
    city_info.battle_time = 1 --标志可以打城战了
    city_info.cur_time = os.time()
    if city_info.declare_crop_id == uq.cache.role.cropsId or city_info.crop_id == uq.cache.role.cropsId then
        uq.ModuleManager:getInstance():show(uq.ModuleManager.WORLD_WAR_OPEN, {data = msg.data})
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_WORLD_BATTLE_INFO})
end

function WorldWar:_onBattleWorldDoMove(evt)
    uq.log('_onBattleWorldDoMove-----', evt.data)
    local info = evt.data
    if info.ret == 1 then
        return
    end
    if info.is_declare ~= 2 then
        self.world_enter_info.night_battle = self.world_enter_info.night_battle + 1
    end
    network:sendPacket(Protocol.C_2_S_NATION_BATTLE_MOVING_LIST)
end

function WorldWar:_onBattleWorldMoveEnd(evt)
    uq.log('_onBattleWorldMoveEnd-----', evt.data)
    local is_self = false
    for k, v in ipairs(evt.data.armys) do
        if next(self.map_moving_list[v.role_id]) then
            self.map_moving_list[v.role_id][v.army_id] = nil
        end
        if v.role_id == uq.cache.role.id then
            is_self =  true
            self.cur_army_info[v.army_id].cur_city = v.city_id
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_WORLD_BATTLE_MOVE_END, data = evt.data.armys})
    if is_self then
        uq.cache.world_war.world_enter_info.night_battle = uq.cache.world_war.world_enter_info.night_battle + 1
        services:dispatchEvent({name = services.EVENT_NAMES.ON_CHANGE_MINI_MAP_POS})
        services:dispatchEvent({name = services.EVENT_NAMES.ON_WORLD_MOVING_STATE_CHANGE})
    end
end

function WorldWar:_onBattleWorldLoadArmy(evt)
    uq.log('_onBattleWorldLoadArmy-----', evt.data)
    self.cur_army_info = evt.data.armies
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CHANGE_MINI_MAP_POS})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_WORLD_BATTLE_LOAD_ARMY})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_WORLD_MOVING_STATE_CHANGE})
end

function WorldWar:_onBattleWorldUpdateFormation(evt)
    network:sendPacket(Protocol.C_2_S_NATION_BATTLE_LOAD_ARMY)
end

function WorldWar:_onBattleWorldMovingList(evt)
    uq.log('_onBattleWorldMovingList-----', evt.data)
    for k, v in ipairs(evt.data.armies) do
        if v.role_id == uq.cache.crop:getMyCropLeaderId() then
            self._isLeaderMoving = true
        end
        if self.map_moving_list[v.role_id] == nil then
            self.map_moving_list[v.role_id] = {}
        end
        if self.map_moving_list[v.role_id][v.army_id] == nil then
            self.map_moving_list[v.role_id][v.army_id] = {}
        end
        self.map_moving_list[v.role_id][v.army_id] = v
    end
    if evt.data.is_last == 1 then
        if self._isLeaderMoving then
            local mov_list = self.map_moving_list[uq.cache.crop:getMyCropLeaderId()]
            for k, v in pairs(mov_list) do
                if v.move_goal == 1 then
                    services:dispatchEvent({name = services.EVENT_NAMES.ON_CHANGE_WORLD_CITY_STATE})
                    break
                end
            end
        end
        self._isLeaderMoving = false
        services:dispatchEvent({name = services.EVENT_NAMES.ON_WORLD_BATTLE_MOVING_LIST})
    end
end

function WorldWar:_onBattleWorldEnter(evt)
    self.world_enter_info = evt.data
    services:dispatchEvent({name = services.EVENT_NAMES.ON_WORLD_BATTLE_ENTER})
end

function WorldWar:checkTaskReward(task_id)
    for k, v in ipairs(self.world_enter_info.task_id) do
        if v == task_id then
            return true
        end
    end
    return false
end

function WorldWar:_onBattleWorldInfo(evt)
    -- uq.log("_onBattleWorldInfo  ", evt.data)
    for k, v in pairs(evt.data.cities) do
        self.world_city_info[v.city_id] = v
        v.cur_time = 0
        if v.battle_time > 0 or v.declare_time > 0 or v.declare_crop_id > 0 then --战斗时间
            v.cur_time = os.time()
        end
    end
    if evt.data.is_last == 1 then
        services:dispatchEvent({name = services.EVENT_NAMES.ON_WORLD_BATTLE_INFO})
    end
end

function WorldWar:_onBattleCreatePower(evt)
    uq.log('_onBattleCreatePower-----', evt.data)
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CREATE_POWER_FAIL, data = evt.data})
end

function WorldWar:getCityRoadInfo(city_id)
    local info = StaticData['world_road'][city_id]
    return info and info.Road
end

function WorldWar:getCityData(city_id)
    return self.world_city_info[city_id]
end

function WorldWar:getCityBattlePath(path_ids, army_id, dec_city)
    local army_info = self.cur_army_info[army_id]
    local cur_city = army_info.cur_city == 0 and self.world_enter_info.city_id or army_info.cur_city
    return self:getSearchPath(path_ids, cur_city, dec_city, uq.cache.role.cropsId)
end

function WorldWar:getSearchPath(path_ids, from, to, crop_id)
    if from == to then
        table.insert(path_ids, from)
        return true
    end
    local visit_map = {}
    local distances = {}
    distances[from] = {from, 0}
    local stop = false
    while not stop do
        local min_distance = 0
        local city_id = 0
        for k, v in pairs(distances) do
            if not visit_map[k] then
                if min_distance == 0 or v[2] < min_distance then
                    min_distance = v[2]
                    city_id = k
                end
            end
        end
        if city_id <= 0 then
            break
        end
        local city = self:getCityData(city_id)
        if not city then
            break
        end
        local city_rolds = self:getCityRoadInfo(city_id)
        if city_rolds == nil then
            break
        end
        for k, v in pairs(city_rolds) do
            local next_city = self:getCityData(tonumber(v.ident))
            if next_city then
                local distances_info = distances[tonumber(v.ident)]
                local dis = min_distance + v.distance
                if not distances_info then
                    distances[tonumber(v.ident)] = {city_id, dis}
                elseif distances_info[2] > dis then
                    distances_info[1] = city_id
                    distances_info[2] = dis
                end
                if tonumber(v.ident) == to then
                    stop = true
                    break
                end
                if next_city.crop_id ~= crop_id then
                    distances[tonumber(v.ident)] = nil
                end
            end
        end
        visit_map[city_id] = true
    end
    if not distances[to] then
        return false
    end
    local start_id = to
    while start_id > 0 do
        local distances_info = distances[start_id]
        if not distances_info then
            break
        end
        table.insert(path_ids, 1 , start_id)
        start_id = distances_info[1]
        if start_id == from then
            table.insert(path_ids, 1 , start_id)
            break
        end
    end
    return true
end

function WorldWar:_onbattleFiledNpcUpdate(msg)
    local point_array = {}
    for k, v in ipairs(msg.data.point) do
        local info = self:getBattleFieldInfoByPointId(v.point_id)
        if info == nil then
            return
        end
        table.insert(point_array, v.point_id)
        info.def_time = v.def_time
        self.point_armys_array[v.point_id] = {}
        for k, army in ipairs(v.armys) do
            table.insert(self.point_armys_array[army.point_id], army)
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_WORLD_BATTLE_FIELD_POINT_ARMYS, data = point_array})
end

function WorldWar:_onbattleFiledHpUpdate(msg)
    local point_array = {}
    for k, v in ipairs(msg.data.point) do
        local info = self:getBattleFieldInfoByPointId(v.point_id)
        if info == nil then
            return
        end
        table.insert(point_array, v.point_id)
        info.wall_time = v.wall_time
        info.hp = v.wall_hp
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_WORLD_BATTLE_FIELD_POINT_ARMYS, data = point_array})
end

function WorldWar:_onBattleFieldInfo(msg)
    uq.log("_onBattleFieldInfo  ", msg.data)
    self.battle_field_info = msg.data
    services:dispatchEvent({name = services.EVENT_NAMES.ON_WORLD_BATTLE_FIELD_INFO})
end

function WorldWar:_onbattleFiledEnter(msg)
    self.battle_field_info.attack_num = msg.data.attack_num
    self.battle_field_info.defend_num = msg.data.defend_num
    local point_array = {}
    for k, v in ipairs(msg.data.army) do
        table.insert(point_array, v.point_id)
        if self.point_armys_array[v.point_id] == nil then
            self.point_armys_array[v.point_id] = {}
        end
        table.insert(self.point_armys_array[v.point_id], v)
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_WORLD_BATTLE_FIELD_POINT_ARMYS, data = point_array})
end

function WorldWar:_onbattleArmyUpdate(msg)
    uq.log("_onbattleArmyUpdate ", msg.data)
    for k, v in ipairs(msg.data.citys) do
        self.world_city_info[v.city_id].def_num = v.defend_num
        self.world_city_info[v.city_id].atk_num = v.attack_num
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_BATTLE_ARYM_UPDATE, data = msg.data})
end

function WorldWar:getBirthCity(army_id)
    for k2, info in pairs(self.point_armys_array) do
        for k3, army_info in ipairs(info) do
            if army_info.id == uq.cache.role.id and army_id == army_info.army_id then
                return army_info.point_id
            end
        end
    end
    local info = self:getFieldMovingListInfo(uq.cache.role.id, army_id)
    if info then
        local field_info = uq.cache.world_war:getBattleFieldInfoByPointId(info.from_point_id)
        if field_info and field_info.crop_id == uq.cache.role.cropsId then
            return info.from_point_id
        else
            return info.to_point_id
        end
    end
    return 0
end

function WorldWar:_onBattleFieldPointArmys(msg)
    for k, v in ipairs(msg.data.armys) do
        if self.point_armys_array[v.point_id] == nil then
            self.point_armys_array[v.point_id] = {}
        end
        table.insert(self.point_armys_array[v.point_id], v)
    end
    if msg.data.is_last == 1 then --结束
        services:dispatchEvent({name = services.EVENT_NAMES.ON_WORLD_BATTLE_FIELD_POINT_ARMYS})
        services:dispatchEvent({name = services.EVENT_NAMES.ON_WORLD_MOVING_STATE_CHANGE})
    end
end

function WorldWar:getFieldMovingCd(id, army_id)
    --获取该队列的move_cd
    local info = self:getFieldMovingListInfo(id, army_id)
    if info then
        return info.move_cd
    end
    return 0
end

function WorldWar:checkFieldMovingInfo(id, army_id)
    --检测该队列是否在城池移动列表内
    local info = self:getFieldMovingListInfo(id, army_id)
    return info ~= nil
end

function WorldWar:checkFieldCityIsMoveTo(role_id, point_id)
    --得到玩家将要移动到的城池id
    local army_info1 = self:getFieldMovingListInfo(role_id, 1)
    local army_info2 = self:getFieldMovingListInfo(role_id, 2)
    if army_info1 ~= nil and army_info1.to_point_id == point_id then
        return true
    end
    if army_info2 ~= nil and army_info2.to_point_id == point_id then
        return true
    end
    return false
end

function WorldWar:checkMapCityIsDeclareByCityId(city_id)
    --检测该城池是否是将要宣战的城池
    for k, info in pairs(self.map_moving_list) do
        for k, v in pairs(info) do
            if city_id == v.to_city and v.move_goal == 1 then
                return true
            end
        end
    end
    return false
end

function WorldWar:checkMapCityIsDeclare(role_id, city_id)
    --检测该城池是否是玩家将要宣战的城池
    if self.map_moving_list[role_id] == nil then
        return false
    end
    local info = self.map_moving_list[role_id]
    for k, v in pairs(info) do
        if city_id == v.to_city and v.move_goal == 1 then
            return true
        end
    end
    return false
end

function WorldWar:getCityMovingCd(id, army_id)
    --获取该队列的move_cd
    if self.map_moving_list[id] ~= nil and self.map_moving_list[id][army_id] ~= nil then
        return self.map_moving_list[id][army_id].move_cd
    end
    return 0
end

function WorldWar:checkCityMovingInfo(id, army_id)
    --检测该队列是否在大地图移动列表内
    local is_move = false
    if self.map_moving_list[id] ~= nil and self.map_moving_list[id][army_id] ~= nil then
        is_move = true
    end
    return is_move
end

function WorldWar:getFieldMovingListInfo(id, army_id)
    for k, v in ipairs(self.field_moving_list) do
        if v.id == id and v.army_id == army_id then
            return self.field_moving_list[k]
        end
    end
    return nil
end

function WorldWar:_removeFieldMovingListInfo(id, army_id)
    for k, v in ipairs(self.field_moving_list) do
        if v.id == id and v.army_id == army_id then
            table.remove(self.field_moving_list, k)
        end
    end
end

function WorldWar:_addFieldMovingListArmy(info)
    local is_find = self:getFieldMovingListInfo(info.id, info.army_id)
    if is_find == nil then
        table.insert(self.field_moving_list, info)
    end
end

function WorldWar:_onBattleFieldMovingList(msg)
    uq.log("_onFieldMovingList  ", msg.data)
    for k, v in ipairs(msg.data.armys) do
        self:_addFieldMovingListArmy(v)
        self:removePointArmy(v.id, v.army_id, v.from_point_id)
    end
    if msg.data.is_last == 1 then --结束
        if self:getFieldMovingListInfo(uq.cache.role.id, 1) ~= nil or self:getFieldMovingListInfo(uq.cache.role.id, 2) ~= nil then
            services:dispatchEvent({name = services.EVENT_NAMES.ON_WORLD_MOVING_STATE_CHANGE})
        end
        services:dispatchEvent({name = services.EVENT_NAMES.ON_WORLD_BATTLE_FIELD_MOVING_LIST})
    end
end

function WorldWar:getPointArmysNumById(point_id, army_type)
    army_type = army_type == nil and 1 or army_type
    if self.point_armys_array[point_id] == nil or next(self.point_armys_array[point_id]) == nil then
        return 0
    end
    local info = self.point_armys_array[point_id]
    local npc_num = 0
    for k, v in pairs(info) do
        if v.type == army_type then
            npc_num = npc_num + 1
        end
    end
    return npc_num
end

function WorldWar:removePointArmy(id, army_id, point_id)
    if self.point_armys_array[point_id] == nil or next(self.point_armys_array[point_id]) == nil then
        return
    end
    for k, v in ipairs(self.point_armys_array[point_id]) do
        if v.id == id and v.army_id == army_id then
            table.insert(self.delete_armys_array, v)
            table.remove(self.point_armys_array[point_id], k)
            break
        end
    end
end

function WorldWar:checkArmyIsDeclare(army_id, declare_city_id)
    if self.map_moving_list[uq.cache.role.id] ~= nil and self.map_moving_list[uq.cache.role.id][army_id] ~= nil then
        local info = self.map_moving_list[uq.cache.role.id][army_id]
        return info.to_city == declare_city_id
    end
    return false
end

function WorldWar:checkArmyIsInBattleCity(army_id) --判断部队是否在的城池已经开始战斗
    local info = self.cur_army_info[army_id]
    if not info then
        return false
    end
    local city_info = self:getCityData(info.cur_city)
    if city_info and city_info.battle_time > 0 then
        return true
    end
    return false
end

function WorldWar:checkArmyIsInDeclareCity(army_id) --判断部队是否在的城池已经开始宣战
    local info = self.cur_army_info[army_id]
    if not info then
        return false
    end
    local city_info = self:getCityData(info.cur_city)
    if city_info and city_info.cur_time > 0 and city_info.declare_crop_id > 0 then
        return true
    end
    return false
end

function WorldWar:_onBattleFieldMove(msg)
    uq.log("_onFieldMove  ", msg.data)
end

function WorldWar:_onBattleFieldNotify(msg)
    uq.log("_onFieldNotify  ", msg.data)
    local is_time = false
    local point_array = {}
    if msg.data.def_time > 0 then
        local info = self:getBattleFieldInfoByPointId(msg.data.point_id)
        if info ~= nil then
            info.def_time = msg.data.def_time
            is_time = true
            table.insert(point_array, msg.data.point_id)
        end
    end
    if msg.data.wall_time > 0 then
        local info = self:getBattleFieldInfoByPointId(msg.data.point_id)
        if info ~= nil then
            info.wall_time = msg.data.wall_time
            is_time = true
            table.insert(point_array, msg.data.point_id)
        end
    end
    if #point_array > 1 then
        table.remove(point_array, 1)
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_WORLD_BATTLE_FIELD_POINT_ARMYS, data = point_array})
    for k, v in ipairs(msg.data.reports) do
        if v.result > 0 then
            self:removePointArmy(v.def[1].id, v.def[1].army_id, msg.data.point_id)
            uq.fadeInfo(string.format(StaticData["local_text"]["world.war.battle.btn10"], v.atk[1].name, v.def[1].name))
        else
            uq.fadeInfo(string.format(StaticData["local_text"]["world.war.battle.btn11"], v.atk[1].name, v.def[1].name))
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_WORLD_BATTLE_FIELD_NOTIFY, data = msg.data})
end

function WorldWar:_onFieldBattleMoveEnd(msg)
    uq.log("_onFieldBattleMoveEnd  ", msg.data)
    local is_self = false
    for k, v in ipairs(msg.data.armys) do
        if v.id == uq.cache.role.id then
            is_self = true
        end
        local info = self:getFieldMovingListInfo(v.id , v.army_id)
        if info ~= nil then
            local point_info = self:getBattleFieldInfoByPointId(info.to_point_id)
            if point_info and point_info.crop_id == uq.cache.role.cropsId then
                for k, v in ipairs(self.delete_armys_array) do
                    if info.role_id == v.id and to_city == v.point_id then
                        table.insert(self.point_armys_array[v.point_id], v)
                        table.remove(self.delete_armys_array, k)
                    end
                end
            end
            self:_removeFieldMovingListInfo(v.id, v.army_id)
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_WORLD_BATTLE_FIELD_MOVE_END, data = msg.data.armys})
    if is_self then
        services:dispatchEvent({name = services.EVENT_NAMES.ON_WORLD_MOVING_STATE_CHANGE})
    end
end

function WorldWar:_onBattleFieldWallHp(msg)
    uq.log("_onFieldWallHp  ", msg.data)
    if msg.data.result == -1 then
        uq.fadeInfo(msg.data.atk_name .. StaticData["local_text"]["world.war.battle.btn13"])
    else
        local info = self:getBattleFieldInfoByPointId(msg.data.point_id)
        if info and info.hp == 0 then
            info = self:getBattleFieldInnerCityInfo(uq.cache.world_war.battle_city_info.city_id)
        end

        if info then
            msg.data.point_id = info.id
            info.hp = info.hp - 1
            info.hp = info.hp < 0 and 0 or info.hp
        end
        uq.fadeInfo(msg.data.atk_name .. StaticData["local_text"]["world.war.battle.btn12"])
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_WORLD_BATTLE_FIELD_WALL_UP, data = msg.data})
end

function WorldWar:getBattleFieldInnerCityInfo(city_id)
    local temp = StaticData['world_city'][city_id]
    if temp == nil then
        return nil
    end
    local war_array = StaticData['world_war_city'][temp.type].war
    for k, v in pairs(war_array) do
        if v.type == 4 then
            return self:getBattleFieldInfoByPointId(v.ident)
        end
    end
    return nil
end

function WorldWar:getBattleFieldInfoByPointId(point_id)
    for k, v in ipairs(self.battle_field_info.points) do
        if v.id == point_id then
            return self.battle_field_info.points[k]
        end
    end
    return nil
end

function WorldWar:_onBattleFieldOccupyNotify(msg)
    uq.log("_onFieldOccupyNotify  ", msg.data)
    local info = msg.data
    for k, v in ipairs(self.battle_field_info.points) do
        if v.id == info.point_id then
            v.crop_id = info.crop_id
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_WORLD_BATTLE_FIELD_INFO})
end

function WorldWar:_onBattleDeclareBattle(msg)
    uq.log("_onDeclareBattle  ", msg.data)
end

function WorldWar:_onBattleEndBattle(msg)
    uq.log("_onBattleEnd  ", msg.data)
    local info = msg.data
    if info.is_win == 0 then
        uq.ModuleManager:getInstance():show(uq.ModuleManager.WORLD_BATTLE_LOST)
    else
        uq.ModuleManager:getInstance():show(uq.ModuleManager.WORLD_BATTLE_WIN, {data = info})
    end
end

function WorldWar:clearBattleFieldData()
    self.point_armys_array = {}
    self.battle_field_info = {}
    self.field_moving_list = {}
end

return WorldWar