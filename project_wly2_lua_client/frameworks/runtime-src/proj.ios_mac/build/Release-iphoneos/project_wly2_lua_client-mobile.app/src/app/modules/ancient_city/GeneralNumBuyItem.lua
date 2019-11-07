local GeneralNumBuyItem = class("GeneralNumBuyItem", require("app.base.PopupBase"))
local EquipItem = require("app.modules.common.EquipItem")

GeneralNumBuyItem.RESOURCE_FILENAME = "ancient_city/AncientCityItemBuy.csb"

GeneralNumBuyItem.RESOURCE_BINDING  = {
    ["button_dec"]     ={["varname"] = "_btnDec",["events"] = {{["event"] = "touch",["method"] = "onBtnDec"}}},
    ["button_add"]     ={["varname"] = "_btnAdd",["events"] = {{["event"] = "touch",["method"] = "onBtnAdd"}}},
    ["button_dec_ten"] ={["varname"] = "_btnDecTen",["events"] = {{["event"] = "touch",["method"] = "onBtnDecTen"}}},
    ["button_add_ten"] ={["varname"] = "_btnAddTen",["events"] = {{["event"] = "touch",["method"] = "onBtnAddTen"}}},
    ["Panel_item"]     ={["varname"] = "_panelItem"},
    ["label_name"]     ={["varname"] = "_nameLabel"},
    ["label_havenum"]  ={["varname"] = "_haveNumLabel"},
    ["btn_buy"]        ={["varname"] = "_btnBuy",["events"] = {{["event"] = "touch",["method"] = "_onBtnBuy"}}},
    ["Panel_1"]        ={["varname"] = "_pnlBg"},
    ["cost_txt"]       ={["varname"] = "_txtCost"},
    ["cost_img"]       ={["varname"] = "_imgCost"},
    ["dec_txt"]        ={["varname"] = "_txtDec"},
    ["close_btn"]      ={["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "_onBtnClose"}}},
}

function GeneralNumBuyItem:ctor(name, args)
    GeneralNumBuyItem.super.ctor(self, name, args)
    self._info = args.info
    self._curNum = 1
    self._totalNum = self._info.num
    self._costNum = 0
    self._oneCost = 0
end

function GeneralNumBuyItem:init()
    self:parseView()
    self:centerView()
    self:initUi()
    self:setLayerColor()
end

function GeneralNumBuyItem:_onBtnBuy(event)
    if event.name ~= "ended" then
        return
    end
    local cost_array = string.split(self._info.xml.cost, ";")
    local info = StaticData.getCostInfo(tonumber(cost_array[1]), tonumber(cost_array[3]))
    if not uq.cache.role:checkRes(tonumber(cost_array[1]), self._costNum, tonumber(cost_array[3])) then
        if tonumber(cost_array[1]) == uq.config.constant.COST_RES_TYPE.GOLDEN then
            local icon = "<img img/common/ui/" .. info.miniIcon .. ">"
            local des = string.format(StaticData['local_text']['ancient.city.sweep.gold.des'], icon)
            local function confirm()
                uq.runCmd('enter_arena')
            end
            local data = {
                content = des,
                confirm_callback = confirm
            }
            uq.addConfirmBox(data)
        else
            uq.fadeInfo(string.format(StaticData['local_text']['general.shop.cannot.buy'], info.name))
        end
        return
    end
    if self._info.type == uq.config.constant.SHOP_BUY_TYPE.ANCIENT_CITY then
        network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_STORE_BUY, {id = self._info.id, num = self._curNum})
    elseif self._info.type == uq.config.constant.SHOP_BUY_TYPE.JADE_SHOP or self._info.type == uq.config.constant.SHOP_BUY_TYPE.GOLD_SHOP then
        network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_EXCHANGE, {id = self._info.id, num = self._curNum, trade_type = self._info.type - 2})
    elseif self._info.type == uq.config.constant.SHOP_BUY_TYPE.TRIAL_SHOP then
        network:sendPacket(Protocol.C_2_S_TRIAL_TOWER_STORE_BUY, {id = self._info.id, num = self._curNum})
    elseif self._info.type == uq.config.constant.SHOP_BUY_TYPE.TRIAL_REWARD then
        network:sendPacket(Protocol.C_2_S_TRIAL_TOWER_DRAW_REWARD, {id = self._info.id, num = self._curNum})
    elseif self._info.type == uq.config.constant.SHOP_BUY_TYPE.ATHLETICS_SHOP then
        network:sendPacket(Protocol.C_2_S_ATHLETICS_EXCHANGE_ITEM, {id = self._info.id, num = self._curNum})
    elseif self._info.type == uq.config.constant.SHOP_BUY_TYPE.ATHLETICS_REWARD then
        network:sendPacket(Protocol.C_2_S_ATHLETICS_DRAW_RANK_REWARD, {id = self._info.id, num = self._curNum})
    elseif self._info.type == uq.config.constant.SHOP_BUY_TYPE.PASS_STORE then
        network:sendPacket(Protocol.C_2_S_PASSCARD_STONE_BUY, {id = self._info.id, num = self._curNum})
    elseif self._info.type == uq.config.constant.SHOP_BUY_TYPE.BUILD_OFFICER_STRENGTH then
        network:sendPacket(Protocol.C_2_S_BUY_TIRED_MATERIAL, {ident = self._info.ident, num = self._curNum})
    end
    self:disposeSelf()
end

function GeneralNumBuyItem:initUi()
    local cost_array = string.split(self._info.xml.cost,";")
    self._oneCost = math.ceil(tonumber(cost_array[2] * self._info.discount))
    local info_cost = StaticData.getCostInfo(tonumber(cost_array[1]),tonumber(cost_array[3]))
    local buy_array = string.split(self._info.xml.buy,";")
    local buy_info = StaticData.getCostInfo(tonumber(buy_array[1]),tonumber(buy_array[3]))
    self._nameLabel:setString(buy_info.name)
    self._panelItem:removeAllChildren()
    local item_array = string.split(self._info.xml.buy,";")
    local info = {}
    info.type = tonumber(item_array[1])
    info.id = tonumber(item_array[3])
    info.num = tonumber(item_array[2])
    local euqip_item = EquipItem:create({info = info})
    euqip_item:setScale(0.8)
    euqip_item:setPosition(cc.p(self._panelItem:getContentSize().width * 0.5,self._panelItem:getContentSize().height * 0.5))
    self._panelItem:addChild(euqip_item)
    local item = uq.RewardType:create(self._info.xml.cost)
    self._imgCost:loadTexture("img/common/ui/" .. item:miniIcon())
    self._txtCost:setString(tostring(self._costNum))
    local num = uq.cache.role:getResNum(info.type, info.id)
    self._haveNumLabel:setHTMLText(string.format(StaticData['local_text']['pass.have.num'], num))
    self._txtDec:setString(buy_info.desc)
    self:initEditBox()
    self:setNum(0)
end

function GeneralNumBuyItem:initEditBox()
    local size = self._pnlBg:getContentSize()
    self._editBox = ccui.EditBox:create(cc.size(size.width, size.height + 2), '')
    self._editBox:setAnchorPoint(cc.p(0.5, 0.5))
    self._editBox:setFontName("font/hwkt.ttf")
    self._editBox:setFontSize(26)
    self._editBox:setFontColor(cc.c3b(255, 255, 255))
    self._editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._editBox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self._editBox:setTextHorizontalAlignment(1)
    self._editBox:setPosition(cc.p(size.width / 2, size.height / 2 + 2))
    self._editBox:registerScriptEditBoxHandler(function(event, sender) self:editboxHandle(event, sender) end)
    self._pnlBg:addChild(self._editBox)
end

function GeneralNumBuyItem:editboxHandle(event, sender)
    if event == 'changed' or event == 'ended' or event == 'return' then
        self._curNum  = tonumber(self._editBox:getText()) or 0

        if self._curNum  < 1 then
            self._curNum  = 1
        elseif self._curNum  > self._totalNum then
            self._curNum  = self._totalNum
        end
        self._costNum = self._oneCost * self._curNum
        self._editBox:setText(tostring(self._curNum))
        self._txtCost:setString(tostring(self._costNum))
    end
end

function GeneralNumBuyItem:setNum(num)
    self._curNum  = self._curNum  + num

    if self._curNum  < 1 then
        self._curNum  = 1
    elseif self._curNum  > self._totalNum then
        self._curNum  = self._totalNum
    end
    self._costNum = self._oneCost * self._curNum
    self._editBox:setText(tostring(self._curNum))
    self._txtCost:setString(tostring(self._costNum))
end

function GeneralNumBuyItem:onBtnDec(event)
    if event.name == 'ended' then
        self:setNum(-1)
    end
end

function GeneralNumBuyItem:onBtnAdd(event)
    if event.name == 'ended' then
        self:setNum(1)
    end
end

function GeneralNumBuyItem:onBtnDecTen(event)
    if event.name == 'ended' then
        self:setNum(-10)
    end
end

function GeneralNumBuyItem:onBtnAddTen(event)
    if event.name == 'ended' then
        self:setNum(10)
    end
end

function GeneralNumBuyItem:_onBtnClose(event)
    if event.name ~= 'ended' then
        return
    end
    self:disposeSelf()
end

function GeneralNumBuyItem:dispose()
    GeneralNumBuyItem.super.dispose(self)
    display.removeUnusedSpriteFrames()
end

return GeneralNumBuyItem