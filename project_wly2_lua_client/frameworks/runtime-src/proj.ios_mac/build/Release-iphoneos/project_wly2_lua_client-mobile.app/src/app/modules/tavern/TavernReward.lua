local TavernReward = class("TavernReward", require('app.base.PopupBase'))
local EquipItem = require("app.modules.common.EquipItem")

TavernReward.RESOURCE_FILENAME = "tavern/TavernReward.csb"
TavernReward.RESOURCE_BINDING = {
    ["Panel_2"]                      = {["varname"] = "_pnl"},
    ["Node_1"]                       = {["varname"] = "_nodeOnce"},
    ["item_node"]                    = {["varname"] = "_nodeItem"},
    ["Panel_4"]                      = {["varname"] = "_closePanel"},
    ["Button_1_0"]                   = {["varname"] = "_btnClose"},
    ["bg_1_img"]                     = {["varname"] = "_imgBg"},
    ["Button_1"]                     = {["varname"] = "_btnAgain"},
    ["Image_14"]                     = {["varname"] = "_imgCost"},
    ["Text_4"]                       = {["varname"] = "_txtCost"},
    ["Button_1/Text_9"]              = {["varname"] = "_txtAgainStr"},
}
function TavernReward:onCreate()
    TavernReward.super.onCreate(self)
    self:centerView()
    self:parseView()
    self:setLayerColor(0.4)
    self._listData = {}
    self._allItem = {}
    self._canClose = true
    self._closePanel:addClickEventListenerWithSound(function()
        if self._canClose then
            self:disposeSelf()
        end
    end)
    self._btnClose:addClickEventListenerWithSound(function()
        if self._canClose then
            self:disposeSelf()
        end
    end)
    self._btnAgain:addClickEventListenerWithSound(function()
        uq.playSoundByID(65)
        self:dealAgain()
    end)
    uq:addEffectByNode(self, 900046, -1, true, cc.p(330, 680))
    uq:addEffectByNode(self, 900047, -1, true, cc.p(830, 680))
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.RECEIVE_AWARDS)
    self:adaptBgSize(self._closePanel)
end

function TavernReward:setData(data)
    self._poolId = data.pool_id
    self._drinkNum = data.is_ten
    self._listData = self:dealData(data)
    if self._drinkNum == 1 then
        self._txtAgainStr:setString(StaticData["local_text"]["tavern.again.ten"])
    else
        self._txtAgainStr:setString(StaticData["local_text"]["tavern.again"])
    end
    if next(self._listData) ~= nil then
        self:initAction()
        self:creatItems()
    end
    self:refreshLayer()
end

function TavernReward:dealData(data)
    local data = data or {}
    if next(data) == nil then
        return {}
    end
    local xml_data = StaticData['appoint_item'][data.pool_id].Businessman
    if not xml_data or next(xml_data) == nil then
        return {}
    end
    local tab = {}
    for i, v in ipairs(data.items) do
        if xml_data[v.id].Item and xml_data[v.id].Item[v.item_id] and xml_data[v.id].Item[v.item_id].itemId then
            table.insert(tab, uq.RewardType:create(xml_data[v.id].Item[v.item_id].itemId):toEquipWidget())
        end
    end
    return tab
end

function TavernReward:creatItems()
    self._nodeItem:removeAllChildren()
    self._allItem = {}
    self:createOneItem(1)
end

function TavernReward:showNewGenerals()
    self._nodeOnce:stopAllActions()
    local func1 = cc.CallFunc:create(function()
                uq.refreshNextNewGeneralsShow()
                end)
    local func2 = cc.CallFunc:create(function()
                self._canClose = true
                end)
    local delay1 = cc.DelayTime:create(0.08)
    local delay2 = cc.DelayTime:create(0.1)
    self._nodeOnce:runAction(cc.Sequence:create(delay1, func1, delay2, func2))
end

function TavernReward:createOneItem(num)
    if num > #self._listData then
        self:showNewGenerals()
        return
    end
    self._canClose = false
    local data = self._listData
    local iconScale = 0.8
    local info = data[num]
    local item = EquipItem:create()
    item:setPosition(self:getItemsPos(num))
    item:setTouchEnabled(true)
    item:setInfo(info)
    item:addClickEventListenerWithSound(function(sender)
        local info = sender:getEquipInfo()
            uq.showItemTips(info)
        end)
    self._nodeItem:addChild(item)
    local nextFunc = function()
        num = num + 1
        self:createOneItem(num)
        item:setImgNameVisible(true, true)
    end
    local delay_time = 0.01
    if num == 1 then
        delay_time = 0.2
    end
    self:createAction(item._view, delay_time, nextFunc, 0.8)
    self._allItem[num] = item
end

function TavernReward:createAction( node, times, func, scale)
    node:setScale(0)
    node:runAction(cc.Sequence:create(
        cc.DelayTime:create(times),
        cc.Spawn:create(
            cc.ScaleTo:create(0.2, scale),
            cc.CallFunc:create(function()
                func()
                end))))
end

function TavernReward:refreshLayer()
    if not self._poolId then
        return
    end
    local is_ten = self._drinkNum == 1
    local cost_type, cost_num = uq.cache.tavern:getCostTypeAndNumById(self._poolId, is_ten)
    if cost_num ~= nil then
        self._txtCost:setString(tonumber(cost_num))
        local info = StaticData['types'].Cost[1].Type[cost_type]
        if info and info.miniIcon then
            self._imgCost:loadTexture("img/common/ui/" .. info.miniIcon)
        end
    end
end

function TavernReward:getItemsPos(num)
    if #self._listData == 1 then
        return cc.p(0, 0)
    end
    local ox = -380 + num * 140
    local oy = 100
    if num > 5 then
        oy = - 50
        ox = - 380 + (num -5) * 140
    end
    return cc.p(ox, oy)
end

function TavernReward:initAction()
    self._imgBg:setScaleX(0)
    self._imgBg:runAction(cc.ScaleTo:create(0.5, 1))
end

function TavernReward:dealAgain()
    if not self._canClose or not self._poolId then
        return
    end
    local is_ten = false
    if self._drinkNum == 1 then
        is_ten = true
    end
    uq.cache.tavern:sendTavernMsg(self._poolId, is_ten)
    self:disposeSelf()
end

return TavernReward