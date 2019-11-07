local GeneralsModule = class("GeneralsModule", require("app.base.PopupTabView"))

GeneralsModule.RESOURCE_FILENAME = "generals/GeneralsMain.csb"
GeneralsModule.RESOURCE_BINDING  = {
    ["Image_2"]                                                   ={["varname"] = "_imgBg"},
    ["Panel_46/role_container"]                                   ={["varname"] = "_roleInfoView"},
    ["Panel_46/Panel_3"]                                          ={["varname"] = "_roleScrollPanel"},
    ["txt_name"]                                                  ={["varname"] = "_txtName"},
    ["Panel_46/role_container/Panel_left"]                        ={["varname"] = "_panelLeft"},
    ["Panel_46/role_container/Panel_left/Node_2"]                 ={["varname"] = "_nodeStrength"},
    ["Panel_46/role_container/Panel_left/Node_2/bmfont_power"]    ={["varname"] = "_powerLabel"},
    ["Panel_46/role_container/Panel_left/Node_2/img_power_state"] ={["varname"] = "_powerImg"},
    ["Panel_46/role_container/Panel_left/Node_2/Text_1"]          ={["varname"] = "_txtAddPower"},
    ["Image_3"]                                                   ={["varname"] = "_imgType"},
    ["Panel_46/role_container/role_pageView"]                     ={["varname"] = "_rolePageView"},
    ["Panel_star"]                                                ={["varname"] = "_panelStar"},
    ["Panel_46/role_container/btn_left"]                          ={["varname"] = "_btnLeft",["events"] = {{["event"] = "touch",["method"] = "onBtnLeft"}}},
    ["Panel_46/role_container/btn_right"]                         ={["varname"] = "_btnRight",["events"] = {{["event"] = "touch",["method"] = "onBtnRight"}}},
    ["sub_cont"]                                                  ={["varname"] = "_panelRight"},
    ["Panel_46/Node_tab"]                                         ={["varname"] = "_nodeMenu"},
    ["Panel_2"]                                                   ={["varname"] = "_panelAdvance"},
    ["Panel_46"]                                                  ={["varname"] = "_panelMain"},
    ["Node_1"]                                                    ={["varname"] = "_nodeInfo"},
    ["action_node"]                                               ={["varname"] = "_nodeAction"},
    ["Node_40"]                                                   ={["varname"] = "_nodeTxtUp"},
    ["Node_5"]                                                    ={["varname"] = "_nodeEffect"},
    ["Button_1"]                                                  ={["varname"] = "_btnDelete",["events"] = {{["event"] = "touch",["method"] = "onClickDeleteGeneral"}}},
}
function GeneralsModule:ctor(name, args)
    GeneralsModule.super.ctor(self, name, args)
    self._tabIndex = args._tab_index or 1
    self._subIndex = args._sub_index or 1
    self._generalId = args._general_id or uq.cache.formation:getDefaultFormationFirstGeneral()
    self._curPageIndex = args._index and args._index - 1 or 0
    self._selectedType = args._occupation or 0
    self._maxIndex = args._max_index or uq.cache.generals:getAllGeneralNumByType(self._generalId) or 0
    self._generalsSex = -1
    self._canScroll = true
    self._pageTimer = "timer_add_page" .. tostring(self)
    self._showInsightBtnState = true
    self._gameMode = args.mode or 1
    GeneralsModule._subModules = {
        {path = "app.modules.generals.GeneralsAttribute"}, --详情
        {path = "app.modules.generals.GeneralsEquip"}, --装备
        {path = "app.modules.generals.GeneralsArms"}, --兵种
        {path = "app.modules.generals.GeneralsQuality"}, --品质
        {path = "app.modules.generals.GeneralsInsight"}, --顿悟
    }
    self._allIndex = #GeneralsModule._subModules
    GeneralsModule._openTab = {
        StaticData['module'][101]["openLevel"],
        StaticData['module'][101]["openLevel"],
        StaticData['module'][103]["openLevel"],
        StaticData['module'][106]["openLevel"],
        StaticData['module'][104]["openLevel"],
    }

    GeneralsModule._tabTxt = {
        StaticData['local_text']["label.attribute"],
        StaticData['local_text']["label.equip"],
        StaticData['local_text']["label.arms"],
        StaticData['local_text']["label.quality"],
        StaticData['local_text']["label.insight"],
    }

    GeneralsModule._imgPath1 = {
        "img/generals/j02_0000032.png",
        "img/generals/j02_0000031.png",
        "img/generals/j02_0000030.png",
        "img/generals/j02_0000028.png",
        "img/generals/j02_0000029.png",
    }

    GeneralsModule._imgPath2 = {
        "img/generals/j02_0000037.png",
        "img/generals/j02_0000036.png",
        "img/generals/j02_0000035.png",
        "img/generals/j02_0000033.png",
        "img/generals/j02_0000034.png",
    }
    self._pagepanel = {}
    if self._gameMode == uq.config.constant.GAME_MODE.INSTANCE_WAR then
        self._upState = uq.cache.instance_war:isGeneralUp(self._generalId)
    else
        self._upState = uq.cache.generals:isGeneralUp(self._generalId)
    end
    if not self._upState then
        GeneralsModule._subModules[1].path = "app.modules.generals.GeneralsAttrNode"
    end
    self._nodeStrength:setVisible(self._upState)
end

function GeneralsModule:onCreate()
    GeneralsModule.super.onCreate(self)
    self:adaptSize()
end

function GeneralsModule:init()
    self._tabModuleArray = {}
    self._generalsInfoArray = {}
    self._curGeneralInfo = {}
    self._curPagePreIndex = 0 --当前页面前一个页面的索引
    self._curPageNextIndex = 0 --当前页面后一个页面的索引
    self._curPageNum = 0
    self._starItem = nil
    self._scrollTag = "change_scroll_state" .. tostring(self)
    local top_ui = uq.ui.CommonHeaderUI:create()
    if self._gameMode == uq.config.constant.GAME_MODE.INSTANCE_WAR then
        top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.GESTE, false, nil, uq.config.constant.GAME_MODE.INSTANCE_WAR))
    else
        top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.GESTE, true))
        top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.IRON_MINE, true))
        top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.MONEY, true))
        top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.GOLDEN, true))
    end
    top_ui:setTitle(uq.config.constant.MODULE_ID.GENERAL_ATTRIBUTE)
    top_ui:setRuleId(uq.config.constant.MODULE_RULE_ID.GENERAL_MODULE)
    self._topUI = top_ui
    self._view:addChild(top_ui:getNode())
    self:parseView()
    self:centerView()
    self._rightPosx = self._panelRight:getPositionX()
    self:setupView()
    self:initProtocolData()
    self:playOpenAction()
    self._upAction = uq.createPanelOnly("generals.GeneralsUpAction")
    self._nodeAction:addChild(self._upAction)
end

function GeneralsModule:adaptSize()
    self._panelMain:setContentSize(cc.size(display.size.width, CC_DESIGN_RESOLUTION.height))
    self._nodeMenu:setPositionX(display.width)

    local img_size = CC_DESIGN_RESOLUTION
    self._imgBg:setContentSize(cc.size(display.size.width, img_size.height))
    local sub_pos_delta = display.size.width - img_size.width

    local role_size = self._rolePageView:getContentSize()
    self._rolePageView:setContentSize(cc.size(role_size.width + sub_pos_delta, display.size.height))
    self._roleScrollPanel:setContentSize(cc.size(role_size.width + sub_pos_delta, display.size.height))

    local sub_pos_x = self._panelRight:getPositionX()
    self._panelRight:setPositionX(sub_pos_x + sub_pos_delta / 2)

    local btn_right_x = self._btnRight:getPositionX()
    self._btnRight:setPositionX(sub_pos_delta + btn_right_x)

    local node_strength_x = self._nodeStrength:getPositionX()
    self._nodeStrength:setPositionX(node_strength_x + sub_pos_delta / 2)
end

function GeneralsModule:playOpenAction()
    local img_size = self._rolePageView:getContentSize()
    uq:addEffectByNode(self._imgBg, 900005, -1, true, cc.p(img_size.width / 2, img_size.height / 2 + 167))
end

function GeneralsModule:setupView()
    self:initRoleInfo()

    self._view:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(handler(self, self.initPage))))
end

function GeneralsModule:initPage()
    self:setGeneralUpDown()
    self:_onRefreshRed()
    local xml_data = StaticData['general'][self._curGeneralInfo.temp_id]
    self:setInsightBtnState(xml_data.isJiuguan == 0)
    self._roleScrollPanel:setTouchEnabled(false)
    self._listener = cc.EventListenerTouchOneByOne:create()
    self._listener:registerScriptHandler(handler(self, self._onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
    self._listener:registerScriptHandler(handler(self, self._onTouchEnd), cc.Handler.EVENT_TOUCH_ENDED)
    local event_dispatcher = self._roleScrollPanel:getEventDispatcher()
    event_dispatcher:addEventListenerWithSceneGraphPriority(self._listener, self._roleScrollPanel)

    local panel = self._subModule[self._tabIndex]:getChildByName("Node"):getChildByName("Panel_2")
    panel:stopAllActions()
    panel:setOpacity(0)
    panel:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.FadeIn:create(0.2)))
end

function GeneralsModule:resetScrollState()
    if not uq.TimerProxy:hasTimer(self._scrollTag) then
        uq.TimerProxy:addTimer(self._scrollTag, function()
            self._canScroll = true
        end, 0, 1, 1)
    end
end

function GeneralsModule:_onTouchBegin(touch, event)
    self._touchBeginX = touch:getLocation().x
    if not self._canScroll then
        self._listener:setSwallowTouches(true)
        return true
    end
    self._listener:setSwallowTouches(false)
    return true
end

function GeneralsModule:_onTouchEnd(touch, event)
    if math.abs(touch:getLocation().x - self._touchBeginX) < 20 then
        return
    end
    if self._touchBeginX - touch:getLocation().x > 20 and (self._curPageIndex == self._maxIndex - 1) then
        return
    end
    if touch:getLocation().x - self._touchBeginX > 20 and (self._curPageIndex == 0) then
        return
    end

    if not self._canScroll then
        uq.fadeInfo(StaticData["local_text"]["general.scroll.des"])
        self:resetScrollState()
        return
    end
    uq.TimerProxy:removeTimer(self._scrollTag)
    self._canScroll = false
end

function GeneralsModule:playAction()
    uq.TimerProxy:addTimer("play_generals_module_right_action", function()
        self:playRightAction()
        uq.TimerProxy:removeTimer("play_generals_module_right_action")
    end, 0, 1, 0.2)
end

function GeneralsModule:playRightAction()
    self._panelRight:stopAllActions()
    local size = self._panelRight:getContentSize()
    self._panelRight:setPositionX(display.width + size.width)
    self._panelRight:runAction(cc.MoveTo:create(0.2, cc.p(self._rightPosx, self._panelRight:getPositionY())))
end

function GeneralsModule:onBtnLeft(event)
    if event.name == "ended" then
        if not self._canScroll then
            uq.fadeInfo(StaticData["local_text"]["general.scroll.des"])
            self:resetScrollState()
            return
        end
        uq.TimerProxy:removeTimer(self._scrollTag)
        if self._curPageIndex == 0 then
            return
        end
        self._canScroll = false
        local index = self._rolePageView:getCurrentPageIndex()
        index = index - 1
        if index  < 0 then
            index = 0
        end
        self._rolePageView:scrollToPage(index)
    end
end
function GeneralsModule:onClickDeleteGeneral(event)
    if event.name ~= "ended" or self._curGeneralInfo.rtemp_id == self._curGeneralInfo.temp_id then
        return
    end
    network:sendPacket(Protocol.C_2_S_GENERAL_DELETE, {general_id = self._curGeneralInfo.id})
end

function GeneralsModule:onBtnRight(event)
    if event.name == "ended" then
        if not self._canScroll then
            uq.fadeInfo(StaticData["local_text"]["general.scroll.des"])
            self:resetScrollState()
            return
        end
        uq.TimerProxy:removeTimer(self._scrollTag)
        if self._curPageIndex == self._maxIndex - 1 then
            return
        end
        self._canScroll = false
        local index = self._rolePageView:getCurrentPageIndex()
        self._rolePageView:scrollToPage(index + 1)
    end
end

function GeneralsModule:onTabChanged(sender, stop_action)
    local tag = sender:getTag()
    if self._tabIndex == tag and not stop_action then
        return
    end
    self._tabIndex = tag
    for k, v in ipairs(self._tabModuleArray) do
        v:getChildByName("img_select1"):setVisible(false)
        v:getChildByName("img_select2"):setVisible(false)
    end
    local img1 = sender:getChildByName("img_select1")
    local img2 = sender:getChildByName("img_select2")
    img1:setVisible(true)
    img2:setVisible(true)
    if not stop_action then
        img1:runAction(cc.RotateBy:create(0.15, -180))
        img2:runAction(cc.RotateBy:create(0.15, 180))
    end
    local path = self._subModules[tag].path
    self:addSub(path, nil, nil, tag, nil)

    local panel = self._subModule[tag]:getChildByName("Node"):getChildByName("Panel_2")
    panel:setOpacity(0)
    panel:runAction(cc.FadeIn:create(0.2))

    if self._curGeneralInfo.id ~= nil then
       --该事件虽然每次发送，不过只在tab页面刚打开时接收一次
        services:dispatchEvent({name=services.EVENT_NAMES.ON_INIT_GENERALS_INFO, data = self._curGeneralInfo, mode = self._gameMode})
    end
end

function GeneralsModule:initProtocolData()
    services:addEventListener(services.EVENT_NAMES.ON_UPDATE_GENERALINFO, handler(self,self._onUpdateGenaralInfo), "_onUpdateGenaralInfo")
    services:addEventListener(services.EVENT_NAMES.ON_TRANSFER_SOLDER_RES, handler(self,self._onTransferSoldierRes), "_onTransferSoldierRes")
    services:addEventListener(services.EVENT_NAMES.ON_REBULID_SOLDIERS_IDS, handler(self,self._onRebuildSoldierIds), "_onRebuildSoldierIds")
    services:addEventListener(services.EVENT_NAMES.ON_REBULID_SOLDIERS_RES, handler(self,self._onRebuildSoldierRes), "_onRebuildSoldierRes")
    services:addEventListener(services.EVENT_NAMES.ON_REINFORCE_SOLDIER, handler(self,self._onReinforcedSoldier), "_onReinforcedSoldier")
    services:addEventListener(services.EVENT_NAMES.ON_DELETE_GENERALS, handler(self,self.disposeSelf), '_onDeleteGeneral' .. tostring(self))
    services:addEventListener(services.EVENT_NAMES.ON_GET_GENERAL_ATTR, handler(self, self.runPowerUpAction), 'ON_GET_GENERAL_INFO' .. tostring(self))

    services:addEventListener(services.EVENT_NAMES.ON_UPDATE_GENERALS_MODULE_RED, handler(self, self._onRefreshRed), "_onRefreshGeneralModuleRed" .. tostring(self))
end

function GeneralsModule:_onRefreshRed(msg)
    local id = self._curGeneralInfo and self._curGeneralInfo.id or self._generalId
    if not id or id == 0 then
        return
    end
    if self._gameMode == uq.config.constant.GAME_MODE.NORMAL and uq.cache.generals:getGeneralDataByID(id) then
        local array = msg and msg.data or {1, 2, 3, 4, 5}
        for k, v in ipairs(array) do
            local is_red = uq.cache.generals:getGeneralsModuleRedByIndex(v, id)
            self:showMenuRed(v, is_red)
        end
    elseif self._gameMode == uq.config.constant.GAME_MODE.INSTANCE_WAR and uq.cache.instance_war:getGeneralData(id) then
        local is_red = uq.cache.instance_war:isCanLevelUp(id)
        self:showMenuRed(1, is_red)
    else
        local is_red = false
        is_red = uq.cache.generals:isComposeRedById(id)
        self:showMenuRed(1, is_red)
    end
end

function GeneralsModule:removeProtocolData()
    uq.TimerProxy:removeTimer('updateGeneralPowerGenralUpdate')
    services:removeEventListenersByTag("_onUpdateGenaralInfo")
    services:removeEventListenersByTag("_onTransferSoldierRes")
    services:removeEventListenersByTag("_onRebuildSoldierIds")
    services:removeEventListenersByTag("_onRebuildSoldierRes")
    services:removeEventListenersByTag("_onReinforcedSoldier")
    services:removeEventListenersByTag('_onDeleteGeneral' .. tostring(self))
    services:removeEventListenersByTag('ON_GET_GENERAL_INFO' .. tostring(self))

    services:removeEventListenersByTag('_onRefreshGeneralModuleRed' .. tostring(self))
end

function GeneralsModule:_onReinforcedSoldier(msg)
    local info = msg.data
    for k, v in pairs(self._generalsInfoArray) do
        if v.id == info.generalId then
            if self._generalsInfoArray[k].soldierId1 == info.oriId then
                if self._generalsInfoArray[k].soldierId1 == self._generalsInfoArray[k].battle_soldier_id then
                    self._generalsInfoArray[k].battle_soldier_id = info.curId
                end
                self._generalsInfoArray[k].soldierId1 = info.curId
            else
                if self._generalsInfoArray[k].soldierId2 == self._generalsInfoArray[k].battle_soldier_id then
                    self._generalsInfoArray[k].battle_soldier_id = info.curId
                end
                self._generalsInfoArray[k].soldierId2 = info.curId
            end
            break
        end
    end
    if self._curGeneralInfo.id == info.generalId then
        if self._curGeneralInfo.soldierId1 == info.oriId then
            if self._curGeneralInfo.soldierId1 == self._curGeneralInfo.battle_soldier_id then
                self._curGeneralInfo.battle_soldier_id = info.curId
            end
            self._curGeneralInfo.soldierId1 = info.curId
        else
            if self._curGeneralInfo.soldierId2 == self._curGeneralInfo.battle_soldier_id then
                self._curGeneralInfo.battle_soldier_id = info.curId
            end
            self._curGeneralInfo.soldierId2 = info.curId
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CHANGE_GENERALS, data = self._curGeneralInfo})
end

function GeneralsModule:_onRebuildSoldierRes(msg)
    local info = msg.data
    for k, v in pairs(self._generalsInfoArray) do
        if v.id == info.genaral_id then
            if self._generalsInfoArray[k].soldierId1 == self._generalsInfoArray[k].battle_soldier_id then
                self._generalsInfoArray[k].battle_soldier_id = info.soldier_id1
            else
                self._generalsInfoArray[k].battle_soldier_id = info.soldier_id2
            end
            self._generalsInfoArray[k].soldierId1 = info.soldier_id1
            self._generalsInfoArray[k].soldierId2 = info.soldier_id2
            self._generalsInfoArray[k].rebuildSoldierId1 = 0
            self._generalsInfoArray[k].rebuildSoldierId2 = 0
            break
        end
    end
    if self._curGeneralInfo.id == info.genaral_id then
        if self._curGeneralInfo.soldierId1 == self._curGeneralInfo.battle_soldier_id then
            self._curGeneralInfo.battle_soldier_id = info.soldier_id1
        else
            self._curGeneralInfo.battle_soldier_id = info.soldier_id2
        end
        self._curGeneralInfo.soldierId1 = info.soldier_id1
        self._curGeneralInfo.soldierId2 = info.soldier_id2
        self._curGeneralInfo.rebuildSoldierId1 = 0
        self._curGeneralInfo.rebuildSoldierId2 = 0
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CHANGE_GENERALS, data = self._curGeneralInfo})
end

function GeneralsModule:_onRebuildSoldierIds(msg)
    local info = msg.data
    for k, v in pairs(self._generalsInfoArray) do
        if v.id == info.genaral_id then
            self._generalsInfoArray[k].rebuildSoldierId1 = info.soldier_id1
            self._generalsInfoArray[k].rebuildSoldierId2 = info.soldier_id2
            break
        end
    end
    if self._curGeneralInfo.id == info.genaral_id then
        self._curGeneralInfo.rebuildSoldierId1 = info.soldier_id1
        self._curGeneralInfo.rebuildSoldierId2 = info.soldier_id2
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CHANGE_GENERALS, data = self._curGeneralInfo})
end

function GeneralsModule:_onTransferSoldierRes(msg)
    local info = msg.data
    for k, v in pairs(self._generalsInfoArray) do
        if v.id == info.genaral_id then
            if self._generalsInfoArray[k].soldierId1 == self._generalsInfoArray[k].battle_soldier_id then
                self._generalsInfoArray[k].battle_soldier_id = info.new_soldier_id1
            else
                self._generalsInfoArray[k].battle_soldier_id = info.new_soldier_id2
            end
            self._generalsInfoArray[k].soldierId1 = info.new_soldier_id1
            self._generalsInfoArray[k].soldierId2 = info.new_soldier_id2
            break
        end
    end
    if self._curGeneralInfo.id == info.genaral_id then
        if self._curGeneralInfo.soldierId1 == self._curGeneralInfo.battle_soldier_id then
            self._curGeneralInfo.battle_soldier_id = info.new_soldier_id1
        else
            self._curGeneralInfo.battle_soldier_id = info.new_soldier_id2
        end
        self._curGeneralInfo.soldierId1 = info.new_soldier_id1
        self._curGeneralInfo.soldierId2 = info.new_soldier_id2
    end
    --self:_onRefreshRed()
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ARMS_ADVANCE_SUCCESS_MODULE, {info = info})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CHANGE_GENERALS, data = self._curGeneralInfo})
end

function GeneralsModule:_onUpdateGenaralInfo()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CHANGE_GENERALS, data = self._curGeneralInfo})
    self:updateRoleInfo()
end

function GeneralsModule:_onGeneralInfo()
    self._generalsInfoArray = {}
    local up_list = {}
    if self._gameMode == uq.config.constant.GAME_MODE.INSTANCE_WAR then
        up_list = uq.cache.instance_war:getUpGeneralsByType(self._selectedType)
        for k, v in ipairs(up_list) do
            local general_info = uq.cache.instance_war:getGeneralData(v.id)
            table.insert(self._generalsInfoArray, general_info)
        end
    else
        up_list = uq.cache.generals:getUpGeneralsByType(self._selectedType)
        for k, v in ipairs(up_list) do
            local general_info = uq.cache.generals:getGeneralDataByID(v.id)
            table.insert(self._generalsInfoArray, general_info)
        end
    end

    for k, v in ipairs(self._generalsInfoArray) do
        if self._generalId == v.id then
            self._curPageIndex = k - 1
            break
        end
    end
    self._curGeneralInfo = self:getGeneralDataByIndex(self._curPageIndex + 1)
    if self._curGeneralInfo == nil then
        self._curGeneralInfo = {}
    end
    self:updatePageIndex()
end

function GeneralsModule:updatePageIndex()
    self._curPagePreIndex = self._curPageIndex - 1
    if self._curPagePreIndex < 0 then
        self._curPagePreIndex = 0
    end
    self._curPageNextIndex = self._curPageIndex + 1
    if self._curPageNextIndex == self._maxIndex then
        self._curPageNextIndex = self._maxIndex - 1
    end
end

function GeneralsModule:initRoleInfo()
    self._btnLeft:setPressedActionEnabled(true)
    self._btnRight:setPressedActionEnabled(true)
    self._starItem = uq.createPanelOnly("generals.GeneralsStarNode")
    self._panelStar:addChild(self._starItem)
    self:_onGeneralInfo()
    self:initBagBox()
    self:updateRoleInfo(true)
end

function GeneralsModule:updateRoleInfo(stop_action)
    self._btnLeft:setVisible(self._curPageIndex ~= 0)
    self._btnRight:setVisible(self._curPageIndex ~= self._maxIndex - 1)
    -- 发送数据给子的界面，用于更新
    local generals_xml = StaticData['general'][self._curGeneralInfo.temp_id]
    if not generals_xml then
        uq.log("error  GeneralsModule updateRoleInfo")
        return
    end
    if self._generalsSex ~= generals_xml.gender then
        self._generalsSex = generals_xml.gender
    end
    local generals_grade = StaticData['types'].GeneralGrade[1].Type[self._curGeneralInfo.grade]
    self._imgType:loadTexture("img/generals/" .. generals_grade.image)
    self._txtName:setString(self._curGeneralInfo.name)
    self._starItem:setData(generals_xml.qualityType)
    if stop_action then
        uq.TimerProxy:removeTimer('updateGeneralPowerGenralUpdate')
        self._powerLabel:setString(self._curGeneralInfo.power)
        self._power = self._curGeneralInfo.power
    end
    self:setInsightBtnState(generals_xml.isJiuguan == 0)
    self._btnDelete:setVisible(self._curGeneralInfo.rtemp_id ~= self._curGeneralInfo.temp_id)
end

function GeneralsModule:runPowerUpAction()
    uq.TimerProxy:removeTimer('updateGeneralPowerGenralUpdate')
    self._powerLabel:setString(self._power)
    self._nodeTxtUp:stopAllActions()
    self._nodeTxtUp:setVisible(false)
    self._nodeEffect:removeAllChildren()


    local pre_power = (self._curGeneralInfo.power - self._power) / 20
    if pre_power <= 0 then
        self._power = self._curGeneralInfo.power
        self._powerLabel:setString(self._power)
        return
    end
    uq.playSoundByID(53)
    uq:addEffectByNode(self._nodeEffect, 900006, 1, true, cc.p(40, 30), function()
        self._nodeTxtUp:setVisible(true)
        local sequence = cc.Sequence:create(cc.FadeIn:create(0.02), cc.DelayTime:create(0.08) ,cc.FadeOut:create(0.02), cc.DelayTime:create(0.04))
        self._nodeTxtUp:runAction(cc.Repeat:create(sequence, 3))
        self._txtAddPower:setString("+" .. math.floor(self._curGeneralInfo.power - self._power))
        uq.TimerProxy:addTimer('updateGeneralPowerGenralUpdate', function()
            self._power = self._power + pre_power
            self._powerLabel:setString(math.floor(self._power + 0.1))
        end, 0.01, 20, 0.5)
    end)
end

function GeneralsModule:setGeneralUpDown()
    --下野武将无法训练
    local tab_index = {1}--, 2, 4, 5}
    local equip_red = false
    local qulity_red = false
    local hide_item = false
    if self._gameMode == uq.config.constant.GAME_MODE.INSTANCE_WAR then
       if uq.cache.instance_war:getGeneralData(self._curGeneralInfo.id) then
            hide_item = true
            tab_index = {1}
        end
    else
        if uq.cache.generals:getGeneralDataByID(self._curGeneralInfo.id) then
            hide_item = true
            tab_index = {1, 2, 3, 4, 5}
            equip_red = uq.cache.generals:isCanOperateEquip(self._curGeneralInfo.id)
            qulity_red = uq.cache.generals:isQulityRedById(self._curGeneralInfo.id)
        end
    end
    self._nodeMenu:setVisible(hide_item)
    local tab_item = self._nodeMenu:getChildByName("Panel_1")
    local posx, posy = tab_item:getPosition()
    self._tabPosY = posy
    tab_item:setVisible(false)
    local select_item = nil
    for k, v in ipairs(tab_index) do
        if self._openTab[v] <= uq.cache.role:level() then
            local item = tab_item:clone()
            self._nodeMenu:addChild(item)
            item:setTag(v)
            item:setVisible(true)
            item:getChildByName("txt"):setString(self._tabTxt[v])
            item:setPosition(posx, posy)
            item:setTouchEnabled(true)
            item:addClickEventListener(function(sender)
                uq.playSoundByID(uq.config.constant.COMMON_SOUND.CHANGE)
                self:onTabChanged(sender, false)
            end)
            if v == self._tabIndex then
                select_item = item
            end
            posy = posy - item:getContentSize().height - 5
            table.insert(self._tabModuleArray, item)
        end
    end
    self:showMenuRed(2, equip_red)
    self:showMenuRed(4, qulity_red)
    if select_item then
        self:onTabChanged(select_item, true)
    end
end

function GeneralsModule:setTabVisible(index, visible)
    local pos_y = self._tabPosY
    local item = nil
    local change_selected = false
    for k, v in ipairs(self._tabModuleArray) do
        local state = v:isVisible()
        if k == index then
            state = visible
            v:setVisible(visible)
            change_selected = self._tabIndex == k and not visible
        end
        if state then
            if not item then
                item = v
            end
            local size = v:getContentSize()
            v:setPositionY(pos_y)
            pos_y = pos_y - size.height - 5
        end
    end

    if change_selected and item then
        self:onTabChanged(item, true)
    end
end

function GeneralsModule:setInsightBtnState(visible)
    if self._showInsightBtnState == visible or not self._tabModuleArray or next(self._tabModuleArray) == nil then
        return
    end
    self._showInsightBtnState = visible
    self:setTabVisible(5, visible)
end

function GeneralsModule:showMenuRed(index, red)
    for k ,v in ipairs(self._tabModuleArray) do
        if v:getTag() == index then
            uq.showRedStatus(v, red, -v:getContentSize().width / 2 + 10, v:getContentSize().height / 2 - 10)
            break
        end
    end
end

function GeneralsModule:updatePageView(pageindex, page)
    if not self._roleInfoView then return end
    local index_num = self._curPageNextIndex
    local widht = self._rolePageView:getContentSize().width
    local height = self._rolePageView:getContentSize().height
    local bag_panel = self:getLayout(widht, height)
    bag_panel.pageindex = pageindex
    self._rolePageView:insertPage(bag_panel, page)  --page 往前加就是0，往后加就是当前页面总数

    self:initBagPanel(bag_panel, pageindex + 1)
    self._curPageNum = self._curPageNum + 1
    if page == 0 then
        self._rolePageView:setCurrentPageIndex(1) --直接显示到改页面
    else
        self._rolePageView:setCurrentPageIndex(page - 1)
    end
end

function GeneralsModule:initBagBox()
    if not self._roleInfoView then return end
    if not self._rolePageView then
        return
    end
    self._rolePageView:removeAllPages()
    self._rolePageView:setCustomScrollThreshold(20.0)
    self._rolePageView:setTouchEnabled(true)
    self._rolePageView:setClippingEnabled(true)
    self._rolePageView:addEventListener(handler(self, self.scrollEvent))

    local index_num = self._curPageNextIndex + 1
    self._curPagePreIndex = math.max(0, self._curPageIndex - 1)
    local widht = self._rolePageView:getContentSize().width
    local height = self._rolePageView:getContentSize().height
    local bag_panel = self:getLayout(widht, height)
    bag_panel.pageindex = self._curPageIndex
    self._curPageNum = self._curPageNum + 1
    self._rolePageView:addPage(bag_panel)
    self:initBagPanel(bag_panel, self._curPageIndex + 1)

    self._rolePageView:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
        for i = self._curPagePreIndex + 1, index_num do
            if i - 1 ~= self._curPageIndex then
                local bag_panel = self:getLayout(widht, height)
                bag_panel.pageindex = i - 1
                self._curPageNum = self._curPageNum + 1
                self._rolePageView:insertPage(bag_panel, i - 1 - self._curPagePreIndex)
                self:initBagPanel(bag_panel, i)
            end
        end
        self._rolePageView:setCurrentPageIndex(self._curPageIndex - self._curPagePreIndex)
    end)))
end

function GeneralsModule:scrollEvent()
    local count = self._maxIndex
    local index = self._rolePageView:getCurrentPageIndex()
    local cell = self._rolePageView:getItem(index)
    if cell and cell.pageindex == self._curPageIndex then
        return
    end
    self._curPageIndex = cell.pageindex
    self:updateSpine()
    if self._curPageIndex == self._curPageNextIndex and self._curPageNextIndex < count - 1 then
        --加入页面
        self._curPageNextIndex = self._curPageNextIndex + 1
        self:updatePageView(self._curPageNextIndex, self._curPageNum)
    elseif self._curPageIndex == self._curPagePreIndex and self._curPagePreIndex > 0 then
        self._curPagePreIndex = self._curPagePreIndex - 1
        if uq.TimerProxy:hasTimer(self._pageTimer) then
            uq.TimerProxy:removeTimer(self._pageTimer)
        end
        uq.TimerProxy:addTimer(self._pageTimer, function()
            self:updatePageView(self._curPagePreIndex, 0)
        end)
    end
    self._curGeneralInfo = self:getGeneralDataByIndex(self._curPageIndex + 1)
    self._generalId = self._curGeneralInfo.id
    if self._curGeneralInfo == nil then
        uq.log("error _curGeneralInfo")
        self._curGeneralInfo = {}
    end
    self:_onRefreshRed()
    self:updateRoleInfo(true)
    services:dispatchEvent({name=services.EVENT_NAMES.ON_CHANGE_GENERALS, data = self._curGeneralInfo}) --更新右侧界面数据
    self._canScroll = true
end

function GeneralsModule:getLayout(width, height)
    local layer = ccui.Layout:create()
    layer:setTouchEnabled(false)
    layer:setContentSize( cc.size(width, height) )
    layer:setClippingEnabled(true)
    layer:setBackGroundColorType(0)
    return layer
end

function GeneralsModule:updateSpine()
    local min_index = self._curPageIndex - 3
    local max_index = self._curPageIndex + 3
    for i = min_index, max_index do
        local data = self._pagepanel[i]
        if data then
            if i == min_index or i == max_index then
                if data.state then
                    data.panel:removeAllChildren()
                    data.state = false
                end
            else
                if not data.state then
                    self:addSpine(data.panel, i)
                    data.state = true
                end
            end
        end
    end
end

function GeneralsModule:initBagPanel(panel, curPage)
    if nil == self._view then
        return
    end
    if curPage <= self._maxIndex then
        self:addSpine(panel, curPage)
        self._pagepanel[curPage] = {panel = panel, state = true}
    end
end

function GeneralsModule:addSpine(panel, curPage)
    local info = self:getGeneralDataByIndex(curPage)
    if info and next(info) ~= nil then
        local generals_xml = StaticData['general'][info.rtemp_id]
        local anim_id = generals_xml.imageId
        local pre_path = "animation/spine/" .. anim_id .. '/' .. anim_id
        local size = panel:getContentSize()
        if cc.FileUtils:getInstance():isFileExist(pre_path .. '.skel') then
            local anim = sp.SkeletonAnimation:createWithBinaryFile(pre_path .. '.skel', pre_path .. '.atlas', 1)
            panel:addChild(anim)
            anim:setScale(generals_xml.imageRatio)
            anim:setPosition(cc.p(size.width * 0.5 + generals_xml.imageX - 500, generals_xml.imageY))
            anim:setAnimation(0, 'idle', true)
        else
            local img = ccui.ImageView:create(pre_path .. '.png')
            panel:addChild(img)
            img:setAnchorPoint(cc.p(0.5, 1))
            img:setScale(generals_xml.imageRatio)
            img:setPosition(cc.p(size.width * 0.5 + generals_xml.imageX, size.height + generals_xml.imageY))
        end
    end
end

function GeneralsModule:dispose()
    if self._topUI then
        self._topUI:dispose()
    end
    self._topUI = nil
    uq.TimerProxy:removeTimer(self._scrollTag)
    uq.TimerProxy:removeTimer(self._pageTimer)
    self:removeProtocolData()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_RELOAD_COLLECT_VIEW})
    GeneralsModule.super.dispose(self)
    display.removeUnusedSpriteFrames()
end

function GeneralsModule:getGeneralDataByIndex(index)
    if self._gameMode == uq.config.constant.GAME_MODE.NORMAL and uq.cache.generals:getGeneralDataByID(self._generalId) then --上野武将
        return self._generalsInfoArray[index]
    elseif self._gameMode == uq.config.constant.GAME_MODE.INSTANCE_WAR and uq.cache.instance_war:getGeneralData(self._generalId) then
        return self._generalsInfoArray[index]
    else
        local down_list = {}
        if self._gameMode == uq.config.constant.GAME_MODE.INSTANCE_WAR then
            down_list = uq.cache.instance_war:getDownGeneralsByType(self._selectedType)
        else
            down_list = uq.cache.generals:getDownGeneralsByType(self._selectedType)
        end
        local general_data = down_list[index] or {}
        if not general_data or next(general_data) == nil then
            return {}
        end
        general_data.down = true

        local xml_data = StaticData['general'][general_data.temp_id]
        local data = {
            id = general_data.id,
            temp_id = general_data.temp_id,
            rtemp_id = general_data.temp_id,
            lvl = general_data.lvl,
            leader = 0,
            attack = 0,
            mental = 0,
            current_soldiers = xml_data.soldierNum,
            max_soldiers = xml_data.soldierNum,
            soldierId1 = StaticData['types']['Occupation'][1].Type[xml_data.occupationType].soldierId1,
            soldierId2 = StaticData['types']['Occupation'][1].Type[xml_data.occupationType].soldierId2,
            rebuildSoldierId1 = 0,
            rebuildSoldierId2 = 0,
            current_exp = 0,
            train_time = -1,
            reincarnation_tims = 0,
            next_reincarnation_lvl = 0,
            battle_soldier_id = StaticData['types']['Occupation'][1].Type[xml_data.occupationType].soldierId1,
            train_time_type = 0,
            train_type = 0,
            auto_reincarnation = 0,
            skill_id = 0,
            name = xml_data.name,
            wound_type = 0,
            tavern_add_soldier_num = 0,
            tavern_add_mentality = 0,
            tavern_add_leader = 0,
            tavern_add_attack = 0,
            leader_atk = 0,
            leader_atk_def = 0,
            policy_atk = 0,
            policy_atk_def = 0,
            attack_atk = 0,
            attack_atk_def = 0,
            crit_rate = 0,
            beat_back_rate = 0,
            dec_injury_rate = 0,
            dragon_soul = 0,
            tiger_soul = 0,
            basaitic_soul = 0,
            transferSoldierTimes = 0,
            siege = 0,
            skill_level = 0,
            grade = xml_data.grade,
            limitSoldierNum = 0,
            unlock = general_data.unlock,
            down = general_data.down,
        }
        return data
    end
end

return GeneralsModule
