local DecreeMain = class("DecreeMain", require('app.base.PopupBase'))

DecreeMain.RESOURCE_FILENAME = "decree/DecreeMain.csb"
DecreeMain.RESOURCE_BINDING = {
    ["ScrollView_1"]                           = {["varname"] = "_scrollView"},
    ["cion_txt"]                               = {["varname"] = "_txtCion"},
    ["close_btn"]                              = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onClose"}}},
    ["Node_2"]                                 = {["varname"] = "_nodeReward"},
    ["dec_txt"]                                = {["varname"] = "_txtDec"},
    ["Panel_1"]                                = {["varname"] = "_pnlAction"},
    ["rule_btn"]                               = {["varname"] = "_btnRule",["events"] = {{["event"] = "touch",["method"] = "onRule"}}},
}

DecreeMain.DECREE_FONT = {
    [1] = "decree_2.fnt",
    [2] = "decree_3.fnt",
    [5] = "decree_4.fnt",
    [10] = "decree_1.fnt",
}

DecreeMain.ITEMS_TYPE = {
    REWARD = 1,
    MONEY = 2,
    FOOD = 3,
    TECH_POINT = 4,
    BLACK = 5,
    VIOLET = 6,
    GESTE = 7,
    IRON = 8,
}
DecreeMain.DECREE_TYPE = {
    [1] = "PNG_TWO",
    [2] = "PNG_THREE",
    [5] = "PNG_FOUR",
    [10] = "PNG_ONE",
}
DecreeMain.PNG_ONE = {
    "s04_00175.png",--恭喜获得
    "s04_00182.png",--银两
    "s04_00183.png",--粮食
    "s04_00187.png",--科技点
    "s04_00191.png",--黑色龙玉
    "s04_00195.png",--紫色龙玉
    "s04_00199.png",--战功
    "s04_00248.png",--铁矿
}
DecreeMain.PNG_TWO = {
    "s04_00172.png",
    "s04_00176.png",
    "s04_00177.png",
    "s04_00184.png",
    "s04_00188.png",
    "s04_00192.png",
    "s04_00196.png",
    "s04_00245.png",
}
DecreeMain.PNG_THREE = {
    "s04_00173.png",
    "s04_00178.png",
    "s04_00179.png",
    "s04_00185.png",
    "s04_00189.png",
    "s04_00193.png",
    "s04_00197.png",
    "s04_00244.png",
}
DecreeMain.PNG_FOUR = {
    "s04_00174.png",
    "s04_00180.png",
    "s04_00181.png",
    "s04_00186.png",
    "s04_00190.png",
    "s04_00194.png",
    "s04_00198.png",
    "s04_00246.png",
}

function DecreeMain:ctor(name, params)
    DecreeMain.super.ctor(self, name, params)
    self:centerView()
    self:parseView()
    self:setLayerColor(0.4)
    self._xml = StaticData['government'].Guanyin or {}
    self._xmlList = StaticData['government'].Government or {}
    self._maxNum = StaticData['government'].Guanyin[1].limit or 24
    self:initLayer()
    self._onLoadDecree = services.EVENT_NAMES.ON_CONSUME_RES_CHANGE .. uq.config.constant.COST_RES_TYPE.RT_DECREE .. tostring(self)
    self._onDecree = "_onDecree" .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_CONSUME_RES_CHANGE .. uq.config.constant.COST_RES_TYPE.RT_DECREE, handler(self, self.refreshCion), self._onLoadDecree)
    network:addEventListener(Protocol.S_2_C_DECREE, handler(self, self._onDecreeShow),self._onDecree)
    self:refreshCion()
end

function DecreeMain:initLayer()
    self._scrollView:setScrollBarEnabled(false)
    if not self._xmlList or next(self._xmlList) == nil then
        return
    end
    self._scrollView:removeAllChildren()
    for i, v in ipairs(self._xmlList) do
        local items = uq.createPanelOnly("decree.DecreeBoxs")
        self._scrollView:addChild(items)
        items:setPosition(cc.p((i - 0.5) * 195, 260))
        items:setData(v)
    end
    self._scrollView:setInnerContainerSize(cc.size(#self._xmlList * 196, 520))
end

function DecreeMain:refreshCion()
    self._txtCion:setString(uq.cache.decree:getNumDecree() .. "/" .. self._maxNum)
end

function DecreeMain:onClose(event)
    if event.name ~= "ended" then
        return
    end
    self:disposeSelf()
end

function DecreeMain:dispose()
    network:removeEventListenerByTag(self._onDecree)
    services:removeEventListenersByTag(self._onLoadDecree)
    DecreeMain.super.dispose(self)
end

function DecreeMain:dealReward(id, data)
    local all_str ={}
    local reward = uq.cache.decree:getDecreeReWard(id)
    for i = 1, #data do
        for _, v in ipairs(reward) do
            local xml_data = StaticData.getCostInfo(v.type, v.id)
            if xml_data and xml_data.name then
                local rate = data[i] or 1
                local decree_type = self.DECREE_TYPE[rate] or {}
                local idx = self:getItemsIdx(v.type, v.id)
                table.insert(all_str, {txt = v.num .. "*" .. rate, font = self.DECREE_FONT[rate], png = self:getNamePng(1, decree_type), icon = self:getNamePng(idx, decree_type)})
            end
        end
    end
    for i, v in ipairs(all_str) do
        self:showOneReward(v, i)
    end
end

function DecreeMain:getNamePng(idx, rate_type)
    local tab = self[rate_type] or {}
    if tab and tab[idx] then
        return "img/decree/" .. tab[idx]
    end
    return "img/decree/" .. self.PNG_ONE[1]
end

function DecreeMain:getItemsIdx(items_type, id)
    if items_type == uq.config.constant.COST_RES_TYPE.MONEY then
        return DecreeMain.ITEMS_TYPE.MONEY
    elseif items_type == uq.config.constant.COST_RES_TYPE.FOOD then
        return DecreeMain.ITEMS_TYPE.FOOD
    elseif items_type == uq.config.constant.COST_RES_TYPE.TECH_POINT then
        return DecreeMain.ITEMS_TYPE.TECH_POINT
    elseif items_type == uq.config.constant.COST_RES_TYPE.IRON_MINE then
        return DecreeMain.ITEMS_TYPE.IRON
    elseif items_type == uq.config.constant.COST_RES_TYPE.MATERIAL then
        if id == 1 then
            return DecreeMain.ITEMS_TYPE.VIOLET
        end
        return DecreeMain.ITEMS_TYPE.BLACK
    end
    return DecreeMain.ITEMS_TYPE.GESTE
end

function DecreeMain:showOneReward(data, idx)
    local pnl = self._pnlAction:clone()
    self._nodeReward:addChild(pnl)
    pnl:setVisible(false)
    pnl:setScale(0)
    local d1 = cc.DelayTime:create(0.7 + idx * 0.15)
    local f1 = cc.CallFunc:create(function ()
                pnl:setVisible(true)
            end)
    local s1 = cc.ScaleTo:create(0.2, 1.2)
    local s2 = cc.ScaleTo:create(0.1, 1)
    local seq = cc.Sequence:create(s1, s2)
    local d2 = cc.DelayTime:create(0.1)
    local m2 = cc.MoveBy:create(0.8, cc.p(0, 150))
    local fd1 = cc.FadeIn:create(0.2)
    local spwn1 = cc.Spawn:create(fd1, m2)
    local f2 = cc.CallFunc:create(function ()
                pnl:removeFromParent()
            end)
    pnl:runAction(cc.Sequence:create(d1, f1, seq, d2, spwn1, f2))
    pnl:getChildByName("Image_10"):loadTexture(data.icon)
    pnl:getChildByName("Image_9"):loadTexture(data.png)
    pnl:getChildByName("txt_font"):setString(data.txt)
    pnl:getChildByName("txt_font"):setFntFile("font/" .. data.font)
end

function DecreeMain:_onDecreeShow(msg)
    local data = msg.data
    if not data.items or next(data.items) == 0 then
        return
    end
    local tab_rate = {}
    for i, v in ipairs(data.items) do
        if v.builds and v.builds[1] and v.builds[1].rate then
            table.insert(tab_rate, v.builds[1].rate)
        end
    end
    if tab_rate and next(tab_rate) ~= nil then
        self:dealReward(data.id, tab_rate)
    end
end

function DecreeMain:onRule(event)
    if event.name ~= "ended" then
        return
    end
    local info = StaticData['rule'][uq.config.constant.MODULE_RULE_ID.DECREE]
    if not info then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ANCIENT_CITY_RULE, {info = info})
end

return DecreeMain