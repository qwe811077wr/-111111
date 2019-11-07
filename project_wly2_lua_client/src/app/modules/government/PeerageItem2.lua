local PeerageItem2 = class("PeerageItem2", function()
    return ccui.Layout:create()
end)

function PeerageItem2:ctor(args)
    self._view = nil
    self._curInfo = nil
    self:init()
end

function PeerageItem2:init()
    if not self._view then
        local node = cc.CSLoader:createNode("government/PeerageItem2.csb")
        self._view = node:getChildByName("Panel_1")
    end
    self._view:removeSelf()
    self:addChild(self._view)
    self:setContentSize(self._view:getContentSize())
    self._view:setPosition(cc.p(0,0))
    self._rankNode3 = self._view:getChildByName("Node_rank3")
    self._rankNode4 = self._view:getChildByName("Node_rank4")
    self._peerageLabel = self._rankNode4:getChildByName("label_peerage")
    self._imgPeerage = self._rankNode3:getChildByName("Image_government")
    self._lockNode = self._view:getChildByName("Node_1")
    self._lockDesLabel = self._lockNode:getChildByName("label_des")
    self._infoNode = self._view:getChildByName("Node_2")
    self._nameLabel = self._infoNode:getChildByName("label_name")
    self._imgCountry = self._infoNode:getChildByName("Image_country")
    self._cropsLabel = self._infoNode:getChildByName("label_corps")
    self._iconPanel = self._infoNode:getChildByName("Panel_2")
    self._imgIcon = self._iconPanel:getChildByName("Image_7")
    self._view:getChildByName("Image_bg"):setTouchEnabled(true)
    self._view:getChildByName("Image_bg"):addClickEventListenerWithSound(function(sender)
        if self._curInfo == nil then
            return
        end
        uq.ModuleManager:getInstance():show(uq.ModuleManager.PRIVILEGE_INFO, {info = self._curInfo})
    end)
    self:updateInfo()
end

function PeerageItem2:setInfo(info)
    self._curInfo = info
    self:updateInfo()
end

function PeerageItem2:updateInfo()
    if self._curInfo == nil then
        return
    end
    self._infoNode:setVisible(self._curInfo.data ~= nil)
    self._lockNode:setVisible(self._curInfo.data == nil)
    self._rankNode3:setVisible(self._curInfo.rank == 2)
    self._rankNode4:setVisible(self._curInfo.rank > 2)
    self._imgPeerage:loadTexture("img/government/" .. self._curInfo.icon)
    self._peerageLabel:setString(self._curInfo.name)
    if self._curInfo.data == nil then
        return
    end
    self._cropsLabel:setString(self._curInfo.data.crop_name)
    self._nameLabel:setString(self._curInfo.data.player_name)
    local res_head = uq.getHeadRes(self._curInfo.data.img_id, self._curInfo.data.img_type)
    self._imgIcon:loadTexture(res_head)
end

return PeerageItem2