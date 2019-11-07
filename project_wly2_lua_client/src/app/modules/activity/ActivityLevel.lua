local ActivityLevel = class("ActivityLevel", require('app.base.PopupBase'))
local EquipItem = require("app.modules.common.EquipItem")

ActivityLevel.RESOURCE_FILENAME = "activity/ActivityLevel.csb"
ActivityLevel.RESOURCE_BINDING = {
    ["Node_1/Panel_1"]                   = {["varname"] = "_pnlList"},
    ["Node_2"]                           = {["varname"] = "_nodeCenter"},
    ["Node_2/title_img"]                 = {["varname"] = "_imgTitle"},
    ["Node_2/Sprite_1"]                  = {["varname"] = "_sprIcon"},
    ["Node_2/Text_1"]                    = {["varname"] = "_txtDec"},
    ["Node_2/Button_1"]                  = {["varname"] = "_btnOk"},
    ["Node_4/prop_node"]                 = {["varname"] = "_nodeProp1"},
    ["Node_4/Button_1_0"]                = {["varname"] = "_btnUpOk"},
    ["Node_4/Text_2_0"]                  = {["varname"] = "_txtFree"},
    ["Node_4/Image_13"]                  = {["varname"] = "_imgFinishFree"},
    ["Node_3/Button_3"]                  = {["varname"] = "_btnBuyDown"},
    ["Node_3/icon_node"]                 = {["varname"] = "_nodeIcon"},
    ["Node_3/icon_node/surplus_num_txt"] = {["varname"] = "_txtSurplusNum"},
    ["Node_3/icon_node/discount_txt"]    = {["varname"] = "_txtDiscount"},
    ["Node_3/icon_node/Image_14"]        = {["varname"] = "_imgCostOld"},
    ["Node_3/icon_node/icon_now_price"]  = {["varname"] = "_imgPirceNow"},
    ["Node_3/icon_node/icon_old_price"]  = {["varname"] = "_imgPirceOld"},
    ["Node_3/Text_17"]                   = {["varname"] = "_txtSurplusTimes"},
    ["Node_6"]                           = {["varname"] = "_nodeProp2"},
    ["Node_3/Image_2"]                   = {["varname"] = "_imgUnknown"},
    ["Node_3/Button_3/Text_2_0_0"]       = {["varname"] = "_txtBuy"},
    ["Node_3/Image_13_0"]                = {["varname"] = "_imgFinish"},
    ["Node_4/Image_2_0"]                 = {["varname"] = "_imgUnknownUp"},
    ["cost_bg_img"]                      = {["varname"] = "_imgBgCostCion"},
    ["close_btn"]                        = {["varname"] = "_btnClose"},
    ["expire_txt"]                       = {["varname"] = "_txtExpire"},
    ["up_cost_img"]                      = {["varname"] = "_imgCostUp"},
}

function ActivityLevel:ctor(name, params)
    ActivityLevel.super.ctor(self, name, params)
end

function ActivityLevel:init()
    self:centerView()
    self:parseView()
    self:setLayerColor(0.7)
    self._allItems = {}
    self._cd = 0
    self._num = 0
    self._listData = self:dealData()
    self._selectIdex = self:getSelectIdx()
    self._nextId = self:getNextIdx()
    self:initLayer()
    self:refreshList(self._selectIdex)
    self._cdTag = "_cdGoods" .. tostring(self)
    uq.TimerProxy:addTimer(self._cdTag, handler(self, self._updateCd), 0.2, -1)
    self._levelRefresh = services.EVENT_NAMES.ON_LEVEL_BUY_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_LEVEL_BUY_REFRESH, handler(self, self._onRefreshBuy), self._levelRefresh)
end

function ActivityLevel:initLayer()
    local viewSize = self._pnlList:getContentSize()
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
    local idx = self._selectIdex > 1 and self._selectIdex - 1 or self._selectIdex
    self._listView:setContentOffset(cc.p(0, math.min(630 - (#self._listData - idx + 1) * 130, 0)), true)
    self._pnlList:addChild(self._listView)
    self._txtDec:setTextAreaSize(cc.size(500, 0))
    self._txtDec:getVirtualRenderer():setLineHeight(30)
    self._btnUpOk:addClickEventListenerWithSound(function()
        if not uq.cache.achievement:isCanBuyFreeItems(self._selectIdex) then
            uq.fadeInfo(StaticData["local_text"]["activity.finish.buy"])
            return
        end
        local data = {
            id = self._selectIdex,
            gift_type = 0,
        }
        network:sendPacket(Protocol.C_2_S_LEVEL_GIFT_DRAW, data)
    end)
    self._btnBuyDown:addClickEventListenerWithSound(function()
        local data = self._listData[self._selectIdex]
        if not data or next(data) == nil or uq.cache.achievement:isNotBuyItem(self._selectIdex) then
            uq.fadeInfo(StaticData["local_text"]["activity.not.sale"])
            return
        end
        local tab_cost = uq.RewardType:create(data.cost):toEquipWidget()
        if not tab_cost or next(tab_cost) == nil then
            uq.fadeInfo(StaticData["local_text"]["activity.not.sale"])
            return
        end
        if not uq.cache.role:checkRes(tonumber(tab_cost.type), tab_cost.num) then
            uq.fadeInfo(StaticData["local_text"]["activity.gold.not.enough"])
            return
        end
        local data = {
            id = self._selectIdex,
            gift_type = 1,
        }
        network:sendPacket(Protocol.C_2_S_LEVEL_GIFT_DRAW, data)
    end)
    self._btnOk:addClickEventListenerWithSound(function()
        if self._nextId == self._selectIdex then
            uq.fadeInfo(StaticData["local_text"]["label.lv.not.enough"])
            return
        end
        local data = self._listData[self._selectIdex]
        uq.jumpToModule(tonumber(data.moduleId))
    end)
    self._btnClose:addClickEventListenerWithSound(function()
        self:disposeSelf()
    end)
end

function ActivityLevel:_onRefreshBuy(evt)
    local data = evt.data
    local tab = StaticData['level_gift'][data.id]
    if tab and next(tab) ~= nil then
        local award = tab.goods
        if data.gift_type == 0 then
            award = tab.freeReward
        end
        uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE,{rewards = award})
    end
    self:refreshList(self._selectIdex)
end

function ActivityLevel:refreshCenterLayer()
    local data = self._listData[self._selectIdex]
    if not data or next(data) == nil then
        return
    end
    self._imgTitle:loadTexture("img/activity/" .. data.nameImage)
    if data.image then
        self._sprIcon:setTexture("img/activity/" .. data.image)
    end
    self._txtDec:setString(data.desc)
end

function ActivityLevel:refreshItemsLayer()
    local data = self._listData[self._selectIdex]
    if not data or next(data) == nil then
        return
    end
    self._nodeProp1:removeAllChildren()
    self._nodeProp2:removeAllChildren()
    self._btnUpOk:setVisible(true)
    self._imgFinishFree:setVisible(false)
    self._imgCostUp:setVisible(true)
    self._btnBuyDown:setVisible(true)
    self._imgFinish:setVisible(false)
    self._nodeIcon:setVisible(false)
    self._txtExpire:setString("")
    self._txtFree:setTextColor(uq.parseColor("#14222a"))
    self._txtBuy:setTextColor(uq.parseColor("#14222a"))
    self._txtFree:setString(StaticData["local_text"]["activity.get"])
    self._txtBuy:setString(StaticData["local_text"]["activity.buy"])
    self._imgUnknown:setVisible(self._nextId == self._selectIdex)
    self._txtSurplusTimes:setString("")
    self._imgUnknownUp:setVisible(self._nextId == self._selectIdex)
    self._nodeIcon:setVisible(self._nextId ~= self._selectIdex)
    self._btnUpOk:setEnabled(self._nextId ~= self._selectIdex)
    self._btnBuyDown:setEnabled(self._nextId ~= self._selectIdex)
    if self._nextId == self._selectIdex then
        uq.ShaderEffect:addGrayButton(self._btnUpOk)
        uq.ShaderEffect:addGrayButton(self._btnBuyDown)
        self._txtFree:setTextColor(uq.parseColor("#353535"))
        self._txtBuy:setTextColor(uq.parseColor("#353535"))
        return
    end
    self._imgPirceOld:setString("")
    self._txtSurplusNum:setHTMLText(string.format(StaticData["local_text"]["activity.num.surplus"], 0))
    for i = 1, 2 do
        local reward = i == 1 and data.freeReward or data.goods
        local tab_reward = uq.RewardType.parseRewards(reward)
        for j, v in ipairs(tab_reward) do
            local item = EquipItem:create()
            item:setTouchEnabled(true)
            item:addClickEventListenerWithSound(function(sender)
                local info = sender:getEquipInfo()
                uq.showItemTips(info)
                end)
            item:setInfo(v:toEquipWidget())
            item:setScale(0.8)
            item:setPosition(cc.p((j - 1) * 100 - 10, 0))
            self["_nodeProp" .. i]:addChild(item)
            if j == 4 then
                break
            end
        end
    end
    local old_num = 1
    local old_tab = uq.RewardType:create(data.price):toEquipWidget()
    if old_tab and next(old_tab) ~= nil then
        old_num = old_tab.num
        self._imgPirceOld:setString(tostring(old_tab.num))
        local info = StaticData['types'].Cost[1].Type[old_tab.type]
        if info and info.miniIcon then
            self._imgCostOld:loadTexture("img/common/ui/" .. info.miniIcon)
        end
    end
    local now_num = 1
    local now_tab = uq.RewardType:create(data.cost):toEquipWidget()
    if now_tab and next(now_tab) ~= nil then
        now_num = now_tab.num
        self._imgPirceNow:setString(tostring(now_tab.num))
    end
    local num_discount  = math.floor(now_num / old_num * 100) / 10
    self._txtDiscount:setString(tostring(num_discount))
    local up_show = uq.cache.achievement:isCanBuyFreeItems(self._selectIdex)
    self._btnUpOk:setVisible(up_show)
    self._imgCostUp:setVisible(up_show)
    self._imgFinishFree:setVisible(not up_show)
    uq.ShaderEffect:removeGrayButton(self._btnBuyDown)
    local down_show = uq.cache.achievement:isNotBuyItem(self._selectIdex)
    if down_show then
        if uq.cache.achievement:isFinishBuyItem(self._selectIdex) then
            self._btnBuyDown:setVisible(false)
            self._imgFinish:setVisible(true)
            self._nodeIcon:setVisible(false)
            self._txtExpire:setString("")
        else
            self._btnBuyDown:setEnabled(false)
            self._txtExpire:setString(StaticData["local_text"]["activity.not.time"])
            self._txtBuy:setTextColor(uq.parseColor("#353535"))
            self._txtBuy:setString(StaticData["local_text"]["activity.sign.expire"])
            uq.ShaderEffect:addGrayButton(self._btnBuyDown)
        end
        self._txtSurplusNum:setString("")
    end
    self._cd = 0
    self._num = 0
    local info = uq.cache.achievement:getBuyInfoById(self._selectIdex)
    if info then
        if info.num then
            self._num = data.times - info.num
            if not down_show then
                self._txtSurplusNum:setHTMLText(string.format(StaticData["local_text"]["activity.num.surplus"], self._num))
            end
        end
        if info.surplus then
            self._cd = info.surplus
        end
    end
    self:_updateCd()
end

function ActivityLevel:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
    if self._nextId ~= 0 and index > self._nextId then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.CHANGE)
    self:refreshList(index)
end

function ActivityLevel:cellSizeForTable(view, idx)
    return 150, 130
end

function ActivityLevel:numberOfCellsInTableView(view)
    if self._listData then
        return #self._listData
    end
    return 0
end

function ActivityLevel:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil
    if not cell then
        cell = cc.TableViewCell:new();
        cell_item = uq.createPanelOnly("activity.LevelItems")
        cell:addChild(cell_item)
        cell_item:setTag(1000)
        table.insert(self._allItems, cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end
    cell_item:setData(self._listData[index], index, self._nextId, self._selectIdex)
    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))
    return cell
end

function ActivityLevel:refreshList(index)
    self._selectIdex = index
    for i, v in ipairs(self._allItems) do
        v:refreshLayer(index)
    end
    self:refreshCenterLayer()
    self:refreshItemsLayer()
end

function ActivityLevel:dealData()
    return StaticData['level_gift'] or {}
end

function ActivityLevel:getNextIdx()
    for i, v in ipairs(self._listData) do
        if v.level > uq.cache.role:level() then
            return i
        end
    end
    return 0
end

function ActivityLevel:getSelectIdx()
    for i, v in ipairs(self._listData) do
        if v.level > uq.cache.role:level() then
            return math.max(i - 1, 1)
        end
    end
    return #self._listData
end

function ActivityLevel:_updateCd()
    if self._nextId == self._selectIdex then
        return
    end
    local time = self._cd - uq.curServerSecond()
    if time >= 0 then
        self._txtSurplusTimes:setString(uq.getTime(time, uq.config.constant.TIME_TYPE.HHMMSS))
    else
        self._txtSurplusTimes:setString("")
        self._txtSurplusNum:setString("")
        if uq.cache.achievement:isFinishBuyItem(self._selectIdex) then
            self._btnBuyDown:setVisible(false)
            self._imgFinish:setVisible(true)
            self._nodeIcon:setVisible(false)
            self._txtExpire:setString(StaticData["local_text"]["activity.end"])
        else
            self._btnBuyDown:setEnabled(false)
            self._txtBuy:setTextColor(uq.parseColor("#353535"))
            self._txtBuy:setString(StaticData["local_text"]["activity.sign.expire"])
            uq.ShaderEffect:addGrayButton(self._btnBuyDown)
        end
    end
end

function ActivityLevel:dispose()
    services:removeEventListenersByTag(self._levelRefresh)
    uq.TimerProxy:removeTimer(self._cdTag)
    ActivityLevel.super.dispose(self)
end

return ActivityLevel