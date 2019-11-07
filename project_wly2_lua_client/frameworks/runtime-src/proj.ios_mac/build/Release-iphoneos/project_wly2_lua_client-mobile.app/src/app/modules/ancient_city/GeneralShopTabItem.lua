local GeneralShopTabItem = class("GeneralShopTabItem", function()
    return ccui.Layout:create()
end)

function GeneralShopTabItem:ctor(args)
    self._view = nil
    self._info = args and args.info
    self:init()
end

function GeneralShopTabItem:init()
    GeneralShopTabItem._txtTab = {
        StaticData["local_text"]['label.common.ancient.city.shop'],
        StaticData["local_text"]['label.common.arena.shop'],
        StaticData["local_text"]['label.common.trial.tower.shop'],
        StaticData['local_text']["label.common.jade.shop"],
        StaticData['local_text']["label.common.coin.shop"],
    }
    if not self._view then
        self._view = cc.CSLoader:createNode("ancient_city/AncientCityTabItem.csb")
    end
    self:addChild(self._view)
    self:setAnchorPoint(cc.p(0.5,0.5))
    self:setContentSize(self._view:getContentSize())
    self._view:setPosition(cc.p(0,0))
    self._checkBox = self._view:getChildByName("CheckBox_1");
    self._txtName = self._view:getChildByName("Text_1");
    self._lockedImg = self._view:getChildByName("Image_3");
    self._lockedImg:setVisible(false)
    self._checkBox:addEventListener(function(sender, eventType)
        if self._callback then
            self._callback(self._index)
        end
    end)
    self:initInfo()
end

function GeneralShopTabItem:setInfo(info)
    self._info = info
    self:initInfo()
end

function GeneralShopTabItem:setIndex(index)
    self._index = index
end

function GeneralShopTabItem:setClickCallBack(callback)
    self._callback = callback
end

function GeneralShopTabItem:setCheckBoxState(state)
    self._checkBox:setSelected(state)
    self._checkBox:setTouchEnabled(not state)
    if state then
        self._txtName:setTextColor(uq.parseColor('#ffffff'))
    else
        self._txtName:setTextColor(uq.parseColor('#61B5D9'))
    end
end

function GeneralShopTabItem:initInfo()
    self._checkBox:setSelected(false)
    self._txtName:setString(self._txtTab[self._info.index])
end

function GeneralShopTabItem:getInfo()
    return self._info
end

return GeneralShopTabItem