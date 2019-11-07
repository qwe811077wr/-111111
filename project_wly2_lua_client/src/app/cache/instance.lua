local Instance = class("Instance")

function Instance:ctor()
    self._instanceData = {}
    self._jumpToChapter = nil
    self._oldMaxNpcId = 0
    self._newInstanceRet = 0
    self._openSoldierInfo = true
    self._instanceReward = {}
    self._speed = 1

    network:addEventListener(Protocol.S_2_C_ADD_NEW_INSTANCE, handler(self, self._onNewInstance))
    network:addEventListener(Protocol.S_2_C_INSTANCE_LIST, handler(self, self._onInstanceList))
    network:addEventListener(Protocol.S_2_C_INSTANCE_INFO, handler(self, self._onInstanceInfo))
    network:addEventListener(Protocol.S_2_C_INSTANCE_PASS_CHAPTER, handler(self, self._onPassChapter))
    network:addEventListener(Protocol.S_2_C_INSTANCE_SWEEP, handler(self, self._onSweepRes))
    network:addEventListener(Protocol.S_2_C_INSTANCE_DRAW, handler(self, self.onInstanceRewardRet))
end

function Instance:getInstanceInfo(id)
    return self._instanceData[id]
end

function Instance:openSweep(instance_id, id)
    local pre_data = uq.cache.instance:getNPC(instance_id, id)
    if not pre_data.star or pre_data.star < 3 then
        uq.fadeInfo(StaticData['local_text']['instance.not.sweep'])
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.NPC_INFO_MODULE, {instance_id = instance_id, npc_id = id, is_sweep = true})
end

function Instance:checkNewInstance()
    if self._newInstanceRet > 0 then
        uq.fadeInfo(string.format(StaticData['local_text']['label.achieve.limit'], self._newInstanceRet))
        self._newInstanceRet = 0
    end
end

function Instance:_onNewInstance(msg)
    self._newInstanceRet = msg.data.ret
    if msg.data.ret ~= 0 then
        return
    end

    for k, instance_id in pairs(msg.data.instance_id) do
        self._instanceData[instance_id] = {}

        local map_xml = self:getNPCXml(instance_id)
        if map_xml then
            for k, item in pairs(map_xml) do
                self._instanceData[instance_id][k] = {}
                self._instanceData[instance_id][k].star = 0
                self._instanceData[instance_id][k].atk_num = 0
            end
        end
    end
end

function Instance:_onInstanceList(msg)
    for k, instance_id in pairs(msg.data.ids) do
        if not self._instanceData[instance_id] then
            self._instanceData[instance_id] = {}
        end
        local map_xml = self:getNPCXml(instance_id)
        if map_xml then
            for k, item in pairs(map_xml) do
                if not self._instanceData[instance_id][k] then
                    self._instanceData[instance_id][k] = {}
                end
                self._instanceData[instance_id][k].star = self._instanceData[instance_id][k].star or 0
                self._instanceData[instance_id][k].atk_num = 0
            end
        end
    end
    uq.cache.role:setCurInstance(msg.data.cur_instance)
    network:sendPacket(Protocol.C_2_S_ENTER_INSTANCE, {instance_id = self:getMaxIntanceID()})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_TASK_UPDATE_RED})
end

function Instance:_onSweepRes(msg)
    local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.SINGLE_BATTLE_MODULE)
    if panel then
        return
    end
    local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.INSIGHT_RES_FROM_MODULE)
    if panel then
        local tab = panel:getItemsInfo() or {}
        msg.data.info_items = tab
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.NPC_SWEEP_MODULE, msg.data)
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CLOSE_NPC_INFO})
    self:decNpcAtkNum(msg.data.instance_id, msg.data.npc_id)
end

function Instance:getMaxIntanceID()
    local max_id = uq.cache.role:getCurInstance()

    for k, item in pairs(self._instanceData) do
        if k > max_id then
            max_id = k
        end
    end

    return max_id
end

function Instance:isInNpcListNotFullStar(npc_info, npc_config, instance_id)
    if npc_config.qtyLimit == 0 then
        if npc_info.star and npc_info.star > 0 then
        else
            local pre_id = npc_config.premiseObjectId
            if pre_id > 0 then
                local pre_data = self:getNPC(instance_id, pre_id)
                if not pre_data.star or pre_data.star <= 0 then
                else
                    return true
                end
            else
                if not npc_info.star or npc_info.star == 0 then
                    return true
                end
            end
        end
    else
        local pre_id = npc_config.premiseObjectId
        local pre_data = self:getNPC(instance_id, pre_id)
        if pre_id > 0 then
            if not pre_data.star or pre_data.star <= 0 then
            else
                return true

            end
        end
    end
    return false
end

function Instance:_onInstanceInfo(evt)
    if not self._instanceData[evt.data.instance_id] then
        self._instanceData[evt.data.instance_id] = {}
    end

    for _, item in pairs(evt.data.npcs) do
        self._instanceData[evt.data.instance_id][item.id] = item
    end

    local instance_xml = StaticData['instance'][evt.data.instance_id]
    local instance_name = instance_xml.fileId
    local map_xml = self:getNPCXml(evt.data.instance_id)

    for k, item in pairs(map_xml) do
        if not self._instanceData[evt.data.instance_id][k] then
            self._instanceData[evt.data.instance_id][k] = {}
        end
    end

    if self._oldMaxNpcId == 0 then
        self:setOldMaxNpcId()
    end

    services:dispatchEvent({name = services.EVENT_NAMES.ENTER_INSTANCE})
end

function Instance:getNPC(instance_id, npc_id)
    local npcs = self._instanceData[instance_id] or {}
    return npcs[npc_id] or {}
end

function Instance:getNPCXml(instance_id, npc_id)
    local instance_temp = StaticData['instance'][instance_id]

    local file_name = instance_temp.fileId

    if npc_id then
        return StaticData.load('instance/' .. file_name).Map[instance_id].Object[npc_id]
    else
        return StaticData.load('instance/' .. file_name).Map[instance_id].Object
    end
end

function Instance:decNpcAtkNum(instance_id, npc_id)
    if not self._instanceData[instance_id][npc_id].atk_num then
        self._instanceData[instance_id][npc_id].atk_num = 0
    end
    self._instanceData[instance_id][npc_id].atk_num = self._instanceData[instance_id][npc_id].atk_num + 1
end

function Instance:_onPassChapter(evt)
    for _, v in pairs(evt.data.chapters) do
        for _, iv in pairs(v.npcs) do
            if not self._instanceData[v.id] then
                self._instanceData[v.id] = {}
            end
            if not self._instanceData[v.id][iv.id] then
                self._instanceData[v.id][iv.id] = {}
            end
            self._instanceData[v.id][iv.id].star = iv.rate
        end
        for k, item in ipairs(v.reward_ids) do
            self._instanceReward[item] = 1
        end
    end
end

function Instance:getMaxNpcID()
    local instance_data = self._instanceData[self:getMaxIntanceID()]
    local npc_id = self:getMaxIntanceID() * 100
    for k, item in pairs(instance_data) do
        if type(item) == 'table' and item.star > 0 and k > npc_id then
            npc_id = k
        end
    end
    return npc_id
end

function Instance:isNpcPassed(npc_id)
    if npc_id == 0 then
        return true
    end
    if next(self._instanceData) == nil then
        return false
    end
    return npc_id <= self:getMaxNpcID()
end

function Instance:setOldMaxNpcId()
    self._oldMaxNpcId = self:getLastNpcID()
end

function Instance:isRefrshOldMaxNpcId()
    return self._oldMaxNpcId == self:getLastNpcID()
end

function Instance:getLastNpcID()
    local npc_id = self:getMaxNpcID()
    if npc_id ~= 0 then
        return npc_id
    end

    local id = 0
    local xml_data = StaticData['instance'][self:getMaxIntanceID()]
    if not xml_data.parent then
        return id
    end

    local instance_data = self._instanceData[xml_data.parent.ident]
    for k, item in pairs(instance_data) do
        if type(item) == 'table' and k > id then
            id = k
        end
    end
    return id
end

function Instance:getMaxPermisionData(instance_id)
    local instance_data = StaticData['instance'][instance_id]
    local next_instance_data = instance_data.next
    if not next_instance_data then
        return instance_data
    end

    while instance_data.premiselevel == next_instance_data.premiselevel do
        instance_data = next_instance_data
        next_instance_data = instance_data.next
        if not next_instance_data then
            break
        end
    end

    return instance_data
end

function Instance:getChapterTotalStar(chapter_id)
    local star_num = 0
    if not self._instanceData[chapter_id] then
        return star_num
    end

    for k, item in pairs(self._instanceData[chapter_id]) do
        star_num = star_num + item.star
    end
    return star_num
end

function Instance:onInstanceRewardRet(evt)
    if evt.data.ret == 0 then
        self._instanceReward[evt.data.id] = 1
        services:dispatchEvent({name = services.EVENT_NAMES.ON_INSTANCE_REWARD_GET})

        local xml_data = StaticData['instance'][evt.data.chapter_id]
        local map_config = StaticData.load('instance/' .. xml_data.fileId)
        local reward = map_config.Map[evt.data.chapter_id].starReward[evt.data.id].reward

        uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, {rewards = reward})
    end
end

function Instance:isRewardGet(id)
    return self._instanceReward[id] == 1
end

function Instance:getChapterAllStar(chapter_id)
    local stars = 0
    local instance_data = StaticData['instance'][chapter_id]
    local map_data = StaticData.load('instance/' .. instance_data.fileId)
    for k, item in pairs(map_data.Map[chapter_id].Object) do
        stars = stars + 3
    end
    return stars
end

function Instance:getBgConfig(bg)
    local effects = {}
    for k, item in ipairs(StaticData['bg_tx']) do
        if bg == item.battleBg then
            table.insert(effects, item)
        end
    end
    return effects
end

return Instance