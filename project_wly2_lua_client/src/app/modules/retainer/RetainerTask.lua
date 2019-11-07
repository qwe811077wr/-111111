local RetainerTask = class("RetainerTask", require("app.base.TableViewBase"))

RetainerTask.RESOURCE_FILENAME = "retainer/RetainerList.csb"
RetainerTask.RESOURCE_BINDING  = {
    ["Panel_1"]              = {["varname"] = "_pnlList"},
    ["Panel_2"]              = {["varname"] = "_pnlApply"},
}

function RetainerTask:ctor(name, args)
    RetainerTask.super.ctor(self)
end

function RetainerTask:init()
    self._listData = self:dealData()
    self:initLayer()
    self._pnlApply:setVisible(false)
    self._listView:reloadData()
    self._eventZongEvent = services.EVENT_NAMES.ON_ZONG_EVENTS .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_ZONG_EVENTS, handler(self, self._onZongEvents), self._eventZongEvent)
end

function RetainerTask:initLayer()
    local view_size = self._pnlList:getContentSize()
    self._listView = cc.TableView:create(cc.size(view_size.width, view_size.height))
    self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listView:setPosition(cc.p(0, 0))
    self._listView:setAnchorPoint(cc.p(0, 0))
    self._listView:setDelegate()
    self._listView:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._listView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._listView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._listView:reloadData()
    self._pnlList:addChild(self._listView)
end

function RetainerTask:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
end

function RetainerTask:cellSizeForTable(view, idx)
    return 1100, 130
end

function RetainerTask:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        cell_item = uq.createPanelOnly("retainer.TaskItems")
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end
    cell_item:setTag(1000)
    cell_item:setData(self._listData[index])
    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))

    return cell
end

function RetainerTask:numberOfCellsInTableView(view)
    if self._listData then
        return #self._listData
    else
        return 0
    end
end

function RetainerTask:_onZongEvents(evt)
    self._listData = self:dealData()
    self._listView:reloadData()
end

function RetainerTask:dealData()
    if uq.cache.retainer:getOwnSuzerain() == 0 then
        return {}
    end
    local tab = {}
    for k, v in pairs(StaticData['zong_event']) do
        if v.type == 1 and uq.cache.retainer:getSuzerainEventStatus(v.ident) == 0 then
            table.insert(tab, v)
        end
    end
    table.sort(tab, function (a, b)
        return a.ident < b.ident
    end)
    return tab
end

function RetainerTask:onExit()
    services:removeEventListenersByTag(self._eventZongEvent)
    RetainerTask.super:onExit()
end

return RetainerTask