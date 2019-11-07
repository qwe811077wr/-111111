local EquipItem = require("app.modules.common.EquipItem")
local GeneralShopItem = class("GeneralShopItem", function()
    return ccui.Layout:create()
end)

function GeneralShopItem:ctor(args)
    self._view = nil
    self._info = args and args.info
    self.can_buy = true
    self:init()
end

function GeneralShopItem:init()
    if not self._view then
        local node = cc.CSLoader:createNode("ancient_city/AncientCityShopItem.csb")
        self._view = node:getChildByName("Panel_1")
    end
    self._view:removeSelf()
    self:addChild(self._view)
    self:setAnchorPoint(cc.p(0.5,0.5))
    self:setContentSize(self._view:getContentSize())
    self._view:setPosition(cc.p(0,0))
    self._imgRed = self._view:getChildByName("img_red");
    self._panelZhe = self._view:getChildByName("Panel_zhe");
    self._zheLabel = self._panelZhe:getChildByName("lbl");
    self._numLabel = self._view:getChildByName("lbl_num");
    self._costIcon = self._view:getChildByName("img_cost");
    self._costLabel = self._view:getChildByName("lbl_cost");
    self._nameLabel = self._view:getChildByName("lbl_name");
    self._desLabel = self._view:getChildByName("lbl_des");
    self._panelItem = self._view:getChildByName("Panel_item");
    self._btnBuy = self._view:getChildByName("Button_1");
    self._imgOver = self._view:getChildByName("img_over");
    self._btnBuy:setTitleText(StaticData['local_text']['achieve.task.day.buy'])
    self._btnBuy:onTouch(function(event)
        if event.name ~= "ended" then
            return
        end
        if self._info.type == uq.config.constant.SHOP_BUY_TYPE.JADE_SHOP or self._info.type == uq.config.constant.SHOP_BUY_TYPE.GOLD_SHOP then
            if self._buyItemCallback and not self._buyItemCallback() then
                uq.fadeInfo(StaticData['local_text']['general.shop.not.open'])
                return
            end
        end
        if self._info.num == 1 then
            local cost_array = string.split(self._info.xml.cost, ";")
            local info = StaticData.getCostInfo(tonumber(cost_array[1]), tonumber(cost_array[3]))
            if not uq.cache.role:checkRes(tonumber(cost_array[1]), math.ceil(tonumber(cost_array[2]) * self._info.discount), tonumber(cost_array[3])) then
                uq.fadeInfo(string.format(StaticData['local_text']['general.shop.cannot.buy'], info.name))
                return
            end
            if self._info.type == uq.config.constant.SHOP_BUY_TYPE.ANCIENT_CITY then
                network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_STORE_BUY, {id = self._info.id, num = 1})
            elseif self._info.type == uq.config.constant.SHOP_BUY_TYPE.JADE_SHOP or self._info.type == uq.config.constant.SHOP_BUY_TYPE.GOLD_SHOP then
                network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_EXCHANGE, {id = self._info.id, num = 1, trade_type = self._info.type - 2})
            elseif self._info.type == uq.config.constant.SHOP_BUY_TYPE.TRIAL_SHOP then
                network:sendPacket(Protocol.C_2_S_TRIAL_TOWER_STORE_BUY, {id = self._info.id, num = 1})
            elseif self._info.type == uq.config.constant.SHOP_BUY_TYPE.TRIAL_REWARD then
                network:sendPacket(Protocol.C_2_S_TRIAL_TOWER_DRAW_REWARD, {id = self._info.id, num = 1})
            elseif self._info.type == uq.config.constant.SHOP_BUY_TYPE.ATHLETICS_SHOP then
                network:sendPacket(Protocol.C_2_S_ATHLETICS_EXCHANGE_ITEM, {id = self._info.id, num = 1})
            elseif self._info.type == uq.config.constant.SHOP_BUY_TYPE.ATHLETICS_REWARD then
                network:sendPacket(Protocol.C_2_S_ATHLETICS_DRAW_RANK_REWARD, {id = self._info.id, num = 1})
            end
        else
            uq.ModuleManager:getInstance():show(uq.ModuleManager.GENERAL_NUM_BUY_ITEM, {info = self._info})
        end
    end)
    self:initInfo()
end

function GeneralShopItem:setInfo(info)
    self._info = info
    self:initInfo()
end

function GeneralShopItem:initInfo()
    if not self._info then
        return
    end
    local limit_num = 0
    if self._info.xml.limit and self._info.xml.times then
        limit_num = math.max(self._info.xml.limit, self._info.xml.times)
    else
        limit_num = self._info.xml.limit or self._info.xml.times
    end
    self._numLabel:setString(string.format(StaticData["local_text"]["ancient.city.shop.des"], self._info.num, limit_num))
    if math.floor(self._info.discount * 10) >= 10 then
        self._panelZhe:setVisible(false)
    else
        self._panelZhe:setVisible(true)
        self._zheLabel:setString(math.floor(self._info.discount * 10) .. StaticData['local_text']['activity.discount'])
    end
    local cost_array = string.split(self._info.xml.cost,";")
    local info = StaticData.getCostInfo(tonumber(cost_array[1]),tonumber(cost_array[3]))
    local buy_array = string.split(self._info.xml.buy,";")
    local buy_info = StaticData.getCostInfo(tonumber(buy_array[1]),tonumber(buy_array[3]))
    if buy_info.qualityType then
        local tab = StaticData['types'].ItemQuality[1].Type[tonumber(buy_info.qualityType)]
        self._nameLabel:setTextColor(uq.parseColor("#" .. tab.color))
    end
    self._nameLabel:setString(buy_info.name)
    self._desLabel:setVisible(false)
    self._costLabel:setString(math.ceil(tonumber(cost_array[2] * self._info.discount)))
    if info.miniIcon then
        self._costIcon:loadTexture("img/common/ui/"..info.miniIcon)
    end
    self.can_buy = true
    if self._info.xml.condition and self._info.xml.condition ~= 0 then
        local first_pass = 0
        local data_info = uq.cache.ancient_city:getPassCityInfo()
        for k2,v2 in pairs(data_info.city) do
            if self._info.xml.condition == v2.id then
                first_pass = v2.first_pass
                break
            end
        end
        self._desLabel:setVisible(first_pass == 0)
        self._desLabel:setString(self._info.xml.content)
        self.can_buy = first_pass ~= 0
    elseif self._info.xml.layer and self._info.xml.layer ~= 0 then
        self.can_buy = uq.cache.trials_tower.trial_info.max_layer_id > self._info.xml.layer
        self._desLabel:setVisible(not self.can_buy)
        self._desLabel:setString(self._info.xml.desc)
    elseif self._info.xml.Rank and self._info.xml.Rank ~= 0 then
        local rank = uq.cache.arena:getHighestRank()
        local state = rank > 0 and rank <= self._info.xml.Rank
        self.can_buy = state
        self._desLabel:setVisible(not state)
        self._desLabel:setString(self._info.xml.desc)
    end

    self._panelItem:removeAllChildren()
    local item_array = string.split(self._info.xml.buy,";")
    local info = {}
    info.type = tonumber(item_array[1])
    info.id = tonumber(item_array[3])
    info.num = tonumber(item_array[2])
    local euqip_item = EquipItem:create({info = info})
    euqip_item:setScale(0.8)
    euqip_item:setPosition(cc.p(self._panelItem:getContentSize().width * 0.5,self._panelItem:getContentSize().height * 0.5))
    euqip_item:setTouchEnabled(true)
    euqip_item:addClickEventListener(function(sender)
        local info = sender:getEquipInfo()
        uq.showItemTips(info)
    end)
    euqip_item:setSwallowTouches(false)
    self._panelItem:addChild(euqip_item)
    self._imgOver:setVisible(self._info.num == 0)
    self._btnBuy:setVisible(self._info.num > 0 and self.can_buy)
end

function GeneralShopItem:setBuyItemCallBack(callback)
    self._buyItemCallback = callback
end

function GeneralShopItem:getInfo()
    return self._info
end

function GeneralShopItem:showAction()
    uq.intoAction(self._view)
end

return GeneralShopItem