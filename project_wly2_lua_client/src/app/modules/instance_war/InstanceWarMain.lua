local InstanceWarMain = class("InstanceWarMain", require('app.modules.common.BaseViewWithHead'))

InstanceWarMain.RESOURCE_FILENAME = "instance_war/InstanceWarMain.csb"
InstanceWarMain.RESOURCE_BINDING = {
    ["Node_22"]            = {["varname"] = "_nodeRightBottom"},
    ["Node_1"]             = {["varname"] = "_nodeCity"},
    ["Node_2"]             = {["varname"] = "_nodeLeftMiddle"},
    ["Node_3"]             = {["varname"] = "_nodeLeftBottom"},
    ["Image_1"]            = {["varname"] = "_imgBg",["events"] = {{["event"] = "touch",["method"] = "onBgTouch"}}},
    ["open_general"]       = {["varname"] = "_btnGeneral",["events"] = {{["event"] = "touch",["method"] = "openViewByTag"}}},
    ["open_warehouse"]     = {["varname"] = "_btnWareHouse",["events"] = {{["event"] = "touch",["method"] = "openViewByTag"}}},
    ["Button_1"]           = {["varname"] = "_btnOverRound",["events"] = {{["event"] = "touch",["method"] = "onOverRound"}}},
    ["open_battle_report"] = {["varname"] = "_btnRound",["events"] = {{["event"] = "touch",["method"] = "onRound"}}},
    ["Text_1"]             = {["varname"] = "_txtRound"},
    ["Button_2"]           = {["varname"] = "_btnSurrneder",["events"] = {{["event"] = "touch",["method"] = "onSurrender"}}},
    ["Image_2"]            = {["varname"] = "_imgEffect"},
    ["city_desc"]          = {["varname"] = "_imgCityDesc"},
}

function InstanceWarMain:ctor(name, params)
    InstanceWarMain.super.ctor(self, name, params)
    self._curCity = 0
    self._instanceId = params.instance_id
    self._instanceData = StaticData['instance_war'][self._instanceId]
    self._curMapData = StaticData.load('campaigns/' .. self._instanceData.fileId).Map[self._instanceId]

    self:setTitleText(string.subUtf(self._instanceData.name, 5, 4))

    network:sendPacket(Protocol.C_2_S_CAMPAIGN_ACTION_LOAD)
    network:sendPacket(Protocol.C_2_S_CAMPAIGN_CITY_LOAD)
    network:sendPacket(Protocol.C_2_S_CAMPAIGN_RESOURCE_LOAD)
    network:sendPacket(Protocol.C_2_S_CAMPAIGN_GENERAL_LOAD)

    self._eventTagLoad = services.EVENT_NAMES.ON_INSTANCE_WAR_CITY_LOAD .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_INSTANCE_WAR_CITY_LOAD, handler(self, self.updateCityInfo), self._eventTagLoad)

    self._eventTagRefresh = services.EVENT_NAMES.ON_INSTANCE_WAR_CITY_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_INSTANCE_WAR_CITY_REFRESH, handler(self, self.refreshCityInfo), self._eventTagRefresh)
end

function InstanceWarMain:init()
    self._fireEffect = {}
    self._arrowEffect = {}
    self:centerView()
    local coin_group = {
        uq.config.constant.COST_RES_TYPE.FOOD,
        uq.config.constant.COST_RES_TYPE.GESTE,
    }
    self:addShowCoinGroup(coin_group, uq.config.constant.GAME_MODE.INSTANCE_WAR)
    self:parseView()
    self:adaptNode()

    for k, item in pairs(self._curMapData.Object) do
        local img_bg = self._nodeCity:getChildByName('b' .. item.city)
        local img_select = self._nodeCity:getChildByName('s' .. item.city)
        img_bg:setLocalZOrder(-100)
        img_select:setLocalZOrder(-100)
    end
    self:refreshCurCity(false)
    self:refreshCityInfo()

    self:setPlayerName(uq.cache.role.name)

    self._init = false
    self._imgCityDesc:setVisible(false)
end

function InstanceWarMain:updateCityInfo()
    for k, item in pairs(self._curMapData.Object) do
        local img_bg = self._nodeCity:getChildByName('b' .. item.city)
        local img_select = self._nodeCity:getChildByName('s' .. item.city)

        local city_data = uq.cache.instance_war:getCityData(item.city)
        if city_data and city_data.power > 0 then
            img_bg:setLocalZOrder(100)
            img_bg:setOpacity(127.5)
            img_bg:setColor(uq.parseColor(StaticData['instance_power'][city_data.power].color))
        else
            img_bg:setOpacity(255)
            img_bg:setColor(uq.parseColor('ffffff'))
            img_bg:setLocalZOrder(-100)
        end

        local img_desc = self._imgEffect:getChildByName('img_desc' .. item.city)
        if not img_desc then
            img_desc = self._imgCityDesc:clone()
            img_desc:setName('img_desc' .. item.city)
            local instance_data = StaticData['instance_city'][item.city]
            img_desc:setPosition(cc.p(instance_data.X + 3, instance_data.Y + 15))
            img_desc:setVisible(true)
            self._imgEffect:addChild(img_desc)
        end
        img_desc:setVisible(true)
        if city_data.soldier > 0 then
            img_desc:getChildByName('soldier'):setVisible(true)
            img_desc:getChildByName('soldier'):setString(city_data.soldier)
        else
            img_desc:getChildByName('soldier'):setVisible(false)
        end

        if #city_data.generals > 0 then
            img_desc:getChildByName('Image_5'):setVisible(true)
        else
            img_desc:getChildByName('Image_5'):setVisible(false)
        end

        if #city_data.generals == 0 and city_data.soldier == 0 then
            img_desc:setVisible(false)
        end
    end
    self:removeKnife()
    -- self:refreshCurCity(false)
    self._txtRound:setString(string.format('%d/%d', uq.cache.instance_war._curRound, self._curMapData.Round))

    if not self._init then
        local power_data = uq.cache.instance_war:getPowerConfig(self._instanceId, 1)
        self:setSelect(power_data.city)
        self._init = true
    end
end

function InstanceWarMain:removeKnife()
    for k, item in pairs(self._curMapData.Object) do
        if self:getChildByName('knife_conquer_effect' .. item.city) then
            self:getChildByName('knife_conquer_effect' .. item.city):removeSelf()
        end
        if self:getChildByName('knife_move_effect' .. item.city) then
            self:getChildByName('knife_move_effect' .. item.city):removeSelf()
        end
    end
end

function InstanceWarMain:conquerCallback()
    self:removeKnife()

    local show = false
    local city_data = uq.cache.instance_war:getCityData(self._curCity)
    if city_data.power == 1 then
        local city_info = StaticData['instance_city'][self._curCity]
        local next_citys = string.split(city_info.nextId, ',')
        for k, item in ipairs(next_citys) do
            local next_city = tonumber(item)
            local city_next_info = StaticData['instance_city'][next_city]
            local city_next_data = uq.cache.instance_war:getCityData(next_city)
            if city_next_data and city_next_data.power ~= 1 then
                local img_bg = self._nodeCity:getChildByName('b' .. next_city)
                local effect = uq.createPanelOnly('instance.AnimationKnife')
                effect:setName('knife_conquer_effect' .. next_city)
                local x, y = img_bg:getPosition()
                local pos = img_bg:getParent():convertToWorldSpace(cc.p(x, y))
                effect:setPosition(cc.p(pos.x - display.width / 2, pos.y - display.height / 2))
                self:addChild(effect)
                show = true
            end
        end
    end

    if not show then
        uq.fadeInfo('无可攻击城市')
    end

    if self._popMenu then
        self._popMenu:setVisible(false)
    end
end

function InstanceWarMain:moveCallback()
    self:removeKnife()

    local show = false
    local city_data = uq.cache.instance_war:getCityData(self._curCity)
    if city_data.power == 1 then
        local city_info = StaticData['instance_city'][self._curCity]
        local next_citys = string.split(city_info.nextId, ',')
        for k, item in ipairs(next_citys) do
            local next_city = tonumber(item)
            local city_next_info = StaticData['instance_city'][next_city]
            local city_next_data = uq.cache.instance_war:getCityData(next_city)
            --只能调动到相邻城池
            if city_next_data and city_next_data.power == 1 then
                local img_bg = self._nodeCity:getChildByName('b' .. next_city)
                local effect = uq.createPanelOnly('instance.AnimationKnife')
                effect:setName('knife_move_effect' .. next_city)
                local x, y = img_bg:getPosition()
                local pos = img_bg:getParent():convertToWorldSpace(cc.p(x, y))
                effect:setPosition(cc.p(pos.x - display.width / 2, pos.y - display.height / 2))
                self:addChild(effect)
                show = true
            end
        end
    end

    if not show then
        uq.fadeInfo('无可调动城市')
    end

    if self._popMenu then
        self._popMenu:setVisible(false)
    end
end

function InstanceWarMain:refreshCurCity(show)
    local img_select = self._nodeCity:getChildByName('s' .. self._curCity)
    if img_select then
        if show then
            img_select:setLocalZOrder(100)
            if not self._npcInfo then
                self._npcInfo = uq.createPanelOnly('instance_war.InstanceWarNpcInfo')
                self._nodeLeftMiddle:addChild(self._npcInfo)
                self._npcInfo:setPosition(cc.p(120, 80))
            end
            self._npcInfo:setVisible(true)
            self._npcInfo:setData(self._curMapData.Object[self._instanceId * 100 + self._curCity])

            local effect = self._imgEffect:getChildByName('effect')
            if not effect then
                effect = uq:addEffectByNode(self._imgEffect, 900186, -1, true)
                effect:setName('effect')
            end
            local instance_data = StaticData['instance_city'][self._curCity]
            effect:setPosition(cc.p(instance_data.X + 1.5, instance_data.Y + 1.5))
        else
            img_select:setLocalZOrder(-100)
            if self._npcInfo then
                self._npcInfo:setVisible(false)
            end
            if self._imgEffect:getChildByName('effect') then
                self._imgEffect:getChildByName('effect'):removeSelf()
            end
        end
    end
end

function InstanceWarMain:refreshCityInfo()
    for k, city_id in ipairs(self._fireEffect) do
        local effect = self._imgEffect:getChildByName('fire_effect' .. city_id)
        if effect then
            effect:removeSelf()
        end
    end
    self._fireEffect = {}

    for effect_name, item in pairs(uq.cache.instance_war._roundBattleAcion) do
        local strs = string.split(effect_name, '_')
        local to_city_id = tonumber(strs[1])
        local effect = self._imgEffect:getChildByName('fire_effect' .. to_city_id)
        if not effect then
            local instance_data = StaticData['instance_city'][to_city_id]
            effect = uq:addEffectByNode(self._imgEffect, 900188, -1, true)
            effect:setName('fire_effect' .. to_city_id)
            effect:setPosition(cc.p(instance_data.X + 3, instance_data.Y + 15))
            table.insert(self._fireEffect, to_city_id)
        end
    end

    for k, city_id in ipairs(self._arrowEffect) do
        local effect = self._imgEffect:getChildByName('arrow_effect' .. city_id)
        if effect then
            effect:removeEffect()
            effect:removeSelf()
        end
    end
    self._arrowEffect = {}
    for effect_name, item in pairs(uq.cache.instance_war._roundBattleAcion) do
        local strs = string.split(effect_name, '_')
        local to_city_id = tonumber(strs[1])
        local from_city_id = tonumber(strs[2])
        local panel_arrow = self._imgEffect:getChildByName('arrow_effect' .. effect_name)
        if not panel_arrow then
            panel_arrow = uq.createPanelOnly('instance_war.InstanceWarArrow')
            panel_arrow:setName('arrow_effect' .. effect_name)
            table.insert(self._arrowEffect, effect_name)
            local to_data = StaticData['instance_city'][to_city_id]
            local from_data = StaticData['instance_city'][from_city_id]

            local cur_pos = cc.p(from_data.X, from_data.Y)
            local dest_pos = cc.p(to_data.X, to_data.Y)
            self._imgEffect:addChild(panel_arrow)
            local normal = cc.pNormalize(cc.pSub(dest_pos, cur_pos))
            local angle = math.atan2(normal.y, normal.x) * 180 / math.pi
            panel_arrow:setRotation(-angle + 180)
            panel_arrow:setData(dest_pos, cur_pos)
        end
    end
end

function InstanceWarMain:showPopmenu(show)
    if show then
        if not self._popMenu then
            self._popMenu = uq.createPanelOnly('instance_war.InstanceWarPopMenu')
            self:addChild(self._popMenu, 100)
        end

        local img_bg = self._nodeCity:getChildByName('b' .. self._curCity)
        local x, y = img_bg:getPosition()
        local pos = img_bg:getParent():convertToWorldSpace(cc.p(x, y))
        local posx = pos.x - display.width / 2
        local posy = pos.y - display.height / 2

        if posx > display.width / 2 - 85 then
            posx = posx - 85
        end

        if posy > display.height / 2 - 100 then
            posy = posy - 70
        end
        self._popMenu:setPosition(cc.p(posx, posy))
        self._popMenu:setVisible(true)
        self._popMenu:setData(self._curMapData.Object[self._instanceId * 100 + self._curCity], handler(self, self.conquerCallback), handler(self, self.moveCallback))
    else
        if self._popMenu then
            self._popMenu:setVisible(false)
        end
    end
end

function InstanceWarMain:onCreate()
    InstanceWarMain.super.onCreate(self)
end

function InstanceWarMain:onExit()
    services:removeEventListenersByTag(self._eventTagLoad)
    services:removeEventListenersByTag(self._eventTagRefresh)

    InstanceWarMain.super.onExit(self)
end

function InstanceWarMain:onBgTouch(event)
    if event.name ~= "ended" then
        return
    end
    self:showPopmenu(false)

    local pos = event.target:getTouchEndPosition()
    local pos_world = event.target:getParent():convertToWorldSpace(pos)
    pos_world = cc.p(pos_world.x - display.width / 2, pos_world.y - display.height / 2)
    local pos_node = self._nodeCity:convertToNodeSpace(pos_world)
    for i = 1, 40 do
        local img_bg = self._nodeCity:getChildByName('b' .. i)
        local size = img_bg:getContentSize()
        local x, y = img_bg:getPosition()
        local rect = cc.rect(x - size.width / 2, y - size.height / 2, size.width, size.height)
        if cc.rectContainsPoint(rect, pos_node) and uq.alphaTouchCheck(img_bg, img_bg:convertToNodeSpace(pos_world)) then
            self:setSelect(i)
            break
        end
    end
    self:removeKnife()
end

function InstanceWarMain:setSelect(index)
    if self:getChildByName('knife_conquer_effect' .. index) then
        self:doAttack(index)
    elseif self:getChildByName('knife_move_effect' .. index) then
        self:doMove(index)
    else
        if self._curCity ~= index then
            self:refreshCurCity(false)
            self._curCity = index
            self:refreshCurCity(true)
        end
        self:showPopmenu(true)
    end
end

function InstanceWarMain:doAttack(city_id)
    local army_data = {
        ids    = {1},
        array  = {'army_1'},
        army_1 = {}
    }
    local city_data = uq.cache.instance_war:getCityData(city_id)
    local enemy_data = {}
    for k, item in ipairs(city_data.troops) do
        local troop_data = uq.cache.instance_war:getTroopConfig(self._instanceId, item)
        table.insert(enemy_data, troop_data.Army)
    end
    if #city_data.troops == 0 then
        enemy_data = {{}}
    end

    local npc_data = self._curMapData.Object[self._instanceId * 100 + city_id]
    local data = {
        army_data = {army_data},
        enemy_data = enemy_data,
        embattle_type = uq.config.constant.TYPE_EMBATTLE.INSTANCE_WAR,
        confirm_callback = handler(self, self.formationEnd),
        mode = uq.config.constant.GAME_MODE.INSTANCE_WAR,
        from_city = self._curCity,
        to_city = city_id,
        npc_data = npc_data
    }
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ARRANGED_BEFORE_WAR, data)
end

function InstanceWarMain:doMove(city_id)
    local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.INSTANCE_WAR_MOVE, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
    panel:setData(self._curCity, city_id)
end

function InstanceWarMain:formationEnd(formation_info)
    uq.ModuleManager:getInstance():dispose(uq.ModuleManager.ARRANGED_BEFORE_WAR)
    local formation = formation_info
    local generals = {}
    for k, item in ipairs(formation.general_loc) do
        table.insert(generals, {general_id = item.general_id, pos = item.index})
    end

    local data = {
        from_city_id = formation.from_id,
        to_city_id = formation.to_city,
        formation_id = formation.formation_id,
        count = #formation.general_loc,
        generals = generals
    }
    network:sendPacket(Protocol.C_2_S_CAMPAIGN_BATTLE, data)
end

function InstanceWarMain:openViewByTag(event)
    if event.name == "ended" then
        local tag = event.target:getTag()
        uq.jumpToModule(tag, {mode = uq.config.constant.GAME_MODE.INSTANCE_WAR})
    end
end

function InstanceWarMain:onOverRound(event)
    if event.name ~= 'ended' then
        return
    end

    local function confirm()
        network:sendPacket(Protocol.C_2_S_CAMPAIGN_ROUND_END)
    end

    local str = '是否结束当前回合？'
    local data = {
        content = str,
        confirm_callback = confirm,
    }
    uq.addConfirmBox(data)
end

function InstanceWarMain:onRound(event)
    if event.name == "ended" then
        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.INSTANCE_WAR_BATTLE_LIST)
        panel:setData()
    end
end

function InstanceWarMain:onSurrender(event)
    if event.name ~= "ended" then
        return
    end

    local function confirm()
        network:sendPacket(Protocol.C_2_S_CAMPAIGN_SURRENDER)
    end

    local str = '投降将结束本轮回合，是否投降？'
    local data = {
        content = str,
        confirm_callback = confirm,
    }
    uq.addConfirmBox(data)
end

return InstanceWarMain