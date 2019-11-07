local DailyInstanceModule = class("DailyInstanceModule", require("app.base.ModuleBase"))
local EquipItem = require("app.modules.common.EquipItem")

DailyInstanceModule.RESOURCE_FILENAME = "daily_instance/DailyInstanceMain.csb"

DailyInstanceModule.RESOURCE_BINDING  = {
    ["Node_1"]                            = {["varname"] = "_nodeBase"},
    ["Panel_3"]                           = {["varname"] = "_panelTableView"},
    ["img_bg"]                            = {["varname"] = "_iconImg"},
    ["Text_4"]                            = {["varname"] = "_countLabel"},
    ["label_progress"]                    = {["varname"] = "_progressLabel"},
    ["label_progress_name"]               = {["varname"] = "_instanceMameLabel"},
    ["general_des"]                       = {["varname"] = "_generalDesLabel"},
    ["general_type"]                      = {["varname"] = "_generalTypeLabel"},
    ["Node_tab"]                          = {["varname"] = "_nodeMenu"},
    ["Button_3"]                          = {["varname"] = "_btnBattle",["events"] = {{["event"] = "touch",["method"] = "_onBtnBattle"}}},
    ["Button_rank"]                       = {["varname"] = "_btnRank",["events"] = {{["event"] = "touch",["method"] = "_onBtnRank"}}},
}

function DailyInstanceModule:ctor(name, args)
    DailyInstanceModule.super.ctor(self, name, args)
    self._tabIndex = 1
    self._difficulty = 101  --默认副本难度
    self._battleCount = 0
    self._curTabInfoArray = {}
    self._curTabItemArray = {}
    self._curDifficultyInfo = nil
    self._curInstanceInfo = nil
    self._curRewardArray = {}
    self._allUi = {}
end

function DailyInstanceModule:init()
    local top_ui = uq.ui.CommonHeaderUI:create()
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.MONEY,  true))
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.GOLDEN,  true))
    top_ui:setTitle(uq.config.constant.MODULE_ID.DAILY_INSTANCE)
    self._topUI = top_ui
    self._view:addChild(top_ui:getNode())

    self:parseView()
    self:centerView()
    self:initData()
    self:initTableView()
    self:addTabBtns()
    self:initProtocolData()
    self:adaptBgSize()
    self:showAction()
end

function DailyInstanceModule:initProtocolData()
    services:addEventListener(services.EVENT_NAMES.ON_DAILY_INSTANCE_LOAD, handler(self, self._onDailyInstanceLoad), '_onDailyInstanceLoadByDailyInstance')
    services:addEventListener(services.EVENT_NAMES.ON_DAILY_INSTANCE_SWEEP, handler(self, self._onDailyInstanceSweep), '_onDailyInstanceSweepByDailyInstance')
    network:addEventListener(Protocol.S_2_C_DAILY_INSTANCE_BATTLE, handler(self, self._onDailyInstanceBattle), '_onDailyInstanceBattleByDailyInstance')
    network:sendPacket(Protocol.C_2_S_DAILY_INSTANCE_LOAD, {})
end

function DailyInstanceModule:_onDailyInstanceSweep(evt)
    local num = uq.cache.daily_activity:getDailyInstanceBattleNum(self._tabIndex)
    self._battleCount = self._curInstanceInfo.count - num
    if self._battleCount < 0 then
        self._battleCount = 0
    end
    self._countLabel:setString(string.format(StaticData['local_text']['daily.instance.des'], self._battleCount, self._curInstanceInfo.count))
    local xml_difficulty = self:getTroopInfo(evt.data.instance_id)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, {rewards = xml_difficulty.showReward})
end

function DailyInstanceModule:_onDailyInstanceBattle(evt)
    uq.BattleReport:getInstance():showBattleReport(evt.data.report_id, handler(self, self._onPlayReportEnd))
end

function DailyInstanceModule:_onPlayReportEnd(report)
    if not report then
        return
    end
    uq.BattleReport:getInstance():showBattleResult(report)
    network:sendPacket(Protocol.C_2_S_DAILY_INSTANCE_LOAD, {})
end

function DailyInstanceModule:_onDailyInstanceLoad()
    self:updateTabDialog()
end

function DailyInstanceModule:removeProtocolData()
    services:removeEventListenersByTag("_onDailyInstanceLoadByDailyInstance")
    services:removeEventListenersByTag("_onDailyInstanceSweepByDailyInstance")
    network:removeEventListenerByTag("_onDailyInstanceBattleByDailyInstance")
end

function DailyInstanceModule:onTabChanged(sender)
    local index = sender["userData"].ident
    if self._tabIndex == index then
        return
    end
    self._tabIndex = index
    for k, v in pairs(self._curTabItemArray) do
        v:setEnabled(true)
    end
    sender:setEnabled(false)
    self:updateTabDialog()
    self:showAction()
end

function DailyInstanceModule:addTabBtns()
    local tab_item = self._nodeMenu:getChildByName("Button_1")
    local posx, posy = tab_item:getPosition()
    tab_item:removeSelf()
    local select_item = nil
    for k, v in ipairs(self._curTabInfoArray) do
        local item = tab_item:clone()
        self._nodeMenu:addChild(item)
        item["userData"] = v
        item:getChildByName("Text_1"):setString(v.name)
        item:setPosition(posx, posy)
        item:setTouchEnabled(true)
        item:addClickEventListenerWithSound(handler(self, self.onTabChanged))
        if k == self._tabIndex then
            select_item = item
            item:setEnabled(false)
        end
        posy = posy - item:getContentSize().height - 5
        self._curTabItemArray[v.ident] = item
    end
end

function DailyInstanceModule:updateTabDialog()
    local item = self._curTabItemArray[self._tabIndex]
    if not item then
        return
    end
    self._curInstanceInfo = item["userData"]
    self._difficulty = uq.cache.daily_activity:getMaxTabDifficulty(self._tabIndex)
    if self._difficulty == 0 then
        self._difficulty = self._tabIndex * 100 + 1
    else
        if self:getTroopInfo(self._difficulty + 1) ~= nil then
            self._difficulty = self._difficulty + 1
        end
    end
    local num = uq.cache.daily_activity:getDailyInstanceBattleNum(self._tabIndex)
    self._iconImg:loadTexture('img/daily_instance/' .. self._curInstanceInfo.mapImage)
    self._battleCount = self._curInstanceInfo.count - num
    if self._battleCount < 0 then
        self._battleCount = 0
    end
    self._countLabel:setString(string.format(StaticData['local_text']['daily.instance.des'], self._battleCount, self._curInstanceInfo.count))
    self._instanceMameLabel:setString(self._curInstanceInfo.name)
    self:updateDialog()
end

function DailyInstanceModule:getTroopInfo(ident)
    local troop_array = {}
    if self._curInstanceInfo == nil then
        return nil
    end
    for k,v in pairs(self._curInstanceInfo.Troop) do
        table.insert(troop_array, v)
    end
    table.sort(troop_array, function(a, b)
        return a.ident < b.ident
    end)
    for k, v in pairs(troop_array) do
        if tonumber(v.ident) == ident then
            return v
        end
    end
    return nil
end

function DailyInstanceModule:updateDialog()
    self._curDifficultyInfo = self:getTroopInfo(self._difficulty)
    self._progressLabel:setString(self._curDifficultyInfo.name)
    self._curRewardArray = uq.RewardType.parseRewards(self._curDifficultyInfo.showReward)
    self._tableView:reloadData()
end

function DailyInstanceModule:_onBtnRank(event)
    if event.name ~= "ended" then
        return
    end
    uq.fadeInfo(StaticData["local_text"]["daily.instance.des5"])
end

function DailyInstanceModule:_onBtnBattle(event)
    if event.name ~= "ended" then
        return
    end
    if self._battleCount <= 0 then
        uq.fadeInfo(StaticData["local_text"]["daily.instance.des12"])
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.DAILY_INSTANCE_VIEW, {info = self._curInstanceInfo})
end

function DailyInstanceModule:initData()
    for k, v in ipairs(StaticData['daily_instance']) do
        table.insert(self._curTabInfoArray, v)
    end
    table.sort(self._curTabInfoArray, function(a, b)
        return a.ident < b.ident
    end)
end

function DailyInstanceModule:initTableView()
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

function DailyInstanceModule:cellSizeForTable(view, idx)
    return 112, 118
end

function DailyInstanceModule:numberOfCellsInTableView(view)
    return #self._curRewardArray
end

function DailyInstanceModule:tableCellTouched(view, cell, touch)
    local touch_point = touch:getLocation()
    local index = cell:getIdx() + 1
    local item = cell:getChildByName("item")
    if item == nil then
        return
    end
    local info = item:getEquipInfo()
    uq.showItemTips(info)
end

function DailyInstanceModule:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx + 1
    if not cell then
        cell = cc.TableViewCell:new()
        local info = self._curRewardArray[index]
        local euqip_item = EquipItem:create({info = info:toEquipWidget()})
        euqip_item:setPosition(cc.p(56, 59))
        euqip_item:setScale(0.9)
        cell:addChild(euqip_item)
        euqip_item:setName("item")
        table.insert(self._allUi, euqip_item)
    else
        local info = self._curRewardArray[index]
        local euqip_item = cell:getChildByName("item")
        if info ~= nil then
            euqip_item:setInfo(info:toEquipWidget())
        end
    end
    return cell
end

function DailyInstanceModule:showAction()
    uq.intoAction(self._nodeBase)
    for i, v in ipairs(self._allUi) do
        v:showAction()
    end
end

function DailyInstanceModule:dispose()
    if self._topUI then
        self._topUI:dispose()
    end
    self:removeProtocolData()
    DailyInstanceModule.super.dispose(self)
end

return DailyInstanceModule
