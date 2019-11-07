local AncientCityBefore = class("AncientCityBefore", require('app.base.PopupBase'))

AncientCityBefore.RESOURCE_FILENAME = "ancient_city/AncientCityBefore.csb"
AncientCityBefore.RESOURCE_BINDING = {
    ["Image_6"]          = {["varname"] = "_imgBg"},
    ["Panel_1"]          = {["varname"] = "_pnlClick"},
    ["Image_4_0"]        = {["varname"] = "_imgTitle1"},
    ["Image_4"]          = {["varname"] = "_imgTitle2"},
    ["Sprite_2"]         = {["varname"] = "_sprTitle"},
    ["Sprite_1"]         = {["varname"] = "_sprBgDown"},
    ["action_node"]      = {["varname"] = "_nodeAction"},
    ["Node_5"]           = {["varname"] = "_nodeTitle"},
}

function AncientCityBefore:ctor(name, params)
    AncientCityBefore.super.ctor(self, name, params)
    self._type = params.type or 1
    self._msgType = params.msg_type
    self._talkType = params.talk_type
    self:initLayer()
end
function AncientCityBefore:initLayer()
    self:centerView()
    self:setLayerColor(0.7)
    self:parseView()
    self._sprTitle:setTexture("img/ancient_city/s04_00162-" .. self._type .. ".png")
    self._sprBgDown:setTexture("img/ancient_city/s03_000588-" .. self._type .. ".png")
    self._imgBg:loadTexture("img/ancient_city/s01_00049-" .. self._type .. ".png")
    self._imgTitle1:loadTexture("img/ancient_city/s03_000587-" .. self._type .. ".png")
    self._imgTitle2:loadTexture("img/ancient_city/s03_000587-" .. self._type .. ".png")
    self:openAction()
end

function AncientCityBefore:openAction()
    self._sprTitle:setScaleX(0)
    self._nodeTitle:setScaleX(0)
    self._imgBg:setVisible(false)
    self._sprBgDown:setVisible(false)
    local time_frame = 1 / 24
    uq:addEffectByNode(self._nodeAction, 900057, 1, true)
    uq.delayAction(self._nodeAction, time_frame * 3, function ()
        uq:addEffectByNode(self._nodeAction, 900050, 2, true, cc.p(0, -10), nil, 2)
    end)
    self._nodeTitle:runAction(cc.Sequence:create(cc.DelayTime:create(time_frame), cc.ScaleTo:create(time_frame * 2, 1)))
    uq.delayAction(self._imgBg, time_frame * 3, function ()
        self._sprTitle:setScaleX(1)
        self._imgBg:setVisible(true)
        self._sprBgDown:setVisible(true)
    end)
    uq.delayAction(self._nodeAction, 2.3, handler(self,self.jumpLayer))
end

function AncientCityBefore:jumpLayer()
    if self._type == 2 then
        uq.ModuleManager:getInstance():show(uq.ModuleManager.FIND_SECRET_ROOM)
    elseif self._type == 1 then
        uq.ModuleManager:getInstance():show(uq.ModuleManager.GENERAL_SHOP_TALK, {_type = self._talkType})
    else
        uq.ModuleManager:getInstance():show(uq.ModuleManager.ANCIENT_CITY_PLAYER, {msg_type = self._msgType})
    end
    self:disposeSelf()
end

return AncientCityBefore