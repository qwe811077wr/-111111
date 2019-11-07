local NPCInfoModule = class("NPCInfoModule", require('app.base.PopupBase'))

NPCInfoModule.RESOURCE_FILENAME = 'instance/NPCInfoView.csb'
NPCInfoModule.RESOURCE_BINDING = {
    ["atk_btn"]            = {["varname"] = "_btnAtk", ["events"] = {{["event"] = "touch",["method"] = "onAttack"}}},
    ["sweep_btn"]          = {["varname"] = "_btnSweep", ["events"] = {{["event"] = "touch",["method"] = "_doSweepNPC",["sound_id"] = 0}}},
    ["guide_btn"]          = {["varname"] = "_btnGuide", ["events"] = {{["event"] = "touch",["method"] = "_doViewGuide"}}},
    ["Button_1"]           = {["varname"] = "_btnAddMillitory", ["events"] = {{["event"] = "touch",["method"] = "onAddMillitory"}}},
    ["left_num_txt"]       = {["varname"] = "_txtAtkNum"},
    ["cost_order_txt_atk"] = {["varname"] = "_txtCostOrderAtk"},
    ["Sprite_cost_atk"]    = {["varname"] = "_spriteCostAtk"},
    ["drop_item_list"]     = {["varname"] = "_dropList"},
    ["star_1"]             = {["varname"] = "_spriteStar1"},
    ["star_2"]             = {["varname"] = "_spriteStar2"},
    ["star_3"]             = {["varname"] = "_spriteStar3"},
    ["Text_7_0"]           = {["varname"] = "_txtName"},
    ["txt_desc"]           = {["varname"] = "_txtDesc"},
}

function NPCInfoModule:ctor(name, params)
    NPCInfoModule.super.ctor(self, name, params)
    self._instanceId = params.instance_id
    self._npcId = params.npc_id
    self._troopId = params.troop_id or self:getDefultTroop()
    self._isSweep = params.is_sweep
end

function NPCInfoModule:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()

    self._xmlData = uq.cache.instance:getNPCXml(self._instanceId, self._npcId)
    local npc_data = uq.cache.instance:getNPC(self._instanceId, self._npcId)

    self:_fillBaseInfo()
    self:setStar(npc_data.star)
    if self._xmlData.qtyLimit == 0 then
        self._txtAtkNum:setString(StaticData['local_text']['instance.not.limit'])
        self._txtAtkNum:setTextColor(uq.parseColor('#37F413'))
    else
        self._txtAtkNum:setTextColor(uq.parseColor('#A9DBE2'))
        self._txtAtkNum:setString(string.format('%d/%d', npc_data.atk_num, self._xmlData.qtyLimit))
    end
    if self._isSweep then
        self._btnAtk:setVisible(false)
    end
    uq.playSoundByID(56)
    uq.cache.guide:openTriggerGuide(uq.config.constant.GUIDE_TRIGGER.CARD_CLICK, self._xmlData.ident)
    network:addEventListener(Protocol.S_2_C_BATTLE_DROPED_INFO, handler(self, self._onBattleDropInfo), '_onInstanceBattleDropInfo')
    network:addEventListener(Protocol.S_2_C_INSTANCE_STRATEGY, handler(self, self._onGuideInfo), '_onInstanceGuideInfo')
    services:dispatchEvent({name = services.EVENT_NAMES.ON_HIDE_MAIN_UI})

    self._eventClose = services.EVENT_NAMES.ON_CLOSE_NPC_INFO .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_CLOSE_NPC_INFO, handler(self, self.onCloseEevent), self._eventClose)

    self._txtName:setString(string.format('%s', self._xmlData.Name))
    services:addEventListener(services.EVENT_NAMES.SEND_BATTLE_REPORT, handler(self, self._doAtkNPC), '_onSendBattleReport')

    self._eventName = services.EVENT_NAMES.ON_CONSUME_RES_CHANGE .. uq.config.constant.COST_RES_TYPE.MILITORY_ORDER
    self._eventTag = self._eventName .. tostring(self)
    services:addEventListener(self._eventName, handler(self, self.refreshMillitory), self._eventTag)

    self._eventBuy = services.EVENT_NAMES.BUY_MILITORY_ORDER .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.BUY_MILITORY_ORDER, handler(self, self.refreshMillitory), self._eventBuy)
end

function NPCInfoModule:setStar(star)
    for i = 1, 3 do
        self['_spriteStar' .. i]:setVisible(false)
    end
    for i = 1, star do
        if self['_spriteStar' .. i] then
            self['_spriteStar' .. i]:setVisible(true)
        end
    end
end

function NPCInfoModule:isCostEnough(num)
    num = num or 1
    local cost_config = string.split(self._xmlData.cost, ';')
    local cost_num = tonumber(cost_config[2]) * num
    local cost_type = tonumber(cost_config[1])
    local info = StaticData.getCostInfo(cost_type)
    if not uq.cache.role:checkRes(cost_type, cost_num) then
        return false, info
    end
    return true, info
end

function NPCInfoModule:onAttack(event)
    if event.name ~= "ended" then
        return
    end
    local ret, info = self:isCostEnough()
    if not ret then
        uq.fadeInfo(string.format(StaticData['local_text']['label.res.tips.less'], info.name))
        return
    end

    local instance_temp = StaticData['instance'][self._instanceId]
    local troop_id = instance_temp.troopId
    local enemy_data = StaticData.load('instance/' .. troop_id).Troop[self._troopId].Army
    local data = {
        enemy_data = enemy_data,
        embattle_type = uq.config.constant.TYPE_EMBATTLE.INSTANCE_EMBATTLE,
        confirm_callback = handler(self, self._doAtkNPC),
        npc_data = self._xmlData,
    }
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ARRANGED_BEFORE_WAR, data)
end

function NPCInfoModule:_fillBaseInfo()
    local npc_data = uq.cache.instance:getNPC(self._instanceId, self._npcId)

    local instance_temp = StaticData['instance'][self._instanceId]
    local troop_id = instance_temp.troopId
    local troop = StaticData.load('instance/' .. troop_id).Troop[self._xmlData.troops]

    local name_len = string.utfLen(troop.name)
    local name_txt = ''
    for i = 1, name_len do
        if i > 1 then
            name_txt = name_txt .. '\n'
        end
        name_txt = name_txt .. string.subUtf(troop.name, i, 1)
    end

    local item_xml = ''
    if npc_data.star >= 1 then
        item_xml = string.split(self._xmlData.Reward, '|')
    else
        local reward = self._xmlData.firstReward
        if self._xmlData.firstDrop ~= '' then
            local ids = string.split(self._xmlData.firstDrop, ',')
            local id = tonumber(ids[1])
            local drop_data = StaticData['drop'][id].reward
            for k, item in ipairs(drop_data) do
                reward = reward .. '|' .. item.show
            end
        end
        item_xml = string.split(reward, '|')
    end
    local reward_result = {}
    for k, item_str in ipairs(item_xml) do
        local items = uq.RewardType:create(item_str)
        local info = {
            str = item_str,
            rate = items._rate,
            info = items._data,
        }
        if items._type == uq.config.constant.COST_RES_TYPE.GENERALS then
            local general_data = StaticData['general'][items._id]
            if general_data.camp == 0 or general_data.camp == uq.cache.role.country_id then
                table.insert(reward_result, info)
            end
        else
            table.insert(reward_result, info)
        end
    end

    table.sort(reward_result, function(a, b)
        if (a.rate == 1000 or b.rate == 1000) and a.rate ~= b.rate then
            return a.rate > b.rate
        else
            return tonumber(a.info.qualityType) > tonumber(b.info.qualityType)
        end
    end)

    self._dropList:setScrollBarEnabled(false)
    for k, item_str in ipairs(reward_result) do
        local panel = uq.createPanelOnly('instance.DropItem')
        panel:setData(item_str.str)
        panel:setSwallow(false)

        local config = string.split(item_str.str, ';')

        local size = panel:getContentSize()
        panel:setPosition(cc.p(size.width / 2 + 10, size.height / 2 - 8))

        local widget = ccui.Widget:create()
        widget:setContentSize(cc.size(size.width + 20, size.height))
        widget:addChild(panel)
        widget:setTouchEnabled(true)
        self._dropList:pushBackCustomItem(widget)
    end

    -- local info = StaticData.getCostInfo(tonumber(cost_config[1]))
    -- local miniIcon = info and info.miniIcon or "03_0002.png"
    --self._spriteCostAtk:setTexture('img/common/ui/' .. miniIcon)
    self._txtDesc:setString(self._xmlData.desc)
    self:refreshMillitory()
end

function NPCInfoModule:refreshMillitory()
    local num = uq.cache.role:getResNum(uq.config.constant.COST_RES_TYPE.MILITORY_ORDER)
    local cost_config = string.split(self._xmlData.cost, ';')
    local color = tonumber(cost_config[2]) <= num and '56FF49' or 'F30B0B'
    self._txtCostOrderAtk:setHTMLText(string.format("<font color='#%s'>%d</font> / %d", color, tonumber(cost_config[2]), num))
end

--攻击
function NPCInfoModule:_doAtkNPC(evt)
    self:_doBattle(1)
end

--扫荡
function NPCInfoModule:_doSweepNPC(event)
    if event.name ~= 'ended' then
        return
    end
    local tag = event.target:getTag()
    local npc_data = uq.cache.instance:getNPC(self._instanceId, self._npcId)
    if npc_data.star >= 3 then
        local ret, info = self:isCostEnough(tag)
        if not ret then
            uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
            uq.fadeInfo(string.format(StaticData['local_text']['label.res.tips.less'], info.name))
            return
        end
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
        -- self:_doBattle(0, tag)
        local data = {
            instance_id = self._instanceId,
            npc_id = self._npcId,
            sweep_count = 1,
            items = {},
        }
        uq.ModuleManager:getInstance():show(uq.ModuleManager.NPC_SWEEP_MODULE, data)
    else
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
        uq.fadeInfo(StaticData['local_text']['instance.pass.tip'])
    end
end

function NPCInfoModule:_doBattle(attack_type, count)
    local npc_data = uq.cache.instance:getNPC(self._instanceId, self._npcId)

    if self._xmlData.qtyLimit ~= 0 and npc_data.atk_num >= self._xmlData.qtyLimit then
        uq.fadeInfo(StaticData['local_text']['crop.redbag.send.num.not'])
        return
    end

    local pre_id = self._xmlData.premiseObjectId
    if pre_id > 0 then
        local pre_npc_data = uq.cache.instance:getNPC(self._instanceId, pre_id)
        if pre_npc_data.star <= 0 then
            uq.fadeInfo(StaticData['local_text']['instance.pass.pre.first'])
            return
        end
    end

    if attack_type == 0 then
        local packet = {instance_id = self._instanceId, npc_id = self._npcId, count = count}
        network:sendPacket(Protocol.C_2_S_INSTANCE_SWEEP, packet)
    else
        local packet = {instance_id = self._instanceId, npc_id = self._npcId}
        network:sendPacket(Protocol.C_2_S_INSTANCE_BATTLE, packet)
    end
end

function NPCInfoModule:_onBattleDropInfo(evt)
    local data = evt.data
end

function NPCInfoModule:_onGuideInfo(evt)
    services:dispatchEvent({name = services.EVENT_NAMES.ON_STRATEGY_INFO, data = evt.data})
end

function NPCInfoModule:_doViewGuide(event)
    if event.name ~= "ended" then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.NPC_GUIDE_MODULE)
    network:sendPacket(Protocol.C_2_S_INSTANCE_STRATEGY, {npc_id = self._npcId})
end

function NPCInfoModule:onExit()
    services:removeEventListenersByTag(self._eventClose)
    network:removeEventListenerByTag('_onInstanceBattleDropInfo')
    network:removeEventListenerByTag('_onInstanceGuideInfo')
    services:dispatchEvent({name = services.EVENT_NAMES.ON_SHOW_MAIN_UI})
    services:removeEventListenersByTag('_onSendBattleReport')
    services:removeEventListenersByTag(self._eventBuy)
    services:removeEventListenersByTag(self._eventTag)
    NPCInfoModule.super.onExit(self)
end

function NPCInfoModule:onCloseEevent()
    local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.ARRANGED_BEFORE_WAR)
    if panel then
        panel:disposeSelf()
    end
    self:disposeSelf()
end

function NPCInfoModule:onAddMillitory(event)
    if event.name == "ended" then
        uq.jumpToModule(uq.config.constant.MODULE_ID.BUY_MILITORY_ORDER)
    end
end

function NPCInfoModule:getDefultTroop()
    local xml_data = StaticData['instance'][self._instanceId]
    return StaticData.load('instance/' .. xml_data.fileId).Map[self._instanceId].Object[self._npcId].troops or 0
end

return NPCInfoModule