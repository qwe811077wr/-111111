local RetainerLike = class("RetainerLike", require('app.base.PopupBase'))

RetainerLike.RESOURCE_FILENAME = "retainer/RetainerLike.csb"
RetainerLike.RESOURCE_BINDING = {
    ["Node_3/Panel_27"]                = {["varname"] = "_pnlList"},
    ["Node_3/value_txt"]               = {["varname"] = "_txtValue"},
}

function RetainerLike:ctor(name,param)
    RetainerLike.super.ctor(self, name, param)
    self.param = param or {}
end
function RetainerLike:init()
    self:centerView()
    self:parseView()
    self:setLayerColor(0.4)
    self._listData = self:getDataLike()
    self._intimacy = self.param.intimacy or 0
    self._id = 0
    self._isSuzerain = false
    self:initLayer()
    self._eventZongEvent = services.EVENT_NAMES.ON_ZONG_EVENTS .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_ZONG_EVENTS, handler(self, self._onZongEvents), self._eventZongEvent)
end

function RetainerLike:initLayer()
    local info = self.param.info or {}
    if info.info and info.info[1] and info.info[1].id then
        self._isSuzerain = uq.cache.retainer:isOwnSuzerain(info.info[1].id)
        self._id = info.info[1].id
    end
    self._txtValue:setString(tostring(self._intimacy))
    local view_size = self._pnlList:getContentSize()
    self._listView = cc.TableView:create(cc.size(view_size.width, view_size.height))
    self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listView:setPosition(cc.p(-15, 0))
    self._listView:setAnchorPoint(cc.p(0, 0))
    self._listView:setDelegate()
    self._listView:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._listView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._listView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._listView:reloadData()
    self._pnlList:addChild(self._listView)
end

function RetainerLike:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
end

function RetainerLike:cellSizeForTable(view, idx)
    return 720, 140
end

function RetainerLike:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil
    if not cell then
        cell = cc.TableViewCell:new();
        cell_item = uq.createPanelOnly("retainer.LikeItems")
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end
    cell_item:setTag(1000)
    cell_item:setData(self._listData[index], self._isSuzerain, self._intimacy, self._id)
    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))
    return cell
end

function RetainerLike:numberOfCellsInTableView(view)
    if self._listData then
        return #self._listData
    else
        return 0
    end
end

function RetainerLike:_onZongEvents(evt)
    self._listData = self:getDataLike()
    self._listView:reloadData()
end

function RetainerLike:getDataLike()
    local tab = StaticData['zong_event'] or {}
    local tab_like = {}
    for k, v in pairs(tab) do
        if v.type == 3 then
            table.insert(tab_like, v)
        end
    end
    table.sort(tab_like, function (a, b)
        return a.ident < b.ident
    end)
    return tab_like
end

function RetainerLike:dispose()
    services:removeEventListenersByTag(self._eventZongEvent)
    RetainerLike.super.dispose(self)
end

return RetainerLike