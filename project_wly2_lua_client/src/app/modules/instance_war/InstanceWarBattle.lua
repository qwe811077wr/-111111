local InstanceWarBattle = class("InstanceWarBattle", require('app.base.PopupBase'))

InstanceWarBattle.RESOURCE_FILENAME = "instance_war/InstanceWarBattle.csb"
InstanceWarBattle.RESOURCE_BINDING = {
    ["Text_1"]   = {["varname"]= "_txtTitle"},
    ["Panel_1"]  = {["varname"] = "_panelBg"},
    ["Button_1"] = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onClose"}}},
}

function InstanceWarBattle:onCreate()
    InstanceWarBattle.super.onCreate(self)
    self:centerView()
    self:parseView()
    self:setLayerColor()
end

function InstanceWarBattle:onExit()
    if self._callBack then
        self._callBack()
    end
    InstanceWarBattle.super.onExit(self)
end

function InstanceWarBattle:setData(data, call_back)
    self._callBack = call_back
    self._battleData = data
    self:createList()

    local city_name = StaticData['instance_city'][data.city_id].name
    self._txtTitle:setString(city_name .. '之战')
end

function InstanceWarBattle:onClose(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

function InstanceWarBattle:createList()
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

function InstanceWarBattle:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
    local data = self._battleData.battle_list[index]

    local intance_id = uq.cache.instance_war:getCurInstanceId()
    local city_data = uq.cache.instance_war:getCityConfig(intance_id, self._battleData.city_id)
    uq.BattleReport:showBattleReport(data.report, handler(self, self.battleEnd), nil, nil, 'img/bg/battle/' .. city_data.battleBg)
end

function InstanceWarBattle:battleEnd(report)
    uq.BattleReport:showBattleResult(report)
end

function InstanceWarBattle:cellSizeForTable(view, idx)
    return 1057, 140
end

function InstanceWarBattle:numberOfCellsInTableView(view)
    return #self._battleData.battle_list
end

function InstanceWarBattle:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("instance_war.InstanceWarBattleItem")
        cell_item:setTag(1000)
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end
    cell_item:setData(self._battleData.battle_list[index], self._battleData)

    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))
    return cell
end


return InstanceWarBattle