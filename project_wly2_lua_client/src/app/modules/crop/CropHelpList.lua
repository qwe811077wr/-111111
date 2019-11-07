local  CropHelpList = class("CropHelpList", require('app.base.PopupBase'))
CropHelpList.RESOURCE_FILENAME = "crop/CropHelpList.csb"
CropHelpList.RESOURCE_BINDING = {
    ["Panel_1"]  = {["varname"] = "_panelBg"},
    ["Button_1"] = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onClosePanel"}}},
}

function CropHelpList:onCreate()
    CropHelpList.super.onCreate(self)
    self:centerView()
    self:parseView()
    self:setLayerColor(0.4)

    self._dataList = {}

    self:createList()

    network:addEventListener(Protocol.S_2_C_CROP_LOAD_HELP_LOG, handler(self, self.onLogDataRet), '_onLogDataRet')
    network:sendPacket(Protocol.C_2_S_CROP_LOAD_HELP_LOG)
end

function CropHelpList:onExit()
    network:removeEventListenerByTag('_onLogDataRet')
    CropHelpList.super:onExit()
end

function CropHelpList:createList()
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

function CropHelpList:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
end

function CropHelpList:cellSizeForTable(view, idx)
    return 550, 88
end

function CropHelpList:numberOfCellsInTableView(view)
    return #self._dataList
end

function CropHelpList:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("crop.CropHelpListItem")
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

function CropHelpList:onClosePanel(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

function CropHelpList:onLogDataRet(evt)
    self._dataList = evt.data.help_log
    self._listView:reloadData()
end

return CropHelpList