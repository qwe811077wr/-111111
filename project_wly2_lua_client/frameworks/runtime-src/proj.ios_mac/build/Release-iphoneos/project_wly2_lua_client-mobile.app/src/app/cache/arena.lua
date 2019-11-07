local Arena = class("Arena")

function Arena:ctor()
    self._rank = 0
    self._bestRank = 0
    network:addEventListener(Protocol.S_2_C_ENTER_ATHLETICS, handler(self, self._onEnterAthletics))
    network:addEventListener(Protocol.S_2_C_ATHLETICS_BUY_TIMES, handler(self, self._onBuyTime))
    network:addEventListener(Protocol.S_2_C_ATHLETICS_DRAW_REWARD, handler(self, self._onGetReward))
    network:addEventListener(Protocol.S_2_C_ATHLETICS_SWEEP, handler(self, self._onSweep))
    network:addEventListener(Protocol.S_2_C_ATHLETICS_UPDATE_REWARD_INTEGRAL, handler(self, self._onRankChange))
end

function Arena:_onEnterAthletics(msg)
    self._info = msg.data
    self._rank = msg.data.rank
    self._bestRank = msg.data.best_rank
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ARENA_ENTER, data = msg.data})
end

function Arena:_onRankChange(msg)
    network:sendPacket(Protocol.C_2_S_ENTER_ATHLETICS)
    uq.fadeInfo(StaticData['local_text']['arena.on.rank.change'])
end

function Arena:_onBuyTime(msg)
    local data = msg.data
    self._info.buy_times = data.buy_times
end

function Arena:_onSweep(msg)
    self._info.challenge_times = self._info.challenge_times + 1
end

function Arena:setRank(rank)
    self._rank = rank
    if rank > 0 then
        self._bestRank = math.min(self._bestRank, rank)
    end
end

function Arena:_onGetReward(msg)
    if msg.data.clear_time ~= 0 then
        for k, v in ipairs(self._info.rewards) do
            if v.clear_time == msg.data.clear_time then
                self._info.rewards[k].state = 1
                break
            end
        end
    else
        for k, v in ipairs(self._info.rewards) do
            self._info.rewards[k].state = 1
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ARENA_DAILY_REWARD})
end

function Arena:setFormation(data)
    self._info.formation_id = data.formation_id
    self._info.general_loc = data.general_loc
end

function Arena:getAreanOwnerBattleFormation(data)
    local array_info = {}
    for k, v in ipairs(self._info.general_loc) do
        local info = uq.cache.generals:getGeneralDataByID(v.general_id)
        info.general_id = info.temp_id
        info.level = info.lvl
        table.insert(array_info, info)
    end
    return array_info
end

function Arena:checkGeneralIsInFormationById(id)
    if not self._info or next(self._info.general_loc) == nil then
        return false
    end
    for k, v in ipairs(self._info.general_loc) do
        if id == v.general_id then
            return true
        end
    end
    return false
end

function Arena:getRankInfo()
    return self._allRankInfo, self._ownerRankInfo
end

function Arena:getArenaInfo()
    return self._info
end

function Arena:_onChallengePlayer(msg)
    self._info.challenge_times = msg.data.challenge_times
end


function Arena:getRank()
    return self._rank
end

function Arena:getHighestRank()
    return self._bestRank
end

function Arena:getArenaReward(rank)
    rank = rank or self._rank
    local reward_config = uq.cache.arena:getRankConfig(rank)
    if reward_config then
        local reward_items = uq.RewardType.parseRewards(reward_config.Reward)
        return reward_items
    end
    return nil
end

function Arena:getRankConfig(rank)
    if rank == 0 then
        return
    end

    local config = StaticData['arena_reward']
    for k, item in ipairs(config) do
        if rank <= item.rewardRankLimit then
            return item
        end
    end

    return
end

function Arena:getBuyChallengeTimeCost(time)
    for i = #StaticData['constant'][13].Data, 1, -1 do
        if time + 1 >= StaticData['constant'][13].Data[i].times then
            local cost_str = StaticData['constant'][13].Data[i].cost
            local value_array = string.split(cost_str, ";")
            return value_array
        end
    end
end

return Arena