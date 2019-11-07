local AncientCityRuleItem = class("AncientCityRuleItem", function()
    return ccui.Layout:create()
end)

function AncientCityRuleItem:ctor(args)
    self._view = nil
    self._info = args and args.info
    self._curHeight = 0
    self:init()
end

function AncientCityRuleItem:init()
    if not self._view then
        local node = cc.CSLoader:createNode("ancient_city/AncientCityRuleItem.csb")
        self._view = node:getChildByName("Panel_1")
    end
    self._view:removeSelf()
    self:addChild(self._view)
    self:setAnchorPoint(cc.p(0.5,0.5))
    self:setContentSize(self._view:getContentSize())
    self._curHeight = self._view:getContentSize().height
    self._view:setPosition(cc.p(0,0))
    self._titleLabel = self._view:getChildByName("lbl_title");
    self._panelDes = self._view:getChildByName("Panel_des");
    self:initInfo()
end

function AncientCityRuleItem:setInfo(info)
    self._info = info
    self:initInfo()
end

function AncientCityRuleItem:initInfo()
    self._panelDes:removeAllChildren()
    self._titleLabel:setString(self._info.subTitle)
    local lbl_des = ccui.Text:create()
    lbl_des:setFontSize(22)
    lbl_des:setFontName("font/hwkt.ttf")
    lbl_des:setAnchorPoint(cc.p(0, 1))
    lbl_des:setPosition(cc.p(0, self._panelDes:getContentSize().height))
    lbl_des:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    lbl_des:setTextAreaSize(cc.size(self._panelDes:getContentSize().width,0))
    lbl_des:getVirtualRenderer():setLineHeight(30)
    lbl_des:setString(self._info.description)
    self._panelDes:addChild(lbl_des)
    self._curHeight = lbl_des:getContentSize().height
end

function AncientCityRuleItem:getHeight()
    return self._curHeight
end

function AncientCityRuleItem:getInfo()
    return self._info
end

return AncientCityRuleItem