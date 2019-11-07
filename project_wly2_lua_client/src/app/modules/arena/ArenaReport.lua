local ArenaReport = class("ArenaReport", require('app.modules.common.BaseViewWithHead'))

ArenaReport.RESOURCE_FILENAME = "arena/ArenaReport.csb"
ArenaReport.RESOURCE_BINDING = {
    ["Panel_1"]    = {["varname"] = "_panelBg"},
    ["Button_1"]   = {["varname"] = "_btnReward", ["events"] = {{["event"] = "touch",["method"] = "onTouchExit"}}},
}

function ArenaReport:init()
    self._dataList = {}

    self:centerView()
    self:parseView()
    self:adaptBgSize()

    local coin_group = {
        uq.config.constant.COST_RES_TYPE.MONEY,
        uq.config.constant.COST_RES_TYPE.GOLDEN,
        uq.config.constant.COST_RES_TYPE.ARENA_SCORE
    }
    self:addShowCoinGroup(coin_group)
    self:createList()
end

function ArenaReport:onTouchExit(evt)
    if evt.name ~= "ended" then
        return
    end
    self:disposeSelf()
end

function ArenaReport:onCreate()
    ArenaReport.super.onCreate(self)

    network:addEventListener(Protocol.S_2_C_ATHLETICS_LOAD_LOG, handler(self, self._onLoadLog), '_onLoadLog')
    network:sendPacket(Protocol.C_2_S_ATHLETICS_LOAD_LOG)
end

function ArenaReport:onExit()
    network:removeEventListenerByTag('_onLoadLog')

    ArenaReport.super:onExit()
end

function ArenaReport:_onLoadLog(msg)
    self._dataList = msg.data.logs

    table.sort(self._dataList, function(a, b)
        return a.time > b.time
    end)

    self._listView:reloadData()
end

function ArenaReport:createList()
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

function ArenaReport:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
end

function ArenaReport:cellSizeForTable(view, idx)
    return 1039, 125
end

function ArenaReport:numberOfCellsInTableView(view)
    return #self._dataList
end

function ArenaReport:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cellItem = nil

    if not cell then
        cell = cc.TableViewCell:new()
        cellItem = uq.createPanelOnly("arena.ArenaReportItem")
        cell:addChild(cellItem)
    else
        cellItem = cell:getChildByTag(1000)
    end

    cellItem:setTag(1000)
    cellItem:setData(self._dataList[index])

    local width, height = self:cellSizeForTable(view, idx)
    cellItem:setPosition(cc.p(width / 2, height / 2))

    return cell
end

return ArenaReport