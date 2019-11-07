local PassCheckDaysWelfareCell = class("PassCheckDaysWelfareCell", require('app.base.ChildViewBase'))
local EquipItem = require("app.modules.common.EquipItem")

PassCheckDaysWelfareCell.RESOURCE_FILENAME = "pass_check/PassCheckDaysWelfareCell.csb"
PassCheckDaysWelfareCell.RESOURCE_BINDING = {
    ["Node_1"]              = {["varname"] = "_nodeBase"},
    ["Node_item"]           = {["varname"] = "_nodeItem"},
    ["Image_6"]             = {["varname"] = "_imgFinish1"},
    ["Image_22"]            = {["varname"] = "_imgNums"},
    ["Image_14"]            = {["varname"] = "_imgFinish"},
    ["light_img"]           = {["varname"] = "_imgLight"},
    ["Button_1"]            = {["varname"] = "_btnReceivedAgain", ["events"] = {{["event"] = "touch",["method"] = "_onReceviedAgain"}}},
}

function PassCheckDaysWelfareCell:ctor(name, params)
    PassCheckDaysWelfareCell.super.ctor(self, name, params)
end

function PassCheckDaysWelfareCell:onCreate()
    PassCheckDaysWelfareCell.super.onCreate(self)

    self._eventTag = services.EVENT_NAMES.ON_PASS_DAYS_WELFARE_RETROACTE .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_PASS_DAYS_WELFARE_RETROACTE, handler(self, self.refreshState), self._eventTag)
end

function PassCheckDaysWelfareCell:onExit()
    services:removeEventListenersByTag(self._eventTag)

    PassCheckDaysWelfareCell.super.onExit(self)
end

function PassCheckDaysWelfareCell:setData(xml_data, cache_data)
    self._xmlData = xml_data
    self._cacheData = cache_data

    self:refreshReward()
    self:refreshState()

    self._imgNums:setVisible(false)
    if xml_data.multiple ~= 1 then
        self._imgNums:setVisible(true)
    end
end

function PassCheckDaysWelfareCell:showAction()
    uq.intoAction(self._nodeBase)
    uq.intoAction(self._imgNums)
end

function PassCheckDaysWelfareCell:refreshReward()
    self._nodeItem:removeAllChildren()
    local item = uq.RewardType.new(self._xmlData.reward)
    self._item = EquipItem:create({info = item:toEquipWidget()})
    self._item:setScale(0.8)
    self._item:setTouchEnabled(true)
    self._item:addClickEventListener(function(sender)
        if self._cacheData.can_checkin > 0 and uq.cache.pass_check:isSignOrByid(self._xmlData.ident) then
            uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
            network:sendPacket(Protocol.C_2_S_PASSCARD_CHECKIN, {checkin_type = 1})
            return
        end
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
        local info = sender:getEquipInfo()
        uq.showItemTips(info)
    end)
    self._item:setSwallowTouches(false)
    self._nodeItem:addChild(self._item)
end

function PassCheckDaysWelfareCell:refreshState()
    local is_show = self._xmlData.ident < self._cacheData.cur_day
    local is_light = self._cacheData.can_checkin > 0 and uq.cache.pass_check:isSignOrByid(self._xmlData.ident)
    self._imgLight:setVisible(is_light)
    self._imgLight:removeAllChildren()
    if is_light then
        uq:addEffectByNode(self._imgLight, 900053, -1, true, cc.p(67.5, 66.5), nil, 1.1)
    end

    local is_again = self:refreshDrawAgain()
    self._btnReceivedAgain:setVisible(is_again)
    self._imgFinish1:setVisible(is_show and not is_again)
    self._imgFinish:setVisible(is_show)
end

function PassCheckDaysWelfareCell:_onReceviedAgain(event)
    if event.name ~= "ended" then
        return
    end

    if uq.cache.pass_check._passCardInfo.state == 0 then
        uq.fadeInfo(StaticData['local_text']['pass.active'])
        return
    end
    network:sendPacket(Protocol.C_2_S_PASSCARD_GET_CHECKIN_REWARD, {id = self._xmlData.ident})
end

function PassCheckDaysWelfareCell:refreshDrawAgain()
    for k, v in pairs(uq.cache.pass_check._passCardInfo.left_reward) do
        if v == self._xmlData.ident then
            return true
        end
    end
    return false
end

return PassCheckDaysWelfareCell