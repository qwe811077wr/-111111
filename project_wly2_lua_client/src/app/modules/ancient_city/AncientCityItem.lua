local AncientCityItem = class("AncientCityItem", function()
    return ccui.Layout:create()
end)

function AncientCityItem:ctor(args)
    self._view = nil
    self._info = args and args.info
    self:init()
end

function AncientCityItem:init()
    if not self._view then
        local node = cc.CSLoader:createNode("ancient_city/AncientCityItem.csb")
        self._view = node:getChildByName("Panel_1")
    end
    self._view:removeSelf()
    self:addChild(self._view)
    self:setAnchorPoint(cc.p(0.5,0.5))
    self:setContentSize(self._view:getContentSize())
    self._view:setPosition(cc.p(0,0))
    self._nodeBase = self._view:getChildByName("Node_2")
    self._imgSelect = self._nodeBase:getChildByName("img_select");
    self._imgBg = self._nodeBase:getChildByName("img_bg");
    self._imgCur = self._nodeBase:getChildByName("img_cur");
    self._fightDesLabel = self._nodeBase:getChildByName("lbl_fight_des");
    self._fightDesLabel:setString(StaticData['local_text']['ancient.city.item.des3'])
    self._sprIcon = self._nodeBase:getChildByName("Sprite_1");
    self._nameLabel = self._nodeBase:getChildByName("lbl_name");
    self._fightLabel = self._nodeBase:getChildByName("lbl_fight");
    self._panelNotOpen = self._nodeBase:getChildByName("Panel_notopen");
    self._openDesLabel = self._panelNotOpen:getChildByName("lbl_open_des");
    self._nodeStar = self._nodeBase:getChildByName("Node_3");
    self:initInfo()
end

function AncientCityItem:setInfo(info)
    self._info = info
    self:initInfo()
end

function AncientCityItem:initInfo()
    self:setSelectImgVisible(false)
    self._imgCur:setVisible(false)
    if not self._info then
        return
    end
    if self._info.data == nil then
        self._panelNotOpen:setVisible(true)
        self._openDesLabel:setString(string.format(StaticData['local_text']['ancient.not.open.des'], self._info.level))
    else
        self._panelNotOpen:setVisible(not self._info.data.is_pass)
        self._openDesLabel:setString(StaticData['local_text']['ancient.need.finish.last'])
        if self._info.data.first_pass > 0 then
            self._imgCur:setVisible(true)
        end
    end
    local num = self._info.data == nil and 0 or self._info.data.layer
    for i = 1, 6 do
        self._nodeStar:getChildByName("star_" .. i .. "_img"):setVisible(i <= num)
    end
    self._nameLabel:setString(self._info.name)
    self._fightLabel:setString(self._info.recommendPower)
    self._sprIcon:setTexture("img/ancient_city/" .. self._info.miniImage)
end

function AncientCityItem:setSelectImgVisible(isvisible)
    self._imgSelect:setVisible(isvisible)
    self._imgBg:setVisible(not isvisible)
    local scale = isvisible and 1.0 or 0.9
    self._sprIcon:setScale(scale)
end

function AncientCityItem:getInfo()
    return self._info
end

function AncientCityItem:showAction()
    uq.intoAction(self._view)
end

return AncientCityItem