local BuildOfficerMain = class("BuildOfficerMain", require('app.modules.common.BaseViewWithHead'))

BuildOfficerMain.RESOURCE_FILENAME = "build_officer/BuildOfficerMain.csb"
BuildOfficerMain.RESOURCE_BINDING = {
    ["Panel_1"]      = {["varname"] = "_panelBg"},
}

function BuildOfficerMain:ctor(name, params)
    BuildOfficerMain.super.ctor(self, name, params)
    self:setTitle(uq.config.constant.MODULE_ID.BUILD_OFFICER)
    self:centerView()
    self:parseView()
    self:setRuleId(uq.config.constant.MODULE_RULE_ID.BUILD_OFFICE)
    self:adaptBgSize()
end

function BuildOfficerMain:onCreate()
    BuildOfficerMain.super.onCreate(self)

    self._dataList = {}
    self:createList()
    self:refreshPage()
end

function BuildOfficerMain:refreshPage()
    self._dataList = StaticData['officer'].Building
    self._listView:reloadData()
end

function BuildOfficerMain:onExit()
    BuildOfficerMain.super.onExit(self)
end

function BuildOfficerMain:createList()
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

function BuildOfficerMain:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
end

function BuildOfficerMain:cellSizeForTable(view, idx)
    return 1244, 136
end

function BuildOfficerMain:numberOfCellsInTableView(view)
    return #self._dataList
end

function BuildOfficerMain:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("build_officer.BuildOfficerItem")
        cell_item:setTag(1000)
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end
    cell:setLocalZOrder(index)
    cell_item:setData(self._dataList[index])

    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))

    return cell
end

return BuildOfficerMain

