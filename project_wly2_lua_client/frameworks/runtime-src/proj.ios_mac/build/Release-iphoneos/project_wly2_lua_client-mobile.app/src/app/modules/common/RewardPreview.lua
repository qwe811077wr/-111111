local RewardPreview = class("RewardPreview", require('app.base.PopupBase'))

RewardPreview.RESOURCE_FILENAME = "common/RewardPreview.csb"
RewardPreview.RESOURCE_BINDING = {
    ["Panel_1"]                   = {["varname"] = "_pnlList"},
}

function RewardPreview:ctor(name, args)
    RewardPreview.super.ctor(self, name, args)
    self._rewards = args.rewards
end

function RewardPreview:init()
    self._dataList = {}
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self:initLayer()
end

function RewardPreview:initLayer()
    if self._rewards and self._rewards ~= "" then
        local item_list = uq.RewardType.parseRewards(self._rewards)
        for i, v in ipairs(item_list) do
            table.insert(self._dataList, v:toEquipWidget())
        end
    end
    local view_size = self._pnlList:getContentSize()
    self._listView = cc.TableView:create(cc.size(view_size.width, view_size.height))
    self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listView:setPosition(cc.p(0, 0))
    self._listView:setDelegate()
    self._listView:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._listView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._listView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._listView:reloadData()
    self._pnlList:addChild(self._listView)
end

function RewardPreview:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
end

function RewardPreview:cellSizeForTable(view, idx)
    return 510, 110
end

function RewardPreview:numberOfCellsInTableView(view)
    return #self._dataList
end

function RewardPreview:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new()
        cell_item = uq.createPanelOnly("common.RewardPreviewItems")
        cell_item:setTag(1000)
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end
    cell_item:setData(self._dataList[index])

    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))
    return cell
end

function RewardPreview:dispose()
    RewardPreview.super.dispose(self)
end
return RewardPreview