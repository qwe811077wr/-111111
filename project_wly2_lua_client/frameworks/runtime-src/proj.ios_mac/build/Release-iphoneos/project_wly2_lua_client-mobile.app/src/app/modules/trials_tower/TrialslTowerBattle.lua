local TrialslTowerBattle = class("TrialslTowerBattle", require('app.base.PopupBase'))
local EquipItem = require("app.modules.common.EquipItem")

TrialslTowerBattle.RESOURCE_FILENAME = 'test_tower/TestTowerBattle.csb'
TrialslTowerBattle.RESOURCE_BINDING = {
    ["Button_3"]            = {["varname"] = "_btnAtk", ["events"] = {{["event"] = "touch",["method"] = "_onTouchExit"}}},
    ["sweep_btn"]           = {["varname"] = "_btnBattle", ["events"] = {{["event"] = "touch",["method"] = "onAttack"}}},
    ["guide_btn"]          = {["varname"] = "_btnGuide", ["events"] = {{["event"] = "touch",["method"] = "_doViewGuide"}}},
    ["Text_7_0"]            = {["varname"] = "_txtName"},
    ["txt_desc"]            = {["varname"] = "_txtDesc"},
    ["ScrollView_1"]        = {["varname"] = "_scrollView"},
}

function TrialslTowerBattle:ctor(name, params)
    TrialslTowerBattle.super.ctor(self, name, params)
    self._info = params.info
end

function TrialslTowerBattle:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self._eventClose = services.EVENT_NAMES.ON_CLOSE_NPC_INFO .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_CLOSE_NPC_INFO, handler(self, self.onCloseEevent), self._eventClose)
    uq.playSoundByID(56)
    self._txtName:setString(self._info.name)
    self._txtDesc:setString(self._info.des)
    local reward_array = uq.RewardType.parseRewards(self._info.reward)
    self._scrollView:removeAllChildren()
    local item_size = self._scrollView:getContentSize()
    local index = #reward_array
    local inner_width = index * 100
    self._scrollView:setInnerContainerSize(cc.size(inner_width, item_size.height))
    self._scrollView:setScrollBarEnabled(false)
    local item_posX = 60
    for _,t in ipairs(reward_array) do
        local euqip_item = EquipItem:create({info = t:toEquipWidget()})
        euqip_item:setPosition(cc.p(item_posX,item_size.height * 0.5))
        euqip_item:setScale(0.73)
        euqip_item:setTouchEnabled(true)
        euqip_item:addClickEventListenerWithSound(function(sender)
            local info = sender:getEquipInfo()
            uq.showItemTips(info)
        end)
        self._scrollView:addChild(euqip_item)
        item_posX = item_posX + 100
    end
end

function TrialslTowerBattle:_doViewGuide(event)
    if event.name ~= "ended" then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.NPC_GUIDE_MODULE)
    network:sendPacket(Protocol.C_2_S_TRIAL_TOWER_LOG_LOAD, {npc_id = self._info.ident})
end

--攻击
function TrialslTowerBattle:_doAtkNPC(evt)
    network:sendPacket(Protocol.C_2_S_TRIAL_TOWER_ATTACK_NPC, {})
end

function TrialslTowerBattle:onAttack(event)
    if event.name ~= "ended" then
        return
    end
    local troop_info = StaticData.load('tower/Troop_' .. self._info.ref_ident)
    local enemy_data = troop_info.Troop[self._info.troops].Army
    local data = {
        enemy_data = enemy_data,
        embattle_type = uq.config.constant.TYPE_EMBATTLE.INSTANCE_EMBATTLE,
        confirm_callback = handler(self, self._doAtkNPC)
    }
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ARRANGED_BEFORE_WAR, data)
end

function TrialslTowerBattle:onExit()
    services:removeEventListenersByTag(self._eventClose)
    TrialslTowerBattle.super.onExit(self)
end

function TrialslTowerBattle:onCloseEevent()
    local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.ARRANGED_BEFORE_WAR)
    if panel then
        panel:disposeSelf()
    end
    self:disposeSelf()
end

return TrialslTowerBattle