local EmbattleView = class("EmbattleView", require('app.modules.common.BaseViewWithHead'))
local EmbattleTip = require("app.modules.embattle.EmbattleGeneralTip")

EmbattleView.RESOURCE_FILENAME = "embattle/EmbattleLayer.csb"
EmbattleView.RESOURCE_BINDING = {
    ["Panel_1"]         = {["varname"] = "_panel1"},
    ["Node_2"]          = {["varname"] = "_itemNode"},
    ["Panel_25"]        = {["varname"] = "_leftListLayer"},
    ["Panel_30"]        = {["varname"] = "_panelBottom"},
    ["wujiang"]         = {["varname"] = "_btnWujiang",["events"] = {{["event"] = "touch",["method"] = "onWuJiang"}}},
    ["zhiji"]           = {["varname"] = "_btnZhiji",["events"] = {{["event"] = "touch",["method"] = "onZhiJi"}}},
    ["Button_soldier1"] = {["varname"] = "_btnSoldier",["events"] = {{["event"] = "touch",["method"] = "_onSoldier"}}},
    ["Button_soldier2"] = {["varname"] = "_btnSoldier",["events"] = {{["event"] = "touch",["method"] = "_onSoldier"}}},
    ["wujiangtxt"]      = {["varname"] = "_txtWujiang"},
    ["zhijitxt"]        = {["varname"] = "_txtZhiji"},
    ["Node_10"]         = {["varname"] = "_nodeZhengfa"},
    ["zhengfapos"]      = {["varname"] = "_nodeZhengfapos"},
    ["Button_5"]        = {["varname"] = "_btnConfirm",["events"] = {{["event"] = "touch",["method"] = "onConfirm"}}},
    ["Node_1"]          = {["varname"] = "_nodeMove"},
    ["bottom"]          = {["varname"] = "_nodeBottom"},
    ["Panel_14"]        = {["varname"] = "_panelEmbattleInfo"},
    ["txt_info_name"]   = {["varname"] = "_txtEmbattleInfoName"},
}

EmbattleView.PAGE = {
    PAGE_WUJIANG = 1,
    PAGE_ZHIJI = 2,
}

function EmbattleView:ctor(name, params)
    EmbattleView.super.ctor(self, name, params)
    self._nodeItemArray = {}
end

function EmbattleView:init()
    self._curPage = self.PAGE.PAGE_WUJIANG
    self._curFormation = 1
    self._openFromOther = false

    self:addShowCoinGroup({uq.config.constant.COST_RES_TYPE.GESTE, uq.config.constant.COST_RES_TYPE.MONEY, uq.config.constant.COST_RES_TYPE.GOLDEN})
    self:setTitle(uq.config.constant.MODULE_ID.EMABTTLE)

    self:centerView()
    self:parseView(self._view)
    self._panel1:setSwallowTouches(true)
    for i = 1, 9 do
        local item = self._itemNode:getChildByName("Panel_item_" .. i)
        table.insert(self._nodeItemArray, item)
    end
    self:initTableView()
    self:adapter()
    self:refreshBtns()
    self:initPage()

    self._moveCard = uq.createPanelOnly("embattle.EmbattleRoleCard")
    self._moveCard:setScale(0.6)
    self._moveCard:setOpacity(150)

    self._moveItem = uq.createPanelOnly("embattle.EmbattleItem")
    self._moveItem:setOpacity(150)
    self._nodeMove:addChild(self._moveCard)
    self._nodeMove:addChild(self._moveItem)
    self._nodeMove:setVisible(false)

    network:sendPacket(Protocol.C_2_S_ALLGENERAL_INFO, {})
    network:sendPacket(Protocol.C_2_S_FORMATION_INFO)
end

function EmbattleView:onCreate()
    EmbattleView.super.onCreate(self)
    services:addEventListener(services.EVENT_NAMES.ON_FORMATION_CONFIRM, handler(self, self._saveFormation), '_saveFormation')
    services:addEventListener(services.EVENT_NAMES.ON_CHANGE_EMBATTLE, handler(self, self.reloadBottom), '_onEmbattleItemChanged' .. tostring(self))
end

function EmbattleView:onExit()
    services:removeEventListenersByTag('_saveFormation')
    services:removeEventListenersByTag('_onEmbattleItemChanged' .. tostring(self))
    uq.cache.formation:setCurRoleType(self.PAGE.PAGE_WUJIANG)
    EmbattleView.super.onExit(self)
end

function EmbattleView:_saveFormation(msg)
    if msg.data.ret == 0 then
        uq.fadeInfo('阵型保存成功')
    end
    self:allFormationRet(msg.data)
    self:playEmbattleAttack()
end

function EmbattleView:refreshPage()
    self:setFormation(self._curFormation)
end

function EmbattleView:setOpenFromOther(flag)
    self._openFromOther = flag

    for k, item in pairs(self._itemList) do
        item:setOpenFromOther(flag)
    end
end

function EmbattleView:touchDownAction(event_name, sender)
    uq.log('touchDownAction log', event_name, sender)
end

function EmbattleView:onWuJiang(event)
    if event.name == "ended" then
        self._curPage = self.PAGE.PAGE_WUJIANG
        self:refreshBtns()
        uq.cache.formation:setCurRoleType(self._curPage)
        uq.cache.formation:reFreshPage()
        self._tbBottom:reLoad(self._curPage)
        for k,v in pairs(self._itemList) do
            v:setBosomHeadState(false)
            v:setCurSelectData(self._curPage)
        end
    end
end

function EmbattleView:onZhiJi(event)
    if event.name == "ended" then
        self._curPage = self.PAGE.PAGE_ZHIJI
        self:refreshBtns()
        uq.cache.formation:setCurRoleType(self._curPage)
        uq.cache.formation:reFreshPage()
        self._tbBottom:reLoad(self._curPage)
        for k, v in pairs(self._itemList) do
            v:setBosomHeadState(true)
            v:setCurSelectData(self._curPage)
        end
    end
end

function EmbattleView:_onSoldier(event)
    if event.name ~= "ended" then
        return
    end
    if uq.cache.role:level() < StaticData['game_config']["new_player_lvl"] then
        uq.fadeInfo(string.format(StaticData["local_text"]["soldier.change.num.condition"], StaticData['game_config']["new_player_lvl"]))
    else
        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.EMBATTLE_SOLDIER_SET_MODULE, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
        if panel then
            panel:setFormationIndex(self._curFormation)
        end
    end
end

function EmbattleView:refreshBtns()
    if self._curPage == self.PAGE.PAGE_WUJIANG then
        self._btnWujiang:setEnabled(false)
        self._btnZhiji:setEnabled(true)
        self._txtZhiji:setTextColor(cc.c3b(255,255,255))
        self._txtWujiang:setTextColor(cc.c3b(48,50,51))
    else
        self._btnWujiang:setEnabled(true)
        self._btnZhiji:setEnabled(false)
        self._txtZhiji:setTextColor(cc.c3b(48,50,51))
        self._txtWujiang:setTextColor(cc.c3b(255,255,255))
    end
end

function EmbattleView:initPage()
    self._onTouch = false
    self._itemList = {}
    for i = 1, 9 do
        local item = uq.createPanelOnly("embattle.EmbattleItem")
        table.insert(self._itemList, item)
        self._nodeItemArray[i]:addChild(item)
        item:setPosition(cc.p(self._nodeItemArray[i]:getContentSize().width * 0.5, self._nodeItemArray[i]:getContentSize().height * 0.5))
        item:setIndex(i)
        item:setIconTouchCallback(handler(self, self.onIconTouchCallback))
    end

    self._itemPosPage = uq.createPanelOnly("embattle.EmbattlePos")
    self._nodeZhengfapos:addChild(self._itemPosPage)
end

function EmbattleView:initTableView()
    local view_size = self._leftListLayer:getContentSize()
    self._leftListView = cc.TableView:create(cc.size(view_size.width, view_size.height))
    self._leftListView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._leftListView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._leftListView:setPosition(cc.p(0, 0))
    self._leftListView:setDelegate()
    self._leftListView:registerScriptHandler(handler(self, self.tableCellTouchedLeft), cc.TABLECELL_TOUCHED)
    self._leftListView:registerScriptHandler(handler(self, self.cellSizeForTableLeft), cc.TABLECELL_SIZE_FOR_INDEX)
    self._leftListView:registerScriptHandler(handler(self, self.tableCellAtIndexLeft), cc.TABLECELL_SIZE_AT_INDEX)
    self._leftListView:registerScriptHandler(handler(self, self.numberOfCellsInTableViewLeft), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

    self._leftListView:reloadData()

    self._leftListLayer:addChild(self._leftListView)

    self._tbBottom = uq.createPanelOnly("embattle.EmbattleBottom")
    self._tbBottom:setCallback(handler(self, self.roleCardCallback))
    self._panelBottom:addChild(self._tbBottom)
end

--data武将信息索引
function EmbattleView:roleCardCallback(role_card_index, pos)
    local role_data = uq.cache.formation:getRoleDataNotInFormation(role_card_index, self._curPage)
    local card_pos = self._panel1:convertToNodeSpace(pos)
    local new_pos = cc.p(650, card_pos.y + 100)
    self:setPropertyDescRole(role_data, new_pos)
end

function EmbattleView:upRoleToRemoveBosomDt(role_data)
    for k, item in pairs(self._itemList) do
        if item:getRoleData(self._curPage) and item:getRoleData(self._curPage).id == role_data.id then
            item:setSoilderData(nil, self._curPage)
            break
        end
    end
end

--武将上阵
function EmbattleView:upRole(battlePosisionItem, role_data, pos)
    --上阵协议待修改
    if self._curPage == uq.cache.formation.ROLE.ROLE_GENERAL then
        battlePosisionItem:setSoilderData(role_data, self._curPage)
        local data = {
            formation_id      = self._curFormation,
            genaral_battle_id = role_data.id,
            formation_pos     = pos
        }
        if not self._openFromOther then
            network:sendPacket(Protocol.C_2_S_FORMATION_GENARAL_BATTLE, data)
        end
    else
        self:upRoleToRemoveBosomDt(role_data)
        battlePosisionItem:setSoilderData(role_data, self._curPage)
        self:sendBosomFormationData()
    end
    uq.cache.formation:removeRoleDown(role_data)
end

function EmbattleView:setPropertyDescRole(role_data, pos)
    if self._curPage == uq.cache.formation.ROLE.ROLE_GENERAL then
        self:setPropertyDescGeneral(role_data, pos)
    else
        self:setPropertyDescBosom(role_data)
    end
end

function EmbattleView:setPropertyDescGeneral(general_data, pos)
    if not self._embattleTip then
        self._embattleTip = EmbattleTip:create({info = general_data})
        self._embattleTip:setInfoData(general_data)
        self._panel1:addChild(self._embattleTip)
        self._embattleTip:setPosition(pos)
    else
        self._embattleTip:setInfoData(general_data)
        self._embattleTip:setPosition(pos)
    end
end

function EmbattleView:setPropertyDescBosom(bosom_data)

end

function EmbattleView:adapter()

end

function EmbattleView:onClose(event)
    if event.name == "ended" then
       uq.ModuleManager:getInstance():dispose(self:name())
    end
end

function EmbattleView:tableCellTouchedLeft(view, cell)
    local index = cell:getIdx() + 1

    if uq.cache.formation:getFormationIdByIndex(index) == self._curFormation then
        return
    end

    self._curFormation = uq.cache.formation:getFormationIdByIndex(index)
    for i = 1, self:numberOfCellsInTableViewLeft() do
        local cell = self._leftListView:cellAtIndex(i - 1)
        if cell then
            local cell_item = cell:getChildByTag(1000)
            if cell_item then
                local width,height = self:cellSizeForTableLeft()
                cell_item:setPositionX(width / 2 - 15)
                cell_item:setSelected(false)
            end
        end
    end
    self:setSelectCurFormation(cell, index)
    self:setFormation(uq.cache.formation:getFormationIdByIndex(index))
end

--获取未上阵的武将列表
function EmbattleView:filterDownData()
    if self._curPage == uq.cache.formation.ROLE.ROLE_GENERAL then
        self:filterDownGenrealData()
    else
        self:filterDownBosomData()
    end
end

function EmbattleView:filterDownGenrealData()
    local allGeneralData = uq.cache.generals:getAllGeneralData()
    if not allGeneralData then return end

    local formationData = uq.cache.formation:getFormationData(self._curFormation)
    local dataList = {}
    if formationData then
        for k, info in pairs(allGeneralData) do
            table.insert(dataList, info)
        end
    end
    uq.cache.formation:setAllListDown(dataList, self._curPage)
end

function EmbattleView:filterDownBosomData()
    local allBosomData = uq.cache.role.bosom:getAllBosomsInfo()
    if not allBosomData then return end

    local formationData = uq.cache.formation:getFormationData(self._curFormation)
    local dataList = {}
    if formationData then
        for k, info in pairs(allBosomData) do
            local find = false
            for _,item in ipairs(formationData.general_loc) do
                if item.bosom_id == info.id then
                    find = true
                    break
                end
            end
            if not find then
                table.insert(dataList, info)
            end
        end

        table.sort(dataList, function(a, b)
            if a.info.qualityType ~= b.info.qualityType then
                return a.info.qualityType > b.info.qualityType
            end
            return a.lvl > b.lvl
        end)
    end
    uq.cache.formation:setAllListDown(dataList, self._curPage)
end

function EmbattleView:reloadBottom()
    self._tbBottom:reLoad(self._curPage)
end

function EmbattleView:setFormation(index)
    for _, item in ipairs(self._itemList) do
        item:setData(index)
    end
    self._itemPosPage:setData(index)

    self:filterDownData()
    self:reloadBottom()
end

function EmbattleView:setSelectCurFormation(cell, index)
    local cell_item = cell:getChildByTag(1000)
    local formation_id = uq.cache.formation:getFormationIdByIndex(index)
    if cell_item then
        cell_item:setSelected(true)
    end
end

function EmbattleView:setEmbattleInfo(formIndex)
    local data = StaticData['formation'][formIndex]
    local techIndex = data['techId']
    self._txtEmbattleInfoName:setString(StaticData['tech'][techIndex].name)

    local desc = uq.cache.formation:getFormationDesc(self._curFormation) .. uq.cache.formation:getFormationAdd(self._curFormation) * 100
    self._panelEmbattleInfo:getChildByName("txt_desc"):setString(desc .. '%')
end

function EmbattleView:cellSizeForTableLeft(view, idx)
    return 288, 80
end

function EmbattleView:numberOfCellsInTableViewLeft(view)
    return uq.cache.formation:getFormationNum()
end

function EmbattleView:tableCellAtIndexLeft(view, idx)
    local index = idx + 1;
    local cell = view:dequeueCell();

    local cell_item = nil;
    if nil == cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("embattle.EmbattleListItem")
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end

    local width,height = self:cellSizeForTableLeft()
    cell_item:setPosition(cc.p(width / 2 - 15, height / 2))
    cell_item:setTag(1000)
    cell_item:setData(uq.cache.formation:getFormationIdByIndex(index))
    cell_item:setCallback(handler(self, self.setEmbattleInfo))
    cell_item:setSelected(false)
    if uq.cache.formation:getFormationIdByIndex(index) == self._curFormation then
        self:setSelectCurFormation(cell, index)
        cell_item:setCurUsedFormation(true)
        cell_item:setSelected(true)
        cell_item:setPositionX(width / 2 - 15)
    end

    return cell

end

function EmbattleView:dispose()
    --services:removeEventListenersByTag("LoginListeners")
    EmbattleView.super.dispose(self)
end

function EmbattleView:allFormationRet(msg)
    self._curFormation = msg.default_id
    self._leftListView:reloadData()
    self:setFormation(self._curFormation)
end

function EmbattleView:playEmbattleAttack()
    for k, v in ipairs(self._itemList) do
        v:playAttack()
    end
end

--确认替换
function EmbattleView:onConfirm(event)
    if event.name == "ended" then
        if not self._openFromOther then
            local data = uq.cache.formation:getFormationData(self._curFormation)
            if data and data.general_nums <= 0 then
                uq.fadeInfo(StaticData['local_text']['embattle.without.general'])
            else
                network:sendPacket(Protocol.C_2_S_SET_DEFAULTFORMATION, {formation_id = self._curFormation})
            end
        else
            local general_data = {}
            for k, item in pairs(self._itemList) do
                if item:getRoleData(self._curPage) then
                    table.insert(general_data, {pos = k, general_id = item:getRoleData(self._curPage).id})
                end
            end
            local data = {
                formation_id = self._curFormation,
                count = #general_data,
                generals = general_data
            }
            network:sendPacket(Protocol.C_2_S_ATHLETICS_SAVE, data)
        end
    end
end

function EmbattleView:onIconTouchCallback(role_data, index, event)
    if uq.cache.formation.ROLE.ROLE_GENERAL == self._curPage then
        if event.name == "began" then
            local node_pos_x, node_pos_y = self._itemList[index]:getPosition()
            local icon_pos = self._nodeZhengfapos:convertToWorldSpace(cc.p(node_pos_x, node_pos_y))
            local pos = cc.p(icon_pos.x - 200, icon_pos.y + 400)
            self:setPropertyDescGeneral(role_data[self._curPage], pos)
        elseif event.name == "moved" then
            if not self._onMoved then
                return
            end
            self._onTouch = false
            self:closeEmbattleGeneralTip()
        else
            self._onTouch = false
            self:closeEmbattleGeneralTip()
        end
    else
        self:setPropertyDescBosom(role_data[self._curPage])
    end
end

function EmbattleView:onTouchMove(data)
    uq.log('onTouchMove', data)
end

function EmbattleView:_onTouchBegin(touches, event)
    self._onTouch = true
    self._onMoved = false
    self._touchPos = touches:getLocation()
    self._nodeMove:setVisible(false)
    return true
end

function EmbattleView:_onTouchMove(touches, event)
    local moved_pos = touches:getLocation()
    local delta_x = math.abs(moved_pos.x - self._touchPos.x)
    local delta_y = math.abs(moved_pos.y - self._touchPos.y)
    local delta = delta_x > delta_y and delta_x or delta_y
    if not self._onMoved and delta < 20 then
        return
    end
    self._onMoved = true
    self._nodeMove:setVisible(true)
    local location = touches:getLocation()
    local locationCon = self:convertToNodeSpace(location)
    self._nodeMove:setPosition(cc.p(locationCon.x + display.width / 2, locationCon.y + display.height / 2))
    self:setMoveCardState(self:bottomContainClickPos(cc.p(moved_pos.x, moved_pos.y)))
end

function EmbattleView:_onTouchEnd(touches, event)
    self._onTouch = false
    self._onMoved = false
    self._nodeMove:setVisible(false)

    --检测是否和武将阵型位置相交
    local location = touches:getLocation()
    local locationCon = self._panel1:convertToNodeSpace(location)
    local nodePos = cc.p(locationCon.x, locationCon.y)

    local intersect = false
    for i = 1, 9 do
        local embattle_item = self._itemList[i]
        local item_node = self._nodeItemArray[i]
        local x , y = item_node:getPosition()
        local width, height = 120, 100
        local rect = cc.rect(x - width / 2, y - height / 2, width, height)

        intersect = cc.rectContainsPoint(rect, nodePos) and embattle_item:formationOpened()
        local nodeCard = self._moveCard
        local role_data = nodeCard:getRoleData()
        if intersect then
            if self._curPage == self.PAGE.PAGE_ZHIJI and not embattle_item:getRoleData(self.PAGE.PAGE_WUJIANG) then
                return
            end

            if nodeCard:getFromID() > 0 then
                if nodeCard:getRoleType() ~= self._curPage then
                    return
                elseif nodeCard:getFromID() == embattle_item._index then
                    return
                elseif embattle_item:getRoleData(self._curPage) then
                    self:switchRole(embattle_item, role_data)
                else
                    self:upRole(embattle_item, role_data, embattle_item._index)
                end
            else
                --判处是否已经出战
                for _,posItem in ipairs(self._itemList) do
                    if posItem:getRoleID(self._curPage) == role_data.id then
                        return
                    end
                end
                if not embattle_item:getRoleData(self._curPage) then
                    self:upRole(embattle_item, role_data, embattle_item._index)
                else
                    self:switchRole(embattle_item, role_data)
                end
            end
            break
        end
    end

    if not intersect then
        if self:bottomContainClickPos(location) then
            local nodeCard = self._moveCard
            if nodeCard:getFromID() > 0 then
                local embattle_item = self._itemList[nodeCard:getFromID()]
                embattle_item:downRole(-1)
                if self._curPage == self.PAGE.PAGE_ZHIJI then self:sendBosomFormationData() end
            end
        end
    end
end

function EmbattleView:setMoveCardState(flag)
    self._moveItem:setVisible(not flag)
    self._moveCard:setVisible(flag)
end

function EmbattleView:bottomContainClickPos(pos)
    local list_localtion = self._nodeBottom:convertToNodeSpace(pos)
    local node_pos = cc.p(list_localtion.x, list_localtion.y)
    local x, y = self._panelBottom:getPosition()
    local width, height = 300, 550
    local rect = cc.rect(x, y, width, height)
    return cc.rectContainsPoint(rect, node_pos)
end

function EmbattleView:setMoveNodeData(role_data, roleType, fromID)
    fromID = fromID and fromID or 0
    self._moveItem:setIndex(fromID)
    self._moveItem:setData(self._curFormation)
    self._moveItem:setSoilderData(role_data, roleType)
    self._moveItem:setVisible(false)
    self._moveCard:setVisible(false)
    self._moveCard:setRoleType(roleType)
    self._moveCard:setRoleData(role_data)
    self._moveCard:setFromID(fromID)
end

function EmbattleView:switchRole(embattle_item, role_data)
    if self._curPage == self.PAGE.PAGE_WUJIANG then
        embattle_item:switch(role_data, self._curPage)
    else
        --交换数据
        local switch_role_data = embattle_item:getRoleData(self._curPage)
        local switch_embattle_item = self:getEmbattleItem(role_data)
        if switch_embattle_item then
            switch_embattle_item:setSoilderData(switch_role_data, self._curPage)
        else
            uq.cache.formation:roleDown(switch_role_data, self._curPage)
            uq.cache.formation:removeRoleDown(role_data)
        end
        embattle_item:setSoilderData(role_data, self._curPage)
        self:sendBosomFormationData()
    end
end

function EmbattleView:closeEmbattleGeneralTip()
    if self._embattleTip and not self._onTouch then
        self._embattleTip:removeFromParent()
        self._embattleTip = nil
    end
end

function EmbattleView:sendBosomFormationData()
    local bosomFormationDt = {}
    for k, item in pairs(self._itemList) do
        if item:getRoleData(self._curPage) then
            table.insert(bosomFormationDt, {pos = k, bosom_id = item:getRoleData(self._curPage).id})
        end
    end
    local data = {
        formation_id = self._curFormation,
        count = #bosomFormationDt,
        bosom_formation = bosomFormationDt
    }
    network:sendPacket(Protocol.C_2_S_BOSOM_FRIEND_BATTLE, data)
end

function EmbattleView:getEmbattleItem(role_data)
    for k, item in pairs(self._itemList) do
        if item:getRoleData(self._curPage) and item:getRoleData(self._curPage).id == role_data.id then
            return item
        end
    end
    return nil
end
function EmbattleView:setCallback(callback)
    self._callback = callback
end

function EmbattleView:onTextfield(event)
    uq.log('onTextfield log', event)
end

return EmbattleView