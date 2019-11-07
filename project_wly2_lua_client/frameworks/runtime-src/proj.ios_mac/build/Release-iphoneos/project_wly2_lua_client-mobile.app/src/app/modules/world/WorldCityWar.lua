local WorldCityWar = class("WorldCityWar", require('app.base.ModuleBase'))

function WorldCityWar:onCreate()
    WorldCityWar.super.onCreate(self)

    self:setBaseBgVisible(false)
    self._buildings = {}
    self._movingList = {}
    self._movingListMark = {}
    self._timerFlag = 'timer_flag' .. tostring(self)
    self._mapScene = uq.ui.MapScene:createMap("img/building/world_city/CountryWar.jpg", 3)
    self:addChild(self._mapScene)

    self._mapScene:setMapScale(true)
    self._mapScene:addMapClickEventListener(handler(self, self._onClick))
    self._mapScene:addMapMoveEventListener(handler(self, self._onBGMove))

    self._mainView = uq.createPanelOnly('main_city.MainCityView')
    self._mainView:setEnterMainCity()
    self._mainView:setLeftMiddleVisible(false)
    self._mainView:setRightMiddleVisible(false)
    self._mainView:setNodeRightBottom(false)
    self._mainView:setNodeRightTop(false)
    self._mainView:setNodeLeftTop(false)
    self._mainView:setNodeBottomRightVisible(false)
    self._mainView:setLeftMiddleVisible(false)
    self._mainView:setNodeBottomLeftInfoVisible(false)
    self:addChild(self._mainView)

    self._uiView = uq.createPanelOnly('world.WorldCityWarView')
    self:addChild(self._uiView)
    self._uiView:initDialog()
    self._oldBuildData = nil
    self:initDialog()
    self:initProtocol()
    if not uq.TimerProxy:hasTimer(self._timerFlag) then
        uq.TimerProxy:addTimer(self._timerFlag, handler(self , self.onTimer), 0, -1)
    end
    self._isOpen = true
end

function WorldCityWar:initDialog()
    local temp = StaticData['world_city'][uq.cache.world_war.battle_city_info.city_id]
    if temp == nil then
        return
    end
    self._cityInfo = StaticData['world_war_city'][temp.type]
    for k, item in pairs(self._cityInfo.war) do
        self:addBuild({id = k})
    end
end

function WorldCityWar:onBattleWorldEnter()
    if not self._isOpen then
        return
    end
    self._isOpen = false
    local brith_city = uq.cache.world_war:getBirthCity(1)
    if self._cityInfo.war[brith_city] then
        local field_info = self._cityInfo.war[brith_city]
        local size = self._mapScene:getMapContentSize()
        local px = field_info.pos_x - size.width / 2
        local py = -field_info.pos_y + size.height / 2
        local pos = display.center
        local pos_build = self._mapScene:convertToMapWorldSpace(cc.p(px, py))
        self._mapScene:updateMapPosition(pos.x - pos_build.x, pos.y - pos_build.y)
    end
end

function WorldCityWar:onDeclareWar(info)
    if self._movingListMark[info.id] ~= nil and self._movingListMark[info.id][info.army_id] ~= nil then
        return
    end
    local soldier = uq.createPanelOnly('world.WorldWarSoldier')
    local size = self._mapScene:getMapContentSize()
    local path_ids = {}
    local cur_pos = cc.p(self._cityInfo.war[info.from_point_id].pos_x - size.width / 2, -self._cityInfo.war[info.from_point_id].pos_y + size.height / 2)
    local end_pos = cc.p(self._cityInfo.war[info.to_point_id].pos_x - size.width / 2, -self._cityInfo.war[info.to_point_id].pos_y + size.height / 2)
    table.insert(path_ids, cur_pos)
    table.insert(path_ids, end_pos)
    local st_data = {
        path_ids = path_ids,
        data = info
    }
    soldier:setSpeed(self._cityInfo.speed)
    self._mapScene:addMapChild(soldier)
    soldier:setInfo(st_data)
    if self._movingListMark[info.id] == nil then
        self._movingListMark[info.id] = {}
    end
    self._movingListMark[info.id][info.army_id] = true
    table.insert(self._movingList, soldier)
end

function WorldCityWar:addBuild(build_data)
    if self._buildings[build_data.id] then
        self._buildings[build_data.id].build:setData(build_data)
        return
    end
    local temp = self._cityInfo.war[build_data.id]
    if temp == nil then
        return
    end
    local size = self._mapScene:getMapContentSize()
    local px = temp.pos_x - size.width / 2
    local py = -temp.pos_y + size.height / 2
    local build = uq.createPanelOnly("world.WorldWarCity")
    build:setData(temp)
    build:setPosition(cc.p(px, py))
    self._mapScene:addMapChild(build)
    build_data.build = build
    self._buildings[build_data.id] = build_data
end

function WorldCityWar:_onClick(pos)
    local build_data = nil
    self._uiView:onCloseArmyItemView()
    for _, v in pairs(self._buildings) do
        local p = cc.p(v.build:getPositionX(), v.build:getPositionY())
        local size = v.build:getIcon():getContentSize()
        local rect = cc.rect(p.x - size.width / 2, p.y - size.height / 2, size.width, size.height)
        if cc.rectContainsPoint(rect, pos) then
            build_data = v
            break
        end
    end

    self:removePopMenu()
    if build_data then
        build_data.build:onClick()
        local item_build = build_data.build
        local x, y = item_build:getPosition()
        self:moveToCity(build_data, display.center, true, true, 1.0)
    end
end

function WorldCityWar:onBattleWorldCityPos(msg)
    local brith_city = uq.cache.world_war:getBirthCity(msg.data.id)
    if self._buildings[brith_city] then
        self:removePopMenu()
        local build_data = self._buildings[brith_city]
        build_data.build:onClick()
        local item_build = build_data.build
        local x, y = item_build:getPosition()
        self:moveToCity(build_data, display.center, true, true, 1.0)
    end
end

function WorldCityWar:moveToCity(build_data, pos, moved, is_scale, scale)
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
    self._mapScene:updateMapPosition(pos.x - pos_build.x, pos.y - pos_build.y, moved)
end

function WorldCityWar:removePopMenu()
    for _, v in pairs(self._buildings) do
        v.build:removePopMenu()
    end
    self._uiView:closeArmyLayer()
end

function WorldCityWar:_onBattleFieldInfo()
    local info = uq.cache.world_war.battle_field_info.points
    for k, v in ipairs(info) do
        if self._buildings[v.id] then
            self._buildings[v.id].build:setFieldInfo(v)
        end
    end
end

function WorldCityWar:_onBattleFieldPointArmys(msg)
    local info = uq.cache.world_war.point_armys_array
    if msg.data == nil then
        for k, v in pairs(self._buildings) do
            v.build:updateArmysInfo(info[k])
        end
    else
        for k, v in ipairs(msg.data) do
            self._buildings[v].build:updateArmysInfo(info[v])
        end
    end
    self:onBattleWorldEnter()
    self._uiView:updateTopArmyView()
end

function WorldCityWar:onTimer(timer, dt)
    for k, v in ipairs(self._movingList) do
        v:timer(dt)
    end
    for k, v in pairs(self._buildings) do
        v.build:timer(dt)
    end
end

function WorldCityWar:onBattleWorldInfo()
    self._uiView:updateBattleTime()
end

function WorldCityWar:_onBattleFieldMovingList(msg)
    local info = uq.cache.world_war.field_moving_list
    for k, army_info in pairs(info) do
        self:onDeclareWar(army_info)
    end
end

function WorldCityWar:_onBattleFieldMove(msg)
    uq.log("_onFieldMove  ", msg.data)
end

function WorldCityWar:_onBattleFieldNotify(msg)
    for k, v in ipairs(msg.data.reports) do
        if v.result > 0 then
            local info = uq.cache.world_war.point_armys_array[msg.data.point_id]
            if self._buildings[msg.data.point_id] then
                self._buildings[msg.data.point_id].build:updateArmysInfo(info)
            end
        end
        self._buildings[msg.data.point_id].build:playBattleEffect()
    end
end

function WorldCityWar:_onFieldBattleMoveEnd(msg)
    uq.log("_onFieldBattleMoveEnd  ", msg.data)
    for k, v in ipairs(msg.data) do
        if self._movingListMark[v.id] ~= nil then
            self._movingListMark[v.id][v.army_id] = nil
        end
        for k2, move_item in ipairs(self._movingList) do
            local info = move_item:getInfo()
            if v.id == info.id and v.army_id == info.army_id then
                move_item:endPath()
                table.remove(self._movingList, k2)
                break
            end
        end
    end
    local info = uq.cache.world_war.point_armys_array
    for k, v in pairs(info) do
        if self._buildings[v.point_id] then
            self._buildings[v.point_id].build:updateArmysInfo(v)
        end
    end
end

function WorldCityWar:_onBattleFieldWallUp(msg)
    if msg.data.result ~= -1 then
        local info = uq.cache.world_war:getBattleFieldInfoByPointId(msg.data.point_id)
        if info and self._buildings[msg.data.point_id] then
            self._buildings[msg.data.point_id].build:updateHp(info.hp)
        end
    end
end

function WorldCityWar:_onBattleFieldOccupyNotify(msg)
    uq.log("_onFieldOccupyNotify  ", msg.data)
end

function WorldCityWar:_onBattleEndBattle(msg)
    uq.log("_onBattleEnd  ", msg.data)
    for k2, move_item in ipairs(self._movingList) do
        move_item:endPath()
    end
    self._movingList = {}
    uq.cache.world_war:clearBattleFieldData()
    uq.TimerProxy:addTimer("delay_end_battle_field", function()
        uq.TimerProxy:removeTimer("delay_end_battle_field")
        uq.runCmd('enter_world')
    end, 0, 1, 1)
end

function WorldCityWar:onMovingChange(msg)
    self._uiView:updateRightArmyView()
    for k, v in pairs(self._buildings) do
        v.build:updateCityState()
    end

end

function WorldCityWar:initProtocol()
    uq.cache.world_war:clearBattleFieldData()
    self._worldMovingChangeTag = services.EVENT_NAMES.ON_WORLD_MOVING_STATE_CHANGE .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_WORLD_MOVING_STATE_CHANGE, handler(self, self.onMovingChange), self._worldMovingChangeTag)

    self._onFieldInfo = services.EVENT_NAMES.ON_WORLD_BATTLE_FIELD_INFO .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_WORLD_BATTLE_FIELD_INFO, handler(self, self._onBattleFieldInfo), self._onFieldInfo)

    self._onFieldPointArmys = services.EVENT_NAMES.ON_WORLD_BATTLE_FIELD_POINT_ARMYS .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_WORLD_BATTLE_FIELD_POINT_ARMYS, handler(self, self._onBattleFieldPointArmys), self._onFieldPointArmys)

    self._onFieldMovingList = services.EVENT_NAMES.ON_WORLD_BATTLE_FIELD_MOVING_LIST .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_WORLD_BATTLE_FIELD_MOVING_LIST, handler(self, self._onBattleFieldMovingList), self._onFieldMovingList)

    self._onFieldMove = services.EVENT_NAMES.ON_WORLD_BATTLE_FIELD_MOVE .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_WORLD_BATTLE_FIELD_MOVE, handler(self, self._onBattleFieldMove), self._onFieldMove)

    self._onFieldNotify = services.EVENT_NAMES.ON_WORLD_BATTLE_FIELD_NOTIFY .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_WORLD_BATTLE_FIELD_NOTIFY, handler(self, self._onBattleFieldNotify), self._onFieldNotify)

    self._onFieldWallUp = services.EVENT_NAMES.ON_WORLD_BATTLE_FIELD_WALL_UP .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_WORLD_BATTLE_FIELD_WALL_UP, handler(self, self._onBattleFieldWallUp), self._onFieldWallUp)

    self._onFieldOccupyNotify = services.EVENT_NAMES.ON_WORLD_BATTLE_FIELD_OCCUPY_NOTIFY .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_WORLD_BATTLE_FIELD_OCCUPY_NOTIFY, handler(self, self._onBattleFieldOccupyNotify), self._onFieldOccupyNotify)

    self._onBattleEnd = services.EVENT_NAMES.ON_WORLD_BATTLE_FIELD_END_BATTLE .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_WORLD_BATTLE_FIELD_END_BATTLE, handler(self, self._onBattleEndBattle), self._onBattleEnd)

    self._onFieldMoveEnd = services.EVENT_NAMES.ON_WORLD_BATTLE_FIELD_MOVE_END .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_WORLD_BATTLE_FIELD_MOVE_END, handler(self, self._onFieldBattleMoveEnd), self._onFieldMoveEnd)

    self._worldInfoTag = services.EVENT_NAMES.ON_WORLD_BATTLE_INFO .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_WORLD_BATTLE_INFO, handler(self, self.onBattleWorldInfo), self._worldInfoTag)

    self._worldCityPos = services.EVENT_NAMES.ON_WORLD_CITY_POS .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_WORLD_CITY_POS, handler(self, self.onBattleWorldCityPos), self._worldCityPos)

    network:sendPacket(Protocol.C_2_S_NATION_BATTLE_VIEW, {op_type = 1, city_id = uq.cache.world_war.battle_city_info.city_id}) --进入战场地图
    uq.cache.world_war.map_moving_list = {} --进去战场地图，清除掉移动数据
    network:sendPacket(Protocol.C_2_S_NATION_BATTLE_FIELD_MOVING_LIST, {city_id = uq.cache.world_war.battle_city_info.city_id})
    network:sendPacket(Protocol.C_2_S_NATION_BATTLE_FIELD_INFO, {city_id = uq.cache.world_war.battle_city_info.city_id})
end

function WorldCityWar:onExit()
    services:removeEventListenersByTag(self._worldMovingChangeTag)
    services:removeEventListenersByTag(self._onFieldInfo)
    services:removeEventListenersByTag(self._onFieldPointArmys)
    services:removeEventListenersByTag(self._onFieldMove)
    services:removeEventListenersByTag(self._onFieldMovingList)
    services:removeEventListenersByTag(self._onFieldNotify)
    services:removeEventListenersByTag(self._onFieldWallUp)
    services:removeEventListenersByTag(self._onFieldOccupyNotify)
    services:removeEventListenersByTag(self._onBattleEnd)
    services:removeEventListenersByTag(self._onFieldMoveEnd)
    services:removeEventListenersByTag(self._worldInfoTag)
    services:removeEventListenersByTag(self._worldCityPos)
    uq.TimerProxy:removeTimer(self._timerFlag)
    uq.TimerProxy:removeTimer("delay_end_battle_field")
    WorldCityWar.super.onExit(self)
end

function WorldCityWar:_onBGMove(pos)
    self._uiView:onCloseArmyItemView()
end

return WorldCityWar