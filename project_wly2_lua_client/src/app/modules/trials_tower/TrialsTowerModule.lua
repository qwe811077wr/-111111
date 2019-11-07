local TrialsTowerModule = class("TrialsTowerModule", require("app.base.ModuleBase"))

TrialsTowerModule.RESOURCE_FILENAME = "test_tower/TestTowerMain.csb"

TrialsTowerModule.RESOURCE_BINDING  = {
    ["Node_1"]                      = {["varname"] = "_nodeBase"},
    ["Image_46"]                    ={["varname"] = "_imgBg"},
    ["img_reward"]                  ={["varname"] = "_rewardImg"},
    ["label_name"]                  ={["varname"] = "_nameLabel"},
    ["Panel_box"]                   ={["varname"] = "_nodeLeftBottom"},
    ["label_reset"]                 ={["varname"] = "_resetLabel"},
    ["label_attr1"]                 = {["varname"] = "_attrLabel1"},
    ["label_attr2"]                 = {["varname"] = "_attrLabel2"},
    ["btn_inspire"]                 ={["varname"] = "_btnInspire",["events"] = {{["event"] = "touch",["method"] = "_onBtnInspire"}}},
    ["btn_shop"]                    ={["varname"] = "_btnShop",["events"] = {{["event"] = "touch",["method"] = "_onBtnShop"}}},
    ["btn_rank"]                    ={["varname"] = "_btnRank",["events"] = {{["event"] = "touch",["method"] = "_onBtnRank",["sound_id"] = 0}}},
    ["btn_autosweep"]               ={["varname"] = "_btnSweep",["events"] = {{["event"] = "touch",["method"] = "_onBtnSweep",["sound_id"] = 0}}},
    ["btn_reset"]                   ={["varname"] = "_btnReset",["events"] = {{["event"] = "touch",["method"] = "_onBtnReset"}}},
}

function TrialsTowerModule:ctor(name, args)
    TrialsTowerModule.super.ctor(self, name, args)
    self._curTowerCfgInfo = nil
    self._curLayerInfo = nil
    self._battleInfo = nil
    self._allItems = {}
end

function TrialsTowerModule:init()
    local top_ui = uq.ui.CommonHeaderUI:create()
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.MILITORY_ORDER))
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.TRIALS_TOWER_ORDER))
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.GOLDEN, true))
    top_ui:setRuleId(uq.config.constant.MODULE_RULE_ID.TRIALS_TOWER)
    top_ui:setTitle(uq.config.constant.MODULE_ID.TRIALS_TOWER)
    self._topUI = top_ui
    self._view:addChild(top_ui:getNode())
    self:parseView()
    self:centerView()
    self:initDialog()
    self:initProtocolData()
    self:adaptBgSize(self._imgBg)
    self:adaptNode()
    self._lastMusic = uq.getLastMusic()
    uq.playSoundByID(1103)

    self._rewardPos = cc.p(self._rewardImg:getPosition())
    uq.intoAction(self._nodeBase, cc.p(0, -uq.config.constant.MOVE_DISTANCE))
end

function TrialsTowerModule:_onBtnReset(event)
    if event.name ~= "ended" then
        return
    end
    if uq.cache.trials_tower.trial_info.reset_num == 1 then
        uq.fadeInfo(StaticData["local_text"]["tower.reset.des"])
        return
    end
    if uq.cache.trials_tower.trial_info.cur_layer_id <= 1 then
        local info_object = {}
        for k,v in pairs(self._curLayerInfo.Object) do
            table.insert(info_object, v)
        end
        table.sort(info_object,function(a,b)
            return a.ident < b.ident
        end)
        if info_object[1].ident == uq.cache.trials_tower.trial_info.cur_npc_id then
            uq.fadeInfo(StaticData["local_text"]["tower.reset.des1"])
            return
        end
    end
    network:sendPacket(Protocol.C_2_S_TRIAL_TOWER_RESET, {})
end

function TrialsTowerModule:_onBtnSweep(event)
    if event.name ~= "ended" then
        return
    end
    local info = uq.cache.trials_tower.trial_info
    if info.cur_layer_id == info.max_layer_id and info.cur_npc_id == info.max_npc_id then
        uq.fadeInfo(StaticData["local_text"]["tower.sweep.des1"])
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    local function confirm()
        network:sendPacket(Protocol.C_2_S_TRIAL_TOWER_SWEEP, {})
    end
    local des = string.format(StaticData['local_text']['tower.sweep.des2'], tostring(info.max_layer_id))
    local data = {
        content = des,
        confirm_callback = confirm
    }
    uq.addConfirmBox(data)
end

function TrialsTowerModule:_onBtnRank(event)
    if event.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.TRIALS_TOWER_RANK, {})
end

function TrialsTowerModule:_onBtnShop(event)
    if event.name ~= "ended" then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.GENRAL_SHOP_MODULE, {_sub_index = uq.config.constant.GENERAL_SHOP.TRIAL_TOWER_SHOP})
end

function TrialsTowerModule:_onBtnInspire(event)
    if event.name ~= "ended" then
        return
    end
    network:sendPacket(Protocol.C_2_S_TRIAL_TOWER_INSPIRE, {})
end

function TrialsTowerModule:initProtocolData()
    services:addEventListener("onTrialsTowerInspire", handler(self, self.updateAddInfo), '_onTrialslTowerInspireByTower')
    network:addEventListener(Protocol.S_2_C_TRIAL_TOWER_ATTACK_NPC, handler(self, self._onTrialsTowerAttackNpc),'_onTrialsTowerAttackNpcByTower')
    services:addEventListener("onTrialsTowerLoadInfo", handler(self, self._onTrialsTowerLoadInfo), '_onTrialsTowerLoadInfoByTower')
    network:sendPacket(Protocol.C_2_S_TRIAL_TOWER_LOAD_INFO, {})
end

function TrialsTowerModule:_onTrialsTowerAttackNpc(evt)
    self._battleInfo = evt.data
    uq.BattleReport:getInstance():showBattleReport(self._battleInfo.report_id, handler(self, self._onPlayReportEnd))
end

function TrialsTowerModule:_onPlayReportEnd(report)
    if not report then
        return
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CLOSE_NPC_INFO})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CLOSE_ARRANGED_BEFORE})
    if report.result > 0 then
        local data = {rewards = self._battleInfo.reward, ['report'] = report}
        uq.ModuleManager:getInstance():show(uq.ModuleManager.NPC_WIN_MODULE, data)
        if self._battleInfo then
            if self._battleInfo.battle_ret > 0 then --胜利
                uq.cache.trials_tower.trial_info.cur_layer_id = self._battleInfo.layer_id
                uq.cache.trials_tower.trial_info.cur_npc_id = self._battleInfo.npc_id
                if uq.cache.trials_tower.trial_info.max_npc_id < uq.cache.trials_tower.trial_info.cur_npc_id then
                    uq.cache.trials_tower.trial_info.max_npc_id = uq.cache.trials_tower.trial_info.cur_npc_id
                end
                if self._battleInfo.pass_layer == 1 then --通关
                    network:sendPacket(Protocol.C_2_S_TRIAL_TOWER_LOAD_INFO, {})
                    uq.cache.trials_tower.trial_info.atk_lvl = 0
                    uq.cache.trials_tower.trial_info.def_lvl = 0
                    self:updateAddInfo()
                else
                    self:updateDialog()
                end
            end
        end
    else
        local data = {npc_id = report.npc_id, ['report'] = report}
        uq.ModuleManager:getInstance():show(uq.ModuleManager.NPC_LOST_MODULE, data)
    end
end

function TrialsTowerModule:updateBoxAction()
    self._rewardImg:stopAllActions()
    self._rewardImg:setRotation(0)
    if uq.cache.trials_tower.trial_info.cur_layer_id ~= uq.cache.trials_tower.trial_info.reward_box_layer + 1 then
        self._rewardImg:runAction(
            cc.RepeatForever:create(
                cc.Sequence:create(
                    cc.RotateTo:create(0.1, 30),
                    cc.RotateTo:create(0.2, -30),
                    cc.RotateTo:create(0.2, 30),
                    cc.RotateTo:create(0.2, -30),
                    cc.RotateTo:create(0.1, 0),
                    cc.DelayTime:create(1)
                )
            )
        )
    end
end

function TrialsTowerModule:_onTrialsTowerLoadInfo()
    local info = uq.cache.trials_tower.trial_info
    self._curTowerCfgInfo = StaticData['tower_cfg'][info.cur_layer_id]
    if uq.cache.trials_tower.trial_info.cur_layer_id ~= uq.cache.trials_tower.trial_info.reward_box_layer + 1 then
        self._curTowerCfgInfo = StaticData['tower_cfg'][info.cur_layer_id - 1]
    end
    self._curLayerInfo = StaticData.load('tower/Map_' .. self._curTowerCfgInfo.mapId).Map[self._curTowerCfgInfo.mapId]
    self:updateDialog()
    self:updateAddInfo()
end

function TrialsTowerModule:updateAddInfo()
    self._attrLabel1:setString(string.format(StaticData['local_text']['tower.attr.des1'],uq.cache.trials_tower.trial_info.atk_lvl))
    self._attrLabel2:setString(string.format(StaticData['local_text']['tower.attr.des2'],uq.cache.trials_tower.trial_info.def_lvl))
end

function TrialsTowerModule:removeProtocolData()
    services:removeEventListenersByTag("_onTrialsTowerLoadInfoByTower")
    network:removeEventListenerByTag("_onTrialsTowerAttackNpcByTower")
    network:removeEventListenerByTag("_onTrialslTowerInspireByTower")
end

function TrialsTowerModule:updateDialog()
    self._resetLabel:setString(string.format(StaticData['local_text']['tower.box.reset.des1'],uq.cache.trials_tower.trial_info.reset_num))
    self._imgBg:loadTexture("img/bg/" .. self._curTowerCfgInfo.icon)
    self._nameLabel:setString(self._curTowerCfgInfo.name)
    self._nodeLeftBottom:removeAllChildren()
    local info_object = {}

    for k,v in pairs(self._curLayerInfo.Object) do
        table.insert(info_object,v)
    end
    table.sort(info_object,function(a,b)
        return a.ident < b.ident
    end)
    local scale_x = display.width / CC_DESIGN_RESOLUTION.width
    self._rewardImg:setPosition(cc.p(self._curTowerCfgInfo.boxX * scale_x, self._curTowerCfgInfo.boxY * scale_x))
    self:updateBoxAction()
    for k,v in pairs(info_object) do
        local layer = ccui.Layout:create()
        local img = ccui.ImageView:create("img/common/soldier/"..v.icon)
        layer:addChild(img)
        layer:setContentSize(cc.size(img:getContentSize().width,img:getContentSize().height))
        layer:setPosition(cc.p(v.x * scale_x, v.y * scale_x))
        layer:setAnchorPoint(cc.p(0.5,0.5))
        if v.scale then
            layer:setScale(v.scale)
        end
        img:setAnchorPoint(cc.p(0,0))
        img:setPosition(cc.p(0,0))
        if v.ident == uq.cache.trials_tower.trial_info.cur_npc_id and uq.cache.trials_tower.trial_info.cur_layer_id == uq.cache.trials_tower.trial_info.reward_box_layer + 1 then
            layer:setSwallowTouches(true)
            layer:setTouchEnabled(true)
            local eff = uq.createPanelOnly('instance.AnimationKnife')
            layer:addChild(eff)
            eff:setPosition(cc.p(img:getContentSize().width * 0.5, img:getContentSize().height * 0.8))
            layer["userData"] = v
            layer:addClickEventListener(function(sender)
                uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
                local info = sender["userData"]
                self:showEmbattle(info)
            end)
        elseif v.ident < uq.cache.trials_tower.trial_info.cur_npc_id or uq.cache.trials_tower.trial_info.cur_layer_id ~= uq.cache.trials_tower.trial_info.reward_box_layer + 1 then
            img:loadTexture("img/common/soldier/"..v.dieIconId)
        end
        self._nodeLeftBottom:addChild(layer)
        self._allItems[v.ident] = layer
    end
end

function TrialsTowerModule:showEmbattle(info)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.TRIALS_TOWER_BATTLE, {info = info})
end

function TrialsTowerModule:initDialog()
    self._btnInspire:setPressedActionEnabled(true)
    self._btnShop:setPressedActionEnabled(true)
    self._btnRank:setPressedActionEnabled(true)
    self._btnSweep:setPressedActionEnabled(true)
    self._btnReset:setPressedActionEnabled(true)
    self._rewardImg:setTouchEnabled(true)
    self._rewardImg:addClickEventListener(function(sender)
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
        uq.ModuleManager:getInstance():show(uq.ModuleManager.TRIALS_TOWER_REWARD, {})
    end)
    self:updateAddInfo()
end

function TrialsTowerModule:dispose()
    if self._topUI then
        self._topUI:dispose()
    end
    self._topUI = nil
    self:removeProtocolData()
    uq.playBackGroundMusic(self._lastMusic)
    TrialsTowerModule.super.dispose(self)
end

return TrialsTowerModule
