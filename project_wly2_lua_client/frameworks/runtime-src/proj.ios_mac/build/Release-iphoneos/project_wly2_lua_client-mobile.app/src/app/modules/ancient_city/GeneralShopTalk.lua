local GeneralShopTalk = class("GeneralShopTalk", require('app.base.PopupBase'))

GeneralShopTalk.RESOURCE_FILENAME = "ancient_city/AncientCityShopTalk.csb"
GeneralShopTalk.RESOURCE_BINDING = {
    ["Image_3"]             = {["varname"] = "_imgName"},
    ["Image_19"]            = {["varname"] = "_imgIcon"},
    ["label_des"]           = {["varname"] = "_desLabel"},
    ["Panel_1"]             = {["varname"] = "_panelPress"},
}

function GeneralShopTalk:ctor(name, args)
    args._isStopAction = true
    GeneralShopTalk.super.ctor(self, name, args)
    self._type = args._type
end

function GeneralShopTalk:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self:initUi()
end

function GeneralShopTalk:initUi()
    self._panelPress:setTouchEnabled(true)
    self._panelPress:addClickEventListenerWithSound(function(sender)
        self._imgIcon:runAction(cc.MoveTo:create(0.5, cc.p(-1230, 0)))
        self._panelPress:runAction(cc.Sequence:create(cc.FadeOut:create(0.5), cc.CallFunc:create(function()
            uq.ModuleManager:getInstance():show(uq.ModuleManager.GENRAL_SHOP_MODULE, {_sub_index = self._type, _is_move = true})
            self:disposeSelf()
        end)))
    end)
    self._panelPress:setOpacity(0)
    local info = StaticData['ancient_trade'].Info[1]
    if self._type == uq.config.constant.GENERAL_SHOP.JADE_SHOP then
        self._imgName:loadTexture("img/ancient_city/s03_000592_0.png")
        self._imgIcon:loadTexture("img/common/general_body/"..info.TraderImg)
        self._desLabel:setString(info.TraderTalk)
    else
        self._imgName:loadTexture("img/ancient_city/s03_000592_1.png")
        self._imgIcon:loadTexture("img/common/general_body/"..info.CoinTraderImg)
        self._desLabel:setString(info.CoinTraderTalk)
    end
    self._panelPress:runAction(cc.FadeIn:create(0.3))
    self._imgIcon:runAction(cc.MoveTo:create(0.5, cc.p(-98, 0)))
end

function GeneralShopTalk:dispose()
    GeneralShopTalk.super.dispose(self)
    display.removeUnusedSpriteFrames()
end
return GeneralShopTalk