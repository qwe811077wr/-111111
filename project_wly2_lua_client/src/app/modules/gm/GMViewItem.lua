local GMViewItem = class("GMViewItem", function()
    return ccui.Layout:create()
end)

function GMViewItem:ctor(args)
    self._view = nil
    self._info = args and args.info
    self:init()
end

function GMViewItem:init()
    if not self._view then
        local node = cc.CSLoader:createNode("gm/GMViewItem.csb")
        self._view = node:getChildByName("Panel_select")
    end
    self._view:removeSelf()
    self:addChild(self._view)
    self:setContentSize(self._view:getContentSize())
    self._typeImg1 = self._view:getChildByName("Image_8")
    self._typeImg2 = self._view:getChildByName("Image_12")
    self._typeImg1:setTouchEnabled(true)
    self._typeImg1:addClickEventListener(function(sender)
        self._info.state = not self._info.state
        self._typeImg2:setVisible(self._info.state)
    end)
    self._idLabel = self._view:getChildByName("label_id")
    self._nameLabel = self._view:getChildByName("label_des")
    self:initDialog()
end

function GMViewItem:setInfo(info)
    self._info = info
    self:initDialog()
end

function GMViewItem:initDialog()
    if not self._info then
        return
    end
    self._idLabel:setString(self._info.ident)
    self._nameLabel:setString(self._info.name)
    self._typeImg2:setVisible(self._info.state)
end

function GMViewItem:getInfo()
    return self._info
end

return GMViewItem
