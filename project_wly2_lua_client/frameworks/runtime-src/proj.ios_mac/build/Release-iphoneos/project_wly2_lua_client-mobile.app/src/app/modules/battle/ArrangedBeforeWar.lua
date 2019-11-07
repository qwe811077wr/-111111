local ArrangedBeforeWar = class("ArrangedBeforeWar", require('app.modules.common.BaseViewWithHead'))
local EmbattleTip = require("app.modules.embattle.EmbattleGeneralTip")

ArrangedBeforeWar.RESOURCE_FILENAME = "battle/ArrangedBefore.csb"
ArrangedBeforeWar.RESOURCE_BINDING = {
    ["img_bg_adapt"]    = {["varname"] = "_imgBg"},
    ["def_side"]        = {["varname"] = "_nodeDef"},
    ["atk_side"]        = {["varname"] = "_nodeAtk"},
    ["Node_info"]       = {["varname"] = "_nodeLeftTop"},
    ["Node_leftCenter"] = {["varname"] = "_nodeLeftMiddle"},
    ["Panel_tab"]       = {["varname"] = "_panelTab"},
    ["Panel_25"]        = {["varname"] = "_rightListLayer"},
    ["Node_downLeft"]   = {["varname"] = "_nodeLeftBottom"},
    ["Node_rightUp"]    = {["varname"] = "_nodeRightTop"},
    ["Node_centerUp"]   = {["varname"] = "_nodeCenterUp"},
    ["Node_rightDown"]  = {["varname"] = "_nodeRightBottom"},
    ["Node_rightCenter"]= {["varname"] = "_nodeRightMiddle"},
    ["Button_3"]        = {["varname"] = "_btnSwitch",["events"] = {{["event"] = "touch",["method"] = "_onSwitch"}}},
    ["img_btn"]         = {["varname"] = "_imgBtnSwitch"},
    ["Button_9"]        = {["varname"] = "_btnFind",["events"] = {{["event"] = "touch", ["method"] = "_onFind"}}},
    ["Panel_26"]        = {["varname"] = "_panelBottom"},
    ["Node_tip"]        = {["varname"] = "_nodeTips"},
    ["Button_1"]        = {["varname"] = "_btnSoldier",["events"] = {{["event"] = "touch",["method"] = "_onSoldier"}}},
    ["Button_30"]       = {["varname"] = "_btnConfirm",["events"] = {{["event"] = "touch",["method"] = "onConfirm"}}},
    ["Button_30_0"]     = {["varname"] = "_btnNationConfirm",["events"] = {{["event"] = "touch",["method"] = "onNationConfirm"}}},
    ["Button_31"]       = {["varname"] = "_btnSet",["events"] = {{["event"] = "touch",["method"] = "onSetState"}}},
    ["Node_3"]          = {["varname"] = "_nodeMove"},
    ["Text_54"]         = {["varname"] = "_txtForamtionDes"},
    ["Text_53"]         = {["varname"] = "_txtEmbattleInfoName"},
    ["Text_56"]         = {["varname"] = "_txtPower"},
    ["img_icon"]        = {["varname"] = "_imgIcon"},
    ["Image_7"]         = {["varname"] = "_imgTipsBg"},
    ["Text_2"]          = {["varname"] = "_txtGroundTip"},
    ["Image_29"]        = {["varname"] = "_switchBg"},
    ["Panel_3"]         = {["varname"] = "_panelInput"},
    ["Button_8"]        = {["varname"] = "_btnExitInput",["events"] = {{["event"] = "touch",["method"] = "_onCloseInput"}}},
    ["Panel_11"]        = {["varname"] = "_panelText"},
    ["Panel_14"]        = {["varname"] = "_panelSwitch"},
    ["Panel_2"]         = {["varname"] = "_panelLeftItem"},
    ["Text_1"]          = {["varname"] = "_txtFood"},
}

ArrangedBeforeWar.PAGE = {
    PAGE_WUJIANG = 1,
    PAGE_ZHIJI = 2,
}

function ArrangedBeforeWar:ctor(name, params)
    ArrangedBeforeWar.super.ctor(self, name, params)
    self._confirmCallBack = params.confirm_callback
    self._allListDown = {}
    self._curArmyData = {}
    self._allArmyData = params.army_data
    self._embattleType = params.embattle_type
    self._SoldierArray = params.soldier_array or {}
    self._npcData = params.npc_data
    self._rank = params.rank
    self._bgName = params.bg_name
    self._curArrayIndex = 1
    self._showBtn = {false, false, false}
    self._siftType = {}
    self._txtSift = {
        StaticData['local_text']['label.quality'],
        StaticData['local_text']['label.type'],
        StaticData['local_text']['fly.nail.general.des8']
    }
    self._injureState = self._embattleType == uq.config.constant.TYPE_EMBATTLE.INSTANCE_EMBATTLE or self._embattleType == uq.config.constant.TYPE_EMBATTLE.NATIONAL_WAR_EMBATTLE
    self._showAllEmbattleInfo = false
    self._enemyData = {}
    for k, v in ipairs(params.enemy_data) do
        self._enemyData[v.index] = v
    end
    self._foodNeed = 0
    self:endActionTop()
end

function ArrangedBeforeWar:initEnemyData(data)
    self._enemyData = {}
    for k, v in ipairs(data) do
        self._enemyData[v.index] = v
    end
    for k, v in ipairs(self._enemyList) do
        v:setData(k, self._enemyData[k], self._injureState)
    end
end

function ArrangedBeforeWar:_onGetEnemyFormation(msg)
    local data = msg.data.generals
    self:initEnemyData(data)
end

function ArrangedBeforeWar:_onFind(evt)
    if evt.name ~= "ended" then
        return
    end
    if not self._showInput then
        self._showInput = true
        self:setInputVisible(true)
    else
        local name = self._editBoxName:getText()
        if name and name ~= "" then
            self._siftListDown = {}
            for k, v in ipairs(self._allListDown) do
                local xml_data = uq.cache.generals:getGeneralDataXML(tonumber(v.id .. 1))
                if string.match(xml_data.name, name) then
                    table.insert(self._siftListDown, v)
                end
            end
            self._tableView:reloadData()
        else
            uq.fadeInfo(StaticData['local_text']['errror.input.general'])
        end
    end
end

function ArrangedBeforeWar:_onCloseInput(evt)
    if evt.name ~= "ended" then
        return
    end
    self._showInput = false
    self:setInputVisible(false)
    self:filterDownGenrealData()
end

function ArrangedBeforeWar:init()
    self._curPage = self.PAGE.PAGE_WUJIANG
    self._curFormation = nil
    self._openFromOther = false
    self._roleCardList = {}
    self:setBgVisible(false)

    self:centerView()
    self:parseView(self._view)
    self:adaptBgSize()
    local saft_delta_x = uq.getAdaptOffX()
    self._panelSwitch:setContentSize(cc.size(display.size.width - saft_delta_x * 2, display.size.height))
    self._panelLeftItem:setContentSize(cc.size(display.size.width - saft_delta_x * 2, display.size.height))
    self:adaptNode()
    self._imgBg:addClickEventListener(function()
        self:setLeftListVisible(false)
    end)
    if self._bgName then
        self._imgBg:loadTexture(self._bgName)
    elseif self._npcData and self._npcData.battleBg then
        self._imgBg:loadTexture('img/bg/battle/' .. self._npcData.battleBg)
    end
    self:initPage()
    self:initTableView()

    self._moveCard = uq.createPanelOnly("embattle.EmbattleRoleCard")
    self._moveCard:setScale(0.6)
    self._moveCard:setOpacity(150)

    self._moveItem = uq.createPanelOnly("battle.ArrangedItem")
    self._moveItem:setCanClick(false)
    self._moveItem:setOpacity(150)
    self._nodeMove:addChild(self._moveCard)
    self._nodeMove:addChild(self._moveItem)
    self._nodeMove:setVisible(false)


    self._panelTab:setVisible(false)
    local state = self._embattleType == uq.config.constant.TYPE_EMBATTLE.NATIONAL_WAR_EMBATTLE
    self._btnConfirm:setVisible(not state)
    self._btnNationConfirm:setVisible(state)
    self:initTabSift()
    if self._embattleType == uq.config.constant.TYPE_EMBATTLE.INSTANCE_EMBATTLE then
        local data = uq.cache.formation:getAllFormation()
        if not data then
            network:sendPacket(Protocol.C_2_S_FORMATION_INFO)
            return
        else
            self:formatData(data)
            self._curFormation = data.default_id
        end
        self:setFormation(self._curFormation)
    else
        if not self._allArmyData then
            return
        end
        self._curFormation = self._allArmyData[1].ids[1]
        self:setFormation(self._curFormation)
        if #self._allArmyData[1].ids > 1 then
            self:initTab()
        end
    end
    self._rightListView:reloadData()
end

function ArrangedBeforeWar:setInputVisible(visible)
    self._panelInput:setVisible(visible)
    for k, v in ipairs(self._tabBtn) do
        v:setVisible(k == 1 or not visible)
    end
end

function ArrangedBeforeWar:initTabSift()
    self._showInput = false
    local num = self._embattleType == uq.config.constant.TYPE_EMBATTLE.DRILL_GROUND_EMBATTLE and 1 or 3
    self._tabBtn = {}
    for i = 1, num do
        local btn = self._nodeRightMiddle:getChildByName("Button_" .. i + 3)
        btn:setVisible(true)
        btn:setTitleText(self._txtSift[i])
        btn:addClickEventListener(handler(i, function(index, sender)
            local img = sender:getChildByName("img")
            local item = sender:getChildByName("item")
            if self._showBtn[i] then
                img:setRotation(0)
            else
                for k, v in ipairs(self._tabBtn) do
                    v:getChildByName("img"):setRotation(0)
                    v:getChildByName("item"):setVisible(false)
                end
                img:setRotation(180)
            end
            item:setVisible(not self._showBtn[i])
            self._showBtn[i] = not self._showBtn[i]
        end))
        local panel = uq.createPanelOnly("embattle.FilterChoiceModule")
        local size = btn:getContentSize()
        panel:setInfo({tab = i, callback = handler(self, self._onBtnSift), type = self._siftType[i]})
        panel:setVisible(false)
        panel:setName("item")
        btn:addChild(panel)
        table.insert(self._tabBtn, btn)
    end

    self._panelInput:setVisible(false)
    local size = self._panelText:getContentSize()
    self._editBoxName = ccui.EditBox:create(cc.size(size.width, size.height), '')
    self._editBoxName:setAnchorPoint(cc.p(0.5, 0.5))
    self._editBoxName:setFontName("font/fzlthjt.ttf")
    self._editBoxName:setFontSize(20)
    self._editBoxName:setFontColor(uq.parseColor("#63686A"))
    self._editBoxName:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._editBoxName:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self._editBoxName:setPosition(cc.p(size.width / 2, size.height / 2))
    self._editBoxName:setPlaceholderFontName("font/fzlthjt")
    self._editBoxName:setPlaceholderFontSize(20)
    self._editBoxName:setMaxLength(20)
    self._editBoxName:setPlaceHolder(StaticData["local_text"]["chat.input.desc"])
    self._editBoxName:setPlaceholderFontColor(cc.c3b(121, 129, 129))
    self._panelText:addChild(self._editBoxName)
end

function ArrangedBeforeWar:_onBtnSift(sify_type, index, name)
    name = name or self._txtSift[index]
    self._tabBtn[index]:setTitleText(name)
    self._siftType[index] = sify_type
    self._showBtn[index] = false
    self._tabBtn[index]:getChildByName("img"):setRotation(0)
    self:filterDownGenrealData()
end

function ArrangedBeforeWar:_onSwitch(event)
    if event.name ~= "ended" then
        return
    end
    local pos_y = self._nodeRightMiddle:getPositionY()
    self._nodeRightMiddle:stopAllActions()
    local size = self._switchBg:getContentSize()
    local saft_delta_x = uq.getAdaptOffX()
    if self._showSwitch then
        self._imgBtnSwitch:setRotation(0)
        self._nodeRightMiddle:runAction(cc.MoveTo:create(0.1, cc.p(display.width - saft_delta_x, pos_y)))
        self:closeEmbattleGeneralTip()
    else
        self._imgBtnSwitch:setRotation(180)
        self._nodeRightMiddle:runAction(cc.MoveTo:create(0.1, cc.p(display.width - size.width + 20 - saft_delta_x, pos_y)))
    end
    self._showSwitch = not self._showSwitch
    self._nodeRightBottom:setVisible(not self._showSwitch)
end

function ArrangedBeforeWar:setLeftListVisible(state)
    if (not self._showAllEmbattleInfo and not state) or (self._showAllEmbattleInfo and state) then
        return
    end
    local pos_y = self._rightListLayer:getPositionY()
    self._rightListLayer:stopAllActions()
    local size = self._rightListLayer:getContentSize()
    if self._showAllEmbattleInfo then
        self._rightListLayer:runAction(cc.MoveTo:create(0.1, cc.p(-size.width, pos_y)))
    else
        self._rightListLayer:runAction(cc.MoveTo:create(0.1, cc.p(0, pos_y)))
    end
    self._showAllEmbattleInfo = not self._showAllEmbattleInfo
    self._nodeLeftTop:setVisible(not self._showAllEmbattleInfo)
end

function ArrangedBeforeWar:initTab()
    local num = #self._curArmyData.ids
    self._panelTab:setVisible(true)
    for i = 1, num do
        local node = self._panelTab:getChildByName("Node_" .. i)
        local check_box = node:getChildByName("CheckBox_1")
        local select_img = node:getChildByName("Image_2")
        local img = node:getChildByName("Image_1")
        check_box:setTouchEnabled(false)
        check_box:setSelected(i == 1)
        select_img:setVisible(i == 1)
        node:setVisible(true)

        img:setTouchEnabled(true)
        img:addClickEventListener(handler(i, function(index)
            if index == self._curArrayIndex then
                return
            end
            for i = 1, #self._curArmyData.ids do
                local node = self._panelTab:getChildByName("Node_" .. i)
                local check_box = node:getChildByName("CheckBox_1")
                local select_img = node:getChildByName("Image_2")
                local img = node:getChildByName("Image_1")
                select_img:setVisible(index == i)
                check_box:setSelected(index == i)
            end
            self._curArrayIndex = index
            self._curFormation = self._curArmyData.ids[self._curArrayIndex] or self._curFormation
            self._rightListView:reloadData()
            self:setFormation(self._curFormation)
        end))
    end
end

function ArrangedBeforeWar:onCreate()
    ArrangedBeforeWar.super.onCreate(self)
    network:addEventListener(Protocol.S_2_C_SET_DEFAULTFORMATION_RES, handler(self, self._saveFormation), '_saveFormation')
    network:addEventListener(Protocol.S_2_C_DRILL_GROUND_FORMATION_SAVE, handler(self, self._saveFormation), '_saveGroundFormation')
    network:addEventListener(Protocol.S_2_C_ATHLETICS_SAVE, handler(self, self._saveBattleFormation), '_saveAthleticBattleFormation')
    network:addEventListener(Protocol.S_2_C_MIRACLE_SET_FORMATION, handler(self, self._saveBattleFormation), '_saveFlyNailFormation')
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_UPDATE_FORMATION, handler(self, self._saveBattleFormation), '_saveBattleFormation')
    network:addEventListener(Protocol.S_2_C_ATHLETICS_VIEW_FORMATION, handler(self, self._onGetEnemyFormation), '_onGetAthleticEnemyFormation' .. tostring(self))
    network:addEventListener(Protocol.S_2_C_CROP_INSTANCE_FORMATION_SAVE, handler(self, self._saveBattleFormation), '_saveCropFormation')
    services:addEventListener(services.EVENT_NAMES.ON_GET_ALL_FORMATION_DATA, handler(self, self.allFormationRet), '_onGetALlFormationRet')
    services:addEventListener(services.EVENT_NAMES.ON_CHANGE_EMBATTLE, handler(self, self.reloadBottom), '_onEmbattleItemChanged')
    services:addEventListener(services.EVENT_NAMES.ON_CLOSE_ARRANGED_BEFORE, handler(self, self._onCloseDialog), '_onCloseDialog')
    services:addEventListener(services.EVENT_NAMES.ON_CHANGE_BATTLE_SOLDIER_ID, handler(self,self._onChangeBattleSoldierId), "_onChangeBattleSoldierIdByWar")
    services:addEventListener(services.EVENT_NAMES.ON_UPDATE_GENERALINFO, handler(self,self.onSoldierTypeChanged), "_onGeneralSoldierChanged")
    services:addEventListener(services.EVENT_NAMES.ON_SET_EMBATTLE_TOUCH_STATE, handler(self, self._onSetTouchState), "_onSetTouchState" .. tostring(self))
end

function ArrangedBeforeWar:_onSetTouchState(msg)
    local state = msg.state or false
    self._onTouch = state
end

function ArrangedBeforeWar:_onChangeBattleSoldierId(evt)
    local index = 1
    for k, v in ipairs(self._allListDown) do
        if v.id == evt.data.general_id then
            index = k
            v.battle_soldier_id = evt.data.battle_soldier_id
            break
        end
    end
    local item = self:getRoleCard(index)
    item:setData(index, self._curPage, self._allListDown[index])
    if self._embattleType == uq.config.constant.TYPE_EMBATTLE.DRILL_GROUND_EMBATTLE then
        item:checkSoldierArray(self._SoldierArray)
    end
    self:updateSoldierTips(index)
end

function ArrangedBeforeWar:updateSoldierTips(index)
    if self._embattleTip then
        local role_data = self._siftListDown[index]
        self._embattleTip:setInfoData(role_data)
    end
end

function ArrangedBeforeWar:onExit()
    network:removeEventListenerByTag('_saveFormation')
    network:removeEventListenerByTag('_saveGroundFormation')
    network:removeEventListenerByTag('_saveBattleFormation')
    network:removeEventListenerByTag('_saveFlyNailFormation')
    network:removeEventListenerByTag('_saveAthleticBattleFormation')
    network:removeEventListenerByTag('_onGetAthleticEnemyFormation' .. tostring(self))
    network:removeEventListenerByTag('_saveCropFormation')
    services:removeEventListenersByTag('_onGetALlFormationRet')
    services:removeEventListenersByTag('_onEmbattleItemChanged')
    services:removeEventListenersByTag('_onChangeBattleSoldierIdByWar')
    services:removeEventListenersByTag('_onGeneralSoldierChanged')
    services:removeEventListenersByTag('_onCloseDialog')
    services:removeEventListenersByTag('_onSetTouchState' .. tostring(self))
    uq.cache.formation:setCurRoleType(self.PAGE.PAGE_WUJIANG)
    ArrangedBeforeWar.super.onExit(self)
end

function ArrangedBeforeWar:_onCloseDialog()
    self:disposeSelf()
end

function ArrangedBeforeWar:onSetState(evt)
    if evt.name ~= "ended" or self._showAllEmbattleInfo then
        return
    end
    self:setLeftListVisible(true)
end

function ArrangedBeforeWar:_saveFormation(msg)
    if self._confirmCallBack then
        self._confirmCallBack()
    end
end

function ArrangedBeforeWar:_saveBattleFormation(msg)
    if self._confirmCallBack then
        self._confirmCallBack()
    end
    if self._embattleType ~= uq.config.constant.TYPE_EMBATTLE.NATIONAL_WAR_EMBATTLE then
        local tab_name = self._curArmyData.array[self._curArrayIndex]
        local formation_data = self._curArmyData[tab_name]
        local data = {
            formation_id = self._curFormation,
            general_loc     = formation_data,
        }
        if self._embattleType == uq.config.constant.TYPE_EMBATTLE.ATHLETIC_EMBATTLE then
            uq.cache.arena:setFormation(data)
        elseif self._embattleType == uq.config.constant.TYPE_EMBATTLE.CROP_SIGN then
            uq.cache.crop:setFormation(data)
        else
            uq.cache.fly_nail:setFormation(data)
        end
    end
end

function ArrangedBeforeWar:refreshPage()
    self:setFormation(self._curFormation)
end

function ArrangedBeforeWar:_onSoldier(event)
    if event.name ~= "ended" then
        return
    end
    local info = StaticData['buildings']['CastleMap'][7]
    if uq.cache.role:isBuildLock(info) then
        local instance_id = math.floor(tonumber(info.objectId) / 100)
        local chapter_id = instance_id - 100
        local npc_id = info.objectId % 100
        uq.fadeInfo(string.format('%s%s-%s', StaticData['local_text']['main.pass.instance.limit'], chapter_id, npc_id))
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.FAIL)
    else
        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.EMBATTLE_SOLDIER_SET_MODULE, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
        if panel then
            panel:setFormationIndex(self._curFormation, self._curArmyData[self._curArmyData.array[self._curArrayIndex]])
        end
    end
end

function ArrangedBeforeWar:initPage()
    self._onTouch = false
    self._itemList = {}
    self._enemyList = {}

    local xml_data = StaticData['formation_loc'].Formationloc
    for i = 1, 9 do
        local center = self:convertPos(self._nodeAtk, xml_data[i].x1 + 70, xml_data[i].y1 - 110)
        local child_node = self._nodeAtk:getChildByName(tostring(i))
        child_node:setPosition(center)
        local item = uq.createPanelOnly('battle.ArrangedItem')
        table.insert(self._itemList, item)
        item:setIndex(i)
        item:setPosition(cc.p(-60, -66))
        child_node:addChild(item)
        item:setIconTouchCallback(handler(self, self.onIconTouchCallback))
    end

    for i = 1, 9 do
        local index = i + 9
        local center = self:convertPos(self._nodeDef, xml_data[index].x1 + 70, xml_data[index].y1 - 110)
        local child_node = self._nodeDef:getChildByName(tostring(i))
        child_node:setPosition(center)
        local item = uq.createPanelOnly("battle.ArrangeEnemyItem")
        local state = self._embattleType ~= uq.config.constant.TYPE_EMBATTLE.NATIONAL_WAR_EMBATTLE
        table.insert(self._enemyList, item)
        item:setData(i, self._enemyData[i])
        child_node:addChild(item)
        item:setPosition(cc.p(-60, -66))
        item:setIconTouchCallback(handler(self, self.onIconTouchCallback))
    end
    if self._rank then
        network:sendPacket(Protocol.C_2_S_ATHLETICS_VIEW_FORMATION, {pos = self._rank})
    end

    local str = nil
    if self._SoldierArray and next(self._SoldierArray) ~= nil then
        for k, v in ipairs(self._SoldierArray) do
            local name = StaticData['types'].Soldier[1].Type[v].name
            if not str then
                str = name
            else
                str = str .. ',' .. name
            end
        end
        self._imgTipsBg:setVisible(true)
        self._txtGroundTip:setHTMLText(string.format(StaticData['local_text']['drill.formation.des1'], str))
    end
end

function ArrangedBeforeWar:convertPos(node, x, y)
    return node:convertToNodeSpace(cc.p(x, CC_DESIGN_RESOLUTION.height - y))
end

function ArrangedBeforeWar:initTableView()
    local view_size = self._rightListLayer:getContentSize()
    self._rightListLayer:setSwallowTouches(true)
    self._rightListView = cc.TableView:create(cc.size(view_size.width, view_size.height))
    self._rightListView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._rightListView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._rightListView:setPosition(cc.p(0, 0))
    self._rightListView:setDelegate()
    self._rightListView:registerScriptHandler(handler(self, self.tableCellTouchedLeft), cc.TABLECELL_TOUCHED)
    self._rightListView:registerScriptHandler(handler(self, self.cellSizeForTableLeft), cc.TABLECELL_SIZE_FOR_INDEX)
    self._rightListView:registerScriptHandler(handler(self, self.tableCellAtIndexLeft), cc.TABLECELL_SIZE_AT_INDEX)
    self._rightListView:registerScriptHandler(handler(self, self.numberOfCellsInTableViewLeft), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

    self._rightListView:reloadData()

    self._rightListLayer:addChild(self._rightListView)

    local size = self._panelBottom:getContentSize()
    self._tableView = cc.TableView:create(cc.size(size.width,size.height))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setAnchorPoint(cc.p(0, 0))
    self._tableView:setDelegate()
    self._panelBottom:addChild(self._tableView)

    self._tableView:registerScriptHandler(handler(self,self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
end

function ArrangedBeforeWar:tableCellTouched()
end

function ArrangedBeforeWar:cellSizeForTable()
    return 520, 170
end

function ArrangedBeforeWar:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx * 4 + 1
    local role_card = nil

    if not cell then
        cell = cc.TableViewCell:new()
        local width, height = self:cellSizeForTable()
        local pos_x = width / 8
        for i = 1, 4 do
            role_card = uq.createPanelOnly("embattle.EmbattleRoleCard")
            local info = self._siftListDown[index]
            role_card:setSelected(false)
            role_card:setName("card" .. i)
            role_card:setCallback(handler(self, self.bottomCardCallBack))
            role_card:setPosition(cc.p(pos_x, height / 2 - 5))
            cell:addChild(role_card)
            table.insert(self._roleCardList, role_card)
            role_card:setVisible(info ~= nil)
            if info then
                local state = self._embattleType == uq.config.constant.TYPE_EMBATTLE.DRILL_GROUND_EMBATTLE
                role_card:setData(index, self._curPage, info, state)
                if state then
                    role_card:checkSoldierArray(self._SoldierArray)
                end
            end
            pos_x = pos_x + width / 4
            index = index + 1
        end
    else
        for i = 1, 4 do
            local info = self._siftListDown[index]
            role_card = cell:getChildByName("card" .. i)
            role_card:setVisible(info ~= nil)
            if info then
                local state = self._embattleType == uq.config.constant.TYPE_EMBATTLE.DRILL_GROUND_EMBATTLE
                role_card:setData(index, self._curPage, info, state)
                if state then
                    role_card:checkSoldierArray(self._SoldierArray)
                end
            end
            index = index + 1
        end
    end
    return cell
end

function ArrangedBeforeWar:numberOfCellsInTableView()
    return math.ceil(#self._siftListDown / 4)
end

function ArrangedBeforeWar:roleCardCallback(role_card_index, pos)
    local role_data = self._siftListDown[role_card_index]
    local new_pos = cc.p(pos.x + 50, pos.y + 280)
    self:setPropertyDescGeneral(role_data, new_pos)
end

function ArrangedBeforeWar:removeUpRoleData(id)
    for k, name in ipairs(self._curArmyData.array) do
        for index, loc in ipairs(self._curArmyData[name]) do
            if id == loc.general_id then
                table.remove(self._curArmyData[name], index)
                self._itemList[loc.index]:downRole()
                return
            end
        end
    end
end

function ArrangedBeforeWar:onSoldierTypeChanged()
    for k, v in ipairs(self._itemList) do
        v:refreshPage()
    end
    -- self:closeEmbattleGeneralTip()
    self:filterDownGenrealData()
end

function ArrangedBeforeWar:upRole(battlePosisionItem, role_data, pos)
    battlePosisionItem:setData(self._curFormation, role_data.id)
    self:setCurArmyData(pos, role_data.id)
    if self._embattleType == uq.config.constant.TYPE_EMBATTLE.INSTANCE_EMBATTLE then
        local data = {
            formation_id      = self._curFormation,
            genaral_battle_id = role_data.id,
            formation_pos     = pos
        }
        network:sendPacket(Protocol.C_2_S_FORMATION_GENARAL_BATTLE, data)
    end
    self:filterDownGenrealData()
    self:setEmbattleInfo(self._curFormation)
end

function ArrangedBeforeWar:setPropertyDescGeneral(general_data, pos)
    if not self._embattleTip then
        self._embattleTip = EmbattleTip:create({info = general_data})
        self._embattleTip:setInfoData(general_data)
        self._nodeTips:addChild(self._embattleTip)
        self._embattleTip:setTipPosition(pos)
    else
        self._embattleTip:setInfoData(general_data)
        self._embattleTip:setTipPosition(pos)
    end
end

function ArrangedBeforeWar:onClose(event)
    if event.name == "ended" then
       uq.ModuleManager:getInstance():dispose(self:name())
    end
end

function ArrangedBeforeWar:tableCellTouchedLeft(view, cell)
    local index = cell:getIdx() + 1

    if uq.cache.formation:getFormationIdByIndex(index) == self._curFormation then
        return
    end

    self._curFormation = uq.cache.formation:getFormationIdByIndex(index)
    local image = StaticData['formation'][self._curFormation].button2

    for i = 1, self:numberOfCellsInTableViewLeft() do
        local cell = self._rightListView:cellAtIndex(i - 1)
        if cell then
            local item = cell:getChildByName("item")
            item:setSelected(i == index)
        end
    end
    self:setFormation(self._curFormation)
end

function ArrangedBeforeWar:checkGeneral(id)
    local data = uq.cache.generals:getGeneralDataByID(id)
    local skill_data = StaticData['skill'][data.skill_id]
    local skill_array = string.split(skill_data.skillType,',')
    if self._siftType[1] ~= nil and data.grade ~= self._siftType[1] then
        return false
    end
    if self._siftType[2] ~= nil then
        local find_state = false
        for k, v in ipairs(skill_array) do
            if tonumber(v) == self._siftType[2] then
                find_state = true
                break
            end
        end
        if not find_state then
            return false
        end
    end
    if self._siftType[3] ~= nil and (not self:checkSoldierArrayById(data.soldierId1, {self._siftType[3]}) and not self:checkSoldierArrayById(data.soldierId2, {self._siftType[3]})) then
        return false
    end
    return true
end

function ArrangedBeforeWar:filterDownGenrealData()
    local all_general_data = uq.cache.generals:getAllGeneralData()
    if not all_general_data then return end

    self._allArrayGeneral = {}
    for index, id in ipairs(self._curArmyData.ids) do
        local name = self._curArmyData.array[index]
        for k, pos_data in ipairs(self._curArmyData[name]) do
            table.insert(self._allArrayGeneral, pos_data.general_id)
        end
    end

    local sift_data_list = all_general_data
    if next(self._SoldierArray) ~= nil then
        sift_data_list = {}
        for k, v in pairs(all_general_data) do
            local data = uq.cache.generals:getGeneralDataByID(v.id)
            v.up_state = self:checkSoldierArrayById(data.battle_soldier_id)
            if v.up_state or self:checkSoldierArrayById(data.soldierId2) or self:checkSoldierArrayById(data.soldierId1) then
                table.insert(sift_data_list, v)
            end
        end
    end

    local data_list = {}
    for k, info in pairs(sift_data_list) do
        local xml_info = uq.cache.generals:getGeneralDataXML(info.temp_id)
        info.quality_type = xml_info.qualityType
        info.state = false
        for _, general_id in ipairs(self._allArrayGeneral) do
            if general_id == info.id then
                info.state = true
                break
            end
        end
        if next(self._SoldierArray) ~= nil and not info.up_state and info.state then
            self:autoDownRole(info.id)
            info.state = false
        end
        info.unlock = true
        if info.up_state == nil then
            info.up_state = true
        end
        table.insert(data_list, info)
    end

    local order = {"state", 'up_state', "quality_type", "advance_lv", "lvl", "grade", "id"}
    uq.cache.generals:sortGenerals(data_list, order)
    self._allListDown = data_list
    self._siftListDown ={}
    for k, v in ipairs(self._allListDown) do
        local state = self:checkGeneral(v.id)
        if state then
            table.insert(self._siftListDown, v)
        end
    end
    self._nodeRightTop:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()
        self._tableView:reloadData()
    end)))
end

function ArrangedBeforeWar:autoDownRole(id)
    local item, index = self:getEmbattleItem({id = id})
    self:setCurArmyData(index)
    item:downRole(self._embattleType)
    self:setEmbattleInfo(self._curFormation)
end

function ArrangedBeforeWar:checkSoldierArrayById(id, array)
    array = array or self._SoldierArray
    local soldier_type = StaticData['soldier'][id].type
    for k, v in ipairs(array) do
        if v == soldier_type then
            return true
        end
    end
    return false
end

function ArrangedBeforeWar:reloadBottom()
    self._tableView:reloadData()
end

function ArrangedBeforeWar:setFormation(index)
    self._curArmyData = self:getFormationDataById(index)
    local formation = {}
    if self._curArmyData then
        for k, v in ipairs(self._curArmyData[self._curArmyData.array[self._curArrayIndex]]) do
            formation[v.index] = v.general_id
        end
    end
    for k, item in ipairs(self._itemList) do
        item:setData(index, formation[k], self._injureState)
    end
    self:filterDownGenrealData()
    self:setEmbattleInfo(index)
    self:refreshFood()
end

function ArrangedBeforeWar:setSelectCurFormation(cell, index)
    local cell_item = cell:getChildByTag(1000)
    local formation_id = uq.cache.formation:getFormationIdByIndex(index)
    if cell_item then
        cell_item:setSelected(true)
    end
end

function ArrangedBeforeWar:setEmbattleInfo(formation_index)
    local data = StaticData['formation'][formation_index]
    local tech_index = data['techId']
    self._txtEmbattleInfoName:setString(StaticData['tech'][tech_index].name)

    local value = uq.cache.generals:getNumByEffectType(StaticData['tech'][tech_index].effectType, uq.cache.formation:getFormationAdd(self._curFormation))
    local desc = uq.cache.formation:getFormationDesc(self._curFormation) .. value
    self._txtForamtionDes:setString(desc)

    self._power = 0
    for k, general_id in ipairs(self._allArrayGeneral) do
        local general_data = uq.cache.generals:getGeneralDataByID(general_id)
        self._power = self._power + general_data.power
    end
    self._txtPower:setString(self._power)
    self._imgIcon:loadTexture("img/embattle/" .. data.button1)
    uq.log('ArrangedBeforeWar:setEmbattleInfo')
end

function ArrangedBeforeWar:cellSizeForTableLeft(view, idx)
    return 250, 80
end

function ArrangedBeforeWar:numberOfCellsInTableViewLeft(view)
    return uq.cache.formation:getFormationNum()
end

function ArrangedBeforeWar:tableCellAtIndexLeft(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell();

    local cell_item = nil
    local formation_id = uq.cache.formation:getFormationIdByIndex(index)
    local formation_data = StaticData['formation'][formation_id]
    if not cell then
        cell = cc.TableViewCell:new();
        cell_item = uq.createPanelOnly("embattle.EmbattleListItem")
        local width, height = self:cellSizeForTableLeft()
        cell_item:setData(formation_id)
        cell_item:getChildByName("Node"):getChildByName("img_bg"):setSwallowTouches(true)
        cell_item:setName("item")
        cell_item:setPosition(cc.p(width / 2, height / 2))
        cell_item:setSelected(formation_id == self._curFormation)
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByName("item")
        cell_item:setData(formation_id)
    end
    local state = formation_id == self._curFormation
    cell_item:setSelected(state)
    if state then
        self._curFormationIndex = index
    end
    return cell
end

function ArrangedBeforeWar:getRoleCard(index)
    for k, v in ipairs(self._roleCardList) do
        if v:getIndex() == index then
            return self._roleCardList[k]
        end
    end
    return nil
end

function ArrangedBeforeWar:bottomCardCallBack(cell_index)
    local role_card = self:getRoleCard(cell_index)
    if not role_card then
        return
    end
    local cell_parent = role_card:getParent()
    local pos = cell_parent:convertToWorldSpace(cc.p(role_card:getPosition()))
    role_card:setSelected(true)
    pos.x = CC_DESIGN_RESOLUTION.width / 2 - 50
    pos.y = pos.y - 200
    self:roleCardCallback(cell_index, pos)
end

function ArrangedBeforeWar:getFormationDataById(id)
    for _, data in ipairs(self._allArmyData) do
        for k, v in ipairs(data.ids) do
            if v == id and k == self._curArrayIndex then
                return data
            end
        end
    end
    local data = {
        ids = {},
        array = {},
    }
    self._allArmyData[1].ids[self._curArrayIndex] = id
    self._allArmyData[1][self._allArmyData[1].array[self._curArrayIndex]] = {}
    data = self._allArmyData[1]
    return data
end

function ArrangedBeforeWar:dispose()
    ArrangedBeforeWar.super.dispose(self)
end

function ArrangedBeforeWar:allFormationRet(msg)
    if not self._curFormation then
        self._curFormation = msg.data.default_id
    end
    self:formatData(msg.data)
    self._rightListView:reloadData()
    self:setFormation(self._curFormation)
end

function ArrangedBeforeWar:formatData(data)
    self._allArmyData = data.formations
    for k, v in ipairs(self._allArmyData) do
        self._allArmyData[k].ids = {v.formation_id}
        self._allArmyData[k].array = {"general_loc"}
    end
end

function ArrangedBeforeWar:playEmbattleAttack()
    for k, v in ipairs(self._itemList) do
        v:playAttack()
    end
end

function ArrangedBeforeWar:onNationConfirm(event)
    if event.name ~= "ended" then
        return
    end
    local army_data = self._allArmyData[1]
    for index = 1, 2 do
        if self:checkArmyStatus(index) then
            local pos_info = {}
            self:updateArmyData(pos_info, army_data[army_data.array[index]])
            local formation_id = army_data.ids[index]
            if #pos_info == 0 then
                formation_id = 0
            end
            local formation_info = {
                army_id = index,
                formation_id = formation_id,
                count = #pos_info,
                generals = pos_info
            }
            network:sendPacket(Protocol.C_2_S_NATION_BATTLE_UPDATE_FORMATION, formation_info)
        end
    end
    uq.fadeInfo(StaticData["local_text"]["world.formation.save"])
end

function ArrangedBeforeWar:checkArmyStatus(index)
    local move_cd = uq.cache.world_war:getCityMovingCd(uq.cache.role.id, index)
    if move_cd > 0 then
        uq.fadeInfo(StaticData["local_text"]["world.war.formation.des" .. index] .. StaticData["local_text"]["world.war.formation.des14"])
        return false
    elseif uq.cache.world_war:checkArmyIsInBattleCity(index) then --所在的城池已经开始打仗不能设置
        uq.fadeInfo(StaticData["local_text"]["world.war.formation.des" .. index] .. StaticData["local_text"]["world.war.formation.des16"])
        return false
    elseif uq.cache.world_war:checkArmyIsInDeclareCity(index) then --所在的城池已经开始宣战不能设置
        uq.fadeInfo(StaticData["local_text"]["world.war.formation.des" .. index] .. StaticData["local_text"]["world.war.formation.des15"])
        return false
    end
    return true
end

function ArrangedBeforeWar:onConfirm(event)
    if event.name ~= "ended" then
        return
    end
    if self._clickTime and self._clickTime + 2 > os.time() then
        return
    end
    local data = self:getFormationDataById(self._curFormation)
    local general_num = 0
    for k, v in ipairs(data.array) do
        general_num = general_num + #data[v]
    end
    if general_num <= 0 then
        uq.fadeInfo(StaticData['local_text']['embattle.without.general'])
        return
    end

    if not uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.FOOD, self._foodNeed) then
        uq.fadeInfo(StaticData['local_text']['label.draft.not.food'])
        return
    end

    local function confirm()
        self._clickTime = os.time()
        self:confirmAttack()
    end

    if not self._injureState then
        confirm()
        return
    end
    for j, v in pairs(data.array) do
        for k, item in pairs(data[v]) do
            local general_data = uq.cache.generals:getGeneralDataByID(item.general_id)
            if general_data.current_soldiers < general_data.max_soldiers then
                local str = StaticData['local_text']['label.attack.tip']
                local data = {
                    content = str,
                    confirm_callback = confirm,
                }
                uq.addConfirmBox(data, uq.config.constant.CONFIRM_TYPE.CONFIRM_DRAFT)
                return
            end
        end
    end
    confirm()
end

function ArrangedBeforeWar:confirmAttack()
    local data = self:getFormationDataById(self._curFormation)
    if self._embattleType == uq.config.constant.TYPE_EMBATTLE.INSTANCE_EMBATTLE then
        network:sendPacket(Protocol.C_2_S_SET_DEFAULTFORMATION, {formation_id = self._curFormation})
    elseif self._embattleType == uq.config.constant.TYPE_EMBATTLE.DRILL_GROUND_EMBATTLE then
        local tab_name = self._curArmyData.array[self._curArrayIndex]
        local formation_data = self._curArmyData[tab_name]
        local data = {
            formation_id             = self._curFormation,
            drill_ground_id          = uq.cache.drill:getDrillIdOperation(),
            count                    = #formation_data,
            formations               = formation_data,
        }
        uq.cache.drill:saveFormation(data)
        network:sendPacket(Protocol.C_2_S_DRILL_GROUND_FORMATION_SAVE, data)
    else
        local tab_name = self._curArmyData.array[self._curArrayIndex]
        local formation_data = self._curArmyData[tab_name]
        local data = {
            formation_id = self._curFormation,
            count        = #formation_data,
            generals     = formation_data,
        }
        if self._embattleType == uq.config.constant.TYPE_EMBATTLE.ATHLETIC_EMBATTLE then
            network:sendPacket(Protocol.C_2_S_ATHLETICS_SAVE, data)
        elseif self._embattleType == uq.config.constant.TYPE_EMBATTLE.CROP_SIGN then
            network:sendPacket(Protocol.C_2_S_CROP_INSTANCE_FORMATION_SAVE, data)
        else
            network:sendPacket(Protocol.C_2_S_MIRACLE_SET_FORMATION, data)
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ENTER_WAR})
end

function ArrangedBeforeWar:updateArmyData(info, data)
    if #data == 0 then
        return
    end
    for k, v in ipairs(data) do
        local formation_info = {
            pos = v.index,
            general_id = v.general_id
        }
        table.insert(info, formation_info)
    end
end

function ArrangedBeforeWar:onIconTouchCallback(role_data, index, event, pos)
    if event.name == "began" then
        self:setPropertyDescGeneral(role_data[self._curPage], pos)
    elseif event.name == "moved" then

        if not self._onMoved then
            return
        end
        self._onTouch = false
        self:closeEmbattleGeneralTip()
    else
        self._onTouch = false
        -- self:closeEmbattleGeneralTip()
    end
end

function ArrangedBeforeWar:_onTouchBegin(touches, event)
    self._onTouch = true
    self._onMoved = false
    self._touchPos = touches:getLocation()
    self._nodeMove:setVisible(false)
    return true
end

function ArrangedBeforeWar:_onTouchMove(touches, event)
    self._tableView:setTouchEnabled(false)
    self._nodeMove:setVisible(true)
    self._onMoved = true
    self._onTouch = false
    local location = touches:getLocation()
    local location_con = self:convertToNodeSpace(location)
    self._nodeMove:setPosition(cc.p(location_con.x, location_con.y))
    self:setMoveCardState(self:bottomContainClickPos(location))
end

function ArrangedBeforeWar:_onTouchEnd(touches, event)
    if not self._onMoved then
        return
    end
    if not self._tableView:isTouchEnabled() then
        self._tableView:setTouchEnabled(true)
        local min_offset = self._tableView:minContainerOffset()
        local offset = self._tableView:getContentOffset()
        local _, height = self:cellSizeForTable()
        if offset.y - min_offset.y < height then
            self._tableView:setContentOffset(min_offset, true)
        elseif offset.y > 0 then
            self._tableView:setContentOffset(cc.p(0, 0), true)
        end
    end
    self._onTouch = false
    self._nodeMove:setVisible(false)
    if self._onMoved and self._embattleType == uq.config.constant.TYPE_EMBATTLE.DRILL_GROUND_EMBATTLE then
        if not self._moveCard:checkSoldierArray(self._SoldierArray) then
            self._onMoved = false
            uq.fadeInfo(StaticData['local_text']['embattle.soldier.des'])
            return
        end
    end
    self._onMoved = false
    local location = touches:getLocation()
    local location_con = self._nodeAtk:convertToNodeSpace(location)
    local node_pos = cc.p(location_con.x, location_con.y + 94)
    local intersect = false
    for i = 1, 9 do
        local embattle_item = self._itemList[i]
        local item_node = self._nodeAtk:getChildByName(i)
        local x , y = item_node:getPosition()
        local width, height = 140, 110
        local rect = cc.rect(x - width / 2, y - height / 2, width, height)

        intersect = cc.rectContainsPoint(rect, node_pos) and embattle_item:formationOpened()
        local node_card = self._moveCard
        local role_data = node_card:getRoleData()
        if intersect then
            local old_data = embattle_item:getRoleData()
            if node_card:getFromID() > 0 then
                if node_card:getFromID() == embattle_item._index then
                    return
                end
                if role_data.state then
                    self:removeUpRoleData(role_data.id)
                end
                if old_data then
                    self:switchRole(embattle_item, role_data, old_data)
                else
                    self:upRole(embattle_item, role_data, embattle_item._index)
                end
            else
                if role_data.state then
                    self:removeUpRoleData(role_data.id)
                end

                if not old_data then
                    self:upRole(embattle_item, role_data, embattle_item._index)
                else
                    self:switchRole(embattle_item, role_data, old_data)
                end
            end
            break
        end
    end

    if not intersect then
        if self:bottomContainClickPos(location) and self._moveCard:getFromID() > 0 then
            local embattle_item = self._itemList[self._moveCard:getFromID()]
            self:downRole(embattle_item)
        end
    end
end

function ArrangedBeforeWar:setMoveCardState(flag)
    self._moveItem:setVisible(not flag)
    self._moveCard:setVisible(flag)
end

function ArrangedBeforeWar:bottomContainClickPos(pos)
    local x, y = self._panelBottom:getPosition()
    local position = self._nodeRightMiddle:convertToWorldSpace(cc.p(x, y))
    local width, height = 520, 640
    local rect = cc.rect(position.x, position.y, width, height)
    return cc.rectContainsPoint(rect, pos)
end

function ArrangedBeforeWar:setMoveNodeData(role_data, roleType, from_id)
    from_id = from_id and from_id or 0
    self._moveItem:setIndex(from_id)
    self._moveItem:setData(self._curFormation, role_data.id, self._injureState)
    self._moveItem:setVisible(false)
    self._moveCard:setVisible(false)
    self._moveCard:setRoleType(roleType)
    self._moveCard:setRoleData(role_data)
    self._moveCard:setFromID(from_id)
end

function ArrangedBeforeWar:switchRole(embattle_item, role_data, old_data)
    embattle_item:switch(role_data, self._embattleType)
    self:setCurArmyData(embattle_item:getIndex(), role_data.id)
    local old_item = self._itemList[self._moveCard:getFromID()]
    if old_item then
        old_item:switch(old_data, self._embattleType)
        self:setCurArmyData(old_item:getIndex(), old_data.id)
    end
    self:filterDownGenrealData()
    self:setEmbattleInfo(self._curFormation)
end

function ArrangedBeforeWar:downRole(embattle_item)
    self:setCurArmyData(embattle_item:getIndex())
    embattle_item:downRole(self._embattleType)
    self:filterDownGenrealData()
    self:setEmbattleInfo(self._curFormation)
end

function ArrangedBeforeWar:setCurArmyData(pos, id)
    local tab_name = self._curArmyData.array[self._curArrayIndex]
    local data = nil
    self._find = false
    for k, v in ipairs(self._curArmyData[tab_name]) do
        if v.index == pos then
            self._find = true
            if id then
                self._curArmyData[tab_name][k] = {index = pos, general_id = id}
                break
            else
                table.remove(self._curArmyData[tab_name], k)
                break
            end
        end
    end
    if not self._find then
        local data = {index = pos, general_id = id}
        table.insert(self._curArmyData[tab_name], data)
    end
end

function ArrangedBeforeWar:closeEmbattleGeneralTip()
    if self._embattleTip and not self._onTouch then
        self._embattleTip:removeFromParent()
        self._embattleTip = nil
    end
end

function ArrangedBeforeWar:getEmbattleItem(role_data)
    for k, item in ipairs(self._itemList) do
        if item:getRoleData() and item:getRoleData().id == role_data.id then
            return item, k
        end
    end
    return nil, 0
end

function ArrangedBeforeWar:setCallback(callback)
    self._callback = callback
end

function ArrangedBeforeWar:refreshFood()
    if self._npcData and self._npcData.battleCoef then
        local food = 0
        local data = self:getFormationDataById(self._curFormation)
        for j, v in pairs(data.array) do
            for k, item in pairs(data[v]) do
                local general_data = uq.cache.generals:getGeneralDataByID(item.general_id)
                food = food + general_data.current_soldiers *  self._npcData.battleCoef
            end
        end
        if uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.FOOD, math.ceil(food)) then
            self._txtFood:setTextColor(uq.parseColor('#FFFFFF'))
        else
            self._txtFood:setTextColor(uq.parseColor('#FF0000'))
        end
        self._txtFood:setString(uq.formatResource(math.ceil(food)))
        self._foodNeed = math.ceil(food)
    end
end

return ArrangedBeforeWar