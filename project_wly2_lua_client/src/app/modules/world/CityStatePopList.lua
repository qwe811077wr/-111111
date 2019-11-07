local CityStatePopList = class("CityStatePopList", require('app.base.PopupBase'))

CityStatePopList.RESOURCE_FILENAME = "world/CityStatePopList.csb"
CityStatePopList.RESOURCE_BINDING = {
    ["Panel_1"]          = {["varname"] = "_panelBuffs"},
}

function CityStatePopList:ctor(name, params)
    CityStatePopList.super.ctor(self, name, params)
    self._allData = {}
    self:centerView()
    self._battleNightTag = services.EVENT_NAMES.ON_BATTLE_NIGHT_CHANGE .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_BATTLE_NIGHT_CHANGE, handler(self, self.updateData), self._battleNightTag)
    self:initBuffsTableView()
end

function CityStatePopList:updateData()
    local tab_server_time = os.date("*t", uq.cache.server_data:getServerTime())
    if tab_server_time.hour < 8 then
        table.insert(self._allData, 1)
    end

    if uq.cache.world_war.world_enter_info.move_times == 0 then
        table.insert(self._allData, 2)
    end

    if uq.cache.world_war.world_enter_info.develop_count == 0 then
        table.insert(self._allData, 3)
    end
end

function CityStatePopList:initBuffsTableView()
    local size = self._panelBuffs:getContentSize()
    self._listView = cc.TableView:create(cc.size(size.width, size.height))
    self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listView:setPosition(cc.p(0, 0))
    self._listView:setDelegate()
    self._listView:registerScriptHandler(handler(self, self.cellSizeForTableContent), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listView:registerScriptHandler(handler(self, self.tableCellAtIndexContent), cc.TABLECELL_SIZE_AT_INDEX)
    self._listView:registerScriptHandler(handler(self, self.numberOfCellsInTableViewContent), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._panelBuffs:addChild(self._listView)
    self:updateData()
    self._listView:reloadData()
end

function CityStatePopList:cellSizeForTableContent(view, idx)
    return 500, 100
end

function CityStatePopList:numberOfCellsInTableViewContent(view)
    return #self._allData
end

function CityStatePopList:tableCellAtIndexContent(view, idx)
    local cell = view:dequeueCell()
    local index = self._allData[idx + 1]
    local buff_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        local width = 0
        buff_item = uq.createPanelOnly("world.CityStateCell")
        buff_item:setName("cell")
        width = buff_item:getContentSize().width
        buff_item:setPosition(cc.p((width + 10), 100))
        buff_item:setIndex(index)
        cell:addChild(buff_item, 1)
    else
        buff_item = cell:getChildByName("cell")
        buff_item:setIndex(index)
    end
    return cell
end

function CityStatePopList:dispose()
    services:removeEventListenersByTag(self._battleNightTag)
    CityStatePopList.super.dispose(self)
end

return CityStatePopList