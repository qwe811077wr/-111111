local NPCGuideModule = class("NPCGuideModule", require('app.base.PopupBase'))

NPCGuideModule.RESOURCE_FILENAME = "instance/GuideView.csb"
NPCGuideModule.RESOURCE_BINDING = {
    ["Button_1"]    = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onBtnClose"}}},
    ["Panel_3"]     = {["varname"] = "_panelList"},
    ["Button_2"]    = {["varname"] = "_btnCountry"},
    ["Node_4"]      = {["varname"] = "_nodeCountry"},
    ["Panel_5"]     = {["varname"] = "_pnlCountry"},
    ["Panel_power"] = {["varname"] = "_panelPowerItem"},
    ["bg_1_img"]    = {["varname"] = "_imgBg1"},
    ["bg_2_img"]    = {["varname"] = "_imgBg2"},
    ["bg_3_img"]    = {["varname"] = "_imgBg3"},
    ["bg_4_img"]    = {["varname"] = "_imgBg4"},
}

function NPCGuideModule:ctor(name, params)
    NPCGuideModule.super.ctor(self, name, params)
    self._reports = {}
    self._countryId = uq.cache.role.country_id
    self._allData = {}
    self._allPowerData = {}
    for i = 1, 4 do
        self._allData[i] = {}
        self._allPowerData[i] = {}
    end
    self._dataList = {}
end

function NPCGuideModule:init()
    self:parseView()
    self:centerView()
    self:setLayerColor(0)
    self._countryStr = {
        StaticData['local_text']['label.power.wei'],
        StaticData['local_text']['label.power.shu'],
        StaticData['local_text']['label.power.wu'],
    }
    self._nodeCountry:setVisible(false)
    self._btnCountry:addClickEventListenerWithSound(function()
        self._nodeCountry:setVisible(true)
    end)
    self._pnlCountry:addClickEventListenerWithSound(function()
        self._nodeCountry:setVisible(false)
    end)
    for i = 1, 3 do
        self["_imgBg" .. i]:getChildByName("bg_txt"):setString(self._countryStr[i])
        self["_imgBg" .. i]:addClickEventListenerWithSound(function()
            self._countryId = i
            self:refreshLayer()
            self._nodeCountry:setVisible(false)
        end)
    end
    self:createList()
    services:addEventListener(services.EVENT_NAMES.ON_STRATEGY_INFO, handler(self, self._onGuideInfo), '_onInstanceGuideInfo')
end

function NPCGuideModule:refreshLayer()
    self._dataList = self._allData[self._countryId] or {}
    self._listView:reloadData()
    self._panelPowerItem:removeAllChildren()
    local power_data = self._allPowerData[self._countryId] or {}
    local pos_y = self._panelPowerItem:getContentSize().height
    for k, v in ipairs(power_data) do
        local cell_item = uq.createPanelOnly("instance.NpcGuideItem")
        cell_item:setData(v)
        cell_item:setPosition(cc.p(1003 * 0.5, pos_y - 55))
        self._panelPowerItem:addChild(cell_item)
        pos_y = pos_y - 100
    end
end

function NPCGuideModule:_onGuideInfo(msg)
    local data = msg.data
    local tab_items = data.items or {}
    if not tab_items or next(tab_items) == nil then
        return
    end
    table.sort(tab_items, function (a, b)
        if a.type == b.type then
            if a.type == 0 then
                return a.report_id > b.report_id
            end
            return a.force_value > b.force_value
        end
        return a.type < b.type
    end)
    for i, v in pairs(tab_items) do
        if v.type == 0 then
            table.insert(self._allData[v.country_id], v)
        else
            table.insert(self._allPowerData[v.country_id], v)
        end
    end
    self:refreshLayer()
end

function NPCGuideModule:dealData(id)
    return {}
end

function NPCGuideModule:createList()
    local view_size = self._panelList:getContentSize()
    self._listView = cc.TableView:create(cc.size(view_size.width, view_size.height))
    self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listView:setPosition(cc.p(0, 0))
    self._listView:setDelegate()
    self._listView:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._listView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._listView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._listView:reloadData()
    self._panelList:addChild(self._listView)
end

function NPCGuideModule:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
end

function NPCGuideModule:cellSizeForTable(view, idx)
    return 1003, 112
end

function NPCGuideModule:numberOfCellsInTableView(view)
    return #self._dataList
end

function NPCGuideModule:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("instance.NpcGuideItem")
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

function NPCGuideModule:onExit()
    services:removeEventListenersByTag('_onInstanceGuideInfo')
    NPCGuideModule.super:onExit()
end

function NPCGuideModule:onBtnClose(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

return NPCGuideModule