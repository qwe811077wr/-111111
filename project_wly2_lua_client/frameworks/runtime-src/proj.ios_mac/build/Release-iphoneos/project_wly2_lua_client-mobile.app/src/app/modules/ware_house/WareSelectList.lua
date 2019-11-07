local WareSelectList = class("WareSelectList", require('app.base.PopupBase'))

WareSelectList.RESOURCE_FILENAME = "ware_house/WareSelectList.csb"
WareSelectList.RESOURCE_BINDING = {
    ["Node_1"]                                 = {["varname"] = "_nodeBase"},
    ["Panel_2"]                                = {["varname"] = "_pnlList"},
    ["btn_ok"]                                 = {["varname"] = "_btnOk"},
    ["Button_1"]                               = {["varname"] = "_btnExit", ["events"] = {{["event"] = "touch", ["method"] = "_onTouchExit"}}},
    ["Button_10"]                              = {["varname"] = "_btnCanCel", ["events"] = {{["event"] = "touch", ["method"] = "_onTouchExit"}}},
}

function WareSelectList:ctor(name, args)
    WareSelectList.super.ctor(self, name, args)
    self._args = args or {}
    self._data = self._args.data or {}
    self._openNum = self._data.open_num or 1
    self._id = self._data.ident or 0
end

function WareSelectList:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self._selectId = 1
    self._listData = self:dealData()
    self._allListUi = {}
    self:initLayer()
end

function WareSelectList:initLayer()
    if not self._data or next(self._data) == nil then
        return
    end
    local size = self._pnlList:getContentSize()
    self._tableView = cc.TableView:create(cc.size(size.width,size.height))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setAnchorPoint(cc.p(0,0))
    self._tableView:setDelegate()
    self._pnlList:addChild(self._tableView)
    self._tableView:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:reloadData()
    self._btnOk:addClickEventListenerWithSound(function()
        network:sendPacket(Protocol.C_2_S_USE_CHEST, {id = self._id, num = self._openNum, choose = self._selectId})
        self:disposeSelf()
    end)
end

function WareSelectList:cellSizeForTable(view, idx)
    return 550, 105
end

function WareSelectList:numberOfCellsInTableView(view)
    return #self._listData
end

function WareSelectList:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        item = uq.createPanelOnly("ware_house.WareSelectItems")
        item:initClickEvent(handler(self, self.onCheckEvent))
        cell:addChild(item)
        table.insert(self._allListUi, item)
    else
        item = cell:getChildByTag(1000)
    end
    item:setTag(1000)
    item:setData(self._listData[index], index, self._selectId)
    local width, height = self:cellSizeForTable(view, idx)
    item:setPosition(cc.p(width / 2, height / 2))
    return cell
end

function WareSelectList:onCheckEvent(tag, sender, event_type)
    self._selectId = tag
    for k, v in ipairs(self._allListUi) do
        v:setSelectShow(self._selectId)
    end
end

function WareSelectList:dealData()
    local tab = {}
    if self._data and self._data.Reward then
        local tab_reward = uq.RewardType.parseRewards(self._data.Reward)
        for i,v in ipairs(tab_reward) do
            table.insert(tab, v:toEquipWidget())
        end
    end
    return tab
end

return WareSelectList