local AncientCityStrategy = class("AncientCityStrategy", require('app.base.PopupBase'))
local AncientCityStrategyItem = require("app.modules.ancient_city.AncientCityStrategyItem")

AncientCityStrategy.RESOURCE_FILENAME = "ancient_city/AncientCityStrategy.csb"
AncientCityStrategy.RESOURCE_BINDING = {
    ["ScrollView_1"]            = {["varname"] = "_scrollView"},
    ["img_wei"]                 ={["varname"] = "_imgWei",["events"] = {{["event"] = "touch",["method"] = "_onImgWei"}}},
    ["img_wu"]                  ={["varname"] = "_imgWu",["events"] = {{["event"] = "touch",["method"] = "_onImgWu"}}},
    ["img_shu"]                 ={["varname"] = "_imgShu",["events"] = {{["event"] = "touch",["method"] = "_onImgShu"}}},
}

function AncientCityStrategy:ctor(name, args)
    AncientCityStrategy.super.ctor(self, name, args)
    self._curInfoArray = {}
    self._imgArray = {}
    self._curCountryId = uq.cache.role.country_id
end

function AncientCityStrategy:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self:initUi()
    self:initProtocolData()
end

function AncientCityStrategy:initProtocolData()
    services:addEventListener("onAncientCityLookUpGuide", handler(self, self._onAncientCityLookUpGuide), '_onAncientCityLookUpGuideByStrategy')
end

function AncientCityStrategy:removeProtocolData()
    services:removeEventListenersByTag("_onAncientCityLookUpGuideByStrategy")
end

function AncientCityStrategy:_onAncientCityLookUpGuide(msg)
    self._curInfoArray = msg.data
    self:updateScroll()
end

function AncientCityStrategy:initUi()
    table.insert(self._imgArray, self._imgWei)
    table.insert(self._imgArray, self._imgShu)
    table.insert(self._imgArray, self._imgWu)
    self:updateCountry()
end

function AncientCityStrategy:updateCountry()
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_LOOKUP_GUIDE, {country_id =  self._curCountryId})
    for k, v in ipairs(self._imgArray) do
        self._imgArray[k]:getChildByName("img"):setVisible(k == self._curCountryId)
        if k == self._curCountryId then
            self._imgArray[k]:getChildByName("label"):setTextColor(uq.parseColor("#EFFDFF"))
        else
            self._imgArray[k]:getChildByName("label"):setTextColor(uq.parseColor("#659291"))
        end
    end
end

function AncientCityStrategy:updateScroll()
    self._scrollView:removeAllChildren()
    local item_size = self._scrollView:getContentSize()
    local index = #self._curInfoArray
    local inner_height = index * 60
    self._scrollView:setInnerContainerSize(cc.size(item_size.width, inner_height))
    self._scrollView:setTouchEnabled(false)
    self._scrollView:setScrollBarEnabled(false)
    local item_posY = 30
    for _, t in ipairs(self._curInfoArray) do
        local euqip_item = AncientCityStrategyItem:create({info = t})
        euqip_item:setPosition(cc.p(item_size.width * 0.5, item_posY))
        euqip_item:setTouchEnabled(true)
        euqip_item:addClickEventListenerWithSound(function(sender)
            local info = sender:getInfo()
            uq.BattleReport:getInstance():showBattleReport(info.report_id, handler(self, self._onPlayReportEnd))
        end)
        self._scrollView:addChild(euqip_item)
        item_posY = item_posY + 60
    end
end

function AncientCityStrategy:_onPlayReportEnd(report)
    if not report then
        return
    end
    uq.BattleReport:getInstance():showBattleResult(report)
end

function AncientCityStrategy:_onImgWu(event)
    if event.name ~= "ended" then
        return
    end
    self._curCountryId = 3
    self:updateCountry()
end

function AncientCityStrategy:_onImgShu(event)
    if event.name ~= "ended" then
        return
    end
    self._curCountryId = 2
    self:updateCountry()
end

function AncientCityStrategy:_onImgWei(event)
    if event.name ~= "ended" then
        return
    end
    self._curCountryId = 1
    self:updateCountry()
end

function AncientCityStrategy:dispose()
    self:removeProtocolData()
    AncientCityStrategy.super.dispose(self)
end
return AncientCityStrategy