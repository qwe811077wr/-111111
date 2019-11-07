local BuffPopList = class("BuffPopList", require('app.base.PopupBase'))

BuffPopList.RESOURCE_FILENAME = "battle/BuffPopList.csb"
BuffPopList.RESOURCE_BINDING = {
    ["Panel_1"]          = {["varname"] = "_panelBuffs"},
}

function BuffPopList:ctor(name, params)
    BuffPopList.super.ctor(self, name, params)
    self._buffsArray = StaticData['buff']
    self._allBuffs = {}
    self:centerView()
    self:initBuffsTableView()
end

function BuffPopList:initBuffsTableView()
    local size = self._panelBuffs:getContentSize()
    self._listView = cc.TableView:create(cc.size(size.width, size.height))
    self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listView:setPosition(cc.p(0, 0))
    self._listView:setDelegate()
    self._listView:registerScriptHandler(handler(self, self.cellSizeForTableContent), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listView:registerScriptHandler(handler(self, self.tableCellAtIndexContent), cc.TABLECELL_SIZE_AT_INDEX)
    self._listView:registerScriptHandler(handler(self, self.numberOfCellsInTableViewContent), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._listView:reloadData()
    self._panelBuffs:addChild(self._listView)
end

function BuffPopList:cellSizeForTableContent(view, idx)
    return 500, 100
end

function BuffPopList:numberOfCellsInTableViewContent(view)
    return 21
end

function BuffPopList:tableCellAtIndexContent(view, idx)
    local index = idx
    local cell = view:dequeueCell()
    local info = self._buffsArray[index]
    local buff_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        local width = 0
        buff_item = uq.createPanelOnly("battle.BuffIntroductionCell")
        width = buff_item:getContentSize().width
        buff_item:setPosition(cc.p((width + 10), 100))
        if info ~= nil then
            buff_item:setData(info)
        end
        buff_item:setVisible(info ~= nil)
        cell:addChild(buff_item, 1)
        table.insert(self._allBuffs, buff_item)
    else
        buff_item = cell:getChildByTag(1000)
        if not buff_item then
            return cell
        end
        if info ~= nil then
            buff_item:setData(info)
        end
        buff_item:setVisible(info ~= nil)
    end
    buff_item:setTag(1000)

    return cell
end

function BuffPopList:dispose()
    BuffPopList.super.dispose(self)
end

return BuffPopList