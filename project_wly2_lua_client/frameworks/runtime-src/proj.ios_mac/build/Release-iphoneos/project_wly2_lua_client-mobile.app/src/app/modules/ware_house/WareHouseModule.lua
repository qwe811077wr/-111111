local WareHouseModule = class("WareHouseModule", require("app.base.PopupTabView"))
local EquipItem = require("app.modules.common.EquipItem")

WareHouseModule.RESOURCE_FILENAME = "ware_house/WareHouseMain.csb"
WareHouseModule.RESOURCE_BINDING  = {
    ["Panel_1/img_bg"]                                                      ={["varname"] = "_imgBg"},
    ["Panel_1/Panel_null"]                                                  ={["varname"] = "_panelNull"},
    ["Panel_1/Panel_tableview"]                                             ={["varname"] = "_panelTableView"},
    ["Panel_1/Panel_items"]                                                 ={["varname"] = "_panelItems"},
    ["Panel_1/Panel_items/label_name"]                                      ={["varname"] = "_nameLabel"},
    ["Panel_1/Panel_items/Panel_item"]                                      ={["varname"] = "_panelItem"},
    ["panel_sell_two"]                                                      ={["varname"] = "_panelTwoPrice"},
    ["panel_sell_one"]                                                      ={["varname"] = "_panelOnePrice"},
    ["Panel_1/Panel_items/label_lvl"]                                       ={["varname"] = "_resNum"},
    ["Panel_1/Panel_items/label_quality_lv"]                                ={["varname"] = "_txtQualityLv"},
    ["Panel_1/Panel_items/Panel_side"]                                      ={["varname"] = "_panelEquip"},
    ["Panel_1/Panel_items/panel_res"]                                       ={["varname"] = "_panelRes"},
    ["Panel_1/Panel_items/label_base"]                                      ={["varname"] = "_txtBaseName"},
    ["Panel_1/Panel_items/label_base_num"]                                  ={["varname"] = "_baseNumLabel"},
    ["Panel_1/Panel_items/Panel_side/label_crit_num"]                       ={["varname"] = "_critNumLabel"},
    ["Panel_1/Panel_items/Panel_side/label_dec_injure"]                     ={["varname"] = "_decInjureLabel"},
    ["Panel_1/Panel_items/Panel_side/label_beat_back_num"]                  ={["varname"] = "_beatBackNumLabel"},
    ["Panel_1/Panel_items/Panel_side/btn_sell"]                             ={["varname"] = "_btnSell",["events"] = {{["event"] = "touch",["method"] = "_onBtnSell"}}},
    ["Panel_1/Panel_items/btn_wear"]                                        ={["varname"] = "_btnWear",["events"] = {{["event"] = "touch",["method"] = "_onBtnUse"}}},
    ["ScrollView_1"]                                                        ={["varname"] = "_scrollView"},
    ["Node_tab"]                                                            ={["varname"] = "_nodeMenu"},
    ["Button_6"]                                                            ={["varname"] = "_btnDelete",["events"] = {{["event"] = "touch",["method"] = "_onDeleteUseNum"}}},
    ["Button_7"]                                                            ={["varname"] = "_btnAdd",["events"] = {{["event"] = "touch",["method"] = "_onAddUseNum"}}},
    ["Slider_1"]                                                            ={["varname"] = "_slider"},
    ["Text_8"]                                                              ={["varname"] = "_txtUseNum"},
    ["Panel_14"]                                                            ={["varname"] = "_panelUse"},
    ["Button_3"]                                                            ={["varname"] = "_btnWear1",["events"] = {{["event"] = "touch",["method"] = "_onBtnWear"}}},
    ["Button_4"]                                                            ={["varname"] = "_btnWear2",["events"] = {{["event"] = "touch",["method"] = "_onBtnWear"}}},
    ["label_des_1_0"]                                                       ={["varname"] = "_txtTips"},
    ["label_name_0"]                                                        ={["varname"] = "_txtQualtiy"},
    ["Text_4"]                                                              ={["varname"] = "_labelNoSuit"},
    ["ScrollView_2"]                                                        ={["varname"] = "_scrollEquip"},
    ["decompose_btn"]                                                       ={["varname"] = "_btnDecompose",["events"] = {{["event"] = "touch",["method"] = "_onBtnDecompose"}}},
    ["Panel_side/label_1"]                                                  ={["varname"] = "_panelTitle1"},
    ["Panel_side/label_2"]                                                  ={["varname"] = "_panelTitle2"},
    ["Panel_side/label_3"]                                                  ={["varname"] = "_panelTitle3"},
    ["CheckBox_1"]                                                          ={["varname"] = "_checkBox"},
}
function WareHouseModule:ctor(name, args)
    WareHouseModule.super.ctor(self, name, args)
    self._tabIndex = args._tab_index or 1
    self._tabModuleArray = {}
    self._tableView = nil
    self._cellArray = {}
    self._equipArray = {}
    self._resArray = {}
    self._itemArray = {}
    self._spiritArray = {}
    self._scrollPosy = self._scrollView:getPositionY()
    self._scrollOriginWidth = self._scrollView:getContentSize().width
    self._scrollOriginHeight = self._scrollView:getContentSize().height
    self._curTabNum = 0
    self._curTableViewIndex = -1
    self._curTableViewInfo = nil
    self._signleEquipInfo = nil
    WareHouseModule._tabTxt = {
        StaticData['local_text']["label.equip"],
        StaticData['local_text']["label.resource"],
        StaticData['local_text']["label.prop"],
        StaticData['local_text']['label.warehouse.spirit'],
    }
    WareHouseModule._MATERIALS_TYPE = {
        BOX_TYPE = 3
    }
    self._arrValue = {self._critNumLabel, self._beatBackNumLabel, self._decInjureLabel}
    self._arrTitle = {self._panelTitle1, self._panelTitle2, self._panelTitle3}
end

function WareHouseModule:init()
    local top_ui = uq.ui.CommonHeaderUI:create()
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.MONEY,  true))
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.GOLDEN,  true))
    top_ui:setTitle(uq.config.constant.MODULE_ID.WAREHOURSE_MODULE)
    self._topUI = top_ui
    self._view:addChild(top_ui:getNode())
    self:parseView()
    self:centerView()
    self:initData()
    self:initDialog()
    self:initLeftLayer()
    self:initProtocolData()
    self:adaptBgSize(self._imgBg)
end

function WareHouseModule:_onBtnWear(event)
    if event.name ~= "ended" then
        return
    end
    local index = 1
    local top_data = uq.cache.generals:getUpGeneralsByType(0)
    local generals_id = top_data[1].id
    uq.runCmd('open_general_attribute', {{generals_id = generals_id, index = index, tabIndex = 2}})
    self:disposeSelf()
end

function WareHouseModule:_onBtnDecompose(event)
    if event.name ~= "ended" then
        return
    end
    uq.runCmd('open_decompose')
end

function WareHouseModule:_onBtnUse(event)
    if event.name ~= "ended" or not self._curTableViewInfo then
        return
    end
    if self._tabIndex == 3 then
        local info = StaticData.getCostInfo(self._curTableViewInfo.type, self._curTableViewInfo.id)
        if not info then
            return
        end
        if info.type == uq.config.constant.BAG_TYPE.CHOOSABLE then
            uq.ModuleManager:getInstance():show(uq.ModuleManager.WAREHOURSE_LIST, {data = info, open_num = self._useNum})
        elseif info.type == uq.config.constant.BAG_TYPE.FUNC then
            network:sendPacket(Protocol.C_2_S_USE_FUNCPROPS, {id = self._curTableViewInfo.id, num = self._useNum})
        else
            network:sendPacket(Protocol.C_2_S_USE_CHEST, {id = self._curTableViewInfo.id, num = self._useNum, choose = 1})
        end
    elseif self._tabIndex == 2 or self._tabIndex == 4 then
        uq.ModuleManager:getInstance():show(uq.ModuleManager.INSIGHT_RES_FROM_MODULE, self._curTableViewInfo)
    elseif self._tabIndex == 1 then
        uq.ModuleManager:getInstance():show(uq.ModuleManager.GENERALS_EQUIP_INFO_MODULE, {info = self._curTableViewInfo})
    end
end

function WareHouseModule:getItemCostBack()
    if self._curTableViewInfo.type == uq.config.constant.COST_RES_TYPE.EQUIP then
        return self:getEquipCostBack()
    else
        return self:getResCostBack()
    end
end

function WareHouseModule:getResCostBack()
    local cost_xml = StaticData.getCostInfo(self._curTableViewInfo.type, self._curTableViewInfo.id)
    local cost_info = string.split(cost_xml.sell, ';')
    return tonumber(cost_info[1]), tonumber(cost_info[2]), 0, 0
end

function WareHouseModule:getEquipCostBack()
    local item_xml = StaticData['items'][self._curTableViewInfo.temp_id]
    local base_cost = uq.RewardType.new(item_xml.sell)
    local total_cost1 = base_cost:num()
    local type1 = base_cost:type()
    local type2 = 0
    local cost1 = 0
    local cost2 = 0
    local cost_array = StaticData['item_level'].getCost(self._curTableViewInfo.lvl)
    for _, v in ipairs(cost_array) do
        local reward_array = uq.RewardType.parseRewards(v)
        for k2, v2 in ipairs(reward_array) do
            if v2:type() == type1 then
                cost1 = cost1 + v2:num()
            else
                type2 = v2:type()
                cost2 = cost2 + v2:num()
            end
        end
    end
    total_cost1 = total_cost1 + math.floor(cost1 * 0.8)
    cost2 = math.floor(cost2 * 0.8)
    --洗练返还计算
    local pre_crit_info , crit_info = StaticData['item_back'].getCost(self._signleEquipInfo.epCritRate, uq.config.constant.TYPES_EFFECT.CRIT)
    local pre_beat_back_info, beat_back_info = StaticData['item_back'].getCost(self._signleEquipInfo.epBeatBackRate, uq.config.constant.TYPES_EFFECT.BEAT_BACK)
    local pre_dec_injure_info, dec_injure_info = StaticData['item_back'].getCost(self._signleEquipInfo.epDecInjureRate, uq.config.constant.TYPES_EFFECT.INJURY)
    if crit_info ~= nil and pre_crit_info ~= nil then
        local cur_type, cost = self:getClearCostBack(pre_crit_info, crit_info, self._signleEquipInfo.epCritRate)
        if cur_type == type1 then
            total_cost1 = total_cost1 + cost
        else
            cost2 = cost2 + cost
        end
    end
    if beat_back_info ~= nil and pre_beat_back_info ~= nil then
        local cur_type, cost = self:getClearCostBack(pre_beat_back_info, beat_back_info, self._signleEquipInfo.epBeatBackRate)
        if cur_type == type1 then
            total_cost1 = total_cost1 + cost
        else
            cost2 = cost2 + cost
        end
    end
    if dec_injure_info ~= nil and pre_dec_injure_info ~= nil then
        local cur_type, cost = self:getClearCostBack(pre_dec_injure_info, dec_injure_info, self._signleEquipInfo.epDecInjureRate)
        if cur_type == type1 then
            total_cost1 = total_cost1 + cost
        else
            cost2 = cost2 + cost
        end
    end
    return type1, total_cost1, type2, cost2
end

function WareHouseModule:getClearCostBack(pre_info, cur_info, value)
    local item_back_cost2 = uq.RewardType.new(cur_info.backCost)
    local item_back_cost1 = uq.RewardType.new(pre_info.backCost)
    local cost = math.floor((item_back_cost2:num() - item_back_cost1:num()) *
    (value - pre_info.effectValue) / (cur_info.effectValue - pre_info.effectValue) + item_back_cost1:num())
    return item_back_cost1:type(), cost
end

function WareHouseModule:_onBtnSell(event)
    if event.name ~= "ended" or self._curTableViewInfo.bind_type == 1 then
        return
    end
    if self._curTableViewInfo.type == uq.config.constant.COST_RES_TYPE.MATERIAL then
        self:onResSell()
    elseif self._curTableViewInfo.type == uq.config.constant.COST_RES_TYPE.EQUIP then
        self:onEquipSell()
    end
end

function WareHouseModule:sendSellMessage(pre_des, callback)
    local info = StaticData.getCostInfo(self._curTableViewInfo.type, self._curTableViewInfo.id)
    local type1, cost1, type2, cost2 = self:getItemCostBack()
    local cost_info1 = StaticData['types'].Cost[1].Type[type1]
    local cost_info2 = StaticData['types'].Cost[1].Type[type2]
    local reward = {}
    table.insert(reward, {type = type1, cost = cost1})
    if cost2 > 0 then
        table.insert(reward, {type = type2, cost = cost2})
    end
    local data = {
        content = pre_des,
        confirm_callback = callback,
        reward = reward
    }
    uq.addConfirmBox(data,uq.config.constant.CONFIRM_TYPE.EQUIP_SELL)
end

function WareHouseModule:onResSell()
    local info = StaticData.getCostInfo(self._curTableViewInfo.type, self._curTableViewInfo.id)
    if info == nil or self._curTableViewInfo.sell == "" then
        return
    end
    local function callback()
        network:sendPacket(Protocol.C_2_S_DO_SELL, {id = self._curTableViewInfo.id, num = 1})
    end
    local des = StaticData['local_text']['warehouse.res.sell.tip']
    self:sendSellMessage(des, callback)
end

function WareHouseModule:onEquipSell()
    local info = StaticData.getCostInfo(self._curTableViewInfo.type, self._curTableViewInfo.id)
    if info == nil then
        return
    end
    local function callback()
        if self._curTableViewInfo.lvl == 0 then
            network:sendPacket(Protocol.C_2_S_EQUIPMENT_SELL, {id = self._curTableViewInfo.db_id})
        else --先降级再卖
            network:sendPacket(Protocol.C_2_S_EQUIPMENT_ACTION, {equipmentId = self._curTableViewInfo.db_id,actionId = 3,upLevel = 1,isForceIntersify = 0})
        end
    end
    local des = StaticData['local_text']['warehouse.sell.item.des1']
    self:sendSellMessage(des, callback)
end

function WareHouseModule:initData()
    self._equipArray = {}
    self._spiritArray = {}
    self._resArray = {}
    self._itemArray = {}
    local equip_info = uq.cache.equipment:getAllEquipInfo()
    for _,v in pairs(equip_info) do
        if v.xml == nil then
            v.xml = StaticData['items'][v.temp_id]
        end
        v.id = v.temp_id
        v.type = uq.config.constant.COST_RES_TYPE.EQUIP
        table.insert(self._equipArray, v)
    end
    uq.cache.role.used_warehouse_num = #self._equipArray
    uq.cache.equipment:sortByQuality(self._equipArray)

    local data_json = uq.cache.role.materials_res
    for k,v in pairs(data_json) do
        for k2,v2 in pairs(v) do
            local info = {}
            info.type = tonumber(k)
            info.num = v2
            if info.num > 0 then
                info.id = tonumber(k2)
                info.xml = StaticData.getCostInfo(info.type, info.id)
                if info.xml and next(info.xml) ~= nil then
                    if not info.xml.bag and info.type == uq.config.constant.COST_RES_TYPE.SPIRIT then
                        table.insert(self._spiritArray, info)
                    elseif info.xml.bag == 2 or not info.xml.bag and info.type ~= uq.config.constant.COST_RES_TYPE.GENERALS then
                        table.insert(self._resArray,info)
                    elseif info.xml.bag == 3 then
                        table.insert(self._itemArray,info)
                    end
                end
            end
        end
    end
    self:sortCostByQuality(self._resArray)
    self:sortCostByQuality(self._itemArray)
end

function WareHouseModule:updateData()
    self._curTabInfo = {}
    if self._tabIndex == 1 then
        self._curTabInfo = self._equipArray
    elseif self._tabIndex == 2 then
        self._curTabInfo = self._resArray
    elseif self._tabIndex == 3 then
        self._curTabInfo = self._itemArray
    elseif self._tabIndex == 4 then
        self._curTabInfo = self._spiritArray
    end
    local has_item = #self._curTabInfo >= 1
    self._panelNull:setVisible(not has_item)
    self._curTabNum = math.floor((#self._curTabInfo + 4) / 5)
    if self._curTableViewIndex == -1 and #self._curTabInfo > 1 then
        self._curTableViewIndex = 1
        self._curTableViewInfo = self._curTabInfo[self._curTableViewIndex]
    end
end

function WareHouseModule:updateTabInfo(data)
    if not data then
        data = self._curTabInfo[self._curTableViewIndex] or self._curTabInfo[1]
    end
    if self._curTableViewInfo ~= nil then
        self._curTableViewInfo = data
    end
    if self._curTableViewInfo ~= nil and self._curTableViewInfo.type > 0 then
        self:updateInfo()
    else
        self._curTableViewIndex = -1
        self._panelItems:setVisible(false)
    end
end

function WareHouseModule:reloadDataNotScroll()
    local offset = self._tableView:getContentOffset();
    self._tableView:reloadData()
    if self._curTabNum > 4 then
        local new_offset = 650 - self._curTabNum * 126
        if new_offset > offset.y then
            offset.y = new_offset
        end
        self._tableView:setContentOffset(offset);
    end
end

function WareHouseModule:initLeftLayer()
    self._tabModuleArray = {}
    local tab_item = self._nodeMenu:getChildByName("Panel_1")
    local posx, posy = tab_item:getPosition()
    tab_item:removeSelf()
    local select_item = nil
    for k, v in ipairs(self._tabTxt) do
        local item = tab_item:clone()
        self._nodeMenu:addChild(item)
        item:setTag(k)
        item:getChildByName("txt"):setString(v)
        item:setPosition(posx, posy)
        item:setTouchEnabled(true)
        item:addClickEventListenerWithSound(function(sender)
            local tag = sender:getTag()
            if tag == self._tabIndex then
                return
            end
            self:onTabChanged(tag, true)
        end)
        posy = posy - item:getContentSize().height - 5
        table.insert(self._tabModuleArray, item)
    end
    self:onTabChanged(self._tabIndex)
end

function WareHouseModule:onTabChanged(tag, state)
    self._tabIndex = tag
    self._curTableViewIndex = -1
    self._curTableViewInfo = nil
    self._panelItems:setVisible(false)
    self:updateData()

    for k, v in ipairs(self._tabModuleArray) do
        v:getChildByName("img_select1"):setVisible(false)
        v:getChildByName("img_select2"):setVisible(false)
    end
    local img1 = self._tabModuleArray[self._tabIndex]:getChildByName("img_select1")
    local img2 = self._tabModuleArray[self._tabIndex]:getChildByName("img_select2")
    img1:setVisible(true)
    img2:setVisible(true)
    if state then
        img1:runAction(cc.RotateBy:create(0.15, -180))
        img2:runAction(cc.RotateBy:create(0.15, 180))
    end

    if #self._curTabInfo > 0 then
        self._curTableViewIndex = 1
        self._curTableViewInfo = self._curTabInfo[1]
    end
    self._tableView:reloadData()
    self:showAction()
end

function WareHouseModule:initProtocolData()
    self._eventUseChest = '_onUseChestWare' .. tostring(self)
    self._eventFuncProps = '_onFuncProps' .. tostring(self)
    network:addEventListener(Protocol.S_2_C_USE_CHEST, handler(self, self._onUseChestWare), self._eventUseChest)
    network:addEventListener(Protocol.S_2_C_BUY_WAREHOUSE_CELL, handler(self, self._onBuyWarehouseCell),'_onBuyWarehouseCell')
    network:addEventListener(Protocol.S_2_C_USE_FUNCPROPS, handler(self, self._onUseFuncProps), self._eventFuncProps)
    services:addEventListener(services.EVENT_NAMES.ON_UPDATE_EQUIPMENTINFO, handler(self, self._onUpdateEquipInfo), '_onUpdateEquipInfo')
    services:addEventListener(services.EVENT_NAMES.ON_SALE_EQUIPMENT, handler(self, self._onUpdateEquipInfo), '_onSaleEquipMent')
    services:addEventListener(services.EVENT_NAMES.ON_DRAW_EQUIPMENT, handler(self, self._onDrawEquipMent), '_onDrawEquipMent')
    network:addEventListener(Protocol.S_2_C_EQUIPMENT_ACTION, handler(self, self._onEquipmentAction), '_onEquipmentAction')
    services:addEventListener(services.EVENT_NAMES.ON_EQUIPMENT_ACTION, handler(self, self._onEquipChange), '_onEquipInfoChange' .. tostring(self))
    services:addEventListener(services.EVENT_NAMES.ON_BIND_EQUIP, handler(self, self._onEquipBindAction), '_onEquipBindAction')
    services:addEventListener(services.EVENT_NAMES.ON_CONSUME_RES_CHANGE, handler(self, self._onUpdateEquipInfo), '_onUseChest')
    services:addEventListener(services.EVENT_NAMES.ON_EQUIPMENT_BREAK_THROUGH, handler(self, self._refreshPage), "_onRisingResult" .. tostring(self))
    self._eventEquipLock = '_onEquipLock' .. tostring(self)
    network:addEventListener(Protocol.S_2_C_EQUIP_BIND, handler(self, self._onUpdateEquipInfo), self._eventEquipLock)
    self._checkBox:addEventListener(function(sender, eventType)
        network:sendPacket(Protocol.C_2_S_EQUIP_BIND, {eqid = self._curTableViewInfo.db_id, bind_type = eventType})
    end)
end

function WareHouseModule:removeProtocolData()
    services:removeEventListenersByTag("_onUpdateEquipInfo")
    services:removeEventListenersByTag("_onSaleEquipMent")
    services:removeEventListenersByTag("_onDrawEquipMent")
    network:removeEventListenerByTag("_onEquipmentAction")
    network:removeEventListenerByTag("_onBuyWarehouseCell")
    network:removeEventListenerByTag(self._eventUseChest)
    network:removeEventListenerByTag(self._eventFuncProps)
    network:removeEventListenerByTag(self._eventEquipLock)
    services:removeEventListenersByTag("_onEquipBindAction")
    services:removeEventListenersByTag("_onUseChest")
    services:removeEventListenersByTag("_onEquipInfoChange" .. tostring(self))
    services:removeEventListenersByTag("_onRisingResult" .. tostring(self))
end

function WareHouseModule:_refreshPage()
    self._equipArray = {}
    local equip_info = uq.cache.equipment:getAllEquipInfo()
    for _,v in pairs(equip_info) do
        if v.xml == nil then
            v.xml = StaticData['items'][v.temp_id]
        end
        v.id = v.temp_id
        v.type = uq.config.constant.COST_RES_TYPE.EQUIP
        table.insert(self._equipArray, v)
    end
    uq.cache.role.used_warehouse_num = #self._equipArray
    uq.cache.equipment:sortByQuality(self._equipArray)
    for k, v in ipairs(self._equipArray) do
        if self._curTableViewInfo.db_id == v.db_id then
            self._curTableViewInfo.index = k
            self._curTableViewInfo = v
            break
        end
    end
    self:updateData()
    self._tableView:reloadData()
end

function WareHouseModule:_onEquipChange(msg)
    self._tableView:reloadData()
end

function WareHouseModule:_onEquipBindAction(msg)
    if self._curTableViewInfo.db_id ~= msg.data.eqid then return end
    self._curTableViewInfo.bind_type = msg.data.bind_type
    local locked_state = self._curTableViewInfo.bind_type == 1
    self._checkBox:setSelected(not locked_state)
    local item = self._panelItem:getChildByName("item")
    if not item then
        return
    end
    item:refreshLockedImgState(locked_state)
    self._curSelectedItem:refreshLockedImgState(locked_state)
end

function WareHouseModule:_onUseFuncProps(evt)
    local data = evt.data or {}
    local info = StaticData.getCostInfo(uq.config.constant.COST_RES_TYPE.MATERIAL, data.id)
    if info and info.name then
        uq.fadeInfo(string.format(StaticData["local_text"]["warehouse.use.success"], info.name))
    end
end

function WareHouseModule:_onUseChestWare(evt)
    local data = evt.data
    if data.rwds and next(data.rwds) ~= nil then
        uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE,{rewards = data.rwds})
    end
end

function WareHouseModule:_onBuyWarehouseCell(evt)
    uq.cache.role.warehouse_num = evt.data.total_warehouse_num
    uq.cache.role.warehouse_draw_time = evt.data.draw_time
    uq.cache.role.total_online_time = uq.cache.role.warehouse_draw_time - uq.cache.role:getGameTime()
    uq.cache.equipment:updateRed()
    self:initData()
    self:updateData()
    self:reloadDataNotScroll()
end

function WareHouseModule:_onDrawEquipMent(msg)
    self:initData()
    self:updateData()
    self:reloadDataNotScroll()
    self:updateTabInfo(msg.data)
end

function WareHouseModule:_onUpdateEquipInfo()
    self:initData()
    self:updateData()
    self:updateTabInfo()
    self:reloadDataNotScroll()
end

function WareHouseModule:_onEquipmentAction(evt)
    if evt.data.ret == 0 and evt.data.actionId == 3 then
        network:sendPacket(Protocol.C_2_S_EQUIPMENT_SELL,{id = evt.data.epId})
    end
end

function WareHouseModule:sortCostByQuality(info) --对cost数据进行排序
    if info == nil or #info < 2 then
        return info
    end
    table.sort(info,function(a,b)
        if a.xml.qualityType == b.xml.qualityType then
            return tonumber(a.xml.ident) > tonumber(b.xml.ident)
        end
        return tonumber(a.xml.qualityType) > tonumber(b.xml.qualityType)
    end)
end

function WareHouseModule:updateEquipInfo()
    self._btnWear:setVisible(true)
    local state = self._curTableViewInfo.general_id == nil or self._curTableViewInfo.general_id == 0
    self._btnWear1:setVisible(state)
    self._btnWear2:setVisible(state)
    self._checkBox:setSelected(self._curTableViewInfo.bind_type == 0)
    local item_xml = StaticData['items'][self._curTableViewInfo.temp_id]
    if not item_xml then
        uq.log("error WareHouseModule:updateEquipInfo ")
    end
    self._panelItems:setVisible(true)
    uq.intoAction(self._panelItems)
    self._scrollView:setVisible(false)

    for i = 1, 3 do
        local state = self._curTableViewInfo.attributes[i] ~= nil
        self._arrTitle[i]:setVisible(state)
        self._arrValue[i]:setVisible(state)
        if state then
            local info = self._curTableViewInfo.attributes[i]
            local effect_info = StaticData['types'].Effect[1].Type[info.attr_type]
            local value = uq.cache.generals:getNumByEffectType(info.attr_type, info.value)
            self._arrTitle[i]:setString(effect_info.name)
            self._arrValue[i]:setString(value)
        end
    end

    local pre_value = uq.cache.equipment:getBaseValue(self._curTableViewInfo.db_id)
    self._baseNumLabel:setString("+" .. pre_value)
    local effect_info = StaticData['types'].Effect[1].Type[self._curTableViewInfo.xml.effectType]
    if not effect_info then
        return
    end
    self._txtBaseName:setString(effect_info.name)

    self._labelNoSuit:setVisible(item_xml.suitId == nil)
    self._scrollEquip:removeAllChildren()
    if item_xml.suitId then
        local suit_data = StaticData['item_suit'][item_xml.suitId]
        local arr_suit = string.split(suit_data.suitEffect, '|')
        local height = #arr_suit * 30 + 22
        local size = self._scrollEquip:getContentSize()
        if size.height < height then
            self._scrollEquip:setInnerContainerSize(cc.size(size.width, height))
        end
        local pos_y = math.ceil(size.height, height)
        local text = self:getLabel(22, "#f6ff61")
        text:setString(suit_data.name)
        text:setPosition(cc.p(10, pos_y))
        pos_y = pos_y - 32
        self._scrollEquip:addChild(text)
        for k, v in ipairs(arr_suit) do
            local str_info = string.split(v, ',')
            local text = self:getLabel(20)
            text:setString(string.format(StaticData['local_text']['equip.suit.cur.num'], str_info[1]))
            text:setPosition(cc.p(10, pos_y))
            self._scrollEquip:addChild(text)

            local type_info = StaticData['types'].Effect[1].Type[tonumber(str_info[2])]
            local text = self:getLabel(20)
            local value = uq.cache.generals:getNumByEffectType(tonumber(str_info[2]), tonumber(str_info[3]))
            text:setString(type_info.name .. "  +" ..value)
            text:setPosition(cc.p(100, pos_y))
            self._scrollEquip:addChild(text)
            pos_y = pos_y - 30
        end
    end
    self._btnWear:getChildByName("label_name_0"):setString(StaticData['local_text']['label.common.strength'])
    self._btnWear:setPositionX(-255)

    local pre_score = effect_info.score
    if not pre_score then
        return
    end
    local total_score = math.ceil(item_xml.effectType * pre_score)
    self._resNum:setString(string.format(StaticData['local_text']['label.equip.to2'], total_score))

end

function WareHouseModule:updateResInfo()
    local desc = StaticData['local_text']['label.use']
    local state = self._tabIndex == 2 or self._tabIndex == 4
    self._panelUse:setVisible(not state)
    if state then
        desc = StaticData['local_text']['insight.res.from.title']
    end
    self._btnWear:getChildByName("label_name_0"):setString(desc)
    self._btnWear:setPositionX(-257)
    local type_cost = StaticData.getCostInfo(self._curTableViewInfo.type,self._curTableViewInfo.id)
    if not type_cost then
        uq.log("updateResInfo  ",self._curTableViewInfo.type,self._curTableViewInfo.id)
        return
    end
    self._btnWear:setVisible(true)
    local size = self._scrollView:getContentSize()
    self._panelItems:setVisible(true)
    uq.intoAction(self._panelItems)
    self._scrollView:setVisible(true)
    self._scrollView:setScrollBarEnabled(false)
    self._scrollView:removeAllChildren()
    self:updateScroll(0)
    local max_num = uq.cache.role:getResNum(self._curTableViewInfo.type, self._curTableViewInfo.id)
    local limit_num = 99
    if type_cost.type == uq.config.constant.BAG_TYPE.FUNC then
        limit_num = 999
    end
    self._maxUseNum = max_num > limit_num and limit_num or max_num
    self._resNum:setString(max_num)
    self._useNum = self._maxUseNum
    self._txtUseNum:setString(self._useNum .. '/' .. self._maxUseNum)
    local precent = self._useNum / self._maxUseNum * 100
    self._slider:setPercent(precent)
end

function WareHouseModule:updateScroll(sttype)
    local scroll_size = self._scrollView:getContentSize()
    local type_cost = StaticData.getCostInfo(self._curTableViewInfo.type,self._curTableViewInfo.id)
    local desc = ''
    if self._curTableViewInfo.type == uq.config.constant.COST_RES_TYPE.SPIRIT then
        local total_num = self._curTableViewInfo.xml.composeNums
        desc = string.format(StaticData['types'].Cost[1].Type[self._curTableViewInfo.type].desc, total_num, self._curTableViewInfo.xml.name, self._curTableViewInfo.xml.name)
    else
        desc = type_cost.desc
    end
    local height = scroll_size.height
    local lbl_tips = self:getLabel()
    lbl_tips:setPositionY(height)
    lbl_tips:setContentSize(cc.size(scroll_size.width, 60))
    lbl_tips:setHTMLText(desc, nil, nil, nil, true)
    self._scrollView:setTouchEnabled(false)
    self._scrollView:addChild(lbl_tips)
end

function WareHouseModule:updateScrollInfo(info)
    local item_cost = StaticData['types'].Cost[1].Type[tonumber(info[1])]
    local item_name = ""
    local item_num = tonumber(info[2])
    if item_cost ~= nil then
        if tonumber(info[0]) == uq.config.constant.COST_RES_TYPE.EQUIP then --装备
            local item_xml = StaticData['items'][tonumber(info[3])]
            item_name = item_xml == nil and "" or item_xml.name
        end
        local lbl_desc = self:getLabel()
        lbl_desc:setPositionY(self._scrollHeight)
        lbl_desc:setString("["..item_cost.name.."]"..item_name.." +"..item_num)
        self._scrollView:addChild(lbl_desc)
        self._scrollHeight = self._scrollHeight - lbl_desc:getContentSize().height - 2
    end
end

function WareHouseModule:getLabel(size, color, font)
    size = size or 26
    font = font or "font/hwkt.ttf"
    color = color or "#ffffff"
    local lbl_desc = ccui.Text:create()
    lbl_desc:setFontSize(size)
    lbl_desc:setFontName(font)
    lbl_desc:setTextColor(uq.parseColor(color))
    lbl_desc:setAnchorPoint(cc.p(0, 1))
    lbl_desc:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    return lbl_desc
end

function WareHouseModule:updateInfo()
    self._panelNull:setVisible(false)
    local item = EquipItem:create({info = self._curTableViewInfo})
    item._nameLabel:setVisible(false)
    self._panelItem:removeAllChildren()
    item:setName("item")
    self._panelItem:addChild(item)
    item:showName(false)
    item:setPosition(cc.p(self._panelItem:getContentSize().width * 0.5,self._panelItem:getContentSize().height * 0.5))
    local xml_info = StaticData.getCostInfo(self._curTableViewInfo.type,self._curTableViewInfo.id)
    local item_quality_info = StaticData['types'].ItemQuality[1].Type[tonumber(xml_info.qualityType)]
    self._nameLabel:setString(xml_info.name)
    self._txtQualtiy:setString(string.format(StaticData['local_text']['equip.item.quality'], item_quality_info.name, item_quality_info.ident))
    if item_quality_info then
        self._nameLabel:setTextColor(uq.parseColor(item_quality_info.color))
        self._txtQualtiy:setTextColor(uq.parseColor(item_quality_info.color))
    end
    self._panelEquip:setVisible(false)
    self._panelRes:setVisible(false)
    if self._tabIndex == 1 then
        if self._curTableViewInfo.xml == nil then
            self._curTableViewInfo.xml = StaticData['items'][self._curTableViewInfo.temp_id]
        end
        self._panelEquip:setVisible(true)
        self:updateEquipInfo()
        self._txtTips:setString(StaticData['local_text']['label.equip.to2'])
    else        --资源
        self._panelRes:setVisible(true)
        self:updateResInfo()
        self._txtTips:setString(StaticData['local_text']['warehouse.equip.has.num'])
    end
end

function WareHouseModule:initDialog()
    self._btnWear:setPressedActionEnabled(true)
    self._panelItems:setVisible(false)
    self:initTableView()

    self._slider:addEventListener(function(sender, event_type)
        if event_type == 1 then
            return
        end
        local precent = sender:getPercent()
        self._useNum = math.ceil(precent * self._maxUseNum / 100)
        self._txtUseNum:setString(self._useNum .. '/' .. self._maxUseNum)

        if event_type == 2 then
            self:updateSliderPrecent()
        end
    end)
end

function WareHouseModule:updateSliderPrecent()
    if self._useNum == 0 then
        self._useNum = 1
    end
    local precent = self._useNum / self._maxUseNum * 100
    self._slider:setPercent(precent)
    self._txtUseNum:setString(self._useNum .. '/' .. self._maxUseNum)
end

function WareHouseModule:_onDeleteUseNum(event)
    if event.name ~= "ended" then
        return
    end
    if self._useNum == 1 then
        return
    end
    self._useNum = self._useNum - 1
    self:updateSliderPrecent()
end

function WareHouseModule:_onAddUseNum(event)
    if event.name ~= "ended" then
        return
    end
    if self._useNum == self._maxUseNum then
        return
    end
    self._useNum = self._useNum + 1
    self:updateSliderPrecent()
end

function WareHouseModule:initTableView()
    local size = self._panelTableView:getContentSize()
    self._tableView = cc.TableView:create(cc.size(size.width,size.height))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setAnchorPoint(cc.p(0,0))
    self._tableView:setDelegate()
    self._panelTableView:addChild(self._tableView)

    self._tableView:registerScriptHandler(handler(self,self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
end

function WareHouseModule:cellSizeForTable(view, idx)
    return 735, 125
end

function WareHouseModule:numberOfCellsInTableView(view)
    return self._curTabNum
end

function WareHouseModule:tableCellTouched(view, cell,touch)
    local touch_point = touch:getLocation()
    local index = cell:getIdx() * 5 + 1
    for i = 0, 4, 1 do
        local item = cell:getChildByName("item"..i)
        if item == nil then
            return
        end
        local pos=item:convertToNodeSpace(touch_point)
        local rect=cc.rect(0,0,item:getContentSize().width,item:getContentSize().height)
        if cc.rectContainsPoint(rect, pos) then
            if self._curTableViewIndex == index then
                return
            end
            if not self._curTabInfo[index] then
                return
            end
            if self._curTabInfo[index].type < 0 then
                return
            end
            for _,v in ipairs(self._cellArray) do
                v:setSelectImgVisible(false)
            end
            self._curTableViewIndex = index
            self._curTableViewInfo = self._curTabInfo[index]
            self._curSelectedItem = item
            item:setSelectImgVisible(true)
            self:updateInfo()
            uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
            break
        end
        index = index + 1
    end
end

function WareHouseModule:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx * 5 + 1
    if not cell then
        cell = cc.TableViewCell:new()
        for i = 0, 4, 1 do
            local info = self._curTabInfo[index]
            local width = 0
            local euqip_item = nil
            if info ~= nil then
                euqip_item = EquipItem:create({info = info})
                width = euqip_item:getContentSize().width
                euqip_item:setScale(0.9)
                euqip_item:setPosition(cc.p((width * 0.5 + 20) * 0.9 + (width + 15) * i * 0.9 - 10, 60))
                cell:addChild(euqip_item, 1)
                euqip_item:setName("item" .. i)
                table.insert(self._cellArray, euqip_item)
                if self._tabIndex == 1 then
                    if self._curTableViewInfo and info.db_id and self._curTableViewInfo.db_id == info.db_id then
                        euqip_item:setSelectImgVisible(true)
                        self._curSelectedItem = euqip_item
                        self:updateInfo()
                    end
                else
                    if self._curTableViewInfo and info.id and self._curTableViewInfo.id == info.id then
                        euqip_item:setSelectImgVisible(true)
                        self._curSelectedItem = euqip_item
                        self:updateInfo()
                    end
                end
            else
                euqip_item = EquipItem:create()
                width = euqip_item:getContentSize().width
                euqip_item:setScale(0.9)
                euqip_item:setPosition(cc.p((width * 0.5 + 20) * 0.9 + (width + 15) * 0.9 * i - 10, 60))
                cell:addChild(euqip_item, 1)
                euqip_item:setName("item" .. i)
                euqip_item:setVisible(false)
                table.insert(self._cellArray, euqip_item)
            end
            index = index + 1
        end
    else
        for i = 0, 4, 1 do
            local info = self._curTabInfo[index]
            local euqip_item = cell:getChildByName("item" .. i)
            if info ~= nil then
                euqip_item:setInfo(info)
                euqip_item:setVisible(true)
                if self._tabIndex == 1 then
                    if self._curTableViewInfo and info.db_id and self._curTableViewInfo.db_id == info.db_id then
                        euqip_item:setSelectImgVisible(true)
                        self._curSelectedItem = euqip_item
                        self:updateInfo()
                    end
                else
                    if self._curTableViewInfo and info.id and self._curTableViewInfo.id == info.id then
                        euqip_item:setSelectImgVisible(true)
                        self._curSelectedItem = euqip_item
                        self:updateInfo()
                    end
                end
            elseif euqip_item then
                euqip_item:setVisible(false)
            end
            index = index + 1
        end
    end
    return cell
end

function WareHouseModule:showAction()
    for k, v in pairs(self._cellArray) do
       uq.intoAction(v)
    end
end

function WareHouseModule:dispose()
    if self._topUI then
        self._topUI:dispose()
    end
    uq.TimerProxy:removeTimer("expire_time")
    self:removeProtocolData()
    WareHouseModule.super.dispose(self)
    display.removeUnusedSpriteFrames()
end

return WareHouseModule
