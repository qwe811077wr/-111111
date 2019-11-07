local Tavern = class("Tavern")

function Tavern:ctor()
    self._tenDrinkTimes = 0
    self._taverns = {}
    --network:addEventListener(Protocol.S_2_C_APPOINT_INFO, handler(self, self._onAppointInfo))
    --network:addEventListener(Protocol.S_2_C_APPOINT_DO, handler(self, self._onAppointDo))
end

function Tavern:_onAppointInfo(msg)
    local data = msg.data
    self._taverns = data.items
    self._tenDrinkTimes = data.dailynum
end

function Tavern:_onAppointDo(msg)
    local data = msg.data
    self._tenDrinkTimes = data.dailynum
    local drink_ever = false
    for k, v in pairs(self._taverns) do
        if v.id == data.pool_id then
            v.num = data.num
            v.cd_time = data.cd_time
            drink_ever = true
        end
    end
    if not drink_ever then
        table.insert(self._taverns, {id = data.pool_id, num = data.num, cd_time = data.cd_time})
    end
    local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.TAVERN_REWARD)
    if not panel then
        panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.TAVERN_REWARD, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
        panel:setData(data)
    else
        panel:setData(data)
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_TAVERN_DO})
end
--花费.减去免费次数
function Tavern:getCostTypeAndNumById(id, is_ten)
    local tab = StaticData['appoint_item'] or {}
    if tab[id] then
        local reward_one = uq.RewardType:create(tab[id].costOne):toEquipWidget()
        local reward_ten = uq.RewardType:create(tab[id].costTen):toEquipWidget()
        if not reward_one or next(reward_one) == nil or not reward_ten or next(reward_ten) == nil then
            return nil, nil
        end
        local reward = reward_one
        if is_ten then
            reward = reward_ten
        end
        local cost_type = reward.type
        local frees = self:getFreeTimes(id)
        local cost = self:getFinalCost(frees, reward.num, is_ten, reward_one.num)
        return cost_type, cost
    end
    return nil, nil
end

function Tavern:getFinalCost(frees, cost, is_ten, one_cost)
    if is_ten then
        if frees >= 10 then
            return 0
        end
        return math.max(cost - one_cost * frees, 0)
    end
    if frees >= 1 then
        return 0
    end
    return cost
end

function Tavern:getFreeTimes(id)
    local tab = StaticData['appoint_item'] or {}
    if tab[id] and tab[id].free then
        for k, v in pairs(self._taverns) do
            if v.id == id then
                return math.max(tab[id].free - v.num, 0)
            end
        end
    end
    return 0
end

function Tavern:getAlreadyDrinkTimes(id)
    for _, v in pairs(self._taverns) do
        if v.id == id then
            return v.num
        end
    end
    return 0
end

function Tavern:sendTavernMsg(pool_id, is_ten)
    local cost_type, cost_num = self:getCostTypeAndNumById(pool_id, is_ten)
    local auto = 0
    if is_ten then
        auto = 1
    end
    if not uq.cache.role:checkRes(cost_type, cost_num) then
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.FAIL)
        uq.fadeInfo(StaticData["local_text"]["label.no.enough.res"])
        return
    end
    uq.playSoundByID(65)
    local msg_data = {
        pool_id = pool_id,
        is_ten = auto
    }
    network:sendPacket(Protocol.C_2_S_APPOINT_DO, msg_data)
end


return Tavern