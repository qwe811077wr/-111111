local BuyMilitoryOrder = class("BuyMilitoryOrder", require('app.base.PopupBase'))
local EquipItem = require("app.modules.common.EquipItem")

BuyMilitoryOrder.RESOURCE_FILENAME = "main_city/BuyMilitoryOrder.csb"
BuyMilitoryOrder.RESOURCE_BINDING = {
    ["text_num"]       = {["varname"] = "_txtNum"},
    ["text_left_num"]  = {["varname"] = "_txtLeftNum"},
    ["button_guy"]     = {["varname"] = "_btnBuy",["events"] = {{["event"] = "touch",["method"] = "onBtnBuy"}}},
    ["Node_1"]         = {["varname"] = "_nodeGold"},
    ["txt_money"]      = {["varname"] = "_txtGold"},
    ["items_node"]     = {["varname"] = "_nodeItems"},
    ["dec_txt"]        = {["varname"] = "_txtDec"},
    ["name_txt"]       = {["varname"] = "_txtName"},
    ["close_btn"]      = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onClose"}}},
    ["text_num_0"]     = {["varname"] = "_curRefreshTime"},
    ["text_num_1"]     = {["varname"] = "_totalRefrshTime"},
    ["text_num_1_0"]   = {["varname"] = "_txtTips"},
    ["Text_4_0_1"]     = {["varname"] = "_curRefreshTimeTitle"},
    ["Text_4_0_2"]     = {["varname"] = "_totalRefreshTimeTitle"},
}

function BuyMilitoryOrder:onCreate()
    BuyMilitoryOrder.super.onCreate(self)
    self:centerView()
    self:parseView()

    self._type = uq.config.constant.COST_RES_TYPE.MILITORY_ORDER
    self._xmlInfo = uq.cache.role:getResRefreshXml(self._type)
    self._configXml = StaticData['constant'][14].Data
    self._limitNum = 10
    self:initLayer()
    self:refreshPage()

    network:addEventListener(Protocol.S_2_C_LOAD_RESOURCE_REFRESH, handler(self, self._refreshTime), 'on_add_update_time' .. tostring(self))
    network:sendPacket(Protocol.C_2_S_LOAD_RESOURCE_REFRESH, {id = self._type})
    self._eventName = services.EVENT_NAMES.ON_CONSUME_RES_CHANGE .. uq.config.constant.COST_RES_TYPE.MILITORY_ORDER
    self._eventTag = self._eventName .. tostring(self)
    services:addEventListener(self._eventName, handler(self, self.refreshPage), self._eventTag)

    self._eventBuy = services.EVENT_NAMES.BUY_MILITORY_ORDER .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.BUY_MILITORY_ORDER, handler(self, self.refreshPage), self._eventBuy)
end

function BuyMilitoryOrder:initLayer()
    local item = EquipItem:create()
    item:setTouchEnabled(true)
    item:setScale(0.8)
    item:setInfo({["type"] = self._type, ["num"] = 0, ["id"] = 0})
    item:addClickEventListenerWithSound(function(sender)
        local info = sender:getEquipInfo()
        uq.showItemTips(info)
    end)
    self._nodeItems:addChild(item)
end

function BuyMilitoryOrder:_refreshTime(msg)
    local data = msg.data
    if data.id ~= self._type then
        return
    end
    if self._timerField then
        self._timerField:dispose()
        self._timerField = nil
    end

    local total_num = math.floor(StaticData['types'].MaxLimit[1].Type[3].value)
    local cur_num = uq.cache.role:getResNum(self._type)
    local state = cur_num >= total_num
    local left_time = state and 0 or data.cd_time
    local total_time = state and 0 or data.cd_time + (total_num - cur_num - 1) * self._xmlInfo.time

    if state then
        return
    end

    local function timer_end()
        if self._timerField then
            self._timerField:dispose()
            self._timerField = nil
        end
        self._curRefreshTime:setString('00:00:00')
        self._totalRefrshTime:setString("00:00:00")
    end

    local function timer_callback(time)
        local cur_num = uq.cache.role:getResNum(self._type)
        local total_time = time + (total_num - cur_num - 1) * self._xmlInfo.time
        if time <= 0 then
            time = self._xmlInfo.time
        end
        self._totalRefrshTime:setString(uq.getTime(total_time, uq.config.constant.TIME_TYPE.HHMMSS))
    end

    if left_time <= 0 then
        timer_end()
        return
    end
    if self._timerField then
        self._timerField:setTime(left_time)
    else
        self._timerField = uq.ui.TimerField:create(self._curRefreshTime, left_time, timer_end, nil, timer_callback)
    end
end

function BuyMilitoryOrder:onExit()
    services:removeEventListenersByTag(self._eventBuy)
    services:removeEventListenersByTag(self._eventTag)
    network:removeEventListenerByTag('on_add_update_time' .. tostring(self))

    if self._timerField then
        self._timerField:dispose()
        self._timerField = nil
    end

    BuyMilitoryOrder.super.onExit(self)
end

function BuyMilitoryOrder:refreshPage()
    self._leftBuyNum = self._limitNum - uq.cache.role:getBuyMilitoryOrderNum()

    local num = uq.cache.role:getResNum(self._type)
    local max_num = math.floor(StaticData['types'].MaxLimit[1].Type[3].value)
    self._txtNum:setString(string.format('%d/%d', num, max_num))
    self._txtLeftNum:setString(string.format('%d/%d', self._leftBuyNum, self._limitNum))
    self._btnBuy:setEnabled(self._leftBuyNum > 0)
    self._nodeGold:setVisible(self._leftBuyNum > 0)
    local cost_str = self._configXml[uq.cache.role:getBuyMilitoryOrderNum() + 1] and self._configXml[uq.cache.role:getBuyMilitoryOrderNum() + 1].cost or self._configXml[#self._configXml].cost
    self._costArray = string.split(cost_str, ';')

    self._txtGold:setString(self._costArray[2])

    if self._leftBuyNum == 0 then
        self._txtLeftNum:setTextColor(cc.c3b(243, 11, 11))
        uq.ShaderEffect:addGrayButton(self._btnBuy)
    else
        self._txtLeftNum:setTextColor(cc.c3b(55, 244, 19))
    end

    if num >= max_num then
        self._btnBuy:setEnabled(false)
        uq.ShaderEffect:addGrayButton(self._btnBuy)
        self._nodeGold:setVisible(false)
    end
    local xml = StaticData.getCostInfo(self._type)
    if xml and next(xml) ~= nil then
        self._txtDec:setString(xml.desc)
        self._txtName:setString(xml.name)
        self._txtTips:setString(string.format(StaticData['local_text']['resource.refresh.time.tip'], xml.name, math.floor(self._xmlInfo.time / 60)))
        self._curRefreshTimeTitle:setString(string.format(StaticData['local_text']['next.resource.refresh'], xml.name))
        self._totalRefreshTimeTitle:setString(string.format(StaticData['local_text']['total.resource.refresh'], xml.name))
    end
end


function BuyMilitoryOrder:onBtnBuy(event)
    if event.name ~= "ended" then
        return
    end

    local militory_num = StaticData['types'].GoldPay[1].Type[1].value
    local num = uq.cache.role:getResNum(uq.config.constant.COST_RES_TYPE.MILITORY_ORDER)
    local max_num = math.floor(StaticData['types'].MaxLimit[1].Type[3].value)
    --当前数量加上购买数量大于上限，无法购买
    if num + militory_num > max_num then
        uq.fadeInfo(StaticData['local_text']['label.common.buy.limit'])
        return
    end

    local function confirm()
        if not uq.cache.role:checkRes(tonumber(self._costArray[1]), tonumber(self._costArray[2])) then
            uq.fadeInfo(StaticData['local_text']['label.common.not.enough.gold'])
            return
        end
        network:sendPacket(Protocol.C_2_S_BUY_MILITY_ORDERS)
    end
    local str = string.format(StaticData['local_text']['label.common.buy'], '<img img/common/ui/03_0003.png>', tonumber(self._costArray[2]), '<img img/common/ui/03_0004.png>', militory_num)
    local data = {
        content = str,
        confirm_callback = confirm
    }
    uq.addConfirmBox(data)
end

function BuyMilitoryOrder:onClose(event)
    if event.name ~= "ended" then
        return
    end
    self:disposeSelf()
end

return BuyMilitoryOrder