local AncientCitySweep = class("AncientCitySweep", require("app.base.PopupBase"))
local AncientCitySweepItem = require("app.modules.ancient_city.AncientCitySweepItem")
local EquipItem = require("app.modules.common.EquipItem")

AncientCitySweep.RESOURCE_FILENAME = "ancient_city/AncientCitySweep.csb"

AncientCitySweep.RESOURCE_BINDING  = {
    ["btn_get1"]                ={["varname"] = "_btnGet1",["events"] = {{["event"] = "touch",["method"] = "_onBtnGet"}}},
    ["Button_1"]                ={["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "_onBtnGet"}}},
    ["btn_get2"]                ={["varname"] = "_btnGet2",["events"] = {{["event"] = "touch",["method"] = "_onBtnGet2"}}},
    ["btn_get5"]                ={["varname"] = "_btnGet5",["events"] = {{["event"] = "touch",["method"] = "_onBtnGet5"}}},
    ["label_name"]              ={["varname"] = "_nameLabel"},
    ["Panel_tabview1"]          ={["varname"] = "_panelTableView1"},
    ["Panel_tabview2"]          ={["varname"] = "_panelTableView2"},
    ["Panel_4"]                 ={["varname"] = "_panel"},
    ["Image_rate"]              = {["varname"] = "_imgRate"},
    ["Image_rate2"]             = {["varname"] = "_imgRate2"},
    ["Text_2"]                  = {["varname"] = "_txtDec1"},
    ["Text_2_0"]                = {["varname"] = "_txtDec2"},
    ["times_num_txt"]           = {["varname"] = "_txtNumTimes"},
    ["label_cost2"]             = {["varname"] = "_txtCostLeft"},
    ["label_cost1"]             = {["varname"] = "_txtCostRight"},
    ["Panel_5"]                 = {["varname"] = "_panelRate"},
}

function AncientCitySweep:ctor(name, args)
    AncientCitySweep.super.ctor(self, name, args)
    self._curInfo = args.info
    self._name = args.name or ""
    uq.cache.ancient_city.battle_info = self._curInfo
    self._curLayerInfoArray = {}
    self._curItemInfo = {}
    self._curRewardInfo = {}
    self._tableView1 = nil
    self._tableView2 = nil
    self._curMultiple = 1
    self._newMultiple = 1
    uq.cache.ancient_city.sweep_over = false
    self._xml = StaticData['ancient_info'][1] or {}
    self._imgPath = {
        "img/ancient_city/g04_000086_0001_1.png",
        "img/ancient_city/g04_000086_0002_2.png",
        "img/ancient_city/g04_000086_0003_3.png",
        "img/ancient_city/g04_000086_0004_4.png",
        "img/ancient_city/g04_000086_0005_5.png",
    }
end

function AncientCitySweep:init()
    self:parseView()
    self:centerView()
    self:initTableView()
    for k, v in pairs(self._curInfo.Layer) do
        table.insert(self._curLayerInfoArray, v)
    end
    table.sort(self._curLayerInfoArray, function(a, b)
        return a.ident < b.ident
    end)
    self:initUi()
    self:initProtocolData()
    self:setLayerColor()
end

function AncientCitySweep:_onBtnGet(event)
    if event.name ~= "ended" then
        return
    end
    if not uq.cache.ancient_city.sweep_over then
        uq.fadeInfo(StaticData["local_text"]["ancient.city.sweep.press.des"])
        return
    end
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_GET_REWARD, {})
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_QUIT_SCENE, {})
    local info = uq.cache.ancient_city:getPassCityInfo()
    info.daily_num = info.daily_num + 1
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ANCIENT_CITY_UPDATE_FIGHT_NUM})
    self:disposeSelf()
end

function AncientCitySweep:_onBtnGet2(event)
    if event.name ~= "ended" then
        return
    end
    if not uq.cache.ancient_city.sweep_over then
        uq.fadeInfo(StaticData["local_text"]["ancient.city.sweep.press.des"])
        return
    end
    if not uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN, 20) then
        uq.fadeInfo(string.format(StaticData["local_text"]["label.res.tips.less"], StaticData.getCostInfo(uq.config.constant.COST_RES_TYPE.GOLDEN).name))
        return
    end
    if self._newMultiple ~= self._curMultiple then
        return
    end
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_CHANGE_REWARD, {is_double = 1})
end

function AncientCitySweep:_onBtnGet5(event)
    if event.name ~= "ended" then
        return
    end
    if not uq.cache.ancient_city.sweep_over then
        uq.fadeInfo(StaticData["local_text"]["ancient.city.sweep.press.des"])
        return
    end
    if not uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN, 100) then
        uq.fadeInfo(string.format(StaticData["local_text"]["label.res.tips.less"], StaticData.getCostInfo(uq.config.constant.COST_RES_TYPE.GOLDEN).name))
        return
    end
    if self._newMultiple ~= self._curMultiple then
        return
    end
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_CHANGE_REWARD, {is_double = 0})
end

function AncientCitySweep:initUi()
    self:addExceptNode(self._panel)
    self._btnGet1:setPressedActionEnabled(true)
    self._btnGet2:setPressedActionEnabled(true)
    self._btnGet5:setPressedActionEnabled(true)
    self._txtNumTimes:setString("x")
    self._txtDec1:setString(tostring(self._curMultiple))
    self._txtCostLeft:setString(tostring(uq.RewardType.new(self._xml.doubleCost):num()))
    self._txtCostRight:setString(tostring(uq.RewardType.new(self._xml.multipleCost):num()))
end

function AncientCitySweep:playAction()
    if self._newMultiple == self._curMultiple then
        self._txtDec1:stopAllActions()
        self._txtDec2:stopAllActions()
        return
    end
    local off_x = 14
    local ac1 = cc.Sequence:create(cc.MoveBy:create(0.3,cc.p(0, off_x * 2)), cc.CallFunc:create(handler(self, self.playAction)), nil)
    local ac2 = cc.MoveBy:create(0.3,cc.p(0, off_x * 2))
    self._txtDec1:stopAllActions()
    self._txtDec2:stopAllActions()
    if self._txtDec1:getPositionY() < self._txtDec2:getPositionY() then
        self._txtDec1:runAction(ac2)
        self._txtDec1:setPositionY(off_x)
        self._txtDec1:setString(tostring(self._curMultiple))
        self._txtDec2:setPositionY(-off_x)
        self._txtDec2:runAction(ac1)
        self._txtDec2:setString(tostring(self._curMultiple + 1))
    else
        self._txtDec2:runAction(ac2)
        self._txtDec2:setPositionY(off_x)
        self._txtDec2:setString(tostring(self._curMultiple))
        self._txtDec1:setPositionY(-off_x)
        self._txtDec1:runAction(ac1)
        self._txtDec1:setString(tostring(self._curMultiple + 1))
    end
    self._curMultiple = self._curMultiple + 1
end

function AncientCitySweep:_onAncientCityChangeReward(msg)
    uq.fadeInfo(StaticData["local_text"]["ancient.city.sweep.gold.des2"])
    self._newMultiple = msg.data.rate
    self._imgRate:stopAllActions()
    self._imgRate2:stopAllActions()
    self:playAction()
    local ShaderEffect = uq.ShaderEffect
    if self._newMultiple >= 2 then
        ShaderEffect:addGrayButton(self._btnGet2)
        self._btnGet2:setTouchEnabled(false)
    end
    if self._newMultiple >= 5 then
        ShaderEffect:addGrayButton(self._btnGet5)
        self._btnGet5:setTouchEnabled(false)
    end
    self:updateTotalReward()
end

function AncientCitySweep:initProtocolData()
    services:addEventListener(services.EVENT_NAMES.ON_ANCIENT_CITY_MEET_PLAYER, handler(self, self._onAncientCityMeetPlayer), '_onAncientCityMeetPlayerBySweep')
    services:addEventListener(services.EVENT_NAMES.ON_ANCIENT_CITY_MEET_NPC, handler(self, self._onAncientCityMeetNpc), '_onAncientCityMeetNpcBySweep')
    services:addEventListener(services.EVENT_NAMES.ON_ANCIENT_CITY_BATTLE_RES, handler(self, self._onAncientCityBattleNpc), '__onAncientCityBattleNpcBySweep')
    services:addEventListener(services.EVENT_NAMES.ON_ANCIENT_CITY_ENTER_SCENE, handler(self, self._onSendEnterScene), '_onAncientCityBattleBySweep')
    services:addEventListener(services.EVENT_NAMES.ON_ANCIENT_CITY_GET_REWARD, handler(self, self._onAncientCityGetReward), '_onAncientCityGetRewardBySweep')
    services:addEventListener(services.EVENT_NAMES.ON_BATTLE_NPC_LOST, handler(self, self._onBattleLost), '_onBattleLostBySweep')
    services:addEventListener(services.EVENT_NAMES.ON_BATTLE_NPC_WIN, handler(self, self._onBattleWin), '_onBattleWinBySweep')
    services:addEventListener(services.EVENT_NAMES.ON_ANCIENT_CITY_MEET_TREASURE, handler(self, self._onAncientCityMeetTreasure), '_onAncientCityMeetTreasureBySweep')
    network:addEventListener(Protocol.S_2_C_ANCIENT_CITY_CHANGE_REWARD, handler(self, self._onAncientCityChangeReward), '_onAncientCityChangeRewardBySweep')
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_SWEEP, {id = self._curInfo.ident,bAuto = 1})
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_ENTER_SCENE, {city_id = self._curInfo.ident,layer = uq.cache.ancient_city.city_id,force = 0})
end

function AncientCitySweep:removeProtocolData()
    services:removeEventListenersByTag("_onAncientCityMeetPlayerBySweep")
    services:removeEventListenersByTag("_onAncientCityMeetNpcBySweep")
    services:removeEventListenersByTag("_onAncientCityBattleBySweep")
    services:removeEventListenersByTag("_onAncientCityGetRewardBySweep")
    services:removeEventListenersByTag("__onAncientCityBattleNpcBySweep")
    services:removeEventListenersByTag("_onBattleLostBySweep")
    services:removeEventListenersByTag("_onBattleWinBySweep")
    network:removeEventListenerByTag("_onAncientCityChangeRewardBySweep")
    services:removeEventListenersByTag("_onAncientCityMeetTreasureBySweep")
end

function AncientCitySweep:_onAncientCityMeetPlayer()
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ANCIENT_CITY_BEFORE, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, msg_type = 0, close_open_action = true, ["type"] = 0})
end

function AncientCitySweep:_onAncientCityMeetNpc(msg)
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_DETOUR, {})
end

function AncientCitySweep:_onBattleLost(evt)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ANCIENT_CITY_PLAYER, {msg_type = 1})
end

function AncientCitySweep:_onBattleWin(evt)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ANCIENT_CITY_PLAYER, {msg_type = 1})
end

function AncientCitySweep:_onPlayReportEnd(report)
    if not report then
        return
    end
    uq.BattleReport:getInstance():showBattleResult(report)
end

function AncientCitySweep:_onAncientCityBattleNpc()
    if uq.cache.ancient_city.battle_res.battle_type == 0 then
        if uq.cache.ancient_city.battle_res.res == 0 then
            local troop_info = self._curLayerInfoArray[uq.cache.ancient_city.city_id].Troop
            local troop_array = {}
            for k,v in pairs(troop_info) do
                table.insert(troop_array,v)
            end
            table.sort(troop_array,function(a,b)
                return a.ident < b.ident
            end)
            local npc_info = troop_array[uq.cache.ancient_city.npc_pos]
            uq.ModuleManager:getInstance():show(uq.ModuleManager.ANCIENT_CITY_CHECK_POINT, {npc_info = npc_info,fail = true})
        else
            network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_MOVE, {hasSecretRoom = 0})
        end
    else
        uq.BattleReport:getInstance():showBattleReport(uq.cache.ancient_city.battle_res.report_id, handler(self, self._onPlayReportEnd))
    end
end

function AncientCitySweep:_onSendEnterScene()
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_ENTER_SCENE, {city_id = self._curInfo.ident,layer = uq.cache.ancient_city.city_id,force = 0})
end

function AncientCitySweep:_onAncientCityMeetTreasure()
    self:updateTotalReward()
end

function AncientCitySweep:_onAncientCityGetReward(msg)
    self:updateCurReward(msg.data)
    if uq.cache.ancient_city.city_id < 7 then
        self:_onSendEnterScene()
    elseif uq.cache.ancient_city.city_id == 8 then
        uq.cache.ancient_city.sweep_over = true
    end
end

function AncientCitySweep:updateTotalReward()
    self._curRewardInfo = {}
    for k,t in pairs(uq.cache.ancient_city.total_rewards_info) do
        local info = {}
        info.type = tonumber(t.type)
        info.id = tonumber(t.paraml)
        info.num = tonumber(t.num) * self._newMultiple
        table.insert(self._curRewardInfo,info)
    end
    self._tableView2:reloadData()
end

function AncientCitySweep:updateCurReward(reward)
    local info_reward = {}
    info_reward.ident = uq.cache.ancient_city.city_id - 1
    info_reward.rewards = {}
    for k,t in pairs(reward) do
        local info = {}
        info.type = tonumber(t.type)
        info.id = tonumber(t.paraml)
        info.num = tonumber(t.num)
        table.insert(info_reward.rewards,info)
    end
    table.insert(self._curItemInfo,info_reward)
    self._tableView1:reloadData()
    if #self._curItemInfo > 3 then
        local offset = self._tableView1:getContentOffset();
        offset.y = 0
        self._tableView1:setContentOffset(offset);
    end
end

function AncientCitySweep:initTableView()
    local size = self._panelTableView1:getContentSize()
    self._tableView1 = cc.TableView:create(cc.size(size.width,size.height))
    self._tableView1:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView1:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView1:setPosition(cc.p(0, 0))
    self._tableView1:setAnchorPoint(cc.p(0,0))
    self._tableView1:setDelegate()
    self._panelTableView1:addChild(self._tableView1)

    self._tableView1:registerScriptHandler(handler(self,self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._tableView1:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView1:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView1:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

    local size = self._panelTableView2:getContentSize()
    self._tableView2 = cc.TableView:create(cc.size(size.width,size.height))
    self._tableView2:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView2:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView2:setPosition(cc.p(0, 0))
    self._tableView2:setAnchorPoint(cc.p(0,0))
    self._tableView2:setDelegate()
    self._panelTableView2:addChild(self._tableView2)

    self._tableView2:registerScriptHandler(handler(self,self.tableCellTouched2), cc.TABLECELL_TOUCHED)
    self._tableView2:registerScriptHandler(handler(self,self.cellSizeForTable2), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView2:registerScriptHandler(handler(self,self.tableCellAtIndex2), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView2:registerScriptHandler(handler(self,self.numberOfCellsInTableView2), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
end

function AncientCitySweep:cellSizeForTable(view, idx)
    return 550, 172
end

function AncientCitySweep:numberOfCellsInTableView(view)
    return #self._curItemInfo
end

function AncientCitySweep:tableCellTouched(view, cell,touch)

end

function AncientCitySweep:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx + 1
    if not cell then
        cell = cc.TableViewCell:new()
        local info = self._curItemInfo[index]
        local euqip_item = nil
        if info ~= nil then
            euqip_item = AncientCitySweepItem:create({info = info, name = self._name})
            local width = euqip_item:getContentSize().width
            euqip_item:setPosition(cc.p(width * 0.5, 86))
            cell:addChild(euqip_item,1)
            euqip_item:setName("item")
        end
    else
        local info = self._curItemInfo[index]
        local euqip_item = cell:getChildByName("item")
        if info ~= nil then
            euqip_item:setInfo(info, self._name)
        end
    end
    return cell
end

function AncientCitySweep:cellSizeForTable2(view, idx)
    return 398, 104
end

function AncientCitySweep:numberOfCellsInTableView2(view)
    return math.floor((#self._curRewardInfo + 3) / 4)
end

function AncientCitySweep:tableCellTouched2(view, cell,touch)
    local touch_point = touch:getLocation()
    local index = cell:getIdx() * 4 + 1
    for i = 0,3,1 do
        local item = cell:getChildByName("item"..i)
        if item == nil then
            return
        end
        local pos=item:convertToNodeSpace(touch_point)
        local rect=cc.rect(0,0,item:getContentSize().width * 0.7,item:getContentSize().height * 0.7)
        if cc.rectContainsPoint(rect, pos) then
            local info = self._curRewardInfo[index]
            uq.showItemTips(info)
            break
        end
        index = index + 1
    end
end

function AncientCitySweep:tableCellAtIndex2(view, idx)
    local cell = view:dequeueCell()
    local index = idx * 4 + 1
    if not cell then
        cell = cc.TableViewCell:new()
        for i = 0, 3, 1 do
            local info = self._curRewardInfo[index]
            local width = 0
            local euqip_item = nil
            if info ~= nil then
                euqip_item = EquipItem:create({info = info})
                euqip_item:setScale(0.7)
                width = euqip_item:getContentSize().width * 0.8
                euqip_item:setPosition(cc.p((width * 0.5) + (width - 10) * i,52))
                cell:addChild(euqip_item,1)
                euqip_item:setName("item"..i)
            else
                euqip_item = EquipItem:create()
                euqip_item:setScale(0.7)
                width = euqip_item:getContentSize().width * 0.8
                euqip_item:setPosition(cc.p((width * 0.5) + (width - 10) * i,52))
                cell:addChild(euqip_item,1)
                euqip_item:setName("item"..i)
                euqip_item:setVisible(false)
            end
            index = index + 1
        end
    else
        for i = 0, 3, 1 do
            local info = self._curRewardInfo[index]
            local euqip_item = cell:getChildByName("item"..i)
            if info ~= nil then
                euqip_item:setInfo(info)
                euqip_item:setVisible(true)
            elseif euqip_item then
                euqip_item:setVisible(false)
            end
            index = index + 1
        end
    end
    return cell
end

function AncientCitySweep:dispose()
    self:removeProtocolData()
    AncientCitySweep.super.dispose(self)
    display.removeUnusedSpriteFrames()
end

return AncientCitySweep