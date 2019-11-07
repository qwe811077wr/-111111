local PassCheckBuyLevel = class("PassCheckBuyLevel", require('app.base.PopupBase'))

PassCheckBuyLevel.RESOURCE_FILENAME = "pass_check/PassCheckBuyLevel.csb"
PassCheckBuyLevel.RESOURCE_BINDING = {
    ["Image_select"]        = {["varname"] = "_imgSelect"},
    ["up_lv_txt"]           = {["varname"] = "_txtUpgradeLevel"},
    ["Image_10_1"]          = {["varname"] = "_imgDiscount"},
    ["coin_txt"]            = {["varname"] = "_txtPrice"},
    ["new_lv_txt"]          = {["varname"] = "_txtLv"},
    ["max_lv_txt"]          = {["varname"] = "_txtMaxLv"},
    ["close_btn"]           = {["varname"] = "_btnClose"},
    ["Button_2"]            = {["varname"] = "_btn1", ["events"] = {{["event"] = "touch",["method"] = "onLevelSelect"}}},
    ["Button_3"]            = {["varname"] = "_btn2", ["events"] = {{["event"] = "touch",["method"] = "onLevelSelect"}}},
    ["Button_4"]            = {["varname"] = "_btn3", ["events"] = {{["event"] = "touch",["method"] = "onLevelSelect"}}},
    ["Button_5"]            = {["varname"] = "_btn4", ["events"] = {{["event"] = "touch",["method"] = "onLevelSelect"}}},
    ["ok_btn"]              = {["varname"] = "_btnLevelBuy", ["events"] = {{["event"] = "touch",["method"] = "onLevelBuy"}}},
}

function PassCheckBuyLevel:ctor(name, params)
    PassCheckBuyLevel.super.ctor(self, name, params)

    self:centerView()
    self:setLayerColor(0.4)
    self:parseView()

    self._xmlData = StaticData['pass']['BuyLevel'] or {}
    self._levelCostData = StaticData['pass']['Pass'] or {}
    self._specOver = StaticData['pass']['SpecOver'] or {}
    self._expCost = self._specOver[1].expCost or 0.01
    self._level = uq.cache.pass_check._passCardInfo.level
    self._exp = uq.cache.pass_check._passCardInfo.exp
end

function PassCheckBuyLevel:init()
    for i = 1, 4 do
        self:initButton(self["_btn" .. i], self._xmlData[i])
    end
    self._index = 1
    self._curBtn = self._btn1
    self:refreshAllBtn()
    self:refreshBtn()
    self._btnClose:addClickEventListener(function ()
        self:disposeSelf()
    end)
end

function PassCheckBuyLevel:onCreate()
    PassCheckBuyLevel.super.onCreate(self)

    self._eventTag = services.EVENT_NAMES.ON_REFRESH_PASS_CHECK_INFO .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_REFRESH_PASS_CHECK_INFO, handler(self, self.onRefreshAll), self._eventTag)
end

function PassCheckBuyLevel:initButton(btn, info)
    btn.data = info
    btn.can_buy = true

    local discount = btn:getChildByName("Image_10")
    if not discount then
        return
    end
    discount:getChildByName("Text_10"):setString(info.discount * 10)
end

function PassCheckBuyLevel:refreshAllBtn()
    for i = 1, 4 do
        local ShaderEffect = uq.ShaderEffect
        local sprite = self["_btn" .. i]:getChildByName("Sprite_1")
        local not_shader = self._level + self._xmlData[self._xmlData[i].ident]['nums'] <= #self._levelCostData
        self["_btn" .. i].can_buy = not_shader
        if not not_shader then
            ShaderEffect:addGrayNode(sprite)
        else
            ShaderEffect:removeGrayNode(sprite)
        end
    end
end

function PassCheckBuyLevel:onLevelSelect(event)
    if event.name ~= "ended" then
        return
    end
    if not event.target.can_buy then
        uq.fadeInfo(string.format(StaticData['local_text']['pass.level.up'], #self._levelCostData - self._level))
        return
    end
    self._index = event.target.data.ident
    self._curBtn = event.target
    self:refreshBtn()
end

function PassCheckBuyLevel:onRefreshAll()
    self._level = uq.cache.pass_check._passCardInfo.level
    if self._level >= #self._levelCostData then
        self:disposeSelf()
        return
    end
    self._exp = uq.cache.pass_check._passCardInfo.exp
    self._index = self._xmlData[1].ident
    self._curBtn = self._btn1
    self:refreshAllBtn()
    self:refreshBtn()
end

function PassCheckBuyLevel:refreshBtn()
    local cur_data = self._xmlData[self._index]
    self._txtUpgradeLevel:setString(string.format(StaticData['local_text']['label.level'], cur_data['nums']))
    self._txtLv:setString(tostring(self._level))
    self._txtMaxLv:setString("/" .. #self._levelCostData)
    self._imgDiscount:setVisible(true)
    self._imgDiscount:getChildByName("Text_10"):setString(cur_data.discount * 10)
    if cur_data.discount == 1 then
        self._imgDiscount:setVisible(false)
    end

    local cost = self:getAllCost(self._xmlData[self._index]['nums'])
    self._txtPrice:setString(tostring(cost))
    self._totalCost = cost

    local x, y = self["_btn" .. self._index]:getPosition()
    self._imgSelect:setPosition(cc.p(x, y))
end

function PassCheckBuyLevel:getAllCost(add_lv)
    local add_lv = add_lv or 0
    local all_exp = -self._exp
    local end_lv = self._level + add_lv - 1
    for i = self._level, end_lv do
        if not self._levelCostData[i] or not self._levelCostData[i]['exp'] then
            break
        end
        all_exp = all_exp + self._levelCostData[i]['exp']
    end
    return math.ceil(math.max(all_exp, 0) * self._expCost * self._xmlData[self._index].discount)
end

function PassCheckBuyLevel:onLevelBuy(event)
    if event.name ~= "ended" then
        return
    end
    if not self._curBtn.can_buy then
        return
    end
    if not uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN, math.ceil(self._totalCost), 0) then
        uq.fadeInfo(StaticData['local_text']['label.common.not.enough.gold'])
        return
    end
    network:sendPacket(Protocol.C_2_S_PASSCARD_BUY_LEVEL, {id = self._index})
end

function PassCheckBuyLevel:onExit()
    services:removeEventListenersByTag(self._eventTag)
    PassCheckBuyLevel.super.onExit(self)
end

return PassCheckBuyLevel