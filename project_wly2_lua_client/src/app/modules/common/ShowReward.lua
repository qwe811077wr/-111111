local ShowReward = class("ShowReward", require('app.base.PopupBase'))
local EquipItem = require("app.modules.common.EquipItem")

ShowReward.RESOURCE_FILENAME = "common/ShowReward.csb"
ShowReward.RESOURCE_BINDING = {
    ["Panel_1"]                     = {["varname"] = "_panel1"},
    ["Image_9"]                     = {["varname"] = "_imgBg"},
    ["Panel_2"]                     = {["varname"] = "_panelRewards"},
    ["node_title"]                  = {["varname"] = "_nodeTitleEff"},
    ["Image_11"]                    = {["varname"] = "_imgGet"},
    ["Text_10"]                     = {["varname"] = "_desLabel"},
    ["Node_3"]                      = {["varname"] = "_nodeTitle"},
    ["Panel_7"]                     = {["varname"] = "_pnlTwo"},
    ["left_btn"]                    = {["varname"] = "_btnLeft"},
    ["right_btn"]                   = {["varname"] = "_btnRight"},
    ["left_txt"]                    = {["varname"] = "_txtLeft"},
    ["right_txt"]                   = {["varname"] = "_txtRight"},
    ["left_btn_txt"]                = {["varname"] = "_txtDecLeft"},
    ["right_btn_txt"]               = {["varname"] = "_txtDecRight"},
}

function ShowReward:ctor(name, args)
    args._isStopAction = true
    ShowReward.super.ctor(self, name, args)
    self._data = args or {}
    self._curInfo = args.rewards
    self._callback = args.callBack
    self._showTwo = args.show_two
    uq.AnimationManager:getInstance():getEffect('txf_27_1')
end

function ShowReward:init()
    self._showRewardItemTag = "appear_reward_item_card"
    self:parseView()
    self:centerView()
    self:setLayerColor(0.7)
    self._scale = 0.9
    self._curRewardIndex = 0
    self._curItemIndex = 0
    self._imgBg:setScaleY(0)
    self._panel1:setTouchEnabled(true)
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.RECEIVE_AWARDS)
    self._panel1:addClickEventListenerWithSound(handler(self, self._onPanelTouched))
    self._pnlTwo:setVisible(false)
    self._btnLeft:addClickEventListenerWithSound(function(sender)
        if self._data.left_func then
            self._data.left_func()
        end
        self:disposeSelf()
    end)
    self._btnRight:addClickEventListenerWithSound(function(sender)
        if self._data.right_func then
            self._data.right_func()
        end
        self:disposeSelf()
    end)
    self:initUi()
end

function ShowReward:_onPanelTouched(evt)
    if not self._curItemIndex or not self._curRewardNum then
        return
    end
    if self._curRewardIndex < #self._totalRewardInfo then
        uq.TimerProxy:removeTimer(self._showRewardItemTag)
        if self._curItemIndex == self._curRewardNum then
            self:setRewardData()
            return
        end
        for i = self._curItemIndex + 1, self._curRewardNum do
            self:setRewardItemData()
        end
        return
    end

    if self._curRewardIndex == #self._totalRewardInfo then
        if self._showTwo then
            return
        end
        self:disposeSelf()
    end
end

function ShowReward:initUi()
    self._curRewardInfo = {}
    if not self._curInfo then
        return
    end
    if type(self._curInfo) == "string" then
        self:updateString()
    elseif type(self._curInfo) == "table" then
        self:updateTable()
    end
    self:runShowAction()
end

function ShowReward:runShowAction()
    local size = self._imgBg:getContentSize()
    self._nodeTitle:setScale(0)
    uq:addEffectByNode(self._nodeTitleEff, 900046, 1, false)
    self._nodeTitle:runAction(cc.Sequence:create(cc.ScaleTo:create(1 / 12, 0.2), cc.ScaleTo:create(1 / 12, 0.6), cc.ScaleTo:create(1 / 12, 1.0)))
    self._imgBg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1), cc.CallFunc:create(function()
        self:setRewardData()
    end)))
    uq.delayAction(self._imgGet, 0.1, uq.refreshNextNewGeneralsShow)
end

function ShowReward:updateString()
    local reward_array = string.split(self._curInfo,"|")
    local total_num = #reward_array
    self._totalRewardInfo = {}
    for _,t in ipairs(reward_array) do
        local str = string.split(t,";")
        local info = {}
        info.type = tonumber(str[1])
        info.id = tonumber(str[3])
        info.num = tonumber(str[2])
        table.insert(self._totalRewardInfo,info)
    end
end

function ShowReward:setRewardData()
    self._curRewardNum = #self._totalRewardInfo - self._curRewardIndex
    self._desLabel:setString(StaticData['local_text']['label.press.exit'])
    if self._curRewardNum > 8 then
        self._curRewardNum = 8
        self._desLabel:setString(StaticData['local_text']['guide.click.go'])
    end
    self:clearData()
    self._curItemIndex = 0
    uq.TimerProxy:removeTimer(self._showRewardItemTag)
    uq.TimerProxy:addTimer(self._showRewardItemTag, handler(self, self.setRewardItemData), 0.1, self._curRewardNum)
end

function ShowReward:clearData()
    for k, v in ipairs(self._curRewardInfo) do
        v:setVisible(false)
    end
end

function ShowReward:setRewardItemData()
    if not self._curRewardInfo then
        return
    end
    self._curItemIndex = self._curItemIndex + 1
    self._curRewardIndex = self._curRewardIndex + 1
    if not self._curRewardInfo[self._curItemIndex] then
        local equip_item = EquipItem:create({info = self._totalRewardInfo[self._curRewardIndex]})
        equip_item:setAnchorPoint(cc.p(0.5, 0.5))
        equip_item:setPosition(self:getItemPosition(self._curItemIndex, self._curRewardNum))
        equip_item:setTouchEnabled(true)
        equip_item:setImgNameVisible(true, false)
        equip_item:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, self._scale + 0.2), cc.ScaleTo:create(0.1, self._scale)))
        equip_item:addClickEventListenerWithSound(function(sender)
            local info = sender:getEquipInfo()
            uq.showItemTips(info)
        end)
        self._panelRewards:addChild(equip_item)
        table.insert(self._curRewardInfo, equip_item)
    else
        self._curRewardInfo[self._curItemIndex]:setInfo(self._totalRewardInfo[self._curRewardIndex])
        self._curRewardInfo[self._curItemIndex]:setVisible(true)
        self._curRewardInfo[self._curItemIndex]:setImgNameVisible(true, false)
        self._curRewardInfo[self._curItemIndex]:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, self._scale + 0.2), cc.ScaleTo:create(0.1, self._scale)))
        self._curRewardInfo[self._curItemIndex]:setPosition(self:getItemPosition(self._curItemIndex, self._curRewardNum))
    end
    if self._curItemIndex == self._curRewardNum and self._showTwo then
        self:showLayerTwo()
    end
end

function ShowReward:showLayerTwo()
    self._pnlTwo:setVisible(true)
    local dec = self._data.left_txt or ""
    local dec1 = self._data.right_txt or ""
    local txt = self._data.left_btn_txt or ""
    local txt1 = self._data.right_btn_txt or ""
    self._txtLeft:setString(dec)
    self._txtRight:setString(dec1)
    self._txtDecLeft:setString(txt)
    self._txtDecRight:setString(txt1)
    self._desLabel:setString("")
end

function ShowReward:getItemPosition(index, num)
    local pos_x = 0
    if num % 2 == 0 then
        pos_x = -60 - math.floor((num - 1) / 2) * 120
    else
        pos_x = -math.floor(num / 2) * 120
    end
    return cc.p(pos_x + (index - 1) * 120, 0)
end

function ShowReward:updateTable()
    self._totalRewardInfo = {}
    for _,t in ipairs(self._curInfo) do
        local id = t.id or t.paraml
        local info = {}
        info.type = tonumber(t.type)
        info.id = tonumber(id)
        info.num = tonumber(t.num)
        table.insert(self._totalRewardInfo,info)
    end
end

function ShowReward:dispose()
    if self._callback then
        self._callback()
    end
    ShowReward.super.dispose(self)
    uq.cache.generals:clearNewGenerals()
    uq.cache.achievement:showOpenChapter()
end
return ShowReward