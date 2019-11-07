local InstanceWar = class("InstanceWar")

InstanceWar.SCORE = {
    E_D = 1,
    E_C = 2,
    E_B = 3,
    E_A = 4,
    E_S = 5,
}

function InstanceWar:ctor()
    self:init()

    network:addEventListener(Protocol.S_2_C_CAMPAIGN_INFO_LOAD, handler(self, self.onInstanceInfoLoad))
    network:addEventListener(Protocol.S_2_C_CAMPAIGN_CHALLENGE, handler(self, self.onInstanceSelect))
    network:addEventListener(Protocol.S_2_C_CAMPAIGN_CITY_LOAD, handler(self, self.onCityLoad))
    network:addEventListener(Protocol.S_2_C_CAMPAIGN_EXPLORE, handler(self, self.onCityExplore))
    network:addEventListener(Protocol.S_2_C_CAMPAIGN_ROUND_END, handler(self, self.overRoundRet))
    network:addEventListener(Protocol.S_2_C_CAMPAIGN_MOVE, handler(self, self.moveRet))
    network:addEventListener(Protocol.S_2_C_CAMPAIGN_RESOURCE_LOAD, handler(self, self.resourceLoad))
    network:addEventListener(Protocol.S_2_C_CAMPAIGN_GENERAL_LOAD, handler(self, self.generalLoad))
    network:addEventListener(Protocol.S_2_C_CAMPAIGN_CITY_UPDATE, handler(self, self.cityUpdate))
    network:addEventListener(Protocol.S_2_C_CAMPAIGN_MOVE_NOTIFY, handler(self, self.moveNotify))
    network:addEventListener(Protocol.S_2_C_CAMPAIGN_EXPLORE_NOTIFY, handler(self, self.exploreNotify))
    network:addEventListener(Protocol.S_2_C_CAMPAIGN_ACTION_LOAD, handler(self, self.actionLoad))
    network:addEventListener(Protocol.S_2_C_CAMPAIGN_BATTLE_RESULT_LOAD, handler(self, self.battleResultLoad))
    network:addEventListener(Protocol.S_2_C_CAMPAIGN_DEFEND_BATTLE, handler(self, self.defendRet))
    network:addEventListener(Protocol.S_2_C_CAMPAIGN_ADD_GENERAL, handler(self, self.addGeneral))
    network:addEventListener(Protocol.S_2_C_CAMPAIGN_BATTLE, handler(self, self.battleRet))
    network:addEventListener(Protocol.S_2_C_CAMPAIGN_RETREAT_NOTIFY, handler(self, self.retreatRet))
    network:addEventListener(Protocol.S_2_C_CAMPAIGN_END, handler(self, self.onCampainEnd))
    network:addEventListener(Protocol.S_2_C_CAMPAIGN_PLAYER_BATTLE_NOTIFY, handler(self, self.battleNotify))
    network:addEventListener(Protocol.S_2_C_CAMPAIGN_SPY, handler(self, self.cityInvestigate))
    network:addEventListener(Protocol.S_2_C_CAMPAIGN_RECRUIT_CAPTURE, handler(self, self.recruitCapture))
    network:addEventListener(Protocol.S_2_C_CAMPAIGN_GENERAL_LEVEL_UP, handler(self, self.generalLevelUp))
    network:addEventListener(Protocol.S_2_C_CAMPAIGN_SOLDIER_SUPPLY, handler(self, self.soldierSupply))
    network:addEventListener(Protocol.S_2_C_CAMPAIGN_WIPE, handler(self, self.wipeRet))
    network:addEventListener(Protocol.S_2_C_CAMPAIGN_UPDATE_CTIY_SOLDIER, handler(self, self.updateCityInfo))
end

function InstanceWar:init()
    self._curInstanceId = 0 --战役中的id
    self._instanceData = {}
    self._cityInfo = {}
    self._roundExploreCity = {}
    self._warRes = {}
    self._warGeneral = {}
    self._curRound = 1
    self._generalCityMap = {}
    self._formationInfo = {}
    self._roundBattleAcion = {}
end

function InstanceWar:endChapter()
    self._curInstanceId = 0 --战役中的id
    self._cityInfo = {}
    self._roundExploreCity = {}
    self._roundBattleAcion = {}
    self._warRes = {}
    self._warGeneral = {}
    self._curRound = 1
    self._formationInfo = {}
end

function InstanceWar:getUpGeneralsByType(selected_type)
    local list = {}
    selected_type = selected_type or 0
    for i, v in pairs(self._warGeneral) do
        v.is_formation = 0
    end
    if selected_type == 0 then
        for k, item in pairs(self._warGeneral) do
            item.unlock = true
            table.insert(list, item)
        end
        uq.cache.generals:sortGenerals(list)
        return list
    end

    for k, item in pairs(self._warGeneral) do
        local skill_type = StaticData['skill'][item.skill_id].skillType
        if uq.cache.generals:isBelongNeedType(item.temp_id, selected_type, skill_type) then
            item.unlock = true
            table.insert(list, item)
        end
    end
    uq.cache.generals:sortGenerals(list)
    return list
end

function InstanceWar:getDownGeneralsByType(occupation_type)
    local general_info = {}
    for k, item in pairs(self._cityInfo) do
        if item.power == 1 then
            for j, capture_data in ipairs(item.capture_general) do
                local general_xml = uq.cache.generals:getGeneralDataXML(capture_data.general_id)
                local data = {
                    lvl = 1,
                    id = math.floor(capture_data.general_id / 10),
                    temp_id = capture_data.general_id,
                    rtemp_id = capture_data.general_id,
                    compose = 0,
                    unlock = false,
                    quality_type = general_xml.qualityType,
                    grade = general_xml.grade,
                    compose_nums = general_xml.composeNums,
                    from_power = capture_data.power,
                    city_id = item.city_id
                }
                table.insert(general_info, data)
            end
        end
    end

    if occupation_type == 5 then
        return {}
    end
    local occupation_type = occupation_type or 0

    if occupation_type == 0 then
        uq.cache.generals:sortGenerals(general_info)
        return general_info
    end
    local list = {}
    for k, item in pairs(general_info) do
        if uq.cache.generals:isBelongNeedType(item.temp_id, occupation_type) then
            table.insert(list, item)
        end
    end
    uq.cache.generals:sortGenerals(list)
    return list
end

function InstanceWar:isGeneralUp(general_id)
    return self._warGeneral[general_id] ~= nil
end

function InstanceWar:isQulityRedById(id)
    local general_info = self:getGeneralData(id)
    if not general_info then
        return false
    end
    local lvl = general_info.lvl
    local quality_type = general_info.advanceLevel or 1
    local tab_info = StaticData['advance_levels'][quality_type]
    if not tab_info or next(tab_info) == nil or not tab_info.consume then
        return false
    end
    if tab_info.level > lvl then
        return false
    end
    local tab_list = uq.RewardType.parseRewards(tab_info.consume)
    local use_num = {}
    for i, v in ipairs(tab_list) do
        local tab = v:toEquipWidget()
        if not use_num[tab.id] then
            use_num[tab.id] = 0
        end
        local num = use_num[tab.id] + tab.num
        if not self:checkRes(tab.type, num, tab.id) then
            return false
        end
        use_num[tab.id] = num
    end
    return true
end

function InstanceWar:checkRes(type, num, id) --类型判断资源是否满足条件
    local is_meet = true
    local res_num = self:getRes(type, id)
    local cost_num = math.floor(num)
    is_meet = res_num >= cost_num
    return is_meet
end

function InstanceWar:getCityRes(city_id, type)
    local instance_data = StaticData['instance_war'][self._curInstanceId]
    local map_data = StaticData.load('campaigns/' .. instance_data.fileId).Map[self._curInstanceId]

    local city_data = self:getCityData(city_id)
    for k, item in ipairs(city_data.left_resource) do
        local item_data = map_data.Object[self._curInstanceId * 100 + city_id].resources[item.id]
        local strs = string.split(item_data.one, ';')
        if type == tonumber(strs[1]) then
            return item.num
        end
    end
    return 0
end

function InstanceWar:getRes(type)
    local num = self._warRes[type] or 0
    return num
end

function InstanceWar:generalLoad(evt)
    self._warGeneral = {}
    for k, item in ipairs(evt.data.generals) do
        item.temp_id = item.id
        item.id = math.floor(item.id / 10)
        self._warGeneral[item.id] = item
    end
end

function InstanceWar:addGeneral(evt)
    for k, item in ipairs(evt.data.general_info) do
        item.temp_id = item.id
        item.id = math.floor(item.id / 10)
        self._warGeneral[item.id] = item
    end
end

function InstanceWar:isCanLevelUp(general_id)
    local is_red = false
    local general_info = self:getGeneralData(general_id)
    local one_to_exp = StaticData["general_level"].Info[1].onetoExp
    local total_exp = StaticData['general_level']['GeneralLevel'][general_info.lvl].exp
    return general_info.lvl < uq.cache.role.master_lvl and self:checkRes(uq.config.constant.COST_RES_TYPE.GESTE, math.ceil(total_exp / one_to_exp))
end

function InstanceWar:getGeneralData(general_id)
    return self._warGeneral[general_id]
end

function InstanceWar:resourceLoad(evt)
    self._warRes = {}
    for k, item in ipairs(evt.data.resources) do
        local old_value = self._warRes[item.type] or 0
        self._warRes[item.type] = item.value
        services:dispatchEvent({name = services.EVENT_NAMES.ON_INSTANCE_WAR_RES_CHANGE .. item.type, data = {old_value = old_value, new_value = item.value}})
    end
end

function InstanceWar:onInstanceInfoLoad(evt)
    self._curInstanceId = evt.data.campaign_id
    self._instanceData = {}
    for k, item in ipairs(evt.data.campaign_list) do
        self._instanceData[item.campaign_id] = item
    end
end

function InstanceWar:getInstanceData(instance_id)
    return self._instanceData[instance_id]
end

function InstanceWar:isInstancePassed(instance_id)
    if instance_id == 0 then
        return true
    end

    local instance_data = self._instanceData[instance_id]
    if instance_data and instance_data.score > 0 then
        return true
    end
    return false
end

function InstanceWar:getCurInstanceId()
    return self._curInstanceId
end

function InstanceWar:onInstanceSelect(evt)
    self._curInstanceId = evt.data.campaign_id
    uq.ModuleManager:getInstance():dispose(uq.ModuleManager.INSTANCE_WAR_CHAPTER_SELECT)
    uq.runCmd('open_instance_war', {self._curInstanceId})
end

function InstanceWar:onCityLoad(evt)
    uq.log('InstanceWar:onCityLoad', evt)
    self._cityInfo = {}
    for k, item in ipairs(evt.data.cities) do
        self._cityInfo[item.city_id] = item
        for j, general_id in ipairs(item.generals) do
            self._generalCityMap[general_id] = item.city_id
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_INSTANCE_WAR_CITY_LOAD})
end

function InstanceWar:getCityGeneral(city_id)
    local city_data = self._cityInfo[city_id]
    local general_list = {}
    for k, item in ipairs(city_data.generals) do
        local general_data = self:getGeneralData(item)
        table.insert(general_list, general_data)
    end
    return general_list
end

function InstanceWar:getCityData(city_id)
    return self._cityInfo[city_id]
end

function InstanceWar:onCityExplore(evt)
    self._roundExploreCity[evt.data.city_id] = true
    uq.fadeInfo('本轮探索成功')
end

function InstanceWar:overRoundRet(evt)
    if evt.data.ret == 0 then
        network:sendPacket(Protocol.C_2_S_CAMPAIGN_BATTLE_RESULT_LOAD)
    end
end

function InstanceWar:moveRet(evt)
    uq.fadeInfo('调动成功')

    for k, item in ipairs(self._cityInfo[evt.data.city_id].generals) do
        self._generalCityMap[item] = nil
    end

    for k, item in ipairs(evt.data.generals) do
        self._generalCityMap[item] = evt.data.city_id
    end

    self._cityInfo[evt.data.city_id].soldier = evt.data.soldier
    self._cityInfo[evt.data.city_id].generals = evt.data.generals

    --城池数据改变跟新
    services:dispatchEvent({name = services.EVENT_NAMES.ON_INSTANCE_WAR_CITY_REFRESH})
end

function InstanceWar:cityUpdate(evt)
    for k, item in ipairs(evt.data.cities) do
        self._cityInfo[item.city_id] = item
        for j, general_id in ipairs(item.generals) do
            self._generalCityMap[general_id] = item.city_id
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_INSTANCE_WAR_CITY_UPDATE})
end

function InstanceWar:moveNotify(evt)
end

function InstanceWar:exploreNotify(evt)
    self._exploreNotifyData = evt.data
end

function InstanceWar:actionLoad(evt)
    self._curRound = evt.data.round
    for k, item in ipairs(evt.data.explore_action) do
        self._roundExploreCity[item.city_id] = true
    end
    for k, item in ipairs(evt.data.battle_city) do
        self._roundBattleAcion[item.to_city_id .. '_' .. item.from_city_id] = true
    end
    --继续加载
    services:dispatchEvent({name = services.EVENT_NAMES.ON_INSTANCE_WAR_CITY_REFRESH})

    if evt.data.battle_result == 1 then
        network:sendPacket(Protocol.C_2_S_CAMPAIGN_BATTLE_RESULT_LOAD)
    end
end

function InstanceWar:defendRet(evt)
    if evt.data.ret == 0 then
        uq.fadeInfo('防守成功')
        network:sendPacket(Protocol.C_2_S_CAMPAIGN_BATTLE_RESULT_LOAD)
    end
end

function InstanceWar:battleRet(evt)
    uq.fadeInfo('出征成功')

    for k, item in ipairs(self._cityInfo[evt.data.city_id].generals) do
        self._generalCityMap[item] = nil
    end

    for k, item in ipairs(evt.data.generals) do
        self._generalCityMap[item] = evt.data.city_id
    end

    self._roundBattleAcion[evt.data.to_city_id .. '_' .. evt.data.city_id] = true
    self._cityInfo[evt.data.city_id].generals = evt.data.generals
    services:dispatchEvent({name = services.EVENT_NAMES.ON_INSTANCE_WAR_CITY_REFRESH})
end

function InstanceWar:onCampainEnd(evt)
    self._campainEndData = evt
end

function InstanceWar:endCampain(evt)
    if self._instanceData[evt.data.campaign_id] then
        if evt.data.score > self._instanceData[evt.data.campaign_id].score then
            self._instanceData[evt.data.campaign_id].score = evt.data.score
        end
    else
        self._instanceData[evt.data.campaign_id] = {}
        self._instanceData[evt.data.campaign_id].score = evt.data.score
        self._instanceData[evt.data.campaign_id].campaign_id = evt.data.campaign_id
    end

    local function end_round()
        uq.ModuleManager:getInstance():dispose(uq.ModuleManager.INSTANCE_WAR_FAIL)
        uq.ModuleManager:getInstance():dispose(uq.ModuleManager.INSTANCE_WAR_ENEMY_DESC)
        uq.ModuleManager:getInstance():dispose(uq.ModuleManager.INSTANCE_WAR_ENEMY_TIP)
        uq.jumpToModule(uq.config.constant.MODULE_ID.INSTANCE_WAR)
    end

    if evt.data.is_win == 1 then
        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.INSTANCE_WAR_WIN)
        panel:setData(evt.data, end_round)
    else
        --战役失败
        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.INSTANCE_WAR_LOSE)
        panel:setData(evt.data, end_round)
    end
    uq.cache.instance_war:endChapter()
end

function InstanceWar:retreatRet(evt)
end

function InstanceWar:battleNotify(evt)
    local instance_id = self:getCurInstanceId()
    local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.INSTANCE_WAR_ENEMY_TIP)
    panel:setData(function()
        --进入布阵
        local army_data = {
            ids    = {1},
            array  = {'army_1'},
            army_1 = {}
        }
        local enemy_data = {}
        for k, troop_id in ipairs(evt.data.troop_id) do
            local troop_data = uq.cache.instance_war:getTroopConfig(instance_id, troop_id)
            table.insert(enemy_data, troop_data.Army)
        end
        local data = {
            army_data = {army_data},
            enemy_data = enemy_data,
            embattle_type = uq.config.constant.TYPE_EMBATTLE.INSTANCE_WAR_BATTLE,
            confirm_callback = handler(self, self.formationEnd),
            mode = uq.config.constant.GAME_MODE.INSTANCE_WAR,
            from_city = evt.data.city_id
        }
        uq.ModuleManager:getInstance():show(uq.ModuleManager.ARRANGED_BEFORE_WAR, data)
    end)
end

function InstanceWar:formationEnd(data)
    uq.ModuleManager:getInstance():dispose(uq.ModuleManager.ARRANGED_BEFORE_WAR)
    local msg_data = {}
    msg_data.city_id = data[1].from_id
    msg_data.count = #data
    msg_data.formation = {}
    for k, item in ipairs(data) do
        local item_data = {}
        item_data.formation_id = item.formation_id
        item_data.count = #item.general_loc
        item_data.generals = {}
        for j, pos_data in ipairs(item.general_loc) do
            table.insert(item_data.generals, {general_id = pos_data.general_id, pos = pos_data.index})
        end
        table.insert(msg_data.formation, item_data)
    end
    network:sendPacket(Protocol.C_2_S_CAMPAIGN_DEFEND_BATTLE, msg_data)
end

function InstanceWar:battleResultLoad(evt)
    uq.log('InstanceWar:battleResultLoad', evt)
    local data = evt.data

    local function continue()
        network:sendPacket(Protocol.C_2_S_CAMPAIGN_BATTLE_RESULT_LOAD)
    end

    local function show_battle_list()
        if data.is_end == 1 then
            local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.INSTANCE_WAR_BATTLE)
            panel:setData(data)
        else
            local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.INSTANCE_WAR_BATTLE)
            panel:setData(data, continue)
        end
    end

    local function show_round()
        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.INSTANCE_WAR_ROUND)
        panel:setData(function()
            uq.fadeInfo('本轮回合结束')

            self._roundExploreCity = {}
            self._roundBattleAcion = {}
            self._curRound = data.round
            services:dispatchEvent({name = services.EVENT_NAMES.ON_INSTANCE_WAR_CITY_LOAD})
            services:dispatchEvent({name = services.EVENT_NAMES.ON_INSTANCE_WAR_CITY_REFRESH})

            if self._campainEndData then
                self:endCampain(self._campainEndData)
                self._campainEndData = nil
            end
        end)
    end

    local function show_explore()
        if self._exploreNotifyData then
            local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.INSTANCE_WAR_EXPLORE_RESULT, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
            panel:setData(self._exploreNotifyData, show_round)
            self._exploreNotifyData = nil
        else
            show_round()
        end
    end

    if data.is_end == 1 then
        if #data.battle_list > 0 then
            local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.INSTANCE_WAR_ENEMY_DESC)
            panel:setData(data, function()
                local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.INSTANCE_WAR_BATTLE)
                panel:setData(data, function()
                    if data.faild_power > 0 then
                        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.INSTANCE_WAR_FAIL)
                        panel:setData(data.faild_power, show_explore)
                    else
                        show_explore()
                    end
                end)
            end)
        else
            if data.faild_power > 0 then
                local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.INSTANCE_WAR_FAIL)
                panel:setData(data.faild_power, show_explore)
            else
                show_explore()
            end
        end
    else
        if #data.battle_list > 0 then
            local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.INSTANCE_WAR_ENEMY_DESC)
            panel:setData(data, function()
                local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.INSTANCE_WAR_BATTLE)
                panel:setData(data, function()
                    if data.faild_power > 0 then
                        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.INSTANCE_WAR_FAIL)
                        panel:setData(data.faild_power, continue)
                    else
                        continue()
                    end
                end)
            end)
        elseif data.faild_power > 0 then
            local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.INSTANCE_WAR_FAIL)
            panel:setData(data.faild_power, continue)
        else
            continue()
        end
    end
end

function InstanceWar:getPowerConfig(instance_id, power)
    local instance_data = StaticData['instance_war'][instance_id]
    local map_data = StaticData.load('campaigns/' .. instance_data.fileId).Map[instance_id]

    for k, item in pairs(map_data.Object) do
        if item.power == power then
            return item
        end
    end
end

function InstanceWar:getCityConfig(instance_id, city)
    local instance_data = StaticData['instance_war'][instance_id]
    local map_data = StaticData.load('campaigns/' .. instance_data.fileId).Map[instance_id]

    for k, item in pairs(map_data.Object) do
        if item.city == city then
            return item
        end
    end
end

function InstanceWar:getTroopConfig(instance_id, troop_id)
    local instance_data = StaticData['instance_war'][instance_id]
    local troop_data = StaticData.load('campaigns/' .. instance_data.troopId).Troop[troop_id]
    return troop_data
end

function InstanceWar:cityInvestigate(evt)

    local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.INSTANCE_WAR_INVESTIGATE, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
    panel:setData(evt.data)
end

function InstanceWar:recruitCapture(evt)
    uq.fadeInfo('劝降成功')
    for k, item in ipairs(self._cityInfo[evt.data.city_id].capture_general) do
        if item == evt.data.general_id then
            table.remove(self._cityInfo[evt.data.city_id].capture_general, k)
        end
    end
end

function InstanceWar:generalLevelUp(evt)
    uq.log('InstanceWar:generalLevelUp', evt)
    local general_data = evt.data.general_info[1]
    local general_id = math.floor(general_data.id / 10)
    local info = self._warGeneral[general_id]
    if not info then
        return
    end
    local pre_lvl = info.lvl
    self._warGeneral[general_id].lvl = general_data.lvl
    self:_onGeneralLevelUpdate(general_data)

    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_GENERAL_LEVEL, data = {pre_lvl = pre_lvl, general_id = general_id}})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_GENERALS_MODULE_RED, data = {uq.cache.generals._GENERAL_SUB_PAGE.GENERAL_ATTRIBUTE, uq.cache.generals._GENERAL_SUB_PAGE.GENERAL_ARMS, uq.cache.generals._GENERAL_SUB_PAGE.GENERAL_QUALITY}})
    -- if uq.cache.formation:checkGeneralIsInDefaultFormation(data.genaral_id) then
        -- services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_ALL_GENERAL_RED})
    -- end
end

function InstanceWar:_onGeneralLevelUpdate(data)
    self._warGeneral[math.floor(data.id / 10)].lvl = data.lvl
end

function InstanceWar:soldierSupply(evt)
    uq.fadeInfo('兵力调整成功!')
    for k, item in ipairs(evt.data.generals) do
        self._warGeneral[item.general_id].current_soldiers = item.soldier
    end
    for k, item in ipairs(evt.data.citys) do
        self._cityInfo[item.city_id].soldier = item.soldier
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_INSTANCE_WAR_CITY_REFRESH})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_INSTANCE_WAR_SOLDIER_SUPPLY})
end

function InstanceWar:inGeneralInFormation(general_id)
    if self._formationInfo.formation_id then
        for k, item in ipairs(self._formationInfo.general_loc) do
            if item.general_id == general_id then
                return true
            end
        end
    else
        for j, formation_data in ipairs(self._formationInfo) do
            for k, item in ipairs(formation_data.general_loc) do
                if item.general_id == general_id then
                    return true
                end
            end
        end
    end
    return false
end

function InstanceWar:wipeRet(evt)
    local data = {
        instance_id = evt.data.campaign_id,
        sweep_count = evt.data.wipe_count,
        items       = evt.data.rwds,
    }
    uq.ModuleManager:getInstance():show(uq.ModuleManager.NPC_SWEEP_MODULE, data)
end

function InstanceWar:updateCityInfo(evt)
    for k, item in ipairs(evt.data.citys) do
        self._cityInfo[item.city_id].soldier = item.soldier
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_INSTANCE_WAR_CITY_REFRESH})
end

return InstanceWar