local AncientCityPlayer = class("AncientCityPlayer", require('app.base.PopupBase'))
local EquipItem = require("app.modules.common.EquipItem")

AncientCityPlayer.RESOURCE_FILENAME = "ancient_city/AncientCityPlayer.csb"
AncientCityPlayer.RESOURCE_BINDING = {
    ["panel_1"]                             = {["varname"] = "_panelPress"},
    ["panel_1/img_icon"]                    = {["varname"] = "_iconImg"},
    ["panel_1/Panel_1"]                     = {["varname"] = "_panelRole"},
    ["panel_1/Panel_1/img_head"]            = {["varname"] = "_headImg"},
    ["panel_1/Panel_1/label_playername"]    = {["varname"] = "_playerNameLabel"},
    ["panel_1/Panel_1/labe_fight"]          = {["varname"] = "_fightLabel"},
    ["panel_1/Panel_1/labe_level"]          = {["varname"] = "_levelLabel"},
    ["panel_1/Panel_1/ScrollView_1"]        = {["varname"] = "_scrollView"},
    ["panel_1/Panel_1/label_time"]          = {["varname"] = "_timeLabel"},
    ["panel_1/Panel_1/btn_fight"]           = {["varname"] = "_btnFight",["events"] = {{["event"] = "touch",["method"] = "_onBtnFight"}}},
    ["panel_1/Panel_1/btn_exit"]            = {["varname"] = "_btnExit",["events"] = {{["event"] = "touch",["method"] = "_onBtnExit"}}},
    ["close_btn"]                           = {["varname"] = "_btnClose"},
    ["fail_btn"]                            = {["varname"] = "_btnFail"},
    ["flag_img"]                            = {["varname"] = "_imgFlag"},
    ["panel_1/Panel_fail"]                  = {["varname"] = "_panelFail"},
    ["panel_1/Panel_fail/Node_effect"]      = {["varname"] = "_fightTitleEff"},
    ["panel_1/Panel_fail/Panel_item"]       = {["varname"] = "_panelItem"},
    ["title_img"]                           = {["varname"] = "_imgTitle"},
    ["finish_dec_txt"]                      = {["varname"] = "_txtDecFinish"},
    ["ScrollView_2"]                        = {["varname"] = "_scrollView2"},
}

function AncientCityPlayer:ctor(name, args)
    AncientCityPlayer.super.ctor(self, name, args)
    self._curPlayerInfo = nil
    self._curMsgType = args.msg_type
end

function AncientCityPlayer:init()
    self._curPlayerInfo = uq.cache.ancient_city.player_info
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self:initUi()
    services:addEventListener(services.EVENT_NAMES.ON_ANCIENT_LOST_JADE, handler(self, self._onAncientLostJade), '_onAncientLostJadeByPlayer')
end

function AncientCityPlayer:initUi()
    self._btnFight:setPressedActionEnabled(true)
    self._btnExit:setPressedActionEnabled(true)
    self._panelPress:setTouchEnabled(true)
    self._panelPress:addClickEventListenerWithSound(function(sender)
        self:closeLayer()
    end)
    self._btnClose:addClickEventListenerWithSound(function(sender)
        if self._curMsgType == 0 then
            self:_onBtnExit({name = "ended"})
            return
        end
        self:closeLayer()
    end)
    self._btnFail:addClickEventListenerWithSound(function(sender)
        self:closeLayer()
    end)
    if self._curMsgType == 0 then
        self._panelFail:setVisible(false)
        self._panelRole:setVisible(true)
        local img_num = self._curPlayerInfo.country or 1
        self._imgFlag:loadTexture("img/common/ui/s03_0003" .. img_num + 2 .. ".png" )
        self._playerNameLabel:setString(self._curPlayerInfo.name)
        self._fightLabel:setString(self._curPlayerInfo.power)
        self._levelLabel:setString(self._curPlayerInfo.level)
        local reward = uq.cache.ancient_city.battle_info.challengerRwd
        self:updateReward(reward)
        local head_xml = StaticData['general'][self._curPlayerInfo.img_id]
        if head_xml then
            self._headImg:loadTexture("img/common/player_head/" .. head_xml.icon)
        end
        self._auto_exit = "auto_exit" .. tostring(self)
        if not uq.cache.ancient_city.sweep_over then
            self._timeNum = 20
            self._timeLabel:setString(string.format(StaticData["local_text"]["ancient.find.room.time.des"], self._timeNum))
            self._timeLabel:setVisible(true)
            uq.TimerProxy:addTimer(self._auto_exit, function()
                self._timeNum = self._timeNum - 1
                self._timeLabel:setString(string.format(StaticData["local_text"]["ancient.find.room.time.des"], self._timeNum))
                if self._timeNum == 0 then
                    uq.TimerProxy:removeTimer(self._auto_exit)
                    self:_onBtnExit({name = "ended"})
                    return
                end
            end, 1, -1)
        end
    else
        self._panelFail:setVisible(true)
        self._panelRole:setVisible(false)
        if uq.cache.ancient_city.battle_res.res == -1 then --输
            self:refreshEndItems(uq.cache.ancient_city._failRward)
            self._txtDecFinish:setString(StaticData["local_text"]["ancient.plunder"])
            self._imgTitle:loadTexture("img/ancient_city/s04_00163.png")
        else
            self:refreshEndItems(uq.cache.ancient_city.rewards_info)
            self._txtDecFinish:setString(StaticData["local_text"]["ancient.succeed.dec"])
            self._imgTitle:loadTexture("img/ancient_city/s04_00164.png")
        end
    end
    local xml_info = StaticData['general'][self._curPlayerInfo.general_id]
    if xml_info then
        self._iconImg:loadTexture("img/common/general_body/" .. xml_info.imageId)
    end
end

function AncientCityPlayer:closeLayer()
    if self._curMsgType == 0 then
        return
    end
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_MOVE, {hasSecretRoom = 0})
    self:disposeSelf()
end

function AncientCityPlayer:refreshEndItems(data)
    self._scrollView2:removeAllChildren()
    if not data or next(data) == nil then
        return
    end
    local ox = 100
    local tab = uq.RewardType:tabMergeReward(data)
    for i, v in ipairs(tab) do
        local item = EquipItem:create({info = v})
        item:setTouchEnabled(true)
        item:setPosition(cc.p((i - 0.5) * ox, 50))
        item:setScale(0.8)
        item:addClickEventListenerWithSound(function(sender)
            local info = sender:getEquipInfo()
            uq.showItemTips(info)
        end)
        self._scrollView2:addChild(item)
    end
    self._scrollView2:setInnerContainerSize(cc.size(#tab * ox, ox))
    self._scrollView2:setScrollBarEnabled(false)
end

function AncientCityPlayer:updateReward(reward)
    local pos_x,pos_y = self._scrollView:getPosition()
    self._itemViewPosx = pos_x
    self._itemViewPosy = pos_y
    local reward_array = uq.RewardType.parseRewards(reward)
    self._scrollView:removeAllChildren()
    local item_size = self._scrollView:getContentSize()
    local index = #reward_array
    local inner_width = index * 110
    self._scrollView:setInnerContainerSize(cc.size(inner_width, item_size.height))
    if inner_width < item_size.width then
        local newPosX = (item_size.width - inner_width) * 0.5 + self._itemViewPosx
        self._scrollView:setPosition(cc.p(newPosX,self._itemViewPosy))
        self._scrollView:setTouchEnabled(false)
    else
        self._scrollView:setTouchEnabled(true)
        self._scrollView:setPosition(cc.p(self._itemViewPosx,self._itemViewPosy))
    end
    self._scrollView:setScrollBarEnabled(false)
    local item_posX = 58
    for _, t in ipairs(reward_array) do
        local euqip_item = EquipItem:create({info = t:toEquipWidget()})
        euqip_item:setPosition(cc.p(item_posX,item_size.height * 0.5))
        euqip_item:setTouchEnabled(true)
        euqip_item:setScale(0.8)
        euqip_item:addClickEventListenerWithSound(function(sender)
            local info = sender:getEquipInfo()
            uq.showItemTips(info)
        end)
        self._scrollView:addChild(euqip_item)
        item_posX = item_posX + 100
    end
end

function AncientCityPlayer:_onBtnExit(event)
    if event.name ~= "ended" then
        return
    end
    self:disposeSelf()
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_CHALLENGE, {result = 0})
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_MOVE, {hasSecretRoom = 0})
end

function AncientCityPlayer:_onBtnFight(event)
    if event.name ~= "ended" then
        return
    end
    self:disposeSelf()
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_CHALLENGE, {result = 1})
end

function AncientCityPlayer:dispose()
    services:removeEventListenersByTag("_onAncientLostJadeByPlayer")
    uq.TimerProxy:removeTimer(self._auto_exit)
    AncientCityPlayer.super.dispose(self)
end
return AncientCityPlayer