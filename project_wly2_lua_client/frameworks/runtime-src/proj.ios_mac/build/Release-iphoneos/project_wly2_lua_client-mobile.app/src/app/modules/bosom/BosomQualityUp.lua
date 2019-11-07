local BosomQualityUp = class("BosomQualityUp", require('app.base.PopupBase'))

BosomQualityUp.RESOURCE_FILENAME = "bosom/BosomQualityUp.csb"
BosomQualityUp.RESOURCE_BINDING = {
    ["Panel_1"]                   = {["varname"] = "_pnlClick"},
    ["Image_6"]                   = {["varname"] = "_imgLeft"},
    ["Node_1"]                    = {["varname"] = "_nodeTxt"},
    ["Node_1/Text_8_0_0"]         = {["varname"] = "_txtName"},
    ["Node_1/Image_7"]            = {["varname"] = "_imgRight"},
}

function BosomQualityUp:ctor(name, params)
    BosomQualityUp.super.ctor(self, name, params)
    self._params = params or {}
end

function BosomQualityUp:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self:initAction()
    self._pnlClick:addClickEventListenerWithSound(function()
        self:disposeSelf()
        end)
    if next(self._params) ~= nil then
        local tab_old = StaticData['types']['DearType'][1]['Type'][self._params.quality_old]
        if tab_old.image then
            self._imgLeft:loadTexture("img/bosom/" .. tab_old.image)
        end
        local tab_now = StaticData['types']['DearType'][1]['Type'][self._params.quality_now]
        if tab_now.image then
            self._imgRight:loadTexture("img/bosom/" .. tab_now.image)
        end
        self._txtName:setString(self._params.name)
    end
end

function BosomQualityUp:initAction()
    self._imgLeft:setOpacity(0)
    self._imgLeft:setPosition(cc.p(0, -70))
    self._imgLeft:runAction(cc.Sequence:create(cc.FadeIn:create(0.3), cc.MoveTo:create(0.2, cc.p(-280, -70)), nil))
    self._nodeTxt:setOpacity(0)
    if self._params.auto_close then
        self._nodeTxt:runAction(cc.Sequence:create(
                cc.DelayTime:create(0.5),
                cc.FadeIn:create(0.2),
                cc.DelayTime:create(1),
                cc.CallFunc:create(function ()
                    self:disposeSelf()
                end),
            nil))
    else
        self._nodeTxt:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.FadeIn:create(0.2), nil))
    end
end

return BosomQualityUp