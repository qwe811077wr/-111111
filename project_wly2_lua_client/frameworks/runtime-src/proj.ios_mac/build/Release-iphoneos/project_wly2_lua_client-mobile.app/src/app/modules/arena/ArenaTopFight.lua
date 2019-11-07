local ArenaTopFight = class("ArenaTopFight", require('app.modules.common.BaseViewWithHead'))

ArenaTopFight.RESOURCE_FILENAME = "arena/ArenaTopFight.csb"
ArenaTopFight.RESOURCE_BINDING = {
    ["Panel_1"]    = {["varname"] = "_panelBg"},
    ["Button_1"]   = {["varname"] = "_btnReward", ["events"] = {{["event"] = "touch",["method"] = "onTouchExit"}}},
}

function ArenaTopFight:init()
    self._dataList = {}

    self:centerView()
    self:parseView()

    local coin_group = {
        uq.config.constant.COST_RES_TYPE.MONEY,
        uq.config.constant.COST_RES_TYPE.GOLDEN,
        uq.config.constant.COST_RES_TYPE.ARENA_SCORE
    }
    self:addShowCoinGroup(coin_group)
    self:createList()
    self:adaptBgSize()
end

function ArenaTopFight:onTouchExit(evt)
    if evt.name ~= "ended" then
        return
    end
    self:disposeSelf()
end

function ArenaTopFight:onCreate()
    ArenaTopFight.super.onCreate(self)

    network:addEventListener(Protocol.S_2_C_ATHLETICS_LOAD_TOP_LOG, handler(self, self._onLoadLog), '_onLoadLog')
    network:sendPacket(Protocol.C_2_S_ATHLETICS_LOAD_TOP_LOG)
end

function ArenaTopFight:onExit()
    network:removeEventListenerByTag('_onLoadLog')

    ArenaTopFight.super:onExit()
end

function ArenaTopFight:_onLoadLog(msg)
    self._dataList = msg.data.logs
    self._listView:reloadData()
end

function ArenaTopFight:createList()
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

function ArenaTopFight:tableCellTouched(view, cell)
    local item = cell:getChildByTag(1000)
    if not item then
        return
    end
    item:onClickItem()
end

function ArenaTopFight:cellSizeForTable(view, idx)
    return 1080, 110
end

function ArenaTopFight:numberOfCellsInTableView(view)
    return #self._dataList
end

function ArenaTopFight:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local item = nil

    if not cell then
        cell = cc.TableViewCell:new()
        item = uq.createPanelOnly("arena.ArenaTopFightItem")
        cell:addChild(item)
    else
        item = cell:getChildByTag(1000)
    end

    item:setTag(1000)
    item:setData(self._dataList[index])

    local width, height = self:cellSizeForTable(view, idx)
    item:setPosition(cc.p(width / 2, height / 2))

    return cell
end

return ArenaTopFight