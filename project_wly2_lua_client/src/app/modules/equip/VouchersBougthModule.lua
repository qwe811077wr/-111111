local VouchersBougthModule = class("VouchersBougthModule", require('app.base.PopupBase'))

VouchersBougthModule.RESOURCE_FILENAME = "equip/VocherBoughtModule.csb"
VouchersBougthModule.RESOURCE_BINDING = {
    ["Button_25"]                     = {["varname"] = "_btnDel", ["events"] = {{["event"] = "touch",["method"] = "onBtnDec"}}},
    ["Button_24"]                     = {["varname"] = "_btbAdd", ["events"] = {{["event"] = "touch",["method"] = "onBtnAdd"}}},
    ["Panel_39_0"]                    = {["varname"] = "_pnlBg"},
    ["Text_73"]                       = {["varname"] = "_txtGetNum"},
    ["Text_75"]                       = {["varname"] = "_txtCostTen"},
    ["Text_74"]                       = {["varname"] = "_txtCost"},
    ["Button_2"]                      = {["varname"] = "_btnBuyTen", ["events"] = {{["event"] = "touch",["method"] = "onBoughtMore",["sound_id"] = 0}}},
    ["Button_2_0"]                    = {["varname"] = "_btnBuy", ["events"] = {{["event"] = "touch",["method"] = "onBoughtOnce",["sound_id"] = 0}}},
    ["Node_9"]                        = {["varname"] = "_nodeDiscount"},
    ["Node_10"]                       = {["varname"] = "_nodeCoin"},
    ["Image_55"]                      = {["varname"] = "_imgItem"},
    ["Image_56"]                      = {["varname"] = "_imgCoinMore"},
    ["Image_57"]                      = {["varname"] = "_imgCoin"},
    ["Text_69"]                       = {["varname"] = "_txtTips"},
    ["Image_42"]                      = {["varname"] = "_imgDiscountBg"},
    ["Text_9"]                        = {["varname"] = "_txtDiscount"},
    ["Button_1"]                      = {["varname"] = "_btnOnExit", ["events"] = {{["event"] = "touch",["method"] = "_onTouchExit",["sound_id"] = 0}}}
}

function VouchersBougthModule:ctor(name, params)
    VouchersBougthModule.super.ctor(self, name, params)
    self._data = params.data
    self._curNum = params.data.num or 1
    self._totalNum = params.data.total_num or 99
    self._itemStr = params.data.item_info and string.split(params.data.item_info, ';') or nil
    self._coinStr = params.data.coin_info and string.split(params.data.coin_info, ';') or nil
    self._discountStr = params.data.discount_info and string.split(params.data.discount_info, ';') or nil
    self._discountNum = params.data.discount_num or 10
end

function VouchersBougthModule:init()
    self:centerView()
    self:parseView()
    self:setLayerColor()
    self:initEditBox()
    self:initPage()
    services:addEventListener(services.EVENT_NAMES.ON_CONSUME_RES_CHANGE .. tonumber(self._coinStr[1]), handler(self, self.updateCoinState), '_onResRefresh' .. tostring(self))
end

function VouchersBougthModule:initPage()
    local showMore = self._discountStr ~= nil
    self._nodeDiscount:setVisible(showMore)
    local pos_x = self._nodeCoin:getPositionX()
    if not showMore then
        self._nodeCoin:setPositionX(pos_x - 120)
    end

    if not self._itemStr or not self._coinStr then
        return
    end

    self._itemInfo = StaticData.getCostInfo(tonumber(self._itemStr[1]), tonumber(self._itemStr[3]))
    self._imgItem:loadTexture("img/common/ui/" .. self._itemInfo.miniIcon)

    self._coinInfo = StaticData.getCostInfo(tonumber(self._coinStr[1]), tonumber(self._coinStr[3]))
    self._imgCoin:loadTexture("img/common/ui/" .. self._coinInfo.miniIcon)
    self._imgCoinMore:loadTexture("img/common/ui/" .. self._coinInfo.miniIcon)

    self._imgDiscountBg:setVisible(self._discountStr ~= nil)
    self._txtDiscount:setVisible(self._discountStr ~= nil)
    if self._discountStr then
        local discount = tonumber(self._discountStr[2]) / self._discountNum / tonumber(self._coinStr[2]) * 10
        self._txtDiscount:setString(discount .. StaticData['local_text']['ancient.city.shop.des1'])
        self._btnBuyTen:setTitleText(string.format(StaticData['local_text']['pool.buy.chance'], self._discountNum))
        self._txtCostTen:setString(tonumber(self._discountStr[2]))
    end

    self._btnBuy:setTitleText(string.format(StaticData['local_text']['pool.buy.chance'], self._curNum))
    self._txtGetNum:setString(self._curNum)
    self._txtCost:setString(tonumber(self._coinStr[2]) * self._curNum)
    self._txtTips:setString(string.format(StaticData['local_text']['res.buy.other.res'], self._coinInfo.name, self._itemInfo.name))

    self:updateCoinState()
end

function VouchersBougthModule:initEditBox()
    local size = self._pnlBg:getContentSize()
    self._editBox = ccui.EditBox:create(cc.size(size.width - 60, size.height + 2), '')
    self._editBox:setAnchorPoint(cc.p(0.5, 0.5))
    self._editBox:setFontName("font/hwkt.ttf")
    self._editBox:setFontSize(26)
    self._editBox:setFontColor(cc.c3b(255, 255, 255))
    self._editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._editBox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self._editBox:setTextHorizontalAlignment(1)
    self._editBox:setPosition(cc.p(size.width / 2, size.height / 2 + 2))
    self._editBox:setText(tostring(self._curNum))
    self._editBox:registerScriptEditBoxHandler(function(event, sender) self:editboxHandle(event, sender) end)
    self._pnlBg:addChild(self._editBox)
end

function VouchersBougthModule:editboxHandle(event, sender)
    if event == 'ended' or event == 'return' then
        self._curNum  = tonumber(self._editBox:getText()) or 0
        self:setNum()
    end
end

function VouchersBougthModule:updateCoinState()
    self._arrState = {}
    local coin_state = uq.cache.role:checkRes(tonumber(self._coinStr[1]), tonumber(self._coinStr[2]) * self._curNum, tonumber(self._coinStr[3]))
    table.insert(self._arrState, coin_state)
    local color = coin_state and "#ffffff" or "#f10000"
    self._txtCost:setTextColor(uq.parseColor(color))

    if not self._discountStr then
        return
    end
    local discount_coin_state = uq.cache.role:checkRes(tonumber(self._discountStr[1]), tonumber(self._discountStr[2]), tonumber(self._discountStr[3]))
    table.insert(self._arrState, discount_coin_state)
    color = discount_coin_state and "#ffffff" or "#f10000"
    self._txtCostTen:setTextColor(uq.parseColor(color))
end

function VouchersBougthModule:setNum()
    if self._curNum  < 1 then
        self._curNum  = 1
    elseif self._curNum  > self._totalNum then
        self._curNum  = self._totalNum
    end
    self._editBox:setText(tostring(self._curNum))
    self._txtGetNum:setString(tostring(self._curNum))
    self._txtCost:setString(tonumber(self._coinStr[2]) * self._curNum)
    self._btnBuy:setTitleText(string.format(StaticData['local_text']['pool.buy.chance'], self._curNum))
    self:updateCoinState()
end

function VouchersBougthModule:onBtnDec(event)
    if event.name ~= 'ended' then
        return
    end
    self._curNum  = self._curNum - 1
    self:setNum()
end

function VouchersBougthModule:onBtnAdd(event)
    if event.name ~= 'ended' then
        return
    end
    self._curNum  = self._curNum + 1
    self:setNum()
end

function VouchersBougthModule:onBoughtOnce(event)
    if event.name ~= "ended" then
        return
    end
    self:onBought(0)
    self:disposeSelf()
end

function VouchersBougthModule:onBought(tag)
    if not self._arrState[tag + 1] then
        local data = {
            content = string.format(StaticData['local_text']['res.not.enough.to.buy'], self._coinInfo.name),
            confirm_callback = function()
                uq.jumpToModule(uq.config.constant.MODULE_ID.ADD_GOLDEN)
            end
        }
        uq.ModuleManager:getInstance():show(uq.ModuleManager.EQUIP_BOUGHT_TIPS, {data = data})
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    local num = tag == 0 and self._curNum or self._discountNum
    network:sendPacket(Protocol.C_2_S_BUY_APPOINT_TIMES, {id = self._itemInfo.ident, buy_num = num, is_ten = tag})
end

function VouchersBougthModule:onBoughtMore(event)
    if event.name ~= "ended" then
        return
    end
    self:onBought(1)
end

function VouchersBougthModule:dispose()
    services:removeEventListenersByTag('_onResRefresh' .. tostring(self))
    VouchersBougthModule.super.dispose(self)
end

return VouchersBougthModule