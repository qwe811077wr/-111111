local ArenaDailyReward = class("ArenaDailyReward", require('app.modules.common.BaseViewWithHead'))

ArenaDailyReward.RESOURCE_FILENAME = "arena/ArenaReward.csb"
ArenaDailyReward.RESOURCE_BINDING = {
    ["Panel_1"]        = {["varname"] = "_panelBg"},
    ["Text_9"]         = {["varname"] = "_txtRank"},
    ["Text_9_0"]       = {["varname"] = "_txtHigestRank"},
    ["Button_2"]       = {["varname"] = "_btnReward", ["events"] = {{["event"] = "touch",["method"] = "onReward"}}},
    ["Button_1"]       = {["varname"] = "_btnReward", ["events"] = {{["event"] = "touch",["method"] = "onTouchExit"}}},
    ["Text_9_1"]       = {["varname"] = "_txtScore"},
}

function ArenaDailyReward:init()
    self._dataList = {}

    local coin_group = {
        uq.config.constant.COST_RES_TYPE.MONEY,
        uq.config.constant.COST_RES_TYPE.GOLDEN,
        uq.config.constant.COST_RES_TYPE.ARENA_SCORE
    }
    self:addShowCoinGroup(coin_group)
    self:centerView()
    self:parseView()
    self:createList()
    self:adaptBgSize()

    self:refreshDailyReward()
    self:refreshPage()
    services:addEventListener(services.EVENT_NAMES.ON_ARENA_DAILY_REWARD, handler(self, self.refreshDailyReward), 'onRefreshDailyReward' .. tostring(self))
end

function ArenaDailyReward:onReward(evt)
    if evt.name ~= "ended" then
        return
    end
    network:sendPacket(Protocol.C_2_S_ATHLETICS_DRAW_REWARD, {clear_time = 0})
end

function ArenaDailyReward:onTouchExit(evt)
    if evt.name ~= "ended" then
        return
    end
    self:disposeSelf()
end

function ArenaDailyReward:refreshDailyReward()
    self._allInfo = uq.cache.arena:getArenaInfo()
    self._dataList = self._allInfo.rewards
    table.sort(self._dataList, function(a, b)
        return a.clear_time > b.clear_time
    end)
    self._listView:reloadData()

    local can_get = false
    for k, v in ipairs(self._dataList) do
        if v.state == 0 then
            can_get = true
            break
        end
    end
    self._btnReward:setVisible(can_get)
end

function ArenaDailyReward:refreshPage()
    if not self._allInfo then
        return
    end
    local rank = uq.cache.arena:getRank()
    local rank_str = rank <= 0 and StaticData['local_text']['arena.out'] or rank
    self._txtRank:setString(rank_str)
    local best_rank = uq.cache.arena:getHighestRank()
    local best_rank_str = best_rank <= 0 and StaticData['local_text']['arena.out'] or best_rank
    self._txtHigestRank:setString(best_rank_str)
    local info = StaticData['arena_reward']
    if rank <= 0 then
        self._txtScore:setVisible(false)
        return
    end
    local cur_info = nil
    for k, v in ipairs(info) do
        if v.rewardRankLimit >= rank then
            cur_info = v
            break
        end
    end
    self._txtScore:setVisible(cur_info ~= nil)
    if cur_info then
        self._txtScore:setString(StaticData['local_text']['label.every.hour'] .. ' ' .. math.floor(cur_info.Score * 3600))
    end
end

function ArenaDailyReward:onCreate()
    ArenaDailyReward.super.onCreate(self)
end

function ArenaDailyReward:onExit()
    services:removeEventListenersByTag('onRefreshDailyReward' .. tostring(self))
    ArenaDailyReward.super:onExit()
end

function ArenaDailyReward:createList()
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

function ArenaDailyReward:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
end

function ArenaDailyReward:cellSizeForTable(view, idx)
    return 1039, 156
end

function ArenaDailyReward:numberOfCellsInTableView(view)
    return #self._dataList
end

function ArenaDailyReward:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new()
        cell_item = uq.createPanelOnly("arena.ArenaDailyRewardItem")
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByName("item")
    end

    cell_item:setName("item")
    cell_item:setData(self._dataList[index])
    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))
    return cell
end

return ArenaDailyReward