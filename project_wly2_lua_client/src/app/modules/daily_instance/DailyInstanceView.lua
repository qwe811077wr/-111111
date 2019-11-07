local DailyInstanceView = class("DailyInstanceView", require("app.base.PopupBase"))
local DailyInstanceItem = require("app.modules.daily_instance.DailyInstanceItem")

DailyInstanceView.RESOURCE_FILENAME = "daily_instance/DailyInstanceView.csb"

DailyInstanceView.RESOURCE_BINDING  = {
    ["Panel_8"]                           = {["varname"] = "_panelTableView"},
    ["btn_close"]                         = {["varname"] = "_btnExit", ["events"] = {{["event"] = "touch",["method"] = "_onTouchExit",["sound_id"] = 0}}},
}

function DailyInstanceView:ctor(name, args)
    DailyInstanceView.super.ctor(self, name, args)
    self._info = args.info
    self._maxDifficulty = 0
    self._curDifficulty = 0
    self._infoArray = {}
    self._itemArray = {}
end

function DailyInstanceView:init()
    self:parseView()
    self:centerView()
    self:initTableView()
    self:initDialog()
end

function DailyInstanceView:initDialog()
    self._maxDifficulty = uq.cache.daily_activity:getMaxTabDifficulty(self._info.ident)
    if self._maxDifficulty == 0 then
        self._maxDifficulty = self._info.ident * 100 + 1
    else
        self._maxDifficulty = self._maxDifficulty + 1
    end

    for k,v in pairs(self._info.Troop) do
        v.max_difficulty = self._maxDifficulty
        v.indtance_id = self._info.ident
        table.insert(self._infoArray, v)
    end
    table.sort(self._infoArray, function(a, b)
        return a.ident < b.ident
    end)
    self._tableView:reloadData()
end

--攻击
function DailyInstanceView:_doAtkNPC(evt)
    network:sendPacket(Protocol.C_2_S_DAILY_INSTANCE_BATTLE, {group_id = self._info.ident, instance_id = self._curDifficulty})
    self:disposeSelf()
end

function DailyInstanceView:initTableView()
    local size = self._panelTableView:getContentSize()
    self._tableView = cc.TableView:create(cc.size(size.width, size.height))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
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

function DailyInstanceView:cellSizeForTable(view, idx)
    return 200, 382
end

function DailyInstanceView:numberOfCellsInTableView(view)
    return #self._infoArray
end

function DailyInstanceView:tableCellTouched(view, cell, touch)
    local touch_point = touch:getLocation()
    local index = cell:getIdx() + 1
    local item = cell:getChildByName("item")
    if item == nil then
        return
    end
    local info = item:getInfo()
    if info.ident > self._maxDifficulty then
        uq.fadeInfo(StaticData["local_text"]["daily.instance.des7"])
        return
    end
    local num = uq.cache.daily_activity:getDailyInstanceBattleNum(self._info.ident)
    num = self._info.count - num
    if num <= 0 then
        uq.fadeInfo(StaticData["local_text"]["daily.instance.des12"])
        return
    end
    if not item:checkTouched(touch_point) then
        return
    end
    self._curDifficulty = info.ident
    local enemy_data = info.Army
    local data = {
        enemy_data = enemy_data,
        embattle_type = uq.config.constant.TYPE_EMBATTLE.INSTANCE_EMBATTLE,
        confirm_callback = handler(self, self._doAtkNPC)
    }
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ARRANGED_BEFORE_WAR, data)
end

function DailyInstanceView:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx + 1
    if not cell then
        cell = cc.TableViewCell:new()
        local info = self._infoArray[index]
        local item = DailyInstanceItem:create()
        item:setPosition(cc.p(100, 191))
        cell:addChild(item)
        item:setInfo(info)
        item:setName("item")
        table.insert(self._itemArray, item)
    else
        local info = self._infoArray[index]
        local item = cell:getChildByName("item")
        if info ~= nil then
            item:setInfo(info)
        end
    end
    return cell
end

function DailyInstanceView:dispose()
    DailyInstanceView.super.dispose(self)
end

return DailyInstanceView
