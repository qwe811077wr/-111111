local PassCheckLimitPackage = class("PassCheckLimitPackage", require('app.base.ChildViewBase'))
local EquipItem = require("app.modules.common.EquipItem")

PassCheckLimitPackage.RESOURCE_FILENAME = "pass_check/PassCheckLimitPackage.csb"
PassCheckLimitPackage.RESOURCE_BINDING = {
    ["Node_3"]              = {["varname"] = "_nodeBase"},
    ["time_txt"]            = {["varname"] = "_txtLeftTime"},
    ["ScrollView_1"]        = {["varname"] = "_scrollView"},
    ["items_1_node"]        = {["varname"] = "_node1"},
    ["items_2_node"]        = {["varname"] = "_node2"},
    ["items_3_node"]        = {["varname"] = "_node3"},
}

function PassCheckLimitPackage:ctor(name, params)
    PassCheckLimitPackage.super.ctor(self, name, params)
end

function PassCheckLimitPackage:onCreate()
    PassCheckLimitPackage.super.onCreate(self)
    self:parseView()
    self._btn = {}
    self._tabReward = {}
    self._info = uq.cache.pass_check._passCardInfo
    self._specInfo = self._info.spec_gift
    self._payInfo = StaticData['pay'] or {}
    self._xmlData = StaticData['pass']['Info'][self._info.season_id]['SpecialGift'] or {}
    self._boxReward = StaticData['pass']['Info'][self._info.season_id]['specShowReward'] or ""
    self:initLayer()
    self:refreshLayer()
    self._timerTag = 'leftTime' .. tostring(self)
    uq.TimerProxy:addTimer(self._timerTag, handler(self, self.setTimeLeft), 1, -1)

    self._eventTag = services.EVENT_NAMES.ON_REFRESH_PASS_CHECK_INFO .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_REFRESH_PASS_CHECK_INFO, handler(self, self.refreshPackageBuy), self._eventTag)
end

function PassCheckLimitPackage:initLayer()
    self._scrollView:setScrollBarEnabled(false)

    self._scrollView:removeAllChildren()
    if self._boxReward and self._boxReward ~= "" then
        local ox = 120
        local tab_award = uq.RewardType.parseRewards(self._boxReward)
        for i, v in pairs(tab_award) do
            local item = EquipItem:create()
            item:setTouchEnabled(true)
            item:setPosition(cc.p((i - 0.5) * (ox * 0.7 + 10), ox / 2 + 30))
            item:setScale(0.7)
            item:setInfo(v:toEquipWidget())
            item:addClickEventListener(function(sender)
                uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
                local info = sender:getEquipInfo()
                uq.showItemTips(info)
            end)
            self._scrollView:addChild(item)
        end
        self._scrollView:setInnerContainerSize(cc.size(#tab_award * (ox * 0.7 + 10), ox + 20))
    end
end

function PassCheckLimitPackage:refreshLayer()
    for i = 1, 3 do
        self:refreshBoxs(self["_node" .. i], i, self._xmlData[i])
    end
end

function PassCheckLimitPackage:refreshBoxs(node, i, info)
    if not info or next(info) == nil then
        return
    end
    local btn = node:getChildByName("buy_btn")
    local btn_details = node:getChildByName("details_btn")
    local buy_times, min_buy, limit_lv = self:getBuyTimes(info)
    node:getChildByName("lock_img"):setVisible(min_buy == 0)
    node:getChildByName("limit_txt"):setVisible(min_buy == 0)
    node:getChildByName("old_coin_btn"):setString(string.format(StaticData["local_text"]["pass.old.cost"], info.price))
    node:getChildByName("limit_txt"):setString(string.format(StaticData["local_text"]["pass.need.limit.lv"], limit_lv))
    local is_can_buy = min_buy ~= 0 and buy_times > 0
    node:getChildByName("discount_img"):setVisible(is_can_buy)
    node:getChildByName("discount_txt"):setVisible(is_can_buy)
    node:getChildByName("discount_txt"):setString(string.format(StaticData["local_text"]["pass.surplus.num"], buy_times))
    btn:setVisible(buy_times > 0)
    btn:setEnabled(is_can_buy)
    local coin_cost = self._payInfo[info.payId]['coin'] or 1
    btn:getChildByName("new_coin_txt"):setString(tostring(coin_cost))
    local num1, num2 = self:getBoxsNumAndCoinNum(info.reward)
    node:getChildByName("num_txt_0"):setString(string.format(StaticData["local_text"]["pass.boxs.num"], num1))
    node:getChildByName("num_txt"):setString(tostring(num2))
    node:getChildByName("finish_img"):setVisible(min_buy ~= 0 and buy_times <= 0)
    btn_details:addClickEventListener(function ()
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
        self._tabReward = self._xmlData[i]
        uq.ModuleManager:getInstance():show(uq.ModuleManager.REWARD_PREVIEW_MODULE,{rewards = info.reward})
    end)
    btn:addClickEventListenerWithSound(function ()
    end)
    if not self._tabReward or next(self._tabReward) == nil then
        self._tabReward = self._xmlData[i]
    end
end

function PassCheckLimitPackage:getBoxsNumAndCoinNum(reward)
    if not reward or reward == "" then
        return 0, 0
    end
    local num1 = 0
    local num2 = 0
    local item_list = uq.RewardType.parseRewards(reward)
    for i, v in ipairs(item_list) do
        local tab = v:toEquipWidget()
        if i == 1 then
            num1 = tab.num
        elseif tab.type == 30 then
            num2 = tab.num
        end
    end
    return num1, num2
end

function PassCheckLimitPackage:refreshPackageBuy(msg)
    self._specInfo = self._info.spec_gift
    self:refreshLayer()
    if msg.data == 2 then
        uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE,{rewards = self._tabReward.reward})
    end
end

function PassCheckLimitPackage:getBuyTimes(data)
    local buy_times = 0
    local min_buy = 0
    local lv = 0
    local times_info = string.split(data.buyTimes, ';')
    for k, v in ipairs(times_info) do
        local info = string.split(v, ',')
        if tonumber(info[1]) <= self._info.level then
            buy_times = tonumber(info[2])
        end
        lv = tonumber(info[1])
    end
    min_buy = buy_times

    for k, v in pairs(self._specInfo) do
        if v.id == data.ident then
            buy_times = buy_times - v.num
            break
        end
    end
    return buy_times, min_buy, lv
end

function PassCheckLimitPackage:setTimeLeft()
    local cur_time = os.date("*t", uq.curServerSecond())
    local hour = cur_time.hour
    local min = cur_time.min
    local sec = cur_time.sec
    local time = hour * 60 * 60 + min * 60 + sec
    local four_time = 4 * 60 * 60
    if tonumber(hour) >= 4 then
        four_time = four_time + 24 * 60 * 60
    end
    local left_time = four_time - time
    local left_hour, left_minute, left_second = uq.getTime(left_time)
    self._txtLeftTime:setString(string.format("%d:%02d:%02d", left_hour, left_minute, left_second))
end

function PassCheckLimitPackage:getRewardItem(node)
    local euqip_item = EquipItem:create({info = node:toEquipWidget()})
    euqip_item:setScale(0.85)
    euqip_item:setTouchEnabled(true)
    euqip_item:addClickEventListener(function(sender)
        local info = sender:getEquipInfo()
        uq.showItemTips(info)
    end)
    return euqip_item
end

function PassCheckLimitPackage:onShop(event)
    if event.name ~= "ended" then
        return
    end
    network:sendPacket(Protocol.C_2_S_PASSCARD_STONE_LOAD)
end

function PassCheckLimitPackage:showAction()
    uq.intoAction(self._nodeBase)
end

function PassCheckLimitPackage:onExit()
    services:removeEventListenersByTag(self._eventTag)
    uq.TimerProxy:removeTimer(self._timerTag)
    PassCheckLimitPackage.super.onExit(self)
end

return PassCheckLimitPackage