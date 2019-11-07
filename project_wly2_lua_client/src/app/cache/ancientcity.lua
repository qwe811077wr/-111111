local AncientCity = class("AncientCity")

function AncientCity:ctor()
    self._passCityInfo = nil
    self.total_rewards_info = nil
    self.rewards_info = nil
    self.battle_info = nil  --记录战斗界面信息
    self.battle_res = nil  --记录战斗结果
    self.player_info = nil
    self.detour_times = 0
    self.city_id = 1
    self.add_att = 0
    self.add_def = 0
    self.npc_pos = 0
    self.meet_npc = true
    self.sweep_over = true
    self.store_info = nil
    self.trade_info = {}  --记录金币商人跟龙玉商人信息
    self.isEnterBattleView = false  --记录是否进入古城关卡雕像选择界面
    self._failRward = {}
    network:addEventListener(Protocol.S_2_C_ANCIENT_CITY_ENTER, handler(self, self._ancientCityEnter))
    network:addEventListener(Protocol.S_2_C_ANCIENT_CITY_ENTER_SCENE, handler(self, self._ancientCityEnterScene))
    network:addEventListener(Protocol.S_2_C_ANCIENT_CITY_BUY_TIMES, handler(self, self._ancientCityBuyItems))
    network:addEventListener(Protocol.S_2_C_ANCIENT_CITY_MOVE, handler(self, self._ancientCityMove))
    network:addEventListener(Protocol.S_2_C_ANCIENT_CITY_DETOUR, handler(self, self._ancientCityDetour))
    network:addEventListener(Protocol.S_2_C_ANCIENT_CITY_LOOKUP_GUIDE, handler(self, self._ancientCityLookUpGuide))
    network:addEventListener(Protocol.S_2_C_ANCIENT_CITY_GET_REWARD, handler(self, self._ancientCityGetReward))
    network:addEventListener(Protocol.S_2_C_ANCIENT_CITY_GET_LOSE_JADE, handler(self, self._ancientCityLostJade))
    network:addEventListener(Protocol.S_2_C_ANCIENT_CITY_INSPIRE, handler(self, self._ancientCityInspire))
    network:addEventListener(Protocol.S_2_C_ANCIENT_CITY_MEET_NPC, handler(self, self._ancientCityMeetNpc))
    network:addEventListener(Protocol.S_2_C_ANCIENT_CITY_MEET_PLAYER, handler(self, self._ancientCityMeetPlayer))
    network:addEventListener(Protocol.S_2_C_ANCIENT_CITY_MEET_MERCHANT, handler(self, self._ancientCityMeetMerchant))
    network:addEventListener(Protocol.S_2_C_ANCIENT_CITY_MEET_TREASURE, handler(self, self._ancientCityMeetTreasure))
    network:addEventListener(Protocol.S_2_C_ANCIENT_CITY_MEET_SECRET_ROOM, handler(self, self._ancientCityMeetSecretRoom))
    network:addEventListener(Protocol.S_2_C_ANCIENT_CITY_FIND_REWARD, handler(self, self._ancientCityFindReward))
    network:addEventListener(Protocol.S_2_C_ANCIENT_CITY_BATTLE_RES, handler(self, self._ancientCityBattleRes))
    network:addEventListener(Protocol.S_2_C_ANCIENT_CITY_STORE_LOAD, handler(self, self._ancientCityStoreLoad))
    network:addEventListener(Protocol.S_2_C_ANCIENT_CITY_STORE_BUY, handler(self, self._ancientCityStoreBuy))
    network:addEventListener(Protocol.S_2_C_ANCIENT_CITY_STORE_REFRESH, handler(self, self._ancientCityRefresh))
    network:addEventListener(Protocol.S_2_C_ANCIENT_CITY_TRADE_LOAD, handler(self, self._ancientCityTradeLoad))
end

function AncientCity:_ancientCityLostJade(evt)
    if evt.data.cost_type == 0 then
        self._failRward = {}
    else
        self._failRward = {{["type"] = evt.data.cost_type, ["num"] = 1, ["paraml"] = evt.data.param1}}
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ANCIENT_LOST_JADE})
end

function AncientCity:_ancientCityTradeLoad(evt)
    local info = evt.data
    self.trade_info[info.trade_type] = info
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ANCIENT_CITY_TRADE_LOAD, data = evt.data})
end

function AncientCity:_ancientCityRefresh(evt)
    uq.log("_ancientCityRefresh  ",evt.data)
    uq.fadeInfo(StaticData["local_text"]["ancient.city.shop.refresh.success"])
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_STORE_LOAD, {})
end

function AncientCity:_ancientCityStoreBuy(evt)
    uq.log("_ancientCityStoreBuy  ",evt.data)
    if evt.data.ret ~= 0 then
        return
    end
    for k,v in pairs(self.store_info.items) do
        if v.id == evt.data.id then
            v.num = evt.data.num + v.num
        end
    end

    for k,v in pairs(self.store_info.total_nums) do
        if v.id == evt.data.id then
            v.num = evt.data.num + v.num
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ANCIENT_CITY_STORE_BUY,data = evt.data})

    local xml_data = StaticData['ancient_store']['AncientStore'][evt.data.id]
    self:showReward(xml_data, evt.data.num)
end

function AncientCity:_ancientCityStoreLoad(evt)
    uq.log("_ancientCityStoreLoad  ",evt.data)
    self.store_info = evt.data
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ANCIENT_CITY_STORE_LOAD})
end

function AncientCity:_ancientCityFindReward(evt)
    uq.fadeInfo(StaticData["local_text"]["ancient.city.find.reward.des"])
end

function AncientCity:_ancientCityEnterScene(evt)
    uq.log('_ancientCityEnterScene-----', evt.data)
    self.detour_times = evt.data.detour_times
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_MOVE, {hasSecretRoom = 0})
end

function AncientCity:_ancientCityMove(evt)
    uq.log('_ancientCityMove-----', evt.data)
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_MOVE, {hasSecretRoom = 0})
end

function AncientCity:_ancientCityDetour(evt)
    uq.log('_ancientCityDetour-----', evt.data)
    if self.sweep_over then
        uq.fadeInfo(StaticData["local_text"]["ancient.city.battle.detour.des1"])
    end
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_MOVE, {hasSecretRoom = 0})
end

function AncientCity:_ancientCityLookUpGuide(evt)
    uq.log('_ancientCityLookUpGuide-----', evt.data)
    services:dispatchEvent({name = "onAncientCityLookUpGuide",data = evt.data.guide})
end

function AncientCity:_ancientCityGetReward(evt)
    uq.log('_ancientCityGetReward-----', evt.data)
    self.rewards_info = evt.data.reward
    if evt.data.reward_type == 4 then
        self.city_id = self.city_id + 1
        services:dispatchEvent({name = services.EVENT_NAMES.ON_ANCIENT_CITY_GET_REWARD,data = evt.data.reward})
    end
    if #evt.data.reward > 0 then
        if evt.data.reward_type == 1 or evt.data.reward_type == 0 then
            uq.TimerProxy:addTimer("delay_send_reward", function()
                uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, {rewards = evt.data.reward})
                uq.fadeInfo(StaticData["local_text"]["ancient.city.box.reward.des"])
            end, 0, 1, 0.2)
        elseif evt.data.reward_type == 2 then
            uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE,{rewards = evt.data.reward})
        end
    end
end

function AncientCity:_ancientCityInspire(evt)
    uq.log('_ancientCityInspire-----', evt.data)
    if evt.data.res == 0 then
        uq.fadeInfo(StaticData["local_text"]["ancient.city.inspire.des"])
        return
    end
    if evt.data.buff_type == 0 then
        self.add_att = evt.data.value
    else
        self.add_def = evt.data.value
    end
    uq.fadeInfo(StaticData["local_text"]["ancient.city.battle.inspire.des"])
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ANCIENT_CITY_INSPIRE})
end

function AncientCity:_ancientCityMeetSecretRoom(evt)
    uq.log('_ancientCityMeetSecretRoom-----', evt.data)
    self.secret_info = evt.data
    if not self.sweep_over then
        if tonumber(evt.data.exists) == 1 then --有密室
            uq.ModuleManager:getInstance():show(uq.ModuleManager.ANCIENT_CITY_BEFORE, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, close_open_action = true, ["type"] = 2})
        else
            self.sweep_over = true
        end
    end
end

function AncientCity:_ancientCityMeetTreasure(evt)
    uq.log('_ancientCityMeetTreasure-----', evt.data)
    self.total_rewards_info = evt.data.reward
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ANCIENT_CITY_MEET_TREASURE})
end

function AncientCity:_ancientCityMeetMerchant(evt)
    uq.log('_ancientCityMeetMerchant-----', evt.data)
    if self.sweep_over then
        uq.ModuleManager:getInstance():show(uq.ModuleManager.ANCIENT_CITY_BEFORE, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, close_open_action = true, talk_type = evt.data.trader_type + 4, ["type"] = 1})
    else
        network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_MOVE, {hasSecretRoom = 0})
    end
end

function AncientCity:_ancientCityMeetPlayer(evt)
    uq.log('_ancientCityMeetPlayer-----', evt.data)
    self.player_info = evt.data
    self.meet_npc = false
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ANCIENT_CITY_MEET_PLAYER})
end

function AncientCity:_ancientCityMeetNpc(evt)
    uq.log('_ancientCityMeetNpc-----', evt.data)
    self.npc_pos = evt.data.npc_pos + 1
    self.meet_npc = true
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ANCIENT_CITY_MEET_NPC})
end

function AncientCity:_ancientCityBattleRes(evt)
    uq.log('_ancientCityBattleRes-----', evt.data)
    self.battle_res = evt.data
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ANCIENT_CITY_BATTLE_RES})
end

function AncientCity:_ancientCityBuyItems(evt)
    uq.log('_ancientCityBuyItems-----', evt.data)
    uq.fadeInfo(StaticData["local_text"]["ancient.city.add.num.des3"])
    self._passCityInfo.extra_times = evt.data.extra_times
    local view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.ANCIENT_CITY_MODULE)
    if view then
        view:updateNum()
    end
end

function AncientCity:_ancientCityEnter(evt)
    uq.log('_ancientCityEnter-----', evt.data)
    self._passCityInfo = evt.data
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ANCIENT_CITY_ENTER})
    self:updateRed()
end

function AncientCity:updateRed()
    local is_red = false
    local info_array = {}
    for k, v in pairs(StaticData['daily_goal']) do
        if v.nums <= self._passCityInfo.daily_num then --可领取
            table.insert(info_array, v)
        end
    end
    for k, v in ipairs(info_array) do
        is_red = true
        for k2, v2 in pairs(self._passCityInfo.goal_ids) do
            if v2 == v.ident then
                is_red = false
                break
            end
        end
        if is_red then
            break
        end
    end
    uq.cache.hint_status.status[uq.cache.hint_status.RED_TYPE.ANCIENT] = is_red
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ANCIENT_CITY_REWARD_RED})
    uq.cache.daily_activity:updateRed()
end

function AncientCity:getPassCityInfo()
    return self._passCityInfo
end

function AncientCity:showReward(xml_data, num)
    if not xml_data then
        return
    end
    local item_info = string.split(xml_data.buy, ';')
    local rewards =  string.format('%s;%d;%s', item_info[1], item_info[2] * num, item_info[3])
    uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, {rewards = rewards})
end

return AncientCity