local BuilderListModule = class('BuilderistModule', require("app.base.TableViewBase"))

BuilderListModule.RESOURCE_FILENAME = "main_city/BuilderListView.csb"
BuilderListModule.RESOURCE_BINDING = {
    ["node_builder1"]  = {["varname"] = "_nodeItem1"},
    ["node_builder2"]  = {["varname"] = "_nodeItem2"},
    ["strategy_node"]  = {["varname"] = "_nodeItem3"},
    ["Text_1_0"]       = {["varname"] = "_txtNum"},
    ["base_node"]      = {["varname"] = "_nodeBase"},
    ["Text_1_0_0"]     = {["varname"] = "_txtNum1"},
    ["Image_48"]       = {["varname"] = "_imgSwitch"},
    ["Button_switch1"] = {["varname"] = "_btnSwitch1",["events"] = {{["event"] = "touch",["method"] = "onSwitch"}}},
    ["Button_switch2"] = {["varname"] = "_btnSwitch2",["events"] = {{["event"] = "touch",["method"] = "onSwitch"}}},
    ["Button_switch3"] = {["varname"] = "_btnSwitch3",["events"] = {{["event"] = "touch",["method"] = "onSwitch"}}},
    ["node_army"]      = {["varname"] = "_nodeArmy"},
    ["node_builder"]   = {["varname"] = "_nodeBuilder"},
    ["Image_43"]       = {["varname"] = "_imgTitle"},
    ["Panel_9"]        = {["varname"] = "_panelBg"},
}

function BuilderListModule:ctor(name, args)
    BuilderListModule.super.ctor(self)
    self:init()
end

function BuilderListModule:init()
    self:parseView()
    self._dataList = {}
    self._eventTagRefresh = services.EVENT_NAMES.ON_MAIN_CITY_REFRESH_BUILD .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_MAIN_CITY_REFRESH_BUILD, handler(self, self.updateCityInfo), self._eventTagRefresh)

    self._eventTagUpRefresh = services.EVENT_NAMES.ON_STRATRGY_UP_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_STRATRGY_UP_REFRESH, handler(self, self.refreshStratrgy), self._eventTagUpRefresh)

    self:refreshPage()
    self._onTimeRefresh = "_onRefreshTime" .. tostring(self)
    uq.TimerProxy:addTimer(self._onTimeRefresh, handler(self, self._onRefreshTime), 1, -1)

    self._dataListArmy = {}
    self:createList()

    self._eventArmy = services.EVENT_NAMES.ON_ARMY_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_ARMY_REFRESH, handler(self, self.refreshArmy), self._eventArmy)

    self:refreshArmy()
    self:onSwitch({name = "ended", target = self._btnSwitch1})
end

function BuilderListModule:onExit()
    services:removeEventListenersByTag(self._eventTagUpRefresh)
    services:removeEventListenersByTag(self._eventTagRefresh)
    services:removeEventListenersByTag(self._eventArmy)
    if self._timerField1 then
        self._timerField1:dispose()
    end
    if self._timerField2 then
        self._timerField2:dispose()
    end
    uq.TimerProxy:removeTimer(self._onTimeRefresh)
    BuilderListModule.super.onExit(self)
end

function BuilderListModule:refreshPage()
    self._dataList = {}
    for k, item in pairs(uq.cache.role.buildings) do
        if item.cd_time > os.time() then
            table.insert(self._dataList, item)
        end
    end

    local available_num = uq.cache.role:getAvailableBuildNum()
    local build_num = uq.cache.role:getBuildNum()
    self._txtNum:setString(string.format('%d/%d', build_num - available_num, build_num))

    local node_using = {}
    local data_temp = {}
    for k, item in ipairs(self._dataList) do
        --使用中的队列
        if item.builder_index ~= nil then
            self:setItemData(self['_nodeItem' .. item.builder_index], item)
            node_using[self['_nodeItem' .. item.builder_index]:getTag()] = true
        else
            table.insert(data_temp, item)
        end
    end

    local index = 1
    for i = 1, 2 do
        if not node_using[i] then
            self:setItemData(self['_nodeItem' .. i], data_temp[index])
            index = index + 1
        end
    end
    self:refreshStratrgy()
end

function BuilderListModule:setItemData(node, data)
    local txt_tip = node:getChildByName('Text_time')
    local txt_tips = node:getChildByName('Text_time_0')
    local time_bar = node:getChildByName('LoadingBar_1')
    local txt_name = node:getChildByName('Text_name')
    local txt_level = node:getChildByName('Text_level')
    local btn_att = node:getChildByName('add_btn')
    local tag = node:getTag()
    if not data then
        if self['_timerField' .. tag] then
            self['_timerField' .. tag]:dispose()
            self['_timerField' .. tag] = nil
        end
        txt_tip:setString("")
        txt_tips:setString(string.format(StaticData['local_text']['label.build.levelup.freebuilder'], tag))
        time_bar:setPercent(0)
        txt_name:setString('')
        txt_level:setString('')
        btn_att:setVisible(false)
        return
    end
    uq.cache.role.buildings[data.build_id].builder_index = tag
    txt_tip:setString('00:00:00')
    txt_tips:setString("")
    btn_att:setVisible(true)
    local build_data = StaticData['buildings']['CastleMap'][data.build_id]
    txt_name:setString(build_data.name)
    txt_level:setString(StaticData['local_text']['label.common.level'] .. data.level)
    btn_att:addClickEventListenerWithSound(function()
        if data.cd_time <= uq.curServerSecond() then
            return
        end
        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.BUILD_SPEED_UP, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
        panel:setData(data.build_id)
    end)

    local left_time = data.cd_time - os.time()
    local total_time = uq.cache.role:getBuildLevelCDTime(data.build_id)

    local function timer_end()
        time_bar:setPercent(0)
        self:refreshPage()
    end

    local function timer_call(left_time)
        time_bar:setPercent(100 - left_time / total_time * 100)
    end
    if self['_timerField' .. tag] then
        self['_timerField' .. tag]:setTime(left_time)
    else
        self['_timerField' .. tag] = uq.ui.TimerField:create(txt_tip, left_time, timer_end, nil, timer_call)
    end
end

function BuilderListModule:updateCityInfo()
    self:refreshPage()
end

function BuilderListModule:refreshStratrgy()
    local node = self._nodeItem3
    local txt_tip = node:getChildByName('Text_time')
    local txt_tips = node:getChildByName('Text_time_0')
    local time_bar = node:getChildByName('LoadingBar_1')
    local txt_name = node:getChildByName('Text_name')
    local txt_level = node:getChildByName('Text_level')
    local btn_att = node:getChildByName('add_btn')
    btn_att:setVisible(uq.cache.technology._upId ~= 0)
    if uq.cache.technology._upId == 0 then
        txt_tip:setString("")
        txt_tips:setString(string.format(StaticData['local_text']['label.build.levelup.freebuilder'], 1))
        time_bar:setPercent(0)
        txt_name:setString('')
        txt_level:setString('')
        self._txtNum1:setString("0/1")
        return
    end
    local info = uq.cache.technology:getTechnologyInfoById(uq.cache.technology._upId)
    if not info or next(info) == nil then
        return
    end
    txt_level:setString(StaticData['local_text']['crop.main.title4']  .. info.level)
    self._txtNum1:setString("1/1")
    txt_tips:setString("")
    txt_name:setString(info.xml.name)
    self:refreshStratrgyLayer()
    btn_att:addClickEventListenerWithSound(function()
        if uq.cache.technology:getSurplusTime() <= 0 then
            return
        end
        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.BUILD_SPEED_UP, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
        panel:setData(uq.cache.technology._upId, true)
    end)
end

function BuilderListModule:refreshStratrgyLayer()
    local info = uq.cache.technology:getTechnologyInfoById(uq.cache.technology._upId)
    if not info or next(info) == nil then
        return
    end
    local all_time = uq.cache.technology:getUpAllTime(info.id, info.level)
    local time = uq.cache.technology:getSurplusTime()
    self._nodeItem3:getChildByName('LoadingBar_1'):setPercent(math.max(math.min((all_time - time) / all_time, 1), 0) * 100)
    self._nodeItem3:getChildByName('Text_time'):setString(uq.getTime(math.max(time, 0), uq.config.constant.TIME_TYPE.HHMMSS))
    self._nodeItem3:getChildByName('add_btn'):setVisible(time > 0)
end

function BuilderListModule:_onRefreshTime()
    if uq.cache.technology._upId == 0 then
        return
    end
    self:refreshStratrgyLayer()
end

function BuilderListModule:openAction()
    self._nodeBase:setPosition(cc.p(-150 + uq.getAdaptOffX(), 80))
    self._nodeBase:setOpacity(0)
    self._nodeBase:runAction(cc.Spawn:create(cc.FadeIn:create(0.2), cc.MoveBy:create(0.2, cc.p(150, 0))))
end

function BuilderListModule:onSwitch(event)
    if event.name ~= "ended" then
        return
    end
    local tag = event.target:getTag()
    self._nodeBuilder:setVisible(false)
    self._nodeItem3:setVisible(false)
    self._nodeArmy:setVisible(false)

    if tag == 1 then
        self._nodeBuilder:setVisible(true)
        self._imgTitle:loadTexture('img/main_city/s04_00235.png')
    elseif tag == 2 then
        self._imgTitle:loadTexture('img/main_city/s04_00234.png')
        self._nodeArmy:setVisible(true)
    elseif tag == 3 then
        self._nodeItem3:setVisible(true)
        self._imgTitle:loadTexture('img/main_city/s04_00235_1.png')
    end
    self._imgSwitch:setPositionY(event.target:getPositionY())
end

function BuilderListModule:refreshArmy()
    self._dataListArmy = {}
    self._armySpeed = uq.cache.role:getTotalArmySpeed()
    if self._armySpeed > 0 then
        self._dataListArmy = uq.cache.generals:getGeneralArmyList()
    end
    self._listView:reloadData()
end

function BuilderListModule:showAction()
    self:runAction(cc.MoveBy:create(0.2, cc.p(220, 0)))
end

function BuilderListModule:createList()
    local view_size = self._panelBg:getContentSize()
    self._listView = cc.TableView:create(cc.size(view_size.width, view_size.height))
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

function BuilderListModule:tableCellTouched(view, cell)
end

function BuilderListModule:cellSizeForTable(view, idx)
    return 345, 42
end

function BuilderListModule:numberOfCellsInTableView(view)
    return #self._dataListArmy
end

function BuilderListModule:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("main_city.ArmyDraftItem")
        cell_item:setTag(1000)
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end
    cell_item:setData(self._dataListArmy[index], self._armySpeed)

    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))

    return cell
end

return BuilderListModule