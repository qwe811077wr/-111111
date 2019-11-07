local ArenaRank = class("ArenaRank", require('app.modules.common.BaseViewWithHead'))

ArenaRank.RESOURCE_FILENAME = "arena/ArenaRank.csb"
ArenaRank.RESOURCE_BINDING = {
    ["Panel_5"]        = {["varname"] = "_panelBg"},
    ["Image_4"]        = {["varname"] = "_imgOwner"},
    ["Button_1"]       = {["varname"] = "_btnReward", ["events"] = {{["event"] = "touch",["method"] = "onTouchExit"}}},
}

function ArenaRank:init()
    self._dataList = {}

    local coin_group = {
        uq.config.constant.COST_RES_TYPE.MONEY,
        uq.config.constant.COST_RES_TYPE.GOLDEN,
        uq.config.constant.COST_RES_TYPE.ARENA_SCORE
    }
    self:addShowCoinGroup(coin_group)
    self:centerView()
    self:parseView()
    self:createList()
    self:adaptBgSize()

    self._ownerItem = uq.createPanelOnly("arena.ArenaRankItem")
    local size = self._ownerItem:getChildByName("Layer"):getContentSize()
    self._ownerItem:setPosition(cc.p(size.width / 2, size.height / 2))
    self._imgOwner:addChild(self._ownerItem)
    self._ownerItem:setOwnerTextSize(18)

    network:addEventListener(Protocol.S_2_C_ATHLETICS_RANK, handler(self, self._onLoadRank), '_onLoadRank')
    network:sendPacket(Protocol.C_2_S_LOAD_ATHLETICS_RANK)
end

function ArenaRank:onCreate()
    ArenaRank.super.onCreate(self)
end

function ArenaRank:onExit()
    network:removeEventListenerByTag('_onLoadRank')
    ArenaRank.super:onExit()
end

function ArenaRank:onTouchExit(evt)
    if evt.name ~= "ended" then
        return
    end
    self:disposeSelf()
end

function ArenaRank:_onLoadRank(msg)
    local data = msg.data
    self._dataList = data.items
    self._ownerInfo = data.owner
    self._listView:reloadData()
    self._ownerItem:setData(self._ownerInfo[1])
end

function ArenaRank:createList()
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
    self._panelBg:addChild(self._listView)
end

function ArenaRank:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
end

function ArenaRank:cellSizeForTable(view, idx)
    return 1039, 115
end

function ArenaRank:numberOfCellsInTableView(view)
    return #self._dataList
end

function ArenaRank:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new()
        cell_item = uq.createPanelOnly("arena.ArenaRankItem")
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end

    cell_item:setTag(1000)
    cell_item:setData(self._dataList[index])

    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))

    return cell
end

return ArenaRank