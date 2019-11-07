local GrowthFundView = class("GrowthFundView", require("app.modules.common.BaseViewWithHead"))
local GrowthFundViewItem = require("app.modules.activity.GrowthFundItem")

GrowthFundView.RESOURCE_FILENAME = "activity/GrowthFund.csb"
GrowthFundView.RESOURCE_BINDING = {
    ["Node_1"]                  = {["varname"] = "_nodeRight"},
    ["Image_3"]                 = {["varname"] = "_imgBought"},
    ["Panel_1"]                 = {["varname"] = "_panelBuy"},
    ["Panel_1/Text_6"]          = {["varname"] = "_txtTime"},
    ["Panel_1/Button_2"]        = {["varname"] = "_btnBuy"},
    ["Panel_10"]                = {["varname"] = "_panelTableView"},
    ["Button_1"]                = {["varname"] = "_btnGet"},
    ["Text_1_0"]                = {["varname"] = "_txtLvl"},
}

function GrowthFundView:ctor(name, params)
    GrowthFundView.super.ctor(self, name, params)
    self:initPage()
end

function GrowthFundView:initPage()
    self._cellArray = {}
    self._selectIndex = 1
    self:setTitle(uq.config.constant.MODULE_ID.GROWTH_FUND)
    self._allGrowthFundInfo = StaticData['growthFund'].GrowthFund
    self._baseInfo = StaticData['growthFund'].Info
    self._txtLvl:setString(uq.cache.role:level())
    self:centerView()
    self:adaptBgSize()
    self:initTabView()
    self._tableView:reloadData()
    self:showAction()
end

function GrowthFundView:initTabView()
    local size = self._panelTableView:getContentSize()
    self._tableView = cc.TableView:create(cc.size(size.width,size.height))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setAnchorPoint(cc.p(0,0))
    self._tableView:setDelegate()
    self._panelTableView:addChild(self._tableView)

    self._tableView:registerScriptHandler(handler(self,self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
end

function GrowthFundView:tableCellTouched(view, cell, touch)
    local touch_point = touch:getLocation()
    local index = cell:getIdx() + 1
    for _,v in ipairs(self._cellArray) do
        v:setSelectImgVisible(false)
    end
    self._selectIndex = index
    local item = cell:getChildByName("item")
    item:setSelectImgVisible(true)
end

function GrowthFundView:cellSizeForTable(view, idx)
    return 700, 165
end

function GrowthFundView:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx + 1
    if not cell then
        cell = cc.TableViewCell:new()
        local info = self._allGrowthFundInfo[index]
        local item = nil
        if info ~= nil then
            item = GrowthFundViewItem:create({info = info})
            item:setIndex(index)
            table.insert(self._cellArray, item)
            item:setPosition(cc.p(350, 82.5))
            cell:addChild(item)
            item:setName("item")
            if index == self._selectIndex then
                item:setSelectImgVisible(true)
            end
        end
    else
        local info = self._allGrowthFundInfo[index]
        local item = cell:getChildByName("item")
        item:setIndex(index)
        if info ~= nil then
            if item:getIndex() == self._selectIndex then
                item:setSelectImgVisible(true)
            else
                item:setSelectImgVisible(false)
            end
            item:setInfo(info)
            item:setVisible(true)
        end
    end
    return cell
end

function GrowthFundView:numberOfCellsInTableView(view, idx)
    return #self._allGrowthFundInfo
end

function GrowthFundView:dispose()
    GrowthFundView.super.dispose(self)
end

function GrowthFundView:showAction()
    for _, v in ipairs(self._cellArray) do
        v:showAction()
    end
end

return GrowthFundView