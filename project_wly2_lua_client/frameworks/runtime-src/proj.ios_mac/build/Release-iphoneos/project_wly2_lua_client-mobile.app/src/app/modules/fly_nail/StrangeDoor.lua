local StrangeDoor = class("StrangeDoor", require("app.base.PopupBase"))
local StrangeDoorItem = require("app.modules.fly_nail.StrangeDoorItem")

StrangeDoor.RESOURCE_FILENAME = "fly_nail/StrangeDoor.csb"

StrangeDoor.RESOURCE_BINDING  = {
    ["Panel_1/Panel_tabview"]               ={["varname"] = "_panelTableView"},
    ["Panel_1/Node_effect"]                 ={["varname"] = "_nodeEffect"},
    ["Panel_1/btn_close"]                   ={["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "_onTouchExit"}}},
}

function StrangeDoor:ctor(name, args)
    StrangeDoor.super.ctor(self, name, args)
    self._dataArray = {}
    self._cellItemArray = {}
end

function StrangeDoor:init()
    self:parseView()
    self:centerView()
    self:initTableView()
    self:initData()
    services:addEventListener(services.EVENT_NAMES.ON_FLYNAIL_LEVEL_UP, handler(self, self._onFlyNailLevelUp), '_onFlyNailLevelUpByDoor')
end

function StrangeDoor:_onFlyNailLevelUp(msg)
    for k, v in ipairs(self._cellItemArray) do
        if v:getInfo().data.id == msg.data.id then
            v:setInfo(self._dataArray[msg.data.id])
            break
        end
    end
    self._nodeEffect:removeAllChildren()
    uq:addEffectByNode(self._nodeEffect, 900162, 1, true)
end

function StrangeDoor:initData()
    local level = uq.cache.role:level()
    for i = 1, 8 do
        local info = {}
        info.xml = StaticData['eight_diagrams'].EightDiagram[i]
        if info.xml.level <= level then
            info.unlock = true
        else
            info.unlock = false
        end
        info.data = nil
        table.insert(self._dataArray, info)
    end
    local info = uq.cache.fly_nail.flyNailInfo
    for k, v in pairs(info.items) do
        self._dataArray[v.id].data = v
    end
    self._tableView:reloadData()
end

function StrangeDoor:initTableView()
    local size = self._panelTableView:getContentSize()
    self._tableView = cc.TableView:create(cc.size(size.width, size.height))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setAnchorPoint(cc.p(0, 0))
    self._tableView:setDelegate()
    self._panelTableView:addChild(self._tableView)

    self._tableView:registerScriptHandler(handler(self,self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
end

function StrangeDoor:cellSizeForTable(view, idx)
    return 1018, 150
end

function StrangeDoor:numberOfCellsInTableView(view)
    return #self._dataArray
end

function StrangeDoor:tableCellTouched(view, cell,touch)
end

function StrangeDoor:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx + 1
    local info = self._dataArray[index]
    if not cell then
        cell = cc.TableViewCell:new()
        local door_item = StrangeDoorItem:create({info = info})
        cell:addChild(door_item)
        door_item:setName("item")
        door_item:setPosition(cc.p(door_item:getContentSize().width * 0.5, 75))
        table.insert(self._cellItemArray, door_item)
    else
        local door_item = cell:getChildByName("item")
        door_item:setInfo(info)
    end
    return cell
end

function StrangeDoor:dispose()
    services:removeEventListenersByTag("_onFlyNailLevelUpByDoor")
    StrangeDoor.super.dispose(self)
end

return StrangeDoor
