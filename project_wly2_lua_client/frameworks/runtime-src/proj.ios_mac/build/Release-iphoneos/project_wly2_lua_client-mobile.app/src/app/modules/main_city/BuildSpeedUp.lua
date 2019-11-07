local BuildSpeedUp = class("BuildSpeedUp", require('app.base.PopupBase'))

BuildSpeedUp.RESOURCE_FILENAME = "main_city/BuilderSpeedUp.csb"
BuildSpeedUp.RESOURCE_BINDING = {
    ["Text_4"]       = {["varname"] = "_txtTime"},
    ["Text_2"]       = {["varname"] = "_txtGold"},
    ["LoadingBar_1"] = {["varname"] = "_loadBar"},
    ["Panel_1"]      = {["varname"] = "_panelBg"},
    ["Text_3"]       = {["varname"] = "_txtFree"},
    ["Button_1"]     = {["varname"] = "_btnFinish",["events"] = {{["event"] = "touch",["method"] = "onFinish"}}},
}

function BuildSpeedUp:onCreate()
    BuildSpeedUp.super.onCreate(self)
    self:centerView()
    self:setLayerColor()
    self:parseView()
    self._isStrategy = false
    self._freeTime = 0
    self._dataList = {}

    self._eventTagRefresh = services.EVENT_NAMES.ON_MAIN_CITY_REFRESH_BUILD .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_MAIN_CITY_REFRESH_BUILD, handler(self, self.updateCityInfo), self._eventTagRefresh)

    self._eventTagStrtegy = services.EVENT_NAMES.ON_STRATRGY_UP_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_STRATRGY_UP_REFRESH, handler(self, self._onRefreshStrtegy), self._eventTagStrtegy)
end

function BuildSpeedUp:onExit()
    if self._timerField then
        self._timerField:dispose()
        self._timerField = nil
    end

    services:removeEventListenersByTag(self._eventTagRefresh)
    services:removeEventListenersByTag(self._eventTagStrtegy)
    BuildSpeedUp.super.onExit(self)
end

function BuildSpeedUp:_onRefreshStrtegy()
    if self._isStrategy and self._buildData and self._buildData.build_id then
        self:setData(self._buildData.build_id, true)
    end
end

function BuildSpeedUp:refreshTableView()
    if self._listView then
        self._listView:reloadData()
        return
    end

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

function BuildSpeedUp:tableCellTouched(view, cell)
end

function BuildSpeedUp:cellSizeForTable(view, idx)
    return 790, 137
end

function BuildSpeedUp:numberOfCellsInTableView(view)
    return #self._dataList
end

function BuildSpeedUp:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("main_city.BuildSpeedUpItem")
        cell_item:setTag(1000)
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end
    cell_item:setData(self._dataList[index], self._buildData.build_id, self._isStrategy)

    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))

    return cell
end

function BuildSpeedUp:setData(id, is_strategy)
    self._isStrategy = is_strategy
    if self._isStrategy then
        self._buildData = {build_id = id, cd_time = uq.cache.technology._endTime}
        self._freeTime = uq.cache.technology._freeTime
    else
        self._buildData = uq.cache.role.buildings[id]
        self._xmlData = StaticData['buildings']['CastleMap'][self._buildData.build_id]
        self._freeTime = self._xmlData.freeTime
    end
    self:refreshData()
    self:refreshTableView()
    self:refreshCdTime()
end

function BuildSpeedUp:refreshCdTime()
    local build_data = self._buildData
    local left_time = self._isStrategy and build_data.cd_time - uq.curServerSecond() or build_data.cd_time - os.time()
    local total_time = self._isStrategy and uq.cache.technology:getUpAllTime(build_data.build_id) or uq.cache.role:getBuildLevelCDTime(build_data.build_id)
    local free_time = math.floor(self._freeTime / 60)
    local function timer_end()
        uq.closeConfirmBox()
        if self._timerField then
            self._timerField:dispose()
            self._timerField = nil
        end
        self._txtTime:setString('00:00:00')
        self:disposeSelf()
    end

    local function timer_call(left_time)
        self._loadBar:setPercent(100 - left_time / total_time * 100)
        self._gold = self._isStrategy and uq.cache.technology:getStudyCostGold(left_time) or uq.cache.role:getLevelUpCDGold(left_time, self._freeTime)

        local time = left_time - self._freeTime
        time = time < 0 and 0 or time

        if self._gold <= 0 then
            self._txtFree:setString(string.format(StaticData['local_text']['label.build.levelup.freetime1'], free_time))
            self._txtGold:setString(StaticData['local_text']['ancient.city.shop.refresh.free'])
            self._txtGold:setTextColor(uq.parseColor('#34FF51'))
        else
            self._txtFree:setString(string.format(StaticData['local_text']['label.build.levelup.freetime'], time, free_time))
            self._txtGold:setString(self._gold)
            self._txtGold:setTextColor(uq.parseColor('#F5F5D8'))
        end
    end

    if left_time <= 0 then
        self._btnFinish:setEnabled(false)
        uq.ShaderEffect:addGrayButton(self._btnFinish)
        timer_call(0)
        timer_end()
        return
    end
    self._btnFinish:setEnabled(true)
    if self._timerField then
        self._timerField:setTime(left_time)
    else
        self._timerField = uq.ui.TimerField:create(self._txtTime, left_time, timer_end, nil, timer_call)
    end
end

function BuildSpeedUp:refreshData()
    self._dataList = {}
    for k, item in pairs(StaticData['material']) do
        if item.type == uq.config.constant.MATERIAL_TYPE.SPEED_UP then
            table.insert(self._dataList, item)
        end
    end
end

function BuildSpeedUp:onFinish(event)
    if event.name ~= "ended" then
        return
    end
    if self._isStrategy then
        uq.cache.technology:sendFinishMsg(nil, handler(self, self.disposeSelf))
    else
        uq.cache.role:finishCD(self._buildData.build_id)
    end
end

function BuildSpeedUp:updateCityInfo()
    if not self._isStrategy then
        self:setData(self._buildData.build_id)
    end
end

return BuildSpeedUp