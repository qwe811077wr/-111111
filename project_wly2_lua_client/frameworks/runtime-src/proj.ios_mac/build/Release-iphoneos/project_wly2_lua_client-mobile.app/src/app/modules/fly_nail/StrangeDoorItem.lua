local StrangeDoorItem = class("StrangeDoorItem", function()
    return ccui.Layout:create()
end)

function StrangeDoorItem:ctor(args)
    self._view = nil
    self._info = args and args.info
    self._levelLimit = 0
    self:init()
end

function StrangeDoorItem:init()
    if not self._view then
        local node = cc.CSLoader:createNode("fly_nail/StrangeDoorItem.csb")
        self._view = node:getChildByName("Panel_1")
    end
    self._view:removeSelf()
    self:addChild(self._view)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self._view:getContentSize())
    self._view:setPosition(cc.p(0, 0))
    self._nameImg = self._view:getChildByName("img_name");
    self._limitLabel = self._view:getChildByName("lbl_limit");
    self._desLabel = self._view:getChildByName("lbl_des");
    self._lvlLabel = self._view:getChildByName("lbl_level");
    self._btnLevel = self._view:getChildByName("btn_level");
    self._lockImg = self._view:getChildByName("Image_lock");
    self._maxLabel = self._view:getChildByName("lbl_max");
    self._effNode = self._view:getChildByName("Node_eff");
    self._btnLevel:setPressedActionEnabled(true)
    self._btnLevel:setTouchEnabled(true)
    self._btnLevel:getChildByName("label_name_0"):setString(StaticData['local_text']['label.level.up'])
    self._maxLabel:setString(StaticData['local_text']['fly.nail.item.des5'])
    self._lockImg:getChildByName("lbl_des_0"):setString(StaticData['local_text']['fly.nail.item.des2'])
    self._btnLevel:addClickEventListenerWithSound(function(sender)
        if self._info.data == nil then
            uq.fadeInfo(string.format(StaticData['local_text']['fly.nail.battle.des15'], self._info.xml.name))
            return
        end
        local build_lvl = uq.cache.role:getBuildingLevel(self._info.xml.castleMap)
        if build_lvl < self._levelLimit then
            local temp = StaticData['buildings']['CastleMap'][self._info.xml.castleMap]
            local des = string.format(StaticData['local_text']['fly.nail.general.des2'], temp.name, self._levelLimit)
            uq.fadeInfo(des)
            return
        end
        network:sendPacket(Protocol.C_2_S_MIRACLE_FIGHT_LEVEL_UP, {id = self._info.xml.ident})
    end)
    self:initInfo()
end

function StrangeDoorItem:setInfo(info)
    self._info = info
    self:initInfo()
end

function StrangeDoorItem:initInfo()
    if not self._info then
        return
    end
    self._lockImg:setVisible(not self._info.unlock)
    self._nameImg:loadTexture("img/fly_nail/" .. self._info.xml.skillImage)

    local lvl = self._info.data == nil and 1 or self._info.data.lvl
    local level_xml = nil
    local next_level_xml = nil
    for k, v in pairs(self._info.xml.Skill) do
        if v.level == lvl then
            level_xml = v
        end
        if v.level == lvl + 1 then
            next_level_xml = v
        end
    end
    self._btnLevel:setVisible(self._info.unlock and (next_level_xml ~= nil))
    self._lvlLabel:setHTMLText(string.format(StaticData['local_text']['fly.nail.item.des3'], self._info.xml.name, lvl))
    local build_lvl = uq.cache.role:getBuildingLevel(self._info.xml.castleMap)
    self._desLabel:setString(string.format(StaticData['local_text']['fly.nail.general.des3'], self._info.xml.name, level_xml.buff * 100))
    self._limitLabel:setVisible(false)
    self._maxLabel:setVisible(next_level_xml == nil)
    if next_level_xml == nil then
        return
    end
    self._limitLabel:setVisible((build_lvl < level_xml.limitLevel) or not self._info.unlock)
    if not self._info.unlock then
        self._limitLabel:setHTMLText(string.format(StaticData['local_text']['fly.nail.item.des4'], self._info.xml.level))
    elseif build_lvl < level_xml.limitLevel then
        local temp = StaticData['buildings']['CastleMap'][self._info.xml.castleMap]
        self._limitLabel:setHTMLText(string.format(StaticData['local_text']['fly.nail.general.des2'], temp.name, level_xml.limitLevel))
    end
end

function StrangeDoorItem:getInfo()
    return self._info
end

return StrangeDoorItem