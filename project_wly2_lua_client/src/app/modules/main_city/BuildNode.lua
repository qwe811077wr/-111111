local BuildNode = class("BuildNode", require('app.base.ChildViewBase'))

BuildNode.RESOURCE_FILENAME = "main_city/BuildNode.csb"
BuildNode.RESOURCE_BINDING = {
    ["image_icon"]     = {["varname"] = "_imageCity"},
}

function BuildNode:onCreate()
    BuildNode.super.onCreate(self)
    self._itemZOrder = {
        pop_menu = 5,
        pop_menu_top = 6,
        pop_info = 7,
    }
    self._mapConfig = StaticData['map_config'][2]
    self._eventCropRefresh = services.EVENT_NAMES.ON_CROP_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_CROP_REFRESH, handler(self, self.refreshPopInfo), self._eventCropRefresh)

    network:addEventListener(Protocol.S_2_C_COLLECTION_MONEY, handler(self, self._onCollectRet), '_onCollectByBuildNode')
    network:addEventListener(Protocol.S_2_C_FRAM_HARVEST, handler(self, self._onFarmHarvestRet), '_onFarmByBuildNode')
    network:addEventListener(Protocol.S_2_C_COLLECTION_IRON, handler(self, self._onCollectIron), '_onCollectIron' .. tostring(self))
    network:addEventListener(Protocol.S_2_C_COLLECTION_REDIF, handler(self, self._onCollectRedif), '_onCollectRedif' .. tostring(self))

    self._eventTagRefresh = services.EVENT_NAMES.ON_MAIN_CITY_REFRESH_BUILD .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_MAIN_CITY_REFRESH_BUILD, handler(self, self.refreshBuild), self._eventTagRefresh)

    self._eventResTag = services.EVENT_NAMES.ON_UPDATE_BUILDER_RESOURCE .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_UPDATE_BUILDER_RESOURCE, handler(self, self.refreshPopInfo), self._eventResTag)

    self._relationEventTag = services.EVENT_NAMES.ON_RELATION_SHIP_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_RELATION_SHIP_REFRESH, handler(self, self.refreshPopInfo), self._relationEventTag)
end

function BuildNode:onExit()
    network:removeEventListenerByTag('_onCollectByBuildNode')
    network:removeEventListenerByTag('_onFarmByBuildNode')
    network:removeEventListenerByTag('_onCollectIron' .. tostring(self))
    network:removeEventListenerByTag('_onCollectRedif' .. tostring(self))

    services:removeEventListenersByTag(self._eventCropRefresh)
    services:removeEventListenersByTag(self._eventTagRefresh)
    services:removeEventListenersByTag(self._eventResTag)
    services:removeEventListenersByTag(self._relationEventTag)
    if self._onLoadDecree then
        services:removeEventListenersByTag(self._onLoadDecree)
    end
    BuildNode.super.onExit(self)
end

function BuildNode:getIcon()
    return self._imageCity
end

function BuildNode:setIcon()
    self._imageCity:ignoreContentAdaptWithSize(true)
    if uq.cache.role:isBuildLock(self._buildXml) then
        self._imageCity:loadTexture('img/building/maincity/' .. self._buildXml.icon2)
    else
        self._imageCity:loadTexture(self._buildXml.icon)
    end
end

function BuildNode:setMainParent(main_parent)
    self._parentMain = main_parent
end

function BuildNode:setData(build_data)
    self._buildData = build_data
    self._buildXml = StaticData['buildings']['CastleMap'][self._buildData.build_id]

    self:addPopMenu()
    self:refreshBuild()

    if not self._onLoadDecree and self._buildData.build_id == uq.config.constant.BUILD_ID.MAIN then
        self._onLoadDecree = services.EVENT_NAMES.ON_CONSUME_RES_CHANGE .. uq.config.constant.COST_RES_TYPE.RT_DECREE .. tostring(self)
        services:addEventListener(services.EVENT_NAMES.ON_CONSUME_RES_CHANGE .. uq.config.constant.COST_RES_TYPE.RT_DECREE, handler(self, self.refreshPopInfo), self._onLoadDecree)
    end
end

function BuildNode:onClick()
    self:playClickSound()

    if uq.cache.role:isBuildLock(self._buildXml) then
        return
    end

    --menu中只有一个module，直接跳转
    if self._menuConfig and #self._menuConfig.Menu == 1 then
        local config = self._menuConfig.Menu[1]
        uq.jumpToModule(config.moduleId, {build_id = self._buildData.build_id})
    else
        self:showPopMenu()
    end
end

function BuildNode:playClickSound()
    local sound_id = uq.config.constant.COMMON_SOUND.BUTTON
    local temp = StaticData['buildings']['CastleMap'][self._buildData.build_id]
    if temp and temp.soundId and temp.soundId ~= "" then
        sound_id = temp.soundId
    end
    uq.playSoundByID(sound_id)
end

function BuildNode:addPopMenu()
    if self._popMenu then
        return
    end

    self._menuConfig = StaticData['menus'][self._buildXml.type]
    if not self._menuConfig then
        return
    end

    self._popMenu = uq.createPanelOnly('main_city.PopupMenu')
    self._popMenu:setData(self._buildData, self._menuConfig.Menu, self._parentMain:getBgLayer():getScale())
    self:getParent():addChild(self._popMenu, self._itemZOrder.pop_menu)
    self:positionChange()
    self:hidePopMenu()
end

function BuildNode:showPopMenu()
    if self._popMenu then
        self._popMenu:setPopItemVisible(true)
        self._popMenu:setLocalZOrder(self._itemZOrder.pop_menu_top)
    end
end

function BuildNode:hidePopMenu()
    if self:getChildByName('effect_guide') then
        self:getChildByName('effect_guide'):removeSelf()
    end

    if self._popMenu then
        self._popMenu:setPopItemVisible(false)
        self._popMenu:setLocalZOrder(self._itemZOrder.pop_menu)
        self._popMenu:removeGuideEffect()
    end
end

function BuildNode:showUI(flag)
    if self._popMenu then
        self._popMenu:setVisible(flag)
    end
end

function BuildNode:positionChange(map_scale)
    map_scale = map_scale or self._mapConfig.normal
    local x, y = self:getPosition()
    -- local pos_world = self:getParent():convertToWorldSpace(cc.p(x, y))
    -- local pos_main = self._parentMain:convertToNodeSpace(pos_world)
    if self._popMenu then
        self._popMenu:setPosition(cc.p(x + self._buildXml.x2 * map_scale, y + self._buildXml.y2 * map_scale))
        if self._popMenu:isVisible() then
            -- self._popMenu:refreshPos(map_scale)
        end
    end

    if self._popInfo then
        self._popInfo:setPosition(cc.p(x + self._buildXml.x3 * map_scale, y + self._buildXml.y3 * map_scale))
    end
    if self._resInfo then
        self._resInfo:setPosition(cc.p(x + self._buildXml.x3 * map_scale, y + self._buildXml.y3 * map_scale))
    end
end

function BuildNode:addGuideEffect()
    if not self:getChildByName('effect_guide') then
        local effect_guide = uq:addEffectByNode(self, 900116, -1, true, cc.p(self._buildXml.x2, self._buildXml.y2))
        effect_guide:setName('effect_guide')
    end
end

function BuildNode:addPopMenuItemEffect(id)
    if not self._popMenu then
        return
    end

    self._popMenu:addPopMenuItemEffect(id)
end

function BuildNode:containPoint(point)
    local sprite = self:getIcon()
    local x, y = self:getPosition()
    local size = sprite:getContentSize()

    local rect = cc.rect(x - size.width / 2, y - size.height / 2, size.width, size.height)
    if cc.rectContainsPoint(rect, point) then
        local pt_world = self:getParent():convertToWorldSpace(point)
        return uq.alphaTouchCheck(sprite, sprite:convertToNodeSpace(pt_world))
    end

    return false
end

function BuildNode:addPopHelp(pop_type)
    if not self._popInfo then
        self._popInfo = uq.createPanelOnly('main_city.BuildPopInfo')
        self:getParent():addChild(self._popInfo, self._itemZOrder.pop_info)
    end
    self._popInfo:setData(self._buildData, pop_type)
    self:positionChange()
end

function BuildNode:_onCollectRet(evt)
    if self._buildXml.type ~= uq.config.constant.BUILD_TYPE.HOUSE then
        return
    end
    self:collectRes(uq.config.constant.BUILD_TYPE.HOUSE, uq.config.constant.COST_RES_TYPE.MONEY)
end

function BuildNode:_onFarmHarvestRet(evt)
    if evt.data.ret ~= 0 then
        return
    end
    self:collectRes(uq.config.constant.BUILD_TYPE.FARM_LAND, uq.config.constant.COST_RES_TYPE.FOOD)
end

function BuildNode:_onCollectIron(evt)
    if evt.data.ret ~= 0 then
        return
    end
    self:collectRes(uq.config.constant.BUILD_TYPE.IRON, uq.config.constant.COST_RES_TYPE.IRON_MINE)
end

function BuildNode:_onCollectRedif(evt)
    if evt.data.ret ~= 0 then
        return
    end
    self:collectRes(uq.config.constant.BUILD_TYPE.SOLDIER, uq.config.constant.COST_RES_TYPE.REDIF)
end

function BuildNode:collectRes(build_type, res_type)
    if self._buildXml.type ~= build_type then
        return
    end
    if uq.cache.role:isBuildLock(self._buildXml) then
        return
    end
    local total_num = uq.cache.role:getBuildResource(build_type)

    local res_num = uq.cache.role.buildings[self._buildData.build_id].resource
    uq.cache.role.buildings[self._buildData.build_id].resource = 0
    local pos_city = self._imageCity:getParent():convertToWorldSpace(cc.p(self._imageCity:getPosition()))
    local pos_pop = pos_city
    if self._popInfo then
        pos_pop = self._popInfo:getParent():convertToWorldSpace(cc.p(self._popInfo:getPosition()))
    end
    self:refreshPopInfo()
    if res_num <= 0 then
        return
    end
    local data = {
        pos_pop = pos_pop,
        pos_city = pos_city,
        total_res = total_num,
        res_type = res_type
    }
    services:dispatchEvent({name = services.EVENT_NAMES.ON_RESOURCE_ACTION, data = data})
end

function BuildNode:refreshPopInfo()
    if uq.cache.role:isBuildLock(self._buildXml) then
        return
    end

    if uq.cache.role:hasCrop() and uq.cache.role.buildings[self._buildData.build_id].cd_time > os.time() and not uq.cache.crop:isCropHelping(self._buildData.build_id) then
        --拥有军团 正在升级 没有求助过
        self:addPopHelp(uq.config.constant.POP_SHOW_TYPE.CROP)
        return
    end

    --建设官人物关系
    if uq.cache.random_event._randomData[uq.cache.random_event.RANDOM_EVENT_TYPE.RELATION][self._buildXml.type] then
        self:addPopHelp(uq.config.constant.POP_SHOW_TYPE.RELATION)
        return
    end

    local info = StaticData['buildings']['CastleMap'][self._buildData.build_id]
    if uq.cache.role.buildings[self._buildData.build_id].resource > 0
        and not uq.cache.role:isBuildLock(self._buildXml)
        and (self._buildXml.type == uq.config.constant.BUILD_TYPE.STRATEGY
            or self._buildXml.type == uq.config.constant.BUILD_TYPE.IRON
            or (self._buildXml.type == uq.config.constant.BUILD_TYPE.HOUSE)
            or (self._buildXml.type == uq.config.constant.BUILD_TYPE.FARM_LAND)
            or (self._buildXml.type == uq.config.constant.BUILD_TYPE.SOLDIER)
        ) then
        self:addPopHelp(uq.config.constant.POP_SHOW_TYPE.RES)
        return
    end

    if self._buildData.build_id == uq.config.constant.BUILD_ID.MAIN and uq.cache.decree:isOperatorDecree() then
        self:addPopHelp(uq.config.constant.POP_SHOW_TYPE.RT_DECREE)
        return
    end

    if self._popInfo then
        self._popInfo:removeSelf()
        self._popInfo = nil
    end
end

function BuildNode:refreshBuild()
    self:refreshPopInfo()
    self:setIcon()
end

return BuildNode