local CropSignBattleReport = class("CropSignBattleReport", require("app.base.PopupBase"))

CropSignBattleReport.RESOURCE_FILENAME = "crop_sign/CropSignReport.csb"

CropSignBattleReport.RESOURCE_BINDING  = {
    ["Panel_1"]  = {["varname"] = "_panelTabView"},
    ["Button_1"] = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onTouchClose"}}},
}

function CropSignBattleReport:ctor(name, args)
    CropSignBattleReport.super.ctor(self, name, args)
    self._reportArray = {}
    self._id = args.id
end

function CropSignBattleReport:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self:initItemTabView()

    self._eventTag = Protocol.S_2_C_CROP_INSTANCE_LOG_LOAD .. tostring(self)
    network:addEventListener(Protocol.S_2_C_CROP_INSTANCE_LOG_LOAD, handler(self, self.onCropSignDataLoad), self._eventTag)

    network:sendPacket(Protocol.C_2_S_CROP_INSTANCE_LOG_LOAD, {id = 0})
end

function CropSignBattleReport:onCropSignDataLoad(evt)
    self._reportArray = {}
    for i = #evt.data.logs, 1, -1 do
        table.insert(self._reportArray, evt.data.logs[i])
    end
    self._itemTableView:reloadData()
end

function CropSignBattleReport:initItemTabView()
    local size = self._panelTabView:getContentSize()
    self._itemTableView = cc.TableView:create(cc.size(size.width,size.height))
    self._itemTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._itemTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._itemTableView:setPosition(cc.p(0, 0))
    self._itemTableView:setAnchorPoint(cc.p(0,0))
    self._itemTableView:setDelegate()
    self._panelTabView:addChild(self._itemTableView)

    self._itemTableView:registerScriptHandler(handler(self,self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._itemTableView:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._itemTableView:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._itemTableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._itemTableView:reloadData()
end

function CropSignBattleReport:cellSizeForTable(view, idx)
    return 1039, 125
end

function CropSignBattleReport:numberOfCellsInTableView(view)
    return #self._reportArray
end

function CropSignBattleReport:tableCellTouched(view, cell)
end

function CropSignBattleReport:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx + 1
    local cell_item = nil
    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("crop_sign.CropSignBattleReportItem")
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByName("item")
    end

    cell_item:setName("item")
    local info = self._reportArray[index]
    cell_item:setData(info)

    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))

    return cell
end

function CropSignBattleReport:dispose()
    network:removeEventListenerByTag(self._eventTag)
    CropSignBattleReport.super.dispose(self)
end

function CropSignBattleReport:onTouchClose(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

return CropSignBattleReport