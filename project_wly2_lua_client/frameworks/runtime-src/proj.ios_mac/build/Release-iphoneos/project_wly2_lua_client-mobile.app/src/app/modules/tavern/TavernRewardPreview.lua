local TavernRewardPreview = class("TavernRewardPreview", require('app.base.PopupBase'))

TavernRewardPreview.RESOURCE_FILENAME = "tavern/TavernRewardPreview.csb"
TavernRewardPreview.RESOURCE_BINDING = {
    ["Node_1"]                        = {["varname"] = "_node"},
    ["Node_1/item_pnl"]               = {["varname"] = "_pnlItem"},
    ["Node_1/Button_1"]               = {["varname"] = "_btn1"},
    ["Node_1/Button_1_0"]             = {["varname"] = "_btn2"},
    ["Node_1/Button_1_1"]             = {["varname"] = "_btn3"},
    ["Node_1/Panel_11"]               = {["varname"] = "_pnlShow1"},
    ["Node_1/Panel_11_0"]             = {["varname"] = "_pnlShow2"},
    ["Node_1/Panel_11_1"]             = {["varname"] = "_pnlShow3"},
}

function TavernRewardPreview:onCreate()
    TavernRewardPreview.super.onCreate(self)
    self._oneRowNum = 7
    self._allData = {}
    self._dataList = {}
    self:setLayerColor(0.4)
    self:centerView()
    self:parseView()
    self._selectIndex = 1
    self._type ={
        [1] = uq.config.constant.COST_RES_TYPE.GENERALS,
        [2] = uq.config.constant.COST_RES_TYPE.SPIRIT,
        [3] = uq.config.constant.COST_RES_TYPE.MATERIAL,
    }
    self:createList()
    for i = 1, 3 do
        self["_btn" .. i]:addClickEventListenerWithSound(function()
            if self._selectIndex == i then
                return
            end
            self._selectIndex = i
            self:loadData()
        end)
    end
end

function TavernRewardPreview:setData(index)
    self._index = index
    local xml_data = StaticData['appoint_item'][self._index].Businessman
    for _, v in pairs(xml_data) do
        for _, iv in pairs(v.Item) do
            local info = uq.RewardType:create(iv.itemId):toEquipWidget()
            if info and next(info) ~= nil then
                if not self._allData[info.type] then
                   self._allData[info.type] = {}
                end
                local grade_info = StaticData.getCostInfo(info.type, info.id)
                if grade_info and grade_info.grade then
                    info.grade = grade_info.grade
                    table.insert(self._allData[info.type], info)
                end
            end
        end
    end
    for k, v in pairs(self._allData) do
        table.sort(v, function (a, b)
           return a.grade > b.grade
        end)
    end
    self:loadData()
end

function TavernRewardPreview:loadData()
    self._dataList = self._allData[self._type[self._selectIndex]] or {}
    self._listView:reloadData()
    self:refreshShow()
end

function TavernRewardPreview:refreshShow()
    for i = 1, 3 do
        self["_pnlShow" .. i]:getChildByName("Image_20"):setVisible(self._selectIndex ~= i)
        self["_pnlShow" .. i]:getChildByName("Image_21"):setVisible(self._selectIndex == i)
        self["_pnlShow" .. i]:getChildByName("Text_10"):setVisible(self._selectIndex ~= i)
        self["_pnlShow" .. i]:getChildByName("Text_10_0"):setVisible(self._selectIndex == i)
    end
end

function TavernRewardPreview:createList()
    local viewSize = self._pnlItem:getContentSize()
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
    self._pnlItem:addChild(self._listView)
end

function TavernRewardPreview:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
end

function TavernRewardPreview:cellSizeForTable(view, idx)
    return 930, 140
end

function TavernRewardPreview:numberOfCellsInTableView(view)
    if self._dataList then
        return math.ceil(#self._dataList / self._oneRowNum)
    end
    return 0
end

function TavernRewardPreview:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cellItem = nil
    if not cell then
        cell = cc.TableViewCell:new()
        cellItem = uq.createPanelOnly("tavern.TavernRewardReviewItem")
        cell:addChild(cellItem)
    else
        cellItem = cell:getChildByTag(1000)
    end
    cellItem:setTag(1000)

    local item_data = {}
    for i = 1, self._oneRowNum do
        if self._dataList[(index - 1) * self._oneRowNum + i] then
            table.insert(item_data, self._dataList[(index - 1) * self._oneRowNum + i])
        end
    end
    cellItem:setData(item_data)

    local width, height = self:cellSizeForTable(view, idx)
    cellItem:setPosition(cc.p(width / 2, height / 2))

    return cell
end

return TavernRewardPreview