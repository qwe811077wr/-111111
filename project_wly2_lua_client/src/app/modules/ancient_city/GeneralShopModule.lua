local GeneralShopModule = class("GeneralShopModule", require("app.base.PopupTabView"))
local GeneralShopTabItem = require("app.modules.ancient_city.GeneralShopTabItem")

GeneralShopModule.RESOURCE_FILENAME = "ancient_city/AncientCityShopMain.csb"
GeneralShopModule.RESOURCE_BINDING  = {
    ["Panel_1/Panel_tab"] ={["varname"] = "_panelTab"},
    ["Panel_tap"]         ={["varname"] = "_panelTabView2"}
}

function GeneralShopModule:ctor(name, args)
    GeneralShopModule.super.ctor(self, name, args)
    self._tabIndex = args._tab_index or 1
    self._subShopIndex = args._sub_index
    self._isMove = args._is_move or false
    self._tabModuleArray = {}
    GeneralShopModule._subModules = {
    --商店和奖励商店
        {path = "app.modules.ancient_city.GeneralShop"},
        {path = "app.modules.ancient_city.GeneralShopReward"},
    }

    GeneralShopModule._tabTxt = {
        StaticData['local_text']["label.common.shop"],
        StaticData['local_text']["label.common.reward"],
    }

    GeneralShopModule._openTab = {
        uq.config.constant.MODULE_ID.ANCIENT_CITY_SHOP,
        uq.config.constant.MODULE_ID.ATHLETICS_SHOP,
        uq.config.constant.MODULE_ID.TRIAL_TOWER_SHOP,
    }

    GeneralShopModule._openTabTxt = {
        StaticData['local_text']["label.common.ancient.city.shop"],
        StaticData['local_text']["label.common.arena.shop"],
        StaticData['local_text']["label.common.trial.tower.shop"],
        StaticData['local_text']["label.common.jade.shop"],
        StaticData['local_text']["label.common.coin.shop"],
    }
end

function GeneralShopModule:init()
    local top_ui = uq.ui.CommonHeaderUI:create()
    top_ui:setTitle(uq.config.constant.MODULE_ID.GENRAL_SHOP)
    self._topUI = top_ui
    self._view:addChild(top_ui:getNode())
    self:parseView()
    self:centerView()
    self:addTabBtns()
    self:initProtocolData()
    self:playTopAction()
    self:adaptBgSize()
end

function GeneralShopModule:playTopAction()
end

function GeneralShopModule:addTabBtns()
    self._curTabInfoArray = {}
    self._tabArray = {}
    local cur_Tab = nil
    local first_tab = nil
    local index = 1
    for i = 1, 2 do
        local tab_btn = self._panelTab:getChildByName("tab_"..i)
        table.insert(self._tabModuleArray, tab_btn)
        tab_btn:addClickEventListenerWithSound(handler(self, self.onTabChanged))
        tab_btn:setTag(i)
        if i == tonumber(self._tabIndex) then
            cur_Tab = tab_btn
        end
        if first_tab == nil then
            first_tab = tab_btn
        end
        index = index + 1
    end

    for k, v in ipairs(self._openTab) do
        if self:checkShopIsOpen(v) then
            local tab_info = {}
            tab_info.name = self._openTabTxt[k]
            tab_info.index = k
            table.insert(self._curTabInfoArray, tab_info)

            if not self._subShopIndex then
                self._subShopIndex = tab_info.index
            end
        end
    end

    if not self._subShopIndex then
        return
    end

    if cur_Tab then
        self:onTabChanged(cur_Tab)
    elseif first_tab then
        self:onTabChanged(first_tab)
    end

    local size = self._panelTabView2:getContentSize()
    self._tableView = cc.TableView:create(cc.size(size.width,size.height))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setAnchorPoint(cc.p(0,0))
    self._tableView:setDelegate()
    self._panelTabView2:addChild(self._tableView)

    self._tableView:registerScriptHandler(handler(self,self.cellSizeForTable2), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.tableCellAtIndex2), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView2), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:setTouchEnabled(false)
    self._tableView:reloadData()
end

function GeneralShopModule:checkShopIsOpen(module_id)
    local info =StaticData['module'][module_id]
    if not info then
        return false
    end

    if tonumber(info.openLevel) > uq.cache.role:level() then
        return false
    end

    local instance_id = math.floor(tonumber(info.openMission) / 100)
    if instance_id ~= 0 then
        local instance_config =  StaticData['instance'][instance_id]
        local map_config = StaticData.load('instance/' .. instance_config.fileId).Map[instance_id].Object[info.openMission]
        if not uq.cache.instance:isNpcPassed(info.openMission) then
            return false
        end
    end

    return true
end

function GeneralShopModule:cellSizeForTable2(view, idx)
    return 119, 120
end

function GeneralShopModule:numberOfCellsInTableView2(view)
    return #self._curTabInfoArray
end

function GeneralShopModule:onClickTabItem(index)
    for k, v in ipairs(self._tabArray) do
        v:setCheckBoxState(k == index)
    end
    self:onShopTabChanged(self._curTabInfoArray[index].index)
    self:onTabChanged(self._tabModuleArray[1])
end

function GeneralShopModule:tableCellAtIndex2(view, idx)
    local cell = view:dequeueCell()
    local index = idx + 1
    local euqip_item = nil
    if not cell then
        cell = cc.TableViewCell:new()
        local info = self._curTabInfoArray[index]
        if info ~= nil then
            euqip_item = GeneralShopTabItem:create({info = info})
            local width = euqip_item:getContentSize().width
            euqip_item:setPosition(cc.p(width * 0.5, 0))
            euqip_item:setInfo(info)
            euqip_item:setClickCallBack(handler(self, self.onClickTabItem))
            cell:addChild(euqip_item,1)
            euqip_item:setName("item")
            table.insert(self._tabArray, euqip_item)
            if self._subShopIndex == info.index then
                euqip_item:setCheckBoxState(true)
                self:onShopTabChanged(info.index)
            end
        end
    else
        local info = self._curTabInfoArray[index]
        euqip_item = cell:getChildByName("item")
        if info ~= nil then
            euqip_item:setInfo(info)
             if self._subShopIndex == info.index then
                euqip_item:setCheckBoxState(true)
            end
        end
    end
    euqip_item:setIndex(index)
    return cell
end

function GeneralShopModule:onTabChanged(btn)
    local tag = btn:getTag()
    for i, v in ipairs(self._tabModuleArray) do
        v:setEnabled(tag ~= i)
        local img_select = v:getChildByName("Node_9")
        local img_normal = v:getChildByName("Node_9_0")
        img_select:setVisible(i == tag)
        img_normal:setVisible(i ~= tag)
    end
    local path = self._subModules[tag].path
    self:addSub(path, nil, nil, tag, self._subShopIndex)
    self._subModule[tag]:showAction()
end

function GeneralShopModule:onShopTabChanged(index)
    self._subShopIndex = index
    self._topUI:removeAllItems()
    if index == uq.config.constant.GENERAL_SHOP.ANCIENT_CITY_SHOP then
        self._topUI:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.ANCIENT_CITY_COIN, true))
        self._topUI:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.MONEY, true))
        self._topUI:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.GOLDEN, true))
        self._panelTab:setVisible(true)
    elseif index == uq.config.constant.GENERAL_SHOP.JADE_SHOP then
        self._panelTab:setVisible(false)
        self._topUI:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.MATERIAL, true, uq.config.constant.MATERIAL_TYPE.PURPLE_DRAGON_JADE))
        self._topUI:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.MATERIAL, true, uq.config.constant.MATERIAL_TYPE.ORANGE_DRAGON_JADE))
        self._topUI:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.GOLDEN, true))
    elseif index == uq.config.constant.GENERAL_SHOP.GOLD_SHOP then
        self._panelTab:setVisible(false)
        self._topUI:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.MONEY, true))
        self._topUI:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.GOLDEN, true))
    elseif index == uq.config.constant.GENERAL_SHOP.TRIAL_TOWER_SHOP then
        self._panelTab:setVisible(true)
        self._topUI:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.TRIALS_TOWER_ORDER, true))
        self._topUI:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.MONEY, true))
        self._topUI:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.GOLDEN, true))
    elseif index == uq.config.constant.GENERAL_SHOP.ATHLETICS_SHOP then
        self._panelTab:setVisible(true)
        self._topUI:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.ARENA_SCORE, true))
        self._topUI:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.MONEY, true))
        self._topUI:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.GOLDEN, true))
    end
end

function GeneralShopModule:initProtocolData()
    services:addEventListener("onShopTabChanged", handler(self, self.onShopTabChanged), 'onShopTabChangedByShop')
    if uq.cache.ancient_city:getPassCityInfo() == nil then
        network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_ENTER, {})
    end
    services:addEventListener(services.EVENT_NAMES.ON_ANCIENT_CITY_TRADE_LOAD, handler(self, self._ancientCityTradeLoad),"_ancientCityTradeLoadByShop" .. tostring(self))
end

function GeneralShopModule:_ancientCityTradeLoad(evt)
    local info = evt.data
    if info.pass_time < 0 or (60 * 30 <= info.pass_time) then
        self._tableView:reloadData()
        return
    end
    for k, v in ipairs(self._curTabInfoArray) do
        if v.index == info.trade_type + 4 then
            return
        end
    end
    local tab_info = {}
    tab_info.name = self._openTabTxt[info.trade_type + 4]
    tab_info.index = info.trade_type + 4
    table.insert(self._curTabInfoArray, tab_info)
    self._tableView:reloadData()
end

function GeneralShopModule:removeProtocolData()
    services:removeEventListenersByTag("onShopTabChangedByShop")
    services:removeEventListenersByTag("_ancientCityTradeLoadByShop" .. tostring(self))
end

function GeneralShopModule:dispose()
    if self._topUI then
        self._topUI:dispose()
    end
    self._topUI = nil
    if self._isMove then
        network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_MOVE, {hasSecretRoom = 0})
    end
    self:removeProtocolData()
    GeneralShopModule.super.dispose(self)
end

return GeneralShopModule