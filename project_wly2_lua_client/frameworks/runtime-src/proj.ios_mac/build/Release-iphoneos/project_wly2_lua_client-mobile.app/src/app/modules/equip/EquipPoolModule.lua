local EquipPoolModule = class("EquipPoolModule", require('app.modules.common.BaseViewWithHead'))

EquipPoolModule.RESOURCE_FILENAME = "equip/EquipPool.csb"
EquipPoolModule.RESOURCE_BINDING = {
    ["Image_24"]                 = {["varname"] = "_imgBg"},
    ["Text_30"]                  = {["varname"] = "_txtTips"},
    ["Text_38"]                  = {["varname"] = "_txtTime"},
    ["Image_38"]                 = {["varname"] = "_imgType"},
    ["Button_10"]                = {["varname"] = "_btnExtractOne", ["events"] = {{["event"] = "touch",["method"] = "_onExtractOnce"}}},
    ["Button_11"]                = {["varname"] = "_btnExtractMore", ["events"] = {{["event"] = "touch",["method"] = "_onExtractMore"}}},
    ["Button_12"]                = {["varname"] = "_btnIllustration", ["events"] = {{["event"] = "touch",["method"] = "_onOpenIllustration"}}},
    ["Image_31"]                 = {["varname"] = "_imgIconMore"},
    ["Text_31"]                  = {["varname"] = "_txtPriceMore"},
    ["Text_31_1"]                = {["varname"] = "_txtPriceMoreNum"},
    ["Node_14"]                  = {["varname"] = "_nodeFree"},
    ["Node_13"]                  = {["varname"] = "_nodePriceOne"},
    ["Image_31_0"]               = {["varname"] = "_imgPriceOne"},
    ["Text_31_0"]                = {["varname"] = "_txtPriceOne"},
    ["Text_31_0_1"]              = {["varname"] = "_txtPriceOneNUm"},
    ["Node_15"]                  = {["varname"] = "_nodeBool"},
    ["Text_34"]                  = {["varname"] = "_txtBoolTip"},
    ["Node_18"]                  = {["varname"] = "_nodeBtns"},
    ["Panel_29"]                 = {["varname"] = "_panelBtn"},
    ["Image_25"]                 = {["varname"] = "_imgTitle"},
    ["Panel_28"]                 = {["varname"] = "_panelTipsBg"},
    ["Image_29"]                 = {["varname"] = "_ecureBg"},
    ['Node_16']                  = {["varname"] = "_nodeLeftBottom"},
    ["Image_28"]                 = {["varname"] = "_imgSecure"},
    ["Button_1"]                 = {["varname"] = "_btnOpenPreview", ["events"] = {{["event"] = "touch",["method"] = "_onOpenPreview"}}},
}
function EquipPoolModule:ctor(name, params)
    EquipPoolModule.super.ctor(self, name, params)
end

function EquipPoolModule:init()
    self._curTabIndex = 1
    self._tagArray = {}
    self:centerView()
    self:parseView()
    self:adaptBgSize()
    self:adaptNode()
    self._priceState = {}
    self:addShowCoinGroup({{type = uq.config.constant.COST_RES_TYPE.MATERIAL, id = uq.config.constant.MATERIAL_TYPE.EQUIP_VOURCHER}, uq.config.constant.COST_RES_TYPE.GOLDEN})
    self:setTitle(uq.config.constant.MODULE_ID.EQUIP_POOL)
    self:initTab()

    services:addEventListener(services.EVENT_NAMES.ON_UPDATE_EQUIP_POOL_REN, handler(self, self._updateRed), "on_update_red" .. tostring(self))
    services:addEventListener(services.EVENT_NAMES.ON_LOAD_EQUIP_POOL_INFO, handler(self, self.initTab), "on_update_pool" .. tostring(self))
    services:addEventListener(services.EVENT_NAMES.ON_CONSUME_RES_CHANGE, handler(self, self.updatePriceState), "on_refrsh_res" .. tostring(self))
    services:addEventListener(services.EVENT_NAMES.ON_EQUIP_EXTRACT_RESULT, handler(self, self._onExtractResult), "on_extract_result" .. tostring(self))
    network:addEventListener(Protocol.S_2_C_BUY_EQUIPMENT_VOCHERS, handler(self, self._onBuyItem), "on_buy_item" .. tostring(self))
end

function EquipPoolModule:_onBuyItem(msg)
    uq.fadeInfo(StaticData['local_text']['ancient.city.add.num.des3'])
end

function EquipPoolModule:initTab()
    local all_data = uq.cache.equipment:GetAllPoolInfo()
    self._allInfo = {}
    for k, v in pairs(all_data) do
        local server_time = uq.cache.server_data:getServerTime()
        if v.open_time == 0 or (v.open_time < server_time and v.close_time > server_time) then
            table.insert(self._allInfo, v)
        end
    end

    table.sort(self._allInfo, function(a, b)
        return a.xml.openTime > b.xml.openTime
    end)

    self._nodeBtns:removeAllChildren()
    uq.TimerProxy:removeTimer("update_timer" .. tostring(self))
    self._tabArray = {}
    self._textArray = {}
    self._redArray = {}
    self._addTimer = false
    for k, v in ipairs(self._allInfo) do
        local btn = self._panelBtn:clone()
        btn:setVisible(true)
        btn:setTag(k)
        table.insert(self._tabArray, btn)
        local size = btn:getContentSize()
        btn:setPosition(cc.p(10, -(k - 1) * (size.height + 10)))
        self._nodeBtns:addChild(btn)
        local check_box = btn:getChildByName("CheckBox_1")
        local title = btn:getChildByName("Text_35")
        local time_text = btn:getChildByName("Text_36")
        table.insert(self._textArray, time_text)
        local red = btn:getChildByName("Image_6")
        self._redArray[v.id] = red
        title:setString(v.xml.name)
        if v.xml.openTime <= 0 then
            time_text:setString(StaticData['local_text']['long.time.to.open'])
        else
            local time = v.close_time - uq.cache.server_data:getServerTime()
            local hours, minutes, seconds, day = uq.getTime(time)
            if day > 0 then
                time_text:setString(string.format(StaticData['local_text']['left.pool.open.day'], day))
            else
                time_text:setString(string.format(StaticData['local_text']['left.pool.open.time'], hours, minutes, seconds))
            end
            self._addTimer = true
        end
        check_box:addEventListener(function(sender, eventType)
            if eventType == 1 then
                return
            end
            local tag = sender:getParent():getTag()
            self:_onTabChanged(tag)
        end)
    end
    self:_onTabChanged(self._curTabIndex)
    if self._addTimer then
        uq.TimerProxy:addTimer("update_timer" .. tostring(self), handler(self, self.updateRigthBtnTimer), 1, -1)
    end

    self:_updateRed()
end

function EquipPoolModule:_onExtractResult(msg)
    local data = msg.data
    local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.EQUIP_EXTRACT_RESULT)
    if panel then
        panel:setData(data)
    else
        uq.ModuleManager:getInstance():show(uq.ModuleManager.EQUIP_EXTRACT_RESULT, {data = data})
    end
    self:refreshPage()
end

function EquipPoolModule:updateRigthBtnTimer()
    for k, v in ipairs(self._allInfo) do
        if v.xml.openTime > 0 then
            local time = v.close_time - uq.cache.server_data:getServerTime()
            local hours, minutes, seconds, day = uq.getTime(time)
            if day > 0 then
                self._textArray[k]:setString(string.format(StaticData['local_text']['left.pool.open.day'], day))
            else
                self._textArray[k]:setString(string.format(StaticData['local_text']['left.pool.open.time'], hours, minutes, seconds))
            end
        end
    end
end

function EquipPoolModule:_onOpenPreview(evt)
    if evt.name ~= "ended" then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.EQUIP_POOL_PREVIEW_MODULE, {pool_id = self._allInfo[self._curTabIndex].id})
end

function EquipPoolModule:_onTabChanged(tag)
    self._curTabIndex = tag
    for k, v in ipairs(self._tabArray) do
        local check_box = v:getChildByName("CheckBox_1")
        local title = v:getChildByName("Text_35")
        local time = v:getChildByName("Text_36")
        check_box:setSelected(k == tag)
        check_box:setEnabled(k ~= tag)
        if k == tag then
            title:setTextColor(uq.parseColor("#8f5a16"))
            time:setTextColor(uq.parseColor("#8f5a16"))
        else
            title:setTextColor(uq.parseColor("#24211c"))
            time:setTextColor(uq.parseColor("#24211c"))
        end
    end
    self:refreshPage()
end

function EquipPoolModule:_updateRed()
    local data = uq.cache.equipment._equipPoolRed
    for k, v in pairs(self._redArray) do
        self._redArray[k]:setVisible(data[k])
    end
end

function EquipPoolModule:refreshPage()
    local data = self._allInfo[self._curTabIndex]
    local state = data.cd_time <= 0 or data.time - os.time() < 0
    local could_free_state = data.xml.freeCD > 0
    self._nodePriceOne:setVisible(not state or not could_free_state)
    self._nodeFree:setVisible(state and could_free_state)
    self._nodeBool:setVisible(not state)
    self._nodeBool:stopAllActions()
    self._nodeBool:setPositionY(0)
    if not state then
        local action = cc.Sequence:create(cc.MoveTo:create(1, cc.p(0, 5)), cc.MoveTo:create(1, cc.p(0, 0)))
        self._nodeBool:runAction(cc.RepeatForever:create(action))
    end
    self._txtTime:setString(data.secure)
    if data.secure == 0 then
        self._imgSecure:loadTexture("img/equip/s04_00240_0.png")
    else
        self._imgSecure:loadTexture("img/equip/s04_00240.png")
    end
    local tip_state = data.xml.content and data.xml.content ~= ""
    self._panelTipsBg:setVisible(tip_state)
    self._txtTips:setVisible(tip_state)
    self._ecureBg:setVisible(tip_state)
    if tip_state then
        self._txtTips:setString(data.xml.content)
    end

    local ecure_state = data.xml.secureAppointId > 0
    self._imgType:setVisible(ecure_state)
    self._txtTime:setVisible(data.secure ~= 0 and ecure_state)
    if ecure_state then
        self._imgType:loadTexture("img/equip/" .. data.xml.secureTextImg)
    end
    self._imgTitle:loadTexture("img/equip/" .. data.xml.titleImg)
    self._imgBg:loadTexture("img/equip/" .. data.xml.bgImg)

    uq.TimerProxy:removeTimer("update_cd_time" .. tostring(self))
    if not state then
        local hours, minutes, seconds = uq.getTime(data.time - os.time())
        self._txtBoolTip:setString(string.format(StaticData['local_text']['left.free.extract.time'], hours, minutes, seconds))
        uq.TimerProxy:addTimer("update_cd_time" .. tostring(self), function()
            local hours, minutes, seconds = uq.getTime(data.time - os.time())
            self._txtBoolTip:setString(string.format(StaticData['local_text']['left.free.extract.time'], hours, minutes, seconds))
        end, 1, -1)
    end

    local price_one = string.split(data.xml.costOne, ';')
    local price_one_info = StaticData.getCostInfo(tonumber(price_one[1]), tonumber(price_one[3]))
    self._imgPriceOne:loadTexture("img/common/ui/" .. price_one_info.miniIcon)
    self._txtPriceOne:setString(price_one_info.name)
    self._txtPriceOneNUm:setString("X" .. tonumber(price_one[2]))

    local price_ten = string.split(data.xml.costTen, ';')
    local price_ten_info = StaticData.getCostInfo(tonumber(price_ten[1]), tonumber(price_ten[3]))
    self._imgIconMore:loadTexture("img/common/ui/" .. price_ten_info.miniIcon)
    self._txtPriceMore:setString(price_ten_info.name)
    self._txtPriceMoreNum:setString("X" .. tonumber(price_ten[2]))
    self._priceInfo = {price_one, price_ten}
    self._priceText = {self._txtPriceOneNUm, self._txtPriceMoreNum}
    self:updatePriceState()
end

function EquipPoolModule:updatePriceState()
    for k, v in ipairs(self._priceInfo) do
        self._priceState[k] = uq.cache.role:checkRes(tonumber(v[1]),tonumber(v[2]) ,tonumber(v[3]))
        if self._priceState[k] then
            self._priceText[k]:setTextColor(uq.parseColor("#ffffff"))
        else
            self._priceText[k]:setTextColor(uq.parseColor("#f10000"))
        end
    end
end

function EquipPoolModule:_onOpenIllustration(event)
    if event.name ~= "ended" then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.EQUIP_HANDBOOK_MODULE, {})
    network:sendPacket(Protocol.C_2_S_LOAD_LOG_EQUIPMENT, {})
end

function EquipPoolModule:onExtract(tag)
    local price_str = self._priceInfo[tag + 1]
    local price_info = self._allInfo[self._curTabIndex]
    if (tag == 0 and price_info.xml.freeCD > 0 and price_info.time - os.time() <= 0) or self._priceState[tag + 1] then
        network:sendPacket(Protocol.C_2_S_APPOINT_EQUIPMENT, {pool_id = price_info.id, is_ten = tag})
    else
        local cur_num = uq.cache.role:getResNum(tonumber(price_str[1]), tonumber(price_str[3]))
        local data = StaticData['item_appoint'].BuyCard[1]
        local info = {
            --num = tonumber(price_str[2]) - cur_num,
            item_info = data.buyOneWhat,
            coin_info = data.buyOneCard,
            discount_info = data.buyTenCard
        }
        uq.ModuleManager:getInstance():show(uq.ModuleManager.EQUIP_BOUGHT_VOUCHERS, {data = info})
    end
end

function EquipPoolModule:_onExtractOnce(event)
    if event.name ~= "ended" then
        return
    end
    self:onExtract(0)
end

function EquipPoolModule:_onExtractMore(event)
    if event.name ~= "ended" then
        return
    end
    self:onExtract(1)
end

function EquipPoolModule:dispose()
    uq.TimerProxy:removeTimer("update_timer" .. tostring(self))
    uq.TimerProxy:removeTimer("update_cd_time" .. tostring(self))
    services:removeEventListenersByTag("on_update_red" .. tostring(self))
    services:removeEventListenersByTag("on_update_pool" .. tostring(self))
    services:removeEventListenersByTag("on_refrsh_res" .. tostring(self))
    services:removeEventListenersByTag("on_extract_result" .. tostring(self))
    network:removeEventListenerByTag("on_buy_item" .. tostring(self))
    EquipPoolModule.super.dispose(self)
end

return EquipPoolModule