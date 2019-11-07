local AncientCityStrategyItem = class("AncientCityStrategyItem", function()
    return ccui.Layout:create()
end)

function AncientCityStrategyItem:ctor(args)
    self._view = nil
    self._info = args and args.info
    self:init()
end

function AncientCityStrategyItem:init()
    if not self._view then
        local node = cc.CSLoader:createNode("ancient_city/AncientCityStrategyItem.csb")
        self._view = node:getChildByName("Panel_1")
    end
    self._view:removeSelf()
    self:addChild(self._view)
    self:setAnchorPoint(cc.p(0.5,0.5))
    self:setContentSize(self._view:getContentSize())
    self._view:setPosition(cc.p(0,0))
    self._desLabel = self._view:getChildByName("label_des");
    self:initInfo()
end

function AncientCityStrategyItem:setInfo(info)
    self._info = info
    self:initInfo()
end

function AncientCityStrategyItem:initInfo()
    self._desLabel:setString(string.format(StaticData['local_text']['ancient.strategy.des'], self._info.name, self._info.level))
end

function AncientCityStrategyItem:getInfo()
    return self._info
end

return AncientCityStrategyItem