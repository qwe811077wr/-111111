local TrialslTowerBoxReward = class("TrialslTowerBoxReward", require('app.base.PopupBase'))
local EquipItem = require("app.modules.common.EquipItem")

TrialslTowerBoxReward.RESOURCE_FILENAME = "test_tower/TestTowerReward.csb"
TrialslTowerBoxReward.RESOURCE_BINDING = {
    ["ScrollView_1"]            = {["varname"] = "_scrollView"},
    ["label_des"]               = {["varname"] = "_desLabel"},
    ["btn_getreward"]           ={["varname"] = "_btnGetReward",["events"] = {{["event"] = "touch",["method"] = "_onBtnGetReward"}}},
}

function TrialslTowerBoxReward:ctor(name, args)
    TrialslTowerBoxReward.super.ctor(self, name, args)
end

function TrialslTowerBoxReward:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self:initUi()
end

function TrialslTowerBoxReward:initUi()
    self._btnGetReward:setPressedActionEnabled(true)
    if uq.cache.trials_tower.trial_info.cur_layer_id == uq.cache.trials_tower.trial_info.reward_box_layer + 1 then
        self._btnGetReward:setVisible(false)
    else
        self._btnGetReward:setVisible(true)
    end
    local layer_id = uq.cache.trials_tower.trial_info.reward_box_layer + 1
    self._desLabel:setHTMLText(string.format(StaticData['local_text']['tower.box.reward.des1'], tostring(layer_id)))
    local xml_info = nil
    for k,v in ipairs(StaticData['tower_cfg']) do
        if v.ident == layer_id then
            xml_info = v
            break
        end
    end
    local pos_x,pos_y = self._scrollView:getPosition()
    self._itemViewPosx = pos_x
    self._itemViewPosy = pos_y
    if not xml_info then
        return
    end
    local reward_array = uq.RewardType.parseRewards(xml_info.reward)
    self._scrollView:removeAllChildren()
    local item_size = self._scrollView:getContentSize()
    local index = #reward_array
    local inner_width = index * 124
    self._scrollView:setInnerContainerSize(cc.size(inner_width,item_size.height))
    if inner_width < item_size.width then
        local newPosX = (item_size.width - inner_width) * 0.5 + self._itemViewPosx
        self._scrollView:setPosition(cc.p(newPosX,self._itemViewPosy))
        self._scrollView:setTouchEnabled(false)
        self._scrollView:setScrollBarEnabled(false)
    else
        self._scrollView:setTouchEnabled(true)
        self._scrollView:setPosition(cc.p(self._itemViewPosx,self._itemViewPosy))
        self._scrollView:setScrollBarEnabled(true)
    end
    local item_posX = 58
    for _,t in ipairs(reward_array) do
        local euqip_item = EquipItem:create({info = t:toEquipWidget()})
        euqip_item:setPosition(cc.p(item_posX,item_size.height * 0.5))
        euqip_item:setTouchEnabled(true)
        euqip_item:addClickEventListenerWithSound(function(sender)
            local info = sender:getEquipInfo()
            uq.showItemTips(info)
        end)
        self._scrollView:addChild(euqip_item)
        item_posX = item_posX + 124
    end
end

function TrialslTowerBoxReward:_onBtnGetReward(event)
    if event.name ~= "ended" then
        return
    end
    network:sendPacket(Protocol.C_2_S_TRIAL_TOWER_DRAW_REWARD_BOX, {})
    self:disposeSelf()
end

function TrialslTowerBoxReward:dispose()
    TrialslTowerBoxReward.super.dispose(self)
    display.removeUnusedSpriteFrames()
end
return TrialslTowerBoxReward