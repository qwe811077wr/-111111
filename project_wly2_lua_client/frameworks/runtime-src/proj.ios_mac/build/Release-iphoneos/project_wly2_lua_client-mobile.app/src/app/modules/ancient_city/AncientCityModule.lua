local AncientCityModule = class("AncientCityModule", require("app.base.ModuleBase"))
local AncientCityItem = require("app.modules.ancient_city.AncientCityItem")
local EquipItem = require("app.modules.common.EquipItem")

AncientCityModule.RESOURCE_FILENAME = "ancient_city/AncientCityMain.csb"

AncientCityModule.RESOURCE_BINDING  = {
    ["Node_2"]                      ={["varname"] = "_nodeBase"},
    ["Node_1"]                      ={["varname"] = "_nodeLeft"},
    ["img_detail"]                  ={["varname"] = "_imgDetail"},
    ["Panel_tab"]                   ={["varname"] = "_panelTab"},
    ["Panel_tabview"]               ={["varname"] = "_panelTableView"},
    ["label_num"]                   ={["varname"] = "_numLabel"},
    ["ScrollView_1"]                ={["varname"] = "_scrollView1"},
    ["label_probability"]           ={["varname"] = "_probabilityLabel"},
    ["label_saodang"]               ={["varname"] = "_saodangLabel"},
    ["Panel_saodang_cost"]          ={["varname"] = "_panelSaoDangDes"},
    ["dec_txt"]                     ={["varname"] = "_txtDec"},
    ["title_img"]                   ={["varname"] = "_imgTitle"},
    ["down_1_img"]                  ={["varname"] = "_imgDown"},
    ["label_name_0"]                ={["varname"] = "_txtName"},
    ["up_1_img"]                    ={["varname"] = "_imgUp"},
    ["cost_war_txt"]                ={["varname"] = "_txtWarCost"},
    ["star_node"]                   ={["varname"] = "_nodeStar"},
    ["cost_spweed_txt"]             ={["varname"] = "_txtSweepCost"},
    ["sweep_btn"]                   ={["varname"] = "_btnSweep",["events"] = {{["event"] = "touch",["method"] = "_onBtnSweep"}}},
    ["btn_add"]                     ={["varname"] = "_btnAdd",["events"] = {{["event"] = "touch",["method"] = "_onBtnAdd"}}},
    ["btn_reward"]                  ={["varname"] = "_btnReward",["events"] = {{["event"] = "touch",["method"] = "_onBtnReward"}}},
    ["btn_shop"]                    ={["varname"] = "_btnShop",["events"] = {{["event"] = "touch",["method"] = "_onBtnShop"}}},
    ["btn_come"]                    ={["varname"] = "_btnComeIn",["events"] = {{["event"] = "touch",["method"] = "_onBtnComeIn"}}},
    ["Node_5"]                      ={["varname"] = "_nodeLeftBottom"},
    ["Node_4"]                      ={["varname"] = "_nodeRightBottom"},
}

function AncientCityModule:ctor(name, args)
    AncientCityModule.super.ctor(self, name, args)
    self._tableView = nil
    self._cellArray = {}
    self._curTableViewInfo = nil
    self._curTabInfo = {}
    self._xml = StaticData['ancient_info'][1] or {}
    self._sweepCost = self:getSweepCost()
end

function AncientCityModule:init()
    self:parseView()
    self:centerView()
    self:adaptBgSize()
    self:adaptNode()
    local top_ui = uq.ui.CommonHeaderUI:create()
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.MILITORY_ORDER, true))
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.MONEY, true))
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.GOLDEN, true))
    top_ui:setRuleId(uq.config.constant.MODULE_RULE_ID.ANCIENT_CITY)
    top_ui:setTitle(uq.config.constant.MODULE_ID.ANCIENT_CITY)
    self._topUI = top_ui
    self._view:addChild(top_ui:getNode())
    local pos_x,pos_y = self._scrollView1:getPosition()
    self._itemViewPosx1 = pos_x
    self._itemViewPosy1 = pos_y
    self._isSweep = false
    self._lastMusic = uq.getLastMusic()
    self:initDialog()
    self:initProtocolData()
    self:playAction()
    self:refreshSweepBtn()
    uq.playSoundByID(104)
    self._scrollView1:setScrollBarEnabled(false)
    self:showAction()
end

function AncientCityModule:playAction()
    self:playTopAction()
    self:playShowAction()
end

function AncientCityModule:playTopAction()
    self._topUI:getNode():stopAllActions()
    self._topUI:getNode():setPositionY(display.height / 2 + 50)
    self._topUI:getNode():runAction(cc.MoveTo:create(0.2, cc.p(-CC_DESIGN_RESOLUTION.width / 2, display.height / 2)))
end

function AncientCityModule:playShowAction()
    self._panelTab:stopAllActions()
    self._panelTab:setOpacity(0)
    self._panelTab:runAction(cc.FadeIn:create(0.2))
end

function AncientCityModule:_onBtnAdd(event)
    if event.name ~= "ended" then
        return
    end
    local info = uq.cache.ancient_city:getPassCityInfo()
    if info.extra_times >= 5 then
        uq.fadeInfo(StaticData["local_text"]["ancient.not.times"])
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ANCIENT_CITY_BUY_NUM_MODULE, {})
end

function AncientCityModule:_onBtnShop(event)
    if event.name ~= "ended" then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.GENRAL_SHOP_MODULE, {_sub_index = 1})
end

function AncientCityModule:_onBtnComeIn(event)
    if event.name ~= "ended" then
        return
    end
    if not self._isSweep then
        self:goBattle()
        return
    end
    self:goSweep()
end

function AncientCityModule:goBattle()
    if self._leftFightNum <= 0 then
        self:_onBtnAdd({name = "ended"})
        return
    end
    if self._curTableViewInfo == nil then
        return
    end
    if not uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.MILITORY_ORDER, 6) then
        uq.fadeInfo(string.format(StaticData["local_text"]["label.res.tips.less"], StaticData.getCostInfo(uq.config.constant.COST_RES_TYPE.MILITORY_ORDER).name))
        return
    end
    uq.cache.ancient_city.city_id = 1
    uq.cache.ancient_city.add_att = 0
    uq.cache.ancient_city.add_def = 0
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ANCIENT_CITY_BATTLE_MODULE, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, info = self._curTableViewInfo})
end

function AncientCityModule:goSweep()
    if self._leftFightNum <= 0 then
        self:_onBtnAdd({name = "ended"})
        return
    end
    if self._curTableViewInfo == nil then
        return
    end
    if not uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.MILITORY_ORDER, 6) then
        uq.fadeInfo(string.format(StaticData["local_text"]["label.res.tips.less"], StaticData.getCostInfo(uq.config.constant.COST_RES_TYPE.MILITORY_ORDER).name))
        return
    end
    local this = self
    if not uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN, 5) then
        local function confirm()
            uq.runCmd('show_add_golden')
        end
        local des = string.format(StaticData['local_text']['ancient.city.sweep.gold.des'], "<img img/common/ui/03_0003.png>")
        local data = {
            content = des,
            confirm_callback = confirm
        }
        uq.addConfirmBox(data)
        return
    end
    local function confirm()
        uq.cache.ancient_city.city_id = 1
        uq.ModuleManager:getInstance():show(uq.ModuleManager.ANCIENT_CITY_SWEEP, {info = this._curTableViewInfo, name = self._curTableViewInfo.name})
    end
    local des = string.format(StaticData['local_text']['ancient.city.saodang.des'], "<img img/common/ui/03_0003.png>", self._sweepCost)
    local data = {
        content = des,
        confirm_callback = confirm
    }
    uq.addConfirmBox(data,uq.config.constant.CONFIRM_TYPE.ANCIENT_CITY_SWEEP)
end

function AncientCityModule:_onBtnSweep(event)
    if event.name ~= "ended" then
        return
    end
    self._isSweep = not self._isSweep
    self:refreshSweepBtn()
end

function AncientCityModule:_onBtnReward(event)
    if event.name ~= "ended" then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ANCIENT_CITY_DAILY_REWARD_MODULE, {})
end

function AncientCityModule:initProtocolData()
    services:addEventListener(services.EVENT_NAMES.ON_ANCIENT_CITY_REWARD_RED, handler(self, self._onAncientCityRewardRed), '_onAncientCityRewardRedByStrategy')
    services:addEventListener(services.EVENT_NAMES.ON_ANCIENT_CITY_ENTER, handler(self, self._onAncientCityEnter), '_onAncientCityEnterByStrategy')
    services:addEventListener(services.EVENT_NAMES.ON_ANCIENT_CITY_UPDATE_FIGHT_NUM, handler(self, self._onAncientCityUpdateFightNum), '_onAncientCityUpdateFightNumByStrategy')
    self._eventChange = services.EVENT_NAMES.ON_CONSUME_RES_CHANGE .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_CONSUME_RES_CHANGE, handler(self, self.updateInfo), self._eventChange)
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_ENTER, {})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ANCIENT_CITY_OPEN})
end

function AncientCityModule:_onAncientCityRewardRed()
    uq.showRedStatus(self._btnReward, uq.cache.hint_status.status[uq.cache.hint_status.RED_TYPE.ANCIENT],
        -self._btnReward:getContentSize().width * 0.5 + 10, self._btnReward:getContentSize().height * 0.5 - 10)
end

function AncientCityModule:_onAncientCityUpdateFightNum()
    local info = uq.cache.ancient_city:getPassCityInfo()
    info.used_times = info.used_times + 1
    self:updateNum()
end

function AncientCityModule:_onAncientCityEnter()
    local info = uq.cache.ancient_city:getPassCityInfo()
    self._curTabInfo = {}
    local index = 0
    local pre_pass = true  --上一关是否通关
    for k, v in ipairs(StaticData['ancients']) do
        v.data = nil
        if v.level <= uq.cache.role:level() then
            v.data = {}
            v.data.id = v.ident
            v.data.layer = 0
            v.data.first_pass = 0
        end
        for k2, v2 in pairs(info.city) do
            if v.ident == v2.id then
                v.data = v2
                break
            end
        end
        if v.data then
            v.data.is_pass = pre_pass
        end
        if v.data and v.data.first_pass > 0 then
            pre_pass = true
        else
            pre_pass = false
        end
        table.insert(self._curTabInfo, v)
    end
    for k, v in ipairs(self._curTabInfo) do
        if v.data == nil then
            index = k - 1
            break
        elseif v.data.first_pass == 0  then
            index = k
            break
        end
    end
    if index == 0 then
        index = #self._curTabInfo
    end
    self._curTableViewInfo = self._curTabInfo[index]
    self._tableView:reloadData()
    local offset = self._tableView:getContentOffset();
    if index > 2 then
        local new_offset = 0
        new_offset = (index - 2) * 108
        offset.y = new_offset + offset.y
        if offset.y > 0 then
            offset.y = 0
        end
        self._tableView:setContentOffset(offset);
    end
    self:updateNum()
    if not self._isfinishAction then
        self._isfinishAction = true
        for i, v in ipairs(self._cellArray) do
            v:showAction()
        end
    end
end

function AncientCityModule:removeProtocolData()
    services:removeEventListenersByTag("_onAncientCityUpdateFightNumByStrategy")
    services:removeEventListenersByTag("_onAncientCityEnterByStrategy")
    services:removeEventListenersByTag("_onAncientCityRewardRedByStrategy")
    services:removeEventListenersByTag(self._eventChange)
end

function AncientCityModule:updateNum()
    local info = uq.cache.ancient_city:getPassCityInfo()
    local ancient_info = StaticData['ancient_info'][1]
    self._leftFightNum = ancient_info.freeTimes + info.extra_times - info.used_times
    self._numLabel:setString(self._leftFightNum)
    local ShaderEffect = uq.ShaderEffect
    if (info.extra_times >= (ancient_info.totalTimes - ancient_info.freeTimes)) and (self._leftFightNum == 0) then
        self._btnComeIn:setEnabled(false)
        ShaderEffect:addGrayButton(self._btnComeIn)
    else
        self._btnComeIn:setEnabled(true)
        ShaderEffect:removeGrayButton(self._btnComeIn)
    end
end

function AncientCityModule:updateInfo()
    if self._curTableViewInfo == nil or self._curTableViewInfo.data == nil then
        return
    end
    self:updatePreview()
    self._probabilityLabel:setString(self._curTableViewInfo.sevenFloorRate * 100 .."%")
    local ShaderEffect = uq.ShaderEffect
    if self._curTableViewInfo.data.first_pass == 0 then
        self._panelSaoDangDes:setVisible(false)
        self._saodangLabel:setVisible(true)
        self._isSweep = false
        self:refreshSweepBtn()
    else
        self._panelSaoDangDes:setVisible(true)
        self._saodangLabel:setVisible(false)
    end
    self._txtDec:setTextAreaSize(cc.size(330, 0))
    self._txtDec:setString(self._curTableViewInfo.desc)
    self._imgTitle:loadTexture("img/ancient_city/" .. self._curTableViewInfo.nameImg)
    local num = self._curTableViewInfo.data.layer or 0
    for i = 1, 6 do
        self._nodeStar:getChildByName("star_" .. i .. "_img"):setVisible(i <= num)
    end
    local num = uq.cache.role:getResNum(uq.config.constant.COST_RES_TYPE.MILITORY_ORDER, 0)
    local war_str = num >= 6 and StaticData['local_text']["ancient.card.cost2"] or StaticData['local_text']["ancient.card.cost1"]
    self._txtWarCost:setHTMLText(string.format(war_str, num, 6))
    local str = self._sweepCost ~= 0 and tostring(self._sweepCost) or StaticData['local_text']["ancient.city.shop.refresh.free"]
    local is_enough = uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN, self._sweepCost)
    local color = is_enough and "#FFFFFF"or "F10000"
    self._txtSweepCost:setString(str)
    self._txtSweepCost:setTextColor(uq.parseColor(color))
end

function AncientCityModule:getSweepCost()
    if not self._xml.sweepCost or self._xml.sweepCost == "" or not self._xml.sweepFreeLv or self._xml.sweepFreeLv <= uq.cache.role.master_lvl then
        return 0
    end
    local base_cost = uq.RewardType.new(self._xml.sweepCost)
    return base_cost:num()
end

function AncientCityModule:refreshSweepBtn()
    self._imgDown:setVisible(not self._isSweep)
    self._imgUp:setVisible(self._isSweep)
    local str = self._isSweep and "label.common.sweep" or "ancient.come.on"
    self._txtName:setString(StaticData['local_text'][str])
end

function AncientCityModule:updatePreview()
    self._scrollView1:removeAllChildren()
    local reward_array = uq.RewardType:parseRewardsAndFilterDrop(self._curTableViewInfo.showReward1)
    local item_size = self._scrollView1:getContentSize()
    local index = #reward_array
    local inner_width = index * 120 * 0.8
    self._scrollView1:setInnerContainerSize(cc.size(inner_width, item_size.height))
    if inner_width < item_size.width then
        local newPosX = (item_size.width - inner_width) * 0.5 + self._itemViewPosx1
        self._scrollView1:setPosition(cc.p(newPosX, self._itemViewPosy1))
        self._scrollView1:setTouchEnabled(false)
    else
        self._scrollView1:setTouchEnabled(true)
        self._scrollView1:setPosition(cc.p(self._itemViewPosx1, self._itemViewPosy1))
    end
    local item_posX = 60
    for _, t in ipairs(reward_array) do
        local euqip_item = EquipItem:create({info = t:toEquipWidget()})
        euqip_item:setPosition(cc.p(item_posX * 0.8, item_size.height * 0.5))
        euqip_item:setTouchEnabled(true)
        euqip_item:setScale(0.7)
        euqip_item:addClickEventListenerWithSound(function(sender)
            local info = sender:getEquipInfo()
            uq.showItemTips(info)
        end)
        self._scrollView1:addChild(euqip_item)
        item_posX = item_posX + 120
    end
end

function AncientCityModule:initDialog()
    self._btnAdd:setPressedActionEnabled(true)
    self._btnComeIn:setPressedActionEnabled(true)
    self._btnShop:setPressedActionEnabled(true)
    self._btnReward:setPressedActionEnabled(true)
    self._imgDetail:setTouchEnabled(true)
    self._imgDetail:setVisible(false)
    self._imgDetail:addClickEventListenerWithSound(function(sender)
        -- local info = StaticData['rule'][301]
        -- uq.ModuleManager:getInstance():show(uq.ModuleManager.ANCIENT_CITY_RULE,{info = info})
    end)
    self:_onAncientCityRewardRed()
    self:initTableView()
end

function AncientCityModule:initTableView()
    local size = self._panelTableView:getContentSize()
    self._tableView = cc.TableView:create(cc.size(size.width,size.height))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
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

function AncientCityModule:cellSizeForTable(view, idx)
    return 460, 108
end

function AncientCityModule:numberOfCellsInTableView(view)
    return #self._curTabInfo
end

function AncientCityModule:tableCellTouched(view, cell, touch)
    local touch_point = touch:getLocation()
    local index = cell:getIdx() + 1
    local item = cell:getChildByName("item")
    if item == nil then
        return
    end
    local pos = item:convertToNodeSpace(touch_point)
    local rect = cc.rect(0, 0, item:getContentSize().width, item:getContentSize().height)
    if cc.rectContainsPoint(rect, pos) then
        if not self._curTabInfo[index] then
            return
        end
        if self._curTableViewInfo and self._curTableViewInfo.ident == self._curTabInfo[index].ident then
            return
        end
        if self._curTabInfo[index].data == nil then
            return
        end
        if self._curTabInfo[index - 1] ~= nil and self._curTabInfo[index - 1].data.first_pass == 0 then
            uq.fadeInfo(string.format(StaticData["local_text"]["ancient.city.battle.des"], self._curTableViewInfo.name))
            return
        end
        for _, v in ipairs(self._cellArray) do
            v:setSelectImgVisible(false)
        end
        self._curTableViewInfo = self._curTabInfo[index]
        item:setSelectImgVisible(true)
        self:updateInfo()
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
        uq.intoAction(self._nodeBase)
    end
end

function AncientCityModule:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx + 1
    if not cell then
        cell = cc.TableViewCell:new()
        local info = self._curTabInfo[index]
        local width = 0
        local euqip_item = AncientCityItem:create({info = info})
        width = euqip_item:getContentSize().width
        euqip_item:setPosition(cc.p(euqip_item:getContentSize().width / 2, euqip_item:getContentSize().height / 2))
        cell:addChild(euqip_item)
        euqip_item:setName("item")
        table.insert(self._cellArray, euqip_item)
        if self._curTableViewInfo and self._curTableViewInfo.ident == info.ident then
            euqip_item:setSelectImgVisible(true)
            self:updateInfo()
        end
    else
        local info = self._curTabInfo[index]
        local euqip_item = cell:getChildByName("item")
        euqip_item:setInfo(info)
        if self._curTableViewInfo and self._curTableViewInfo.ident == info.ident then
            euqip_item:setSelectImgVisible(true)
            self:updateInfo()
        end
    end
    return cell
end

function AncientCityModule:showAction()
    uq.intoAction(self._nodeLeft, cc.p(-uq.config.constant.MOVE_DISTANCE, 0))
    uq.intoAction(self._nodeBase)
    uq.intoAction(self._btnShop, cc.p(0, -uq.config.constant.MOVE_DISTANCE))
    uq.intoAction(self._btnReward, cc.p(0, -uq.config.constant.MOVE_DISTANCE))
end

function AncientCityModule:dispose()
    if self._topUI then
        self._topUI:dispose()
    end
    uq.playBackGroundMusic(self._lastMusic)
    self._topUI = nil
    uq.cache.ancient_city.isEnterBattleView = false
    self:removeProtocolData()
    AncientCityModule.super.dispose(self)
end

return AncientCityModule
