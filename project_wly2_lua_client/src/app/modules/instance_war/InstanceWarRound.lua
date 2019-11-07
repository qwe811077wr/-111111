local InstanceWarRound = class("InstanceWarRound", require('app.base.PopupBase'))

InstanceWarRound.RESOURCE_FILENAME = "instance_war/InstanceWarRound.csb"
InstanceWarRound.RESOURCE_BINDING = {
    ["Panel_1"]  = {["varname"] = "_panelBg"},
    ["Button_1"] = {["varname"] = "_btnComfirm",["events"] = {{["event"] = "touch",["method"] = "onConfirm"}}},
}

function InstanceWarRound:onCreate()
    InstanceWarRound.super.onCreate(self)
    self:centerView()
    self:parseView()
    self:setLayerColor()
    self:createList()
end

function InstanceWarRound:setData(callback)
    self._callback = callback
end

function InstanceWarRound:onExit()
    if self._callback then
        self._callback()
    end
    InstanceWarRound.super.onExit(self)
end

function InstanceWarRound:onConfirm(event)
    if event.name ~= "ended" then
        return
    end
    self:disposeSelf()
end

function InstanceWarRound:createList()
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

function InstanceWarRound:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
end

function InstanceWarRound:cellSizeForTable(view, idx)
    return 455, 32
end

function InstanceWarRound:numberOfCellsInTableView(view)
    return 0
end

function InstanceWarRound:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("instance_war.InstanceWarRoundItem")
        cell_item:setTag(1000)
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end
    cell_item:setData()

    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))
    return cell
end

return InstanceWarRound