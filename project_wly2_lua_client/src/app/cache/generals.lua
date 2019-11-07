local Generals = class("Generals")

Generals._GENERAL_SUB_PAGE = {
    GENERAL_ATTRIBUTE = 1,
    GENERAL_EQUIP     = 2,
    GENERAL_ARMS      = 3,
    GENERAL_QUALITY   = 4,
    GENERAL_INSIGHT   = 5,
}

function Generals:ctor()
    self._allGeneralsInfo = {}
    self._allGeneralsAttr = {}
    self._allPieceInfo = {}
    self._curTrainTimeType = 0
    self._curTrainIntensityType = 0
    self._startReceiveGeneralInfo = true
    self._repeatSuddenFly = false
    self._isSuddenFlySuccess = false
    self._upDownOrder = {"compose", "quality_type", "grade", "id"}

    self._upGeneralsInfo = {}
    self._unlockGeneral = {}
    self._xmlGeneralsInfo = {}
    self._showGenerels = {}
    self._newGenerelPools = {}
    self._generelPoolsRedInfo = {}
    self._GeneralPoolInfo = {}

    local arr_type = StaticData['types'].Effect[1].Type
    self._arrSpecialType = {}
    for k, v in pairs(arr_type) do
        if v.percent and v.percent ~= 1 then
            self._arrSpecialType[v.ident] = v.percent
        end
    end

    network:addEventListener(Protocol.S_2_C_ALLGENERAL_INFO, handler(self, self._allGeneralInfoRet))
    network:addEventListener(Protocol.S_2_C_UPDATE_GENARALINFO, handler(self, self._onUpdateGenaralInfo))
    network:addEventListener(Protocol.S_2_C_GENERAL_EPIPHANY, handler(self, self._onGeneralEpiphany))
    network:addEventListener(Protocol.S_2_C_GENERALINFOS, handler(self, self._onGeneralInfo))
    network:addEventListener(Protocol.S_2_C_GENERAL_LIMIT_SOLDIER_NUM, handler(self, self._onGeneralLimitSoldierNum))
    network:addEventListener(Protocol.S_2_C_UPDATE_GENERAL_SOLDIER, handler(self, self._onUpdateGeneralSoldier))
    network:addEventListener(Protocol.S_2_C_TRANSFER_SOLDIER_RES, handler(self, self._onTransferSoldierRes))
    network:addEventListener(Protocol.S_2_C_REBUILD_SOLDIER_IDS, handler(self, self._onRebuildSoldierIds))
    network:addEventListener(Protocol.S_2_C_REBUILD_SOLDIER_RES, handler(self, self._onRebuildSoldierRes))
    network:addEventListener(Protocol.S_2_C_ADD_TRAINSOLT_RES, handler(self, self._onAddTrainSoltRes))
    network:addEventListener(Protocol.S_2_C_REINFORCED_SOLDIER,handler(self,self._onReinforcedSoldier))
    network:addEventListener(Protocol.S_2_C_CRUITEGENERAL_RES, handler(self, self._onRecruitGeneral))
    network:addEventListener(Protocol.S_2_C_ADD_GENERAL_RES, handler(self, self._onAddGeneralTrain))
    network:addEventListener(Protocol.S_2_C_OVER_GENERAL_RES, handler(self, self._onOverGeneralTrain))
    network:addEventListener(Protocol.S_2_C_ADD_GENERAL_NUMS, handler(self, self._onAddGeneralNum))
    network:addEventListener(Protocol.S_2_CREINCARNATION_RES, handler(self, self._onReincarnation))
    network:addEventListener(Protocol.S_2_C_END_TRAINING, handler(self, self._onEndTraining))
    network:addEventListener(Protocol.S_2_C_GENERAL_COMPOSE, handler(self, self._onPieceCompose))
    network:addEventListener(Protocol.S_2_C_EQUIP_ADVANCE_ITEM, handler(self, self._onEquipAdvanceItem))
    network:addEventListener(Protocol.S_2_C_UPDATE_GENERAL_INTERNAL, handler(self, self.onUpdateGeneralInternal))
    network:addEventListener(Protocol.S_2_C_GENERAL_CLEAR_TIRED, handler(self, self.onClearTired))
    network:addEventListener(Protocol.S_2_C_GET_NEW_GENERAL, handler(self, self.onGetNewGeneral))
    network:addEventListener(Protocol.S_2_C_GENERAL_ATTR_INFO, handler(self, self._onGetGeneralAttr))
    network:addEventListener(Protocol.S_2_C_DRAFT_UPDATE, handler(self, self.onUpdateArmy))
    network:addEventListener(Protocol.S_2_C_DRAFT_SPEED, handler(self, self.onDraftSpeed))
    network:addEventListener(Protocol.S_2_C_SUDDLEN_RES, handler(self, self._updateSuddenFlight))
    network:addEventListener(Protocol.S_2_C_GENERAL_ADVANCE, handler(self, self._onGeneralAdvance))
    network:addEventListener(Protocol.S_2_C_APPOINT_GENERAL_INFO, handler(self, self._loadGeneralPoolInfo))
    network:addEventListener(Protocol.S_2_C_APPOINT_GENERAL, handler(self, self._onAppointGeneral))
    network:addEventListener(Protocol.S_2_C_APPOINT_GENERAL_CHANGE, handler(self, self._onAppointGeneralChange))
    services:addEventListener(services.EVENT_NAMES.ON_ILLUSTRATION_RED, handler(self, self.updateRed))
    services:addEventListener(services.EVENT_NAMES.ON_UPDATE_ALL_GENERAL_RED, handler(self, self.updateRed))
    services:addEventListener(services.EVENT_NAMES.ON_GENERALS_COMPOSE_RED, handler(self, self.updateComposeRed))

    local arrSourceType = {
        uq.config.constant.COST_RES_TYPE.GESTE,
        uq.config.constant.COST_RES_TYPE.IRON_MINE,
        uq.config.constant.COST_RES_TYPE.MONEY,
    }
    local arrPage = {
        {self._GENERAL_SUB_PAGE.GENERAL_ATTRIBUTE},
        {self._GENERAL_SUB_PAGE.GENERAL_EQUIP},
        {self._GENERAL_SUB_PAGE.GENERAL_EQUIP, self._GENERAL_SUB_PAGE.GENERAL_ARMS}
    }
    for k, v in ipairs(arrSourceType) do
        services:addEventListener(services.EVENT_NAMES.ON_CONSUME_RES_CHANGE .. v, function()
            self:updateRed({array = arrPage[k]})
        end)
    end
end

function Generals:_onGeneralAdvance(msg)
    local data = msg.data
    local general_info = uq.cache.generals:getGeneralDataByID(data.general_id)
    if not general_info then
        return
    end
    general_info.advanceLevel = data.advance_level
    self:refreshGeneralAdvanceLv(data.general_id, data.advance_level)
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_GENERALS_MODULE_RED, data = {self._GENERAL_SUB_PAGE.GENERAL_QUALITY}})
end

function Generals:_onGetGeneralAttr(msg)
    local data = msg.data
    self._generalAttrChange = {}
    for _, info in ipairs(data.arr_infos) do
        if not self._allGeneralsAttr[info.general_id] then
            self._allGeneralsAttr[info.general_id] = {}
        end
        self._generalAttrChange[info.general_id] = {}
        for k, v in ipairs(info.attr_list) do
            local pre_info = self._allGeneralsAttr[info.general_id][v.attr_type]
            local value = pre_info and v.value - pre_info or v.value
            self._generalAttrChange[info.general_id][v.attr_type] = value ~= 0 and value or nil
            self._allGeneralsAttr[info.general_id][v.attr_type] = v.value
        end

        local data = self:getGeneralDataByID(info.general_id)
        if data then
            data.power = info.power
            data.leader = self._allGeneralsAttr[info.general_id][27]
            data.attack = self._allGeneralsAttr[info.general_id][28]
            data.mental = self._allGeneralsAttr[info.general_id][29]
            data.siege  = self._allGeneralsAttr[info.general_id][35]
            data.max_soldiers = self._allGeneralsAttr[info.general_id][7]
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_GET_GENERAL_ATTR})
end

function Generals:getGeneralAttrById(id)
    return self._allGeneralsAttr[id]
end

function Generals:_onReinforcedSoldier(evt)
    local info = evt.data
    local general_info = self:getGeneralDataByID(info.generalId)
    if general_info then
        if general_info.soldierId1 == info.oriId then
            if general_info.soldierId1 == general_info.battle_soldier_id then
                general_info.battle_soldier_id = info.curId
            end
            general_info.soldierId1 = info.curId
        else
            if general_info.soldierId2 == general_info.battle_soldier_id then
                general_info.battle_soldier_id = info.curId
            end
            general_info.soldierId2 = info.curId
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_REINFORCE_SOLDIER,data = info})
    local view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.GENERALS_ARMS_STRENGTH_MODULE)
    if view then
        view:disposeSelf()
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ARMS_STRENGTH_SUCCESS_MODULE,{soldier_id = info.curId})
end

function Generals:onGetNewGeneral(evt)
    local data = evt.data
    for i = 1, data.count do
        self:_refreshGeneralInfo(data.info[i])
        self:dealGetNewGenerals(data.info[i].id, true)
    end
end

function Generals:getNumByEffectType(effect_type, num)
    local str = ''
    if self._arrSpecialType[effect_type] then
        num = num * self._arrSpecialType[effect_type]
        str = '%'
    end
    local dot1 = (num - math.floor(num)) * 10
    local dot2 = (dot1 - math.floor(dot1)) * 10
    local dot3 = (dot2 - math.floor(dot2)) * 100
    if dot2 >= 1 or dot3 >= 1 then
        return math.floor(num) + math.floor(dot1) * 0.1 + math.ceil(dot2) * 0.01 .. str
    elseif dot1 > 1 then
        return math.floor(num) + math.ceil(dot1) * 0.1 .. str
    else
        return string.format("%d", num) .. str
    end
end

--登庸合成的消息
function Generals:_onPieceCompose(evt)
    local data = evt.data
    if data.ret ~= 0 then
        return
    end
    self:_refreshGeneralInfo(data.info[1])
    self:dealGetNewGenerals(data.info[1].id, true)
    self:updateComposeRed()
    self:updateRed()
    uq.refreshNextNewGeneralsShow()
end

function Generals:dealGetNewGenerals(general_id, is_new)
    local data = {info = general_id, is_new = is_new}
    uq.showNewGenerals(data, false)
    if not is_new then
        return
    end
end

function Generals:_onEndTraining(evt)
    local general_id = evt.data.general_id
    if self._allGeneralsInfo.generals_map[general_id] then
        self._allGeneralsInfo.generals_map[general_id].train_time = 0
        self._allGeneralsInfo.generals_map[general_id].current_exp = 0
        services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_GENERALINFO, genaral_id = evt.data.general_id})
    end
end

function Generals:_onRebuildSoldierRes(evt)
    local info = evt.data
    if info.res == 0 then
        local general_info = self:getGeneralDataByID(info.genaral_id)
        if general_info then
            general_info.rebuildSoldierId1 = 0
            general_info.rebuildSoldierId2 = 0
            general_info.soldierId1 = info.soldier_id1
            general_info.soldierId2 = info.soldier_id2
        end
        services:dispatchEvent({name = services.EVENT_NAMES.ON_REBULID_SOLDIERS_RES,data = info})
        local view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.GENERALS_ARMS_REBUILD_MODULE)
        if view then
            view:disposeSelf()
        end
        uq.fadeInfo(StaticData["local_text"]["general.soldier.changes.success"])
    end
end

function Generals:_onRebuildSoldierIds(evt)
    local info = evt.data
    local general_info = self:getGeneralDataByID(info.genaral_id)
    if general_info then
        general_info.rebuildSoldierId1 = info.soldier_id1
        general_info.rebuildSoldierId2 = info.soldier_id2
    end
    uq.fadeInfo(StaticData["local_text"]["general.soldier.rebuild.success"])
    self._allGeneralsInfo.rebuildSoldierNums = self._allGeneralsInfo.rebuildSoldierNums + 1
    self._allGeneralsInfo.isRebuildSoldierFree = 1
    services:dispatchEvent({name = services.EVENT_NAMES.ON_REBULID_SOLDIERS_IDS,data = info})
end

function Generals:_onTransferSoldierRes(evt)
    uq.log("_onTransferSoldierRes ",evt.data)
    local info = evt.data
    if info.ret == 0 then
        local general_info = self:getGeneralDataByID(info.genaral_id)
        if general_info then
            general_info.transferSoldierTimes = info.transfer_soldier_times
            if general_info.soldierId1 == general_info.battle_soldier_id then
                general_info.battle_soldier_id = info.new_soldier_id1
            else
                general_info.battle_soldier_id = info.new_soldier_id2
            end
            general_info.soldierId1 = info.new_soldier_id1
            general_info.soldierId2 = info.new_soldier_id2
            general_info.rebuildSoldierId1 = 0
            general_info.rebuildSoldierId2 = 0
        end
        services:dispatchEvent({name = services.EVENT_NAMES.ON_TRANSFER_SOLDER_RES,data = info})
        services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_GENERALS_MODULE_RED, data = {self._GENERAL_SUB_PAGE.GENERAL_EQUIP, self._GENERAL_SUB_PAGE.GENERAL_ARMS}})
        if uq.cache.formation:checkGeneralIsInDefaultFormation(info.genaral_id) then
            services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_ALL_GENERAL_RED})
        end
        local view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.GENERALS_ARMS_ADVANCE_MODULE)
        if view then
            view:disposeSelf()
        end
    end
end

function Generals:_onUpdateGeneralSoldier(evt)
    uq.log('_onUpdateGeneralSoldier  ', evt.data)
    uq.cache.role.soldierNum = evt.data.role_soldier_num
    for k, v in ipairs(evt.data.general) do
        self._allGeneralsInfo.generals_map[v.general_id].current_soldiers = v.cur_soldier_num
        services:dispatchEvent({name = services.EVENT_NAMES.ON_GENERAL_LIMIT_SOLDIER, data = v.general_id})
    end

    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_GENERALINFO})
end

function Generals:_onGeneralLimitSoldierNum(evt)
    uq.log('_onGeneralLimitSoldierNum  ', evt.data)
    self._allGeneralsInfo.generals_map[evt.data.generalId].limitSoldierNum = evt.data.soldierNum
    self._allGeneralsInfo.generals_map[evt.data.generalId].current_soldiers = evt.data.cur_soldier_num
    uq.cache.role.soldierNum = evt.data.role_soldier_num
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_GENERALINFO})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_GENERAL_LIMIT_SOLDIER, data = evt.data.generalId})
    uq.fadeInfo(StaticData["local_text"]["general.soldier.limit.success"])
end

function Generals:_onGeneralInfo(evt)
    local info = evt.data.data[1] or {}
    if evt.data.res == 0 then
        self:_refreshGeneralInfo(info)
    end
end

function Generals:_refreshGeneralInfo(info)
    local info = info or {}
    if not info or next(info) == nil then
        return
    end
    info.temp_id = info.id
    info.id = math.floor(info.id / 10)
    info.general_id = info.id
    self:_onUpdateGenaralInfo({data = info})
    if not self:isGeneralUp(info.id) then
        local xml_data = StaticData['general'][info.temp_id]
        local tab = {
            lvl = info.lvl,
            id = info.id,
            temp_id = info.temp_id,
            rtemp_id = info.rtemp_id,
            skill_id = info.skill_id,
            unlock = true,
            is_formation = uq.cache.formation:checkGeneralIsInFormationById(info.id) and 1 or 0,
            advance_lv = info.advanceLevel,
            quality_type = xml_data.qualityType,
            grade = info.grade
        }
        table.insert(self._upGeneralsInfo, tab)

        for i, v in ipairs(self._xmlGeneralsInfo) do
            if v.id == info.general_id then
                table.remove(self._xmlGeneralsInfo, i)
                break
            end
        end
        services:dispatchEvent({name = services.EVENT_NAMES.ON_GENERALS_NEW_GENERAL})
    end
end

function Generals:_onGeneralLevelUpdate(data)
    self._allGeneralsInfo.generals_map[data.genaral_id].lvl = data.level
    for k, info in ipairs(self._upGeneralsInfo) do
        if info.id == data.genaral_id then
            self._upGeneralsInfo[k].lvl = data.level
        end
    end
end

function Generals:refreshGeneralAdvanceLv(id, lv)
    for i, v in ipairs(self._upGeneralsInfo) do
        if v.id == id then
            v.advance_lv = lv
            break
        end
    end
end

function Generals:_onGeneralEpiphany(evt)
    local data = evt.data
    for k, info in ipairs (self._upGeneralsInfo) do
        if info.id == data.id then
            local xml_data = StaticData['general'][data.new_temp_id]
            info.quality_type = xml_data.qualityType
            info.temp_id = data.new_temp_id
            info.rtemp_id = data.new_temp_id
        end
    end
    data.data[1].general_id = data.id
    self._allGeneralsInfo.generals_map[data.id].temp_id = data.new_temp_id
    self._allGeneralsInfo.generals_map[data.id].rtemp_id = data.new_temp_id
    self:_onUpdateGenaralInfo({data = data.data[1]})
    uq.playSoundByID(47)
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_GENERALS_MODULE_RED, data = {self._GENERAL_SUB_PAGE.GENERAL_INSIGHT}})
    uq.ModuleManager:getInstance():show(uq.ModuleManager.INSIGHT_SUCCESS_MODULE,{general_id = evt.data.old_temp_id, temp_id = data.new_temp_id})
end

function Generals:_onUpdateGenaralInfo(evt)
    local info = evt.data
    if self._allGeneralsInfo.generals_map[info.general_id] then
        if self._allGeneralsInfo.generals_map[info.general_id].current_exp ~= info.exp then
            self._allGeneralsInfo.generals_map[info.general_id].current_exp = info.exp
        end
        if self._allGeneralsInfo.generals_map[info.general_id].lvl ~= info.lvl then
            self._allGeneralsInfo.generals_map[info.general_id].lvl = info.lvl
        end
        if self._allGeneralsInfo.generals_map[info.general_id].leader ~= info.leader then
            self._allGeneralsInfo.generals_map[info.general_id].leader = info.leader
        end
        if self._allGeneralsInfo.generals_map[info.general_id].attack ~= info.attack then
            self._allGeneralsInfo.generals_map[info.general_id].attack = info.attack
        end
        if self._allGeneralsInfo.generals_map[info.general_id].mental ~= info.mental then
            self._allGeneralsInfo.generals_map[info.general_id].mental = info.mental
        end
        if self._allGeneralsInfo.generals_map[info.general_id].max_soldiers ~= info.max_soldiers then
            self._allGeneralsInfo.generals_map[info.general_id].max_soldiers = info.max_soldiers
        end
        if self._allGeneralsInfo.generals_map[info.general_id].current_soldiers ~= info.current_soldiers then
            self._allGeneralsInfo.generals_map[info.general_id].current_soldiers = info.current_soldiers
        end
        if self._allGeneralsInfo.generals_map[info.general_id].battle_soldier_id ~= info.battle_soldier_id then
            self._allGeneralsInfo.generals_map[info.general_id].battle_soldier_id = info.battle_soldier_id
            uq.fadeInfo(StaticData["local_text"]["general.soldier.change"])
            services:dispatchEvent({name = services.EVENT_NAMES.ON_CHANGE_BATTLE_SOLDIER_ID, data = info})
        end
        if self._allGeneralsInfo.generals_map[info.general_id].power ~= info.power then
            self._allGeneralsInfo.generals_map[info.general_id].power = info.power
        end
        services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_GENERALINFO, genaral_id = evt.data.general_id})
    else
        self._allGeneralsInfo.generals_map[info.general_id] = info
    end
end

function Generals:deleteGeneralsById(id)
    if self._allGeneralsInfo.generals_map[id] then
        uq.fadeInfo(StaticData["local_text"]["recruit.generals.out"])
        self._allGeneralsInfo.generals_map[id] = nil
    end
    for i, v in ipairs(self._upGeneralsInfo) do
        if v.id == id then
            table.remove(self._upGeneralsInfo, i)
            break
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_DELETE_GENERALS})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_GENERALS_NEW_GENERAL})
end

function Generals:refreshGeneralStatus()
    self._upGeneralsInfo = {}
    self._xmlGeneralsInfo = {}
    local id_map = {}
    for k, info in pairs(self._allGeneralsInfo.generals_map) do
        local xml_data = StaticData['general'][info.temp_id]
        local tab = {
            lvl = info.lvl,
            id = info.id,
            temp_id = info.temp_id,
            rtemp_id = info.rtemp_id,
            skill_id = info.skill_id,
            unlock = true,
            is_formation = uq.cache.formation:checkGeneralIsInFormationById(info.id) and 1 or 0,
            advance_lv = info.advanceLevel,
            quality_type = xml_data.qualityType,
            grade = info.grade
        }
        table.insert(self._upGeneralsInfo, tab)
        id_map[info.id] = true
    end
    for k, item in pairs(StaticData['general']) do
        --相同国家或者中立
        local id = math.floor(k / 10)
        if not id_map[id] and k % 10 == 1 and (item.camp == uq.cache.role.country_id or item.camp == uq.config.constant.COUNTRY.NEUTRAL) and item.type <= 5 and item.Visibility == 1 then
            local tab = {
                lvl = 1,
                id = id,
                temp_id = k,
                rtemp_id = k,
                compose = uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.SPIRIT, item.composeNums, id) and 1 or 0,
                unlock = false,
                quality_type = item.qualityType,
                grade = item.grade,
                compose_nums = item.composeNums
            }
            table.insert(self._xmlGeneralsInfo, tab)
            id_map[id] = true
        end
    end
    self:updateCollectPage()
    --self:updataQualityRed()
    self:updateComposeRed()
    self:updateRed()
end

function Generals:_onEquipAdvanceItem(evt)
    local data = evt.data
    if not data or next(data) == nil then
        return
    end
    local general_info = uq.cache.generals:getGeneralDataByID(data.general_id)
    if not general_info and next(general_info) == nil then
        return
    end
    for i, v in ipairs(data.equip_pos) do
        if v ~= 0 then
            general_info.advanceInfo[v] = 1
            local prop_id = self:getPropIdByPos(general_info.advanceLevel, v)
            uq.cache.role:setResChange(uq.config.constant.COST_RES_TYPE.ORDER_MATERIAL, -1, prop_id)
        end
    end
    self:updataQualityRed()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_GENERALS_ITEM, data = data})
end

function Generals:getUnLockGeneralaDataByID(id)
    for k,item in ipairs(self._unlockGeneral) do
        if item.temp_id == id then
            return item
        end
    end
    return nil
end

function Generals:_allGeneralInfoRet(msg)
    if self._startReceiveGeneralInfo then
        self._allGeneralsInfo.generals_map = {}
        self._startReceiveGeneralInfo = false
    end

    self._allGeneralsInfo.rebuildSoldierNums = msg.data.rebuildSoldierNums
    self._allGeneralsInfo.isOver = msg.data.isOver
    self._allGeneralsInfo.mainGeneralId = msg.data.mainGeneralId
    self._allGeneralsInfo.isRebuildSoldierFree = msg.data.isRebuildSoldierFree
    self._allGeneralsInfo.counts = msg.data.counts
    self._allGeneralsInfo.goldSuddenNums = msg.data.goldSuddenNums
    for k,item in ipairs(msg.data.generals) do
        item.temp_id = item.id
        item.id = math.floor(item.id / 10)
        self._allGeneralsInfo.generals_map[item.id] = item
    end
    if msg.data.isOver == 1 then
        self._startReceiveGeneralInfo = true
        services:dispatchEvent({name=services.EVENT_NAMES.ON_GENERAL_INFO_RET})
        uq.runCmd('enter_main_city')
    end
    self:refreshGeneralStatus()
end

function Generals:sortGenerals(list, order)
    if not list or next(list) == nil then
        return
    end
    local str_tab = order or {"is_formation", "quality_type", "advance_lv", "lvl", "grade", "id"}
    table.sort(list, function (a, b)
        for i, v in ipairs(str_tab) do
            if a[v] ~= b[v] then
                if type(a[v]) == "boolean" then
                    return a[v]
                else
                    if b[v] == nil then
                        return true
                    elseif a[v] == nil then
                        return false
                    else
                        return a[v] > b[v]
                    end
                end
            end
        end
        return false
    end)
end
--已有武将
function Generals:getUpGeneralsByType(selected_type)
    selected_type = selected_type or 0
    for i, v in ipairs(self._upGeneralsInfo) do
        v.is_formation = uq.cache.formation:checkGeneralIsInFormationById(v.id) and 1 or 0
    end
    if selected_type == 0 then
        self:sortGenerals(self._upGeneralsInfo)
        return self._upGeneralsInfo
    end

    local list = {}
    if selected_type == 5 then
        for k, item in pairs(self._upGeneralsInfo) do
            local info = StaticData['general'][item.temp_id]
            if info.isJiuguan ~= 0 then
                table.insert(list, item)
            end
        end
        self:sortGenerals(list)
        return list
    end

    for k, item in pairs(self._upGeneralsInfo) do
        local skill_type = StaticData['skill'][item.skill_id].skillType
        if self:isBelongNeedType(item.temp_id, selected_type, skill_type) then
            table.insert(list, item)
        end
    end
    self:sortGenerals(list)
    return list
end

function Generals:checkGeneralIsInFormationById(id)
    return uq.cache.formation:checkGeneralIsInFormationById(id) or uq.cache.arena:checkGeneralIsInFormationById(id)
        or uq.cache.fly_nail:checkGeneralIsInFormationById(id) or uq.cache.world_war:checkGeneralIsInFormationById(id)
end

function Generals:getDownGeneralsByType(occupation_type)
    if occupation_type == 5 then
        return {}
    end
    local occupation_type = occupation_type or 0
    for i, v in ipairs(self._xmlGeneralsInfo) do
        v.compose = uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.SPIRIT, v.compose_nums, v.id) and 1 or 0
    end
    if occupation_type == 0 then
        self:sortGenerals(self._xmlGeneralsInfo, self._upDownOrder)
        return self._xmlGeneralsInfo
    end
    local list = {}
    for k, item in pairs(self._xmlGeneralsInfo) do
        if self:isBelongNeedType(item.temp_id, occupation_type) then
            table.insert(list, item)
        end
    end
    self:sortGenerals(list, self._upDownOrder)
    return list
end
--根据武将技能类型区分
function Generals:isBelongNeedType(temp_id, type_skill, skill_type)
    skill_type = skill_type or self:getSkillTypeById(temp_id)
    if skill_type == "" then
        return false
    end
    local str_tab = string.split(tostring(skill_type), ",")
    for i, v in ipairs(str_tab) do
        if tonumber(v) == type_skill then
            return true
        end
    end
    return false
end

function Generals:getXmlSkillById(temp_id)
    local xml_data = StaticData['general'][temp_id] or {}
    if not xml_data or not xml_data.skillId then
        return {}
    end
    return StaticData['skill'][xml_data.skillId] or {}
end

function Generals:getSkillTypeById(temp_id)
    local skill_xml = self:getXmlSkillById(temp_id)
    if skill_xml and skill_xml.skillType then
        return tostring(skill_xml.skillType)
    end
    return ""
end

function Generals:getGeneralTempId(general_id)
    local general_data = self._allGeneralsInfo.generals_map[general_id]
    return general_data.temp_id
end

function Generals:getGeneralRtempId(general_id)
    local general_data = self._allGeneralsInfo.generals_map[general_id]
    return general_data.rtemp_id
end

--已经拥有的武将
function Generals:getGeneralDataByID(id)
    return (id and self._allGeneralsInfo.generals_map) and self._allGeneralsInfo.generals_map[id] or nil
end
--得到招募武将的数量
function Generals:getRecruitGeneralsNum()
    local num = 0
    for k, v in pairs(self._allGeneralsInfo.generals_map) do
        if v.rtemp_id ~= v.temp_id then
            num = num + 1
        end
    end
    return num
end

function Generals:getAllGeneralData()
    return self._allGeneralsInfo and self._allGeneralsInfo.generals_map or nil
end

function Generals:getGeneralNameByID(id)
    local temp_id = tonumber(id .. 1)
    local config = StaticData['general'][temp_id]
    if config then
        return config.name
    else
        return nil
    end
end

function Generals:getGeneralIsHaveByID(id)
    if self._allGeneralsInfo and self._allGeneralsInfo.generals_map[id] then
        return true
    end
    return false
end

function Generals:getAllGeneralInfo()
    return self._allGeneralsInfo
end

function Generals:getAllTrainingNum()
    local num = 0
    for _,item in pairs(self._allGeneralsInfo.generals_map) do
        if item.train_time > 0 then
            num = num + 1
        end
    end
    return num
end

--获取所有在训练中的武将数据
function Generals:getAllNotTrainGeneral()
    local data_list = {}
    for _,item in pairs(self._allGeneralsInfo.generals_map) do
        if item.train_time < 0 then
            table.insert(data_list, item)
        end
    end
    return data_list
end

function Generals:getAllGeneralCanTrain()
    local data_list = {}
    for _, item in pairs(self._allGeneralsInfo.generals_map) do
        local lvl = StaticData['game_config']['InitReincarnationLvl'] + StaticData['game_config']['AddLvlReincarnation'] * item.reincarnation_tims
        if item.train_time <= 0 and item.lvl < lvl and item.lvl < uq.cache.role:level() then
            table.insert(data_list, item)
        end
    end
    return data_list
end

function Generals:getDefaultTrainTimeType()
    for i=1, 10 do
        if StaticData['types'].TrainingTime[1].Type[i] then
            return i
        end
    end
end

function Generals:getTrainTimeType(id)
    return StaticData['types'].TrainingTime[1].Type[id]
end

function Generals:getDefaultTrainIntensityType()
    for i=1, 10 do
        if StaticData['types'].TrainingIntensity[1].Type[i] then
            return i
        end
    end
end

function Generals:getTrainIntensityType(id)
    return StaticData['types'].TrainingIntensity[1].Type[id]
end

function Generals:_onAddTrainSoltRes(msg)
    uq.cache.role:setTrainNums(msg.data.nums)
    uq.fadeInfo(StaticData["local_text"]["general.add.solt.des"])
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_GENERALINFO})
end

function Generals:_onOverGeneralTrain(msg)
    uq.log('_onOverGeneralTrain', msg)
end

function Generals:_updateSuddenFlight(msg)
    local data = msg.data
    local info = self._allGeneralsInfo.generals_map[data.genaral_id]
    if not info then
        return
    end
    local pre_lvl = info.lvl
    self._allGeneralsInfo.generals_map[msg.data.genaral_id].lvl = msg.data.level
    self:_onGeneralLevelUpdate(data)
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_GENERAL_LEVEL, data = {pre_lvl = pre_lvl, general_id = data.genaral_id}})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_GENERALS_MODULE_RED, data = {self._GENERAL_SUB_PAGE.GENERAL_ATTRIBUTE, self._GENERAL_SUB_PAGE.GENERAL_ARMS, self._GENERAL_SUB_PAGE.GENERAL_QUALITY}})
    if uq.cache.formation:checkGeneralIsInDefaultFormation(data.genaral_id) then
        services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_ALL_GENERAL_RED})
    end
end

function Generals:dealGeneralPoolRedTimer()
    local has_free = false
    for k, v in pairs(self._GeneralPoolInfo) do
        if v.xml.freeCD ~= 0 and (v.cd_time <= 0 or v.time - os.time() < 0) then
            has_free =  true
        end
    end
    if has_free then
        services:dispatchEvent({name = services.EVENT_NAMES.ON_BUILD_OFFICER_REFRESH})
        uq.TimerProxy:removeTimer("update_timer_free" .. tostring(self))
    end
end

function Generals:_loadGeneralPoolInfo(msg)
    self._GeneralPoolInfo = {}
    local data = msg.data
    for k, v in pairs(data.items) do
        local xml_data = StaticData['general_appoint']['GeneralAppoint'][v.id]
        if xml_data then
            v.open_time = uq.getTimeStampByDaily(xml_data.openTime)
            v.close_time = uq.getTimeStampByDaily(xml_data.closeTime)
            v.time = v.cd_time > 0 and v.cd_time + os.time() or 0
            v.xml = xml_data
            table.insert(self._GeneralPoolInfo, v)
        end
    end
    self:readGeneralPoolRedFile()
    uq.TimerProxy:removeTimer("update_timer_free" .. tostring(self))
    uq.TimerProxy:addTimer("update_timer_free" .. tostring(self), handler(self, self.dealGeneralPoolRedTimer), 1, -1)
end

function Generals:_onAppointGeneral(msg)
    local data = msg.data
    local pool_key = nil
    for k, v in pairs(self._GeneralPoolInfo) do
        if v.id == data.pool_id then
            pool_key = k
            break
        end
    end
    if pool_key == nil then
        return
    end
    self._GeneralPoolInfo[pool_key].secure = data.secure
    self._GeneralPoolInfo[pool_key].cd_time = data.cd_time
    self._GeneralPoolInfo[pool_key].time = data.cd_time > 0 and data.cd_time + os.time() or 0
    data.pool_key = pool_key
    services:dispatchEvent({name = services.EVENT_NAMES.ON_GENERAL_EXTRACT_RESULT, data = data})
    uq.TimerProxy:removeTimer("update_timer_free" .. tostring(self))
    uq.TimerProxy:addTimer("update_timer_free" .. tostring(self), handler(self, self.dealGeneralPoolRedTimer), 1, -1)
    services:dispatchEvent({name = services.EVENT_NAMES.ON_GENERAL_POOL_RED_REFRESH})
end

function Generals:_onAppointGeneralChange(msg)
    local data = msg.data
    for i = 1, data.count do
        local xml_data = StaticData['general_appoint']['GeneralAppoint'][data.items[i].id]
        if xml_data then
            local pool_data = {}
            pool_data.id = data.items[i].id
            pool_data.duration = data.items[i].end_time
            pool_data.xml = xml_data
            table.insert(self._GeneralPoolInfo, pool_data)
            table.insert(self._newGenerelPools, pool_data)
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_GENERAL_POOL_CHANGE, data = data})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_BUILD_OFFICER_REFRESH})
end

function Generals:showNewGeneralsPoolOpen()
    if not self._newGenerelPools or next(self._newGenerelPools) == nil then
        return
    end
    local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.GENERAL_UNLOCKED_VIEW)
    if panel then
        return
    end
    local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.RECRUIT_SUCCESS)
    if panel then
        return
    end
    local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.GENERAL_POOL_OPEN)
    if panel then
        return
    end
    local data = table.remove(self._newGenerelPools, 1)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.GENERAL_POOL_OPEN, {zOrder = uq.ModuleManager.SPECIAL_ZORDER.TIP_ZORDER - 20, moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE , data = data})
end

function Generals:GetGeneralPoolInfo()
    return self._GeneralPoolInfo
end

function Generals:readGeneralPoolRedFile()
    local json = require("json")

    local file_instance = cc.FileUtils:getInstance()
    local find_path = file_instance:getWritablePath() .. "redInfo"
    file_instance:addSearchPath(find_path)

    local file_name = 'generalPoolInfoDt.json'
    local full_path = find_path .. "/" .. file_name
    local isExist = file_instance:isFileExist(file_name)

    if isExist then
        --读取文件
        local read_file = io.readfile(full_path)
        self._generelPoolsRedInfo = json.decode(read_file)
        self:clearGeneralPoolRedInfoByDuration()
    else
        --创建文件
        cc.FileUtils:getInstance():createDirectory(find_path)
    end
end

function Generals:writeGeneralPoolRedFile()
    local full_path = cc.FileUtils:getInstance():getWritablePath() .. 'redInfo/generalPoolInfoDt.json'

    local wirtjson = json.encode(self._generelPoolsRedInfo)
    local open_file = io.writefile(full_path, wirtjson, "w")
end

function Generals:isHasGeneralPoolRed()
    for k, v in pairs(self._GeneralPoolInfo) do
        --是否有新奖池
        if not self:isInGenerelPoolsRedInfo(v.id, v.duration) then
            return true
        end
        --是否有免费
        if v.xml.freeCD ~= 0 and (v.cd_time <= 0 or v.time - os.time() < 0) then
            return true
        end
    end
    return false
end

function Generals:isGenerelPoolFree(pool_id, duration)
    local has_free = false
    for k, v in pairs(self._GeneralPoolInfo) do
        if v.xml.freeCD ~= 0 and (v.cd_time <= 0 or v.time - os.time() < 0) and v.id == pool_id and v.duration == duration then
            has_free =  true
        end
    end
    return has_free
end

function Generals:isInGenerelPoolsRedInfo(pool_id, duration)
    if not self._generelPoolsRedInfo then
        return false
    end
    for k, v in pairs(self._generelPoolsRedInfo) do
        if v.id == pool_id and v.duration == duration and v.role_id == uq.cache.role.id then
            return true
        end
    end
    return false
end

function Generals:addGeneralPoolRedInfo(data)
    if not data then
        return
    end
    self._generelPoolsRedInfo = self._generelPoolsRedInfo or {}
    local info = {}
    info.role_id = uq.cache.role.id
    info.id = data.id
    info.duration = data.duration
    for k, v in pairs(self._generelPoolsRedInfo) do
        if v.id == info.id and v.duration == info.duration and v.role_id == uq.cache.role.id then
            return
        end
    end
    table.insert(self._generelPoolsRedInfo, info)
end

function Generals:clearGeneralPoolRedInfoByDuration()
    self._generelPoolsRedInfo = self._generelPoolsRedInfo or {}
    local tmp_red_info = {}
    for k, v in pairs(self._generelPoolsRedInfo) do
        local server_time = uq.cache.server_data:getServerTime()
        local left_time = v.duration == 0 and v.duration or (v.duration - server_time)
        if v.duration == -1 or left_time > 0 then
            table.insert(tmp_red_info, v)
        end
    end
    self._generelPoolsRedInfo = tmp_red_info
end

function Generals:setRepeatSuddenFly(flag)
    self._repeatSuddenFly = flag
end

function Generals:getRepeatSuddenFly()
    return self._repeatSuddenFly
end

function Generals:getIsSuddenFlySuccess()
    return self._isSuddenFlySuccess
end

function Generals:setIsSuddenFlySuccess(flag)
    self._isSuddenFlySuccess = flag
end

function Generals:checkGeneralByGuideId(id) --根据generals内的newIdent 来判断是否用有改武将
    for k,v in pairs(self._upGeneralsInfo) do
        if math.floor(v.temp_id / 10) == id then
            return true
        end
    end
    return false
end

function Generals:getGeneralDataXML(temp_id)
    return StaticData['general'][temp_id]
end

function Generals:_onRecruitGeneral(msg)
    local view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.GENERALS_MODULE)
    if view then
        view:disposeSelf()
    end
    uq.playSoundByID(44)
    network:sendPacket(Protocol.C_2_S_ALLGENERAL_INFO, {})
    network:sendPacket(Protocol.C_2_S_GETRECRUIT_GENERAL_IDS, {})
end

function Generals:_onDissmissGeneral(msg)
    local view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.GENERALS_MODULE)
    if view then
        view:disposeSelf()
    end
    uq.playSoundByID(45)
    network:sendPacket(Protocol.C_2_S_ALLGENERAL_INFO, {})
    network:sendPacket(Protocol.C_2_S_GETRECRUIT_GENERAL_IDS, {})
end

function Generals:updateCollectPage()
    local view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.COLLECT_MODULE)
    if view then
        view:infoRetRefresh()
    end
end

function Generals:_onAddGeneralTrain(msg)
    uq.playSoundByID(48)
    local config = self:getTrainTimeType(self._curTrainTimeType)
    self._allGeneralsInfo.generals_map[msg.data.general_id].train_time = config.value * 60 + os.time()
    self._allGeneralsInfo.generals_map[msg.data.general_id].train_time_type = self._curTrainTimeType
    self._allGeneralsInfo.generals_map[msg.data.general_id].train_type = self._curTrainIntensityType
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_GENERALINFO})
end

function Generals:_onOverGeneralTrain(msg)
    self._allGeneralsInfo.generals_map[msg.data.genaral_id].train_time = -1
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_GENERALINFO})
end

function Generals:setGeneralExp(id, add_exp)
    self._allGeneralsInfo.generals_map[id].current_exp = self._allGeneralsInfo.generals_map[id].current_exp + add_exp
end

function Generals:_onAddGeneralNum(msg)
    uq.cache.role.generalnums_max = msg.data.generalNums

    local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.COLLECT_MODULE)
    if panel then
        panel:setLimitNum()
    end
end

function Generals:getAllGeneralNum()
    return #self._upGeneralsInfo + #self._xmlGeneralsInfo
end

function Generals:getAllGeneralNumByType(general_id)
    if self:getGeneralDataByID(general_id) then
        return #self._upGeneralsInfo
    else
        return #self._xmlGeneralsInfo
    end
end

function Generals:getUnLockGeneral()
    return self._unlockGeneral
end

function Generals:_onReincarnation(msg)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.GENERAL_REIN_STATE, {info = self._allGeneralsInfo.generals_map[msg.data.genaral_id], type = true})
    self._allGeneralsInfo.generals_map[msg.data.genaral_id].reincarnation_tims = msg.data.reincarnation_nums
    self._allGeneralsInfo.generals_map[msg.data.genaral_id].lvl = 1
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_GENERALINFO, genaral_id = msg.data.genaral_id})
    self:_onGeneralLevelUpdate(msg)
end

function Generals:getSuddenFlyCostByTime(time)
    for i = #StaticData['constant'][1].Data, 1, -1 do
        if time + 1 >= StaticData['constant'][1].Data[i].times then
            local cost_str = StaticData['constant'][1].Data[i].cost
            local value_array = StaticData.splitString(cost_str, ";")
            if #value_array > 2 then
                return tonumber(value_array[2])
            end
            return 0
        end
    end
end

function Generals:getExtraQualityEquipAtt(info)
    local info = info or {}
    if next(info) == nil or not info.advanceInfo then
        return {}
    end
    local tab = {}
    for i = 1, 6 do
        if info.advanceInfo[i] and tonumber(info.advanceInfo[i]) ~= 0 then
            local prop_id = self:getPropIdByPos(info.advanceLevel, i)
            local info_prop = self:getPropInfoById(prop_id)
            for k, v in pairs(info_prop) do
                if not tab[k] then
                    tab[k] = 0
                end
                tab[k] = tab[k] + v
            end
        end
    end
    return tab
end

function Generals:getPropIdByPos(quality, index)
    local consume = StaticData['advance_levels'][quality].consume
    local tab_list = string.split(consume, ',') or {}
    return tab_list[index] and tonumber(tab_list[index]) or 0
end

function Generals:getPropInfoById(id)
    local prop_tab = StaticData['advance_data'][id] or {}
    if not prop_tab or next(prop_tab) == nil then
        return {}
    end
    local tab = {}
    local tab_str = string.split(prop_tab.effect, ";")
    for i, v in ipairs(tab_str) do
        local tab_att = string.split(v, ",")
        if tab_att and next(tab_att) ~= nil then
            tab[tonumber(tab_att[1])] = tonumber(tab_att[2])
        end
    end
    return tab
end

function Generals:isGeneralUp(id)
    for k, v in pairs(self._upGeneralsInfo) do
        if v.id == id then
            return true
        end
    end
    return false
end

function Generals:clearNewGenerals()
    self._showGenerels = {}
end

function Generals:addNewGenerals(info)
    table.insert(self._showGenerels, info)
end

function Generals:isNeetShowGenerals()
    return #self._showGenerels >= 1
end

function Generals:getFristGeneralsAddRemove()
    return table.remove(self._showGenerels, 1) or 0
end

function Generals:setNewGeneralsFunc(general_id, func, is_stop_continue)
    if not self._showGenerels then
        return
    end

    for i = 1, #self._showGenerels do
        if self._showGenerels[i].info == general_id then
            self._showGenerels[i].func = func
            self._showGenerels[i].is_stop_continue = is_stop_continue
            if i ~= 1 then
                local item = self._showGenerels[i]
                table.remove(self._showGenerels, i)
                table.insert(self._showGenerels, 1, item)
            end
            break
        end
    end
end

function Generals:getGeneralsModuleRedByIndex(index, id)
    if not id or not self._allGeneralsInfo.generals_map[id] then
        return false
    end
    index = index or 1
    if index == 1 then
        return self:isCanLevelUp(id)
    elseif index == 2 then
        return self:isCanOperateEquip(id)
    elseif index == 3 then
        return self:isCanAdvance(id)
    elseif index == 4 then
        return self:isQulityRedById(id)
    else
        return self:isCouldInsightById(id)
    end
end

function Generals:isCanLevelUp(general_id)
    local is_red = false
    local general_info = uq.cache.generals:getGeneralDataByID(general_id)
    local one_to_exp = StaticData["general_level"].Info[1].onetoExp
    local total_exp = StaticData['general_level']['GeneralLevel'][general_info.lvl].exp
    return general_info.lvl < uq.cache.role.master_lvl and uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GESTE, math.ceil(total_exp / one_to_exp))
end

function Generals:isCanAdvance(general_id)
    local general_info = uq.cache.generals:getGeneralDataByID(general_id)
    local soldier_xml1 = StaticData['soldier'][general_info.soldierId1]
    if not soldier_xml1 then
        return false
    end
    local soldier_transfer = StaticData['soldier_transfer'][soldier_xml1.level + 1]
    if not soldier_transfer then
        return false
    end
    local is_red = true
    if soldier_transfer.cost ~= "" then
        local reward_items = uq.RewardType.parseRewards(soldier_transfer.cost)
        local cost_array = string.split(soldier_transfer.cost, "|")
        for k, item in ipairs(reward_items) do
            local info = item:toEquipWidget()
            if not uq.cache.role:checkRes(info.type, info.num, info.id) then
                return false
            end
        end
    end

    if soldier_transfer.level > 0 and soldier_transfer.level > general_info.lvl then
        return false
    end

    if soldier_transfer.towerFloor > 0 then
        local info = uq.cache.trials_tower:getCurTowerInfo()
        if not info or info.ident < soldier_transfer.towerFloor then
            return false
        end
    end

    return true
end

function Generals:isCanOperateEquip(general_id)
    local general_info = self._allGeneralsInfo.generals_map[general_id]
    if not general_info then
        return false
    end
    local general_equips = uq.cache.equipment:getInfoByGeneralId(general_id)
    local arr_suit = uq.cache.equipment:getGeneralsSuitId(general_id)
    for i = 1, 7 do
        local info = uq.cache.equipment:getInfoByTypeAndGeneralId(i, general_id)
        if info then
            local rising_state = uq.cache.equipment:judgeCouldRisingByEquipDBId(info.db_id)
            if rising_state then
                return true
            end

            if info.xml.suitId then
                arr_suit[info.xml.suitId] = arr_suit[info.xml.suitId] - 1
            end

            local max_info = uq.cache.equipment:getChangeEquipInfo(info.xml.type, general_info.lvl, arr_suit)
            local change_state = max_info ~= nil and max_info.xml.effectValue > info.xml.effectValue
            if change_state then
                return true
            end

            if info.xml.suitId then
                arr_suit[info.xml.suitId] = arr_suit[info.xml.suitId] + 1
            end
            local lvl_state = info.lvl < uq.cache.role.master_lvl
            local xml_cost = StaticData['item_level'][info.lvl].cost
            local cost_array = uq.RewardType.parseRewards(xml_cost)
            local cost_state = true
            for k, v in ipairs(cost_array) do
                local cost_info = v:toEquipWidget()
                if cost_info.num > 0 and not uq.cache.role:checkRes(cost_info.type, cost_info.num, cost_info.id) then
                    cost_state = false
                    break
                end
            end
            if cost_state and lvl_state then
                return true
            end
        else
            local state = uq.cache.equipment:couldAddEquipment(i, general_info.lvl)
            if state then
                return true
            end
        end
    end
    return false
end

--单个武将判断
function Generals:isQulityRedById(id)
    local general_info = uq.cache.generals:getGeneralDataByID(id)
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
        if not uq.cache.role:checkRes(tab.type, num, tab.id) then
            return false
        end
        use_num[tab.id] = num
    end
    return true
end

function Generals:isCouldInsightById(id)
    local info = self._allGeneralsInfo.generals_map[id]
    if not info then
        return false
    end
    local generals_xml = StaticData['general'][info.temp_id]
    if generals_xml.evolutionCost == "" then
        return false
    end
    local cost_array = string.split(generals_xml.evolutionCost, "|")
    for k, v in pairs(cost_array) do
        local info = string.split(v, ";")
        if not uq.cache.role:checkRes(tonumber(info[1]), tonumber(info[2]), tonumber(info[3])) then
            return false
        end
    end
    return true
end

function Generals:getAttAllValue(id, equip_id, db_id, att_vale)
    if db_id ~= nil or equip_id == 0 then
        return att_vale
    end
    local cur_item_xml = StaticData['items'][id] or {}
    local pre_equip_info = uq.cache.equipment:_getEquipInfoByDBId(equip_id)
    if not pre_equip_info then
        return 0
    end
    local pre_item_xml = StaticData['items'][pre_equip_info.temp_id] or {}
    if not pre_item_xml or next(pre_item_xml) == nil then
        return 0
    end
    local cost1 = 0
    local items_level = StaticData['item_level'] or {}
    for _, v in ipairs(items_level) do
        if v.ident < pre_equip_info.lvl then
            local cost_array = string.split(v.cost, "|")
            local info_array = string.split(cost_array[1], ";")
            cost1 = cost1 + tonumber(info_array[2])
        end
    end
    cost1 = math.floor(cost1 * 0.8 * pre_item_xml.intensifyEffect)
    local level = 1
    for _, v in ipairs(items_level) do
        local cost_array = string.split(v.cost, "|")
        local info_array = string.split(cost_array[1], ";")
        if cost1 >= math.floor(tonumber(info_array[2]) * cur_item_xml.intensifyEffect) then
            level = level + 1
            cost1 = cost1 - math.floor(tonumber(info_array[2]) * cur_item_xml.intensifyEffect)
        else
            break
        end
    end
    local base_num = cur_item_xml.effectValue
    local base_solider_num = 0
    for _, k in ipairs(cur_item_xml.SubEffect) do
        if k.type == 7 then
            base_solider_num = k.value + k.increase * (level - 1)
            break
        end
    end
    local tab_intensify = StaticData['intensify'] or {}
    for _, k in ipairs(tab_intensify) do
        if k.itemType == cur_item_xml.type and k.qualityType == cur_item_xml.qualityType then
            base_num = base_num + k.increase * (level - 1)
            break
        end
    end
    return base_num
end

function Generals:updateComposeRed()
    local is_red = false
    for k, v in pairs(self._xmlGeneralsInfo) do
        if uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.SPIRIT, v.compose_nums, v.id) then
            is_red = true
            break
        end
    end
    uq.cache.hint_status.status[uq.cache.hint_status.RED_TYPE.GENERALS_COMPOSE] = is_red
    --self:updateRed()
    --services:dispatchEvent({name = services.EVENT_NAMES.ON_GENERALS_COMPOSE_RED})
    return is_red
end

function Generals:isComposeRedById(id)
    local is_red = false
    for k, v in pairs(self._xmlGeneralsInfo) do
        if v.id == id then
            is_red = uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.SPIRIT, v.compose_nums, v.id)
            return is_red
        end
    end
    return is_red
end

function Generals:updataQualityRed()
    local is_red = false
    local general_id = 0
    local up_list = uq.cache.generals:getUpGeneralsByType(0)
    local foramtion_array = {}
    for k, v in ipairs(up_list) do
        if uq.cache.formation:checkGeneralIsInFormationById(v.id) then
            table.insert(foramtion_array, v)
        else
            break
        end
    end
    for k, v in ipairs(foramtion_array) do
        is_red = self:isQulityRedById(v.id)
        general_id = v.id
        if is_red then
            break
        end
    end
    uq.cache.hint_status.status[uq.cache.hint_status.RED_TYPE.GENERALS_QUALITY] = is_red
    return is_red, general_id
end

function Generals:updateRed(msg)
    local array = (msg and msg.array) and msg.array or {1, 2, 3, 4, 5}
    local is_red = uq.cache.hint_status.status[uq.cache.hint_status.RED_TYPE.GENERALS_COMPOSE]
    if not is_red then
        is_red = uq.cache.hint_status.status[uq.cache.hint_status.RED_TYPE.MAP_GUIDE]
    end
    if not is_red then
        local general_info = uq.cache.formation:getDefaultFormation()
        if general_info.general_loc then
            for k, v in pairs(general_info.general_loc) do
                for _, index in pairs(array) do
                    is_red = self:getGeneralsModuleRedByIndex(index, v.general_id)
                    if is_red then
                        break
                    end
                end
                if is_red then
                    break
                end
            end
        end
    end
    uq.cache.hint_status.status[uq.cache.hint_status.RED_TYPE.MAIN_CITY_GENERALS] = is_red
    services:dispatchEvent({name = services.EVENT_NAMES.ON_MAIN_CITY_BOTTOM_SIDE_RED_CHANGES, data = uq.cache.hint_status.RED_TYPE.MAIN_CITY_GENERALS})
end

function Generals:getGeneralInternalData(id, property_type)
    if self._allGeneralsInfo.generals_map[id] then
        local internal_data = self._allGeneralsInfo.generals_map[id].internal_attr[property_type]
        return internal_data
    else
        return {level = 1, exp = 0, attr = 0}
    end
end

function Generals:getGeneralTire(id)
    return self._allGeneralsInfo.generals_map[id].tired
end

function Generals:getGeneralTireModeData(general_id)
    local tire = self:getGeneralTire(general_id)
    local xml_data = StaticData['officer_level'].Mood

    for k, item in ipairs(xml_data) do
        if tire <= item.tired then
            return item
        end
    end
    return nil
end

--获取武将总加成
function Generals:getGeneralBuildOfficerPropertyAdd(general_id, init)
    local values = {}
    for index = 1, 7 do
        local internal_data = self:getGeneralInternalData(general_id, index)
        local level = internal_data.level
        if init then
            level = 1
        end
        local rate = internal_data.attr / 20
        local value = internal_data.attr + (level - 1) * rate
        values[index] = {math.ceil(value), rate}
    end
    return values
end

function Generals:getGeneralBuildOfficerLevelAdd(genaral_id)
    local id = genaral_id
    local values = {}
    for i = 1, 7 do
        local internal_data = self:getGeneralInternalData(id, i)
        values[i] = {internal_data.level, internal_data.exp}
    end
    return values
end

function Generals:getTireCdTime(general_id, rework_tire)
    local reword_tire = StaticData['officer_level'].Info[1].reWorkTired
    local reduce_tire = StaticData['officer_level'].Info[1].reduceTired
    local tire = self:getGeneralTire(general_id)
    local off_tire = tire - rework_tire
    if off_tire <= 0 then
        return 0
    end
    --50=最近的10分钟的差值+（50-5-reWorkTired）/reduceTired*10
    local cur_min = tonumber(os.date("%M", uq.curServerSecond()))
    local next_ten = (math.floor(cur_min / 10) + 1) * 10
    local off_min = next_ten - cur_min

    return math.ceil(off_min + (off_tire - reduce_tire) / reduce_tire * 10) * 60
end

function Generals:isGeneralProcesing(genaral_id)
    --任务中
    if uq.cache.role:getGeneralBuildOffcerType(genaral_id) then
        return true
    end
    return false
end

function Generals:getBuildOfficeSelect(build_type)
    local select_list = {}
    local all_list = uq.cache.generals:getUpGeneralsByType()
    for k, item in ipairs(all_list) do
        local office_build_type = uq.cache.role:getGeneralBuildOffcerType(item.id)
        if not office_build_type or office_build_type == build_type then
            table.insert(select_list, item)
        end
    end
    return select_list
end

function Generals:onUpdateGeneralInternal(evt)
    for k, item in ipairs(evt.data.general) do
        for i = 1, #self._allGeneralsInfo.generals_map[item.general_id].internal_attr do
            self._allGeneralsInfo.generals_map[item.general_id].internal_attr[i].level = item.internal_attr[i].level
            self._allGeneralsInfo.generals_map[item.general_id].internal_attr[i].exp = item.internal_attr[i].exp
        end
        self._allGeneralsInfo.generals_map[item.general_id].tired = item.tired
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_BUILD_OFFICER_REFRESH})
end

--武将疲劳值清除成功
function Generals:onClearTired(evt)
    uq.fadeInfo(StaticData['local_text']['label.buildofficer.success'])
    self._allGeneralsInfo.generals_map[evt.data.general_id].tired = evt.data.tired
    services:dispatchEvent({name = services.EVENT_NAMES.ON_BUILD_OFFICER_REFRESH})
end

function Generals:getNpcDataByLevel(lvl)
    local data = StaticData['npc_level_soldier']
    return data[lvl]
end

--获取武将征兵队列
function Generals:getGeneralArmyList()
    local data_list = {}
    for k, item in pairs(self._allGeneralsInfo.generals_map) do
        if item.current_soldiers < item.max_soldiers then
            table.insert(data_list, item)
        end
    end
    self:sortGenerals(data_list)
    return data_list
end

function Generals:onUpdateArmy(evt)
    for k, item in ipairs(evt.data.general) do
        if self._allGeneralsInfo.generals_map[item.general_id] then
            local off_soldier = item.cur_soldiernum - self._allGeneralsInfo.generals_map[item.general_id].current_soldiers
            self._allGeneralsInfo.generals_map[item.general_id].current_soldiers = item.cur_soldiernum
            local general_data = self._allGeneralsInfo.generals_map[item.general_id]
            if general_data.current_soldiers >= general_data.max_soldiers and off_soldier > 0 then
                uq.cache.chat:addChat({
                    msg_type = uq.config.constant.TYPE_CHAT_CHANNEL.CC_SYSTEM,
                    content = general_data.name ..  StaticData['local_text']['label.draft.finish'] .. '。',
                    create_time = uq.curServerSecond()
                })
            end
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ARMY_REFRESH})
end

function Generals:onDraftSpeed(evt)
    self._allGeneralsInfo.generals_map[evt.data.general_id].current_soldiers = self._allGeneralsInfo.generals_map[evt.data.general_id].current_soldiers + evt.data.speed_num
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ARMY_REFRESH})

    local general_data = self._allGeneralsInfo.generals_map[evt.data.general_id]
    if general_data.current_soldiers >= general_data.max_soldiers then
        uq.cache.chat:addChat({
            msg_type = uq.config.constant.TYPE_CHAT_CHANNEL.CC_SYSTEM,
            content = general_data.name ..  StaticData['local_text']['label.draft.finish'] .. '。',
            create_time = uq.curServerSecond()
        })
    end
end

return Generals