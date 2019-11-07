local AncientCityRule = class("AncientCityRule", require('app.base.PopupBase'))
local AncientCityRuleItem = require("app.modules.ancient_city.AncientCityRuleItem")

AncientCityRule.RESOURCE_FILENAME = "ancient_city/AncientCityRule.csb"
AncientCityRule.RESOURCE_BINDING = {
    ["label__1_0"]              = {["varname"] = "_lblTitle"},
    ["ScrollView_1"]            = {["varname"] = "_scrollView"},
    ["Button_1"]                = {["varname"] = "_btnExit", ["events"] = {{["event"] = "touch",["method"] = "_onTouchExit",["sound_id"] = 0}}},
}

function AncientCityRule:ctor(name, args)
    AncientCityRule.super.ctor(self, name, args)
    self._curInfo = args.info
end

function AncientCityRule:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self:initUi()
end

function AncientCityRule:initUi()
    if not self._curInfo then
        return
    end
    self._scrollView:setScrollViewSpriteFrame("img/common/ui/j01_000015.png")
    self._scrollView:setScrollBarOpacity(255)
    self._lblTitle:setString(self._curInfo.title)
    local text_array = self._curInfo.Text
    self._scrollView:removeAllChildren()
    local size = self._scrollView:getContentSize()
    local item_size = self._scrollView:getContentSize()
    local item_posY = 0
    for k, txt in ipairs(text_array) do
        local lbl_des = ccui.Text:create()
        lbl_des:setFontSize(22)
        lbl_des:setFontName("font/hwkt.ttf")
        lbl_des:setTextColor(uq.parseColor("#aadce3"))
        lbl_des:setAnchorPoint(cc.p(0, 1))
        lbl_des:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
        lbl_des:setTextAreaSize(cc.size(570,0))
        lbl_des:getVirtualRenderer():setLineHeight(30)
        lbl_des:setString(txt.description)
        item_posY = 45 + lbl_des:getContentSize().height + item_posY
    end

    local item_size = self._scrollView:getContentSize()
    if item_posY < item_size.height then
        item_posY = item_size.height
    end
    self._scrollView:setInnerContainerSize(cc.size(item_size.width, item_posY))
    for _, txt in ipairs(text_array) do
        local euqip_item = AncientCityRuleItem:create({info = txt})
        euqip_item:setPosition(cc.p(euqip_item:getContentSize().width * 0.5, item_posY - 45))
        self._scrollView:addChild(euqip_item)
        item_posY = item_posY - 45 - euqip_item:getHeight()
    end
end

function AncientCityRule:dispose()
    AncientCityRule.super.dispose(self)
    display.removeUnusedSpriteFrames()
end
return AncientCityRule