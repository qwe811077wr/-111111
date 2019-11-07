local PassCheckLevel = class("PassCheckLevel", require('app.base.ChildViewBase'))

PassCheckLevel.RESOURCE_FILENAME = "pass_check/PassCheckLevel.csb"
PassCheckLevel.RESOURCE_BINDING = {
    ["lv_txt"]            = {["varname"] = "_txtLevel"},
    ["exp_txt"]           = {["varname"] = "_txtLevelExp"},
    ["Panel_1"]           = {["varname"] = "_panelReward"},
    ["time_text"]         = {["varname"] = "_txtUpToDay"},
    ["lock_img"]          = {["varname"] = "_imgLock"},
    ["buy_node"]          = {["varname"] = "_nodeBuy"},
    ["up_node"]           = {["varname"] = "_nodeUp"},
    ["Button_12"]         = {["varname"] = "_btnActivate", ["events"] = {{["event"] = "touch",["method"] = "onActivate"}}},
    ["Button_13"]         = {["varname"] = "_btnUpActivate", ["events"] = {{["event"] = "touch",["method"] = "onUpActivate"}}},
    ["Button_14"]         = {["varname"] = "_btnBuyLevel", ["events"] = {{["event"] = "touch",["method"] = "onBuyLevel",["sound_id"] = 0}}},
    ["Button_15"]         = {["varname"] = "_btnOneKey", ["events"] = {{["event"] = "touch",["method"] = "onOneKeyFinish"}}},
    ["dec_btn"]           = {["varname"] = "_btnDec", ["events"] = {{["event"] = "touch",["method"] = "onDec",["sound_id"] = 0}}},
    ["right_node"]        = {["varname"] = "_nodeLevelReward"},
    ["items_1_node"]      = {["varname"] = "_nodeRewardFreeItem"},
    ["items_3_node"]      = {["varname"] = "_nodeRewardPassItem"},
    ["BitmapFontLabel_1"] = {["varname"] = "_txtRewardLevel"},
    ["Image_45"]          = {["varname"] = "_imgRewardFreeGot"},
    ["Image_45_0"]        = {["varname"] = "_imgRewardPassGot"},
    ["LoadingBar_1"]      = {["varname"] = "_lbr"},
    ["surplus_exp_txt"]   = {["varname"] = "_txtExpSurplus"},
    ["exp_own_txt"]       = {["varname"] = "_txtExpOwnTxt"},
    ["dec1_txt"]          = {["varname"] = "_txtDec1"},
    ["dec2_txt"]          = {["varname"] = "_txtDec2"},
    ["Image_5"]           = {["varname"] = "_imgRewardLock"},
    ["Panel_7_0"]         = {["varname"] = "_panelGetReward1", ["events"] = {{["event"] = "touch",["method"] = "onGetReward"}}},
    ["Panel_7"]           = {["varname"] = "_panelGetReward2", ["events"] = {{["event"] = "touch",["method"] = "onGetReward"}}},
    ["Node_1"]            = {["varname"] = "_nodeDown"},
    ["Node_5"]            = {["varname"] = "_nodeCenter"},
    ["dec_node"]          = {["varname"] = "_nodeDec"},
}

function PassCheckLevel:ctor(name, params)
    PassCheckLevel.super.ctor(self, name, params)
    self:parseView()
    self._cacheData = uq.cache.pass_check._passCardInfo
    self._oldLevel = self._cacheData.level
    self._normalGift = self._cacheData.free_gift
    self._specGift = self._cacheData.pass_gift
    self._passData = StaticData['pass']['Info'][self._cacheData.season_id]
    self._passLevel = self._passData['PassGift']
    self._curLevel = 0
    self._curHeight = 0
    self._curScale = 1
    self._rewardCache = {}
    self._allItems = {}

    self:initLevelList()
    self:refreshLock()
    self:refreshBtn()
    self:refreshLevel()
end

function PassCheckLevel:onCreate()
    PassCheckLevel.super.onCreate(self)
    self:initRewardItem(self._nodeRewardFreeItem)
    self:initRewardItem(self._nodeRewardPassItem)

    self._onTimerTag = "_onTimerTag" .. tostring(self)
    uq.TimerProxy:addTimer(self._onTimerTag, handler(self, self._refreshEndTime), 1, -1)

    self._eventTag = services.EVENT_NAMES.ON_REFRESH_PASS_CHECK_INFO .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_REFRESH_PASS_CHECK_INFO, handler(self, self.onRefreshAll), self._eventTag)
    self._eventOneKey = "_onOneKeyDrawReward" .. tostring(self)
    network:addEventListener(Protocol.S_2_C_PASSCARD_LEVEL_ONEKEY_DRAW_REWARD, handler(self, self._onOneKeyReward), self._eventOneKey)
end

function PassCheckLevel:_refreshEndTime()
    self._txtUpToDay:setString(uq.cache.pass_check:getSurplusTimeString())
end

function PassCheckLevel:_onOneKeyReward(evt)
    local data = evt.data
    for i, v in ipairs(data.rwds) do
        table.insert(self._rewardCache, v)
    end
    if data.is_over == 1 then
        uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, {rewards = self._rewardCache})
        uq.cache.pass_check:setOneKeyFinish()
        self._listView:reloadData()
        self._rewardCache = {}
        uq.cache.pass_check:updateRed()
        services:dispatchEvent({name = services.EVENT_NAMES.ON_PASS_CHECK_RED_REFRESH})
    end
end

function PassCheckLevel:refreshLevel()
    self._txtLevel:setString(self._cacheData.level)

    local data = StaticData['pass']['Pass']
    local exp_data = data[self._cacheData.level]['exp']
    self._txtLevelExp:setString('/' .. exp_data)
    self._lbr:setPercent(math.min(self._cacheData.exp / exp_data, 1) * 100)
    self._txtExpOwnTxt:setString(tostring(self._cacheData.exp))
    self._txtExpSurplus:setHTMLText(string.format(StaticData["local_text"]["pass.surplus.exp"], exp_data - self._cacheData.exp))
end

function PassCheckLevel:refreshRewardTip()
    local tip_data = nil
    for i = self._showIndex + 1, self._showIndex + 10 do
        if self._passLevel[i] and self._passLevel[i].isShow == 1 then
            tip_data = self._passLevel[i]
            break
        end
    end
    self._nodeLevelReward:setVisible(tip_data ~= nil)
    if not tip_data or next(tip_data) == nil then
        return
    end
    self._txtRewardLevel:setString(tip_data.ident)
    self:addRewardItem(self._nodeRewardFreeItem, tip_data.freeGift, -10)
    self:addRewardItem(self._nodeRewardPassItem, tip_data.passGift, 5)

    self._imgRewardFreeGot:setVisible(uq.cache.pass_check._freeGift[tip_data.ident] == 1)
    self._imgRewardPassGot:setVisible(uq.cache.pass_check._passGift[tip_data.ident] == 1)

    self._imgRewardLock:setVisible(uq.cache.pass_check._passCardInfo.state == 0)
    self._tipData = tip_data

    self._panelGetReward1:setVisible(uq.cache.pass_check._passCardInfo.level >= tip_data.ident and not uq.cache.pass_check._freeGift[tip_data.ident])
    self._panelGetReward2:setVisible(uq.cache.pass_check._passCardInfo.level >= tip_data.ident and not uq.cache.pass_check._passGift[tip_data.ident])
end

function PassCheckLevel:onGetReward(event)
    if event.name == "ended" then
        local tag = event.target:getTag()
        network:sendPacket(Protocol.C_2_S_PASSCARD_LEVEL_DRAW_REWARD, {id = self._tipData.ident, drawtype = tag})
    end
end

function PassCheckLevel:initRewardItem(parent)
    for i = 1 , 2 , 1 do
        local reward = require("app.modules.common.EquipItem"):create()
        reward:setTouchEnabled(false)
        reward:addClickEventListener(function(sender)
            uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
            local info = sender:getEquipInfo()
            uq.showItemTips(info)
        end)
        reward:setSwallowTouches(false)
        reward:setScale(0.7)
        parent:addChild(reward)
        reward:setName("reward" .. i)
        reward:setVisible(false)
    end
end

function PassCheckLevel:addRewardItem(parent, reward, off)
    local children = parent:getChildren()
    for k , v in pairs(children) do
        v:setTouchEnabled(false)
        v:setPositionY(off)
        v:setVisible(false)
    end
    local item_list = uq.RewardType.parseRewards(reward)
    for k, item in pairs(item_list) do
        local reward = parent:getChildByName("reward" .. k)
        if reward ~= nil then
            reward:setInfo(item:toEquipWidget())
            reward:setTouchEnabled(true)
            reward:setPositionY(off - (k - 1) * 105)
            reward:setVisible(true)
        end
    end
end

function PassCheckLevel:refreshLock()
    self._imgLock:setVisible(self._cacheData.state == 0)
end

function PassCheckLevel:refreshBtn()
    local is_show = self._cacheData.state == 0
    self._btnOneKey:setVisible(uq.cache.pass_check:isCanOneKeyFinish())
    self._nodeBuy:setVisible(is_show)
    self._nodeUp:setVisible(not is_show)
end

function PassCheckLevel:onRefreshAll()
    if self._oldLevel ~= self._cacheData.level then
        self:srollToLevel(self._cacheData.level, true)
    end

    self:refreshBtn()
    self:refreshLock()
    self:refreshLevel()
    self:refreshRewardTip()
end

function PassCheckLevel:onActivate(event)
    if event.name ~= "ended" then
        return
    end
end

function PassCheckLevel:onUpActivate(event)
    if event.name ~= "ended" then
        return
    end
end

function PassCheckLevel:onBuyLevel(event)
    if event.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.RECEIVE_AWARDS)
    local tab = StaticData['pass']['Pass'] or {}
    if self._cacheData.level >= #tab then
         uq.fadeInfo(StaticData['local_text']['pass.full.lv'])
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.PASS_CHECK_GRADE_BUY_LEVEL)
end

function PassCheckLevel:setRuleState(func)
    self._func = func
end

function PassCheckLevel:onDec(event)
    if event.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    self._nodeDec:setVisible(true)
    if self._func then
        self._func()
    end
end

function PassCheckLevel:closeRule()
    self._nodeDec:setVisible(false)
end

function PassCheckLevel:onOneKeyFinish(event)
    if event.name ~= "ended" then
        return
    end
    if not uq.cache.pass_check:isCanOneKeyFinish() then
        uq.fadeInfo(StaticData["local_text"]["pass.not.reward"])
        return
    end
    network:sendPacket(Protocol.C_2_S_PASSCARD_LEVEL_ONEKEY_DRAW_REWARD, {})
end

function PassCheckLevel:initLevelList()
    local size = self._panelReward:getContentSize()
    self._listView = cc.TableView:create(cc.size(size.width, size.height))
    self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self._listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listView:setPosition(cc.p(0, 0))
    self._listView:setDelegate()
    self._listView:registerScriptHandler(handler(self, self.tableCellTouchedContent), cc.TABLECELL_TOUCHED)
    self._listView:registerScriptHandler(handler(self, self.cellSizeForTableContent), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listView:registerScriptHandler(handler(self, self.tableCellAtIndexContent), cc.TABLECELL_SIZE_AT_INDEX)
    self._listView:registerScriptHandler(handler(self, self.numberOfCellsInTableViewContent), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._listView:registerScriptHandler(handler(self, self.onListScroll), cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._listView:reloadData()
    self._panelReward:addChild(self._listView)

    self:srollToLevel(self._cacheData.level)
    self._txtDec1:setHTMLText(StaticData["local_text"]["pass.level.dec1"])
    self._txtDec2:setHTMLText(StaticData["local_text"]["pass.level.dec2"])
    self._nodeDec:setVisible(false)
end

function PassCheckLevel:tableCellTouchedContent(view, cell, touch)
    local index = cell:getIdx() + 1
    local cell_item = cell:getChildByTag(1000)
    cell_item:getReward(touch:getLocation())
end

function PassCheckLevel:cellSizeForTableContent(view, idx)
    return 120, 510
end

function PassCheckLevel:numberOfCellsInTableViewContent(view)
    return #self._passLevel
end

function PassCheckLevel:tableCellAtIndexContent(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("pass_check.PassCheckLevelCell")
        cell_item:setPositionY(-4)
        cell:addChild(cell_item)
        table.insert(self._allItems, cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end

    cell_item:setTag(1000)
    cell_item:setData(self._passLevel[index], self._cacheData)

    return cell
end

function PassCheckLevel:srollToLevel(index, animated)
    local index = 1
    if self._cacheData.level >= 3 then
        index = self._cacheData.level - 1
    end
    if self._cacheData.level >= #self._passLevel - 4 then
        index = #self._passLevel - 4 + 0.5
    end
    index = math.min(index, #self._passLevel - 6.5)
    self:scrollToCell(index, animated)
end

function PassCheckLevel:scrollToCell(index, animated)
    local point = self._listView:getContentOffset()
    local width, height = self:cellSizeForTableContent()
    point.x = -((index - 1) * width)
    self._listView:setContentOffset(point, animated)
    for i, v in ipairs(self._allItems) do
        v:refreshData()
    end
end

function PassCheckLevel:onExit()
    network:removeEventListenerByTag(self._eventOneKey)
    services:removeEventListenersByTag(self._eventTag)
    uq.TimerProxy:removeTimer(self._onTimerTag)
    PassCheckLevel.super.onExit(self)
end

function PassCheckLevel:onListScroll()
    local index = 0
    for k, item in ipairs(self._allItems) do
        if item:getId() > index then
            index = item:getId()
        end
    end
    if self._showIndex ~= index then
        self._showIndex = index
        self:refreshRewardTip()
    end
end

function PassCheckLevel:showAction()
    uq.intoAction(self._nodeDown, cc.p(0, -uq.config.constant.MOVE_DISTANCE))
    uq.intoAction(self._nodeLevelReward, cc.p(uq.config.constant.MOVE_DISTANCE, 0))
    uq.intoAction(self._nodeCenter)
    for i, v in ipairs(self._allItems) do
        v:showAction()
    end
end

return PassCheckLevel