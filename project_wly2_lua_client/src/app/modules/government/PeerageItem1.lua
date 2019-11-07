local PeerageItem1 = class("PeerageItem1", function()
    return ccui.Layout:create()
end)

function PeerageItem1:ctor(args)
    self._view = nil
    self._curInfo = nil
    self:init()
end

function PeerageItem1:init()
    if not self._view then
        local node = cc.CSLoader:createNode("government/PeerageItem1.csb")
        self._view = node:getChildByName("Panel_3")
    end
    self._view:removeSelf()
    self:addChild(self._view)
    self:setContentSize(self._view:getContentSize())
    self._view:setPosition(cc.p(0,0))
    self._imgPeerage = self._view:getChildByName("img_governemnt");
    self._desLabel = self._view:getChildByName("label_des");
    self._bgImg = self._view:getChildByName("Image_bg");
    self._infoNode = self._view:getChildByName("Node_2");
    self._nameLabel = self._infoNode:getChildByName("label_name");
    self._imgCountry = self._infoNode:getChildByName("Image_country");
    self._cropsLabel = self._infoNode:getChildByName("label_corps");
    self._panelMash = self._infoNode:getChildByName("Panel_1");
    self._bgImg:setTouchEnabled(true)
    self._bgImg:addClickEventListenerWithSound(function(sender)
        if self._curInfo == nil then
            return
        end
        uq.ModuleManager:getInstance():show(uq.ModuleManager.PRIVILEGE_INFO, {info = self._curInfo})
    end)
    self._imgIcon = self._panelMash:getChildByName("Image_icon");
    self:updateInfo()
end

function PeerageItem1:setInfo(info)
    self._curInfo = info
    self:updateInfo()
end

function PeerageItem1:updateInfo()
    if self._curInfo == nil then
        return
    end
    self._infoNode:setVisible(self._curInfo.data ~= nil)
    self._desLabel:setVisible(self._curInfo.data == nil)
    self._imgPeerage:setTexture("img/government/" .. self._curInfo.icon)
    self._bgImg:loadTexture("img/government/g03_0000489.png")
    if self._curInfo.data == nil then
        return
    end
    self._cropsLabel:setString(self._curInfo.data.crop_name)
    self._nameLabel:setString(self._curInfo.data.player_name)
end

return PeerageItem1