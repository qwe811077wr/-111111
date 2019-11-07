local StrategyModule = class("StrategyModule", require("app.base.ModuleBase"))
local StrategyItem = require("app.modules.strategy.StrategyItem")

StrategyModule.RESOURCE_FILENAME = "strategy/StrategyMain.csb"

StrategyModule.RESOURCE_BINDING  = {
    ["Panel_1/Panel_tab"]                                    ={["varname"] = "_panelTab"},
    ["Panel_1/Panel_des/img_item"]                           ={["varname"] = "_imgItem"},
    ["Panel_1/Panel_des/btn_study"]                          ={["varname"] = "_btnStudy",["events"] = {{["event"] = "touch",["method"] = "_onBtnStudy"}}},
    ["Panel_1/Panel_2"]                                      ={["varname"] = "_panelTableView"},
    ["Panel_levelup"]                                        ={["varname"] = "_panelLevelUp"},
    ["Panel_levelup/img_title"]                              ={["varname"] = "_imgTitle"},
    ["Panel_levelup/img_bg"]                                 ={["varname"] = "_imgTitleBg"},
    ["Panel_1/Panel_des"]                                    ={["varname"] = "_pnlDes"},
    ["tab_2"]                                                ={["varname"] = "_pnlTab2"},
    ["Text_8_0"]                                             ={["varname"] = "_txtDec1"},
    ["Text_8"]                                               ={["varname"] = "_txtDec"},
    ["Text_4"]                                               ={["varname"] = "_txtTime"},
    ["action_1_node"]                                        ={["varname"] = "_nodeAction1"},
    ["action_2_node"]                                        ={["varname"] = "_nodeAction2"},
    ["action_3_node"]                                        ={["varname"] = "_nodeAction3"},
    ["btn_speed"]                                            ={["varname"] = "_btnSpeed",["events"] = {{["event"] = "touch",["method"] = "_onBtnSpeed"}}},
}

function StrategyModule:ctor(name, args)
    StrategyModule.super.ctor(self, name, args)
    self._tabIndex = 1
    self._curPageItemIndex = 1
    self._curPageItemInfo = {}
    self._allListData = {}
    self._curTabInfo = {}
    self._uiAll = {}
end

function StrategyModule:init()
    local top_ui = uq.ui.CommonHeaderUI:create()
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.GESTE, true))
    top_ui:setTitle(uq.config.constant.MODULE_ID.STRATEGY_MODULE)
    self._topUI = top_ui
    self._view:addChild(top_ui:getNode())
    self:parseView()
    self:centerView()
    self:initTableView()
    self:initData()
    self:initProtocolData()
    self:initDialog()
    self:adaptBgSize()
    if uq.cache.technology._upId ~= 0 then
        network:sendPacket(Protocol.C_2_S_TECHNOLOGY_UPDATE,{id = uq.cache.technology._upId})
    end
    self:_onRefreshTime()
    self._onTimeRefresh = "_onRefreshTime" .. tostring(self)
    uq.TimerProxy:addTimer(self._onTimeRefresh, handler(self, self._onRefreshTime), 1, -1)
    uq:addEffectByNode(self._nodeAction1, 900146, -1, true, cc.p(-2, 110))
    uq:addEffectByNode(self._nodeAction3, 900147, -1, true, cc.p(-2, 60))
    uq:addEffectByNode(self._nodeAction2, 900148, -1, true, cc.p(-4, 0))
end

function StrategyModule:_onRefreshTime()
    local time = uq.cache.technology:getSurplusTime()
    if time > 0 then
        self._txtTime:setString(uq.getTime(time, uq.config.constant.TIME_TYPE.HHMMSS))
    else
        self._txtTime:setString("")
        self._btnSpeed:setVisible(false)
    end
end

function StrategyModule:_onBtnStudy(event)
    if event.name ~= "ended" then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.STRATEGY_UP_LEVEL, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, data = self._curPageItemInfo})
end

function StrategyModule:_onBtnSpeed(event)
    if event.name ~= "ended" then
        return
    end
    if uq.cache.technology:getSurplusTime() <= 0 then
        return
    end
    local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.BUILD_SPEED_UP, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
    panel:setData(uq.cache.technology._upId, true)
end

function StrategyModule:updateData()
    self._curTabInfo = self._allListData[self._tabIndex] or {}
    self._curPageItemInfo = self._curTabInfo[self._curPageItemIndex] or {}
end

function StrategyModule:refreshBoxs()
    for i, v in ipairs(self._uiAll) do
        v:setSelected(self._curPageItemInfo.id)
    end
end

function StrategyModule:getPageItemsIdx()
    for i, v in ipairs(self._allListData[self._tabIndex]) do
        if v.id == self._curPageItemInfo.id then
            return i
        end
    end
    return 1
end

function StrategyModule:updateTabInfo(data)
    self._curPageItemInfo = data
    self:updateInfo()
end

function StrategyModule:addTabBtns()
    for i = 1, 3 do
        local tab_btn = self._panelTab:getChildByName("tab_" .. i)
        tab_btn:addClickEventListenerWithSound(function ()
            if self._tabIndex == i then
                return
            end
            self:refreshBtnTo(i)
        end)
        tab_btn:setVisible(self:isShowBtn(i))
    end
    local idx, cur_id = self:getStudyShowIdx()
    self:refreshBtnTo(idx, true, cur_id)
end

function StrategyModule:isShowBtn(id)
    local tab = self._allListData[id] or {}
    for k, v in pairs(tab) do
        if v.xml.openLevel <= uq.cache.role:getBuildingLevel(uq.config.constant.TYPE_BUILDING.STRATEGY_MANSION) then
            return true
        end
    end
    return false
end

function StrategyModule:getStudyShowIdx()
    if not uq.cache.technology:isFullFinish() then
        return 2, 1
    end
    for k, v in pairs(self._allListData) do
        for i, iv in ipairs(v) do
            if iv.id == uq.cache.technology._upId then
                return k, i
            end
        end
    end
    return 2, 1
end

function StrategyModule:refreshBtnTo(idx, not_action, cur_id)
    for i = 1, 3 do
        local tab_btn = self._panelTab:getChildByName("tab_" .. i)
        tab_btn:getChildByName("img_select2"):setVisible(i == idx)
        tab_btn:getChildByName("img_select1"):setVisible(i == idx)
        if not not_action and i == idx then
            tab_btn:getChildByName("img_select1"):runAction(cc.RotateBy:create(0.3, -180))
            tab_btn:getChildByName("img_select2"):runAction(cc.RotateBy:create(0.3, 180))
        end
    end
    self._tabIndex = idx
    self._curPageItemIndex = cur_id or 1
    self:updateData()
    self._tableView:reloadData()
    self:updateInfo()
    self:refreshBoxs()
end

function StrategyModule:initProtocolData()
    self._eventTagRefresh = services.EVENT_NAMES.ON_STRATRGY_UP_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_STRATRGY_UP_REFRESH, handler(self, self._onRefreshSucceed), self._eventTagRefresh)
end

function StrategyModule:initData()
    self:setTableData()
    self:addTabBtns()
end

function StrategyModule:setTableData()
    self._allListData = {}
    local tech_array = uq.cache.technology:getTechnologyInfo()
    for i, v in ipairs(tech_array) do
        local num = tonumber(v.xml.studytype)
        if not self._allListData[num] then
            self._allListData[num] = {}
        end
        table.insert(self._allListData[num], v)
    end
    for k, v in pairs(self._allListData) do
        table.sort(v, function (a, b)
            if a.level == b.level then
                return a.need_level < b.need_level
            end
            return a.level > b.level
        end)
    end
end

function StrategyModule:initTableView()
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

function StrategyModule:tableCellTouched(view, cell, touch)
    local touch_point = touch:getLocation()
    local index = cell:getIdx() * 4 + 1
    for i = 0, 3, 1 do
        local strategy_item = cell:getChildByName("item"..i)
        if strategy_item == nil then
            return
        end
        local pos = strategy_item:convertToNodeSpace(touch_point)
        local size = strategy_item:getContentSize()
        local rect = cc.rect(-size.width / 2, -size.height / 2, size.width, size.height)
        if cc.rectContainsPoint(rect, pos) then
            if self._curPageItemIndex == index then
                return
            end
            if not self._curTabInfo[index] then
                return
            end
            self._curPageItemIndex = index
            self._curPageItemInfo = self._curTabInfo[index]
            self:updateInfo()
            self:refreshBoxs()
            break
        end
        index = index + 1
    end
end

function StrategyModule:cellSizeForTable()
    return 600, 260
end

function StrategyModule:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx * 4 + 1
    if not cell then
        cell = cc.TableViewCell:new()
        for i = 0, 3, 1 do
            local info = self._curTabInfo[index]
            local size = nil
            local strategy_item = nil
            if info ~= nil then
                strategy_item = StrategyItem:create({info = info})
                size = strategy_item:getContentSize()
                strategy_item:setPosition(cc.p((size.width + 30) + (size.width + 20) * i, size.height))
                cell:addChild(strategy_item, 1)
                strategy_item:setName("item" .. i)
            else
                strategy_item = StrategyItem:create()
                size = strategy_item:getContentSize()
                strategy_item:setPosition(cc.p((size.width + 30) + (size.width + 20) * i, size.height))
                cell:addChild(strategy_item, 1)
                strategy_item:setName("item" .. i)
                strategy_item:setVisible(false)
            end
            index = index + 1
            table.insert(self._uiAll, strategy_item)
        end
    else
        for i = 0, 3, 1 do
            local info = self._curTabInfo[index]
            local strategy_item = cell:getChildByName("item" .. i)
            if info ~= nil then
                strategy_item:setInfo(info)
                strategy_item:setVisible(true)
            elseif strategy_item then
                strategy_item:setVisible(false)
            end
            index = index + 1
        end
    end
    return cell
end

function StrategyModule:numberOfCellsInTableView()
    return math.ceil(#self._curTabInfo / 4)
end

function StrategyModule:_onLoadTechnology()
    self:setTableData()
    self._tableView:reloadData()
    self:updateInfo()
end

function StrategyModule:getEffectInfo(level)
    if self._curPageItemInfo == nil then
        return nil
    end
    for k, v in pairs(self._curPageItemInfo.xml.Effect) do
        if level == v.ident then
            return v
        end
    end
    return nil
end

function StrategyModule:updateInfo()
    if not self._curPageItemInfo or not self._curPageItemInfo.xml then
        return
    end
    local effect_info = self:getEffectInfo(self._curPageItemInfo.level)
    if not effect_info then
        return
    end
    self._btnStudy:setVisible(self._curPageItemInfo.level < uq.cache.technology:getTechnologyMaxLv(self._curPageItemInfo.xml) and self._curPageItemInfo.id ~= uq.cache.technology._upId)
    self._imgItem:loadTexture("img/strategy/" .. self._curPageItemInfo.xml.icon)
    local is_show = self._curPageItemInfo.id == uq.cache.technology._upId
    self._txtTime:setVisible(is_show)
    self._nodeAction2:setVisible(is_show)
    self._nodeAction3:setVisible(is_show)
    self._btnSpeed:setVisible(is_show)
    local str_num = uq.cache.technology:getAttAddById(self._curPageItemInfo.id)
    local str = tostring(str_num)
    if self._tabIndex ~= 3 then
        str = uq.cache.generals:getNumByEffectType(self._curPageItemInfo.xml.effectType, str_num)
    else
        if self._curPageItemInfo.xml.percent == 1 then
            str = str_num * 100 .. "%"
        end
    end
    self._txtDec:setHTMLText(string.format(StaticData["local_text"]["strategy.dec.skill"], self._curPageItemInfo.xml.desc, str))
    local off_y = self._tabIndex == 2 and 36 or 26
    self._txtDec:setPositionY(off_y)
    local str_dec = self._tabIndex == 2 and self._curPageItemInfo.xml.desc2 or ""
    self._txtDec1:setString(str_dec)
end

function StrategyModule:initDialog()
    self._btnStudy:setPressedActionEnabled(true)
    self._panelLevelUp:setVisible(false)
end

function StrategyModule:_onRefreshSucceed()
    self:setTableData()
    self._curPageItemIndex = self:getPageItemsIdx()
    self:updateData()
    self._tableView:reloadData()
    self:updateInfo()
    self:refreshBoxs()
end

function StrategyModule:dispose()
    if self._topUI then
        self._topUI:dispose()
    end
    services:removeEventListenersByTag(self._eventTagRefresh)
    uq.TimerProxy:removeTimer(self._onTimeRefresh)
    StrategyModule.super.dispose(self)
end

return StrategyModule
