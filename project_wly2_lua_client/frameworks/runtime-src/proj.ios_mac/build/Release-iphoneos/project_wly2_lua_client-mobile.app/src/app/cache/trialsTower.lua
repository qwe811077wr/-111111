local TrialsTower = class("TrialsTower")

function TrialsTower:ctor()
    self.trial_info = nil
    self.store_info = nil
    network:addEventListener(Protocol.S_2_C_TRIAL_TOWER_INSPIRE, handler(self, self._trialsTowerInspire))
    network:addEventListener(Protocol.S_2_C_TRIAL_TOWER_LOAD_INFO, handler(self, self._trialTowerLoadInfo))
    network:addEventListener(Protocol.S_2_C_TRIAL_TOWER_SWEEP, handler(self, self._trialTowerSweep))
    network:addEventListener(Protocol.S_2_C_TRIAL_TOWER_DRAW_REWARD_BOX, handler(self, self._trialTowerDrawBoxReward))
    network:addEventListener(Protocol.S_2_C_TRIAL_TOWER_RESET, handler(self, self._trialTowerReset))
    network:addEventListener(Protocol.S_2_C_TRIAL_TOWER_STORE_LOAD, handler(self, self._trialTowerStoreLoad))
    network:addEventListener(Protocol.S_2_C_TRIAL_TOWER_STORE_BUY, handler(self, self._trialTowerStoreBuy))
    network:addEventListener(Protocol.S_2_C_TRIAL_TOWER_DRAW_REWARD, handler(self, self._trialTowerDrawReward))
    network:addEventListener(Protocol.S_2_C_TRIAL_TOWER_STORE_REFRESH, handler(self, self._trialTowerRefresh))
    network:addEventListener(Protocol.S_2_S_TRIAL_TOWER_LOG_LOAD, handler(self, self._trialTowerLogLoad))
end

function TrialsTower:_trialTowerLogLoad(evt)
    services:dispatchEvent({name = services.EVENT_NAMES.ON_STRATEGY_INFO, data = evt.data})
end

function TrialsTower:_trialTowerRefresh(evt)
    uq.fadeInfo(StaticData["local_text"]["ancient.city.shop.refresh.success"])
    network:sendPacket(Protocol.C_2_S_TRIAL_TOWER_STORE_LOAD, {})
end

function TrialsTower:_trialTowerDrawReward(evt)
    for k,v in pairs(self.store_info.rank_rwds) do
        if v.id == evt.data.id then
            v.num = v.num - evt.data.num
            break
        end
    end
    services:dispatchEvent({name = "onTrialTowerDrawReward",data = evt.data})

    local xml_data = StaticData['tower_store']['TowerReward'][evt.data.id]
    uq.cache.ancient_city:showReward(xml_data, evt.data.num)
end

function TrialsTower:_trialTowerStoreBuy(evt)
    for k,v in pairs(self.store_info.items) do
        if v.id == evt.data.id then
            v.num = v.num - evt.data.num
            break
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_TRIAL_TOWER_STORE_BUY,data = evt.data})

    local xml_data = StaticData['tower_store']['TowerStore'][evt.data.id]
    uq.cache.ancient_city:showReward(xml_data, evt.data.num)
end

function TrialsTower:_trialTowerStoreLoad(evt)
    self.store_info = evt.data
    services:dispatchEvent({name = services.EVENT_NAMES.ON_TRIAL_TOWER_STORE_LOAD})
end

function TrialsTower:_trialTowerReset(evt)
    self.trial_info.atk_lvl = 0
    self.trial_info.def_lvl = 0
    uq.fadeInfo(StaticData["local_text"]["tower.box.reset.des2"])
    network:sendPacket(Protocol.C_2_S_TRIAL_TOWER_LOAD_INFO, {})
end

function TrialsTower:_trialTowerDrawBoxReward(evt)
    self.trial_info.reward_box_layer = evt.data.reward_layer_id
    services:dispatchEvent({name = "onTrialsTowerLoadInfo"})
    local xml_info = nil
    for k,v in ipairs(StaticData['tower_cfg']) do
        if v.ident == evt.data.reward_layer_id then
            xml_info = v
            break
        end
    end
    if not xml_info then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE,{rewards = xml_info.reward})
end

function TrialsTower:_trialTowerSweep(evt)
    local info = evt.data
    self.trial_info.cur_layer_id = info.cur_layer_id
    self.trial_info.cur_npc_id = info.cur_npc_id
    self.trial_info.atk_lvl = 0
    self.trial_info.def_lvl = 0
    services:dispatchEvent({name = "onTrialsTowerLoadInfo"})
    uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE,{rewards = info.rwds})
end

function TrialsTower:_trialTowerLoadInfo(evt)
    self.trial_info = evt.data
    services:dispatchEvent({name = "onTrialsTowerLoadInfo"})
end

function TrialsTower:getCurTowerInfo()
    if not self.trial_info then
        return nil
    end
    for k, v in pairs(StaticData['tower_cfg']) do
        if v.ident == self.trial_info.cur_layer_id then
            return v
        end
    end
    return nil
end

function TrialsTower:_trialsTowerInspire(evt)
    if evt.data.ret == 0 then
        self.trial_info.atk_lvl = evt.data.atk_lvl
        self.trial_info.def_lvl = evt.data.def_lvl
        uq.fadeInfo(StaticData["local_text"]["ancient.city.battle.inspire.des"])
        services:dispatchEvent({name = "onTrialsTowerInspire"})
    else
        uq.fadeInfo(StaticData["local_text"]["ancient.city.inspire.des"])
    end
end

return TrialsTower