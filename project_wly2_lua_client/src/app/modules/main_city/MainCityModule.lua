local MainCityModule = class("MainCityModule", require('app.base.ModuleBase'))

function MainCityModule:ctor(name, params)
    MainCityModule.super.ctor(self, name, params)

    self._mapScene = nil
    self._buildings = {}
    self._itemZOrder = {
        map_scene = 0,
        pop_menu = 1,
        pop_menu_top = 2,
        pop_info = 3,
        main_ui = 4,
        equip_item = 5,
    }
end

function MainCityModule:init()
    self:setBaseBgVisible(false)
    self._mapScene = uq.ui.MapScene:createMap(nil, 2, cc.p(-386, -297))
    self:addChild(self._mapScene, self._itemZOrder.map_scene)

    self._mapScene:setMapScale(true)
    self._mapScene:addMapClickEventListener(handler(self, self._onClick))
    self._mapScene:addMapMoveEventListener(handler(self, self._onBGMove))
    self._mapScene:addMapScaleEventListener(handler(self, self._onBGScale))
    self._mapScene:scaleCallback(handler(self, self._onScaleCallback))
    self:refreshBuild()
    --self:moveToBuild(0, display.center, false, false)

    self._uiLayer = uq.createPanelOnly('main_city.MainCityView')
    self:addChild(self._uiLayer, self._itemZOrder.main_ui)
    self._uiLayer:setMainParent(self)

    self._equipChangeUI = uq.createPanelOnly('generals.EquipChangeUi')
    self._equipChangeUI:setPosition(cc.p(display.width, display.height / 2 - 100))
    self._equipChangeUI:setVisible(false)
    self:addChild(self._equipChangeUI, self._itemZOrder.equip_item)

    self._refreshMainCityEvent = services.EVENT_NAMES.ON_MAIN_CITY_REFRESH_BUILD .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_MAIN_CITY_REFRESH_BUILD, handler(self, self.refreshBuild), self._refreshMainCityEvent)

    self._serviceBuildToPosTag = services.EVENT_NAMES.ON_MAIN_CITY_BUILD_TO_POS .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_MAIN_CITY_BUILD_TO_POS, handler(self, self._onMainCityBuildToPos), self._serviceBuildToPosTag)

    self._serviceBuildToDefaultTag = services.EVENT_NAMES.ON_MAIN_CITY_BUILD_TO_DEFALT .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_MAIN_CITY_BUILD_TO_DEFALT, handler(self, self._onMainCityBuildToDefault), self._serviceBuildToDefaultTag)

    self._serviceShowMainUITag = services.EVENT_NAMES.ON_SHOW_MAIN_UI .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_SHOW_MAIN_UI, handler(self, self.showUI), self._serviceShowMainUITag)

    self._serviceHideMainUITag = services.EVENT_NAMES.ON_HIDE_MAIN_UI .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_HIDE_MAIN_UI, handler(self, self.hideUI), self._serviceHideMainUITag)

    self._eventRereshRandomEvent = services.EVENT_NAMES.ON_REFRESH_RANDOM_EVENT .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_REFRESH_RANDOM_EVENT, handler(self, self.refreshRandomEvent), self._eventRereshRandomEvent)

    self._serviceJumpToItem = services.EVENT_NAMES.ON_MAIN_CITY_JUMP_TO_ITEM .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_MAIN_CITY_JUMP_TO_ITEM, handler(self, self._onJumpToPopItem), self._serviceJumpToItem)

    self._eventTagRecruitNew = services.EVENT_NAMES.ON_RECRUIT_GENERALS .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_RECRUIT_GENERALS, handler(self, self.newGeneralsShow), self._eventTagRecruitNew)

    self._eventTagPoolNew = services.EVENT_NAMES.ON_GENERAL_POOL_CHANGE .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_GENERAL_POOL_CHANGE, handler(self, self.newGeneralsPool), self._eventTagPoolNew)

    uq.playSoundByID(1102)
    self._randomEventList = {}
    self:refreshRandomEvent()

    local soldier = StaticData['world_soldier'][11]
    local soldier2 = StaticData['world_soldier'][16]
    uq.AnimationManager:getInstance():dispose('world_soldier', string.format('%s_%d', soldier.action, 3))
    uq.AnimationManager:getInstance():dispose('world_soldier', string.format('%s_%d', soldier2.action, 3))
end

function MainCityModule:showUI()
    self._uiLayer:setVisible(true)

    for k, item in pairs(self._buildings) do
        item.build:showUI(true)
    end
end

function MainCityModule:hideUI()
    self._uiLayer:setVisible(false)

    for k, item in pairs(self._buildings) do
        item.build:showUI(false)
    end
end

function MainCityModule:openListEntry(is_bool)
    self._uiLayer:showListLayer(is_bool)
    self._uiLayer:showAction(true)
end

function MainCityModule:_onMainCityBuildToPos(data)
    self:moveToBuild(data.build_id)
end

function MainCityModule:_onMainCityBuildToDefault(data)
    self:returnToDefault(data.build_id)
end

function MainCityModule:_onJumpToPopItem(data)
    self._jumpBuildID = data.build_id
    self._jumpItemID = data.item_id
    self:moveToBuild(data.build_id, display.center, true, true, handler(self, self.JumpToCallback))
end

function MainCityModule:JumpToCallback()
    if self._jumpItemID then
        self._buildings[self._jumpBuildID].build:showPopMenu()
        self._buildings[self._jumpBuildID].build:addPopMenuItemEffect(self._jumpItemID)
    else
        self._buildings[self._jumpBuildID].build:addGuideEffect()
    end
end

function MainCityModule:_onClick(pos)
    self:hidePopMenu()

    local build_data = nil

    for k, item in pairs(self._randomEventList) do
        if item:containPoint(pos) then
            item:onClick()
            return
        end
    end

    for _, v in pairs(self._buildings) do
        if v.build:containPoint(pos) then
            build_data = v
            break
        end
    end

    if build_data then
        local item_build = build_data.build
        item_build:onClick()
        local x, y = item_build:getPosition()
        local build_pos = cc.p(x, y)
        local size = item_build:getIcon():getContentSize()
        self._mapScene:adaptPosition(cc.p(build_pos.x, build_pos.y))
    end
end

function MainCityModule:hidePopMenu()
    for k, v in pairs(self._buildings) do
        if v.build.hidePopMenu then
            v.build:hidePopMenu()
        end
    end
end

function MainCityModule:_onBGMove(pos)
    -- for _, item in pairs(self._buildings) do
    --     item.build:positionChange(self._mapScene:getBgLayer():getScale())
    -- end
end

function MainCityModule:_onScaleCallback(scale)
    if not self._scaleBack then
        self._scaleBack = scale
        return
    end
    if scale ~= self._scaleBack then
        self:hidePopMenu()
        self._scaleBack = scale
    end
end

function MainCityModule:_onBGScale(map_scale)
    -- for _, item in pairs(self._buildings) do
    --     item.build:positionChange(map_scale)
    -- end
end

function MainCityModule:refreshBuild()
    for _, v in pairs(uq.cache.role.buildings) do
        self:_addBuild(v)
    end
end

function MainCityModule:_addBuild(b)
    if self._buildings[b.build_id] then
        self._buildings[b.build_id].build:setData(b)
        return
    end

    local temp = StaticData['buildings']['CastleMap'][b.build_id]
    if temp == nil then
        return
    end
    local size = self._mapScene:getMapContentSize()
    local px = temp.x - size.width / 2
    local py = -temp.y + size.height / 2

    local build = uq.createPanelOnly("main_city.BuildNode")
    self._mapScene:addMapChild(build)
    build:setPosition(cc.p(px, py))
    build:setMainParent(self._mapScene)
    build:setData(b)
    build:setLocalZOrder(uq.ui.MapScene.ObjectZOrder.CITY)

    b.build = build
    self._buildings[b.build_id] = b
end

function MainCityModule:moveToBuild(build_id, pos, moved, is_scale, callback, scale)
    moved = moved == nil and true or moved
    is_scale = is_scale == nil and true or is_scale
    pos = pos or cc.p(476, 500)

    local temp = StaticData['buildings']['CastleMap'][build_id]
    if temp == nil then
        return
    end

    local build_data = self._buildings[build_id]
    local x, y = build_data.build:getPosition()

    if is_scale then
        self._mapScene:returnToInit(cc.p(x, y), true)
        scale = scale or temp.scale
        self._mapScene:updateMapScale(scale, cc.p(x, y), true)
    end

    local pos_build = self._mapScene:convertToMapWorldSpace(cc.p(x, y))
    self._oldPos = pos_build

    self._mapScene:updateMapPosition(pos.x - pos_build.x, pos.y - pos_build.y, moved, nil, callback)
end

function MainCityModule:returnToDefault(build_id)
    local temp = StaticData['buildings']['CastleMap'][build_id]
    if temp == nil then
        return
    end

    local build_data = self._buildings[build_id]
    local x, y = build_data.build:getPosition()
    self._mapScene:returnToInit(cc.p(x, y), true)

    local pos_build = self._mapScene:convertToMapWorldSpace(cc.p(x, y))
    local pos_bg = self._oldPos
    self._mapScene:updateMapPosition(pos_bg.x - pos_build.x, pos_bg.y - pos_build.y, true)
end

function MainCityModule:dispose()
    services:removeEventListenersByTag(self._refreshMainCityEvent)
    services:removeEventListenersByTag(self._serviceBuildToPosTag)
    services:removeEventListenersByTag(self._serviceBuildToDefaultTag)
    services:removeEventListenersByTag(self._serviceShowMainUITag)
    services:removeEventListenersByTag(self._serviceHideMainUITag)
    services:removeEventListenersByTag(self._eventRereshRandomEvent)
    services:removeEventListenersByTag(self._serviceJumpToItem)
    services:removeEventListenersByTag(self._eventTagRecruitNew)
    services:removeEventListenersByTag(self._eventTagPoolNew)

    MainCityModule.super.dispose(self)
end

function MainCityModule:getMapScene()
    return self._mapScene
end

function MainCityModule:refreshRandomEvent(evt)
    if evt and evt.event_data then
        self:addRandomEventItem(evt.event_data.event_type, evt.event_data.event_id)
        return
    end

    for random_type, random_data in pairs(uq.cache.random_event:getRandomData()) do
        if not random_data.map_hide then
            for k, item in pairs(random_data) do
                self:addRandomEventItem(random_type, k)
            end
        end
    end
end

function MainCityModule:addRandomEventItem(type, id)
    local event_id = type .. '_' .. id
    if not self._randomEventList[event_id] then
        local random_item = uq.createPanelOnly("random_event.RandomMapItem")
        self._mapScene:addMapChild(random_item)
        self._randomEventList[event_id] = random_item

        random_item:setLocalZOrder(uq.ui.MapScene.ObjectZOrder.CITY)
        random_item:setData(type, id, handler(self, self.removeRandomEvent), self._mapScene:getMapContentSize())
    else
        self._randomEventList[event_id]:refreshData()
    end
end

function MainCityModule:removeRandomEvent(event_id)
    self._randomEventList[event_id] = nil
end

function MainCityModule:refreshLayerFromTop()
    self._uiLayer:refreshBtnView()
    if uq.ModuleManager:getInstance():isCloseChildBase() then
        self._uiLayer:showAction(false)
    end
    uq.cache.recruit:showNewRecruitGenerals()
    uq.cache.generals:showNewGeneralsPoolOpen()
end

function MainCityModule:newGeneralsShow()
    if uq.ModuleManager:getInstance():getTopLayerName() == self:name() then
        uq.cache.recruit:showNewRecruitGenerals()
    end
end

function MainCityModule:newGeneralsPool()
    if uq.ModuleManager:getInstance():getTopLayerName() == self:name() then
        uq.cache.generals:showNewGeneralsPoolOpen()
    end
end

return MainCityModule