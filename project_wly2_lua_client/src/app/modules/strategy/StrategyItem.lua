local StrategyItem = class("StrategyItem", function()
    return ccui.Layout:create()
end)

function StrategyItem:ctor(args)
    self._view = nil
    self._info = args and args.info
    self:init()
end

function StrategyItem:init()
    if not self._view then
        local node = cc.CSLoader:createNode("strategy/StrategyItem.csb")
        self._view = node:getChildByName("Panel_1"):clone()
    end
    self:addChild(self._view)
    self:setAnchorPoint(cc.p(0.5,0.5))
    self:setContentSize(self._view:getContentSize())
    self._view:setPosition(cc.p(0,0))
    self._imgIcon = self._view:getChildByName("img_icon");
    self._panelSelected = self._view:getChildByName("Panel_3");
    self._imgbg = self._view:getChildByName("img_bg");
    self._nameLabel = self._view:getChildByName("lbl_name");
    self._levelLabel = self._view:getChildByName("lbl_level");
    self._desLabel = self._view:getChildByName("lbl_des");
    self._imgSel = self._view:getChildByName("sel_img");
    self._txtLevel = self._view:getChildByName("lbl_level_0");
    self._txtNotOpen = self._view:getChildByName("lbl_level_1");
    self._txtLevel:setString(StaticData["local_text"]["label.common.level"])
    self._txtNotOpen:setString(StaticData["local_text"]["label.bosom.module.not.open"])
    self:initInfo()
end

function StrategyItem:setInfo(info)
    self._info = info
    self:initInfo()
end

function StrategyItem:initInfo()
    if not self._info then
        return
    end
    self._imgIcon:loadTexture("img/strategy/" .. self._info.xml.icon)
    local hidden_state = self._info.level < 1
    self._nameLabel:setOpacity(255)
    self._nameLabel:setString(self._info.xml.name)
    self._levelLabel:setString(self._info.level)
    if hidden_state then
        uq.ShaderEffect:addGrayNode(self._imgIcon)
        uq.ShaderEffect:addGrayNode(self._imgbg)
    else
        uq.ShaderEffect:removeGrayNode(self._imgIcon)
        uq.ShaderEffect:removeGrayNode(self._imgbg)
    end
    self._txtNotOpen:setVisible(hidden_state)
    self._txtLevel:setVisible(not hidden_state)
    self._levelLabel:setVisible(not hidden_state)
end

function StrategyItem:setSelected(id)
    if not self._info then
        return
    end
    self._imgSel:setVisible(self._info.id == id)
end

function StrategyItem:getInfo()
    return self._info
end

return StrategyItem