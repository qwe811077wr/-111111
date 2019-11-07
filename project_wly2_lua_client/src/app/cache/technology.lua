local Technology = class("Technology")

function Technology:ctor()
    self._curTechnologyInfo = {}
    self._endTime = 0
    self._upId = 0
    self._freeTime = 0
    self:initTechnologyInfo()
    network:addEventListener(Protocol.S_2_C_TECHNOLOGY_LOAD, handler(self, self._loadTechnology))
    network:addEventListener(Protocol.S_2_C_TECHNOLOGY_INTERSIFY, handler(self, self._technologyIntersify))
    network:addEventListener(Protocol.S_2_C_TECHNOLOGY_UPDATE, handler(self, self._technologyRefresh))
    network:addEventListener(Protocol.S_2_C_TECHNOLOGY_CD_END, handler(self, self._technologyEnd))
    network:addEventListener(Protocol.S_2_C_TECHNOLOGY_SPEED_UP, handler(self, self._technologySpeed))
end

function Technology:initTechnologyInfo()
    local tech_array = StaticData['tech']
    for k, v in ipairs(tech_array) do
        local item = {}
        item.xml = v
        item.need_level = v.Effect[0].strategyLevel
        item.level = v.initLevel
        item.id = v.ident
        self._curTechnologyInfo[item.xml.ident] = item
    end
    self._freeTime = StaticData['tech_info'][1].freeTime
end

function Technology:_technologyIntersify(evt)
    local data = evt.data
    self._endTime = data.cd_time + uq.curServerSecond()
    self._upId = data.id
    uq.fadeInfo(StaticData['local_text']["strategy.up.loading"])
    services:dispatchEvent({name = services.EVENT_NAMES.ON_STRATRGY_UP_REFRESH})
end

function Technology:_loadTechnology(evt)
    local data = evt.data
    for k, v in pairs(data.teches) do
        self._curTechnologyInfo[v.id].level = v.lvl
        self:setFormationLevel(v.id, v.lvl)
        if v.cd_time >= 0 then
            self._endTime = v.cd_time + uq.curServerSecond()
            self._upId = v.id
            if v.cd_time == 0 then
                network:sendPacket(Protocol.C_2_S_TECHNOLOGY_UPDATE, {id = v.id})
            end
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_STRATRGY_UP_REFRESH})
end

function Technology:_technologyRefresh(evt)
    local data = evt.data
    local is_up = data.ret == 0
    self._endTime = is_up and 0 or data.cd_time + uq.curServerSecond()
    self._upId = is_up and 0 or data.id
    if is_up and self._curTechnologyInfo[data.id] and self._curTechnologyInfo[data.id].level then
        self._curTechnologyInfo[data.id].level = self._curTechnologyInfo[data.id].level + 1
        self:setFormationLevel(data.id, self._curTechnologyInfo[data.id].level)
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_STRATRGY_UP_REFRESH})
end

function Technology:_technologyEnd(evt)
    local data = evt.data
    if data.ret ~= 0 then
        return
    end
    self._endTime = 0
    self._upId = 0
    if self._curTechnologyInfo[data.id] then
        self._curTechnologyInfo[data.id].level = data.level
        self:setFormationLevel(data.id, data.level)
    end
    uq.fadeInfo(StaticData['local_text']["strategy.up.finish"])
    uq.playSoundByID(86)
    services:dispatchEvent({name = services.EVENT_NAMES.ON_STRATRGY_UP_REFRESH})
end

function Technology:_technologySpeed(evt)
    local data = evt.data
    self._endTime = data.cd_time + uq.curServerSecond()
    uq.fadeInfo(StaticData['local_text']["strategy.finish.speed"])
    services:dispatchEvent({name = services.EVENT_NAMES.ON_STRATRGY_UP_REFRESH})
    if data.cd_time == 0 then
        network:sendPacket(Protocol.C_2_S_TECHNOLOGY_UPDATE, {id = self._upId})
    end
end

function Technology:setFormationLevel(id, level)
    if not self._curTechnologyInfo[id] or not self._curTechnologyInfo[id].xml or not self._curTechnologyInfo[id].xml.formationId
        or self._curTechnologyInfo[id].xml.formationId == 0 then
        return
    end
    uq.cache.formation:setFormationLevel(self._curTechnologyInfo[id].xml.formationId, level)
end

function Technology:getTechnologyMaxLv(data)
    local data = data or {}
    if not data or next(data) == nil then
        return 0
    end
    local num = -1
    for k, v in pairs(data.Effect) do
        num = num + 1
    end
    return num
end

function Technology:getTechnologyInfo()
    return self._curTechnologyInfo
end

function Technology:getTechnologyInfoById(id)
    return self._curTechnologyInfo[id] or {}
end

function Technology:getUpAllTime(id, lv)
    local lv = lv or self:getLevelById(id)
    if self._curTechnologyInfo[id] and self._curTechnologyInfo[id].xml.Effect[lv] then
        return self._curTechnologyInfo[id].xml.Effect[lv].time
    end
    return 0
end

function Technology:getLevelById(id)
    if self._curTechnologyInfo[id] and self._curTechnologyInfo[id].level then
        return self._curTechnologyInfo[id].level
    end
    return 0
end

function Technology:getAttAddById(id)
    local tab = self._curTechnologyInfo[id] or {}
    if tab and tab.xml and tab.xml.Effect and tab.xml.Effect[tab.level] and tab.xml.Effect[tab.level].value then
        return tab.xml.Effect[tab.level].value
    end
    return 0
end

function Technology:getStudyTimeFreeRatio()
    return self:getAttAddById(uq.config.constant.STRATRGY_TYPE.STUDY_TIME)
end

function Technology:getStudyCostFreeRatio()
    return self:getAttAddById(uq.config.constant.STRATRGY_TYPE.STUDY_COST)
end

function Technology:getBuildTimeFreeRatio()
    return self:getAttAddById(uq.config.constant.STRATRGY_TYPE.BUILD_TIME)
end

function Technology:getBuildCostFreeRatio()
    return self:getAttAddById(uq.config.constant.STRATRGY_TYPE.BUILD_COST)
end

function Technology:getStudySurplusTime(all_time)
    return math.max(all_time - math.floor(all_time * self:getStudyTimeFreeRatio()), 0)
end

function Technology:getStudySurplusCost(all_cost)
    local build_type = uq.cache.role:getBuildType(uq.config.constant.TYPE_BUILDING.STRATEGY_MANSION)
    local rate = uq.cache.role:getBuildOfficerPropertyAdd(build_type, uq.config.constant.BUILD_OFFICER_EFFECT.TYPE_LEVEL_UP_COST)
    local rate1 = self:getStudyCostFreeRatio()
    return math.ceil(math.ceil(all_cost * (1 - rate1)) * (1 - rate))
end

function Technology:getStudyCostGold(time)
    return math.max(math.ceil((time - self._freeTime) * 2.8 / 60), 0)
end

function Technology:isFullFinish()
    return self._endTime > uq.curServerSecond()
end

function Technology:getSurplusTime()
    return self._endTime - uq.curServerSecond()
end

function Technology:updataTechnologyUp()
    if self._endTime ~= uq.curServerSecond() or self._upId == 0 then
        return
    end
    network:sendPacket(Protocol.C_2_S_TECHNOLOGY_UPDATE, {id = self._upId})
end

function Technology:sendFinishMsg(id, func)
    local id = id or self._upId
    local cost_time = self:getSurplusTime()
    if not func then
        cost_time = self:getStudySurplusTime(self:getUpAllTime(id))
    end
    local cost_num = self:getStudyCostGold(cost_time)
    if not uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN, cost_num) then
        uq.fadeInfo(StaticData['local_text']["label.common.not.enough.gold"])
        return
    end
    local function sendFunc()
        if func then
            if not self:isFullFinish() then
                return
            end
            func()
        end
        network:sendPacket(Protocol.C_2_S_TECHNOLOGY_CD_END, {id = id})
    end
    if cost_num <= 0 then
        sendFunc()
        return
    end
    local data = {
        content = string.format(StaticData['local_text']['strategy.reset.tip'], '<img img/common/ui/03_0003.png>', cost_num),
        confirm_callback = sendFunc
    }
    uq.addConfirmBox(data, uq.config.constant.CONFIRM_TYPE.BUILD_SPEED_UP)
end

return Technology