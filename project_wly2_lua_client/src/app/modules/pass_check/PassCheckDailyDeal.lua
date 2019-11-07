local PassCheckDailyDeal = class("PassCheckDailyDeal", require('app.base.ChildViewBase'))
local EquipItem = require("app.modules.common.EquipItem")

PassCheckDailyDeal.RESOURCE_FILENAME = "pass_check/PassCheckDailyDeal.csb"
PassCheckDailyDeal.RESOURCE_BINDING = {
    ["Node_3"]               = {["varname"] = "_nodeBase"},
    ["Node_left"]            = {["varname"] = "_nodeLeft"},
    ["Node_center"]          = {["varname"] = "_nodeCenter"},
    ["Node_right"]           = {["varname"] = "_nodeRight"},
    ["finish_img"]           = {["varname"] = "_imgFinish"},
    ["Button_2"]             = {["varname"] = "_btnGift", ["events"] = {{["event"] = "touch",["method"] = "onWelfareGift"}}},
    ["Button_3"]             = {["varname"] = "_btnGift2", ["events"] = {{["event"] = "touch",["method"] = "onWelfareGift"}}},
    ["Node_center/Button_1"] = {["varname"] = "_btnCenter", ["events"] = {{["event"] = "touch",["method"] = "onClickBtn"}}},
    ["Node_left/Button_1"]   = {["varname"] = "_btnLeft", ["events"] = {{["event"] = "touch",["method"] = "onClickBtn"}}},
    ["Node_right/Button_1"]  = {["varname"] = "_btnRight", ["events"] = {{["event"] = "touch",["method"] = "onClickBtn"}}},
}

function PassCheckDailyDeal:ctor(name, params)
    PassCheckDailyDeal.super.ctor(self, name, params)
end

function PassCheckDailyDeal:onCreate()
    PassCheckDailyDeal.super.onCreate(self)
    self:parseView()
    self._maxBoxNum = 6
    self._allUi = {}
    self._info = uq.cache.pass_check._passCardInfo
    self._dailyInfo = self._info.daily_gift
    self._xmlData = StaticData['pass']['Info'][self._info.season_id]['Gift']
    self._payInfo = StaticData['pay']
    self:refreshDaily()
    self:refreshWelfareGift()

    self._eventTag = services.EVENT_NAMES.ON_REFRESH_PASS_CHECK_INFO .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_REFRESH_PASS_CHECK_INFO, handler(self, self.refreshDailyBuy), self._eventTag)
    self._eventTagGift = services.EVENT_NAMES.ON_ACHIEVEMENT_WELFARE_GIFT .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_ACHIEVEMENT_WELFARE_GIFT, handler(self, self.onShowWelfareGift), self._eventTagGift)
end

function PassCheckDailyDeal:onClickBtn(event)
    if event.name ~= "ended" then
        return
    end
    self._curInfo = event.target['userData']
end

function PassCheckDailyDeal:onWelfareGift(event)
    if event.name ~= "ended" then
        return
    end
    if not uq.cache.pass_check:isCanBuyWelfareGift() then
        return
    end
    network:sendPacket(Protocol.C_2_S_PASSCARD_DRAW_DAILY_FREE_GIFT, {})
end

function PassCheckDailyDeal:refreshDaily()
    self:initSingleData(self._nodeLeft, self._xmlData[1])
    self:initSingleData(self._nodeCenter, self._xmlData[2])
    self:initSingleData(self._nodeRight, self._xmlData[3])
end

function PassCheckDailyDeal:onShowWelfareGift(msg)
    self:refreshWelfareGift()
    local rewards = StaticData['pass']['Info'][self._info.season_id].dailyFreeGift or ""
    if not rewards or rewards == "" then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE,{rewards = rewards})
end

function PassCheckDailyDeal:refreshWelfareGift()
    local is_buy = uq.cache.pass_check:isCanBuyWelfareGift()
    self._btnGift:removeAllChildren()
    if is_buy then
        local size = self._btnGift:getContentSize()
        uq:addEffectByNode(self._btnGift, 900150, -1, true, cc.p(size.width / 2 + 8 , size.height / 2 - 5))
    end

    self._imgFinish:setVisible(not is_buy)
    self._btnGift:setEnabled(is_buy)
end

function PassCheckDailyDeal:initSingleData(node, xml_data)
    local btn = node:getChildByName("Button_1")
    btn['userData'] = xml_data

    self:initReward(node, xml_data)
    self:initDaily(node, xml_data)
    self:refreshDailyBuyState(node, xml_data)
end

function PassCheckDailyDeal:refreshDailyBuy(msg)
    self._dailyInfo = self._info.daily_gift
    self:refreshDailyBuyState(self._nodeLeft, self._xmlData[1])
    self:refreshDailyBuyState(self._nodeCenter, self._xmlData[2])
    self:refreshDailyBuyState(self._nodeRight, self._xmlData[3])

    if msg.data == 1 then
        uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE,{rewards = self._curInfo.reward})
    end
end

function PassCheckDailyDeal:initReward(node, data)
    local reward_panel = node:getChildByName("Panel_1")
    reward_panel:removeAllChildren()
    local item_list = uq.RewardType.parseRewards(data.reward)
    for i, v in ipairs(item_list) do
        if i > self._maxBoxNum then
            return
        end
        local euqip_item = EquipItem:create({info = v:toEquipWidget()})
        reward_panel:addChild(euqip_item)
        euqip_item:setScale(0.8)
        euqip_item:setPosition(cc.p(((i - 1) % 3 + 1) * 115 - 65, 277 - math.ceil(i / 3) * 115))
        euqip_item:setTouchEnabled(true)
        euqip_item:addClickEventListener(function(sender)
            uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
            local info = sender:getEquipInfo()
            uq.showItemTips(info)
        end)
        euqip_item:setSwallowTouches(false)
        table.insert(self._allUi, euqip_item)
    end
end

function PassCheckDailyDeal:initDaily(node, data)
    local shade = node:getChildByName("Image_23"):setVisible(false)
    local btn = node:getChildByName("Button_1"):setVisible(true)
    local details = node:getChildByName("Text_1")
    local icon = node:getChildByName("Image_12")
    local item_list = uq.RewardType.parseRewards(data.reward)
    details:setVisible(#item_list > self._maxBoxNum)
    icon:setVisible(#item_list > self._maxBoxNum)
    details:setTouchEnabled(true)
    details:addClickEventListenerWithSound(function (sender)
        uq.ModuleManager:getInstance():show(uq.ModuleManager.REWARD_PREVIEW_MODULE,{rewards = data.reward})
    end)

    local now_price = node:getChildByName("Text_7")
    now_price:setString(string.format(StaticData["local_text"]["pass.old.cost"], data.price))

    local coin = self._payInfo[data.payId]['coin']
    local btn_txt = btn:getChildByName("Text_20")
    btn_txt:setString(string.format(StaticData["local_text"]["pass.buy.coin"], coin))
end

function PassCheckDailyDeal:refreshDailyBuyState(node, data)
    local shade = node:getChildByName("Image_23"):setVisible(false)
    local btn = node:getChildByName("Button_1"):setVisible(true)

    for k, v in pairs(self._dailyInfo) do
        if v.id == data.ident and v.num == data.buyTimes then
            btn:setVisible(false)
            shade:setVisible(true)
            break
        end
    end
end

function PassCheckDailyDeal:showAction()
    uq.intoAction(self._nodeBase)
    for i, v in ipairs(self._allUi) do
        uq.intoAction(v)
    end
end

function PassCheckDailyDeal:onExit()
    services:removeEventListenersByTag(self._eventTag)
    services:removeEventListenersByTag(self._eventTagGift)
    PassCheckDailyDeal.super.onExit(self)
end

return PassCheckDailyDeal