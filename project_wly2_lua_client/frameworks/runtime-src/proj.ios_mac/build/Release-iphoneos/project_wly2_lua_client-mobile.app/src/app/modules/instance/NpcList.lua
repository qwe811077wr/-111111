local NpcList = class("NpcList", require('app.base.PopupBase'))

NpcList.RESOURCE_FILENAME = "instance/NpcList.csb"
NpcList.RESOURCE_BINDING = {
    ["Panel_1"] = {["varname"] = "_panelBg"},
}

function NpcList:onCreate()
    NpcList.super.onCreate(self)
    self:centerView()
    self:parseView()
    self:setLayerColor()

    self._dataList = {}
    self:createList()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_HIDE_MAIN_UI})
end

function NpcList:onExit()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_SHOW_MAIN_UI})
    NpcList.super:onExit()
end

function NpcList:createList()
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

function NpcList:setData(instance_id)
    self._instanceId = instance_id
    local instance_config = StaticData['instance'][self._instanceId]
    local map_config = StaticData.load('instance/' .. instance_config.fileId)

    for _, map_item in pairs(map_config.Map[self._instanceId].Object) do
        local npc_info = uq.cache.instance:getNPC(self._instanceId, map_item.ident)
        if uq.cache.instance:isInNpcListNotFullStar(npc_info, map_item, self._instanceId) then
            table.insert(self._dataList, {config = map_item, instance_id = self._instanceId})
        end
    end

    table.sort(self._dataList, function(item1, item2)
        return item1.config.ident < item2.config.ident
    end)

    self._listView:reloadData()
end

function NpcList:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
end

function NpcList:cellSizeForTable(view, idx)
    return 655, 155
end

function NpcList:numberOfCellsInTableView(view)
    return #self._dataList
end

function NpcList:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("instance.NpcListItem")
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end

    cell_item:setTag(1000)
    cell_item:setData(self._dataList[index], handler(self, self.callbackBattle))

    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))

    return cell
end

function NpcList:callbackBattle()
    self:disposeSelf()
end

return NpcList