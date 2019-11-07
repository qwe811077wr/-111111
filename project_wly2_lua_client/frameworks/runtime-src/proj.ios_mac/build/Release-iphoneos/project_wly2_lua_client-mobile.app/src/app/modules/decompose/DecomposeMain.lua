local DecomposeMain = class("DecomposeMain", require('app.modules.common.BaseViewWithHead'))
local EquipItem = require("app.modules.common.EquipItem")

DecomposeMain.RESOURCE_FILENAME = "decompose/DecomposeMain.csb"
DecomposeMain.RESOURCE_BINDING = {
    ["Image_16"]          ={["varname"]="_imgBg"},
    ["left_btn_pnl"]      ={["varname"]="_pnlBtnLeft"},
    ["tab_node"]          ={["varname"]="_nodeMenu"},
    ["reward_node"]       ={["varname"]="_nodeReward"},
    ["setting_node"]      ={["varname"]="_nodeSetting"},
    ["clone_pnl"]         ={["varname"]="_pnlClone"},
    ["Node_5"]            ={["varname"]="_nodeTitle"},
    ["ok_btn"]            ={["varname"]="_btnOk",["events"] = {{["event"] = "touch",["method"] = "_onOk"}}},
    ["ok_btn_0"]          ={["varname"]="_btnOk",["events"] = {{["event"] = "touch",["method"] = "_onOkEquip"}}},
    ["Node_10"]           ={["varname"]="_nodeScreen"},
    ["Panel_27"]          ={["varname"]="_pnlBackScreen",["events"] = {{["event"] = "touch",["method"] = "_onCloseScreen"}}},
    ["Panel_27_0"]        ={["varname"]="_pnlBackSort",["events"] = {{["event"] = "touch",["method"] = "_onCloseSort"}}},
    ["setting_btn"]       ={["varname"]="_btnSetting",["events"] = {{["event"] = "touch",["method"] = "_onSetting"}}},
    ["btn_node"]          ={["varname"]="_nodeScreenMenu"},
    ["sel_btn"]           ={["varname"]="_btnSelect",["events"] = {{["event"] = "touch",["method"] = "_onQuickSelect"}}},
    ["title_1_txt"]       ={["varname"]="_txtTitle1"},
    ["title_2_txt"]       ={["varname"]="_txtTitle2"},
    ["sort_btn"]          ={["varname"]="_btnSort",["events"] = {{["event"] = "touch",["method"] = "_onSort"}}},
    ["sort_btn_0"]        ={["varname"]="_btnSort1",["events"] = {{["event"] = "touch",["method"] = "_onSort"}}},
    ["Node_14"]           ={["varname"]="_nodeSort"},
    ["Panel_tableview"]   ={["varname"]="_panelTableView"},
    ["rarity_btn"]        ={["varname"]="_btnRarity",["events"] = {{["event"] = "touch",["method"] = "_onRarity"}}},
    ["Button_7"]          ={["varname"]="_btnRarity1",["events"] = {{["event"] = "touch",["method"] = "_onChangeSort"}}},
    ["Button_7_0"]        ={["varname"]="_btnRarity2",["events"] = {{["event"] = "touch",["method"] = "_onChangeSort"}}},
    ["Button_7_1"]        ={["varname"]="_btnRarity3",["events"] = {{["event"] = "touch",["method"] = "_onChangeSort"}}},
    ["sort_1_img"]        ={["varname"]="_imgSort1"},
    ["sort_2_img"]        ={["varname"]="_imgSort2"},
    ["sort_3_img"]        ={["varname"]="_imgSort3"},
    ["num_txt"]           ={["varname"]="_txtNum"},
    ["ScrollView_1"]      ={["varname"]="_scrollView"},
    ["equip_btn_txt"]     ={["varname"]="_txtEquipBtn"},
}
DecomposeMain.TXT_TYPE = {
    StaticData['local_text']["label.equip"],
    StaticData['local_text']["label.resource"],
    StaticData['local_text']["label.prop"],
}

DecomposeMain.SORT_TYPE = {
    UP_LV = 1,
    STAR = 2,
    RARITY = 3,
}

DecomposeMain.BTN_TYPE = {
    EQUIP = 1,
    RES   = 2,
    PROP  = 3,
}

DecomposeMain.SORT_NAME = {
    StaticData['local_text']["decompose.up.lv"],
    StaticData['local_text']["decompose.star"],
    StaticData['local_text']["decompose.rarity"],
}

DecomposeMain.SORT_UP_DOWN = {
    StaticData['local_text']["decompose.sort.up"],
    StaticData['local_text']["decompose.sort.down"],
}

function DecomposeMain:ctor(name, params)
    DecomposeMain.super.ctor(self, name, params)

    self._selPropNum = 0
    self._maxPropNum = 99
    self._isUpSort = true
    self._tabModuleArray = {}
    self._tabScreen = {}
    self._tabScreenState = uq.cache.decree:getDecompose()
    self._allData = {}
    self._listData = {}
    self._cellArray = {}
    self._tabSelect = {}
    self._tabReward = {}
    self._tabIndex = self.BTN_TYPE.EQUIP
    self._sortType = self.SORT_TYPE.RARITY
    self._tabName = StaticData['types'].ItemQuality[1].Type
    self:addShowCoinGroup({uq.config.constant.COST_RES_TYPE.MONEY, uq.config.constant.COST_RES_TYPE.GOLDEN})
    self:setTitle(uq.config.constant.MODULE_ID.DECOMPOSE)
    self:setRuleId(uq.config.constant.MODULE_RULE_ID.DECOMPOSE)
    self:centerView()
    self:parseView()
    self:adaptBgSize(self._imgBg)
    self:dealData()
    self:initTableView()
    self:initLayer()
    self:initScreenLayer()
    self:initLeftLayer()
    self._eventMultipleDoSell = '_onMultipleDoSell' .. tostring(self)
    network:addEventListener(Protocol.S_2_C_MULTIPLE_DO_SELL, handler(self, self._onDoSell), self._eventMultipleDoSell)
    self._eventEquipSell = '_onEquipDoSell' .. tostring(self)
    network:addEventListener(Protocol.S_2_C_EQUIPMENT_MULTIPLE_SELL, handler(self, self._onDoSell), self._eventEquipSell)
    self._eventEquipLock = '_onEquipLock' .. tostring(self)
    network:addEventListener(Protocol.S_2_C_EQUIP_BIND, handler(self, self._onEquipBindAction), self._eventEquipLock)
end

function DecomposeMain:initLayer()
    self._nodeReward:setVisible(false)
    self._nodeSetting:setVisible(false)
    self._btnOk:setVisible(false)
    self._nodeScreen:setVisible(false)
    self._nodeSort:setVisible(false)
    self._nodeTitle:setVisible(self._tabIndex == self.BTN_TYPE.EQUIP)
    local str = self._isUpSort and self.SORT_UP_DOWN[1] or self.SORT_UP_DOWN[2]
    self._txtTitle2:setString(str)
    self._txtTitle1:setString(self.SORT_NAME[self._sortType])
end

function DecomposeMain:initTableView()
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

function DecomposeMain:cellSizeForTable(view, idx)
    return 630, 125
end

function DecomposeMain:numberOfCellsInTableView(view)
    return math.ceil(#self._listData / 5)
end

function DecomposeMain:tableCellTouched(view, cell,touch)
end

function DecomposeMain:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx * 5 + 1
    if not cell then
        cell = cc.TableViewCell:new()
        for i = 0, 4, 1 do
            local info = self._listData[index]
            local width = 0
            local euqip_item = nil
            if info ~= nil then
                euqip_item = EquipItem:create({info = info})
                if self._tabIndex == self.BTN_TYPE.EQUIP then
                    euqip_item:setUnlockSelect(info.general_id <= 0, true)
                else
                    euqip_item:setUnlockSelect(info.sell == 1)
                end
                euqip_item:enableEvent(nil, handler(self,self._endHandler))
                euqip_item:setSwallow(false)
            else
                euqip_item = EquipItem:create()
                euqip_item:setVisible(false)
            end
            width = euqip_item:getContentSize().width
            euqip_item:setScale(0.9)
            euqip_item:setPosition(cc.p((width * 0.5 + 20) * 0.9 + (width + 10) * 0.9 * i - 12, 60))
            cell:addChild(euqip_item, 1)
            euqip_item:setName("item" .. i)
            table.insert(self._cellArray, euqip_item)
            index = index + 1
        end
    else
        for i = 0, 4, 1 do
            local info = self._listData[index]
            local euqip_item = cell:getChildByName("item" .. i)
            if info ~= nil then
                euqip_item:setInfo(info)
                euqip_item:setVisible(true)
                local is_sel = false
                if self._tabIndex == self.BTN_TYPE.EQUIP then
                    euqip_item:setUnlockSelect(info.general_id <= 0, true)
                    is_sel = self:isSelected(info.db_id)
                else
                    euqip_item:setUnlockSelect(info.sell == 1)
                    is_sel = self:isSelected(info.id)
                end
                euqip_item:setSelectItems(is_sel)
                euqip_item:enableEvent(nil, handler(self, self._endHandler))
                euqip_item:setSwallow(false)
            elseif euqip_item then
                euqip_item:setVisible(false)
            end
            index = index + 1
        end
    end
    return cell
end

function DecomposeMain:_endHandler(info)
    if self._tabIndex == self.BTN_TYPE.EQUIP then
        if info.general_id > 0 then
            return
        end
        if info.bind_type == 1 then
            uq.fadeInfo(StaticData["local_text"]["decompose.awary.btn"])
            return
        end
        local is_sel = self:isSelected(info.db_id)
        if not is_sel and self._maxPropNum <= self._selPropNum then
            uq.fadeInfo(StaticData["local_text"]["decompose.num.is.max"])
            return
        end
        self._tabSelect[info.db_id] = is_sel and 0 or 1
        local change_num = is_sel and -1 or 1
        self._selPropNum = self._selPropNum + change_num
        self:addOneEquip(info, not is_sel)
        self:refreshBoxsSelect()
        return
    end
    if info.sell == 0 then
        return
    end
    if self:isSelected(info.id) then
        self._selPropNum = self._selPropNum - self._tabSelect[info.id]
        self:addDecomposeReward(info.xml.sell, self._tabSelect[info.id], false)
        self._tabSelect[info.id] = 0
        self:refreshBoxsSelect()
        return
    end
    if self._maxPropNum <= self._selPropNum then
        uq.fadeInfo(StaticData["local_text"]["decompose.num.is.max"])
        return
    end
    local res_num = uq.cache.role:getResNum(info.type, info.id)
    if res_num == 1 then
        self:addPropNum(info, 1)
        return
    end
    local max_num = math.min(res_num, self._maxPropNum - self._selPropNum)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.DECOMPOSE_NUM, {moduleType = uq.ModuleManager.DECOMPOSE_NUM, func = handler(self, self.addPropNum), info = info, max_num = max_num})
end

function DecomposeMain:addPropNum(info, num)
    self._selPropNum = self._selPropNum + num
    self._tabSelect[info.id] = num
    self:addDecomposeReward(info.xml.sell, num, true)
    self:refreshBoxsSelect()
end

function DecomposeMain:refreshBoxsSelect()
    for i, v in ipairs(self._cellArray) do
        if v:isVisible() then
            local info = v:getEquipInfo()
            local is_sel = false
            if self._tabIndex == self.BTN_TYPE.EQUIP then
                is_sel = self:isSelected(info.db_id)
            else
                is_sel = self:isSelected(info.id)
            end
            v:setSelectItems(is_sel)
        end
    end
    local is_open = self._selPropNum > 0
    self._nodeReward:setVisible(is_open)
    local str = is_open and StaticData["local_text"]["decompose.cacel.select"] or StaticData["local_text"]["decompose.fast.sel"]
    self._txtEquipBtn:setString(str)
    if is_open then
        self:refreshRewardLayer()
    end
end

function DecomposeMain:refreshRewardLayer()
    self:refreshScrollView()
    self._txtNum:setHTMLText(string.format(StaticData["local_text"]["decompose.sel.num"], self._selPropNum, self._maxPropNum))
end

function DecomposeMain:refreshScrollView()
    local tab_scroll = self:getDecomposeReward()
    self._scrollView:removeAllChildren()
    for i = 1, #tab_scroll do
        local item = EquipItem:create()
        item:setTouchEnabled(true)
        item:setPosition(cc.p((i - 0.5) * 80, 50))
        item:setScale(0.6)
        item:setInfo(tab_scroll[i])
        item:addClickEventListenerWithSound(function(sender)
                local info = sender:getEquipInfo()
                uq.showItemTips(info)
                end)
        self._scrollView:addChild(item)
    end
    self._scrollView:setScrollBarEnabled(false)
    self._scrollView:setInnerContainerSize(cc.size(#tab_scroll * 80 * 0.6, 50))
end

function DecomposeMain:isSelected(id)
    return self._tabSelect[id] and self._tabSelect[id] > 0
end

function DecomposeMain:initLeftLayer()
    local posx, posy = self._pnlBtnLeft:getPosition()
    local select_item = nil
    self._pnlBtnLeft:setVisible(false)
    for i, v in ipairs(self.TXT_TYPE) do
        local item = self._pnlBtnLeft:clone()
        item:setVisible(true)
        self._nodeMenu:addChild(item)
        item:setTag(i)
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

function DecomposeMain:onTabChanged(tag, state)
    self._tabIndex = tag
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
    local is_show = self._tabIndex == self.BTN_TYPE.EQUIP
    self._tabSelect = {}
    self._nodeSetting:setVisible(is_show)
    self._btnOk:setVisible(not is_show)
    self._nodeTitle:setVisible(is_show)
    self._selPropNum = 0
    self._tabReward = {}
    self:refreshListData()
    self._nodeReward:setVisible(false)
    if is_show then
        self._txtEquipBtn:setString(StaticData["local_text"]["decompose.fast.sel"])
    end
end

function DecomposeMain:initScreenLayer()
    self._pnlClone:setVisible(false)
    for i = 1, 7 do
        local pnl = self._pnlClone:clone()
        pnl:setVisible(true)
        pnl:setPosition(self:getPosScreen(i))
        self._nodeScreenMenu:addChild(pnl)
        pnl.img_up = pnl:getChildByName("up_img")
        pnl.img_down = pnl:getChildByName("down_img")
        pnl.txtName = pnl:getChildByName("Text_40")
        pnl.txtName:setString(self._tabName[i].name)
        pnl.txtName:setTextColor(uq.parseColor("#" .. self._tabName[i].color))
        pnl:addClickEventListenerWithSound(function()
            self:selectScreenByIdx(i, true)
        end)
        table.insert(self._tabScreen, pnl)
    end
    self:selectScreenByIdx(1, false)
end

function DecomposeMain:refreshListData()
    if self._tabIndex == self.BTN_TYPE.EQUIP then
        self._listData = self:dealEquip()
    else
        self._listData = self._allData[self._tabIndex]
    end
    self._tableView:reloadData()
end

function DecomposeMain:getPosScreen(idx)
    local ox = idx % 2 == 0 and 90 or -20
    local oy = -(math.ceil(idx / 2) - 1) * 40 - 15
    return cc.p(ox - 10, oy)
end

function DecomposeMain:selectScreenByIdx(idx, is_select)
    if is_select then
        self._tabScreenState[idx] = self._tabScreenState[idx] == 0 and 1 or 0
    end
    for i, v in ipairs(self._tabScreen) do
        local is_show = self._tabScreenState[i] == 1
        v.img_up:setVisible(is_show)
        v.img_down:setVisible(not is_show)
    end
end

function DecomposeMain:_onOk(event)
    if event.name ~= "ended" then
        return
    end
    if self._selPropNum <= 0 then
        uq.fadeInfo(StaticData["local_text"]["decompose.please.sel"])
        return
    end
    local tab = {}
    for k, v in pairs(self._tabSelect) do
        if v > 0 then
            table.insert(tab, {['id'] = k, ['num'] = v})
        end
    end
    local data = {
        count = #tab,
        sell_item = tab,
    }
    network:sendPacket(Protocol.C_2_S_MULTIPLE_DO_SELL, data)
end

function DecomposeMain:_onOkEquip(event)
    if event.name ~= "ended" then
        return
    end
    if self._selPropNum <= 0 then
        uq.fadeInfo(StaticData["local_text"]["decompose.please.sel"])
        return
    end
    local tab = {}
    for k, v in pairs(self._tabSelect) do
        if v > 0 then
            table.insert(tab, k)
        end
    end
    local data = {
        count = #tab,
        dbid = tab,
    }
    network:sendPacket(Protocol.C_2_S_EQUIPMENT_MULTIPLE_SELL, data)
end

function DecomposeMain:_onCloseScreen(event)
    if event.name ~= "ended" then
        return
    end
    self._nodeScreen:setVisible(false)
end

function DecomposeMain:_onSetting(event)
    if event.name ~= "ended" then
        return
    end
    self:refreshScreenLayer(true)
end

function DecomposeMain:_onQuickSelect(event)
    if event.name ~= "ended" then
        return
    end
    if self._selPropNum > 0 then
        self._tabSelect = {}
        self._selPropNum = 0
        self._tabReward = {}
        self:refreshBoxsSelect()
        return
    end
    local is_sel = false
    for i, v in ipairs(self._tabScreenState) do
        if v == 1 then
            is_sel = true
        end
    end
    if not is_sel then
        uq.fadeInfo(StaticData["local_text"]["decompose.not.type"])
        return
    end
    local is_ok = false
    for i, v in ipairs(self._listData) do
        if v.general_id <= 0 and v.bind_type ~= 1 and self._tabScreenState[v.qualityType] == 1 then
            if not is_ok then
                is_ok = true
                self._tabSelect = {}
                self._selPropNum = 0
                self._tabReward = {}
            end
            self._tabSelect[v.db_id] = 1
            self._selPropNum = self._selPropNum + 1
            self:addOneEquip(v, true)
            if self._selPropNum >= self._maxPropNum then
                break
            end
        end
    end
    local str = is_ok and StaticData["local_text"]["decompose.finish.sel"] or StaticData["local_text"]["decompose.less.sel"]
    uq.fadeInfo(str)
    if not is_ok then
        return
    end
    self:refreshBoxsSelect()
end

function DecomposeMain:_onSort(event)
    if event.name ~= "ended" then
        return
    end
    self._isUpSort = not self._isUpSort
    local str = self._isUpSort and self.SORT_UP_DOWN[1] or self.SORT_UP_DOWN[2]
    self._txtTitle2:setString(str)
    self:refreshListData()
    self:refreshBoxsSelect()
    self._btnSort:setVisible(self._isUpSort)
    self._btnSort1:setVisible(not self._isUpSort)
end

function DecomposeMain:_onCloseSort(event)
    if event.name ~= "ended" then
        return
    end
    self._nodeSort:setVisible(false)
end

function DecomposeMain:_onRarity(event)
    if event.name ~= "ended" then
        return
    end
    self._nodeSort:setVisible(true)
    for i = 1, 3 do
        self["_imgSort" .. i]:setVisible(self._sortType == i)
    end
end

function DecomposeMain:_onChangeSort(event)
    if event.name ~= "ended" then
        return
    end
    self._nodeSort:setVisible(false)
    local tag = event.target:getTag()
    if tag == self._sortType then
        return
    end
    self._sortType = tag
    self._txtTitle1:setString(self.SORT_NAME[self._sortType])
    self:refreshListData()
    self:refreshBoxsSelect()
end

function DecomposeMain:dealData()
    self._allData = {}
    for i = 1, 3 do
        table.insert(self._allData, {})
    end
    local equip_info = uq.cache.equipment:getAllEquipInfo()
    for _, v in pairs(equip_info) do
        if v.xml == nil then
            v.xml = StaticData['items'][v.temp_id]
        end
        v.id = v.temp_id
        v.type = uq.config.constant.COST_RES_TYPE.EQUIP
        v.qualityType = v.xml.qualityType
        table.insert(self._allData[self.BTN_TYPE.EQUIP], v)
    end

    local data_json = uq.cache.role.materials_res
    for k, v in pairs(data_json) do
        for k2, v2 in pairs(v) do
            local info = {}
            info.type = tonumber(k)
            info.num = v2
            if info.num > 0 then
                info.id = tonumber(k2)
                info.xml = StaticData.getCostInfo(info.type, info.id)
                if info.xml and next(info.xml) ~= nil then
                    if not info.xml.sell or info.xml.sell == "" then
                        info.sell = 0
                    else
                        info.sell = 1
                    end
                    if not info.xml.bag and info.type == uq.config.constant.COST_RES_TYPE.SPIRIT then
                    elseif info.xml.bag == 2 or not info.xml.bag and info.type ~= uq.config.constant.COST_RES_TYPE.GENERALS then
                        table.insert(self._allData[self.BTN_TYPE.RES], info)
                    elseif info.xml.bag == 3 then
                        table.insert(self._allData[self.BTN_TYPE.PROP], info)
                    end
                end
            end
        end
    end
    self:sortResByQuality(self._allData[self.BTN_TYPE.RES])
    self:sortResByQuality(self._allData[self.BTN_TYPE.PROP])
end

function DecomposeMain:dealEquip()
    local tab_equip = self._allData[self.BTN_TYPE.EQUIP] or {}
    if not tab_equip or next(tab_equip) == nil then
        return {}
    end
    local str_sort = {"general_id", "qualityType", "lvl", "id", "star", "db_id"}
    if self._sortType == self.SORT_TYPE.UP_LV then
        str_sort = {"general_id", "lvl", "qualityType", "id", "star", "db_id"}
    elseif self._sortType == self.SORT_TYPE.STAR then
        str_sort = {"general_id", "star", "lvl", "qualityType", "id", "db_id"}
    end
    table.sort(tab_equip, function (a, b)
        for i, v in ipairs(str_sort) do
            if a[v] ~= b[v] then
                if v == "general_id" then
                    return a[v] < b[v]
                end
                if self._isUpSort then
                    return a[v] < b[v]
                else
                    return a[v] > b[v]
                end
            end
        end
        return false
    end)
    return tab_equip
end

function DecomposeMain:sortResByQuality(info)
    if info == nil or #info < 2 then
        return info
    end
    table.sort(info, function(a, b)
        if a.sell ~= b.sell then
            return a.sell > b.sell
        end
        if a.xml.qualityType ~= b.xml.qualityType then
            return tonumber(a.xml.qualityType) < tonumber(b.xml.qualityType)
        end
        return tonumber(a.xml.ident) < tonumber(b.xml.ident)
    end)
end

function DecomposeMain:refreshScreenLayer(is_frist)
    self._nodeScreen:setVisible(true)
end

function DecomposeMain:addDecomposeReward(one_reward, num, is_add)
    local reward_array = uq.RewardType.parseRewards(one_reward)
    for k, v in pairs(reward_array) do
        local info = v:toEquipWidget()
        if not self._tabReward[info.type] then
            self._tabReward[info.type] = {}
        end
        if not self._tabReward[info.type][info.id] then
            self._tabReward[info.type][info.id] = 0
        end
        local num = is_add and num or -num
        self._tabReward[info.type][info.id] = self._tabReward[info.type][info.id] + info.num * num
    end
end

function DecomposeMain:getDecomposeReward()
    local reward = {}
    for k, v in pairs(self._tabReward) do
        for ik, iv in pairs(v) do
            if iv > 0 then
                table.insert(reward, {['type'] = k, ['num'] = iv, ['id'] = ik})
            end
        end
    end
    return reward
end

function DecomposeMain:addOneEquip(info, is_add)
    local str_sell = info.xml.sell
    if info.star > 0 then
        local tab_sell = uq.RewardType:create(info.xml.sell):toEquipWidget()
        str_sell = tab_sell.type .. ";" .. tab_sell.num * (info.star + 1) .. ";" .. tab_sell.id
    end
    self:addDecomposeReward(str_sell, 1, is_add)
    if info.lvl <= 0 then
        return
    end
    local all_cost = {}
    local tab = StaticData['item_level'].getCost(info.lvl)
    for i, v in ipairs(tab) do
        local reward_array = uq.RewardType.parseRewards(v)
        for ik, iv in pairs(reward_array) do
            local info = iv:toEquipWidget()
            if not all_cost[info.type] then
                all_cost[info.type] = {}
            end
            if not all_cost[info.type][info.id] then
                all_cost[info.type][info.id] = 0
            end
            all_cost[info.type][info.id] = all_cost[info.type][info.id] + info.num
        end
    end
    for k, v in pairs(all_cost) do
        for ik, iv in pairs(v) do
            self:addDecomposeReward(k .. ";" .. math.ceil(iv * 0.8) .. ";" .. ik, 1, is_add)
        end
    end
end

function DecomposeMain:_onDoSell(msg)
    local data = msg.data
    if data.rwds and next(data.rwds) ~= nil then
        uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE,{rewards = data.rwds})
    end
    uq.cache.equipment:removeItemTab(data.dbid)
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_GENERALS_MODULE_RED, data = {uq.cache.generals._GENERAL_SUB_PAGE.GENERAL_EQUIP}})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_ALL_GENERAL_RED, array = {uq.cache.generals._GENERAL_SUB_PAGE.GENERAL_EQUIP}})
    self:dealData()
    self:onTabChanged(self._tabIndex)
end

function DecomposeMain:_onEquipBindAction(msg)
    for i, v in ipairs(self._listData) do
        if v.bind_type == 1 and self._tabSelect[v.db_id] == 1 then
            self._tabSelect[v.db_id] = 0
            self._selPropNum = self._selPropNum - 1
            self:addDecomposeReward(v.xml.sell, 1, false)
        end
    end
    self:refreshListData()
    self:refreshBoxsSelect()
end

function DecomposeMain:dispose()
    network:removeEventListenerByTag(self._eventMultipleDoSell)
    network:removeEventListenerByTag(self._eventEquipSell)
    network:removeEventListenerByTag(self._eventEquipLock)
    DecomposeMain.super.dispose(self)
end

return DecomposeMain
