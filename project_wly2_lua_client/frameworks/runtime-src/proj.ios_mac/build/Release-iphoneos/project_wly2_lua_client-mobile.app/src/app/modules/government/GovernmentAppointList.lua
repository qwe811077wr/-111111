local GovernmentAppointList = class("GovernmentAppointList", require('app.base.PopupBase'))

GovernmentAppointList.RESOURCE_FILENAME = "government/GovernmentAppointList.csb"
GovernmentAppointList.RESOURCE_BINDING = {
    ["Panel_1"]      = {["varname"] = "_panelList"},
}

function GovernmentAppointList:ctor(name, args)
    GovernmentAppointList.super.ctor(self, name, args)
    self._pos = args.pos or 0
    self._cityId = args.city_id or 0
end

function GovernmentAppointList:init()
    self._allApplyListData = {}
    self:centerView()
    self:setLayerColor()
    self:parseView()
    services:addEventListener(services.EVENT_NAMES.ON_CROP_APPOINT_NOTIFY, handler(self, self._onCropAppointNotify), "onCropAppointNotifyByList")
    local crop_info = uq.cache.crop._allMemberInfo
    for k, v in ipairs(crop_info) do
        if v.pos == uq.config.constant.GOVERNMENT_POS.MEMBER then
            table.insert(self._allApplyListData, v)
        end
    end
    self:initLayer()
end

function GovernmentAppointList:dispose()
    services:removeEventListenersByTag("onCropAppointNotifyByList")
    GovernmentAppointList.super.dispose(self)
end

function GovernmentAppointList:_onCropAppointNotify()
    self:disposeSelf()
end

function GovernmentAppointList:initLayer()
    local viewSize = self._panelList:getContentSize()
    self._listView = cc.TableView:create(cc.size(viewSize.width, viewSize.height))
    self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listView:setPosition(cc.p(0, 0))
    self._listView:setDelegate()
    self._listView:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._listView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._listView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._panelList:addChild(self._listView)
    self._listView:reloadData()
end

function GovernmentAppointList:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
    local info = self._allApplyListData[index]
    if info then
        network:sendPacket(Protocol.C_2_S_CROP_APPOINT, {role_id = info.id, pos = self._pos, city_id = self._cityId})
    end
end

function GovernmentAppointList:cellSizeForTable(view, idx)
    return 610, 100
end

function GovernmentAppointList:numberOfCellsInTableView(view)
    return #self._allApplyListData
end

function GovernmentAppointList:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("government.GovernmentAppointListCell")
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end

    cell_item:setTag(1000)
    cell_item:setData(self._allApplyListData[index], index)

    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))
    return cell
end

return GovernmentAppointList