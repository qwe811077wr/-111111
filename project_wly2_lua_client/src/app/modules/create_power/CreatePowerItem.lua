local CreatePowerItem = class("CreatePowerItem", function()
    return ccui.Layout:create()
end)

CreatePowerItem._CITY_PATH = {
    "img/create_power/s03_0007102.png",
    "img/create_power/s03_0007106.png",
    "img/create_power/s03_0007108.png",
    "img/create_power/s03_0007109.png",
    "img/create_power/s03_0007107.png",
}

function CreatePowerItem:ctor(args)
    self._view = nil
    self._info = args and args.info
    self:init()
end

function CreatePowerItem:init()
    if not self._view then
        local node = cc.CSLoader:createNode("create_power/CreatePowerItem.csb")
        self._view = node:getChildByName("Panel_1")
    end
    self._view:removeSelf()
    self:addChild(self._view)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self._view:getContentSize())
    self._view:setPosition(cc.p(self._view:getContentSize().width * 0.5, self._view:getContentSize().height * 0.5))
    self._spriteCity = self._view:getChildByName("Sprite_2");
    self._spriteBg = self._view:getChildByName("sprite_bg");
    self._imgState = self._view:getChildByName("Image_state");
    self._nameLabel = self._view:getChildByName("label_name");
    self:initInfo()
end

function CreatePowerItem:setInfo(info)
    self._info = info
    self:initInfo()
end

function CreatePowerItem:initInfo()
    if not self._info then
        return
    end
    self:setPosition(cc.p(self._info.pos_x * 0.2, display.height - self._info.pos_y * 0.2))
    self._spriteBg:setVisible(false)
    self._imgState:setVisible(self._info.type == 1)
    if self._info.type == 1 then
        self._spriteBg:setVisible(not self._info.used)
        if self._info.used then
            self._imgState:loadTexture("img/create_power/s03_0007127.png")
            self._spriteCity:setTexture("img/create_power/s03_0007103.png")
        else
            self._imgState:loadTexture("img/create_power/s03_0007128.png")
            self._spriteCity:setTexture("img/create_power/s03_0007104.png")
        end
    else
        self._spriteCity:setTexture(self._CITY_PATH[self._info.type])
    end

    self._nameLabel:setString(self._info.name)
end

function CreatePowerItem:getInfo()
    return self._info
end

return CreatePowerItem