local AncientCityBattleModule = class("AncientCityBattleModule", require("app.base.ModuleBase"))
local EquipItem = require("app.modules.common.EquipItem")

AncientCityBattleModule.RESOURCE_FILENAME = "ancient_city/AncientCityBattleMain.csb"

AncientCityBattleModule.RESOURCE_BINDING  = {
    ["img_bg"]                      ={["varname"] = "_imgBg"},
    ["Node_fighter"]                ={["varname"] = "_nodeFighterEff"},
    ["label_name"]                  ={["varname"] = "_nameLabel"},
    ["label_des"]                   ={["varname"] = "_deslabel"},
    ["Panel_tabview"]               ={["varname"] = "_panelTableView"},
    ["Panel_box"]                   ={["varname"] = "_panelBox"},
    ["img_cost1"]                   ={["varname"] = "_imgCost"},
    ["label_cost"]                  ={["varname"] = "_costLabel"},
    ["label_cost_0"]                ={["varname"] = "_txtMaxLv"},
    ["label_att"]                   ={["varname"] = "_attLabel"},
    ["label_def"]                   ={["varname"] = "_defLabel"},
    ["Node_yu"]                     ={["varname"] = "_nodeYu"},
    ["Node_gold"]                   ={["varname"] = "_nodeGold"},
    ["btn_inspire"]                 ={["varname"] = "_btnInspire",["events"] = {{["event"] = "touch",["method"] = "_onBtnInspire"}}},
}

function AncientCityBattleModule:ctor(name, args)
    AncientCityBattleModule.super.ctor(self, name, args)
    self._curInfo = args.info
    uq.cache.ancient_city.battle_info = self._curInfo
    uq.cache.ancient_city.isEnterBattleView = true
    self._tableView = nil
    self._npcInfo = nil
    self._curTabInfoArray = {}
    self._curLayerInfoArray = {}
    self._itemArray = {}
    self._view:setOpacity(0)
    self._view:runAction(cc.FadeIn:create(0.2))
    self._xml = StaticData['ancient_info'][1] or {}
    uq.cache.ancient_city.sweep_over = true
    uq.cache.ancient_city.total_rewards_info = nil
end

function AncientCityBattleModule:init()
    local top_ui = uq.ui.CommonHeaderUI:create()
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.MILITORY_ORDER, true))
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.MONEY, true))
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.GOLDEN, true))
    top_ui:setTitle(uq.config.constant.MODULE_ID.ANCIENT_CITY)
    self._topUI = top_ui
    self._view:addChild(top_ui:getNode())
    self._topUI:getBackBtn():addClickEventListenerWithSound(function()
        local function confirm()
            network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_QUIT_SCENE, {})
            self:disposeSelf()
            uq.runCmd('enter_ancient_city')
        end
        uq.ModuleManager:getInstance():show(uq.ModuleManager.ANCIENT_CITY_TIPS, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, func = confirm, ["type"] = 1})
    end)
    self:parseView()
    self:centerView()
    for k, v in pairs(self._curInfo.Layer) do
        table.insert(self._curLayerInfoArray, v)
    end
    table.sort(self._curLayerInfoArray, function(a, b)
        return a.ident < b.ident
    end)
    self:initDialog()
    self:initProtocolData()
    self:_onSendEnterScene()
    self:updateAddInfo()
    local reward = uq.RewardType.new(self._xml.inspireCost)
    local color = uq.cache.role:checkRes(reward:type(), reward:num()) and "#0B1B22" or "#AF38EA"
    self._costLabel:setString(tostring(reward:num()))
    self._costLabel:setTextColor(uq.parseColor(color))
end

function AncientCityBattleModule:_onBtnInspire(event)
    if event.name ~= "ended" then
        return
    end
    if not uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN, 2) then
        uq.fadeInfo(string.format(StaticData["local_text"]["label.res.tips.less"], StaticData.getCostInfo(uq.config.constant.COST_RES_TYPE.GOLDEN).name))
        return
    end
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_INSPIRE, {})
end

function AncientCityBattleModule:initProtocolData()
    services:addEventListener(services.EVENT_NAMES.ON_ANCIENT_CITY_TRADE_LOAD, handler(self, self._ancientCityTradeLoad),"_onAncientCityTradeLoadByBattle")
    services:addEventListener(services.EVENT_NAMES.ON_ANCIENT_CITY_CLEARANCE_REWARD, handler(self, self._onAncientCityClearanceReward), '_onAncientCityClearanceRewardByBattle')
    services:addEventListener(services.EVENT_NAMES.ON_ANCIENT_CITY_ENTER_SCENE, handler(self, self._onSendEnterScene), '_onAncientCityBattle')
    services:addEventListener(services.EVENT_NAMES.ON_ANCIENT_CITY_MEET_PLAYER, handler(self, self._onAncientCityMeetPlayer), '_onAncientCityMeetPlayerByBattle')
    services:addEventListener(services.EVENT_NAMES.ON_ANCIENT_CITY_INSPIRE, handler(self, self._onAncientCityInspire), 'onAncientCityInspireByBattle')
    services:addEventListener(services.EVENT_NAMES.ON_ANCIENT_CITY_GET_REWARD, handler(self, self._onAncientCityGetReward), '_onAncientCityGetRewardByBattle')
    services:addEventListener(services.EVENT_NAMES.ON_ANCIENT_CITY_MEET_NPC, handler(self, self._onAncientCityMeetNpc), '_onAncientCityMeetNpcByBattle')
    services:addEventListener(services.EVENT_NAMES.ON_BATTLE_NPC_LOST, handler(self, self._onBattleLost), '_onBattleLostByBattle')
    services:addEventListener(services.EVENT_NAMES.ON_BATTLE_NPC_WIN, handler(self, self._onBattleWin), '_onBattleWinByBattle')
    services:addEventListener(services.EVENT_NAMES.ON_ANCIENT_CITY_BATTLE_RES, handler(self, self._onAncientCityBattleNpc), '_onAncientCityBattleNpcByBattle')
    services:addEventListener(services.EVENT_NAMES.ON_ANCIENT_CITY_OPEN, handler(self, self._onCloseDialog), '_onCloseDialogByBattle')

    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_TRADE_LOAD, {trade_type = 0})
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_TRADE_LOAD, {trade_type = 1})  --金币
end

function AncientCityBattleModule:_onCloseDialog()
    self:disposeSelf()
end

function AncientCityBattleModule:_ancientCityTradeLoad()
    local jade_info = uq.cache.ancient_city.trade_info[0]
    if jade_info == nil or jade_info.pass_time < 0 or (60 * 30 <= jade_info.pass_time) then
        self._nodeYu:setVisible(false)
    else
        if self._jadeCdTimer then
            self._jadeCdTimer:setTime(60 * 30 - jade_info.pass_time)
        else
            local time_label = self._nodeYu:getChildByName("label_0")
            self._jadeCdTimer = uq.ui.TimerField:create(time_label, 60 * 30 - jade_info.pass_time, handler(self, self._cdTimeOver))
        end
        self._nodeYu:setVisible(true)
    end

    local gold_info = uq.cache.ancient_city.trade_info[1]
    if gold_info == nil or gold_info.pass_time < 0 or (60 * 30 <= gold_info.pass_time) then
        self._nodeGold:setVisible(false)
    else
        if self._goldCdTimer then
            self._goldCdTimer:setTime(60 * 30 - gold_info.pass_time)
        else
            local time_label = self._nodeGold:getChildByName("label_0")
            self._goldCdTimer = uq.ui.TimerField:create(time_label, 60 * 30 - gold_info.pass_time, handler(self, self._cdTimeOver))
        end
        self._nodeGold:setVisible(true)
    end
end

function AncientCityBattleModule:_cdTimeOver()
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_TRADE_LOAD, {trade_type = 0})
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_TRADE_LOAD, {trade_type = 1})  --金币
end

function AncientCityBattleModule:_onAncientCityClearanceReward()
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ANCIENT_CITY_CLEARANCE_REWARD)
end

function AncientCityBattleModule:_onAncientCityMeetPlayer()
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ANCIENT_CITY_BEFORE, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, msg_type = 0, close_open_action = true, ["type"] = 0})
end

function AncientCityBattleModule:_onAncientCityInspire()
    self:updateAddInfo()
end

function AncientCityBattleModule:_onBattleLost(evt)
    if uq.cache.ancient_city.battle_res.battle_type == 0 then  --npc
        local troop_info = self._curLayerInfoArray[uq.cache.ancient_city.city_id].Troop
        local troop_array = {}
        for k, v in pairs(troop_info) do
            table.insert(troop_array, v)
        end
        table.sort(troop_array, function(a, b)
            return a.ident < b.ident
        end)
        local npc_info = troop_array[uq.cache.ancient_city.npc_pos]
        uq.ModuleManager:getInstance():show(uq.ModuleManager.ANCIENT_CITY_CHECK_POINT, {npc_info = npc_info, fail = true})
    else --player
        uq.ModuleManager:getInstance():show(uq.ModuleManager.ANCIENT_CITY_PLAYER, {msg_type = 1})
    end
end

function AncientCityBattleModule:_onBattleWin(evt)
    if uq.cache.ancient_city.battle_res.battle_type == 0 then  --npc
        network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_MOVE, {hasSecretRoom = 0})
    else --player
        uq.ModuleManager:getInstance():show(uq.ModuleManager.ANCIENT_CITY_PLAYER, {msg_type = 1})
    end
end

function AncientCityBattleModule:_onAncientCityBattleNpc()
    local data = uq.cache.ancient_city.battle_res
    local addr = uq.cache.nodes:getReportAddress(data.report_id, '')
    uq.BattleReport:getInstance():load(addr, data.report_id, handler(self, self._reportLoaded), uq.BattleReport.TYPE_PERSONAL)
end

function AncientCityBattleModule:_reportLoaded(report_id, report)
    if not report then
        return
    end
    local troop_info = self._curLayerInfoArray[uq.cache.ancient_city.city_id].Troop
    local troop_array = {}
    for k, v in pairs(troop_info) do
        table.insert(troop_array, v)
    end
    table.sort(troop_array, function(a, b)
        return a.ident < b.ident
    end)
    local npc_info = troop_array[uq.cache.ancient_city.npc_pos]
    uq.runCmd('enter_single_battle_report', {report, handler(self, self._onPlayReportEnd), 'img/bg/battle/' .. npc_info.battleBg})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CLOSE_ARRANGED_BEFORE})
end

function AncientCityBattleModule:_onPlayReportEnd(report)
    if not report then
        return
    end
    if report.result > 0 then
        local data = {rewards = {}, ['report'] = report}
        uq.ModuleManager:getInstance():show(uq.ModuleManager.NPC_WIN_MODULE, data)
    else
        local data = {npc_id = report.npc_id, ['report'] = report}
        uq.ModuleManager:getInstance():show(uq.ModuleManager.NPC_LOST_MODULE, data)
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CLOSE_ARRANGED_BEFORE})
end

function AncientCityBattleModule:_onSendEnterScene()
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_ENTER_SCENE, {city_id = self._curInfo.ident, layer = uq.cache.ancient_city.city_id, force = 0})
    self:updateRewardInfo()
end

function AncientCityBattleModule:updateRewardInfo()
    if uq.cache.ancient_city.total_rewards_info then
        self:updateReward()
        self._deslabel:setVisible(false)
    else
        self._deslabel:setVisible(true)
    end
end

function AncientCityBattleModule:_onAncientCityGetReward(msg)
    self:showReward(msg.data)
end

function AncientCityBattleModule:_onAncientCityMeetNpc()
    self:showCheckPoint()
end

function AncientCityBattleModule:updateReward()
    self._curTabInfoArray = {}
    for k, t in pairs(uq.cache.ancient_city.total_rewards_info) do
        local info = {}
        info.type = tonumber(t.type)
        info.id = tonumber(t.paraml)
        info.num = tonumber(t.num)
        table.insert(self._curTabInfoArray, info)
    end
    self._tableView:reloadData()
end

function AncientCityBattleModule:removeProtocolData()
    services:removeEventListenersByTag("_onAncientCityMeetPlayerByBattle")
    services:removeEventListenersByTag("_onAncientCityClearanceRewardByBattle")
    services:removeEventListenersByTag("_onAncientCityBattle")
    services:removeEventListenersByTag("onAncientCityInspireByBattle")
    services:removeEventListenersByTag("_onBattleWinByBattle")
    services:removeEventListenersByTag("_onBattleLostByBattle")
    services:removeEventListenersByTag("_onAncientCityGetRewardByBattle")
    services:removeEventListenersByTag("_onAncientCityMeetNpcByBattle")
    services:removeEventListenersByTag("_onAncientCityTradeLoadByBattle")
    services:removeEventListenersByTag("_onAncientCityBattleNpcByBattle")
    services:removeEventListenersByTag("_onCloseDialogByBattle")
end

function AncientCityBattleModule:updateAddInfo()
    self._attLabel:setString("Lv." .. uq.cache.ancient_city.add_att)
    self._defLabel:setString("Lv." .. uq.cache.ancient_city.add_def)
    local is_full = uq.cache.ancient_city.add_att == 5 and uq.cache.ancient_city.add_def == 5
    self._txtMaxLv:setVisible(is_full)
    self._costLabel:setVisible(not is_full)
    self._imgCost:setVisible(not is_full)
    self._btnInspire:setTouchEnabled(not is_full)
end

function AncientCityBattleModule:updateDialog()
    self._nameLabel:setHTMLText(string.format(StaticData['local_text']['ancient.battle.title'], self._curInfo.name, uq.cache.ancient_city.city_id - 1))
    local index = 1
    for i = 1, uq.cache.ancient_city.city_id - 1, 1 do --根据进度添加坐标
        local head = self._panelBox:getChildByName("head" .. i)
        head:getChildByName("img_bg"):setVisible(true)
        head:getChildByName("img_icon"):setVisible(false)
        head:getChildByName("img_icon"):setVisible(false)
        head:getChildByName("Image_1"):setVisible(false)
        head:getChildByName("Panel_2"):removeAllChildren()
        head:getChildByName("Panel_battle"):removeAllChildren()
    end
end

function AncientCityBattleModule:showCheckPoint()
    self:updateDialog()
    local troop_info = self._curLayerInfoArray[uq.cache.ancient_city.city_id].Troop
    local troop_array = {}
    for k, v in pairs(troop_info) do
        table.insert(troop_array, v)
    end
    table.sort(troop_array, function(a, b)
        return a.ident < b.ident
    end)
    local npc_info = troop_array[uq.cache.ancient_city.npc_pos]
    if uq.cache.ancient_city.city_id == 7 then --密室
        uq.ModuleManager:getInstance():show(uq.ModuleManager.ANCIENT_CITY_CHECK_POINT, {npc_info = npc_info})
        return
    end
    local head = self._panelBox:getChildByName("head" .. uq.cache.ancient_city.city_id)
    head:getChildByName("img_bg"):setVisible(false)
    head:getChildByName("img_icon"):setVisible(true)
    head:getChildByName("Panel_2"):removeAllChildren()
    head:getChildByName("Panel_battle"):removeAllChildren()
    head:getChildByName("Image_1"):setVisible(true)
    local knife = uq.createPanelOnly('instance.AnimationKnife')
    head:getChildByName("Panel_battle"):addChild(knife)
    head:getChildByName("img_icon"):setTouchEnabled(true)
    knife:setScale(0.6)
    head:getChildByName("img_icon"):addClickEventListenerWithSound(function(sender)
        uq.ModuleManager:getInstance():show(uq.ModuleManager.ANCIENT_CITY_CHECK_POINT, {npc_info = npc_info})
    end)
end

function AncientCityBattleModule:updateBoxDialog()
    self._nameLabel:setHTMLText(string.format(StaticData['local_text']['ancient.battle.title'], self._curInfo.name, uq.cache.ancient_city.city_id - 1))
    for i = 1,uq.cache.ancient_city.city_id - 1,1 do --根据进度添加坐标
        local head = self._panelBox:getChildByName("head" .. i)
        head:getChildByName("img_bg"):setVisible(true)
        head:getChildByName("img_icon"):setVisible(false)
        head:getChildByName("Image_1"):setVisible(false)
        head:getChildByName("Panel_2"):removeAllChildren()
        head:getChildByName("Panel_battle"):removeAllChildren()
    end
end

function AncientCityBattleModule:showReward(reward)
    if uq.cache.ancient_city.city_id == 8 then --打完了，显示最终奖励
        uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_BOX_REWARD, {rewards = reward})
        self:updateRewardInfo()
        return
    end
    if uq.cache.ancient_city.city_id == 7 and tonumber(uq.cache.ancient_city.secret_info.exists) == 1 then --有密室
        for i = 1, 6, 1 do
            local head = self._panelBox:getChildByName("head" .. i)
            head:setVisible(false)
        end
        local head = self._panelBox:getChildByName("head7")
        local effect_node = uq.createPanelOnly('common.EffectNode')
        head:getChildByName("Panel_2"):removeAllChildren()
        head:getChildByName("adytum_img"):setVisible(true)
        head:getChildByName("adytum_img"):loadTexture("img/ancient_city/" .. self._curInfo.sevenFloorImage)
        head:getChildByName("action_img"):setVisible(true)
        head:getChildByName("action_img"):runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(0, -50)), cc.MoveBy:create(0.5, cc.p(0, 50)))))
        head:setVisible(true)
    end
    self:updateBoxDialog()
    uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_BOX_REWARD, {rewards = reward})
    self:updateRewardInfo()
end

function AncientCityBattleModule:initDialog()
    self._btnInspire:setPressedActionEnabled(true)
    self:initTableView()
    local panel_press = self._nodeYu:getChildByName("Panel_3")
    panel_press:setTouchEnabled(true)
    panel_press:addClickEventListenerWithSound(function(sender)
        panel_press:removeAllChildren()
        uq.ModuleManager:getInstance():show(uq.ModuleManager.GENRAL_SHOP_MODULE, {_sub_index = uq.config.constant.GENERAL_SHOP.JADE_SHOP})
    end)
    panel_press = self._nodeGold:getChildByName("Panel_3")
    panel_press:setTouchEnabled(true)
    panel_press:addClickEventListenerWithSound(function(sender)
        panel_press:removeAllChildren()
        uq.ModuleManager:getInstance():show(uq.ModuleManager.GENRAL_SHOP_MODULE, {_sub_index = uq.config.constant.GENERAL_SHOP.GOLD_SHOP})
    end)
    self._imgBg:setTexture("img/bg/" .. self._curInfo.mapImage)
    self._panelBox:removeAllChildren()
    local dotCoord_array = string.split(self._curInfo.dotCoord, ";")
    local node_head = cc.CSLoader:createNode("ancient_city/AncientCityHeadItem.csb")
    local index = 1
    local head
    for i = 1, 7, 1 do --根据进度添加坐标
        head = node_head:getChildByName("Panel_1"):clone()
        self._panelBox:addChild(head)
        local pos_array = string.split(dotCoord_array[index], ",")
        head:setPosition(cc.p(tonumber(pos_array[1]), tonumber(pos_array[2])))
        head.posy = tonumber(pos_array[2])
        head:getChildByName("img_bg"):setVisible(false)
        head:getChildByName("img_bg"):loadTexture("img/ancient_city/" .. self._curInfo.shatterImage)
        head:getChildByName("img_icon"):loadTexture("img/ancient_city/" .. self._curInfo.statueImage)
        head:setName("head" .. i)
        index = index + 1
        table.insert(self._itemArray, head)
    end
    --隐藏最后一个密室的图
    head:setVisible(false)
    head:getChildByName("img_icon"):setVisible(false)
    head:getChildByName("Panel_2"):setTouchEnabled(true)
    head:getChildByName("Panel_2"):setScale(1.0)
    head:getChildByName("Panel_2"):setContentSize(cc.size(387, 259))
    head:getChildByName("Panel_2"):addClickEventListenerWithSound(function(sender)
        uq.ModuleManager:getInstance():show(uq.ModuleManager.ANCIENT_CITY_BEFORE, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, close_open_action = true, ["type"] = 2})
    end)
    table.sort(self._itemArray, function(a, b)
        return a.posy > b.posy
    end)
    for k, v in ipairs(self._itemArray) do
        v:setLocalZOrder(k)
    end
end

function AncientCityBattleModule:initTableView()
    local size = self._panelTableView:getContentSize()
    self._tableView = cc.TableView:create(cc.size(size.width,size.height))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setAnchorPoint(cc.p(0,0))
    self._tableView:setDelegate()
    self._panelTableView:addChild(self._tableView)

    self._tableView:registerScriptHandler(handler(self,self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
end

function AncientCityBattleModule:cellSizeForTable(view, idx)
    return 100, 110
end

function AncientCityBattleModule:numberOfCellsInTableView(view)
    return #self._curTabInfoArray
end

function AncientCityBattleModule:tableCellTouched(view, cell,touch)

end

function AncientCityBattleModule:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx + 1
    if not cell then
        cell = cc.TableViewCell:new()
        local info = self._curTabInfoArray[index]
        local euqip_item = nil
        if info ~= nil then
            euqip_item = EquipItem:create({info = info})
            euqip_item:setScale(0.7)
            local width = euqip_item:getContentSize().width * 0.7
            euqip_item:setPosition(cc.p(width * 0.5, 50))
            cell:addChild(euqip_item,1)
            euqip_item:setTouchEnabled(true)
            euqip_item:addClickEventListenerWithSound(function(sender)
                local info = sender:getEquipInfo()
                uq.showItemTips(info)
            end)
            euqip_item:setName("item")
        end
    else
        local info = self._curTabInfoArray[index]
        local euqip_item = cell:getChildByName("item")
        if info ~= nil then
            euqip_item:setInfo(info)
            euqip_item:setTouchEnabled(true)
            euqip_item:addClickEventListenerWithSound(function(sender)
                local info = sender:getEquipInfo()
                uq.showItemTips(info)
            end)
        end
    end
    return cell
end

function AncientCityBattleModule:dispose()
    if self._topUI then
        self._topUI:dispose()
    end
    self._topUI = nil
    if self._jadeCdTimer then
        self._jadeCdTimer:dispose()
        self._jadeCdTimer = nil
    end
    if self._goldCdTimer then
        self._goldCdTimer:dispose()
        self._goldCdTimer = nil
    end
    self:removeProtocolData()
    AncientCityBattleModule.super.dispose(self)
end

return AncientCityBattleModule
