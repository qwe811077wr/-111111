local ArmsMain = class("ArmsMain", require("app.base.PopupTabView"))
local ArmsListItem = require("app.modules.generals.ArmsListItem")

ArmsMain.RESOURCE_FILENAME = "generals/ArmsMain.csb"

ArmsMain.RESOURCE_BINDING  = {
    ["Panel_46/Panel_27"]                ={["varname"] = "_panelTab"},
    ["Panel_1"]                          ={["varname"] = "_panelTableView"},
}

function ArmsMain:ctor(name, args)
    ArmsMain.super.ctor(self, name, args)
    self._generalId = args.general_id or 0
    self._curSoldierId = 0
    self._cellArray = {}
end

function ArmsMain:init()
    self._tabModuleArray = {}
    self._soldierarray1 = {}
    self._soldierarray2 = {}
    self._allSoldierInfo = {self._soldierarray1, self._soldierarray2}
    self._curSoldierarray = {}
    self._curGeneralInfo = uq.cache.generals:getGeneralDataByID(self._generalId)
    local top_ui = uq.ui.CommonHeaderUI:create()
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.GESTE, true))
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.MONEY, true))
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.GOLDEN, true))
    self._topUI = top_ui
    self._view:addChild(top_ui:getNode())

    self:parseView()
    self:centerView()
    if self._curGeneralInfo == nil then
        return
    end
    self._tabIndex = 1
    self:initData()
    self:initTableView()
    self:addTabBtns()
    self:initProtocolData()
end

function ArmsMain:initData()
    local soldier_xml1 = StaticData['soldier'][self._curGeneralInfo.soldierId1]
    local soldier_xml2 = StaticData['soldier'][self._curGeneralInfo.soldierId2]
    self._tabType = {soldier_xml1.type, soldier_xml2.type}
    if not soldier_xml2 or not soldier_xml1 then
        uq.log("error ArmsMain updateBaseInfo  soldier_xml2")
        return
    end
    for k, v in pairs(StaticData['soldier']) do
        if v.type == soldier_xml1.type and v.isHidden == 0 then
            if self._soldierarray1[v.level + 1] == nil then
                self._soldierarray1[v.level + 1] = {}
            end
            v.mainSoldierLevel = 0
            if v.ident == soldier_xml1.ident then
                v.mainSoldierLevel = soldier_xml1.level
            end
            table.insert(self._soldierarray1[v.level + 1], v)
        elseif v.type == soldier_xml2.type and v.isHidden == 0 then
            if self._soldierarray2[v.level + 1] == nil then
                self._soldierarray2[v.level + 1] = {}
            end
            v.mainSoldierLevel = 0
            if v.ident == soldier_xml2.ident then
                v.mainSoldierLevel = soldier_xml2.level
            end
            table.insert(self._soldierarray2[v.level + 1], v)
        end
    end
end

function ArmsMain:initTableView()
    local size = self._panelTableView:getContentSize()
    self._tableView = cc.TableView:create(cc.size(size.width,size.height))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setAnchorPoint(cc.p(0,0))
    self._tableView:setDelegate()
    self._panelTableView:addChild(self._tableView)

    self._tableView:registerScriptHandler(handler(self,self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
end

function ArmsMain:tableCellTouched(view, cell, touch)
    local touch_point = touch:getLocation()
    local item = cell:getChildByName("item")
    item:onItemTouch(touch_point)
end

function ArmsMain:cellSizeForTable(view, idx)
    local width = 1180
    local height = self:getHeightByIndex(idx + 1)
    return width, height
end

function ArmsMain:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx + 1
    if not cell then
        cell = cc.TableViewCell:new()
        local item = ArmsListItem:create()
        item:setContentHeight(self:getHeightByIndex(index))
        item:setName("item")
        item:setTag(index)
        item:setInfo(self._allSoldierInfo[self._tabIndex][index], self._generalId)
        local height = item:getPanelItemHeight()
        item:setPositionY(height)
        cell:addChild(item)
        table.insert(self._cellArray, item)
    else
        local item = cell:getChildByName("item")
        item:setTag(index)
        item:setContentHeight(self:getHeightByIndex(index))
        item:setInfo(self._allSoldierInfo[self._tabIndex][index], self._generalId)
        item:setPositionY(item:getPanelItemHeight())
    end
    return cell
end

function ArmsMain:numberOfCellsInTableView()
    return #self._allSoldierInfo[self._tabIndex]
end

function ArmsMain:getHeightByIndex(index)
    local num = #self._allSoldierInfo[self._tabIndex][index]
    local height = math.ceil(num / 4) * 175 + 40
    return height
end

function ArmsMain:addTabBtns()
    local ids = {self._curGeneralInfo.soldierId1, self._curGeneralInfo.soldierId2}
    for i = 1, 2, 1 do
        local tab_btn = self._panelTab:getChildByName("tab_" .. i)
        table.insert(self._tabModuleArray, tab_btn)

        local soldier_xml1 = StaticData['soldier'][ids[i]]
        if not soldier_xml1 then
            uq.log("error GeneralsArms updateBaseInfo  soldier_xml1")
            return
        end
        tab_btn:setTag(ids[i])
        tab_btn.index = i
        if i == self._tabIndex then
            self:onTabChanged(tab_btn)
            self._curSoldierId = self._curGeneralInfo.soldierId1
        end
        tab_btn:addClickEventListenerWithSound(handler(self, self.onTabChanged))
    end
end

function ArmsMain:onTabChanged(btn)
    local tag = btn:getTag()
    if self._curSoldierId == tag then
        return
    end
    for i, v in ipairs(self._tabModuleArray) do
        local type_data = StaticData['types'].Soldier[1].Type[self._tabType[i]]
        local img_bg = v:getChildByName("Image_17")
        v:setEnabled(btn.index ~= i)
        if btn.index == i then
            img_bg:loadTexture("img/generals/" .. type_data.selectedTab)
        else
            img_bg:loadTexture("img/generals/" .. type_data.normalTab)
        end
    end
    self._curSoldierId = tag
    self._tabIndex = btn.index
    self._tableView:reloadData()
end

function ArmsMain:_onReinforcedSoldierInfo(evt)
    uq.log("_onReinforcedSoldierInfo ",evt.data)

end

function ArmsMain:initProtocolData()
    network:addEventListener(Protocol.S_2_C_REINFORCED_SOLDIER_INFO, handler(self, self._onReinforcedSoldierInfo), "_onReinforcedSoldierInfo")
    network:sendPacket(Protocol.C_2_S_REINFORCED_SOLDIER_INFO,{generalId = self._generalId})
end

function ArmsMain:removeProtocolData()
    network:removeEventListenerByTag("_onReinforcedSoldierInfo")
end

function ArmsMain:dispose()
    for k, v in ipairs(self._cellArray) do
        v:dispose()
    end
    if self._topUI then
        self._topUI:dispose()
    end
    self._topUI = nil
    uq.TimerProxy:removeTimer("addListView")
    self:removeProtocolData()
    ArmsMain.super.dispose(self)
end

return ArmsMain
