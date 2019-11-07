local RewardType = class('RewardType')

function RewardType:ctor(rwd_str)
    self._rewardStr = rwd_str
    self._type = 0
    self._num = 0
    self._id = 0
    self._rate = 1000
    self._maxNum = 0
    local parts = string.split(rwd_str, ";")
    if #parts < 3 then
        return
    end

    self._type = tonumber(parts[1])
    self._num = tonumber(parts[2])
    self._id = tonumber(parts[3])
    self._maxNum = parts[4] == nil and 0 or tonumber(parts[4])
    self._rate = parts[5] == nil and 1000 or tonumber(parts[5])
    self._data = StaticData.getCostInfo(self._type, self._id) or {}
    self._icon = self._data and self._data.icon or ""
    self._miniIcon = self._data and self._data.miniIcon or ""
end

function RewardType:data()
    return self._data
end

function RewardType:type()
    return self._type
end

function RewardType:num()
    return self._num
end

function RewardType:id()
    return self._id
end

function RewardType:icon()
    return self._icon
end

function RewardType:miniIcon()
    return self._miniIcon
end

function RewardType:toEquipWidget()
    local info = {
        type = self._type,
        id = self._id,
        num = self._num,
        max_num = self._maxNum,
        rate = self._rate
    }
    return info
end

function RewardType:toWidget(templat)
    templat = templat or 'arena.RewardItem'

    local panel = uq.createPanelOnly(templat)
    if panel then
        panel:setData(self._rewardStr)
    end

    return panel
end

function RewardType:toHTMLStr()
    return '<img ' .. self._icon .. '>' .. self._num
end

function RewardType:toMiniIconHTMLStr()
    return "<img img/common/ui/" .. self._miniIcon .. ">" .. self._num
end

function RewardType:parseRewardsAndFilterDrop(rws)
    local array = {}
    local rewards_array = {}
    if rws == nil or rws == "" then
        return array
    end

    local reward_string = string.split(rws,"|")
    for k, v in ipairs(reward_string) do
        local reward = uq.RewardType.new(v)
        if not array[reward:type()] then
            array[reward:type()] = {}
        end
        if not array[reward:type()][reward:id()] or reward._rate < 1000 or reward._num < reward._maxNum then
            array[reward:type()][reward:id()] = reward
        end
    end
    for k, v in pairs(array) do
        for _, reward in pairs(v) do
            table.insert(rewards_array, reward)
        end
    end
    return rewards_array
end

function RewardType.parseRewards(rws)
    local rewards_array = {}
    if rws == nil or rws == "" then
        return rewards_array
    end

    local reward_string = string.split(rws,"|")
    for k, v in ipairs(reward_string) do
        local reward = uq.RewardType.new(v)
        table.insert(rewards_array, reward)
    end
    return rewards_array
end

function RewardType:convertMapToTable(list)
    local rewards_array = {}
    for k, v in pairs(list) do
        for _, reward in pairs(v) do
            local info = reward:toEquipWidget()
            table.insert(rewards_array, info)
        end
    end
    return rewards_array
end

function RewardType:checkNeedNumState(str)
    if str == "" then
        return true
    end
    local needs = self.parseRewards(str)
    for k, v in ipairs(needs) do
        local info = v:toEquipWidget()
        if not uq.cache.role:checkRes(info.type, info.num, info.id) then
            return false
        end
    end
    return true
end

function RewardType:getRewardByDrop(str)
    local arr_drop = string.split(str, ';')
    local reward_info = {}
    for _, drop_str in ipairs(arr_drop) do
        local drop_info = string.split(drop_str, ',')
        local rewards = StaticData['drop'][tonumber(drop_info[1])].reward
        for _, reward_str in ipairs(rewards) do
            if (reward_str.country == 0 or reward_str.country == uq.cache.role.country_id) and reward_str.level <= uq.cache.role:level() then
                local reward = uq.RewardType.new(reward_str.show)
                local info = reward:toEquipWidget()
                if not reward_info[info.type] then
                    reward_info[info.type] = {}
                end
                if not reward_info[info.type][info.id] then
                    info.rate = tonumber(drop_info[2]) / #rewards
                    info.num = 1
                    reward_info[info.type][info.id] = info
                end
            end
        end
    end

    local arr_info_list = {}
    for k, v in pairs(reward_info) do
        for _, info in pairs(v) do
            table.insert(arr_info_list, info)
        end
    end
    return arr_info_list
end

function RewardType:mergeRewardToMap(list, tab, is_info)
    local type_name = is_info and "type" or "_type"
    local id_name = is_info and "id" or "_id"
    local num_name = is_info and "num" or "_num"
    for k, v in ipairs(tab) do
        if not list[v[type_name]] then
            list[v[type_name]] = {}
        end
        if not list[v[type_name]][v[id_name]] then
            list[v[type_name]][v[id_name]] = v
        else
            list[v[type_name]][v[id_name]][num_name] = list[v[type_name]][v[id_name]][num_name] + v[num_name]
        end
    end
    return list
end

function RewardType:getRuleRewardTab(data)
    local tab = {}
    for k, v in pairs(data) do
        for ik, iv in pairs(v) do
            table.insert(tab, {["type"] = k, ["num"] = iv, ["id"] = ik, ["paraml"] = ik})
        end
    end
    return tab
end

function RewardType:tabMergeReward(data)
    if not data or next(data) == nil then
        return {}
    end
    local tab = {}
    for _, v in pairs(data) do
        if not tab[v.type] then
            tab[v.type] = {}
        end
        local id = v.id or v.paraml
        if not tab[v.type][id] then
            tab[v.type][id] = 0
        end
        tab[v.type][id] = tab[v.type][id] + v.num
    end
    return self:getRuleRewardTab(tab)
end

uq.RewardType = RewardType