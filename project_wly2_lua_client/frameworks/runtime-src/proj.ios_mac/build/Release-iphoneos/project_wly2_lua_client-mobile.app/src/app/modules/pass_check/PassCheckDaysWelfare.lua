local PassCheckDaysWelfare = class("PassCheckDaysWelfare", require('app.base.ChildViewBase'))

PassCheckDaysWelfare.RESOURCE_FILENAME = "pass_check/PassCheckDaysWelfare.csb"
PassCheckDaysWelfare.RESOURCE_BINDING = {
    ["Text_time"]    = {["varname"] = "_txtLeftTime"},
    ["ScrollView_1"] = {["varname"] = "_scrollView"},
    ["coin_txt"]     = {["varname"] = "_txtRewroacte"},
    ["Panel_1"]      = {["varname"] = "_panel"},
    ["Node_2"]       = {["varname"] = "_nodeLeftNum"},
    ["Text_6"]       = {["varname"] = "_txtLeftNum"},
    ["Button_1"]     = {["varname"] = "_btnRetroacte", ["events"] = {{["event"] = "touch",["method"] = "onRetroacte"}}},
    ["Text_10"]      = {["varname"] = "_txtState"},
    ["Image_8"]      = {["varname"] = "_imgActive", ["events"] = {{["event"] = "touch",["method"] = "onActive"}}},
    ["Image_9"]      = {["varname"] = "_nodeRewardDesc"},
    ["Image_10"]     = {["varname"] = "_imgReward"},
    ["Image_17"]     = {["varname"] = "_imgGot"},
    ["Node_5"]       = {["varname"] = "_nodeBase"},
}

function PassCheckDaysWelfare:ctor(name, params)
    PassCheckDaysWelfare.super.ctor(self, name, params)
end

function PassCheckDaysWelfare:onCreate()
    PassCheckDaysWelfare.super.onCreate(self)
    self:parseView()
    self._checkActiveNum = 14
    self._lineNum = 8
    self._allUi = {}
    self._info = uq.cache.pass_check._passCardInfo
    self._curDay = self._info.checkin_idx + 1
    local data = StaticData['pass']['Info'][self._info.season_id]
    self._xmlData = data['Checkin']
    self._complementXmlData = data['Complement']
    self._curData = {cur_day = self._curDay, can_checkin = self._info.can_checkin}
    self:initListView()
    self:refreshRetroacte()
    self._scrollView:setScrollBarEnabled(false)

    self._onTimerTag = "_onTimerTag" .. tostring(self)
    uq.TimerProxy:addTimer(self._onTimerTag, handler(self, self._refreshEndTime), 1, -1)

    self._networkTag = 'S_2_C_PASSCARD_CHECKIN' .. tostring(self)
    network:addEventListener(Protocol.S_2_C_PASSCARD_CHECKIN, handler(self, self._onCheckIn), self._networkTag)

    self._networkTag1 = 'S_2_C_PASSCARD_GET_CHECKIN_REWARD' .. tostring(self)
    network:addEventListener(Protocol.S_2_C_PASSCARD_GET_CHECKIN_REWARD, handler(self, self._onCheckInAgain), self._networkTag1)

    self._eventTag = services.EVENT_NAMES.ON_REFRESH_PASS_CHECK_INFO .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_REFRESH_PASS_CHECK_INFO, handler(self, self.refreshState), self._eventTag)

    self:refreshState()

    self._imgActive:ignoreContentAdaptWithSize(true)
end

function PassCheckDaysWelfare:onActive(event)
    if event.name ~= 'ended' then
        return
    end

    if self._txtState:getString() ~= StaticData['local_text']['activity.can.get'] then
        return
    end

    local function confirm()
        network:sendPacket(Protocol.C_2_S_PASSCARD_ACTIVATE)
    end
    --已经激活
    if uq.cache.pass_check._passCardInfo.state == 1 then
        local strs = string.split(StaticData['pass'].SpecOver[1].IfActivated, ';')
        local str = string.format(StaticData['local_text']['label.passcard.active'], tonumber(strs[2]))
        local data = {
            style = uq.config.constant.CONMFRIM_BOX_STYLE.CONFIRM_BTN_ONLY,
            content = str,
            confirm_callback = confirm
        }
        uq.addConfirmBox(data)
    else
        confirm()
    end
end

function PassCheckDaysWelfare:refreshState()
    self._nodeRewardDesc:setVisible(true)
    self._imgActive:loadTexture('img/pass_check/s03_00172.png')
    self._imgGot:setVisible(false)
    if uq.cache.pass_check._passCardInfo.checkin_idx < self._checkActiveNum then
        self._txtState:setString(string.format(StaticData['local_text']['pass.ten.day.rewards'], self._checkActiveNum - uq.cache.pass_check._passCardInfo.checkin_idx))
    else
        self._imgReward:removeAllChildren()
        if uq.cache.pass_check._passCardInfo.checkin_activated == 0 then
            self._txtState:setString(StaticData['local_text']['activity.can.get'])
            local size = self._imgReward:getContentSize()
            uq:addEffectByNode(self._imgReward, 900149, -1, true, cc.p(size.width / 2 , size.height / 2))
        else
            self._imgGot:setVisible(true)
            self._imgActive:loadTexture('img/pass_check/s03_00190.png')
            self._nodeRewardDesc:setVisible(false)
            self._txtState:setString(StaticData['local_text']['activity.finish.get'])
        end
    end
end

function PassCheckDaysWelfare:onRetroacte(event)
    if event.name ~= "ended" then
        return
    end
    if self._info.can_checkin == 0 and not uq.cache.role:checkRes(self._costItem:type(), self._costItem:num(), self._costItem:id()) then
        uq.fadeInfo(StaticData['local_text']['label.common.not.enough.gold'])
        return
    end
    network:sendPacket(Protocol.C_2_S_PASSCARD_CHECKIN, {checkin_type = 1})
end

function PassCheckDaysWelfare:_onCheckIn(msg)
    if msg.data.ret ~= 0 then
        return
    end
    if self._xmlData[self._curDay].multiple ~= 1 and self._info.state == 0 then
        table.insert(self._info.left_reward, self._xmlData[self._curDay].ident)
        uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, {rewards = self._xmlData[self._curDay].reward})
    else
        uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, {rewards = self._xmlData[self._curDay].multipleNums})
    end

    if msg.data.left_repair_nums >= 0 then
        self._curDay = msg.data.checkin_day + 1
        self._curData.cur_day = self._curDay
        self._curData.can_checkin = self._info.can_checkin
        self:refreshRetroacte()
        services:dispatchEvent({name = services.EVENT_NAMES.ON_PASS_DAYS_WELFARE_RETROACTE})
    end
    self:refreshState()
end

function PassCheckDaysWelfare:_onCheckInAgain(msg)
    if msg.data.ret == 0 then
        uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, {rewards = self._xmlData[msg.data.id].reward})
        services:dispatchEvent({name = services.EVENT_NAMES.ON_PASS_DAYS_WELFARE_RETROACTE})
    end
end

function PassCheckDaysWelfare:onRefreshRetroacte()
    self._costItem = uq.RewardType.new(self._complementXmlData[self._info.repair_times + 1].cost)
    local cost = self._costItem:num()
    self._txtRewroacte:setString(cost)
end

function PassCheckDaysWelfare:_refreshEndTime()
    self._txtLeftTime:setString(uq.cache.pass_check:getSurplusTimeString())
end

function PassCheckDaysWelfare:refreshRetroacte()
    self._btnRetroacte:setVisible(false)
    self._nodeLeftNum:setVisible(false)
    if self._info.can_checkin ~= 0 then
        return
    end

    if self._info.left_repair_nums > 0 then
        self._btnRetroacte:setVisible(true)
        self._nodeLeftNum:setVisible(true)
        self._nodeLeftNum:getChildByName("Text_6"):setString(self._info.left_repair_nums)
        self:onRefreshRetroacte()
    end
end

function PassCheckDaysWelfare:initListView()
    local size = self._scrollView:getContentSize()
    self._allUi = {}
    self._scrollView:removeAllChildren()
    local col_interval = 145
    local view_height = col_interval * (#self._xmlData / self._lineNum)
    self._scrollView:setInnerContainerSize(cc.size(size.width, view_height + 40))
    local up_height = view_height - 35

    local row = 1
    local col = 1
    for k, v in ipairs(self._xmlData) do
        local panel = uq.createPanelOnly("pass_check.PassCheckDaysWelfareCell")

        col = k
        if k > self._lineNum then
            row = math.floor(k / self._lineNum) + 1
            col = k - (row - 1)* self._lineNum
            if col == 0 then
                row = row - 1
                col = self._lineNum
            end
        end
        panel:setPosition(cc.p((col - 1) * 140 + 70, up_height - (row - 1) * col_interval))
        self._scrollView:addChild(panel)
        panel:setData(v, self._curData)
        table.insert(self._allUi, panel)
    end
end

function PassCheckDaysWelfare:showAction()
    uq.intoAction(self._nodeBase)
    for i, v in ipairs(self._allUi) do
        v:showAction()
    end
end

function PassCheckDaysWelfare:onExit()
    network:removeEventListenerByTag(self._networkTag)
    network:removeEventListenerByTag(self._networkTag1)
    services:removeEventListenersByTag(self._eventTag)
    uq.TimerProxy:removeTimer(self._onTimerTag)
    PassCheckDaysWelfare.super.onExit(self)
end

return PassCheckDaysWelfare