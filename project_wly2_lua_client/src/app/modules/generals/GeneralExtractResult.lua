local GeneralExtractResult = class("GeneralExtractResult", require('app.modules.common.BaseViewWithHead'))
local EquipItem = require("app.modules.common.EquipItem")

GeneralExtractResult.RESOURCE_FILENAME = "generals/GeneralExtractResult.csb"
GeneralExtractResult.RESOURCE_BINDING = {
    ["img_bg_adapt"]                                                                = {["varname"] = "_nodeBgAction"},
    ["Node_button"]                                                                 = {["varname"] = "_nodeBtns"},
    ["Node_button/Panel_appoint_left_bg/Button_appoint"]                            = {["varname"] = "_btnResultLeftAppoint", ["events"] = {{["event"] = "touch",["method"] = "_onResultAppointLeft"}}},
    ["Node_button/Panel_appoint_right_bg"]                                          = {["varname"] = "_panelResultRightAppoint"},
    ["Node_button/Panel_appoint_right_bg/Button_appoint"]                           = {["varname"] = "_btnResultRightAppoint", ["events"] = {{["event"] = "touch",["method"] = "_onResultAppointRight"}}},
    ["Panel_one"]                                                                   = {["varname"] = "_panelOne"},
    ["Panel_ten"]                                                                   = {["varname"] = "_panelTen"},
    ["Particle_2"]                                                                  = {["varname"] = "_particle"},
}
function GeneralExtractResult:ctor(name, params)
    GeneralExtractResult.super.ctor(self, name, params)
    self._data = params.data
    self._data.time = self._data.cd_time > 0 and self._data.cd_time + os.time() or 0
    uq.AnimationManager:getInstance():getEffect('lizibaozha', nil, nil, true)
    uq.AnimationManager:getInstance():getEffect('juqi', nil, nil, true)
end

function GeneralExtractResult:init()
    self:centerView()
    self:parseView()
    self._particle:setPosVar(cc.p(display.size.width / 2, display.size.height / 2))
    self:adaptBgSize()
    self:addShowCoinGroup({{type = uq.config.constant.COST_RES_TYPE.MATERIAL, id = uq.config.constant.MATERIAL_TYPE.GENENRAL_VOURCHER}, uq.config.constant.COST_RES_TYPE.GOLDEN})
    self:setRuleId(uq.config.constant.MODULE_RULE_ID.GENERAL_POOL)
    self:setTitle(uq.config.constant.MODULE_ID.TAVERN_VIEW)

    self._poolData = uq.cache.generals:GetGeneralPoolInfo()
    self:refreshCostPanel()
    self:runResultAction()
    network:addEventListener(Protocol.S_2_C_BUY_APPOINT_TIMES, handler(self, self._onBuyItem), "on_buy_item" .. tostring(self))
end

function GeneralExtractResult:setData(data)
    self._data = data
    self._data.time = self._data.cd_time > 0 and self._data.cd_time + os.time() or 0
    self._poolData = uq.cache.generals:GetGeneralPoolInfo()
    self:refreshCostPanel()
    self:runResultAction()
end

function GeneralExtractResult:_onBuyItem(msg)
    self:refreshCostPanel()
    uq.fadeInfo(StaticData['local_text']['ancient.city.add.num.des3'])
end

function GeneralExtractResult:refreshCostPanel()
    if not self._poolData or not self._poolData[self._data.pool_key] then
        return
    end
    local cur_data = self._poolData[self._data.pool_key]
    if self._data.is_ten == 1 then
        self:setCostInfo(self._panelResultRightAppoint, cur_data.xml.costTen, cur_data.xml.costTenPrice, false, self._data.is_ten == 1)
    else
        self:setCostInfo(self._panelResultRightAppoint, cur_data.xml.costOne, cur_data.xml.costOnePrice, false, self._data.is_ten == 1)
        self:refreshTimerFree()
    end
end

function GeneralExtractResult:refreshTimerFree()
    uq.TimerProxy:removeTimer("update_timer_free" .. tostring(self))
    if not self._poolData or not self._poolData[self._data.pool_key] then
        return
    end
    --处理无免费情况
    local cur_data = self._poolData[self._data.pool_key]
    if cur_data.xml.freeCD == 0 then
        self._panelResultRightAppoint:getChildByName('Text_free_time'):setVisible(false)
        return
    end
    --处理免费情况
    local free_state = cur_data.cd_time <= 0 or cur_data.time - os.time() < 0
    self._panelResultRightAppoint:getChildByName('Text_free_time'):setVisible(not free_state)
    self:setCostInfo(self._panelResultRightAppoint, cur_data.xml.costOne, cur_data.xml.costOnePrice, free_state, self._data.is_ten == 1)
    if free_state then
        return
    end
    --处理免费在cd中情况
    self:setFreeCDTxt()
    uq.TimerProxy:addTimer("update_timer_free" .. tostring(self), handler(self, self.setFreeCDTxt), 1, -1)
end

function GeneralExtractResult:setFreeCDTxt()
    if not self._poolData or not self._poolData[self._data.pool_key] then
        return
    end
    local cur_data_free = self._poolData[self._data.pool_key].time - os.time()
    if cur_data_free < 0 then
        self:refreshTimerFree()
        return
    end
    local hours, minutes, seconds, day = uq.getTime(cur_data_free)
    local str_left_time = string.format("%02d", hours) .. ":" .. string.format("%02d", minutes) .. ":" .. string.format("%02d", seconds)
    self._panelResultRightAppoint:getChildByName('Text_free_time'):setHTMLText(string.format(StaticData['local_text']['general.pool.free.time'], str_left_time))
end

function GeneralExtractResult:setCostInfo(parent, cost_data, pre_cost_data, is_free, is_ten)
    local txt_cost_real = parent:getChildByName('Text_cost_real')
    local txt_cost_previous = parent:getChildByName('Text_cost_previous')
    local img_cost = parent:getChildByName('Image_cost')
    local img_discount = parent:getChildByName('Image_discount')
    local txt_discount = parent:getChildByName('Text_discount')
    local img_abandon = parent:getChildByName('Image_abandon')
    local txt_appoint = parent:getChildByName('Text_appoint')
    if is_ten then
        txt_appoint:setString(StaticData['local_text']['general.pool.choose.ten'])
    else
        txt_appoint:setString(StaticData['local_text']['general.pool.choose.one'])
    end
    txt_cost_previous:setVisible(false)
    img_discount:setVisible(false)
    txt_discount:setVisible(false)
    img_abandon:setVisible(false)
    img_cost:setVisible(not is_free or is_ten)
    local cost_info_list = string.split(cost_data, ';')
    local cost_info = StaticData.getCostInfo(tonumber(cost_info_list[1]), tonumber(cost_info_list[3]))
    local miniIcon = cost_info and cost_info.miniIcon or "03_0002.png"
    img_cost:loadTexture('img/common/ui/' .. miniIcon)
    if is_free and not is_ten then
        txt_cost_real:setString(StaticData['local_text']['ancient.city.shop.refresh.free'])
    else
        txt_cost_real:setString(cost_info_list[2])
    end

    --初始化位置
    local parent_size = parent:getContentSize()
    txt_cost_real:setPositionX(parent_size.width / 2)
    local img_cost_size = img_cost:getContentSize()
    local txt_cost_real_size = txt_cost_real:getContentSize()
    img_cost:setPositionX((parent_size.width - txt_cost_real_size.width - img_cost_size.width) / 2 - 20)
    self:checkPrice(txt_cost_real, cost_info_list, is_free)
    if is_free then
        return
    end
    --处理减价的情况
    local has_pre_cost = not(pre_cost_data == nil or pre_cost_data == "")
    if not has_pre_cost then
        return
    end
    txt_cost_previous:setVisible(has_pre_cost)
    img_discount:setVisible(has_pre_cost)
    txt_discount:setVisible(has_pre_cost)
    img_abandon:setVisible(has_pre_cost)
    txt_cost_real:setPositionX((parent_size.width + txt_cost_real_size.width + img_cost_size.width) / 2 + 20)
    img_abandon:setContentSize(cc.size(txt_cost_real_size.width + 10, img_abandon:getContentSize().height))
    local pre_cost_info_list = string.split(pre_cost_data, ';')
    txt_cost_previous:setString(pre_cost_info_list[2])
    local discount = tonumber(cost_info_list[2]) / tonumber(pre_cost_info_list[2]) * 10
    local discount_str = string.format("%d%s", discount, StaticData['local_text']['activity.discount'])
    txt_discount:setString(discount_str)
end

function GeneralExtractResult:checkPrice(txt_node, price_info_list, is_free)
    local color_str = "#FAF3EB"
    txt_node.is_enough = true
    if not is_free then
        local is_enough = uq.cache.role:checkRes(tonumber(price_info_list[1]),tonumber(price_info_list[2]) ,tonumber(price_info_list[3]))
        if not is_enough then
            txt_node.is_enough = false
            color_str = "#f10000"
        end
    end
    txt_node:setTextColor(uq.parseColor(color_str))
end

function GeneralExtractResult:runResultAction()
    self._panelOne:setVisible(self._data.is_ten ~= 1)
    self._panelTen:setVisible(self._data.is_ten == 1)
    if self._data.is_ten == 1 then
        self:runPanelTenAction()
    else
        self:runPanelOneAction()
    end
end

function GeneralExtractResult:runPanelOneAction()
    self._canTouch = false
    for i = 1, self._data.count do
        self:createItems(self._panelOne, i)
        self:setItemsVisible(self._panelOne, i, false, false)
    end
    local time = 1 / 12
    local move_card_bg = self._panelOne:getChildByName('Image_card_back1'):clone()
    self._panelOne:getChildByName('Image_card_back1'):getParent():addChild(move_card_bg)
    local scale_card_bg = self._panelOne:getChildByName('Image_card_back2'):clone()
    self._panelOne:getChildByName('Image_card_back2'):getParent():addChild(scale_card_bg)
    local node_action_flip = self._panelOne:getChildByName('Node_action_flip')
    local move_step_one = cc.MoveTo:create(time * 3, cc.p(590, 386))
    local move_step_two = cc.MoveTo:create(time * 1, cc.p(668, 386))
    local scale_step_one = cc.ScaleTo:create(time * 2, 2)
    local scale_step_two = cc.ScaleTo:create(time * 2, 1)
    local delay_step_one = cc.DelayTime:create(time * 15)
    local delay_step_two = cc.DelayTime:create(time * 5)
    local rotate_step = cc.RotateTo:create(time * 4, 0)
    local fade_in_step = cc.FadeIn:create(time * 4)
    local move_sequence = cc.Sequence:create(move_step_one, move_step_two)
    local scale_sequence = cc.Sequence:create(scale_step_one, scale_step_two)
    local show_item = cc.CallFunc:create(function()
            for i = 1, self._data.count do
                self:setItemsVisible(self._panelOne, i, true, true)
            end
            self._canTouch = true
            self:setNewGeneralShowData(1)
            if tonumber(self._data.rws[1].type) == uq.config.constant.COST_RES_TYPE.GENERALS or tonumber(self._data.rws[1].type) == uq.config.constant.COST_RES_TYPE.TRANSFORMED_SPIRIT then
                uq.refreshNextNewGeneralsShow()
            end
            move_card_bg:removeFromParent()
    end)
    local show_btn = cc.CallFunc:create(function()
            self._nodeBtns:setVisible(true)
    end)
    local show_flip = cc.CallFunc:create(function()
            move_card_bg:setVisible(false)
            scale_card_bg:removeFromParent()
            node_action_flip:removeAllChildren()
            uq.playSoundByID(88)
            uq:addEffectByNode(node_action_flip, 900180, 1, true, nil, nil, 1)
    end)
    self._nodeBtns:setVisible(false)
    move_card_bg:setVisible(true)
    move_card_bg:runAction(cc.Sequence:create(cc.Spawn:create(move_sequence, scale_sequence, rotate_step, fade_in_step), show_btn, delay_step_one, show_flip, delay_step_two, show_item))
    local scale_bg_scale_step = cc.ScaleTo:create(time * 2, 1.9)
    local scale_bg_fade_step = cc.FadeOut:create(time * 2)
    local delay_step = cc.DelayTime:create(time * 5)
    local show_card_bg = cc.CallFunc:create(function()
            scale_card_bg:setVisible(true)
            scale_card_bg:setOpacity(255)
    end)
    scale_card_bg:setVisible(false)
    scale_card_bg:runAction(cc.Sequence:create(delay_step, show_card_bg, cc.Spawn:create(scale_bg_scale_step, scale_bg_fade_step)))
end

function GeneralExtractResult:runPanelTenAction()
    local time = 1 / 12
    self._canTouch = false
    self._nodeBtns:setVisible(false)
    for i = 1, self._data.count do
        self:createItems(self._panelTen, i)
        self:setItemsVisible(self._panelTen, i, false, false)
        self:setTenMidCardBackAction(i, i == self._data.count)
    end
    for i = 1, 5 do
        self:setTenCardBackAction(self._panelTen:getChildByName('Image_card_back' .. i), (i % 2) == 0)
    end
    local node_mid = self._panelTen:getChildByName('Node_mid')
    local delay_step = cc.DelayTime:create(time * 5)
    local show_juqi = cc.CallFunc:create(function()
        node_mid:removeAllChildren()
        uq.playSoundByID(87)
        uq:addEffectByNode(node_mid, 900179, 1, true, nil, nil, 2)
    end)
    node_mid:runAction(cc.Sequence:create(delay_step, show_juqi))
    local delay_step_twenty = cc.DelayTime:create(time * 20)
    local show_lizi = cc.CallFunc:create(function()
        node_mid:removeAllChildren()
        uq.playSoundByID(112)
        uq:addEffectByNode(node_mid, 900181, 1, true, nil, nil, 2)
    end)
    node_mid:runAction(cc.Sequence:create(delay_step_twenty, show_lizi))

    local light_clone = self._panelTen:getChildByName('Image_light'):clone()
    self._panelTen:getChildByName('Image_light'):getParent():getChildByName('Panel_copy'):addChild(light_clone)
    local show_light = cc.CallFunc:create(function()
        light_clone:setVisible(true)
    end)
    local remove_light = cc.CallFunc:create(function()
        light_clone:removeFromParent()
    end)
    local light_scale_one = cc.ScaleTo:create(time * 3, 2)
    local light_fade = cc.FadeOut:create(time * 8)
    local light_scale_two = cc.ScaleTo:create(time * 8, 2.5)
    light_clone:runAction(cc.Sequence:create(delay_step_twenty, show_light, light_scale_one, cc.Spawn:create(light_fade, light_scale_two), remove_light))
end

function GeneralExtractResult:setTenCardBackAction(origin_node, action_type)
    local time = 1 / 12
    local clone_node = origin_node:clone()
    origin_node:getParent():getChildByName('Panel_copy'):addChild(clone_node)
    local move_step = cc.MoveTo:create(time * 5, cc.p(668, 346))
    local scale_step_one = cc.ScaleTo:create(time * 3, 2.4)
    local scale_step_two = cc.ScaleTo:create(time * 2, 1)
    local scale_step = cc.Sequence:create(scale_step_one, scale_step_two)
    local rotate_step = cc.RotateTo:create(time * 5, 360)
    local delay_step = cc.DelayTime:create(time * 1)
    local fade_in_step = cc.FadeIn:create(time * 5)
    local show_node = cc.CallFunc:create(function()
            clone_node:setVisible(true)
            clone_node:setOpacity(0)
    end)
    local hide_node = cc.CallFunc:create(function()
            clone_node:setVisible(false)
            clone_node:removeFromParent()
    end)
    if action_type then
        clone_node:runAction(cc.Sequence:create(delay_step, show_node, cc.Spawn:create(move_step, scale_step, rotate_step, fade_in_step), hide_node))
    else
        clone_node:runAction(cc.Sequence:create(show_node, cc.Spawn:create(move_step, scale_step, rotate_step, fade_in_step), delay_step, hide_node))
    end
end

function GeneralExtractResult:setTenMidCardBackAction(index, need_show_btn)
    local time = 1 / 12
    local origin_node = self._panelTen:getChildByName('Image_card_back_mid')
    local clone_node = origin_node:clone()
    origin_node:getParent():getChildByName('Panel_copy'):addChild(clone_node)
    clone_node:setTag(1000 + index)
    local scale_num = self:getItemsScale(index)
    local target_node = self._panelTen:getChildByName('Node_item_' .. index)
    local flip_effect = nil
    local delay_step_one = cc.DelayTime:create(time * 19)
    local move_step = cc.MoveTo:create(time * 5, cc.p(target_node:getPosition()))
    local scale_step_one = cc.ScaleTo:create(time * 8, scale_num)
    local delay_step_two = cc.DelayTime:create(time * 1)
    local delay_step_three = cc.DelayTime:create(time * (17 + (index - 1) * 3))
    local delay_step_four = cc.DelayTime:create(time * 3)
    local scale_step_two = cc.ScaleTo:create(time * 2, scale_num / 3, scale_num)
    local scale_step_three = cc.ScaleTo:create(time * 2, scale_num)
    local show_node = cc.CallFunc:create(function()
            clone_node:setVisible(true)
    end)
    local show_item = cc.CallFunc:create(function()
            self:setItemsVisible(self._panelTen, index, true, true)
            self._canTouch = true
            local general_info_type = tonumber(self._data.rws[index].type)
            self:setNewGeneralShowData(index)
            if general_info_type == uq.config.constant.COST_RES_TYPE.GENERALS or general_info_type == uq.config.constant.COST_RES_TYPE.TRANSFORMED_SPIRIT then
                uq.refreshNextNewGeneralsShow()
                local parent = self._panelTen:getChildByName('Panel_copy')
                for i = 1, self._data.count do
                    local node = parent:getChildByTag(1000 + i)
                    if node then
                        node:pause()
                    end
                end
            end
            if flip_effect then
                flip_effect:remove()
            end
            clone_node:removeFromParent()
    end)
    local show_btn = cc.CallFunc:create(function()
            self._nodeBtns:setVisible(true)
    end)
    local show_flip = cc.CallFunc:create(function()
            self:setItemsVisible(self._panelTen, index, false, false)
            uq.playSoundByID(88)
            flip_effect = uq:addEffectByNode(target_node, 900180, 1, true, nil, nil, 1)
            clone_node:setVisible(false)
    end)
    local show_light = cc.CallFunc:create(function()
            self:setItemsVisible(self._panelTen, index, false, true)
    end)
    if need_show_btn then
        clone_node:runAction(cc.Sequence:create(delay_step_one, show_node, cc.Spawn:create(move_step, scale_step_one), show_light, delay_step_three, show_flip, delay_step_four, show_btn, show_item))
    else
        clone_node:runAction(cc.Sequence:create(delay_step_one, show_node, cc.Spawn:create(move_step, scale_step_one), show_light, delay_step_three, show_flip, delay_step_four, show_item))
    end
end

function GeneralExtractResult:setNewGeneralShowData(index)
    local general_info = {}
    general_info.type = tonumber(self._data.rws[index].type)
    general_info.id = tonumber(self._data.rws[index].paraml)
    general_info.num = tonumber(self._data.rws[index].num)
    if general_info.type == uq.config.constant.COST_RES_TYPE.GENERALS then
        general_info.id = general_info.id / 10
    end
    if general_info.type == uq.config.constant.COST_RES_TYPE.GENERALS or general_info.type == uq.config.constant.COST_RES_TYPE.TRANSFORMED_SPIRIT then
        uq.cache.generals:setNewGeneralsFunc(math.floor(general_info.id), handler(self, self.continueActions), true)
    end
end

function GeneralExtractResult:getItemsScale(index)
    if index == 1 or index == 6 then
        return 1
    elseif index == 2 or index == 5 or index == 7 or index == 10 then
        return 0.8
    else
        return 0.7
    end
end

function GeneralExtractResult:continueActions()
    local parent = self._panelTen:getChildByName('Panel_copy')
    for i = 1, self._data.count do
        local node = parent:getChildByTag(1000 + i)
        if node then
            node:resume()
        end
    end
end

function GeneralExtractResult:setItemsVisible(parent, index, is_show, is_show_light)
    local euqip_item = parent:getChildByName('Node_item_' .. index):getChildByTag(1000)
    if euqip_item then
        euqip_item:setVisible(is_show)
    end
    local light_circle = parent:getChildByName('Node_item_' .. index):getChildByName('Image_light_circle')
    if light_circle then
        light_circle:setVisible(is_show)
    end
    local light_bg = parent:getChildByName('Node_item_' .. index):getChildByName('Image_light_bg')
    if light_bg then
        light_bg:setVisible(is_show_light)
    end
end

function GeneralExtractResult:createItems(parent, index)
    local info = {}
    info.type = tonumber(self._data.rws[index].type)
    info.id = tonumber(self._data.rws[index].paraml)
    info.num = tonumber(self._data.rws[index].num)
    if info.type == uq.config.constant.COST_RES_TYPE.TRANSFORMED_SPIRIT then
        info.type = uq.config.constant.COST_RES_TYPE.SPIRIT
    end
    local euqip_item = nil
    if parent:getChildByName('Node_item_' .. index):getChildByTag(1000) then
        euqip_item = parent:getChildByName('Node_item_' .. index):getChildByTag(1000)
        euqip_item:setInfo(info)
    else
        euqip_item = EquipItem:create({info = info})
        parent:getChildByName('Node_item_' .. index):addChild(euqip_item, 1)
        euqip_item:setTag(1000)
    end
    euqip_item:enableEvent(nil, function(equip_info)
        uq.showItemTips(equip_info)
    end)
end

function GeneralExtractResult:_onResultAppointLeft(event)
    if event.name ~= "ended" or not self._canTouch then
        return
    end
    self:disposeSelf()
end

function GeneralExtractResult:_onResultAppointRight(event)
    if event.name ~= "ended" or not self._canTouch then
        return
    end
    local is_enough = event.target:getParent():getChildByName('Text_cost_real').is_enough
    self:onExtract(self._data.is_ten, is_enough)
end

function GeneralExtractResult:onExtract(tag, is_enough)
    local price_info = self._poolData[self._data.pool_key]
    if (tag == 0 and price_info.xml.freeCD > 0 and price_info.time - os.time() <= 0) or is_enough then
        self._canTouch = false
        network:sendPacket(Protocol.C_2_S_APPOINT_GENERAL, {pool_id = price_info.id, is_ten = tag})
    else
        local data = StaticData['general_appoint'].BuyCard[1]
        local info = {
            item_info = data.buyOneWhat,
            coin_info = data.buyOneCard,
            discount_info = data.buyTenCard
        }
        uq.ModuleManager:getInstance():show(uq.ModuleManager.EQUIP_BOUGHT_VOUCHERS, {data = info})
    end
end

function GeneralExtractResult:dispose()
    uq.TimerProxy:removeTimer("update_timer_free" .. tostring(self))
    services:removeEventListenersByTag("on_refrsh_res" .. tostring(self))
    services:removeEventListenersByTag("_onEquipBindAction" ..tostring(self))
    network:removeEventListenerByTag("on_buy_item" .. tostring(self))
    GeneralExtractResult.super.dispose(self)
end

return GeneralExtractResult