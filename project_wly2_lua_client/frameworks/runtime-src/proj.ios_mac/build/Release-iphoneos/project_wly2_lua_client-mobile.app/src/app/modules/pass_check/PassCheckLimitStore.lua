local PassCheckLimitStore = class("PassCheckLimitStore", require('app.base.ChildViewBase'))

PassCheckLimitStore.RESOURCE_FILENAME = "pass_check/PassCheckLimitStore.csb"
PassCheckLimitStore.RESOURCE_BINDING = {
    ["Node_1"]        = {["varname"] = "_nodeBase"},
    ["time_txt"]      = {["varname"] = "_txtLeftTime"},
    ["Panel_1"]       = {["varname"] = "_panel"},
    ["Button_15"]     = {["varname"] = "_btn1",["events"] = {{["event"] = "touch",["method"] = "onShop"}}},
    ["Button_16"]     = {["varname"] = "_btn2",["events"] = {{["event"] = "touch",["method"] = "onReward"}}},
}
function PassCheckLimitStore:ctor(name, params)
    PassCheckLimitStore.super.ctor(self, name, params)
end

function PassCheckLimitStore:onCreate()
    PassCheckLimitStore.super.onCreate(self)
    self:parseView()

    self._dataList = {}
    self._allUi = {}
    self._info = uq.cache.pass_check._passCardInfo
    self._xmlData = StaticData['pass']['Info'][self._info.season_id]['Store']
    self._cacheData = uq.cache.pass_check._passShop
    self._shopData = {}
    self._rewardData = {}
    self._btn = {}
    self:selectShopData()
    self:initTableView()
    self:_refreshEndTime()
    self._onTimerTag = "_onTimerTag" .. tostring(self)
    uq.TimerProxy:addTimer(self._onTimerTag, handler(self, self._refreshEndTime), 1, -1)
    network:sendPacket(Protocol.C_2_S_PASSCARD_STONE_LOAD)

    self._eventTag = services.EVENT_NAMES.ON_PASS_CHECK_LIMIT_SHOP_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_PASS_CHECK_LIMIT_SHOP_REFRESH, handler(self, self.refreshLayer), self._eventTag)

    self._eventTagRefresh = services.EVENT_NAMES.ON_PASS_CHECK_LIMIT_SHOP_BUY .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_PASS_CHECK_LIMIT_SHOP_BUY, handler(self, self.refreshBoxs), self._eventTagRefresh)

    self._eventTagLevel = services.EVENT_NAMES.ON_REFRESH_PASS_CHECK_INFO .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_REFRESH_PASS_CHECK_INFO, handler(self, self.refreshLayer), self._eventTagLevel)
end

function PassCheckLimitStore:_refreshEndTime()
    self._txtLeftTime:setString(uq.cache.pass_check:getSurplusTimeString())
end

function PassCheckLimitStore:selectShopData()
    for i, v in ipairs(self._xmlData) do
        if v.type == 1 then
            table.insert(self._shopData, v)
        else
            table.insert(self._rewardData, v)
        end
    end
    self._dataList = self._shopData
    self:refreshBtn(1)
end

function PassCheckLimitStore:refreshBtn(idx)
    for i = 1, 2 do
        local btn = self["_btn" .. i]
        local is_limit = i == idx
        btn:setEnabled(not is_limit)
        local color = is_limit and"FFFFFF" or "#3F9AC7"
        btn:getChildByName("name_txt"):setTextColor(uq.parseColor(color))
    end
end

function PassCheckLimitStore:initTableView()
    local size = self._panel:getContentSize()
    self._tableView = cc.TableView:create(cc.size(size.width,size.height))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setAnchorPoint(cc.p(0,0))
    self._tableView:setDelegate()
    self._tableView:registerScriptHandler(handler(self,self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:reloadData()
    self._panel:addChild(self._tableView)
end

function PassCheckLimitStore:refreshLayer()
    self._tableView:reloadData()
end

function PassCheckLimitStore:tableCellTouched(view, cell, touch)
    local index = cell:getIdx() + 1
end

function PassCheckLimitStore:cellSizeForTable(view, idx)
    return 1090, 230
end

function PassCheckLimitStore:numberOfCellsInTableView(view)
    return math.ceil(#self._dataList / 3)
end

function PassCheckLimitStore:tableCellAtIndex(view, idx)
    local index = idx * 3 + 1
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
        for i = 0, 2 do
            local info = self._dataList[index] or {}
            local cell_item = uq.createPanelOnly("pass_check.PassCheckLimitStoreCell")
            cell:addChild(cell_item)
            self._allUi[index] = cell_item
            cell_item:setPosition(cc.p(360 * i + 190, 115))
            cell_item:setName("item" .. i)
            if info and next(info) ~= nil then
                cell_item:setData(info)
            else
                cell_item:setVisible(false)
            end
            index = index + 1
        end
    else
        for i = 0, 2 do
            local info = self._dataList[index] or {}
            local cell_item = cell:getChildByName("item" .. i)
            if cell_item then
                if info and next(info) ~= nil then
                    cell_item:setData(info)
                    cell_item:setVisible(true)
                else
                    cell_item:setVisible(false)
                end
            end
            index = index + 1
        end
    end
    return cell
end

function PassCheckLimitStore:refreshBoxs(evt)
    for k, v in pairs(self._allUi) do
        v:refreshData()
    end
    local data = evt.data
    local xml = self._xmlData[data.id] or {}
    if not xml or not xml.buy then
        return
    end
    local tab = uq.RewardType.new(xml.buy):toEquipWidget()
    if not tab or next(tab) == nil then
        return
    end
    local tab_reward = {}
    for i = 1, data.num do
        table.insert(tab_reward, tab)
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, {rewards = tab_reward})
end

function PassCheckLimitStore:onShop(event)
    if event.name ~= "ended" then
        return
    end
    self._dataList = self._shopData
    self:refreshBtn(1)
    self._tableView:reloadData()
end

function PassCheckLimitStore:onReward(event)
    if event.name ~= "ended" then
        return
    end
    self._dataList = self._rewardData
    self:refreshBtn(2)
    self._tableView:reloadData()
end

function PassCheckLimitStore:showAction()
    uq.intoAction(self._nodeBase)
    for k, v in pairs(self._allUi) do
        v:showAction()
    end
end

function PassCheckLimitStore:onExit()
    uq.TimerProxy:removeTimer(self._onTimerTag)
    services:removeEventListenersByTag(self._eventTag)
    services:removeEventListenersByTag(self._eventTagRefresh)
    services:removeEventListenersByTag(self._eventTagLevel)
    PassCheckLimitStore.super.onExit(self)
end

return PassCheckLimitStore