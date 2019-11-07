local WorldModule = class("WorldModule", require('app.base.ModuleBase'))

function WorldModule:onCreate()
    WorldModule.super.onCreate(self)
    self._timerFlag = 'timer_flag' .. tostring(self)
    self._timerChangeFlag = 'timer_flag_change' .. tostring(self)
    uq.playSoundByID(101)
    self:setBaseBgVisible(false)
    self._buildings = {}
    self._movingList = {}
    self._movingListMask = {}
    self._mapScene = uq.ui.MapScene:createMap(nil, 1)
    self:addChild(self._mapScene)
    self._mapScene:setMapScale(true)
    self._mapScene:addMapClickEventListener(handler(self, self._onClick))
    self._mapScene:addMapMoveEventListener(handler(self, self._onBGMove))
    self._mapScene:addMapScaleEventListener(handler(self, self._onBGScale))

    self._mainView = uq.createPanelOnly('main_city.MainCityView')
    self._mainView:setEnterMainCity()
    self:addChild(self._mainView)
    self._mainView:setNodeTopLeftInfoVisible(false)
    self._mainView:setNodeBottomLeftInfoVisible(false)
    self._mainView:setNodeBottomRightVisible(false)
    self._mainView:showWorldOnly(true)
    self._mainView:setRightMiddleVisible(false)
    self._mainView:setLeftMiddleVisible(false)
    self._mainView:setNodePopVisible(false)

    self._uiView = uq.createPanelOnly('world.WorldView')
    self:addChild(self._uiView)

    self._miniMap = uq.createPanelOnly('world.WorldMiniMap')
    local size = self._miniMap:getContentSize()
    self._miniMap:setPosition(cc.p(size.width / 2 + 20, display.height - 250 + size.height / 2))
    self:addChild(self._miniMap)
    self._miniMap:setMapScene(self._mapScene)
    self._miniMap:setMapScale(self._mapScene:getMapConfig().normal)
    self._stateNode = cc.Node:create()
    self._stateNode:setPosition(cc.p(size.width + 120, display.height - 160 + size.height / 2))
    self:addChild(self._stateNode)
    for k, item in pairs(StaticData['world_city']) do
        self:addBuild({id = k})
    end
    self._isClick = false
    self._oldBuildData = nil
    self._buildPos = cc.p(display.width * 0.5, display.height * 0.5)
    self._oldBuild = nil
    self:loadSoldier()
    self:showCloud()
    self:initProtocol()
    self:onShowUI()
    self._isNightBattle = false
    local tab_server_time = os.date("*t", uq.cache.server_data:getServerTime())
    if tab_server_time.hour < 8 then
        self._isNightBattle = true
    end
    uq.TimerProxy:addTimer(self._timerChangeFlag, handler(self , self.onChangeTimer), 1, -1)
end

function WorldModule:onChangeTimer()
    local tab_server_time = os.date("*t", uq.cache.server_data:getServerTime())
    if tab_server_time.hour < 8 and not self._isNightBattle then
        self._isNightBattle = true
        services:dispatchEvent({name = services.EVENT_NAMES.ON_BATTLE_NIGHT_CHANGE})
        self:updateState()
    elseif tab_server_time.hour >= 8 and self._isNightBattle then
        self._isNightBattle = false
        services:dispatchEvent({name = services.EVENT_NAMES.ON_BATTLE_NIGHT_CHANGE})
        self:updateState()
    end
end

function WorldModule:loadSoldier()
    local soldier = StaticData['soldier'][11]
    self._action1 = string.format('%s_%d', soldier.action, 3)
    uq.AnimationManager:getInstance():getAction('soldier', self._action1)

    local soldier2 = StaticData['soldier'][16]
    self._action2 = string.format('%s_%d', soldier2.action, 3)
    uq.AnimationManager:getInstance():getAction('soldier', self._action2)
end

function WorldModule:showCloud()
    self._popupLayer = ccui.Layout:create()
    self._popupLayer:setTouchEnabled(true)
    self._popupLayer:ignoreContentAdaptWithSize(false)
    self._popupLayer:setContentSize(cc.size(display.width, display.height))
    self:addChild(self._popupLayer)
    self._topRight = ccui.ImageView:create("img/world/s05_00061_4.png")
    self._topRight:setAnchorPoint(cc.p(0.5, 0.5))
    self._topRight:setPosition(cc.p(900, display.height - 200))
    self:addChild(self._topRight)
    self._topLeft = ccui.ImageView:create("img/world/s05_00061_2.png")
    self._topLeft:setAnchorPoint(cc.p(0.5, 0.5))
    self._topLeft:setPosition(cc.p(430, display.height - 180))
    self:addChild(self._topLeft)
    self._bottomLeft = ccui.ImageView:create("img/world/s05_00061_3.png")
    self._bottomLeft:setAnchorPoint(cc.p(0.5, 0.5))
    self._bottomLeft:setPosition(cc.p(200, display.height - 550))
    self:addChild(self._bottomLeft)
    self._bottomRight = ccui.ImageView:create("img/world/s05_00061_1.png")
    self._bottomRight:setAnchorPoint(cc.p(0.5, 0.5))
    self._bottomRight:setPosition(cc.p(950, display.height - 600))
    self:addChild(self._bottomRight)
end

function WorldModule:onShowUI()
    self._uiView:showView(true)
    self._mainView:setNodeLeftTop(true)
    self._mainView:setNodeRightBottom(true)
    self._mainView:setNodeRightTop(true)
    self._miniMap:setVisible(true)
end

function WorldModule:onHideUI()
    self._uiView:showView(false)
    self._mainView:setNodeLeftTop(false)
    self._mainView:setNodeRightBottom(false)
    self._mainView:setNodeRightTop(false)
    self._miniMap:setVisible(false)
end

function WorldModule:updateState()
    self._stateNode:removeAllChildren()
    local img = ccui.ImageView:create("img/crop/s02_00047.png")
    img:setTouchEnabled(true)
    img:addClickEventListenerWithSound(function(sender)
        local info = StaticData['rule'][uq.config.constant.MODULE_RULE_ID.WORLD]
        if not info then
            return
        end
        uq.ModuleManager:getInstance():show(uq.ModuleManager.ANCIENT_CITY_RULE, {info = info})
    end)
    local pos_x = 0
    self._stateNode:addChild(img)
    pos_x = pos_x + 60
    local tab_server_time = os.date("*t", uq.cache.server_data:getServerTime())
    if tab_server_time.hour < 8 then
        local item1 = self:getStatusItem()
        item1:setPositionX(pos_x)
        item1:setScale(0.8)
        item1:setType(1)
        self._stateNode:addChild(item1)
        pos_x = pos_x + 60
    end

    if uq.cache.world_war.world_enter_info.move_times == 0 then
        local item2 = self:getStatusItem()
        item2:setPositionX(pos_x)
        self._stateNode:addChild(item2)
        item2:setType(2)
        item2:setScale(0.8)
        pos_x = pos_x + 60
    end

    if uq.cache.world_war.world_enter_info.develop_count == 0 then
        local item2 = self:getStatusItem()
        item2:setPositionX(pos_x)
        self._stateNode:addChild(item2)
        item2:setType(3)
        item2:setScale(0.8)
        pos_x = pos_x + 60
    end
end

function WorldModule:getStatusItem()
    local item1 = uq.createPanelOnly('world.CityStatusItem')
    item1:setClick()
    return item1
end

function WorldModule:onDeclareWar(info)
    if self._movingListMask[info.role_id] ~= nil and self._movingListMask[info.role_id][info.army_id] ~= nil then
        return
    end
    local soldier = uq.createPanelOnly('world.WorldSoldier')
    local size = self._mapScene:getMapContentSize()
    self._mapScene:addMapChild(soldier)
    soldier:setInfo(info, size)
    if self._movingListMask[info.role_id] == nil then
        self._movingListMask[info.role_id] = {}
    end
    self._movingListMask[info.role_id][info.army_id] = true
    table.insert(self._movingList, soldier)
end

function WorldModule:onExit()
    network:sendPacket(Protocol.C_2_S_NATION_BATTLE_VIEW, {op_type = 0, city_id = 0}) --退出世界地图
    services:removeEventListenersByTag(self._worldMovingChangeTag)
    services:removeEventListenersByTag(self._worldCityCloseTag)
    services:removeEventListenersByTag(self._pressMiniPos)
    services:removeEventListenersByTag(self._worldArmyTag)
    services:removeEventListenersByTag(self._worldInfoTag)
    services:removeEventListenersByTag(self._worldEnterTag)
    services:removeEventListenersByTag(self._worldCityPos)
    services:removeEventListenersByTag(self._worldMovingListTag)
    services:removeEventListenersByTag(self._changeCityState)
    services:removeEventListenersByTag(self._worldMoveEndTag)
    services:removeEventListenersByTag(self._worldDevelopTag)
    uq.TimerProxy:removeTimer(self._timerFlag)
    uq.TimerProxy:removeTimer(self._timerChangeFlag)
    WorldModule.super.onExit(self)
end

function WorldModule:onBattleWorldEnter()
    self:updateState()
    local delta = 1 / 12
    local city_id = uq.cache.world_war.move_city_id == 0 and uq.cache.world_war.world_enter_info.city_id or uq.cache.world_war.move_city_id
    local city_info = StaticData['world_city'][city_id]
    local size = self._mapScene:getMapContentSize()
    local px = city_info.pos_x - size.width / 2
    local py = -city_info.pos_y + size.height / 2
    local pos = display.center
    self._buildPos = cc.p(px, py)
    local pos_build = self._mapScene:convertToMapWorldSpace(cc.p(px, py))
    self._mapScene:updateMapPosition(pos.x - pos_build.x, pos.y - pos_build.y)
    self._mapScene:updateScale(self._mapScene:getMapConfig().small, self._buildPos)
    self._topRight:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
        local speed = (self._mapScene:getMapConfig().normal - self._mapScene:getMapConfig().small) / (6 * delta)
        self._mapScene:changeScaleAction(self._mapScene:getMapConfig().normal, self._buildPos, speed)
        self._topRight:runAction(cc.Sequence:create(cc.MoveTo:create(4 * delta, cc.p(1150, display.height - 200)), cc.MoveTo:create(8 * delta, cc.p(2050, display.height - 200)), cc.CallFunc:create(function()
            self._topRight:removeSelf()
        end)))
        self._topLeft:runAction(cc.Sequence:create(cc.MoveTo:create(3 * delta, cc.p(300, display.height - 180)), cc.MoveTo:create(13 * delta, cc.p(-550, display.height - 180)), cc.CallFunc:create(function()
            self._topLeft:removeSelf()
        end)))
        self._bottomLeft:runAction(cc.Sequence:create(cc.MoveTo:create(5 * delta, cc.p(120, display.height - 550)) , cc.MoveTo:create(9 * delta, cc.p(-720, display.height - 550)), cc.CallFunc:create(function()
            self._bottomLeft:removeSelf()
        end)))
        self._bottomRight:runAction(cc.Sequence:create(cc.MoveTo:create(4 * delta, cc.p(1150, display.height - 600)), cc.MoveTo:create(12 * delta, cc.p(2100, display.height - 600)), cc.CallFunc:create(function()
            self._bottomRight:removeSelf()
            self._popupLayer:removeSelf()
        end)))
    end)))
end

function WorldModule:onTimer(timer, dt)
    for k, v in pairs(self._movingList) do
        if v then
            v:timer(dt)
        end
    end
    for k, v in pairs(self._buildings) do
        v.build:timer(dt)
    end
end

function WorldModule:onMovingList()
    for k, v in pairs(uq.cache.world_war.map_moving_list) do
        for k2, v2 in pairs(v) do
            if next(v2) ~= nil then
                self:onDeclareWar(v2)
            end
        end
    end
    if not uq.TimerProxy:hasTimer(self._timerFlag) then
        uq.TimerProxy:addTimer(self._timerFlag, handler(self , self.onTimer), 0, -1)
    end
end

function WorldModule:onChangeCityState()
    for k, v in pairs(self._buildings) do
        v.build:updateState()
    end
end

function WorldModule:onMoveEnd(msg)
    for k, v in ipairs(msg.data) do
        if self._movingListMask[v.role_id] ~= nil then
            self._movingListMask[v.role_id][v.army_id] = nil
        end
        for k2, move_item in ipairs(self._movingList) do
            local info = move_item:getInfo()
            if v.role_id == info.role_id and v.army_id == info.army_id then
                move_item:endPath()
                table.remove(self._movingList, k2)
                break
            end
        end
    end
end

function WorldModule:onBattleWorldInfo()
    if uq.cache.world_war.world_city_info == nil then
        return
    end
    for k, v in pairs(uq.cache.world_war.world_city_info) do
        if next(v) ~= nil and self._buildings[v.city_id] then
            self._buildings[v.city_id].build:setInfo(uq.cache.world_war.world_city_info[k])
        end
    end
    self._miniMap:updateCity()
end

function WorldModule:onBattleArmyUpdate(msg)
    for k, v in pairs(msg.data.citys) do
        if self._buildings[v.city_id] then
            self._buildings[v.city_id].build:updateSoldierNum(v.defend_num, v.attack_num)
        end
    end
end

function WorldModule:onBattleWorldCityPos(msg)
    if self._buildings[msg.data.cur_city] then
        local build_data = self._buildings[msg.data.cur_city]
        self._mapScene:setTouchState(false)
        build_data.build:onClick()
        services:dispatchEvent({name = services.EVENT_NAMES.ON_WORLD_CITY_SELECT})
        if not self._isClick then
            self:onHideUI()
            self._isClick = true
        end
        local item_build = build_data.build
        local x, y = item_build:getPosition()
        self:moveToCity(build_data, display.center, true, true, 1.3)
    end
end

function WorldModule:addBuild(build_data)
    if self._buildings[build_data.id] then
        self._buildings[build_data.id].build:setData(build_data)
        return
    end

    local temp = StaticData['world_city'][build_data.id]
    if temp == nil then
        return
    end
    local size = self._mapScene:getMapContentSize()
    local px = temp.pos_x - size.width / 2
    local py = -temp.pos_y + size.height / 2

    local build = uq.createPanelOnly("world.WorldCity")
    build:setData(temp)
    build:setPosition(cc.p(px, py))
    self._mapScene:addMapChild(build)
    build_data.build = build
    self._buildings[build_data.id] = build_data
end

function WorldModule:onPressMiniPos(msg)
    local pos = display.center
    local world_pos = self._mapScene:convertToMapWorldSpace(msg.pos)
    self._mapScene:updateMapPosition(pos.x - world_pos.x, pos.y - world_pos.y, false)
end

function WorldModule:_onClick(pos)
    local build_data = nil
    for _, v in pairs(self._buildings) do
        local p = cc.p(v.build:getPositionX(), v.build:getPositionY())
        local size = v.build:getIcon():getContentSize()
        local rect = cc.rect(p.x - size.width / 2, p.y - size.height / 2, size.width, size.height)
        if cc.rectContainsPoint(rect, pos) then
            build_data = v
            uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
            break
        end
    end

    self:removePopMenu()
    if build_data then
        self._mapScene:setTouchState(false)
        build_data.build:onClick()
        services:dispatchEvent({name = services.EVENT_NAMES.ON_WORLD_CITY_SELECT})
        if not self._isClick then
            self:onHideUI()
            self._isClick = true
        end
        local item_build = build_data.build
        local x, y = item_build:getPosition()
        self:moveToCity(build_data, display.center, true, true, 1.3)
    else
        if self._isClick then
            self._mapScene:setTouchState(true)
            self:onShowUI()
            self:returnToDefault()
            self._isClick = false
        end
    end
end

function WorldModule:moveToCity(build_data, pos, moved, is_scale, scale)
    moved = moved == nil and true or moved
    is_scale = is_scale == nil and true or is_scale
    pos = pos or cc.p(476, 500)

    local build_data = build_data
    local x, y = build_data.build:getPosition()

    if is_scale then
        self._mapScene:returnToInit(cc.p(x, y), true)
        self._mapScene:updateMapScale(scale, cc.p(x, y), true)
    end
    local pos_build = self._mapScene:convertToMapWorldSpace(cc.p(x, y))
    self._oldPos = pos_build
    self._oldBuildData = build_data
    self._mapScene:updateMapPosition(pos.x - pos_build.x, pos.y - pos_build.y, moved)
end

function WorldModule:returnToDefault()
    local build_data = self._oldBuildData
    local x, y = build_data.build:getPosition()
    self._mapScene:returnToInit(cc.p(x, y), true)

    local pos_build = self._mapScene:convertToMapWorldSpace(cc.p(x, y))
    local pos_bg = self._oldPos
    self._mapScene:updateMapPosition(pos_bg.x - pos_build.x, pos_bg.y - pos_build.y, true)
    self._oldBuildData = nil
end

function WorldModule:removePopMenu()
    for _, v in pairs(self._buildings) do
        v.build:removePopMenu()
    end
end

function WorldModule:_onBGMove(pos)
    self._miniMap:setDrawNodePosition()
    self._uiView:onCloseArmyItemView()
end

function WorldModule:_onBGScale(scale)
    self._miniMap:setMapScale(scale)
end

function WorldModule:onMovingChange(msg)
    self._uiView:updateRightArmyView()
    local info_array = uq.cache.world_war.cur_army_info
    local cur_city = 0
    for k, v in ipairs(info_array) do
        local info = info_array[k]
        if #info.generals > 0 then
            cur_city = info.cur_city
            break
        end
    end
    if cur_city == 0 then
        cur_city = uq.cache.world_war.world_enter_info.city_id
    end
    if self._buildings[cur_city] == nil then
        return
    end
    if self._oldBuild then
        self._oldBuild.build:updateSelfBgState(false)
    end
    self._buildings[cur_city].build:updateSelfBgState(true)
    self._oldBuild = self._buildings[cur_city]
end

function WorldModule:onCloseCityView()
    self:removePopMenu()
    self._mapScene:setTouchState(true)
    self:onShowUI()
    self:returnToDefault()
    self._isClick = false
end

function WorldModule:initProtocol()
    self._pressMiniPos = services.EVENT_NAMES.ON_PRESS_MINI_MAP_POS .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_PRESS_MINI_MAP_POS, handler(self, self.onPressMiniPos), self._pressMiniPos)

    self._worldCityCloseTag = services.EVENT_NAMES.ON_WORLD_CITY_CLOSE .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_WORLD_CITY_CLOSE, handler(self, self.onCloseCityView), self._worldCityCloseTag)

    self._worldMovingChangeTag = services.EVENT_NAMES.ON_WORLD_MOVING_STATE_CHANGE .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_WORLD_MOVING_STATE_CHANGE, handler(self, self.onMovingChange), self._worldMovingChangeTag)

    self._worldInfoTag = services.EVENT_NAMES.ON_WORLD_BATTLE_INFO .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_WORLD_BATTLE_INFO, handler(self, self.onBattleWorldInfo), self._worldInfoTag)

    self._worldArmyTag = services.EVENT_NAMES.ON_BATTLE_ARYM_UPDATE .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_BATTLE_ARYM_UPDATE, handler(self, self.onBattleArmyUpdate), self._worldArmyTag)

    self._worldEnterTag = services.EVENT_NAMES.ON_WORLD_BATTLE_ENTER .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_WORLD_BATTLE_ENTER, handler(self, self.onBattleWorldEnter), self._worldEnterTag)

    self._worldCityPos = services.EVENT_NAMES.ON_WORLD_CITY_POS .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_WORLD_CITY_POS, handler(self, self.onBattleWorldCityPos), self._worldCityPos)

    self._worldMovingListTag = services.EVENT_NAMES.ON_WORLD_BATTLE_MOVING_LIST .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_WORLD_BATTLE_MOVING_LIST, handler(self, self.onMovingList), self._worldMovingListTag)

    self._changeCityState = services.EVENT_NAMES.ON_CHANGE_WORLD_CITY_STATE .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_CHANGE_WORLD_CITY_STATE, handler(self, self.onChangeCityState), self._changeCityState)

    self._worldMoveEndTag = services.EVENT_NAMES.ON_WORLD_BATTLE_MOVE_END .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_WORLD_BATTLE_MOVE_END, handler(self, self.onMoveEnd), self._worldMoveEndTag)

    self._worldDevelopTag = services.EVENT_NAMES.ON_BATTLE_DEVELOP .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_BATTLE_DEVELOP, handler(self, self.updateState), self._worldDevelopTag)

    network:sendPacket(Protocol.C_2_S_NATION_BATTLE_VIEW, {op_type = 1, city_id = 0}) --进入世界地图
    network:sendPacket(Protocol.C_2_S_NATION_BATTLE_WOLRD_INFO, {city_id = 0})
    network:sendPacket(Protocol.C_2_S_NATION_BATTLE_ENTER)
    network:sendPacket(Protocol.C_2_S_NATION_BATTLE_MOVING_LIST)
    network:sendPacket(Protocol.C_2_S_NATION_BATTLE_LOAD_ARMY)
    network:sendPacket(Protocol.C_2_S_NATION_BATTLE_REPORT_LOAD)
end

return WorldModule