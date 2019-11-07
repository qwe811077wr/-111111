local InstanceWarInvestigate = class("InstanceWarInvestigate", require('app.base.PopupBase'))

InstanceWarInvestigate.RESOURCE_FILENAME = "instance_war/InstanceWarInvestigate.csb"
InstanceWarInvestigate.RESOURCE_BINDING = {
    ["Panel_1"]  = {["varname"] = "_panelBg"},
    ["Button_1"] = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onClose"}}},
}

function InstanceWarInvestigate:onCreate()
    InstanceWarInvestigate.super.onCreate(self)
    self:centerView()
    self:parseView()
    self:setLayerColor()
end

function InstanceWarInvestigate:setData(data)
    self._data = data
    self:createList()
end

function InstanceWarInvestigate:onClose(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

function InstanceWarInvestigate:createList()
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

function InstanceWarInvestigate:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
end

function InstanceWarInvestigate:cellSizeForTable(view, idx)
    return 950, 115
end

function InstanceWarInvestigate:numberOfCellsInTableView(view)
    return #self._data.troop_id
end

function InstanceWarInvestigate:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("instance_war.InstanceWarInvestigateItem")
        cell_item:setTag(1000)
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end
    cell_item:setData(self._data.troop_id[index], self._data.city_id)

    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))
    return cell
end


return InstanceWarInvestigate