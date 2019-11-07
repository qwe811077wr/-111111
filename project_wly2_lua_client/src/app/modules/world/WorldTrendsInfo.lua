local WorldTrendsInfo = class("WorldTrendsInfo", require("app.base.PopupBase"))
local EquipItem = require("app.modules.common.EquipItem")

WorldTrendsInfo.RESOURCE_FILENAME = "world/WorldTrendsInfo.csb"

WorldTrendsInfo.RESOURCE_BINDING  = {
    ["city_des1_0"]          ={["varname"] = "_recieveLabel"},
    ["Panel_tabview"]        ={["varname"] = "_panelTabView"},
    ["btn_reward"]           = {["varname"] = "_btnReward",["events"] = {{["event"] = "touch",["method"] = "onBtnReward"}}},
}

WorldTrendsInfo.STATE = {
    ST_INIT = 0,
    ST_FINISHED = 1,
    ST_TIMEOUT = 2,
}

function WorldTrendsInfo:ctor(name, args)
    WorldTrendsInfo.super.ctor(self,name,args)
    self._info = args.info or nil
    self._dataArray = {}
end

function WorldTrendsInfo:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self:initUi()
    services:addEventListener(services.EVENT_NAMES.ON_BATTLE_DRAW_TASK, handler(self, self.onDrawTask), "onBattleTaskDrawByInfo")
end

function WorldTrendsInfo:onDrawTask()
    local reward_state = uq.cache.world_war:checkTaskReward(self._info.id)
    local reward = self:getRankReward()
    self._btnReward:setVisible(self._info.id < uq.cache.world_war.battle_task_info.now_id and not reward_state and reward ~= nil)
    if reward_state then
        self._recieveLabel:setString(StaticData["local_text"]["world.trends.des10"])
    elseif reward == nil then
        self._recieveLabel:setString(StaticData["local_text"]["world.trends.des3"])
    else
        self._recieveLabel:setString(StaticData["local_text"]["world.trends.des11"])
    end
end

function WorldTrendsInfo:initUi()
    self:initItemTabView()
    self:initDialog()
end

function WorldTrendsInfo:onBtnReward(event)
    if event.name ~= "ended" then
        return
    end
    network:sendPacket(Protocol.C_2_S_NATION_BATTLE_DRAW_TASK, {task_id = self._info.id})
end

function WorldTrendsInfo:getRankReward()
    local info = nil
    for k, v in ipairs(self._info.crops) do
        if v.id == uq.cache.role.cropsId then
            info = v
            break
        end
    end
    if not info then
        return nil
    end
    local rank_reward = string.split(self._info.xml.reward2, "%")
    local reward = rank_reward[info.rank] or nil
    return reward
end

function WorldTrendsInfo:initDialog()
    local reward_state = uq.cache.world_war:checkTaskReward(self._info.id)
    local reward = self:getRankReward()
    self._btnReward:setVisible(self._info.id < uq.cache.world_war.battle_task_info.now_id and not reward_state and reward ~= nil)
    if reward_state then
        self._recieveLabel:setString(StaticData["local_text"]["world.trends.des10"])
    elseif reward == nil then
        self._recieveLabel:setString(StaticData["local_text"]["world.trends.des3"])
    else
        self._recieveLabel:setString(StaticData["local_text"]["world.trends.des11"])
    end
    local rank_reward = string.split(self._info.xml.reward2, "%")
    for k, v in ipairs(rank_reward) do
        local data = self:getCrops(k)
        data.reward = v
        table.insert(self._dataArray, data)
    end
    self._itemTableView:reloadData()
end

function WorldTrendsInfo:getCrops(rank)
    for k, v in ipairs(self._info.crops) do
        if v.rank == rank then
            return v
        end
    end
    return {rank = rank, name = ""}
end

function WorldTrendsInfo:initItemTabView()
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

function WorldTrendsInfo:cellSizeForTable(view, idx)
    return 1034, 100
end

function WorldTrendsInfo:numberOfCellsInTableView(view)
    return #self._dataArray
end

function WorldTrendsInfo:tableCellTouched(view, cell, touch)
    local index = cell:getIdx() + 1
    local info = self._dataArray[index]
end

function WorldTrendsInfo:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx + 1
    local cell_item = nil
    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("world.WorldTrendsInfoItem")
        cell_item:setPosition(cc.p(517, 50))
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByName("item")
    end

    cell_item:setName("item")
    local info = self._dataArray[index]
    cell_item:setData(info)
    return cell
end

function WorldTrendsInfo:dispose()
    services:removeEventListenersByTag("onBattleTaskDrawByInfo")
    WorldTrendsInfo.super.dispose(self)
end

return WorldTrendsInfo