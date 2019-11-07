local InstanceWarBattleList = class("InstanceWarBattleList", require('app.base.PopupBase'))

InstanceWarBattleList.RESOURCE_FILENAME = "instance_war/InstanceWarBattle.csb"
InstanceWarBattleList.RESOURCE_BINDING = {
    ["Text_1"]   = {["varname"]= "_txtTitle"},
    ["Panel_1"]  = {["varname"] = "_panelBg"},
    ["Button_1"] = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onClose"}}},
}

function InstanceWarBattleList:onCreate()
    InstanceWarBattleList.super.onCreate(self)
    self:centerView()
    self:parseView()
    self:setLayerColor()
end

function InstanceWarBattleList:onExit()
    if self._callBack then
        self._callBack()
    end
    InstanceWarBattleList.super.onExit(self)
end

function InstanceWarBattleList:setData(data)
    self._txtTitle:setString('战报')

    self._listData = {{show_type = 1}, {show_type = 1}, {show_type = 2}, {show_type = 2}, {show_type = 1}, {show_type = 3}, }
    self:createList()
end

function InstanceWarBattleList:onClose(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

function InstanceWarBattleList:createList()
    local viewSize = self._panelBg:getContentSize()
    self._listView = cc.TableView:create(cc.size(viewSize.width, viewSize.height))
    self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listView:setPosition(cc.p(0, 0))
    self._listView:setDelegate()
    self._listView:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._listView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._listView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._listView:reloadData()
    self._panelBg:addChild(self._listView)
end

function InstanceWarBattleList:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
    local item_data = self._listData[index]
    if item_data.show_type == 2 then
        self._listData[index].show_type = 3
        self._listView:reloadData()
    elseif item_data.show_type == 3 then
        -- local data = self._battleData.battle_list[index]
        -- uq.BattleReport:showBattleReport(data.report, handler(self, self.battleEnd))
    end
end

function InstanceWarBattleList:battleEnd(report)
    uq.BattleReport:showBattleResult(report)
end

function InstanceWarBattleList:cellSizeForTable(view, idx)
    local index = idx + 1
    local item_data = self._listData[index]
    if item_data.show_type == 1 then
        return 1057, 50
    elseif item_data.show_type == 2 then
        return 1057, 44
    elseif item_data.show_type == 3 then
        return 1057, 139
    end
end

function InstanceWarBattleList:numberOfCellsInTableView(view)
    return #self._listData
end

function InstanceWarBattleList:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("instance_war.InstanceWarBattleItem")
        cell_item:setTag(1000)
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end
    local item_data = self._listData[index]
    cell_item:setListData(item_data)

    local width, height = self:cellSizeForTable(view, idx)
    if item_data.show_type == 1 then
        cell_item:setPosition(cc.p(width / 2 - 5, height / 2 - 3))
    else
        cell_item:setPosition(cc.p(width / 2 - 5, height / 2))
    end
    return cell
end


return InstanceWarBattleList