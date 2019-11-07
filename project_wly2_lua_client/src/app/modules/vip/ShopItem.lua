local ShopItem = class("ShopItem", function()
    return ccui.Layout:create()
end)

function ShopItem:ctor(args)
    self._view = nil
    self._info = args and args.info
    self:init()
end

function ShopItem:init()
    if not self._view then
        local node = cc.CSLoader:createNode("Vip/ShopItem.csb")
        self._view = node:getChildByName("Panel_1"):clone()
    end
    self:addChild(self._view)
    self:setAnchorPoint(cc.p(0.5,0.5))
    self:setContentSize(self._view:getContentSize())
    self._view:setPosition(cc.p(0,0))
    self._imgMark = self._view:getChildByName("img_cur");
    self._imgIcon = self._view:getChildByName("img_icon");
    self._imgCost = self._view:getChildByName("img_cost");
    self._rewardLabel = self._view:getChildByName("lbl_reward");
    self._moneyLabel = self._view:getChildByName("lbl_money");
    self._desLabel = self._view:getChildByName("lbl_des");
    self:initInfo()
end

function ShopItem:setInfo(info)
    self._info = info
    self:initInfo()
end

function ShopItem:initInfo()
    if not self._info then
        return
    end
    if self._info.recommend == 1 then
        self._imgMark:setVisible(true)
        self._desLabel:setVisible(true)
        self._desLabel:setString(StaticData['local_text']['vip.libao.des2'])
    else
        self._imgMark:setVisible(false)
        self._desLabel:setVisible(false)
    end
    self._imgIcon:loadTexture("img/vip/"..self._info.icon)
    self._rewardLabel:setString(self._info.gold)
    self._moneyLabel:setString("")
    if self._info.coin then
        self._moneyLabel:setString(StaticData['local_text']['label.common.dollar']..self._info.coin)
    end
end

function ShopItem:getInfo()
    return self._info
end

function ShopItem:onExit()

end

return ShopItem