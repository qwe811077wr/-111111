local GeneralCollectView = class("GeneralCollectView", require('app.modules.common.BaseViewWithHead'))

GeneralCollectView.RESOURCE_FILENAME = "general_collect/GeneralCollect.csb"
GeneralCollectView.RESOURCE_BINDING = {
    ["Panel_1"]          ={["varname"]="_panelTop"},
    ["Node_1"]           ={["varname"]="_nodeEffect"},
    ["tab_1"]            ={["varname"]="_tab1",["events"]={{["event"]="touch",["method"]="onTabChange",["sound_id"] = 0}}},
    ["tab_2"]            ={["varname"]="_tab3",["events"]={{["event"]="touch",["method"]="onTabChange",["sound_id"] = 0}}},
    ["tab_3"]            ={["varname"]="_tab4",["events"]={{["event"]="touch",["method"]="onTabChange",["sound_id"] = 0}}},
    ["tab_4"]            ={["varname"]="_tab2",["events"]={{["event"]="touch",["method"]="onTabChange",["sound_id"] = 0}}},
    ["tab_4_0"]          ={["varname"]="_tab5",["events"]={{["event"]="touch",["method"]="onTabChange",["sound_id"] = 0}}},
    ["tab_5"]            ={["varname"]="_tab6",["events"]={{["event"]="touch",["method"]="onTabChange",["sound_id"] = 0}}},
    ["btn_illustration"] ={["varname"]="_btnIllustration",["events"]={{["event"]="touch",["method"]="onIllustration",["sound_id"] = 0}}},
    ["node_left_middle"] ={["varname"]="_nodeLeftMiddle"},
}

function GeneralCollectView:ctor(name, params)
    GeneralCollectView.super.ctor(self, name, params)
    self._gameMode = params.mode or uq.config.constant.GAME_MODE.NORMAL
    self._upData = {}
    self._downData = {}
    self._curType = 0
    self._curTopType = 0

    if self._gameMode == uq.config.constant.GAME_MODE.NORMAL then
        self:addShowCoinGroup({uq.config.constant.COST_RES_TYPE.MONEY, uq.config.constant.COST_RES_TYPE.GOLDEN})
    end

    self:setRuleId(uq.config.constant.MODULE_RULE_ID.GENERAL_COLLECT)
    self:setTitle(uq.config.constant.MODULE_ID.COLLECT_MODULE)
    self:initList()
    self:centerView()
    self:parseView(self._view)
    self:adaptBgSize()
    self:initDialog()
    self._indexOut = 0
    self._indexIn = 1
    self._boxHeight = 310
    self._boxWidth = 240
    self._allUi = {}
    self:infoRetRefresh()
    self:_onIllustrationRed()
    network:sendPacket(Protocol.C_2_S_GETRECRUIT_GENERAL_IDS, {})
    self._newGeneralEvent = '_onGeneralEpiphany' .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_FORMATION_CHANGES, handler(self,self._onFormationChanges), "_onFormationChanges")
    services:addEventListener(services.EVENT_NAMES.ON_ILLUSTRATION_RED, handler(self, self._onIllustrationRed), '_onIllustrationRed' .. tostring(self))
    services:addEventListener(services.EVENT_NAMES.ON_GENERALS_NEW_GENERAL, handler(self,self._onNewGeneral), self._newGeneralEvent)
    services:addEventListener(services.EVENT_NAMES.ON_RELOAD_COLLECT_VIEW, handler(self, self._onRefreshRed), '_onUpdateGeneralCollectView' .. tostring(self))

    self._instanceWarUpdateEvent = services.EVENT_NAMES.ON_INSTANCE_WAR_CITY_UPDATE .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_INSTANCE_WAR_CITY_UPDATE, handler(self, self.freshPage), self._instanceWarUpdateEvent)
    self:adaptNode()
end

function GeneralCollectView:freshPage()
    if self._listTop then
        self:refreshData()
        self._listTop:reloadData()
    end
end

function GeneralCollectView:_onIllustrationRed()
    uq.showRedStatus(self._btnIllustration, uq.cache.hint_status.status[uq.cache.hint_status.RED_TYPE.MAP_GUIDE],
        -self._btnIllustration:getContentSize().width * 0.5 + 10, self._btnIllustration:getContentSize().height * 0.5 - 10)
end

function GeneralCollectView:_onRefreshRed()
    if self._listTop then
        self._listTop:reloadData()
        self:showAction()
    end
end

function GeneralCollectView:_onFormationChanges()
    self:infoRetRefresh()
end

function GeneralCollectView:initDialog()
    self._btnIllustration:setPressedActionEnabled(true)

    if self._gameMode == uq.config.constant.GAME_MODE.INSTANCE_WAR then
        self._tab6:setVisible(false)
    end
end

function GeneralCollectView:initList()
    local viewSize = self._panelTop:getContentSize()
    self._listTop = cc.TableView:create(cc.size(viewSize.width, viewSize.height))
    self._listTop:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._listTop:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listTop:setPosition(cc.p(0, 0))
    self._listTop:setDelegate()
    self._listTop:registerScriptHandler(handler(self, self.tableCellTouchedTop), cc.TABLECELL_TOUCHED)
    self._listTop:registerScriptHandler(handler(self, self.cellSizeForTableTop), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listTop:registerScriptHandler(handler(self, self.tableCellAtIndexTop), cc.TABLECELL_SIZE_AT_INDEX)
    self._listTop:registerScriptHandler(handler(self, self.numberOfCellsInTableViewTop), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

    self._listTop:reloadData()
    self._panelTop:addChild(self._listTop)
end

function GeneralCollectView:tableCellTouchedTop(view, cell, touch)
    local touch_point = touch:getLocation()
    local index = cell:getIdx() * 5 + 1
    local up_line = math.ceil(#self._upData / 5)
    local is_down = index > up_line * 5
    local list_data = self._upData
    if is_down then
        index = index - up_line * 5
        list_data = self._downData
    end
    for i = 0, 4, 1 do
        local item = cell:getChildByName("item" .. i)
        if item == nil or item:isVisible() == false then
            return
        end
        local pos = item:convertToNodeSpace(touch_point)
        local rect = cc.rect(-self._boxWidth / 2, -self._boxHeight / 2, self._boxWidth, self._boxHeight)
        if cc.rectContainsPoint(rect, pos) then
            local tab_list = list_data[index] or {}
            if not tab_list or next(tab_list) == nil then
                return
            end
            if self._gameMode == uq.config.constant.GAME_MODE.INSTANCE_WAR then
            else
                if not tab_list.unlock and self:isCanCallGenerals(tab_list.id, tab_list.temp_id) then
                    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
                    local xml = uq.cache.generals:getGeneralDataXML(tab_list.temp_id)
                    if not xml or not xml.name then
                        return
                    end
                    local data = {
                        content = string.format(StaticData["local_text"]["general.collect.call"], xml.name),
                        confirm_callback = function()
                            network:sendPacket(Protocol.C_2_S_GENERAL_COMPOSE, {temp_id = tab_list.temp_id})
                        end
                    }
                    uq.addConfirmBox(data)
                    return
                end
            end

            uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
            local idx, max_num = self:getIdxAndMaxNumGenerals(tab_list)
            if idx == 0 then
                return
            end
            uq.runCmd('open_general_attribute', {{generals_id = tab_list.id, index = idx, occupation = self._curType, max_index = max_num, mode = self._gameMode}})
            break
        end
        index = index + 1
    end
end

function GeneralCollectView:cellSizeForTableTop(view, idx)
    if idx == math.ceil(#self._upData / 5) then
        return self._boxWidth, self._boxHeight + 30
    end
    return self._boxWidth, self._boxHeight
end

function GeneralCollectView:numberOfCellsInTableViewTop(view)
    return math.ceil(#self._upData / 5) + math.ceil(#self._downData / 5)
end

function GeneralCollectView:tableCellAtIndexTop(view, idx)
    local cell = view:dequeueCell()
    local index = idx * 5 + 1
    local up_line = math.ceil(#self._upData / 5)
    local is_down = index > up_line * 5
    local tab_list = self._upData
    if is_down then
        index = index - up_line * 5
        tab_list = self._downData
    end
    if not cell then
        cell = cc.TableViewCell:new()
        for i = 0, 4, 1 do
            local info = tab_list[index]
            local cell_item = uq.createPanelOnly("general_collect.GeneralCollectCardItem")
            cell:addChild(cell_item)
            cell["item" .. i] = cell_item
            cell_item:setPosition(cc.p(self._boxWidth * i + 110, self._boxHeight / 2))
            cell_item:setName("item" .. i)
            if info and next(info) ~= nil then
                cell_item:setData(info, self._gameMode, true)
                cell_item:showRed()
            else
                cell_item:setVisible(false)
            end
            index = index + 1
        end
        local item_temp = cc.CSLoader:createNode('general_collect/GeneralCollectTitle.csb')
        cell:addChild(item_temp)
        cell.item_temp = item_temp

        if self._gameMode == uq.config.constant.GAME_MODE.INSTANCE_WAR then
            item_temp:getChildByName("Text_1"):setString("俘虏")
        elseif self._gameMode == uq.config.constant.GAME_MODE.NORMAL then
            item_temp:getChildByName("Text_1"):setString(StaticData["local_text"]["general.not.call"])
        end

        item_temp:setPosition(cc.p(595, self._boxHeight + 15))
        item_temp:setVisible(idx == up_line)
        table.insert(self._allUi, cell)
    else
        for i = 0, 4, 1 do
            local info = tab_list[index]
            local cell_item = cell:getChildByName("item" .. i)
            if cell_item then
                if info and next(info) ~= nil then
                    cell_item:setData(info, self._gameMode, true)
                    cell_item:showRed()
                    cell_item:setVisible(true)
                else
                    cell_item:setVisible(false)
                end
            end
            if cell.item_temp then
                cell.item_temp:setVisible(idx == up_line)
            end
            index = index + 1
        end
    end
    return cell
end

function GeneralCollectView:dispose()
    services:removeEventListenersByTag("_onFormationChanges")
    services:removeEventListenersByTag('_onIllustrationRed' .. tostring(self))
    services:removeEventListenersByTag('_onUpdateGeneralCollectView' ..tostring(self))
    services:removeEventListenersByTag(self._newGeneralEvent)
    services:removeEventListenersByTag(self._instanceWarUpdateEvent)
    GeneralCollectView.super.dispose(self)
end

function GeneralCollectView:onTabTopChange(index)
    if self._curTopType == index then
        return
    end
    self._curTopType = index
    self:infoRetRefresh()
end

function GeneralCollectView:onTabChange(event)
    if event.name == "ended" then
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.CHANGE)
        if event.target == self["_tab" .. self._curType + 1] then
            return
        end
        for i = 1, 6 do
            local is_show = event.target == self["_tab" .. i]
            if is_show then
                self._curType = i - 1
            end
            self["_tab" .. i]:getChildByName("img_select1"):setVisible(is_show)
            self["_tab" .. i]:getChildByName("img_select2"):setVisible(is_show)
            self["_tab" .. i]:getChildByName("img_select1"):runAction(cc.RotateBy:create(0.3, -180))
            self["_tab" .. i]:getChildByName("img_select2"):runAction(cc.RotateBy:create(0.3, 180))
        end
        self:infoRetRefresh()
    end
end

function GeneralCollectView:_onNewGeneral(msg)
    self:onTabChange({name = "ended", target = self["_tab" .. self._curType + 1]})
    self:infoRetRefresh()
end

function GeneralCollectView:infoRetRefresh()
    self:refreshData()
    self._listTop:reloadData()
    self:showAction()
end

function GeneralCollectView:refreshData()
    if self._gameMode == uq.config.constant.GAME_MODE.INSTANCE_WAR then
        self._upData = uq.cache.instance_war:getUpGeneralsByType(self._curType)
        self._downData = uq.cache.instance_war:getDownGeneralsByType(self._curType)
    elseif self._gameMode == uq.config.constant.GAME_MODE.NORMAL then
        local up_data = {}
        local tab_up = uq.cache.generals:getUpGeneralsByType(self._curType) or {}
        for i, v in ipairs(tab_up) do
            table.insert(up_data, v)
        end
        local tab = {}
        local down_data = {}
        local tab_down = uq.cache.generals:getDownGeneralsByType(self._curType) or {}
        for i, v in ipairs(tab_down) do
            if self:isCanCallGenerals(v.id, v.temp_id) then
                table.insert(tab, v)
            else
                table.insert(down_data, v)
            end
        end
        if next(tab) ~= nil then
            for i = #tab, 1, -1 do
                table.insert(up_data, 1, tab[i])
            end
        end
        self._upData = up_data
        self._downData = down_data
    end
end

function GeneralCollectView:isCanCallGenerals(id, temp_id)
    local general_data = uq.cache.generals:getGeneralDataXML(temp_id)
    if not general_data or not general_data.composeNums then
        return false
    end
    return general_data.composeNums <= uq.cache.role:getResNum(uq.config.constant.COST_RES_TYPE.SPIRIT, id)
end

function GeneralCollectView:getIdxAndMaxNumGenerals(data)
    local tab = {}

    if self._gameMode == uq.config.constant.GAME_MODE.INSTANCE_WAR then
        if data.unlock then
            tab = uq.cache.instance_war:getUpGeneralsByType(self._curType) or {}
        else
            tab = uq.cache.instance_war:getDownGeneralsByType(self._curType) or {}
        end
    else
        if data.unlock then
            tab = uq.cache.generals:getUpGeneralsByType(self._curType) or {}
        else
            tab = uq.cache.generals:getDownGeneralsByType(self._curType) or {}
        end
    end

    for i, v in ipairs(tab) do
        if v.id == data.id then
            return i, #tab
        end
    end
    return 0, 0
end

function GeneralCollectView:onIllustration(event)
    if event.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    uq.jumpToModule(105)
end

function GeneralCollectView:showAction()
    for k, v in pairs(self._allUi) do
        uq.intoAction(v.item_temp:getChildByName("Text_1"))
        for i = 0, 4 do
            v["item" .. i]:showAction()
        end
    end
end

return GeneralCollectView