local GeneralShop = class("GeneralShop", require("app.base.TableViewBase"))
local GeneralShopItem = require("app.modules.ancient_city.GeneralShopItem")
local GeneralShopTabItem = require("app.modules.ancient_city.GeneralShopTabItem")

GeneralShop.RESOURCE_FILENAME = "ancient_city/AncientCityShop.csb"

GeneralShop.RESOURCE_BINDING  = {
    ["btn_reward"]          ={["varname"] = "_btnRefresh",["events"] = {{["event"] = "touch",["method"] = "onBtnRefresh"}}},
    ["Panel_tabview"]       ={["varname"] = "_panelTabView"},
    ["Panel_center"]        ={["varname"] = "_panelCenter"},
    ["label_time"]          ={["varname"] = "_timeLabel"},
    ["label_remainder"]     ={["varname"] = "_reminderLabel"},
    ["label_name_0"]        ={["varname"] = "_refreshCostLabel"},
    ["label_name_0_0"]      ={["varname"] = "_labelFull"},
    ["Panel_tap"]           ={["varname"] = "_panelTabView2"},
    ["Panel_4"]             ={["varname"] = "_panelRefresh"},
    ["Image_cost"]          ={["varname"] = "_refreshCostImg"},

}

function GeneralShop:ctor(name, args)
    GeneralShop.super.ctor(self)
    self._curItemInfoArray = {}
    self._curTotalInfoArray = {}
    self._curTabInfoArray = {}
    self._allUi = {}
    self._curTableViewInfo = nil
    self._curTabIndex = args.sub_index or 1
    self._totalRefreshNum = 0
    self._freeRefreshNum = 0
    self._refreshBuyNum = 0
    self._buyNum = 0
    self._closeTime = 0
    self._tradeReciveNum = 0
    self._shopTime = StaticData['ancient_info'][1].storeDuration or 0
end

function GeneralShop:init()
    self:parseView()
    self:initItemTabView()
    self:initProtocal()
    self:initBtnListener()
    self:showAction()
end

function GeneralShop:initTimer()
    if self._closeTime <= 0 then
        return
    end
    if self._cdTimer then
        self._cdTimer:setTime(self._closeTime)
    else
        self._cdTimer = uq.ui.TimerField:create(self._timeLabel, self._closeTime, handler(self, self._cdTimeOver),
        handler(self, self.normalFormat), nil, true)
    end
end

function GeneralShop:normalFormat(t)
    return string.format(StaticData['local_text']['ancient.city.shop.des6'], math.floor(t / 3600), math.floor(t % 3600 / 60), t % 60)
end

function GeneralShop:_cdTimeOver()
    self._closeTime = 0
end

function GeneralShop:initUi()
    self._curTabInfoArray = {}
    self._curTotalInfoArray = {}
    for k,v in ipairs(self._openTab) do
        if tonumber(v) <= uq.cache.role:level() then
            local tab_info = {}
            tab_info.name = self._tabTxt[k]
            tab_info.index = k
            table.insert(self._curTabInfoArray,tab_info)
            if k == uq.config.constant.GENERAL_SHOP.ATHLETICS_SHOP then --竞技场刷新数据获取
                network:sendPacket(Protocol.C_2_S_ENTER_ATHLETICS)
            end
        end
    end
end

function GeneralShop:getConfig(index)
    local info = nil
    if self._curTabIndex == uq.config.constant.GENERAL_SHOP.ANCIENT_CITY_SHOP then
        info = StaticData['constant'][11].Data
    elseif self._curTabIndex == uq.config.constant.GENERAL_SHOP.TRIAL_TOWER_SHOP then
        info = StaticData['constant'][15].Data
    elseif self._curTabIndex == uq.config.constant.GENERAL_SHOP.ATHLETICS_SHOP then
        info = StaticData['constant'][10].Data
    end
    return info
end

function GeneralShop:onBtnRefresh(event)
    if event.name ~= "ended" then
        return
    end

    if self._freeRefreshNum <= 0 and uq.cache.role:getResNum(uq.config.constant.COST_RES_TYPE.MATERIAL, uq.config.constant.MATERIAL_TYPE.REFRESH_ORDER) == 0 then
        local info = self:getConfig(self._curTabIndex)
        local store_info = uq.cache.ancient_city.store_info
        local cost_str = ""
        local cost = 0
        local cost_type = 0
        for k, v in ipairs(info) do
            if self._refreshBuyNum < v.times and k ~= 1 then
                break
            end
            cost_str = v.cost
        end
        local cost_array = string.split(cost_str, ";")
        cost_type = tonumber(cost_array[1])
        cost = tonumber(cost_array[2])
        if not uq.cache.role:checkRes(cost_type, cost) then
            uq.fadeInfo(string.format(StaticData["local_text"]["label.res.tips.less"],StaticData.getCostInfo(cost_type).name))
            return
        end
        local call_back = nil
        if self._curTabIndex == uq.config.constant.GENERAL_SHOP.ANCIENT_CITY_SHOP then
            local confirm = function()
                network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_STORE_REFRESH, {})
            end
            call_back = confirm
        elseif self._curTabIndex == uq.config.constant.GENERAL_SHOP.TRIAL_TOWER_SHOP then
            local confirm = function()
                network:sendPacket(Protocol.C_2_S_TRIAL_TOWER_STORE_REFRESH, {})
            end
            call_back = confirm
        elseif self._curTabIndex == uq.config.constant.GENERAL_SHOP.ATHLETICS_SHOP then
            local confirm = function()
                network:sendPacket(Protocol.C_2_S_ATHLETICS_REFRESH_STORE, {})
            end
            call_back = confirm
        end
        local info = StaticData.getCostInfo(tonumber(cost_type))
        local icon = "<img img/common/ui/"..info.miniIcon..">"
        local des = string.format(StaticData['local_text']['ancient.city.shop.refresh.des1'],icon,cost)
        local data = {
            content = des,
            confirm_callback = call_back
        }
        uq.addConfirmBox(data, uq.config.constant.CONFIRM_TYPE.SHOP_REFRESH)
    else
        if self._curTabIndex == uq.config.constant.GENERAL_SHOP.ANCIENT_CITY_SHOP then
            network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_STORE_REFRESH, {})
        elseif self._curTabIndex == uq.config.constant.GENERAL_SHOP.TRIAL_TOWER_SHOP then
            network:sendPacket(Protocol.C_2_S_TRIAL_TOWER_STORE_REFRESH, {})
        elseif self._curTabIndex == uq.config.constant.GENERAL_SHOP.ATHLETICS_SHOP then
            network:sendPacket(Protocol.C_2_S_ATHLETICS_REFRESH_STORE, {})
        end
    end
end

function GeneralShop:initBtnListener()
    self._btnRefresh:setPressedActionEnabled(true)
end

function GeneralShop:initProtocal()
    services:addEventListener(services.EVENT_NAMES.ON_ANCIENT_CITY_TRADE_LOAD, handler(self, self._ancientCityTradeLoad),"_ancientCityTradeLoadByShop")
    network:addEventListener(Protocol.S_2_C_ANCIENT_CITY_EXCHANGE, handler(self, self._ancientCityExchange),"_ancientCityExchange")
    services:addEventListener(services.EVENT_NAMES.ON_ATHLETICS_STORE_INFO_LOAD, handler(self, self._athleticsStoreInfoLoad),"_athleticsStoreInfoLoadByShop")
    services:addEventListener(services.EVENT_NAMES.ON_ATHLETICS_EXCHANGEITEM, handler(self, self._onAthleticsExchangeItem),"_onAthleticsExchangeItemByShop")
    services:addEventListener(services.EVENT_NAMES.ON_ANCIENT_CITY_STORE_LOAD, handler(self, self._ancientCityStoreLoad),"_ancientCityStoreLoadByShop")
    services:addEventListener(services.EVENT_NAMES.ON_ANCIENT_CITY_STORE_BUY, handler(self, self._onAncientCityStoreBuy),"_onAncientCityStoreBuyByShop")
    services:addEventListener(services.EVENT_NAMES.ON_TRIAL_TOWER_STORE_LOAD, handler(self, self._onTrialTowerStoreLoad),"_onTrialTowerStoreLoadByShop")
    services:addEventListener(services.EVENT_NAMES.ON_TRIAL_TOWER_STORE_BUY, handler(self, self._onTrialTowerStoreBuy),"_onTrialTowerStoreBuyByShop")
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_TRADE_LOAD, {trade_type = 0})
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_TRADE_LOAD, {trade_type = 1})  --金币
end

function GeneralShop:_ancientCityTradeLoad(evt)
    local info = evt.data
    self._tradeReciveNum = self._tradeReciveNum + 1
    if info.pass_time < 0 or (60 * 30 <= info.pass_time) then
        self:updateTabInfo()
        return
    end
    local item_array = {}
    for k,v in pairs(info.items) do
        local item = {}
        item.id = v.id
        if info.trade_type == 0 then
            item.xml = StaticData['ancient_trade'].AncientTrade[item.id]
        else
            item.xml = StaticData['ancient_trade'].AncientCoinTrade[item.id]
        end
        item.discount = v.discount
        item.num = item.xml.limit - v.num
        if item.num <= 0 then
            item.num = 0
        end
        item.type = info.trade_type + 2
        table.insert(item_array,item)
    end
    self._curTotalInfoArray[info.trade_type + 4] = {items = item_array,type = info.trade_type + 2,pass_time = self._shopTime - info.pass_time + os.time()}
    self:updateTabInfo()
end

function GeneralShop:_ancientCityExchange(evt)
    local index = 0
    for k,v in pairs(self._curItemInfoArray) do
        index = index + 1
        if v.id == evt.data.id then
            v.num = v.num - evt.data.num
            if v.num < 0 then
                v.num = 0
            end
            break
        end
    end
    index = math.floor(index + 1) / 3
    local offset = self._itemTableView:getContentOffset();
    self._itemTableView:reloadData()
    local xml_data = nil
    if evt.data.trade_type == 0 then
        xml_data = StaticData['ancient_trade'].AncientTrade[evt.data.id]
    else
        xml_data = StaticData['ancient_trade'].AncientCoinTrade[evt.data.id]
    end
    uq.cache.ancient_city:showReward(xml_data, evt.data.num)
end

function GeneralShop:_onAncientCityStoreBuy(evt)
    local index = 0
    for k,v in pairs(self._curItemInfoArray) do
        index = index + 1
        if v.id == evt.data.id then
            v.num = v.num - evt.data.num
            if v.num < 0 then
                v.num = 0
            end
            break
        end
    end
    index = math.floor(index + 1) / 3
    local offset = self._itemTableView:getContentOffset();
    self._itemTableView:reloadData()
end

function GeneralShop:_onTrialTowerStoreBuy(evt)
    local index = 0
    for k,v in pairs(self._curItemInfoArray) do
        index = index + 1
        if v.id == evt.data.id then
            v.num = v.num - evt.data.num
            if v.num < 0 then
                v.num = 0
            end
            break
        end
    end
    index = math.floor(index + 1) / 3
    local offset = self._itemTableView:getContentOffset();
    self._itemTableView:reloadData()
end

function GeneralShop:_onAthleticsExchangeItem(evt)
    local index = 0
    for k,v in pairs(self._curItemInfoArray) do
        index = index + 1
        if v.id == evt.data.id then
            v.num = v.num - evt.data.num
            if v.num < 0 then
                v.num = 0
            end
            break
        end
    end
    self._itemTableView:reloadData()
end

function GeneralShop:_athleticsStoreInfoLoad(evt)
    local info = uq.cache.athletics.store_info
    self._refreshBuyNum = info.refresh_buy_num
    local item_array = {}
    for k,v in pairs(info.items) do
        local item = {}
        item.id = v.id
        item.xml = StaticData['arena_store'].ArenaStore[item.id]
        item.discount = v.discount
        item.type = uq.config.constant.SHOP_BUY_TYPE.ATHLETICS_SHOP
        if item.xml.limit == 0 then
            item.num = item.xml.times - v.num
        else
            item.num = item.xml.limit - v.num
        end
        if item.num <= 0 then
            item.num = 0
        end
        table.insert(item_array,item)
    end
    self._curTotalInfoArray[uq.config.constant.GENERAL_SHOP.ATHLETICS_SHOP] = {items = item_array,type = 5}
    self:updateTabInfo()
end

function GeneralShop:_ancientCityStoreLoad(evt)
    local info = uq.cache.ancient_city.store_info
    self._refreshBuyNum = info.refresh_buy_num
    local item_array = {}
    for k, v in ipairs(info.items) do

        local item = {}
        item.id = v.id
        item.xml = StaticData['ancient_store'].AncientStore[item.id]
        if item.xml.type == 1 then
            item.discount = v.discount
            item.type = uq.config.constant.SHOP_BUY_TYPE.ANCIENT_CITY
            if item.xml.limit == 0 then
                item.num = item.xml.times - v.num
            else
                item.num = item.xml.limit - v.num
            end
            if item.xml.times > 0 then
                local min_num = item.num
                for k2,v2 in pairs(info.total_nums) do
                    if v2.id == item.id then
                        local nums = item.xml.times - v2.num
                        if nums < item.num then
                            item.num = nums
                        end
                        break
                    end
                end
            end
            if item.num <= 0 then
                item.num = 0
            end
            table.insert(item_array,item)
        end
    end
    self._curTotalInfoArray[uq.config.constant.GENERAL_SHOP.ANCIENT_CITY_SHOP] = {items = item_array,type = 1}
    self:updateTabInfo()
    if not self._isOneFinish then
        self:showAction()
        self._isOneFinish = true
    end
end

function GeneralShop:checkCanBuyState(buy_type)
    return self._closeTime > 0
end

function GeneralShop:_onTrialTowerStoreLoad()
    local info = uq.cache.trials_tower.store_info
    self._refreshBuyNum = info.refresh_buy_num
    local item_array = {}
    for k, v in pairs(info.items) do
        local item = {}
        item.id = v.id
        item.xml = StaticData['tower_store'].TowerStore[item.id]
        item.discount = v.discount
        item.type = uq.config.constant.SHOP_BUY_TYPE.TRIAL_SHOP   --用于区分物品所属类型
        if item.xml.limit == 0 then
            item.num = item.xml.times - v.num
        else
            item.num = item.xml.limit - v.num
        end
        if item.num <= 0 then
            item.num = 0
        end
        table.insert(item_array,item)
    end
    self._curTotalInfoArray[uq.config.constant.GENERAL_SHOP.TRIAL_TOWER_SHOP] = {items = item_array,type = 4}
    self:updateTabInfo()
end

function GeneralShop:updateTabInfo()
    if not self._curTabIndex then
        return
    end
    local info = self._curTotalInfoArray[self._curTabIndex]
    if not info then  --没数据，去拉取
        if self._curTabIndex == uq.config.constant.GENERAL_SHOP.ANCIENT_CITY_SHOP then
            network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_STORE_LOAD, {})
        elseif self._curTabIndex == uq.config.constant.GENERAL_SHOP.TRIAL_TOWER_SHOP then
            network:sendPacket(Protocol.C_2_S_TRIAL_TOWER_STORE_LOAD, {})
        elseif self._curTabIndex == uq.config.constant.GENERAL_SHOP.ATHLETICS_SHOP then
            network:sendPacket(Protocol.C_2_S_ATHLETICS_STORE_INFO_LOAD, {})
        end
        return
    end
    if self._curTabIndex == uq.config.constant.GENERAL_SHOP.ANCIENT_CITY_SHOP or self._curTabIndex == uq.config.constant.GENERAL_SHOP.TRIAL_TOWER_SHOP or self._curTabIndex == uq.config.constant.GENERAL_SHOP.ATHLETICS_SHOP then
        self._panelRefresh:setVisible(true)
    else
        self._panelRefresh:setVisible(false)
    end
    if self._curTabIndex == uq.config.constant.GENERAL_SHOP.ANCIENT_CITY_SHOP then --古城商店
        local info = uq.cache.ancient_city.store_info
        local xml_data = StaticData['ancient_store'].Fresh[1]
        self:updateRefreshInfo(xml_data, info.refresh_num)
    elseif self._curTabIndex == uq.config.constant.GENERAL_SHOP.TRIAL_TOWER_SHOP then --试练塔商店
        local info = uq.cache.trials_tower.store_info
        local xml_data = StaticData['tower_store'].Fresh[1]
        self:updateRefreshInfo(xml_data, info.refresh_num)
    elseif self._curTabIndex == uq.config.constant.GENERAL_SHOP.ATHLETICS_SHOP then --竞技场商店
        local info = uq.cache.athletics.store_info
        local xml_data = StaticData['arena_store'].Fresh[1]
        self:updateRefreshInfo(xml_data, info.refresh_num)
    else
        self._closeTime = info.pass_time - os.time()
        self:initTimer()
    end
    self._curItemInfoArray = info.items
    self._itemTableView:reloadData()
end

function GeneralShop:updateRefreshInfo(xml_data,refresh_num)
    self._totalRefreshNum = xml_data.limitTimes - refresh_num
    if self._totalRefreshNum < 0 then
        self._totalRefreshNum = 0
    end
    self._reminderLabel:setString(self._totalRefreshNum)

    self._freeRefreshNum = xml_data.freeTimes - refresh_num
    if self._freeRefreshNum < 0 then
        self._freeRefreshNum = 0
    end
    local num = uq.cache.role:getResNum(uq.config.constant.COST_RES_TYPE.MATERIAL,uq.config.constant.MATERIAL_TYPE.REFRESH_ORDER)
    local state = self._freeRefreshNum == 0 and self._totalRefreshNum > 0
    self._refreshCostImg:setVisible(state)
    self._refreshCostLabel:setVisible(state)
    self._labelFull:setVisible(not state)
    self._btnRefresh:setEnabled(self._totalRefreshNum > 0)
    if self._freeRefreshNum > 0 then
        self._labelFull:setString(StaticData['local_text']['ancient.city.shop.des3'])
    elseif num > 0 then
        local data = StaticData['material'][3].miniIcon
        self._refreshCostImg:loadTexture("img/common/ui/" .. data)
        self._refreshCostLabel:setString(1 .. "  " .. StaticData['local_text']['label.common.refresh'])
    elseif self._totalRefreshNum > 0 then
        local data = StaticData['types'].Cost[1].Type[102].miniIcon
        self._refreshCostImg:loadTexture("img/common/ui/" .. data)
        local info = self:getConfig(self._curTabIndex)
        local cost = ""
        for k, v in ipairs(info) do
            if self._refreshBuyNum < v.times and k ~= 1 then
                break
            end
            cost = v.cost
        end
        local cost_array = string.split(cost, ";")
        self._refreshCostLabel:setString(cost_array[2] .. "  " ..  StaticData['local_text']['label.common.refresh'])
    else
        self._labelFull:setString(StaticData['local_text']['has.less.refresh.num'])
    end

    if self._cdTimer then
        self._cdTimer:dispose()
        self._cdTimer = nil
    end
    local time_array = string.split(xml_data.freshTime,";")
    local hour = os.date("%H",os.time())
    local sthour = 0
    for k,v in ipairs(time_array) do
        if tonumber(v) > tonumber(hour) then
            sthour = tonumber(v)
            break
        end
    end
    if sthour == 0 then
        sthour = tonumber(time_array[1])
    end
    self._timeLabel:setHTMLText(string.format(StaticData['local_text']['ancient.city.shop.des5'],sthour))
end

function GeneralShop:initItemTabView()
    local size = self._panelTabView:getContentSize()
    self._itemTableView = cc.TableView:create(cc.size(size.width,size.height))
    self._itemTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._itemTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._itemTableView:setPosition(cc.p(0, 0))
    self._itemTableView:setAnchorPoint(cc.p(0,0))
    self._itemTableView:setDelegate()
    self._panelTabView:addChild(self._itemTableView)

    self._itemTableView:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._itemTableView:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._itemTableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._itemTableView:reloadData()
end

function GeneralShop:cellSizeForTable(view, idx)
    return 1110, 225
end

function GeneralShop:numberOfCellsInTableView(view)
    return math.ceil((#self._curItemInfoArray + 1) / 3)
end

function GeneralShop:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx * 3 + 1
    if not cell then
        cell = cc.TableViewCell:new()
        for i = 0, 2 do
            local info = self._curItemInfoArray[index]
            local width = 0
            local euqip_item = nil
            if info ~= nil then
                euqip_item = GeneralShopItem:create({info = info})
                width = euqip_item:getContentSize().width
                euqip_item:setPosition(cc.p((width * 0.5) + width * i, 112.5))
                euqip_item:setBuyItemCallBack(handler(self, self.checkCanBuyState))
                cell:addChild(euqip_item,1)
                euqip_item:setName("item"..i)
            else
                euqip_item = GeneralShopItem:create()
                width = euqip_item:getContentSize().width
                euqip_item:setPosition(cc.p((width * 0.5) + width * i, 112.5))
                cell:addChild(euqip_item,1)
                euqip_item:setName("item"..i)
                euqip_item:setVisible(false)
            end
            table.insert(self._allUi, euqip_item)
            index = index + 1
        end
    else
        for i = 0, 2 do
            local info = self._curItemInfoArray[index]
            local euqip_item = cell:getChildByName("item"..i)
            if info ~= nil then
                euqip_item:setInfo(info)
                euqip_item:setVisible(true)
            elseif euqip_item then
                euqip_item:setVisible(false)
            end
            index = index + 1
        end
    end
    return cell
end

function GeneralShop:update(param)
    self._curTabIndex = param
    self:updateTabInfo()
end

function GeneralShop:showAction()
    for i, v in ipairs(self._allUi) do
        v:showAction()
    end
end

function GeneralShop:dispose()
    if self._cdTimer then
        self._cdTimer:dispose()
        self._cdTimer = nil
    end
    services:removeEventListenersByTag("_ancientCityTradeLoadByShop")
    network:removeEventListenerByTag("_ancientCityExchange")
    services:removeEventListenersByTag("_athleticsStoreInfoLoadByShop")
    services:removeEventListenersByTag("_onAthleticsExchangeItemByShop")
    services:removeEventListenersByTag("_ancientCityStoreLoadByShop")
    services:removeEventListenersByTag("_onAncientCityStoreBuyByShop")
    services:removeEventListenersByTag("_onTrialTowerStoreLoadByShop")
    services:removeEventListenersByTag("_onTrialTowerStoreBuyByShop")
end

return GeneralShop