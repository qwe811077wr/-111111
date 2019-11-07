local ExtractResult = class("ExtractResult", require('app.modules.common.BaseViewWithHead'))
local EquipItem = require("app.modules.common.EquipItem")

ExtractResult.RESOURCE_FILENAME = "equip/EquipRxtractResult.csb"
ExtractResult.RESOURCE_BINDING = {
    ["Image_3"]                = {["varname"] = "_imgLeft"},
    ["Image_4"]                = {["varname"] = "_imgRight"},
    ["Node_3"]                 = {["varname"] = "_nodeReward"},
    ["Button_2"]               = {["varname"] = "_btnExtractAgain", ["events"] = {{["event"] = "touch",["method"] = "_onExtract"}}},
    ["Button_2_0"]             = {["varname"] = "_btnOk", ["events"] = {{["event"] = "touch",["method"] = "onBtnOk"}}},
    ["Node_12"]                = {["varname"] = "_nodeBool"},
    ["Text_34"]                = {["varname"] = "_txtBoolTips"},
    ["Node_14"]                = {["varname"] = "_nodeFree"},
    ["Node_15"]                = {["varname"] = "_nodeCoin"},
    ["Text_31"]                = {["varname"] = "_txtCoin"},
    ["Node_4_0"]               = {["varname"] = "_nodeOne"},
    ["Node_4"]                 = {["varname"] = "_nodeTen"},
    ["Node_4/Panel_3"]         = {["varname"] = "_panelTen"},
    ["Node_4_0/Panel_3"]       = {["varname"] = "_panelOne"},
    ["Node_4_0/Image_14"]      = {["varname"] = "_panelOneImg"},
    ["Node_4_0/Image_1"]       = {["varname"] = "_imgLight"},
    ["img_bg_adapt"]           = {["varname"] = "_imgBg", ["events"] = {{["event"] = "touch",["method"] = "onClickCenter"}}},
    ["Panel_4"]                = {["varname"] = "_panelBlack"},
    ["Node_1"]                 = {["varname"] = "_nodeLight"},
    ["Node_16"]                = {["varname"] = "_nodeEffect"},
    ["Node_5"]                 = {["varname"] = "_nodeCard"},
    ["Text_4"]                 = {["varname"] = "_btnJumpOver", ["events"] = {{["event"] = "touch",["method"] = "onClickJumpOver"}}},
    ["Image_5"]                = {["varname"] = "_imgItemBg"},
    ["Image_6"]                = {["varname"] = "_imgItemType"},
    ["Text_1"]                 = {["varname"] = "_txtName"},
    ["Image_7"]                = {["varname"] = "_imgItem"},
    ["Image_31"]               = {["varname"] = "_imgCoin"},
    ["Image_8"]                = {["varname"] = "_imgMengLong"},
    ["Image_10"]               = {["varname"] = "_imgCardLight"},
    ["Node_16_0"]              = {["varname"] = "_nodeEffect0"},
    ["Node_2"]                 = {["varname"] = "_nodeBgEffect"},
}
function ExtractResult:ctor(name, params)
    ExtractResult.super.ctor(self, name, params)
    self._data = params.data
    self._data.time = self._data.cd_time > 0 and self._data.cd_time + os.time() or 0
    uq.AnimationManager:getInstance():getEffect('CK_kapaichuxian', nil, nil, true)
    uq.AnimationManager:getInstance():getEffect('CK_texiao', nil, nil, true)
    uq.AnimationManager:getInstance():getEffect('CK_mengfeng', nil, nil, true)
end

function ExtractResult:init()
    self:centerView()
    self:parseView()
    self:adaptBgSize()
    self:addShowCoinGroup({{type = uq.config.constant.COST_RES_TYPE.MATERIAL, id = uq.config.constant.MATERIAL_TYPE.EQUIP_VOURCHER}, uq.config.constant.COST_RES_TYPE.GOLDEN})
    self:setTitle(uq.config.constant.MODULE_ID.EQUIP_POOL)
    self:setBaseBgVisible(false)
    self._doingAction = true
    self._index = 1
    self._delta = 1 / 12
    self._imgLeft:setVisible(false)
    self._imgRight:setVisible(false)
    self:runOpenAction()
    self._arrItems = {}
    services:addEventListener(services.EVENT_NAMES.ON_CONSUME_RES_CHANGE, handler(self, self.updateCoinState), "on_refrsh_res" .. tostring(self))
    services:addEventListener(services.EVENT_NAMES.ON_BIND_EQUIP, handler(self, self._onEquipBindAction), '_onEquipBindAction' .. tostring(self))
end

function ExtractResult:_onEquipBindAction(msg)
    if not self._selectEquipItem then
        return
    end
    local info = self._selectEquipItem:getEquipInfo()
    if info.db_id ~= msg.data.eqid then
        return
    end
    self._selectEquipItem:refreshLockedImgState()
end

function ExtractResult:onClickCenter(event)
    if event.name ~= "ended" or self._doingAction or self._nodeReward:isVisible() then
        return
    end
    self._panelBlack:stopAllActions()
    self._nodeBgEffect:removeAllChildren()
    self._nodeLight:stopAllActions()
    self._nodeCard:setVisible(false)
    self._nodeEffect:removeAllChildren()
    self._nodeEffect0:removeAllChildren()
    if self._data.is_ten == 0 or self._index > 10 then
        self:showEndResult()
    else
        self:runEquipAction()
    end
end

function ExtractResult:onBtnOk(event)
    if event.name ~= "ended" then
        return
    end
    self:disposeSelf()
end

function ExtractResult:_onExtract(event)
    if event.name ~= "ended" then
        return
    end
    local xml_info = StaticData['item_appoint'].ItemAppoint[self._data.pool_id]

    if (self._data.is_ten == 0 and xml_info.freeCD > 0 and self._data.time - os.time() <= 0) or self._coinState then
        network:sendPacket(Protocol.C_2_S_APPOINT_EQUIPMENT, {pool_id = self._data.pool_id, is_ten = self._data.is_ten})
    else
        local cur_num = uq.cache.role:getResNum(tonumber(self._coinStr[1]), tonumber(self._coinStr[3]))
        local data = StaticData['item_appoint'].BuyCard[1]
        local info = {
            --num = tonumber(self._coinStr[2]) - cur_num,
            item_info = data.buyOneWhat,
            coin_info = data.buyOneCard,
            discount_info = data.buyTenCard
        }
        uq.ModuleManager:getInstance():show(uq.ModuleManager.EQUIP_BOUGHT_VOUCHERS, {data = info})
    end
end

function ExtractResult:onClickJumpOver(event)
    if event.name ~= "ended" then
        return
    end
    self._nodeBgEffect:removeAllChildren()
    self._panelBlack:stopAllActions()
    self._nodeLight:stopAllActions()
    self._btnJumpOver:setVisible(false)
    self._nodeCard:setVisible(false)
    self._nodeEffect:removeAllChildren()
    self._nodeEffect0:removeAllChildren()
    self._nodeLight:removeAllChildren()
    self:showEndResult()
end

function ExtractResult:runOpenAction()
    self._imgLeft:setPositionX(-600)
    self._imgRight:setPositionX(600)
    self._imgLeft:setVisible(true)
    self._imgRight:setVisible(true)
    self._imgLeft:runAction(cc.MoveBy:create(self._delta * 6, cc.p(600, 0)))
    self._imgRight:runAction(cc.MoveBy:create(self._delta * 6, cc.p(-600, 0)))

    self._nodeLight:runAction(cc.Sequence:create(cc.DelayTime:create(self._delta * 5), cc.CallFunc:create(function()
        uq:addEffectByNode(self._nodeLight, 900015, 1, true, nil, nil, 2)
        self._panelBlack:runAction(cc.Sequence:create(cc.FadeTo:create(self._delta * 4, 255), cc.FadeTo:create(self._delta * 10, 0)))
    end)))

    self._imgBg:runAction(cc.Sequence:create(cc.DelayTime:create(self._delta * 12), cc.CallFunc:create(function()
        local scale_x= display.width / CC_DESIGN_RESOLUTION.width, display.height / CC_DESIGN_RESOLUTION.height
        self._imgBg:setAnchorPoint(cc.p(0.5, 0))
        self._imgBg:setPosition(cc.p(0, -CC_DESIGN_RESOLUTION.height / 2 * scale_x))
        self._imgBg:setScale(scale_x * 1.5)
        self._imgBg:setVisible(true)
        self._imgBg:runAction(cc.Sequence:create(cc.ScaleTo:create(self._delta * 3, 1.05 * scale_x), cc.ScaleTo:create(self._delta * 5, 1 * scale_x)))
        self:setBaseBgVisible(true)
        self._imgLeft:runAction(cc.Sequence:create(cc.MoveBy:create(self._delta * 2, cc.p(-467, 0)), cc.MoveBy:create(self._delta * 6, cc.p(-133, 0))))
        self._imgRight:runAction(cc.Sequence:create(cc.MoveBy:create(self._delta * 2, cc.p(467, 0)), cc.MoveBy:create(self._delta * 6, cc.p(133, 0))))
    end)))

    self._nodeCard:runAction(cc.Sequence:create(cc.DelayTime:create(self._delta * 16), cc.CallFunc:create(function()
        self._btnJumpOver:setVisible(true)
        self:runEquipAction()
    end)))
end

function ExtractResult:setData(data)
    self._data = data
    self._data.time = self._data.cd_time > 0 and self._data.cd_time + os.time() or 0
    uq.TimerProxy:removeTimer("update_timer" .. tostring(self))
    self._nodeReward:setVisible(false)
    self._btnJumpOver:setVisible(true)
    self._index = 1
    self:runEquipAction()
end

function ExtractResult:runEquipAction()
    self._doingAction = true
    self._nodeEffect:removeAllChildren()
    self._nodeEffect0:removeAllChildren()
    uq:addEffectByNode(self._nodeEffect0, 900016, 1, true, nil, nil, 2)
    uq:addEffectByNode(self._nodeEffect, 900014, 1, true, nil, nil, 2)
    local info = StaticData['items'][self._data.items[self._index].equip_id]
    if not info then
        return
    end
    local item_quality_info = StaticData['types'].ItemQuality[1].Type[tonumber(info.qualityType)]
    if item_quality_info and item_quality_info.txLightTx then
        uq.AnimationManager:getInstance():getEffect(StaticData['effect'][item_quality_info.txLightTx].tx, nil, nil, true)
    end
    self._panelBlack:runAction(cc.Sequence:create(cc.DelayTime:create(self._delta), cc.FadeTo:create(self._delta * 7, 0.8 * 255),
    cc.DelayTime:create(self._delta * 37), cc.CallFunc:create(function()
        self._panelBlack:runAction(cc.FadeTo:create(self._delta * 3, 0))
        if item_quality_info and item_quality_info.txLightTx then
            uq:addEffectByNode(self._nodeBgEffect, item_quality_info.txLightTx, -1, true)
        end
        self._imgCardLight:setOpacity(255)
        self._imgCardLight:runAction(cc.FadeTo:create(self._delta * 30, 0))
        self:refreshPage()
        self._index = self._index + 1
        self._doingAction = false
    end)))
end

function ExtractResult:showEndResult()
    self._btnJumpOver:setVisible(false)
    self._nodeCard:setVisible(false)
    self._nodeReward:setScale(0)
    self._nodeReward:setVisible(true)
    self._nodeReward:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.2), cc.ScaleTo:create(0.1, 1)))
    local state = self._data.is_ten == 0 and self._data.cd_time > 0
    local xml_info = StaticData['item_appoint'].ItemAppoint[self._data.pool_id]
    self._nodeBool:setVisible(state)
    self._nodeBool:stopAllActions()
    self._nodeBool:setPositionY(0)
    if state then
        local action = cc.Sequence:create(cc.MoveTo:create(1, cc.p(0, 10)), cc.MoveTo:create(1, cc.p(0, 0)))
        self._nodeBool:runAction(cc.RepeatForever:create(action))
    end
    local free_state = xml_info.freeCD > 0 and self._data.is_ten == 0 and self._data.cd_time <= 0
    self._nodeFree:setVisible(free_state)
    self._nodeCoin:setVisible(not free_state)
    if state then
        local time = self._data.cd_time
        local hours, minutes, seconds = uq.getTime(time)
        self._txtBoolTips:setString(string.format(StaticData['local_text']['left.free.extract.time'], hours, minutes, seconds))
        uq.TimerProxy:addTimer("update_timer" .. tostring(self), function()
            time = time - 1
            local hours, minutes, seconds = uq.getTime(time)
            self._txtBoolTips:setString(string.format(StaticData['local_text']['left.free.extract.time'], hours, minutes, seconds))
            if time <= 0 then
                uq.TimerProxy:removeTimer("update_timer" .. tostring(self))
                self._nodeBool:setVisible(false)
                self._nodeCoin:setVisible(false)
                self._nodeFree:setVisible(true)
            end
        end, 1, -1)
    end

    self._coinStr = self._data.is_ten == 0 and string.split(xml_info.costOne, ';') or string.split(xml_info.costTen, ';')
    self._priceInfo = StaticData.getCostInfo(tonumber(self._coinStr[1]), tonumber(self._coinStr[3]))
    self._imgCoin:loadTexture("img/common/ui/" .. self._priceInfo.miniIcon)
    self:updateCoinState()

    self._nodeOne:setVisible(self._data.is_ten == 0)
    self._nodeTen:setVisible(self._data.is_ten == 1)
    if self._data.is_ten == 1 then
        self._btnExtractAgain:setTitleText(string.format(StaticData['local_text']['pool.extract.chance'], 10))
        for k, v in ipairs(self._data.items) do
            local info = uq.cache.equipment:_getEquipInfoByDBId(v.equip_db_id)
            info.id = info.temp_id
            info.type = uq.config.constant.COST_RES_TYPE.EQUIP
            if not self._arrItems[k] then
                local panel = self._panelTen:clone()
                panel:setVisible(true)
                local item = EquipItem:create({info = info})
                item:setName("item")
                item:setScale(0.8)
                local size = panel:getContentSize()
                item:setPosition(cc.p(size.width / 2, size.height / 2))
                item:setTouchEnabled(true)
                item:addClickEventListener(function(sender)
                    self._selectEquipItem = sender
                    local info = sender:getEquipInfo()
                    uq.showItemTips(info)
                end)
                panel:setPosition(cc.p((math.ceil(k % 5.5) - 1) * 125, -math.floor((k - 1) / 5) * 130 + 10))
                panel:addChild(item, 0)
                table.insert(self._arrItems, panel)
                self._nodeTen:addChild(panel)
            else
                local item = self._arrItems[k]:getChildByName("item")
                item:setInfo(info)
            end
            local img = self._arrItems[k]:getChildByName("Image_14")
            img:setVisible(v.state == 1)
            img:setLocalZOrder(1)
            img:stopAllActions()
            img:setPositionY(87.5)
            if v.state == 1 then
                local action = cc.Sequence:create(cc.MoveTo:create(1, cc.p(47, 97.5)), cc.CallFunc:create(function()
                    img:setPositionY(87.5)
                end))
                img:runAction(cc.RepeatForever:create(action))
            end
            local bg = self._arrItems[k]:getChildByName("Image_1_0")
            local info = StaticData['items'][v.equip_id]
            if not info then
                return
            end
            local item_quality_info = StaticData['types'].ItemQuality[1].Type[tonumber(info.qualityType)]
            local state = item_quality_info.iconLight and item_quality_info.iconLight ~= ""
            bg:setVisible(state)
            if state then
                bg:loadTexture("img/equip/" .. item_quality_info.iconLight)
            end
        end
    else
        self._btnExtractAgain:setTitleText(string.format(StaticData['local_text']['pool.extract.chance'], 1))
        local item = self._panelOne:getChildByName("item")
        local info = uq.cache.equipment:_getEquipInfoByDBId(self._data.items[1].equip_db_id)
        info.id = info.temp_id
        info.type = uq.config.constant.COST_RES_TYPE.EQUIP
        if not item then
            item =  EquipItem:create({info = info})
            local size = self._panelOne:getContentSize()
            item:setScale(1.2)
            item:setPosition(cc.p(size.width / 2, size.height / 2))
            item:setName("item")
            item:setTouchEnabled(true)
            item:addClickEventListener(function(sender)
                self._selectEquipItem = sender
                local info = sender:getEquipInfo()
                uq.showItemTips(info)
            end)
            self._panelOne:addChild(item)
        else
            item:setInfo(info)
        end
        self._panelOneImg:setVisible(self._data.items[1].state == 1)
        self._panelOneImg:stopAllActions()
        self._panelOneImg:setPositionY(60)
        if self._data.items[1].state == 1 then
            local action = cc.Sequence:create(cc.MoveTo:create(1, cc.p(0, 70)), cc.CallFunc:create(function()
                self._panelOneImg:setPositionY(60)
            end))
            self._panelOneImg:runAction(cc.RepeatForever:create(action))
        end
        local info = StaticData['items'][self._data.items[1].equip_id]
        if not info then
            return
        end
        local item_quality_info = StaticData['types'].ItemQuality[1].Type[tonumber(info.qualityType)]
        local state = item_quality_info.iconLight and item_quality_info.iconLight ~= ""
        self._imgLight:setVisible(state)
        if state then
            self._imgLight:loadTexture("img/equip/" .. item_quality_info.iconLight)
        end
    end
end

function ExtractResult:updateCoinState()
    self._coinState = uq.cache.role:checkRes(tonumber(self._coinStr[1]), tonumber(self._coinStr[2]), tonumber(self._coinStr[3]))
    local color = self._coinState and "#ffffff" or "#f10000"
    self._txtCoin:setHTMLText(string.format("%s<font color='%s'> X%s</font>", self._priceInfo.name, color, tonumber(self._coinStr[2])))
end

function ExtractResult:refreshPage()
    local info = StaticData['items'][self._data.items[self._index].equip_id]
    if not info then
        return
    end
    self._txtName:setString(info.name)
    self._imgItem:loadTexture("img/common/item/" .. info.icon)
    local item_quality_info = StaticData['types'].ItemQuality[1].Type[tonumber(info.qualityType)]
    if item_quality_info then
        self._txtName:setTextColor(uq.parseColor("#" .. item_quality_info.color))
        self._imgItemBg:loadTexture("img/equip/" .. item_quality_info.itemBg)
        self._imgItemType:loadTexture("img/equip/" .. item_quality_info.itemStamp)
    end
    self._nodeCard:setVisible(true)
end

function ExtractResult:dispose()
    uq.TimerProxy:removeTimer("update_timer" .. tostring(self))
    services:removeEventListenersByTag("on_refrsh_res" .. tostring(self))
    services:removeEventListenersByTag("_onEquipBindAction" ..tostring(self))
    ExtractResult.super.dispose(self)
end

return ExtractResult