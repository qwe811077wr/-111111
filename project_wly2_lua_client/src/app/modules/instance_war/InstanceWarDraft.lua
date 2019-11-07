local InstanceWarDraft = class("InstanceWarDraft", require('app.base.PopupBase'))

InstanceWarDraft.RESOURCE_FILENAME = "instance_war/InstanceWarDraft.csb"
InstanceWarDraft.RESOURCE_BINDING = {
    ["Panel_1"]    = {["varname"] = "_panelBg"},
    ["Button_2"]   = {["varname"] = "_btnComfirm",["events"] = {{["event"] = "touch",["method"] = "onConfirm"}}},
    ["Button_2_0"] = {["varname"] = "_btnCancle",["events"] = {{["event"] = "touch",["method"] = "onConfirm"}}},
    ["Button_1"]   = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onConfirm"}}},
    ["Text_2_0"]   = {["varname"] = "_txtDraft"},
}

function InstanceWarDraft:onCreate()
    InstanceWarDraft.super.onCreate(self)
    self:centerView()
    self:parseView()
    self:setLayerColor()
    self._generalCurrentSolder = {}
    self._generals = {}
    self:createList()
end

function InstanceWarDraft:setData(city_id)
    self._generals = uq.cache.instance_war:getCityGeneral(city_id)

    for k, item in ipairs(self._generals) do
        self._generalCurrentSolder[item.id] = item.current_soldiers
    end
    self._listView:reloadData()
    local city_data = uq.cache.instance_war:getCityData(city_id)
    self._soldiers = city_data.soldier
    self:refreshSolder()
end

function InstanceWarDraft:setCurrentSoldier(general_id, soldier)
    self._generalCurrentSolder[general_id] = soldier
end

function InstanceWarDraft:refreshSolder()
    local left_soldier = self._soldiers
    for k, item in ipairs(self._generals) do
        left_soldier = left_soldier + item.current_soldiers - self._generalCurrentSolder[item.id]
    end
    self._txtDraft:setString(left_soldier)
end

function InstanceWarDraft:getLeftSoldier()
    local left_soldier = self._soldiers
    for k, item in ipairs(self._generals) do
        left_soldier = left_soldier + item.current_soldiers - self._generalCurrentSolder[item.id]
    end
    return left_soldier
end

function InstanceWarDraft:onConfirm(event)
    if event.name ~= "ended" then
        return
    end

    local generals_dec = {}
    local generals_add = {}

    for k, item in ipairs(self._generals) do
        local data = {
            general_id = item.id,
            soldier = self._generalCurrentSolder[item.id]
        }
        if item.current_soldiers < self._generalCurrentSolder[item.id] then
            table.insert(generals_add, data)
        else
            table.insert(generals_dec, data)
        end
    end

    for k, item in ipairs(generals_add) do
        table.insert(generals_dec, item)
    end

    network:sendPacket(Protocol.C_2_S_CAMPAIGN_SOLDIER_SUPPLY, {count = #generals_dec, generals = generals_dec})

    self:disposeSelf()
end

function InstanceWarDraft:createList()
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

function InstanceWarDraft:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
end

function InstanceWarDraft:cellSizeForTable(view, idx)
    return 972, 155
end

function InstanceWarDraft:numberOfCellsInTableView(view)
    return math.ceil(#self._generals / 2)
end

function InstanceWarDraft:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()

    local cell_item1 = nil
    local cell_item2 = nil
    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item1 = uq.createPanelOnly("instance_war.InstanceWarDraftItem")
        cell_item1:setTag(1000)
        cell:addChild(cell_item1)

        if index < self:numberOfCellsInTableView() or #self._generals % 2 == 0 then
            --创建列表项
            cell_item2 = uq.createPanelOnly("instance_war.InstanceWarDraftItem")
            cell_item2:setTag(1001)
            cell:addChild(cell_item2)
        end
    else
        cell_item1 = cell:getChildByTag(1000)
        cell_item2 = cell:getChildByTag(1001)
    end
    cell_item1:setData(self._generals[idx * 2 + 1], self, self._generalCurrentSolder)
    local width, height = self:cellSizeForTable(view, idx)
    cell_item1:setPosition(cc.p(235, height / 2))

    if cell_item2 then
        cell_item2:setData(self._generals[idx * 2 + 2], self, self._generalCurrentSolder)
        local width, height = self:cellSizeForTable(view, idx)
        cell_item2:setPosition(cc.p(width / 2 + 255, height / 2))
    end

    return cell
end

return InstanceWarDraft