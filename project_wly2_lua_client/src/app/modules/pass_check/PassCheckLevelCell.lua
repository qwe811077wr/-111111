local PassCheckLevelCell = class("PassCheckLevelCell", require('app.base.ChildViewBase'))
local EquipItem = require("app.modules.common.EquipItem")

PassCheckLevelCell.RESOURCE_FILENAME = "pass_check/PassCheckLevelCell.csb"
PassCheckLevelCell.RESOURCE_BINDING = {
    ["Image_44"]            = {["varname"] = "_imgNormalReceived"},
    ["Image_44_0"]          = {["varname"] = "_imgSpecialReceived"},
    ["lv_txt"]              = {["varname"] = "_txtLevel"},
    ["lock_img"]            = {["varname"] = "_imgLock"},
    ["Node_1"]              = {["varname"] = "_nodeBase"},
}

function PassCheckLevelCell:ctor(name, params)
    PassCheckLevelCell.super.ctor(self, name, params)

    self._isExistRewardUp = false
    self._isExistRewardDown = false
end

function PassCheckLevelCell:onCreate()
    PassCheckLevelCell.super.onCreate(self)
    self:initReward(self._imgNormalReceived, 1)
    self:initReward(self._imgSpecialReceived, 2)
end

function PassCheckLevelCell:initReward(parent, effect_type)
    local node = parent:getChildByName('Node_2')
    for i = 1 , 2 , 1 do
        local reward = EquipItem:create()
        reward:setTouchEnabled(false)
        reward:addClickEventListener(function(sender)
            uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
            local info = sender:getEquipInfo()
            uq.showItemTips(info)
        end)
        reward:setSwallowTouches(false)
        reward:setScale(0.7)
        node:addChild(reward)
        reward:setName("reward" .. i)
        reward:setVisible(false)
    end
    local effect_id = 900117
    if effect_type == 2 then
        effect_id = 900173
    end
    local effect_node = parent:getChildByName('Node_3')
    uq:addEffectByNode(effect_node, effect_id, -1, true)
end

function PassCheckLevelCell:setData(xml_data, cache_data)
    self._cacheData = cache_data
    self._xmlData = xml_data
    local color = self._xmlData.ident <= self._cacheData.level and "#FFFFFF" or "#7FB5BF"
    self._txtLevel:setString(string.format(StaticData['local_text']['label.level'], xml_data.ident))
    self._txtLevel:setTextColor(uq.parseColor(color))
    self:refreshReward(self._imgNormalReceived, self._xmlData.freeGift)
    self:refreshReward(self._imgSpecialReceived, self._xmlData.passGift)

    self._isExistRewardUp = self:refreshBg(self._imgNormalReceived, self._cacheData.free_gift, 1)
    self._isExistRewardDown = self:refreshBg(self._imgSpecialReceived, self._cacheData.pass_gift, 2)
    self._imgLock:setVisible(self._cacheData.state == 0)
    self._imgNormalReceived:getChildByName('Node_3'):setVisible(self._isExistRewardUp)
    self._imgSpecialReceived:getChildByName('Node_3'):setVisible(self._isExistRewardDown)
    self:addListener()
end

function PassCheckLevelCell:refreshData()
    if next(self._cacheData) == nil or next(self._xmlData) == nil then
        return
    end
    self:setData(self._xmlData, self._cacheData)
end

function PassCheckLevelCell:addListener()
    self._networkTag = 'S_2_C_PASSCARD_LEVEL_DRAW_REWARD' .. tostring(self)
    network:addEventListener(Protocol.S_2_C_PASSCARD_LEVEL_DRAW_REWARD, handler(self, self.onLevelRefresh), self._networkTag)
end

function PassCheckLevelCell:refreshReward(parent, reward)
    local node = parent:getChildByName('Node_2')
    local children = node:getChildren()
    for k , v in pairs(children) do
        v:setTouchEnabled(false)
        v:setPositionY(0)
        v:setVisible(false)
    end
    local item_list = uq.RewardType.parseRewards(reward)
    for k, item in pairs(item_list) do
        local reward = node:getChildByName("reward" .. k)
        if reward ~= nil then
            reward:setInfo(item:toEquipWidget())
            reward:setTouchEnabled(true)
            if #item_list > 1 then
                reward:setPositionY(55 - (k - 1) * 110)
            end
            reward:setVisible(true)
        end
    end
end

function PassCheckLevelCell:refreshBg(bg, data, index)
    local tick = bg:getChildByName('Image_45')
    tick:setVisible(false)
    local node = bg:getChildByName('Node_2')
    local rewards = node:getChildren()
    node:setOpacity(255)
    local black_img = bg:getChildByName('Image_2')
    black_img:setVisible(self._xmlData.ident > self._cacheData.level)

    local is_exist = false
    self:setRewardTouch(rewards, true)
    if index == 2 and self._cacheData.state == 0 then
        return is_exist
    end

    table.sort(data, function (a, b)
        return a < b
    end)

    if self._xmlData.ident <= self._cacheData.level then
        is_exist = true
        self:setRewardTouch(rewards, false)
    end

    for k, v in pairs(data) do
        if self._xmlData.ident == v then
            node:setOpacity(150)
            tick:setVisible(true)
            is_exist = false
            self:setRewardTouch(rewards, true)
            break
        end
    end
    return is_exist
end

function PassCheckLevelCell:setRewardTouch(nodes, flag)
    for k, v in pairs(nodes) do
        v:setTouchEnabled(flag)
        v:setSwallowTouches(not flag)
    end
end

function PassCheckLevelCell:getReward(pos)
    self._pos = pos
    self:clickReward(self._imgNormalReceived, self._isExistRewardUp, 1, self._xmlData.freeGift)
    self:clickReward(self._imgSpecialReceived, self._isExistRewardDown, 2, self._xmlData.passGift)
end

function PassCheckLevelCell:onLevelRefresh(msg)
    if msg.data.id ~= self._xmlData.ident then
        return
    end
    local reward = ''
    if msg.data.draw_type == 1 then
        reward = self._xmlData.freeGift
        self._isExistRewardUp = self:refreshBg(self._imgNormalReceived, self._cacheData.free_gift, 1)
        self._imgNormalReceived:getChildByName('Node_3'):setVisible(self._isExistRewardUp)
    else
        reward = self._xmlData.passGift
        self._isExistRewardDown = self:refreshBg(self._imgSpecialReceived, self._cacheData.pass_gift, 2)
        self._imgSpecialReceived:getChildByName('Node_3'):setVisible(self._isExistRewardDown)
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, {rewards = reward})
end

function PassCheckLevelCell:clickReward(bg, is_exist, type, reward)
    local click_pos = bg:convertToNodeSpace(self._pos)
    local size = bg:getContentSize()
    local tick = bg:getChildByName('Image_45')
    local node = bg:getChildByName('Node_2')
    if click_pos.y >= 0 and click_pos.y <= size.height and is_exist then
        tick:setVisible(true)
        network:sendPacket(Protocol.C_2_S_PASSCARD_LEVEL_DRAW_REWARD, {id = self._xmlData.ident, drawtype = type})
    end
end

function PassCheckLevelCell:onExit()
    network:removeEventListenerByTag(self._networkTag)

    PassCheckLevelCell.super.onExit(self)
end

function PassCheckLevelCell:getId()
    return self._xmlData.ident
end

function PassCheckLevelCell:showAction()
    uq.intoAction(self._nodeBase)
end

return PassCheckLevelCell