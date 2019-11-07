local GeneralsInternal = class("GeneralsInternal", require("app.base.PopupBase"))

GeneralsInternal.RESOURCE_FILENAME = "generals/InternalProperty.csb"
GeneralsInternal.RESOURCE_BINDING  = {
    ["Button_1"] = {["varname"] = "_btnInternal",["events"] = {{["event"] = "touch",["method"] = "onInternal"}}},
    ['Panel_1']  = {["varname"] = "_panelBg"},
}

function GeneralsInternal:onCreate()
    GeneralsInternal.super.onCreate(self)
    self:centerView()
    self:parseView()

    self._dataList = {}
    self:createList()
end

function GeneralsInternal:setData(temp_id, gerneral_id)
    self._dataList = StaticData['officer'].OfficerAttrType
    self._generalId = gerneral_id
    self._tempId = temp_id
    self._listView:reloadData()
end

function GeneralsInternal:onInternal(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

function GeneralsInternal:createList()
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

function GeneralsInternal:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
end

function GeneralsInternal:cellSizeForTable(view, idx)
    return 596, 80
end

function GeneralsInternal:numberOfCellsInTableView(view)
    return #self._dataList
end

function GeneralsInternal:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("generals.GeneralsInternalItem")
        cell_item:setTag(1000)
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end

    cell_item:setData(self._dataList[index], self._tempId, self._generalId)

    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))

    return cell
end

return GeneralsInternal
