local SignItems = class("SignItems", require('app.base.ChildViewBase'))
local EquipItem = require("app.modules.common.EquipItem")

SignItems.RESOURCE_FILENAME = "activity/SignItems.csb"
SignItems.RESOURCE_BINDING = {
    ["Node_3/Image_10"]               = {["varname"] = "_imgBg1"},
    ["Node_3/Image_13"]               = {["varname"] = "_imgFinish"},
    ["Node_3/Node_4"]                 = {["varname"] = "_nodeItems"},
    ["Node_3/state_1_txt_0_0"]        = {["varname"] = "_txtDays"},
    ["icon_spr"]                      = {["varname"] = "_sprIcon"},
    ["num_txt"]                       = {["varname"] = "_txtNum"},
    ["ok_btn"]                        = {["varname"] = "_btnOk"},
    ["action_node"]                   = {["varname"] = "_nodeAction"},
}

function SignItems:onCreate()
    SignItems.super.onCreate(self)
    self:parseView()
end

function SignItems:setData(data, can_sign)
    if not data or next(data) == nil then
        return
    end
    self._nodeAction:removeAllChildren()
    local checkin_id = uq.cache.achievement:getCanSignId()
    local can_sign = uq.cache.achievement:isCanSign()
    if checkin_id == data.ident then
        self._imgBg1:loadTexture("img/activity/s03_000595-1.png")
        if can_sign then
            uq:addEffectByNode(self._nodeAction, 900071, -1, true, cc.p(20, -200))
        end
    elseif checkin_id < data.ident then
        self._imgBg1:loadTexture("img/activity/s03_000595-2.png")
    else
        self._imgBg1:loadTexture("img/activity/s03_000595-0.png")
    end
    self._imgFinish:setVisible(checkin_id > data.ident or (not can_sign and checkin_id == data.ident))
    local color = checkin_id == data.ident and "#6c6353" or "#2d3234"
    self._txtDays:setString(StaticData["local_text"]["activity.sign.day" .. data.ident])
    self._txtDays:setTextColor(uq.parseColor(color))
    self._btnOk:addClickEventListenerWithSound(function(sender)
        if uq.cache.achievement:isCanSign() and data.ident == uq.cache.achievement:getCanSignId() then
            network:sendPacket(Protocol.C_2_S_ROLE_CHECKIN, {checkin_type = 0})
            return
        end
    end)
    if data.reward and data.reward ~= "" then
        local tab_reward = uq.RewardType:create(data.reward):toEquipWidget()
        local tab_info = StaticData.getCostInfo(tab_reward.type, tab_reward.id)
        if tab_info and tab_info.icon then
            self._sprIcon:setTexture("img/common/item/" .. tab_info.icon)
        end
        self._txtNum:setString(uq.formatResource(tab_reward.num, true))
    end
end
return SignItems