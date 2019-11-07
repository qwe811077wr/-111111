local InstanceWarSweep = class("InstanceWarSweep", require('app.base.PopupBase'))

InstanceWarSweep.RESOURCE_FILENAME = 'instance/NpcSweep.csb'
InstanceWarSweep.RESOURCE_BINDING = {
    ["sweep_btn_0"]        = {["varname"] = "_btnSweepOne",["events"] = {{["event"] = "touch",["method"] = "onSweep"}}},
    ["sweep_btn"]          = {["varname"] = "_btnSweepFive",["events"] = {{["event"] = "touch",["method"] = "onSweep"}}},
    ["Button_1"]           = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "closePanel"}}},
    ["Button_1_0"]         = {["varname"] = "_btnAddMillitory"},
    ["cost_order_txt_atk"] = {["varname"] = "_txtCostOrderAtk"},
    ["Panel_3"]            = {["varname"] = "_panelList"},
    ["img_icon"]           = {["varname"] = "_imgIcon"},
    ["Node_1"]             = {["varname"] = "_nodeItems"},
}

function InstanceWarSweep:ctor(name, params)
    InstanceWarSweep.super.ctor(self, name, params)
    self._instanceId = params.instance_id
    self._dataList = params.items
    self._sweepCount = params.sweep_count
end

function InstanceWarSweep:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()

    self._instanceData = StaticData['instance_war'][self._instanceId]
    self._curMapData = StaticData.load('campaigns/' .. self._instanceData.fileId).Map[self._instanceId]
    self:createList()
    self:refreshMillitory()

    self._btnAddMillitory:setVisible(false)
    self._nodeItems:setVisible(false)
end

function InstanceWarSweep:onSweep(event)
    if event.name == "ended" then
        self._sweepCount = event.target:getTag()
        local cost_config = string.split(self._curMapData.cost, ';')
        local cost_num = tonumber(cost_config[2]) * self._sweepCount
        local cost_type = tonumber(cost_config[1])
        local info = StaticData.getCostInfo(cost_type)
        if not uq.cache.instance_war:checkRes(cost_type, cost_num) then
            uq.fadeInfo(string.format(StaticData['local_text']['label.res.tips.less'], info.name))
            return
        end

        local packet = {campaign_id = self._instanceId, wipe_count = self._sweepCount}
        network:sendPacket(Protocol.C_2_S_CAMPAIGN_WIPE, packet)
        self:disposeSelf()
    end
end

function InstanceWarSweep:closePanel(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

function InstanceWarSweep:refreshMillitory()
    local num = uq.cache.instance_war:getRes(self._costType)
    local cost_config = string.split(self._curMapData.cost, ';')
    local color = tonumber(cost_config[2]) <= num and '56FF49' or 'F30B0B'
    self._txtCostOrderAtk:setHTMLText(string.format("<font color='#%s'>%d</font> / %d", color, tonumber(cost_config[2]), num))
end

function InstanceWarSweep:onExit()
    InstanceWarSweep.super.onExit(self)
end

function InstanceWarSweep:createList()
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

function InstanceWarSweep:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
end

function InstanceWarSweep:cellSizeForTable(view, idx)
    return 1033, 122
end

function InstanceWarSweep:numberOfCellsInTableView(view)
    return #self._dataList
end

function InstanceWarSweep:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("instance.NpcSweepItem")
        cell_item:setTag(1000)
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end
    cell_item:setData(self._dataList[index], index)

    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))

    return cell
end

return InstanceWarSweep