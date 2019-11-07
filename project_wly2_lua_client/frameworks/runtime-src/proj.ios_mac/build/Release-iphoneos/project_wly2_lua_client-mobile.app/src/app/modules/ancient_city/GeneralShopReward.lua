local GeneralShopReward = class("GeneralShopReward", require("app.base.TableViewBase"))
local GeneralShopItem = require("app.modules.ancient_city.GeneralShopItem")
local GeneralShopTabItem = require("app.modules.ancient_city.GeneralShopTabItem")

GeneralShopReward.RESOURCE_FILENAME = "ancient_city/AncientCityReward.csb"

GeneralShopReward.RESOURCE_BINDING  = {
    ["Panel_tabview"]       ={["varname"] = "_panelTabView"},
    ["panel_1"]             ={["varname"] = "_panelCenter"},
    ["Panel_tap"]           ={["varname"] = "_panelTabView2"},
}

function GeneralShopReward:ctor(name, args)
    GeneralShopReward.super.ctor(self)
    self._curTabIndex = args.sub_index or 1
    self._curItemInfoArray = {}
    self._curTotalInfoArray = {}
    self._allUi = {}
    self._curTabInfoArray = {}
    self._curTableViewInfo = nil
    self._panelCenter:setOpacity(0)
end

function GeneralShopReward:init()
    self:parseView()
    self:initItemTabView()
    self:initProtocal()
end

function GeneralShopReward:initData()
    self._curTabInfoArray = {}
    self._curTotalInfoArray = {}
    for k, v in ipairs(self._openTab) do
        if tonumber(v) <= uq.cache.role:level() then
            local tab_info = {}
            tab_info.name = self._tabTxt[k]
            tab_info.index = k
            table.insert(self._curTabInfoArray,tab_info)
            if self._curTabIndex == tonumber(k) then
                self._curTableViewInfo = tab_info
            end
        end
    end
    self._tableView:reloadData()
end

function GeneralShopReward:_onInitAncientReward()
    local info = uq.cache.ancient_city.store_info
    local item_array = {}
    for k,v in pairs(info.items) do
        local item = {}
        item.id = v.id
        item.xml = StaticData['ancient_store'].AncientStore[item.id]
        if item.xml.type == 2 then
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
    self._curTotalInfoArray[uq.config.constant.GENERAL_SHOP.ANCIENT_CITY_SHOP] = {items = item_array, type = 1}
    self:updateTabInfo()
end

function GeneralShopReward:_onInitTowerReward()
    local info = uq.cache.trials_tower.store_info
    local reward_array = StaticData['tower_store'].TowerReward
    local item_array = {}
    for k,v in ipairs(reward_array) do
        local discount_info = string.split(v.discount, ',')
        local item = {}
        item.xml = v
        item.id = v.id
        item.discount = discount_info[1]
        item.num = v.times
        item.type = uq.config.constant.SHOP_BUY_TYPE.TRIAL_REWARD
        for k2,v2 in pairs(info.rank_rwds) do
            if item.id == v2.id then
                item.discount = v2.discount
                item.num = item.num - v2.num
                break
            end
        end
        table.insert(item_array,item)
    end
    self._curTotalInfoArray[uq.config.constant.GENERAL_SHOP.TRIAL_TOWER_SHOP] = {items = item_array,type = uq.config.constant.GENERAL_SHOP.TRIAL_TOWER_SHOP}
    self:updateTabInfo()
end

function GeneralShopReward:_onInitAthleticsReward()
    local info = uq.cache.athletics.store_info
    local reward_array = StaticData['arena_store'].ArenaReward
    local item_array = {}
    for k,v in ipairs(reward_array) do
        local discount_info = string.split(v.discount, ',')
        local item = {}
        item.xml = v
        item.id = v.id
        item.discount = tonumber(discount_info[1])
        item.num = v.times
        item.type = uq.config.constant.SHOP_BUY_TYPE.ATHLETICS_REWARD
        for k2,v2 in pairs(info.rank_rwds) do
            if item.id == v2.id then
                item.discount = v2.discount
                item.num = item.num - v2.num
                break
            end
        end
        table.insert(item_array,item)
    end
    self._curTotalInfoArray[uq.config.constant.GENERAL_SHOP.ATHLETICS_SHOP] = {items = item_array,type = uq.config.constant.GENERAL_SHOP.ATHLETICS_SHOP}
    self:updateTabInfo()
end

function GeneralShopReward:_onTrialTowerDrawReward(evt)
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
    if index > 4 then
        local new_offset = 535 - index * 134
        if new_offset > offset.y then
            offset.y = new_offset
        end
        self._itemTableView:setContentOffset(offset);
    end
end

function GeneralShopReward:initItemTabView()
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
    self:updateTabInfo()
end

function GeneralShopReward:cellSizeForTable(view, idx)
    return 1110, 225
end

function GeneralShopReward:numberOfCellsInTableView(view)
    return math.ceil((#self._curItemInfoArray + 1) / 3)
end

function GeneralShopReward:tableCellAtIndex(view, idx)
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

function GeneralShopReward:updateTabInfo()
    if not self._curTabIndex then
        return
    end
    local info = nil
    for k,v in pairs(self._curTotalInfoArray) do
        if v.type == self._curTabIndex then
            info = v
            break
        end
    end
    if not info then
        if self._curTabIndex == uq.config.constant.GENERAL_SHOP.ANCIENT_CITY_SHOP then
            network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_STORE_LOAD, {})
        elseif self._curTabIndex == uq.config.constant.GENERAL_SHOP.TRIAL_TOWER_SHOP then
            network:sendPacket(Protocol.C_2_S_TRIAL_TOWER_STORE_LOAD, {})
        elseif self._curTabIndex == uq.config.constant.GENERAL_SHOP.ATHLETICS_SHOP then
            network:sendPacket(Protocol.C_2_S_ATHLETICS_STORE_INFO_LOAD, {})
        end
        return
    end
    self._curItemInfoArray = info.items
    self._itemTableView:reloadData()
    if not self._isOneFinish and #self._allUi > 0 then
        self:showAction()
        self._isOneFinish = true
    end
end

function GeneralShopReward:initProtocal()
    services:addEventListener(services.EVENT_NAMES.ON_ANCIENT_CITY_STORE_BUY, handler(self, self._onTrialTowerDrawReward),"onAncientCityStoreBuyByReward")
    services:addEventListener("onTrialTowerDrawReward", handler(self, self._onTrialTowerDrawReward),"_onTrialTowerDrawRewardByReward")
    services:addEventListener("onAthleticsDrawRankReward", handler(self, self._onTrialTowerDrawReward),"_onAthleticsDrawRankRewardByReward")
    services:addEventListener(services.EVENT_NAMES.ON_ATHLETICS_STORE_INFO_LOAD, handler(self, self._onInitAthleticsReward),"_athleticsStoreInfoLoadByReward")
    services:addEventListener(services.EVENT_NAMES.ON_ANCIENT_CITY_STORE_LOAD, handler(self, self._onInitAncientReward),"_ancientCityStoreLoadByReward")
    services:addEventListener(services.EVENT_NAMES.ON_TRIAL_TOWER_STORE_LOAD, handler(self, self._onInitTowerReward),"_onTrialTowerStoreLoadByReward")
end

function GeneralShopReward:update(param)
    self._curTabIndex = param
    self:updateTabInfo()
end

function GeneralShopReward:showAction()
    for i, v in ipairs(self._allUi) do
        v:showAction()
    end
end

function GeneralShopReward:dispose()
    services:removeEventListenersByTag("onAncientCityStoreBuyByReward")
    services:removeEventListenersByTag("_onTrialTowerDrawRewardByReward")
    services:removeEventListenersByTag("_onAthleticsDrawRankRewardByReward")
    services:removeEventListenersByTag("_athleticsStoreInfoLoadByReward")
    services:removeEventListenersByTag("_ancientCityStoreLoadByReward")
    services:removeEventListenersByTag("_onTrialTowerStoreLoadByReward")
end

return GeneralShopReward