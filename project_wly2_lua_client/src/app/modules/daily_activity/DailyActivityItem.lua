local EquipItem = require("app.modules.common.EquipItem")
local DailyActivityItem = class("DailyActivityItem", function()
    return ccui.Layout:create()
end)

function DailyActivityItem:ctor(args)
    self._view = nil
    self._info = args and args.info
    DailyActivityItem.RED_TYPE = {
        uq.cache.hint_status.RED_TYPE.ANCIENT,
        0,
        0,
        0,
        uq.cache.hint_status.RED_TYPE.FLY_NAIL,
    }
    self:init()
end

function DailyActivityItem:init()
    if not self._view then
        local node = cc.CSLoader:createNode("daily_activity/DailyActivityItem.csb")
        self._view = node:getChildByName("Panel_1")
    end
    self._view:removeSelf()
    self:addChild(self._view)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self._view:getContentSize())
    self._view:setPosition(cc.p(0, 0))
    self._panelMash = self._view:getChildByName("Panel_2");
    self._imgBg = self._view:getChildByName("Image_1");
    self._nameLabel = self._view:getChildByName("label_title");
    self._desLabel = self._view:getChildByName("label_des");
    self._scrollView = self._view:getChildByName("ScrollView_2");
    local pos_x,pos_y = self._scrollView:getPosition()
    self._itemViewPosx1 = pos_x
    self._itemViewPosy1 = pos_y
    self:initInfo()
end

function DailyActivityItem:setInfo(info)
    self._info = info
    self:initInfo()
end

function DailyActivityItem:initInfo()
    if not self._info then
        return
    end
    self._imgBg:loadTexture("img/daily/" .. self._info.icon)
    self._nameLabel:setString(self._info.name)
    self._desLabel:setString(self._info.Content)
    local module_info = StaticData['module'][tonumber(self._info.moduleId)]
    if module_info and tonumber(module_info.openLevel) > uq.cache.role:level() then
        self._panelMash:setVisible(true)
    else
        self._panelMash:setVisible(false)
    end
    -- uq.showRedStatus(self, uq.cache.hint_status.status[self.RED_TYPE[self._info.ident]],
    --     -self._view:getContentSize().width * 0.5 + 100, self._view:getContentSize().height * 0.5 - 90)
    self._scrollView:removeAllChildren()
    local item_size = self._scrollView:getContentSize()
    local item_posX = 60
    self._scrollView:setTouchEnabled(true)
    self._scrollView:setPosition(cc.p(self._itemViewPosx1, self._itemViewPosy1))
    self._scrollView:setScrollBarEnabled(true)
    if self._info.reward == "" then
        local inner_width = 2 * 100
        self._scrollView:setInnerContainerSize(cc.size(inner_width, item_size.height))
        for i = 1, 2 do
            local img = ccui.ImageView:create("img/map_guide/g03_0000254.png")
            self._scrollView:addChild(img)
            img:setAnchorPoint(cc.p(0.5, 0.5))
            img:setPosition(cc.p(item_posX, item_size.height * 0.5))
            item_posX = item_posX + 100
        end
        return
    end
    local reward_array = uq.RewardType.parseRewards(self._info.reward)
    local index = #reward_array
    local inner_width = index * 100
    self._scrollView:setInnerContainerSize(cc.size(inner_width, item_size.height))
    if inner_width < item_size.width then
        local newPosX = (item_size.width - inner_width) * 0.5 + self._itemViewPosx1
        self._scrollView:setPosition(cc.p(newPosX, self._itemViewPosy1))
        self._scrollView:setTouchEnabled(false)
        self._scrollView:setScrollBarEnabled(false)
    end
    for _, t in ipairs(reward_array) do
        local euqip_item = EquipItem:create({info = t:toEquipWidget()})
        euqip_item:setPosition(cc.p(item_posX, item_size.height * 0.5))
        euqip_item:setTouchEnabled(true)
        euqip_item:setScale(0.75)
        euqip_item:addClickEventListenerWithSound(function(sender)
            local info = sender:getEquipInfo()
            uq.showItemTips(info)
        end)
        self._scrollView:addChild(euqip_item)
        item_posX = item_posX + 100
    end
end

function DailyActivityItem:getInfo()
    return self._info
end

return DailyActivityItem