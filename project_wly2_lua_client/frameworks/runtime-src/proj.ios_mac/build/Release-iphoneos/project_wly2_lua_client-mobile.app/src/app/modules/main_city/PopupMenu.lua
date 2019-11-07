local PopupMenu = class("PopupMenu", require('app.base.ChildViewBase'))

PopupMenu.RESOURCE_FILENAME = "main_city/PopupMenu.csb"
PopupMenu.RESOURCE_BINDING = {
    ["node_tip"]       = {["varname"] = "_nodeTip"},
    ["node_item"]      = {["varname"] = "_nodeItem"},
    ["txt_level"]      = {["varname"] = "_txtLevel"},
    ["txt_name"]       = {["varname"] = "_txtName"},
    ["sprite_uparrow"] = {["varname"] = "_spriteUpArrow"},
    ["node_cd"]        = {["varname"] = "_nodeBar"},
    ["txt_loadtime"]   = {["varname"] = "_txtTime"},
    ["loadbar"]        = {["varname"] = "_loadbar"},
    ["Image_1"]        = {["varname"] = "_imgLevelBg"},
    ["node_lock"]      = {["varname"] = "_nodeLock"},
    ["Text_1"]         = {["varname"] = "_txtLock"},
    ["red"]            = {["varname"] = "_spriteRed"},
}

function PopupMenu:onCreate()
    PopupMenu.super.onCreate(self)

    self._menuNodes = {}
    self._buildData = nil

    self._eventTagRefresh = services.EVENT_NAMES.ON_MAIN_CITY_REFRESH_BUILD .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_MAIN_CITY_REFRESH_BUILD, handler(self, self.refreshBuild), self._eventTagRefresh)

    self._eventNewInstance = services.EVENT_NAMES.ON_NEW_INSTANCE .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_NEW_INSTANCE, handler(self, self.refreshBuild), self._eventNewInstance)

    self._refreshEventTag = services.EVENT_NAMES.ON_BUILD_OFFICER_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_BUILD_OFFICER_REFRESH, handler(self, self.refreshRed), self._refreshEventTag)

    self._spriteUpArrow:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(0, -10)), cc.MoveBy:create(0.5, cc.p(0, 10)))))
end

function PopupMenu:onExit()
    if self._timerField then
        self._timerField:dispose()
        self._timerField = nil
    end
    services:removeEventListenersByTag(self._eventTagRefresh)
    services:removeEventListenersByTag(self._eventNewInstance)
    services:removeEventListenersByTag(self._refreshEventTag)

    PopupMenu.super:onExit()
end

function PopupMenu:setData(build_data, menu_data, map_scale)
    self._buildData = build_data
    self._mapScale = map_scale
    self._buildXml = StaticData['buildings']['CastleMap'][self._buildData.build_id]

    local name_config = string.split(self._buildXml.label, '：')
    self._txtName:setString(name_config[1])
    self._spriteUpArrow:setVisible(false)
    self._nodeTip:setVisible(name_config[1] ~= '')
    self:refreshBuild()

    for k = #menu_data, 1, -1 do
        self:addItem(menu_data[k])
    end
    self:refreshPos(self._mapScale)
    self:itemAction()
    self:setLevelUp(menu_data)
    self:refreshRed()
end

function PopupMenu:setLevelUp(menu_data)
    local can_levelup = false
    for k, item in ipairs(menu_data) do
        if item.moduleId == uq.config.constant.MODULE_ID.LEVEL_UP then
            can_levelup = true
            break
        end
    end

    self._txtLevel:setVisible(can_levelup)
    self._imgLevelBg:setVisible(can_levelup)
end

function PopupMenu:refreshCDTime()
    local build_data = uq.cache.role.buildings[self._buildData.build_id]
    local left_time = build_data.cd_time - os.time()
    local total_time = uq.cache.role:getBuildLevelCDTime(self._buildData.build_id)

    self._nodeBar:setVisible(left_time > 0)

    if left_time <= 0 then
        if self._timerField then
            self._timerField:dispose()
            self._timerField = nil
        end
        return
    end

    local function timer_end()
        self:refreshCDTime()
    end

    local function timer_call(left_time)
        self._loadbar:setPercent(100 - left_time / total_time * 100)
    end
    if self._timerField then
        self._timerField:setTime(left_time)
    else
        self._timerField = uq.ui.TimerField:create(self._txtTime, left_time, timer_end, nil, timer_call)
    end
end

function PopupMenu:refreshBuild()
    if uq.cache.role:isBuildLock(self._buildXml) then
        local pre_xml = StaticData['buildings']['CastleMap'][self._buildXml.ident - 1]
        if pre_xml and pre_xml.type == self._buildXml.type and uq.cache.role:isBuildLock(pre_xml) then
            self._nodeLock:setVisible(false)
            self._nodeTip:setVisible(false)
        else
            self._nodeLock:setVisible(true)
            self._nodeTip:setVisible(false)
            if uq.cache.role:level() < self._buildXml.level then
                self._txtLock:setString(string.format(StaticData['local_text']['label.build.pop.unlock'], self._buildXml.level))
            else
                local chapter_id = math.floor(self._buildXml.objectId / 100) - 100
                local npc_id = self._buildXml.objectId % 100
                self._txtLock:setString(string.format(StaticData['local_text']['label.instance.unlock'], chapter_id, npc_id))
            end
        end
    else
        self._nodeLock:setVisible(false)
        self._nodeTip:setVisible(true)
        self._spriteUpArrow:setVisible(self._buildXml.coefficient > 0 and uq.cache.role:getCityCanLevelUp(self._buildData.build_id))
        self:setLevel()
        self:refreshCDTime()
    end
    self:refreshRed()
end

function PopupMenu:addItem(item)
    local pop_node = cc.CSLoader:createNode('main_city/PopupMenuItem.csb')

    local touch_btn = pop_node:getChildByName('button_icon')
    touch_btn.touchId = item.moduleId
    touch_btn.soundId = item.soundId or ""
    local img_path = 'img/main_city/' .. item.icon
    touch_btn:onTouch(handler(self, self.onOpenModule))
    pop_node:getChildByName('red'):setVisible(false)
    local spr_icon = pop_node:getChildByName('Sprite_1')
    spr_icon:setTexture(img_path)
    self._nodeItem:addChild(pop_node)

    table.insert(self._menuNodes, pop_node)
end

function PopupMenu:refreshItemRed()
    for k, pop_node in ipairs(self._menuNodes) do
        local module_id = pop_node:getChildByName('button_icon').touchId
        --竞技场红点显示
        if module_id == uq.config.constant.MODULE_ID.ARENA then
            local reward_items = uq.cache.arena:getArenaReward()
            if reward_items and #reward_items > 0 then
                pop_node:getChildByName('red'):setVisible(true)
            end
        elseif module_id == uq.config.constant.MODULE_ID.BUILD_OFFICER then
            pop_node:getChildByName('red'):setVisible(uq.cache.role:isHasGeneralCanOfficeAll())
        end
    end
end

function PopupMenu:refreshPos(map_scale)
    self._mapScale = map_scale

    if not self._nodeItem:isVisible() then
        return
    end

    local radius = 200 * math.sqrt(map_scale)
    local angle_off = -25 * 300 / radius
    local total_angle = (#self._menuNodes - 1) * angle_off

    for k, item in ipairs(self._menuNodes) do
        item:stopAllActions()
        local space_angle = angle_off * (k - 1) - total_angle / 2 - 90
        local x = radius * math.cos(space_angle * math.pi / 180)
        local y = radius * math.sin(space_angle * math.pi / 180) + 100 + self._buildXml.menuOffy
        item:setPosition(cc.p(x, y))
        item.init_pos = cc.p(x, y)
    end
end

function PopupMenu:itemAction()
    for k, item in ipairs(self._menuNodes) do
        item:stopAllActions()
        item:setPosition(cc.p(0, 0))
        item:runAction(cc.EaseBackOut:create(cc.MoveTo:create(0.1, item.init_pos)))
    end
end

function PopupMenu:onOpenModule(event)
    if event.name == "ended" then
        local moduleId = event.target.touchId
        self:setPopItemVisible(false)
        local sound_id = event.target.soundId
        if sound_id == "" then
            sound_id = uq.config.constant.COMMON_SOUND.BUTTON
        end
        uq.playSoundByID(sound_id)
        uq.jumpToModule(moduleId, {build_id = self._buildData.build_id})
    end
end

function PopupMenu:setPopItemVisible(flag)
    local is_visible = flag and not uq.cache.role:isBuildLock(self._buildXml)
    self._nodeItem:setVisible(is_visible)
    if is_visible == true then
        self:refreshPos(self._mapScale)
        self:itemAction()
    end
end

function PopupMenu:setLevelUpVisible(flag)
    self._nodeTip:setVisible(flag)
end

function PopupMenu:setLevel()
    self._txtLevel:setString(uq.cache.role:getBuildingLevel(self._buildData.build_id))
end

function PopupMenu:addPopMenuItemEffect(id)
    local item_node = self._menuNodes[#self._menuNodes - id + 1]
    if item_node and not item_node:getChildByName('effect_guide') then
        local effect_guide = uq:addEffectByNode(item_node, 900116, -1, true, cc.p(-5, -5))
        effect_guide:setName('effect_guide')
    end
end

function PopupMenu:removeGuideEffect()
    for k, item in ipairs(self._menuNodes) do
        if item:getChildByName('effect_guide') then
            item:getChildByName('effect_guide'):removeSelf()
        end
    end
end

function PopupMenu:refreshRed()
    self._spriteRed:setVisible(false)
    if self._buildXml.type == uq.config.constant.BUILD_TYPE.MAIN_CITY then
        self._spriteRed:setVisible(uq.cache.role:isHasGeneralCanOfficeAll())
    end
    self:refreshItemRed()
end

return PopupMenu