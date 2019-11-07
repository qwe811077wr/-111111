local BuildOfficerSelect = class("BuildOfficerSelect", require('app.base.PopupBase'))

BuildOfficerSelect.RESOURCE_FILENAME = "build_officer/BuildOfficerSelect.csb"
BuildOfficerSelect.RESOURCE_BINDING = {
    ["Panel_1"]    = {["varname"] = "_panelBg"},
    ["Button_1"]   = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onTouchClose"}}},
    ["Image_2"]    = {["varname"] = "_imgSort",["events"] = {{["event"] = "touch",["method"] = "onSort"}}},
    ["Button_2"]   = {["varname"] = "_btnProperty",["events"] = {{["event"] = "touch",["method"] = "onSwitch"}}},
    ["Button_2_0"] = {["varname"] = "_btnLevel",["events"] = {{["event"] = "touch",["method"] = "onSwitch"}}},
    ["Text_2"]     = {["varname"] = "_txtSort"},
}

function BuildOfficerSelect:ctor(name, params)
    BuildOfficerSelect.super.ctor(self, name, params)
    self:centerView()
    self:parseView()
    self:setLayerColor()
end

function BuildOfficerSelect:onCreate()
    BuildOfficerSelect.super.onCreate(self)

    self._dataList = {}
    self:createList()
    self:refreshSwitch()

    self._refreshEventTag = services.EVENT_NAMES.ON_BUILD_OFFICER_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_BUILD_OFFICER_REFRESH, handler(self, self.onEventRefresh), self._refreshEventTag)
end

function BuildOfficerSelect:onExit()
    uq.cache.role.switch_property = true
    services:removeEventListenersByTag(self._refreshEventTag)
    BuildOfficerSelect.super.onExit(self)
end

function BuildOfficerSelect:onSwitch(event)
    if event.name ~= 'ended' then
        return
    end
    uq.cache.role.switch_property = not uq.cache.role.switch_property
    self:refreshSwitch()
    self:refreshValue()
end

function BuildOfficerSelect:refreshSwitch()
    self._btnProperty:setEnabled(not uq.cache.role.switch_property)
    local color = self._btnProperty:isEnabled() and '#4B7688' or '#FFFFFF'
    self._btnProperty:setTitleColor(uq.parseColor(color))

    self._btnLevel:setEnabled(uq.cache.role.switch_property)
    local color = self._btnLevel:isEnabled() and '#4B7688' or '#FFFFFF'
    self._btnLevel:setTitleColor(uq.parseColor(color))
end

function BuildOfficerSelect:refreshValue()
    for i = 1, #self._dataList do
        local cell = self._listView:cellAtIndex(i - 1)
        if cell and cell:getChildByTag(1000) then
            cell:getChildByTag(1000):refreshValue()
        end
    end
end

function BuildOfficerSelect:setData(build_data, temp_id, index)
    self._selectGeneralTempId = temp_id
    self._buildData = build_data
    self._sortPropertyType = self._buildData.officerAttrType
    self._posIndex = index
    self._isDown = true
    self:refreshSort()
end

function BuildOfficerSelect:onEventRefresh()
    self:refreshSort()
end

function BuildOfficerSelect:refreshSort()
    self._dataList = uq.cache.generals:getBuildOfficeSelect(self._buildData.castleMapType) --获取可用列表
    table.sort(self._dataList, function(item1, item2)
        local value1 = nil
        local value2 = nil
        if uq.cache.role.switch_property then
            value1 = uq.cache.generals:getGeneralBuildOfficerPropertyAdd(item1.id)
            value2 = uq.cache.generals:getGeneralBuildOfficerPropertyAdd(item2.id)
        else
            value1 = uq.cache.generals:getGeneralBuildOfficerLevelAdd(item1.id)
            value2 = uq.cache.generals:getGeneralBuildOfficerLevelAdd(item2.id)
        end
        if self._isDown then
            --属性值
            return value1[self._sortPropertyType][1] > value2[self._sortPropertyType][1]
        else
            --等级
            return value1[self._sortPropertyType][1] < value2[self._sortPropertyType][1]
        end
    end)
    self._listView:reloadData()

    local xml_data = StaticData['officer'].OfficerAttrType[self._sortPropertyType]
    if self._isDown then
        self._txtSort:setString(string.format('%s\\' .. StaticData['local_text']['label.buildofficer.down'], xml_data.name))
    else
        self._txtSort:setString(string.format('%s\\' .. StaticData['local_text']['label.buildofficer.up'], xml_data.name))
    end
end

function BuildOfficerSelect:createList()
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

function BuildOfficerSelect:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
end

function BuildOfficerSelect:cellSizeForTable(view, idx)
    return 1181, 121
end

function BuildOfficerSelect:numberOfCellsInTableView(view)
    return #self._dataList
end

function BuildOfficerSelect:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("build_officer.BuildOfficerSelectItem")
        cell_item:setTag(1000)
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end

    cell_item:setData(self._dataList[index], self._selectGeneralTempId, self._buildData, self._posIndex, handler(self, self.selectCallback))

    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))

    return cell
end

function BuildOfficerSelect:onTouchClose(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

function BuildOfficerSelect:onSort(event)
    if event.name ~= 'ended' then
        return
    end

    local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.BUILD_OFFICER_SORT, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
    panel:setData(self._sortPropertyType, self._isDown, handler(self, self.sortCallback))
end

function BuildOfficerSelect:selectCallback()
    self:disposeSelf()
end

function BuildOfficerSelect:sortCallback(property_type, is_down)
    self._sortPropertyType = property_type
    self._isDown = is_down
    self:refreshSort()
end

return BuildOfficerSelect

