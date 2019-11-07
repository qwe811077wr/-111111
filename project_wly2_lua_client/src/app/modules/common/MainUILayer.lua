local MainUILayer = class('MainUILayer', function()
    return cc.Node:create()
end)

function MainUILayer:ctor()
    self._activityUI = cc.CSLoader:createNode('main_city/ActivityUI.csb')
    self:_updateActivityIcons()
    local size = self._activityUI:getContentSize()
    self._activityUI:setPosition(cc.p(display.width / 2 - size.width - 30, display.height / 2 - size.height - 80))
    self:addChild(self._activityUI)

    local view = cc.CSLoader:createNode('main_city/RightSideUI.csb')
    view:setPosition(cc.p(display.width / 2, 0))
    local btn = view:getChildByName('control_btn')
    btn:addClickEventListenerWithSound(handler(self, self._showHideRightView))
    self._rightUI = view:getChildByName('view_container')
    self:addChild(view)
    self._rightUIMain = view

    self._equipChangeUI = uq.createPanelOnly('generals.EquipChangeUi')
    self._equipChangeUI:setPosition(cc.p(display.width / 2, -100))
    self:addChild(self._equipChangeUI)

    self._chatUI = uq.createPanelOnly('chat.ChatBottom')
    self._chatUI:setPosition(cc.p(-display.width / 2 + 20, -display.height / 2 + 50))
    self:addChild(self._chatUI)

    self._taskUI = uq.createPanelOnly('task.TaskUi')
    self._taskUI:setPosition(cc.p(-display.width / 2 + 20, -display.height / 2 + 90))
    self:addChild(self._taskUI)

    view = cc.CSLoader:createNode('main_city/BottomSideUI.csb')
    view:setPosition(cc.p(-100, -display.height / 2 + 20))
    local view_container = view:getChildByName('view_mask'):getChildByName('view_container')
    self._bottomUI = view_container:getChildByName('view')
    self:_updateBottomIcons()
    btn = view_container:getChildByName('control_btn')
    btn:addClickEventListenerWithSound(handler(self, self._showHideBottomView))
    self:addChild(view)
    self._bottomUIMain = view

    self:_setupIconCommand(self._activityUI)
    self:_setupIconCommand(self._rightUI:getChildByName('view'))
    self:_setupIconCommand(self._bottomUI)

    self:initBottomUi()
    self:initTopUi()
    self:_onMainCityBottomSideRedChanges()
    self:_onMainCityTopSideRedChanges()
    services:addEventListener(services.EVENT_NAMES.ON_MAIN_CITY_BOTTOM_SIDE_RED_CHANGES, handler(self, self._onMainCityBottomSideRedChanges),"_onMainCityBottomSideRedChanges" .. tostring(self))
    services:addEventListener(services.EVENT_NAMES.ON_MAIN_CITY_TOP_SIDE_RED_CHANGES, handler(self, self._onMainCityTopSideRedChanges),"_onMainCityTopSideRedChanges" .. tostring(self))
end

function MainUILayer:initBottomUi()
    self._bottomUIArray = {}
    self._bottomUIArray[uq.cache.hint_status.RED_TYPE.MAIN_CITY_WAREHOUSE] = self._bottomUI:getChildByName("open_warehouse")
    self._bottomUIArray[uq.cache.hint_status.RED_TYPE.MAIN_CITY_GENERALS] = self._bottomUI:getChildByName("open_general")
    self._bottomUIArray[uq.cache.hint_status.RED_TYPE.MAIN_CITY_FORMATION] = self._bottomUI:getChildByName("open_formation")
    self._bottomUIArray[uq.cache.hint_status.RED_TYPE.MAIN_CITY_CROP] = self._bottomUI:getChildByName("open_crop")
    self._bottomUIArray[uq.cache.hint_status.RED_TYPE.MAIN_CITY_BOSOM] = self._bottomUI:getChildByName("open_bosom")
    self._bottomUIArray[uq.cache.hint_status.RED_TYPE.MAIN_CITY_RETAINER] = self._bottomUI:getChildByName("open_retainer")
end

function MainUILayer:initTopUi()
    self._topUIArray = {}
    self._topUIArray[uq.cache.hint_status.RED_TYPE.MAIN_CITY_MAIL] = self._activityUI:getChildByName("open_mail")
    self._topUIArray[uq.cache.hint_status.RED_TYPE.MAIN_CITY_TASK] = self._activityUI:getChildByName("open_task")
    self._topUIArray[uq.cache.hint_status.RED_TYPE.MAIN_CITY_DAILY_ACTIVITY] = self._activityUI:getChildByName("open_daily")
    self._topUIArray[uq.cache.hint_status.RED_TYPE.MAIN_CITY_ACTIVITY] = self._activityUI:getChildByName("open_activity")
    self._topUIArray[uq.cache.hint_status.RED_TYPE.MAIN_CITY_RANK] = self._activityUI:getChildByName("open_rank")
end

function MainUILayer:_onMainCityBottomSideRedChanges(msg)--下边功能页签
    if msg then
        if self._bottomUIArray[msg.data] ~= nil then
            uq.showRedStatus(self._bottomUIArray[msg.data], uq.cache.hint_status.status[msg.data], -self._bottomUIArray[msg.data]:getContentSize().width * 0.5, self._bottomUIArray[msg.data]:getContentSize().width * 0.5)
        end
    else
        for k, v in pairs(self._bottomUIArray) do
            uq.showRedStatus(v, uq.cache.hint_status.status[k], -v:getContentSize().width * 0.5, v:getContentSize().width * 0.5)
        end
    end
end

function MainUILayer:_onMainCityTopSideRedChanges(msg) --上层活动页签
    if msg then
        if self._topUIArray[msg.data] ~= nil then
            uq.showRedStatus(self._topUIArray[msg.data], uq.cache.hint_status.status[msg.data], -self._topUIArray[msg.data]:getContentSize().width * 0.5, self._topUIArray[msg.data]:getContentSize().width * 0.5)
        end
    else
        for k, v in pairs(self._topUIArray) do
            uq.showRedStatus(v, uq.cache.hint_status.status[k], -v:getContentSize().width * 0.5, v:getContentSize().width * 0.5)
        end
    end
end

function MainUILayer:_updateActivityIcons()
    local children = self._activityUI:getChildren()
    local icon_gap = 20
    local pos_x = 0
    local size = cc.size(0, 0)
    for _, child in ipairs(children) do
        if child:isVisible() then
            child:setPositionX(pos_x)
            pos_x = pos_x + child:getContentSize().width + icon_gap
            size.height = child:getContentSize().height
        end
    end
    size.width = pos_x
    self._activityUI:setContentSize(size)
end

function MainUILayer:_showHideRightView(evt)
    local is_show = evt:isFlippedX()
    evt:setFlippedX(not is_show)
    local right_view = self._rightUI
    local action = nil
    local pos_y = right_view:getPositionY()
    if is_show then
        action = cc.MoveTo:create(0.07, cc.p(0, pos_y))
    else
        action = cc.MoveTo:create(0.07, cc.p(right_view:getContentSize().width, pos_y))
    end
    right_view:runAction(action)
end

function MainUILayer:_setupIconCommand(view)
    local children = view:getChildren()
    for _, child in ipairs(children) do
        child:addClickEventListenerWithSound(function(evt)
            if "open_bosom" == evt:getName() then
                local tab_module = StaticData['module'][2501]
                if not tab_module or tonumber(tab_module.openLevel) > uq.cache.role:level() then
                    uq.fadeInfo(string.format(StaticData["local_text"]["label.open.lv"],tostring(tab_module.openLevel)))
                    return
                end
            end
            uq.runCmd(evt:getName())
        end)
    end
end

function MainUILayer:_showHideBottomView(evt)
    local is_show = evt:isFlippedX()
    evt:setFlippedX(not is_show)
    local bottom_view = self._bottomUI:getParent()
    local action = nil
    local pos_y = bottom_view:getPositionY()
    if is_show then
        action = cc.MoveTo:create(0.15, cc.p(0, pos_y))
    else
        action = cc.MoveTo:create(0.15, cc.p(self._bottomUI:getContentSize().width, pos_y))
    end
    bottom_view:runAction(action)
end

function MainUILayer:_updateBottomIcons()
    local children = self._bottomUI:getChildren()
    local icon_gap = 20
    local pos_x = icon_gap
    for _, child in ipairs(children) do
        if child:isVisible() then
            child:setPosition(cc.p(pos_x, child:getPositionY()))
            pos_x = pos_x + child:getContentSize().width + icon_gap
        end
    end
    local parent = self._bottomUI:getParent()
    local parent_size = parent:getContentSize()
    self._bottomUI:setContentSize(cc.size(pos_x, parent_size.height))
    self._bottomUI:setPosition(cc.p(parent_size.width - pos_x, self._bottomUI:getPositionY()))
    parent:getChildByName('control_btn'):setPositionX(self._bottomUI:getPositionX() - 50)
end

function MainUILayer:hideControl()
    self._activityUI:setVisible(false)
    --self._leftUI:setVisible(false)
    self._equipChangeUI:setVisible(false)
    self._rightUIMain:setVisible(false)
    self._bottomUIMain:setVisible(false)
    self._taskUI:setVisible(false)
end

function MainUILayer:setActivityUIShow(flag)
    self._activityUI:setVisible(flag)
end

function MainUILayer:dispose()
    services:removeEventListenersByTag('_onMainCityBottomSideRedChanges' .. tostring(self))
    services:removeEventListenersByTag('_onMainCityTopSideRedChanges' .. tostring(self))
end

return MainUILayer