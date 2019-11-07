local DrillMain = class("DrillMain", require('app.base.TableViewBase'))

DrillMain.RESOURCE_FILENAME = "drill/DrillView.csb"
DrillMain.RESOURCE_BINDING = {
    ["Node_1"]              = {["varname"] = "_nodeBase"},
    ["Panel_28"]            = {["varname"] = "_panelItem"},
    ["Panel_27"]            = {["varname"] = "_panelTableView"},
    ["Text_101"]            = {["varname"] = "_txtNum"},
    ["Text_21"]             = {["varname"] = "_txtTitle"},
}
function DrillMain:ctor(name, params)
    DrillMain.super.ctor(self, name, params)
    self._info = params.info
    self._tabArray = {}
    self._rightUi = {}
    self._arrList = {1, 2, 3, 4, 5}
    self._curIndex = uq.cache.drill:getDrillIdOperation()
    self._drillNum = StaticData['drill_ground'].Info[1].times - uq.cache.drill:getFinishTimes()
end

function DrillMain:init()
    self:initProtocal()
    self._allDiffItem = {}
    self:parseView()
    self:initTableView()
    self:initItem()
end

function DrillMain:showAction()
    uq.intoAction(self._nodeBase, cc.p(uq.config.constant.MOVE_DISTANCE, 0))
    uq.intoAction(self._panelItem, cc.p(-uq.config.constant.MOVE_DISTANCE, 0))
    for i, v in ipairs(self._tabArray) do
        v:showAction()
    end
    for k, v in ipairs(self._allDiffItem) do
        v:showAction()
    end
end

function DrillMain:initProtocal()
    services:addEventListener(services.EVENT_NAMES.ON_REFRESH_DRILL_OPEN_TIME, handler(self, self.refreshItem), 'on_refresh_open_time' .. tostring(self))
    services:addEventListener(services.EVENT_NAMES.ON_DRILL_GROUND_ENTER, handler(self, self._onDrillEnter), 'on_drill_enter' .. tostring(self))
    services:addEventListener(services.EVENT_NAMES.ON_DRILL_SKILL_END, handler(self, self._onDrillEnd), 'on_drill_end' .. tostring(self))
end

function DrillMain:_onDrillEnter(msg)
    local data = msg.data
    if data.ret ~= 0 then
        return
    end
    local info = {
        xml_data = uq.cache.drill:getDrillXmlById(data.id),
        cur_mode = data.mode
    }
    self._drillNum = self._drillNum - 1
    self._txtNum:setString(self._drillNum)
    for k, v in ipairs(self._tabArray) do
        v:setDoingState(true, data.id)
    end
    for k, v in ipairs(self._allDiffItem) do
        v:refreshBtnState(data.id, data.mode)
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.DRILL_CARD, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, data = info})
end

function DrillMain:_onDrillEnd()
    for k, v in ipairs(self._tabArray) do
        v:setDoingState(false)
    end
    for k, v in ipairs(self._allDiffItem) do
        v:refreshOpenState()
        v:refreshBtnState()
    end
end

function DrillMain:initItem()
    self:sortAllDrillInfo()
    if self._curIndex ~= 0 then
        for k, v in ipairs(self._allDrillInfo) do
            if self._curIndex == v.ident then
                self._curDrillInfo = v.Mode
                break
            end
        end
    else
        self._curDrillInfo = self._allDrillInfo[self._arrList[1]].Mode
        self._curIndex = self._allDrillInfo[self._arrList[1]].ident
    end

    self._tabArray = {}
    local size = self._panelItem:getContentSize()
    self._panelItem:removeAllChildren()
    local pos_y = size.height
    for i = 1, #self._allDrillInfo do
        local item = uq.createPanelOnly("drill.DrillCardBox")
        local item_size = item:getItemContentSize()
        item:setCallBack(handler(self, self._onTabChanged))
        item:setInfo(self._allDrillInfo[self._arrList[i]])
        item:setPosition(cc.p(size.width / 2, pos_y - item_size.height / 2))
        item:setImgSelectedState(self._arrList[i] == self._curIndex)
        table.insert(self._tabArray, item)
        self._panelItem:addChild(item)
        pos_y = pos_y - item_size.height + 5
    end
    self._txtTitle:setString(self._allDrillInfo[self._arrList[1]].name)
    self._txtNum:setString(self._drillNum)
    self._tableView:reloadData()
end

function DrillMain:refreshItem()
    if self._refreshTime and self._refreshTime - os.time() < 10 then
        return
    end
    self._refreshTime = os.time()
    self:sortAllDrillInfo()
    for k, v in ipairs(self._tabArray) do
        item:setInfo(self._allDrillInfo[self._arrList[i]])
    end
    self._curDrillInfo = self._allDrillInfo[self._arrList[1]].Mode
    self._curIndex = self._allDrillInfo[self._arrList[1]].ident
    self._tableView:reloadData()
end

function DrillMain:_onTabChanged(info)
    for k, v in ipairs(self._tabArray) do
        v:setImgSelectedState(false)
    end
    self._curDrillInfo = info.Mode
    self._curIndex = info.ident
    self._tableView:reloadData()
    self._txtTitle:setString(info.name)
end

function DrillMain:sortAllDrillInfo()
    local info = StaticData['drill_ground'].DrillGround
    for k, v in ipairs(info) do
        v.open_state = uq.cache.drill:checkDrillStateByDay(v.openDay)
    end
    table.sort(self._arrList, function(a, b)
        if info[a].open_state ~= info[b].open_state then
            return info[a].open_state
        else
            return info[a].ident < info[b].ident
        end
    end)
    self._allDrillInfo = info
end

function DrillMain:initTableView()
    local size = self._panelTableView:getContentSize()
    self._tableView = cc.TableView:create(cc.size(size.width,size.height))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setAnchorPoint(cc.p(0,0))
    self._tableView:setDelegate()
    self._panelTableView:addChild(self._tableView)

    self._tableView:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
end

function DrillMain:cellSizeForTable(view, idx)
    local index = idx + 1
    if index == self:numberOfCellsInTableView() and idx >= 4 then
        return 774, 175
    else
        return 774, 125
    end
end

function DrillMain:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local item = nil
    if not cell then
        cell = cc.TableViewCell:new()
        item = uq.createPanelOnly("drill.DrillDiffcultyBox")
        table.insert(self._allDiffItem, item)
        item:setName("item")
        cell:addChild(item)
    else
        item = cell:getChildByName("item")
    end
    local size = item:getItemContentSize()
    local width, height = self:cellSizeForTable(view, idx)
    item:setPosition(cc.p(size.width / 2 + 10, height - size.height / 2))
    item:setVisible(self._curDrillInfo[index] ~= nil)
    item:setInfo(self._curDrillInfo[index], self._curIndex)
    return cell
end

function DrillMain:numberOfCellsInTableView()
    return #self._curDrillInfo
end

function DrillMain:update()
    -- body
end

function DrillMain:dispose()
    services:removeEventListenersByTag('on_refresh_open_time' .. tostring(self))
    services:removeEventListenersByTag('on_drill_enter' .. tostring(self))
    services:removeEventListenersByTag('on_drill_end' .. tostring(self))
    DrillMain.super.dispose(self)
end

return DrillMain