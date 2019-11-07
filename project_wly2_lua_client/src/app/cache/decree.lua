local Decree = class('Decree')

function Decree:ctor()
    self._decompose = {}
    for i = 1, 7 do
        local num = i == 1 and 1 or 0
        table.insert(self._decompose, num)
    end
end

function Decree:getNumDecree()
    return uq.cache.role:getResNum(uq.config.constant.COST_RES_TYPE.RT_DECREE, 0)
end

function Decree:getDecompose()
    return self._decompose
end

function Decree:isOperatorDecree()
    return self:getNumDecree() > 0 and uq.jumpToModule(uq.config.constant.MODULE_ID.RT_DECREE, nil, true)
end

function Decree:getDecreeReWard(id)
    local xml = StaticData['government'].Government or {}
    if not xml[id] or next(xml[id]) == nil then
        return {}
    end
    local xml_info = xml[id] or {}
    local xml_object = xml_info.Object or {}
    local tab_reward = {}
    for k, v in pairs(uq.cache.role.buildings) do
        if v.type == xml_info.type and xml_object[v.level] and xml_object[v.level].reward then
            local item_list = uq.RewardType.parseRewards(xml_object[v.level].reward)
            for i, v in ipairs(item_list) do
                table.insert(tab_reward, v:toEquipWidget())
            end
        end
    end
    if #tab_reward <= 1 then
        return tab_reward
    end
    table.sort(tab_reward, function (a, b)
        if a.type ~= b.type then
            return a.type > b.type
        end
        return a.id > b.id
    end)
    for i = #tab_reward - 1, 1, -1 do
        if tab_reward[i].type == tab_reward[i + 1].type and tab_reward[i].id == tab_reward[i + 1].id then
            tab_reward[i].num = tab_reward[i].num + tab_reward[i + 1].num
            table.remove(tab_reward, i + 1)
        end
    end
    return tab_reward
end

function Decree:getResMaxAddProduce(build_type)
    local max_num = 0
    local add_num = 0
    for k, v in pairs(uq.cache.role.buildings) do
        if v.type == build_type and v.level > 0 then
            local num_add, num_max = self:getAttValue(build_type, v.level)
            max_num = max_num + num_max
            add_num = add_num + num_add
        end
    end
    return max_num, add_num
end

function Decree:getAttValue(build_type, level)
    if build_type == uq.config.constant.BUILD_TYPE.IRON then
        local tab = StaticData['iron'].LevelIron
        local num = tonumber(self:getValue(tab, level))
        local rate = uq.cache.role:getBuildOfficerPropertyAdd(build_type, uq.config.constant.BUILD_OFFICER_EFFECT.TYPE_PRO_IRON)
        return math.ceil(num * (1 + rate)), self:getStockValue(tab, level)
    elseif build_type == uq.config.constant.BUILD_TYPE.HOUSE then
        local tab = StaticData['level_collection'].LevelCollection
        local num = tonumber(self:getValue(tab, level))
        local rate = uq.cache.role:getBuildOfficerPropertyAdd(build_type, uq.config.constant.BUILD_OFFICER_EFFECT.TYPE_MONEY_ADD)
        return math.ceil(num * (1 + rate)), self:getStockValue(tab, level)
    elseif build_type == uq.config.constant.BUILD_TYPE.FARM_LAND then
        local tab = StaticData['lvlfarms'].Levelfarm
        local num = tonumber(self:getValue(tab, level))
        local rate = uq.cache.role:getBuildOfficerPropertyAdd(build_type, uq.config.constant.BUILD_OFFICER_EFFECT.TYPE_FOOD_ADD)
        return math.ceil(num * (1 + rate)), self:getStockValue(tab, level)
    elseif build_type == uq.config.constant.BUILD_TYPE.SOLDIER then
        local tab = StaticData['draft'].Conscription
        if tab[level] and next(tab[level]) ~= nil then
            return math.ceil(tab[level].coolDown * 3600), tab[level].reserveSoldier
        end
        return 0, 0
    end
    return level, nil
end

function Decree:getValue(data, level)
    if data[level] and data[level].effect then
        return data[level].effect
    end
    return 0
end

function Decree:getStockValue(data, level)
    if data[level] and data[level].stock then
        return data[level].stock
    end
    return 0
end

return Decree