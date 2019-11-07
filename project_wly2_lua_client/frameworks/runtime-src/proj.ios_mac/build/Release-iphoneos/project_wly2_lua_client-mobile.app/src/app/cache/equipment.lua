local Equipment = class("Equipment")

Equipment.QUALITY = {
    QUALITY_NORMAL = 1,
    QUALITY_GOOD = 2,
    QUALITY_EXCELLENT = 3,
    QUALITY_EPIC = 4,
    QUALITY_LEGEND = 5,
    QUALITY_ANCIENT = 6,
    QUALITY_EARLY = 7,
    QUALITY_EMPEROR = 8,
    QUALITY_DARK_GOLD = 9,
    QUALITY_PANGU = 10,
    QUALITY_CHAOS = 11,
    QUALITY_XUANYUAN = 12
}

function Equipment:ctor()
    self._allequipmentData = nil
    self._singleEquipInfo = {}
    self._equipPoolInfo = {}
    self._warehouse_red_tag = "update_warehouse_lock_time" .. tostring(self)
    network:addEventListener(Protocol.S_2_C_EQUIPMENT_LOADALL_BEGIN, handler(self, self._loadAllBegin))
    network:addEventListener(Protocol.S_2_C_EQUIPMENT_LOADALL_END, handler(self, self._loadAllEnd))
    network:addEventListener(Protocol.S_2_C_EQUIPMENT_LOADALL, handler(self, self._equipmentInfoRet))
    network:addEventListener(Protocol.S_2_C_LOAD_SINGLE_EQUIPMENT_INFO, handler(self, self._signleEquipmentInfoRet))
    network:addEventListener(Protocol.S_2_C_ITEM_CHAGE_RES, handler(self, self._itemChangeRes))
    network:addEventListener(Protocol.S_2_C_DRAW_EQUIPMENT, handler(self, self._drawEquipment))
    network:addEventListener(Protocol.S_2_C_EQUIPMENT_SELL, handler(self, self._saleEquipMent))
    network:addEventListener(Protocol.S_2_C_EQUIPMENT_DELETE, handler(self, self._equipmentDelete))
    network:addEventListener(Protocol.S_2_C_ADD_NEW_EQUIPMENT, handler(self, self._addNewEquipment))
    network:addEventListener(Protocol.S_2_C_EQUIPMENT_ACTION, handler(self, self._onEquipmentAction))
    network:addEventListener(Protocol.S_2_C_EQUIPMENT_CASTING, handler(self, self._onEquipmentCasting))
    network:addEventListener(Protocol.S_2_C_BATCH_EQUIP_ITEMS, handler(self, self._onBatchEquipItems))
    network:addEventListener(Protocol.S_2_C_EQUIP_BIND, handler(self, self._onEquipBindAction))
    network:addEventListener(Protocol.S_2_C_APPOINT_INFO, handler(self, self._loadEquipPoolInfo))
    network:addEventListener(Protocol.S_2_C_APPOINT_EQUIPMENT, handler(self, self._onAppointEquipment))
    network:addEventListener(Protocol.S_2_C_EQUIPMENT_BREAK_THROUGH, handler(self, self._onRisingSuccess))
    self:initXml()
end

function Equipment:initXml()
    self._itemLevelXml = {}
    local xml_info = StaticData['item_level']
    for k, v in pairs(xml_info) do
        local arr_price = {}
        if type(v) ~= "function" and v.cost and v.cost ~= "" then
            local arr_info = uq.RewardType.parseRewards(v.cost)
            for _, info in ipairs(arr_info) do
                table.insert(arr_price, {id = tonumber(info._id), num = tonumber(info._num), type = tonumber(info._type)})
            end
            self._itemLevelXml[v.ident + 1] = arr_price
        end
    end
end

function Equipment:calculateStrengthReturn(lvl)
    local map_return = {}
    if not lvl or lvl < 1 then
        return map_return
    end
    for i = 1, lvl do
        local arr_price = self._itemLevelXml[i]
        if arr_price and next(arr_price) ~= nil then
            for k, v in ipairs(arr_price) do
                if not map_return[v.type] then
                    map_return[v.type] = {}
                end
                map_return[v.type][v.id] = map_return[v.type][v.id] and map_return[v.type][v.id] + v.num or v.num
            end
        end
    end
    return map_return
end

function Equipment:returnMultipRate(map, rate)
    rate = rate or 0.8
    if not map or next(map) == nil then
        return {}
    end
    for k, v in pairs(map) do
        for i, num in pairs(v) do
            v[i] = math.ceil(num * rate)
        end
    end
    return map
end

function Equipment:getBaseValue(db_id)
    local info = self._allequipmentData[db_id]
    if not info then
        return 0
    end
    local effect_add = uq.cache.equipment:getIncreaseByType(info.xml.type, info.xml.qualityType)
    local pre_value = info.xml.effectValue + info.lvl * effect_add

    local star = info.star or 0
    local star_info = info.xml.UpStar[star]
    if not star_info then
        return pre_value
    end
    pre_value = pre_value + math.ceil(pre_value * star_info.effectProp / 1000) + star_info.effectValue
    return pre_value
end

function Equipment:_onRisingSuccess(evt)
    local data = evt.data
    local info = self._allequipmentData[data.db_id]
    local pre_star = info.star
    info.star = data.star
    local map_price_info = nil
    for k, v in ipairs(data.db_ids) do
        if self._allequipmentData[v].lvl > 0 then
            local map_price = self:calculateStrengthReturn(self._allequipmentData[v].lvl)
            local cur_map_price = self:returnMultipRate(map_price, 0.8)
            map_price_info = map_price_info == nil and cur_map_price or uq.RewardType.mergeRewardToMap(map_price_info, cur_map_price, true)
        end
        self._allequipmentData[v] = nil
    end
    if map_price_info then
        local tab_return = uq.RewardType:getRuleRewardTab(map_price_info)
        uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, {rewards = tab_return})
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.EQUIP_RISING_MODULE, {db_id = data.db_id, star = pre_star})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_EQUIPMENT_BREAK_THROUGH})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_GENERALS_MODULE_RED, data = {uq.cache.generals._GENERAL_SUB_PAGE.GENERAL_EQUIP, uq.cache.generals._GENERAL_SUB_PAGE.GENERAL_ARMS}})
    if info.general_id and info.general_id ~= 0 then
        services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_GENERALINFO})
    else
        self:addEquipChangeUi({info})
    end
end

function Equipment:_onAppointEquipment(msg)
    local data = msg.data
    self._equipPoolInfo[data.pool_id].secure = data.secure
    self._equipPoolInfo[data.pool_id].cd_time = data.cd_time
    self._equipPoolInfo[data.pool_id].time = data.cd_time > 0 and data.cd_time + os.time() or 0
    self._equipPoolRed[data.pool_id] = data.cd_time <= 0 and self._equipPoolInfo[data.pool_id].xml.freeCD > 0
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_EQUIP_POOL_REN})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_EQUIPMENTINFO})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_EQUIP_EXTRACT_RESULT, data = data})
end

function Equipment:_loadEquipPoolInfo(msg)
    uq.TimerProxy:removeTimer("schedele_update_info" .. tostring(self))
    self._equipPoolInfo = {}
    self._equipPoolRed = {}
    local data = msg.data
    for k, v in pairs(data.items) do
        local xml_data = StaticData['item_appoint'].ItemAppoint[v.id]
        self._equipPoolRed[v.id] = v.cd_time <= 0 and xml_data.freeCD > 0
        v.open_time = uq.getTimeStampByDaily(xml_data.openTime)
        v.close_time = uq.getTimeStampByDaily(xml_data.closeTime)
        v.time = v.cd_time > 0 and v.cd_time + os.time() or 0
        v.xml = xml_data
        self._equipPoolInfo[v.id] = v
    end

    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_EQUIP_POOL_REN})
    services:dispatchEvent({name = services.ON_LOAD_EQUIP_POOL_INFO})
end

function Equipment:scheduleUpdateInfo()
    uq.TimerProxy:addTimer("schedele_update_info" .. tostring(self), function()
        local server_time = uq.cache.server_data:getServerTime()
        local open_state = false
        local close_state = false
        for k, v in pairs(self._equipPoolInfo) do
            if v.close_time == 0 or v.close_time > server_time then
                local free_state = v.xml.freeCD > 0 and (v.cd_time <= 0 or v.time - os.time() <= 0) and v.open_time < server_time
                self._equiipPoolRed[k] = free_state
                if v.cd_time > 0 and v.time - os.time() <= 0 then
                    v.cd_time = 0
                    v.time = 0
                    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_EQUIP_POOL_REN})
                end
                if open_time ~= 0 and server_time > v.open_time and server_time - v.open_time <= 5 then
                    open_state = true
                end
            else
                if server_time > v.close_time and  server_time - v.close_time <= 5 then
                    close_state = true
                end
                self._equipPoolRed[k] = false
            end
        end
        if open_state or close_state then
            services:dispatchEvent({name = services.ON_LOAD_EQUIP_POOL_INFO})
        end
    end, 5, -1)
end

function Equipment:GetAllPoolInfo()
    return self._equipPoolInfo
end

function Equipment:_onBatchEquipItems(evt)
    for k,v in ipairs(evt.data.equip_ids) do
        self._allequipmentData[v].general_id = evt.data.general_id
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_GENERALEFF,data = evt.data.equip_ids})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_GENERALINFO})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_EQUIPMENTINFO})
end

function Equipment:_onEquipBindAction(evt)
    local data = evt.data
    if not self._allequipmentData[data.eqid] then
        return
    end
    self._allequipmentData[data.eqid].bind_type = data.bind_type
    services:dispatchEvent({name = services.EVENT_NAMES.ON_BIND_EQUIP, data = data})
end

function Equipment:_onEquipmentCasting(evt)
    local info = evt.data
    self._allequipmentData[info.new_equip_id] = {}
    self._allequipmentData[info.new_equip_id].lvl = info.level
    self._allequipmentData[info.new_equip_id].general_id = self._allequipmentData[info.src_equip_id].general_id
    self._allequipmentData[info.new_equip_id].expire_time = -1
    self._allequipmentData[info.new_equip_id].db_id = info.new_equip_id
    self._allequipmentData[info.new_equip_id].temp_id = info.new_temp_id
    self._allequipmentData[info.new_equip_id].bind_type = 0
    self._allequipmentData[info.new_equip_id].xml = StaticData['items'][info.new_temp_id]
    self._allequipmentData[info.new_equip_id].id = info.new_temp_id
    self._allequipmentData[info.new_equip_id].type = self._allequipmentData[info.new_equip_id].xml.type
    self._allequipmentData[info.src_equip_id] = nil
    services:dispatchEvent({name = services.EVENT_NAMES.ON_EQUIPMENT_CASTING,data = self._allequipmentData[info.new_equip_id]})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_GENERALINFO})
end

function Equipment:exchangeItem(general_id1, general_id2)
    local general_euqip1 = {}
    local general_euqip2 = {}
    local is_can_change = true
    for k, v in pairs(self._allequipmentData) do
        if v.general_id == general_id1 then
            table.insert(general_euqip1, self._allequipmentData[k])
        elseif v.general_id == general_id2 then
            table.insert(general_euqip2, self._allequipmentData[k])
        end
    end
    local general_info1 = uq.cache.generals:getGeneralDataByID(general_id1)
    local general_info2 = uq.cache.generals:getGeneralDataByID(general_id2)
    for k, v in ipairs(general_euqip1) do
        if v.xml == nil then
            v.xml = StaticData['items'][v.temp_id]
        end
        if v.xml.needLevel > general_info2.lvl then
            self._allequipmentData[v.db_id].general_id = 0
            is_can_change = false
        else
            self._allequipmentData[v.db_id].general_id = general_id2
        end
    end
    for k, v in ipairs(general_euqip2) do
        if v.xml == nil then
            v.xml = StaticData['items'][v.temp_id]
        end
        if v.xml.needLevel > general_info1.lvl then
            self._allequipmentData[v.db_id].general_id = 0
            is_can_change = false
        else
            self._allequipmentData[v.db_id].general_id = general_id1
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_GENERALINFO})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_EQUIPMENTINFO})
    return is_can_change
end

function Equipment:_onEquipmentAction(evt)
    uq.log('_onEquipmentAction-----', evt.data)
    local info = evt.data
    if info.ret == 0 then
        if info.actionId == 1 or info.actionId == 4  then --强化
            self._allequipmentData[info.epId].lvl = info.epLevel
            if self._allequipmentData[info.epId].general_id == 0 then
                self:addEquipChangeUi({self._allequipmentData[info.epId]})
            end
        end
        services:dispatchEvent({name = services.EVENT_NAMES.ON_EQUIPMENT_ACTION, data = info})
        services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_GENERALINFO})
        --services:dispatchEvent({name = services.EVENT_NAMES.ON_GENERAL_DETAILS_RED})
    end
end

function Equipment:_addNewEquipment(evt)
    uq.log('_addNewEquipment-----', evt.data)
    if self._allequipmentData == nil then
        self._allequipmentData = {}
    end
    local info = evt.data
    local equip_info = {}
    equip_info.db_id = info.epId
    equip_info.temp_id = info.epTemplateId
    equip_info.general_id = info.epFighterId
    equip_info.expire_time = info.epExpireTime
    equip_info.bind_type = 0
    equip_info.lvl = info.epLevel
    equip_info.xml = StaticData['items'][equip_info.temp_id]
    self._allequipmentData[equip_info.db_id] = equip_info
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_EQUIPMENTINFO})
end

function Equipment:_equipmentDelete(evt)
    uq.log('_equipmentDelete-----', evt.data)
    self._allequipmentData[evt.data.eqId] = nil
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_EQUIPMENTINFO})
end

function Equipment:_saleEquipMent(evt)
    uq.log('_saleEquipMent-----', evt.data)
    if evt.data.ret == 0 then
        self._allequipmentData[evt.data.id] = nil
        services:dispatchEvent({name = services.EVENT_NAMES.ON_SALE_EQUIPMENT})
        services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_EQUIPMENTINFO})
    end
end

function Equipment:getNumBySuitIdAndGeneral(suit_id, general_id)
    local num = 0
    if not general_id or general_id == 0 then
        return num
    end
    local info = uq.cache.equipment:getInfoByGeneralId(general_id)
    if not info or next(info) == nil then
        return num
    end
    for k, v in ipairs(info) do
        if v.xml.suitId == suit_id then
            num = num + 1
        end
    end
    return num
end

function Equipment:_drawEquipment(evt)
    uq.log('_drawEquipment-----', evt.data)
    if evt.data.ret == 0 then
        self._allequipmentData[evt.data.equipmentId].expire_time = -1
        services:dispatchEvent({name = services.EVENT_NAMES.ON_DRAW_EQUIPMENT,data = self._allequipmentData[evt.data.equipmentId]})
        services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_EQUIPMENTINFO})
    end
    self:updateRed()
end

function Equipment:_itemChangeRes(msg)
    uq.log('_itemChangeRes-----', msg.data)
    local info = msg.data
    if info.res == 0 then --穿装备
        self:unloadEquipmentByGeneralId(info.general_id,info.res_item_pos)
        self._allequipmentData[info.req_item_id].general_id = info.general_id
        local item_id = {}
        table.insert(item_id,info.req_item_id)
        uq.fadeInfo(StaticData["local_text"]["label.equip.success"])
        services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_GENERALEFF,data = item_id})
    elseif info.res == 2 then --卸载装备
        if info.req_item_id == 0 then
            uq.fadeInfo(StaticData["local_text"]["warehouse.box.full"])
            return
        end
        if info.req_item_id == -1 then
            self:unloadEquipmentByGeneralId(info.general_id)
        else
            self._allequipmentData[info.req_item_id].general_id = 0
        end
        uq.fadeInfo(StaticData["local_text"]["label.unload.success"])
    elseif info.res == 3 then
        uq.fadeInfo(StaticData["local_text"]["warehouse.box.full"])
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_EQUIPMENTINFO})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_GENERALINFO})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_GENERALS_MODULE_RED, data = {uq.cache.generals._GENERAL_SUB_PAGE.GENERAL_EQUIP}})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_ALL_GENERAL_RED, array = {uq.cache.generals._GENERAL_SUB_PAGE.GENERAL_EQUIP}})
end

function Equipment:unloadEquipmentByGeneralId(general_id,pos)
    --pos是武器部位，默认为nil的情况下，清空该武将身上装备，否则只清空该武将对应部位装备
    for k,v in pairs(self._allequipmentData) do
        if v.general_id == general_id then
            if not pos then
                self._allequipmentData[k].general_id = 0
            else
                if v.xml == nil then
                    self._allequipmentData[k].xml = StaticData['items'][v.temp_id]
                end
                if self._allequipmentData[k].xml.type == pos then
                    self._allequipmentData[k].general_id = 0
                    break
                end
            end
        end
    end
end

function Equipment:_loadAllBegin()
    self._allequipmentData = {}
    self._loadingState = true
end

function Equipment:_loadAllEnd()
    self._loadingState = false
    local totalindex = 0
    local timeindex = 0
    local generalindex = 0
    for k,v in pairs(self._allequipmentData) do
        totalindex = totalindex + 1
        if v.expire_time >= 0 then
            timeindex = timeindex + 1
            self._allequipmentData[k].xml = StaticData['items'][v.temp_id]
        end
        if v.general_id > 0 then
            generalindex = generalindex + 1
        end
    end
    self:updateRed()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_EQUIPMENTINFO})
end

function Equipment:_equipmentInfoRet(msg)
    for _,v in pairs(msg.data.equipment_data) do
        if v.expire_time >= 0 then
            v.expire_time = v.expire_time + os.time()
        end
        self._allequipmentData[v.db_id] = v
    end
    if not self._loadingState then
        self:addEquipChangeUi(msg.data.equipment_data)
        services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_ALL_GENERAL_RED})
    end
    services:dispatchEvent({name=services.EVENT_NAMES.ON_ALL_EQUIPMENT})
end

function Equipment:getAllEquipInfo()
    return self._allequipmentData
end

function Equipment:getIncreaseByType(item_type, quality_type)
    local increase = 1
    for k, v in pairs(StaticData['intensify']) do
        if item_type == v.itemType and quality_type == v.qualityType then
            increase = v.increase
        end
    end
    return increase
end

function Equipment:getInfoByTempId(temp_id)
    --根据temp_id，获取信息
    if self._allequipmentData == nil then
        return nil
    end
    local info = {}
    for k,v in pairs(self._allequipmentData) do
        if v.xml == nil then
            self._allequipmentData[k].xml = StaticData['items'][v.temp_id]
        end
        if v.temp_id == temp_id and v.expire_time <= 0 then
            table.insert(info,v)
        end
    end
    return info
end

function Equipment:getInfoByGeneralId(general_id)
    if self._allequipmentData == nil then
        return {}
    end
    local info = {}
    for k, v in pairs(self._allequipmentData) do
        if v.xml == nil then
            self._allequipmentData[k].xml = StaticData['items'][v.temp_id]
        end
        if v.general_id == general_id then
            table.insert(info, v)
        end
    end
    return info
end

function Equipment:couldAddEquipment(type, lvl)
    lvl = lvl or 1000000
    for k, v in pairs(self._allequipmentData) do
        if v.xml == nil then
            v.xml = StaticData['items'][v.temp_id]
        end
        if v.xml and v.xml.type == type and v.xml.needLevel <= lvl then
            return true
        end
    end
    return false
end

function Equipment:getInfoByType(type,level,is_general_id)
    --level是武将等级默认10000,不传level意思是等级无限制 is_general_id :true，不获取武将身上的装备
    is_general_id = is_general_id == nil and true or is_general_id
    local lvl = level or 100000
    if self._allequipmentData == nil then
        return nil
    end
    local info = {}
    for k,v in pairs(self._allequipmentData) do
        if v.xml == nil then
            self._allequipmentData[k].xml = StaticData['items'][v.temp_id]
        end
        if v.xml and v.xml.type == type and v.xml.needLevel <= lvl and v.expire_time <= 0 then
            if not is_general_id then
                table.insert(info,v)
            elseif v.general_id <= 0 then
                table.insert(info,v)
            end
        end
    end
    return info
end

function Equipment:sortByEffectValue(info)
    if info == nil or #info < 2 then
        return info
    end
    for _,v in ipairs(info) do
        if v.xml == nil then
            info[_].xml = StaticData['items'][v.temp_id]
        end
    end
    table.sort(info,function(a,b)
        if a.xml.effectValue == b.xml.effectValue then
            return false
        end
        return a.xml.effectValue > b.xml.effectValue
    end)
end

function Equipment:removeItem(id)
    for k, v in pairs(self._allequipmentData) do
        if v.db_id == id then
            self._allequipmentData[k] = nil
            break
        end
    end
    self:updateRed()
end

function Equipment:removeItemTab(tab)
    if not tab or next(tab) == nil then
        return
    end
    for k, v in pairs(tab) do
        self:removeItem(v)
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_EQUIPMENTINFO})
end

function Equipment:sortByQuality(info)
    if info == nil or #info < 2 then
        return info
    end
    for k, v in ipairs(info) do
        if v.xml == nil then
            info[k].xml = StaticData['items'][v.temp_id]
        end
        if v.general_id == nil or v.general_id == 0 then
            info[k].general_power = 0
            info[k].not_has_general = true
        else
            local general_info = uq.cache.generals:getGeneralDataByID(v.general_id)
            info[k].general_power = general_info.power
            info[k].not_has_general = false
        end
    end
    table.sort(info, function(a,b)
        if a.xml.qualityType ~= b.xml.qualityType then
            return tonumber(a.xml.qualityType) > tonumber(b.xml.qualityType)
        elseif a.star ~= b.star then
            return a.star > b.star
        elseif a.lvl ~= b.lvl then
            return a.lvl > b.lvl
        elseif a.not_has_general ~= b.not_has_general then
            return a.not_has_general
        end
        return tonumber(a.xml.ident) > tonumber(b.xml.ident)
    end)
end

function Equipment:getEquipInfoExpGeneral()
    --获取所有没有穿戴的物品
    local info = {}
    for k,v in pairs(self._allequipmentData) do
        if v.xml == nil then
            self._allequipmentData[k].xml = StaticData['items'][v.temp_id]
        end
        if v.general_id <= 0 then
            table.insert(info,v)
        end
    end
    return info
end

function Equipment:getEquipInfoExpGeneralAndTime()
    --获取所有没有穿戴并且没有倒计时的物品
    local info = {}
    for k,v in pairs(self._allequipmentData) do
        if v.xml == nil then
            self._allequipmentData[k].xml = StaticData['items'][v.temp_id]
        end
        if v.general_id <= 0 and v.expire_time < 0 then
            table.insert(info,v)
        end
    end
    uq.cache.role.used_warehouse_num = #info
    return info
end

function Equipment:getInfoByTypeAndGeneralId(type,general_id)
    --根据装备类型和武将id，获取穿戴再武将身上的装备
    if self._allequipmentData == nil or not general_id or general_id == 0 then
        return nil
    end
    for k,v in pairs(self._allequipmentData) do
        if v.xml == nil then
            self._allequipmentData[k].xml = StaticData['items'][v.temp_id]
        end
        if v.xml and v.xml.type == type and v.general_id == general_id then
            return self._allequipmentData[k]
        end
    end
    return nil
end

function Equipment:judgeCouldRisingByEquipDBId(db_id)
    if not self._allequipmentData then
        return false
    end
    local star = 0
    local info = self._allequipmentData[db_id]
    local arr_string = (info.xml.materialValue and info.xml.materialValue ~= "") and uq.RewardType.parseRewards(info.xml.materialValue)

    if not info then
        return false
    end
    if info.star >= info.xml.fullStar then
        return false
    end
    for k, v in pairs(self._allequipmentData) do
        if k ~= db_id and v.general_id == 0 and v.temp_id == info.temp_id then
            local price_state = true
            for _, object in ipairs(arr_string) do
                local price_info = object:toEquipWidget()
                if not uq.cache.role:checkRes(price_info.type, price_info.num, price_info.id) then
                    price_state = false
                end
            end
            if price_state then
                return true
            end
        end
    end
    return false
end

function Equipment:getRisingMaterialsByEquipDBId(db_id)
    if not self._allequipmentData then
        return {}
    end
    local info = self._allequipmentData[db_id]
    if not info then
        return {}
    end
    self._allMaterials = {}
    for k, v in pairs(self._allequipmentData) do
        if k ~= db_id and v.general_id == 0 and v.temp_id == info.temp_id then
            table.insert(self._allMaterials, v)
        end
    end
    return self._allMaterials
end

function Equipment:getEqualTypeEquipInfoExpDBId(db_id)
    --通过唯一db_id得到可以当做祭品洗练的装备
    if self._allequipmentData == nil then
        return nil
    end
    local old_info = self._allequipmentData[db_id]
    if not old_info then
        return nil
    end
    local info = {}
    if old_info.xml == nil then
        old_info.xml = StaticData['items'][old_info.temp_id]
    end
    for k,v in pairs(self._allequipmentData) do
        if v.xml == nil then
            self._allequipmentData[k].xml = StaticData['items'][v.temp_id]
        end
        if v.xml.type == old_info.xml.type and v.db_id ~= old_info.db_id and v.expire_time <= 0 and v.general_id == 0 and v.xml.qualityType == old_info.xml.qualityType then
            table.insert(info,v)
        end
    end
    return info
end

function Equipment:getChangeEquipInfoExpDBId(db_id, level)
    --通过唯一db_id得到可以替换的装备信息,自己除外.level是武将等级默认10000,不传level意思是等级无限制
    local lvl = level or 100000
    if self._allequipmentData == nil then
        return nil
    end
    local old_info = self._allequipmentData[db_id]
    if not old_info then
        return nil
    end
    local info = {}
    if old_info.xml == nil then
        old_info.xml = StaticData['items'][old_info.temp_id]
    end
    for k,v in pairs(self._allequipmentData) do
        if v.xml == nil then
            self._allequipmentData[k].xml = StaticData['items'][v.temp_id]
        end
        if v.xml.type == old_info.xml.type and v.db_id ~= old_info.db_id and v.xml.needLevel <= lvl and v.expire_time <= 0 then
            table.insert(info,v)
        end
    end
    return info
end

function Equipment:getChangeEquipInfo(type, lvl, arr_suit, arr_tab, state)
    --通过type得到可以替换的最高属性的装备信息,level是武将等级默认10000,不传level意思是等级无限制
    lvl = lvl or 100000
    arr_suit = arr_suit or {}
    arr_tab = arr_tab or self._allequipmentData
    if self._allequipmentData == nil then
        return nil
    end
    local effect_value = 0
    local ep_level = -1
    local star = -1
    local info = nil
    local find_suit = false
    local suit_num = 0
    for k, v in pairs(arr_tab) do
        if v.xml == nil then
            v.xml = StaticData['items'][v.temp_id]
        end
        if state and lvl == 8 then
            uq.log(v, effect_value, lvl, star, ep_level, find_suit)
        end
        if v.general_id == 0 and v.xml and v.xml.type == type and v.xml.needLevel <= lvl and v.expire_time <= 0 and
            (v.xml.effectValue > effect_value or (v.xml.effectValue == effect_value and v.star > star) or
            (v.xml.effectValue == effect_value and v.star == star and v.lvl > ep_level) or
            (v.xml.effectValue == effect_value and v.star == star and v.lvl == ep_level and
            (not find_suit or (v.xml.suitId and arr_suit[v.xml.suitId] and arr_suit[v.xml.suitId] > suit_num)))) then

            if not find_suit and v.xml.suitId ~= nil then
                find_suit = true
            end
            ep_level = v.lvl
            suit_num = (v.xml.suitId and arr_suit[v.xml.suitId]) and arr_suit[v.xml.suitId] or 0
            effect_value = v.xml.effectValue
            star = v.star
            info = v
        end
    end
    return info
end

function Equipment:getGeneralsSuitId(general_id)
    self._arrSuitId = {}
    local info = uq.cache.equipment:getInfoByGeneralId(general_id)
    if info and next(info) ~= nil then
        for k, v in ipairs(info) do
            if v.xml.suitId then
                self._arrSuitId[v.xml.suitId] = self._arrSuitId[v.xml.suitId] and self._arrSuitId[v.xml.suitId] + 1 or 1
            end
        end
    end
    return self._arrSuitId
end

function Equipment:_getEquipInfoByDBId(db_id)
    return self._allequipmentData[db_id]
end

function Equipment:_signleEquipmentInfoRet(evt)
    uq.log('_signleEquipmentInfoRet-----', evt.data)
    self._singleEquipInfo[evt.data.epDbId] = evt.data
    services:dispatchEvent({name = services.EVENT_NAMES.ON_SIGNLE_EQUIPMENT,data = evt.data})
end

function Equipment:getSingleEquipInfoById(ep_id)
    return self._singleEquipInfo[ep_id]
end

function Equipment:isEquip(item_id)
    local xml_data = StaticData['items'][item_id]
    if xml_data then
        if xml_data.type == uq.config.constant.ITEM_TYPE.TYPE_WEAPON
            or xml_data.type == uq.config.constant.ITEM_TYPE.TYPE_ARMOR
            or xml_data.type == uq.config.constant.ITEM_TYPE.TYPE_CLOAK
            or xml_data.type == uq.config.constant.ITEM_TYPE.TYPE_SHIELD then
            return true
        end
    end
    return false
end

function Equipment:updateRed()
    uq.cache.hint_status.status[uq.cache.hint_status.RED_TYPE.MAIN_CITY_WAREHOUSE] = false
    local total_info = self:getEquipInfoExpGeneral()
    local used_info = self:getEquipInfoExpGeneralAndTime()
    if #total_info - #used_info >= 1 then
        uq.cache.hint_status.status[uq.cache.hint_status.RED_TYPE.MAIN_CITY_WAREHOUSE] = true
        services:dispatchEvent({name = services.EVENT_NAMES.ON_MAIN_CITY_BOTTOM_SIDE_RED_CHANGES, data = uq.cache.hint_status.RED_TYPE.MAIN_CITY_WAREHOUSE})
    end
end

function Equipment:getAllXmlEquipByType(equip_type)
    local info = {}
    for k, v in pairs(StaticData['items']) do
        if v.type == equip_type then
            local data = {}
            data.type = uq.config.constant.COST_RES_TYPE.EQUIP
            data.id = v.ident
            data.qualityType = v.qualityType
            table.insert(info, data)
        end
    end
    table.sort(info, function(a, b)
        return a.qualityType < b.qualityType
    end)
    return info
end

function Equipment:addEquipChangeUi(array)
    local arr_type = {}
    for k, v in ipairs(array) do
        if not v.xml then
            v.xml = StaticData['items'][v.temp_id]
        end
        arr_type[v.xml.type] = true
    end
    self._selectedInfo = nil
    local find_not_equip = false
    local formation_info = uq.cache.formation:getDefaultFormation()
    for k, v in pairs(formation_info.general_loc) do
        if v and v.general_id and v.general_id ~= 0 then
            local arr_suit = uq.cache.equipment:getGeneralsSuitId(v.general_id)
            for equip_type, state in pairs(arr_type) do
                local general_info = uq.cache.generals:getGeneralDataByID(v.general_id)
                local pre_info = self:getInfoByTypeAndGeneralId(equip_type, v.general_id)
                if (not find_not_equip and not self._selectedInfo) or not pre_info then
                    if pre_info and pre_info.xml.suitId then
                        arr_suit[pre_info.xml.suitId] = arr_suit[pre_info.xml.suitId] - 1
                    end
                    local max_info = self:getChangeEquipInfo(equip_type, general_info.lvl, arr_suit, array, true)
                    if max_info and (not pre_info or max_info.xml.effectValue > pre_info.xml.effectValue) then
                        self._selectedInfo = max_info
                        self._seletdId = v.general_id
                    end

                    if not pre_info then
                        find_not_equip = true
                        break
                    end
                    if pre_info and pre_info.xml.suitId then
                        arr_suit[pre_info.xml.suitId] = arr_suit[pre_info.xml.suitId] + 1
                    end
                end
            end
        end
        if find_not_equip then
            break
        end
    end
    if self._selectedInfo then
        services:dispatchEvent({name = services.EVENT_NAMES.ON_SET_CHANGEUI_INFO, data = {info = self._selectedInfo, id = self._seletdId, state = find_not_equip}})
    end
end

return Equipment