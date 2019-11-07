local WorldTrendsReward = class("WorldTrendsReward", require("app.base.TableViewBase"))

WorldTrendsReward.RESOURCE_FILENAME = "world/WorldTrendsRewards.csb"

WorldTrendsReward.RESOURCE_BINDING  = {
    ["Panel_2/Panel_tabview"]       ={["varname"] = "_panelTabView"},
    ["Panel_2/Image_1"]             ={["varname"] = "_boxImg1"},
    ["Panel_2/Image_2"]             ={["varname"] = "_boxImg2"},
    ["Panel_2/Image_3"]             ={["varname"] = "_boxImg3"},
    ["Panel_2/box_1"]               ={["varname"] = "_boxLabel1"},
    ["Panel_2/box_2"]               ={["varname"] = "_boxLabel2"},
    ["Panel_2/box_3"]               ={["varname"] = "_boxLabel3"},
    ["Panel_2/text_time"]           ={["varname"] = "_timeLabel"},
}

function WorldTrendsReward:ctor(name, args)
    WorldTrendsReward.super.ctor(self)
end

function WorldTrendsReward:init()
    self:parseView()
    self._boxArray = {self._boxImg1, self._boxImg2, self._boxImg3}
    self._boxNameArray = {self._boxLabel1, self._boxLabel2, self._boxLabel3}
    self._curSeanInfo = nil
    self._dataArray = {}
    self:initUi()
end

function WorldTrendsReward:update()

end

function WorldTrendsReward:initUi()
    self._curSeanInfo = StaticData['war_season'].WarSeason[uq.cache.world_war.world_enter_info.season_id]
    local time = self._curSeanInfo.duration * 24 * 3600 - (uq.cache.server_data:getServerTime() - uq.cache.world_war.world_enter_info.season_begin_time)
    self._timeLabel:setString(self:parseTime(time))
    local reward_items = uq.RewardType.parseRewards(self._curSeanInfo.box)
    self:initItemTabView()
    for k, v in ipairs(reward_items) do
        local info = v:data()
        self._boxNameArray[k]:setString(info.name)
        self._boxArray[k]["info"] = v:toEquipWidget()
        self._boxArray[k]:setTouchEnabled(true)
        self._boxArray[k]:addClickEventListenerWithSound(function(sender)
            local info = sender["info"]
            uq.showItemTips(info)
        end)
    end
    self._dataArray = self._curSeanInfo.settle
    self._itemTableView:reloadData()
end

function WorldTrendsReward:parseTime(seconds)
    local day = math.floor(seconds / 24 / 3600)
    seconds = seconds % (24 * 3600)
    local hours = math.floor(seconds / 3600)
    seconds = seconds % 3600
    local minutes = math.floor(seconds / 60)
    return day .. StaticData['local_text']['label.common.day'] .. hours .. StaticData['local_text']['label.train.time.hour']
        .. minutes .. StaticData['local_text']['label.train.time.minute']
end

function WorldTrendsReward:initItemTabView()
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

function WorldTrendsReward:cellSizeForTable(view, idx)
    return 1080, 107
end

function WorldTrendsReward:numberOfCellsInTableView(view)
    return #self._dataArray
end

function WorldTrendsReward:tableCellTouched(view, cell, touch)
    local index = cell:getIdx() + 1
    local info = self._dataArray[index]
end

function WorldTrendsReward:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx + 1
    local cell_item = nil
    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("world.WorldTrendsRewardItem")
        cell:addChild(cell_item)
        cell_item:setPosition(cc.p(545, 56))
    else
        cell_item = cell:getChildByName("item")
    end

    cell_item:setName("item")
    local info = self._dataArray[index]
    cell_item:setData(info)
    return cell
end

function WorldTrendsReward:dispose()
    WorldTrendsReward.super.dispose(self)
end

return WorldTrendsReward