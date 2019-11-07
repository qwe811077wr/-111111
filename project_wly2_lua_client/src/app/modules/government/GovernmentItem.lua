local GovernmentItem = class("GovernmentItem", function()
    return ccui.Layout:create()
end)

function GovernmentItem:ctor(args)
    self._view = nil
    self._curInfo = nil
    self:init()
end

function GovernmentItem:init()
    if not self._view then
        local node = cc.CSLoader:createNode("government/GovernmentItem.csb")
        self._view = node:getChildByName("Panel_3")
    end
    self._view:removeSelf()
    self:addChild(self._view)
    self:setContentSize(self._view:getContentSize())
    self._view:setPosition(cc.p(0,0))
    self._governmentLabel = self._view:getChildByName("label_government")
    self._lockNode = self._view:getChildByName("Node_1")
    self._lockDesLabel = self._lockNode:getChildByName("label_des")
    self._lockConditionLabel = self._lockNode:getChildByName("label_condition")
    self._addLabel = self._lockNode:getChildByName("label_add")
    self._lockImage = self._lockNode:getChildByName("Image_lock")
    self._infoNode = self._view:getChildByName("Node_2")
    self._nameLabel = self._infoNode:getChildByName("label_name")
    self._imgIcon = self._infoNode:getChildByName("Panel_2"):getChildByName("Image_7")
    self:updateInfo()
end

function GovernmentItem:setInfo(info, pos_cityid)
    self._curInfo = info
    self._cityId = pos_cityid
    self:updateInfo()
end

function GovernmentItem:updateInfo()
    self._governmentLabel:setString("")
    local temp = StaticData['world_city'][self._cityId]
    if temp then
        self._governmentLabel:setString(string.format(StaticData['local_text']["crop.government.des9"], temp.name))
    end
    self._infoNode:setVisible(self._curInfo and not self._curInfo.is_last)
    self._lockNode:setVisible(self._curInfo == nil or self._curInfo.is_last)
    self._addLabel:setVisible(self._curInfo == nil)
    self._lockImage:setVisible(self._curInfo ~= nil)
    if self._curInfo == nil then
        self._lockDesLabel:setString(StaticData["local_text"]["crop.government.des3"])
        self._lockConditionLabel:setString("")
    elseif self._curInfo.is_last then
        self._lockDesLabel:setString(StaticData["local_text"]["crop.government.des4"])
        self._lockConditionLabel:setString(StaticData["local_text"]["crop.government.des5"])
    else
        local res_head = uq.getHeadRes(self._curInfo.img_id, self._curInfo.img_type)
        self._imgIcon:loadTexture(res_head)
        self._nameLabel:setString(self._curInfo.name)
    end
end

return GovernmentItem