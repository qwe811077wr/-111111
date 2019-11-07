local WorldTrendsHeroes = class("WorldTrendsHeroes", require("app.base.TableViewBase"))

WorldTrendsHeroes.RESOURCE_FILENAME = "world/WorldTrendsHeroes.csb"

WorldTrendsHeroes.RESOURCE_BINDING  = {
    ["Panel_2/Panel_tabview"]       ={["varname"] = "_panelTabView"},
}
function WorldTrendsHeroes:ctor(name, args)
    WorldTrendsHeroes.super.ctor(self)
    self._dataArray = {}
    self._itemArray = {}
end

function WorldTrendsHeroes:init()
    self:parseView()
    self:initUi()
    self:initProtocal()
end

function WorldTrendsHeroes:initUi()
    self:initItemTabView()
    self:initData()
end

function WorldTrendsHeroes:update()

end

function WorldTrendsHeroes:initData()
    local war_task = StaticData['war_task'][uq.cache.world_war.world_enter_info.season_id]
    local battle_info =  uq.cache.world_war.battle_task_info.items
    for k, v in ipairs(battle_info) do
        v.xml = war_task.Stage[v.id]
        table.insert(self._dataArray, v)
    end
    self._itemTableView:reloadData()
end

function WorldTrendsHeroes:initItemTabView()
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
end

function WorldTrendsHeroes:cellSizeForTable(view, idx)
    return 1090, 322
end

function WorldTrendsHeroes:numberOfCellsInTableView(view)
    return #self._dataArray
end

function WorldTrendsHeroes:tableCellTouched(view, cell, touch)
end

function WorldTrendsHeroes:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx + 1
    local cell_item = nil
    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("world.WorldTrendsHeroesItem")
        cell:addChild(cell_item)
        cell_item:setPosition(cc.p(545, 161))
        table.insert(self._itemArray, cell_item)
    else
        cell_item = cell:getChildByName("item")
    end

    cell_item:setName("item")
    local info = self._dataArray[index]
    cell_item:setData(info)
    return cell
end

function WorldTrendsHeroes:onDrawTask(msg)
    for k, v in ipairs(self._itemArray) do
        local data = v:getData()
        if data.id == msg.id then
            v:updateDialog()
            local reward = v:getReward()
            uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, {rewards = reward})
        end
    end
end

function WorldTrendsHeroes:onTaskUpdate()
    local battle_info =  uq.cache.world_war.battle_task_info.items
    for k, v in ipairs(battle_info) do
        if v.id == uq.cache.world_war.battle_task_info.now_id - 1 or v.id == uq.cache.world_war.battle_task_info.now_id then
            local st_data = nil
            for k2, data in ipairs(self._dataArray) do
                if v.id == data.id then
                    data.begin_time = v.begin_time
                    data.end_time = v.end_time
                    st_data = data
                    break
                end
            end
            for k2, item in ipairs(self._itemArray) do
                local data = item:getData()
                if data.id == v.id then
                    item:setData(st_data)
                    break
                end
            end
        end
    end
end

function WorldTrendsHeroes:initProtocal()
    services:addEventListener(services.EVENT_NAMES.ON_BATTLE_DRAW_TASK, handler(self, self.onDrawTask), "onBattleTaskDrawByHeroes")
    services:addEventListener(services.EVENT_NAMES.ON_BATTLE_TASK_UPDATE, handler(self, self.onTaskUpdate), "onBattleTaskUpdateByHeroes")
end

function WorldTrendsHeroes:dispose()
    services:removeEventListenersByTag("onBattleTaskDrawByHeroes")
    services:removeEventListenersByTag("onBattleTaskUpdateByHeroes")
    WorldTrendsHeroes.super.dispose(self)
end

return WorldTrendsHeroes