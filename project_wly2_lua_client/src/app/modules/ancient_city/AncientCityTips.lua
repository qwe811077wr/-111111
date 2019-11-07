local AncientCityTips = class("AncientCityTips", require('app.base.PopupBase'))

AncientCityTips.RESOURCE_FILENAME = "ancient_city/AncientCityTips.csb"
AncientCityTips.RESOURCE_BINDING = {
    ["escape_node"]      = {["varname"] = "_nodeEscape"},
    ["back_node"]        = {["varname"] = "_nodeBack"},
    ["dec_1_txt"]        = {["varname"] = "_txtDec1"},
    ["dec_2_txt"]        = {["varname"] = "_txtDec2"},
    ["dec_3_txt"]        = {["varname"] = "_txtDec3"},
    ["ok_btn"]           = {["varname"] = "_btnOk",["events"] = {{["event"] = "touch",["method"] = "onBtnOk"}}},
    ["close_btn"]        = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onBtnClose"}}},
}

function AncientCityTips:ctor(name, params)
    AncientCityTips.super.ctor(self, name, params)
    self._data = params or {}
    self._func = params.func
    self:initLayer()
end

function AncientCityTips:onCreate()
    AncientCityTips.super.onCreate(self)
    self:centerView()
    self:setLayerColor()
    self:parseView()
end

function AncientCityTips:initLayer()
    self._txtDec1:setHTMLText(StaticData["local_text"]["ancient.escape.dec1"])
    self._txtDec3:setHTMLText(StaticData["local_text"]["ancient.back.dec1"])
    self._nodeEscape:setVisible(self._data.type ~= 1)
    self._nodeBack:setVisible(self._data.type == 1)
    self._richText = uq.RichText:create()
    self._richText:setAnchorPoint(cc.p(0, 1))
    self._richText:setDefaultFont("res/font/hwkt.ttf")
    self._richText:setFontSize(22)
    self._richText:setContentSize(cc.size(520, 0))
    self._richText:setMultiLineMode(true)
    self._richText:setTextColor(uq.parseColor('#ffffff'))
    self._txtDec2:addChild(self._richText)
    self._richText:formatText()
    self._richText:setText(string.format(StaticData["local_text"]["ancient.escape.dec2"], "<img img/common/ui/03_0004.png>"))
end

function AncientCityTips:onBtnOk(event)
    if event.name ~= "ended" then
        return
    end
    if self._func then
        self._func()
    end
    self:disposeSelf()
end

function AncientCityTips:onBtnClose(event)
    if event.name ~= "ended" then
        return
    end
    self:disposeSelf()
end

return AncientCityTips