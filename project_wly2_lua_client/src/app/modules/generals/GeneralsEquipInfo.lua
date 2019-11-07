local GeneralsEquipInfo = class("GeneralsEquipInfo", require("app.base.PopupBase"))
local EquipItem = require("app.modules.common.EquipItem")

GeneralsEquipInfo.RESOURCE_FILENAME = "generals/GeneralsEquipInfo.csb"

GeneralsEquipInfo.RESOURCE_BINDING  = {
    ["panel_strength/btn_replace"]                     ={["varname"] = "_btnReplace",["events"] = {{["event"] = "touch",["method"] = "onBtnReplace",["sound_id"] = 0}}},
    ["panel_strength/btn_unload"]                      ={["varname"] = "_btnUnload",["events"] = {{["event"] = "touch",["method"] = "onUnload",["sound_id"] = 50}}},
    ["panel_strength/Panel_3"]                         ={["varname"] = "_panelItem"},
    ["panel_strength/Node_13/label_name"]              ={["varname"] = "_nameLabel"},
    ["Node_27"]                                        ={["varname"] = "_nodeItems"},
    ["panel_btn"]                                      ={["varname"] = "_panelTab"},
    ["CheckBox_6"]                                     ={["varname"] = "_checkBox"},
    ["Button_8"]                                       ={["varname"] = "_btnshowSuitInfo",["events"] = {{["event"] = "touch", ["method"] = "_onShowSuitInfo",["sound_id"] = 0}}},
    ["Node_13"]                                        ={["varname"] = "_nodeEquipBaseAttr"},
    ["panel_strength"]                                 ={["varname"] = "_panelStrength"},
    ["panel_strength/Node_14/txt_pre_1"]               ={["varname"] = "_txtAttrPre"},
    ["panel_strength/Node_14/Panel_4/Text_1_4"]        ={["varname"] = "_txtAttrNext"},
    ["panel_strength/Node_14/Text_1_0"]                ={["varname"] = "_txtAttrName"},
    ["panel_strength/Node_14/Panel_4/Text_1_0_0"]      ={["varname"] = "_txtAttrName1"},
    ["panel_strength/Node_14/txt_pre_2"]               ={["varname"] = "_txtPreStrengthLvl"},
    ["panel_strength/Node_14/Panel_4/Text_1_3"]        ={["varname"] = "_txtNextStrengthLvl"},
    ["panel_strength/btn_strength0"]                   ={["varname"] = "_btnStrengthMore",["events"] = {{["event"] = "touch",["method"] = "onBtnStrengthMore",["sound_id"] = 51}}},
    ["panel_strength/btn_strength1"]                   ={["varname"] = "_btnStrengthOne",["events"] = {{["event"] = "touch",["method"] = "onBtnStrengthOne",["sound_id"] = 51}}},
    ["panel_strength/Node_14/Panel_4"]                 ={["varname"] = "_panelNotFullStrength"},
    ["panel_strength/Node_14/Text_2"]                  ={["varname"] = "_txtStrengthFullTip"},
    ["panel_strength/Node_14/txt_full_tip"]            ={["varname"] = "_txtStrengthFullTip2"},
    ["panel_rebuild"]                                  ={["varname"] = "_panelRebuild"},
    ["panel_rebuild/Node_28/Panel_3_0"]                ={["varname"] = "_panelRebuildPreItem"},
    ["panel_rebuild/Node_28/Panel_3_1"]                ={["varname"] = "_panelRebuildNextItem"},
    ["panel_rebuild/Node_28/node_normal"]              ={["varname"] = "_nodeRisingNotFull"},
    ["panel_rebuild/Node_28/node_full"]                ={["varname"] = "_nodeRisingFull"},
    ["panel_rebuild/Node_6"]                           ={["varname"] = "_nodeRisingMaterial"},
    ["panel_rebuild/Node_6/img_full"]                  ={["varname"] = "_imgRisingFull"},
    ["panel_rebuild/Node_6/btn_replace_0"]             ={["varname"] = "_btnCasting",["events"] = {{["event"] = "touch", ["method"] = "_onRising"}}},
    ["panel_rebuild/Node_6/node_normal/Sprite_8_0"]    ={["varname"] = "_imgRebuild"},
    ["panel_rebuild/Node_6/node_normal/label_cost_0"]  ={["varname"] = "_txtRebuild"},
    ["panel_rebuild/Node_9/Panel_6"]                   ={["varname"] = "_panelTableView"},
    ["panel_rebuild/Node_6/node_normal"]               ={["varname"] = "_nodeRisingPrice"},
    ["img_tab"]                                        ={["varname"] = "_imgTabBlack"},
}

GeneralsEquipInfo.PAGE = {
    STRENGTH_VIEW = 1,
    INJECT_VIEW   = 2,
}

GeneralsEquipInfo.PAGE_NAME = {
    StaticData['local_text']['label.common.strength'],
    StaticData['local_text']['equip.break.through']
}

function GeneralsEquipInfo:ctor(name, args)
    GeneralsEquipInfo.super.ctor(self, name, args)
    self._curEquipInfo = args.info or nil
    if not self._curEquipInfo then
        return
    end
    self._curEquipInfo.star = self._curEquipInfo.star or 0
    self._equipOrder = {1, 2, 3, 5, 4, 6, 7}
    self._generalsId = args.generals_id
    self._curSelectedType = self._curEquipInfo.xml.type
    self._isCloseEquipState = true
    self._selectedAll = false
    self._cellArray = {}
    self._selectedMaterials = {}
    self._curIndex = self.PAGE.STRENGTH_VIEW
end

function GeneralsEquipInfo:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self:initEventLinstener()

    GeneralsEquipInfo._btnNormalImg = {
        "img/generals/j02_00000116.png",
        "img/generals/j02_00000117.png",
        "img/generals/j02_00000115.png",
    }
    GeneralsEquipInfo._btnSelectedImg = {
        "img/generals/j02_00000119.png",
        "img/generals/j02_00000120.png",
        "img/generals/j02_00000118.png",
    }
    GeneralsEquipInfo._jadeName = {
        StaticData['local_text']['label.crit'],
        StaticData['local_text']['label.beat.back'],
        StaticData['local_text']['label.dec.injure'],
    }

    self._cellArray = {}
    self:initClickEventListener()
    self:initTableView()
    self:initUi()
end

function GeneralsEquipInfo:initUi()
    self._filterData = {1, 2, 3, 4, 5}
    self._strengthMaxLvl = uq.cache.role.master_lvl
    self._panelRebuild:setVisible(false)
    local state = self._generalsId ~= nil
    self._btnReplace:setVisible(state)
    self._btnUnload:setVisible(state)
    self._nodeItems:setVisible(state)
    self._btnReplace:setPressedActionEnabled(true)
    self._btnUnload:setPressedActionEnabled(true)
    if state then
        self:initPanelItems()
    end

    self._arrBaseText = {}
    self._arrBasePosY = {}
    for i = 1, 5 do
        local node = self._nodeEquipBaseAttr:getChildByName("Node_" .. i)
        local pos_y = node:getPositionY()
        local text_name = node:getChildByName("Text_1")
        local text_value = node:getChildByName("Text_2")
        table.insert(self._arrBaseText, {name = text_name, value = text_value, node = node})
        table.insert(self._arrBasePosY, pos_y)
    end

    self._panelMaterials = {}
    for i = 1, 6 do
        local panel = self._nodeRisingMaterial:getChildByName("img_" .. i)
        table.insert(self._panelMaterials, panel)
    end

    self:updateBaseInfo()
    self:updateRed()
    self._checkBox:addEventListener(function(sender, eventType)
        local sound_id = eventType == 0 and 60 or 61
        uq.playSoundByID(sound_id)
        network:sendPacket(Protocol.C_2_S_EQUIP_BIND, {eqid = self._curEquipInfo.db_id, bind_type = eventType})
    end)
end

function GeneralsEquipInfo:updateRed()
    local lvl_state = self._curEquipInfo.lvl < uq.cache.role.master_lvl
    local cost_state = false
    if lvl_state then
        cost_state = true
        local xml_cost = StaticData['item_level'][self._curEquipInfo.lvl].cost
        local cost_array = uq.RewardType.parseRewards(xml_cost)
        for k, v in ipairs(cost_array) do
            local info = v:toEquipWidget()
            if info.num > 0 and not uq.cache.role:checkRes(info.type, info.num, info.id) then
                cost_state = false
                break
            end
        end
    end

    local change_state = false
    if self._generalsId and self._generalsId ~= 0 then
        local general_info = uq.cache.generals:getGeneralDataByID(self._generalsId)
        if not general_info then
            change_state = false
        else
            local arr_suit = uq.cache.equipment:getGeneralsSuitId(self._generalsId)
            if self._curEquipInfo.xml.suitId then
                arr_suit[self._curEquipInfo.xml.suitId] = arr_suit[self._curEquipInfo.xml.suitId] - 1
            end
            local max_info = uq.cache.equipment:getChangeEquipInfo(self._curEquipInfo.xml.type, general_info.lvl, arr_suit)
            change_state = max_info ~= nil and max_info.xml.effectValue > self._curEquipInfo.xml.effectValue
        end
    end

    local rising_state = uq.cache.equipment:judgeCouldRisingByEquipDBId(self._curEquipInfo.db_id)
    local strength_state = change_state or cost_state

    local arrRed = {strength_state, rising_state}
    for k, v in ipairs(self._tabList) do
        v:getChildByName("img_red"):setVisible(arrRed[k])
    end

    local img_red = self._btnReplace:getChildByName("img_red")
    img_red:setVisible(change_state)
    if not self._generalsId then
        return
    end
    self._panelRightItems[self._curEquipInfo.xml.type]:getChildByName("item"):setStrengthImgVisible(change_state or cost_state or rising_state)
end

function GeneralsEquipInfo:initEventLinstener()
    services:addEventListener(services.EVENT_NAMES.ON_EQUIPMENT_ACTION, handler(self, self._onEquipAction), '_onEquipmentAction' .. tostring(self))
    services:addEventListener(services.EVENT_NAMES.ON_BIND_EQUIP, handler(self, self._onEquipBindAction), '_onEquipBindAction' .. tostring(self))
    services:addEventListener(services.EVENT_NAMES.ON_UPDATE_GENERALEFF, handler(self,self._onShowEquipEffect), "_onShowEquipEffect" .. tostring(self))
    services:addEventListener(services.EVENT_NAMES.ON_EQUIPMENT_BREAK_THROUGH, handler(self, self._onRisingResult), "_onRisingResult" .. tostring(self))
end

function GeneralsEquipInfo:_onRisingResult()
    self:updateBaseInfo()
    self:updateRed()
    if not self._generalsId then
        return
    end
    for k, v in ipairs(self._panelRightItems) do
        local item = v:getChildByName("item")
        if item then
            item:updateStar()
            item:showStrengthImg(true)
        end
    end
end

function GeneralsEquipInfo:_onEquipBindAction(msg)
    local item = self._panelItem:getChildByName("item")
    if not item then
        return
    end
    if self._curEquipInfo.db_id == msg.data.eqid then
        self._curEquipInfo.bind_type = msg.data.bind_type
        item:refreshLockedImgState()
        return
    else
        for k, v in ipairs(self._cellArray) do
            local info = v:getEquipInfo()
            if info and info.db_id and info.db_id == msg.data.eqid then
                info.bind_type = msg.data.bind_type
                v:setNodeLockedVisible(msg.data.bind_type == 1)
                v:refreshLockedImgState()
                break
            end
        end
    end
end

function GeneralsEquipInfo:_onEquipAction(msg)
    local data = msg.data
    if (data.actionId == 1 or data.actionId == 4) and self._curEquipInfo.db_id == data.epId then
        local lvl = data.epLevel - self._curLvl
        self._curEquipInfo.lvl = data.epLevel
        local effect_type = self._curEquipInfo.xml.effectType
        local effect_add = 0
        for _, k in ipairs(StaticData['intensify']) do
            if k.itemType == self._curEquipInfo.xml.type and k.qualityType == self._curEquipInfo.xml.qualityType then
                effect_add = k.increase
                break
            end
        end
        local str = StaticData['types'].Effect[1].Type[effect_type].name .. ' +' .. effect_add * lvl

        local pos_x, pos_y = self._panelItem:getPosition()
        local size = self._panelItem:getContentSize()
        local pos = self._panelStrength:convertToWorldSpace(cc.p(pos_x, pos_y))
        uq.fadeAttr(str, pos.x + size.width / 2, pos.y + size.height / 2)
    end
    self:updateBaseInfo()
    self:updateRed()
    if not self._generalsId then
        return
    end
    for k, v in ipairs(self._panelRightItems) do
        local item =  v:getChildByName("item")
        item:showStrengthImg(true)
        if k == self._curEquipInfo.xml.type then
            item:showLevel(true, self._curEquipInfo.lvl)
        end
    end
end

function GeneralsEquipInfo:_onShowSuitInfo(evt)
    if evt.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    local num = uq.cache.equipment:getNumBySuitIdAndGeneral(self._curEquipInfo.xml.suitId, self._curEquipInfo.general_id)
    local pos_x, pos_y = self._btnshowSuitInfo:getPosition()
    local pos = self._arrBaseText[5].node:convertToWorldSpace(cc.p(pos_x, pos_y))
    local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.EQUIP_SUIT_INFO, {id = self._curEquipInfo.xml.suitId, num = num})
    panel:setPosition(cc.p(pos.x, pos.y - 30))
end

function GeneralsEquipInfo:initPanelItems()
    self._generalsEquipInfo = {}
    local all_info = uq.cache.equipment:getInfoByGeneralId(self._generalsId)
    for k, v in ipairs(all_info) do
        self._generalsEquipInfo[v.xml.type] = v
    end

    local panel = self._nodeItems:getChildByName("Panel_1")
    local pos_y = panel:getPositionY()
    local scale = 0.65
    self._panelRightItems = {}
    for i = 1, 7 do
        local item = panel:clone()
        local img_selected = item:getChildByName("img")
        self._nodeItems:addChild(item)
        item:setPositionY(pos_y - 95 * (self._equipOrder[i] - 1))
        item:setTag(i)

        local info = self._generalsEquipInfo[i]
        if not info then
            info = {id = i, type = uq.config.constant.EQUIPITEM_TYPE.TYPES_ITEM}
        else
            info.type = uq.config.constant.COST_RES_TYPE.EQUIP
            info.id = info.temp_id
        end
        local equip_item = EquipItem:create({info = info})
        local state = info.db_id == self._curEquipInfo.db_id
        img_selected:setVisible(state)
        equip_item:setName("item")
        equip_item:setScale(scale)
        equip_item:showStrengthImg(true)
        local size = equip_item:getContentSize()
        equip_item:setPosition(cc.p(size.width / 2 * scale, size.height / 2 * scale - 5))
        equip_item:setTextCanEquipVisible(false)
        equip_item:showName(false)
        equip_item:setTouchEnabled(true)
        equip_item:setLockedImgState(false)
        equip_item:addClickEventListener(function(sender)
            if self._curEquipInfo.xml.type == sender:getTag() then
                uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
                return
            end
            local info = sender:getEquipInfo()
            if not info.db_id then
                uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
                return
            end
            uq.playSoundByID(uq.config.constant.COMMON_SOUND.CHANGE)
            self._curEquipInfo = sender:getEquipInfo()
            for k, v in ipairs(self._panelRightItems) do
                local img = v:getChildByName("img")
                img:setVisible(k == self._curEquipInfo.xml.type)
            end
            self:updateBaseInfo()
            self:updateRed()
        end)
        item:addChild(equip_item)
        table.insert(self._panelRightItems, item)
    end
    panel:setVisible(false)
end

function GeneralsEquipInfo:initClickEventListener()
    self._tabList = {}
    self._panelItemList = {}
    self._panels = {self._panelStrength, self._panelRebuild}

    local init_tab = self._panelTab:getChildByName("tab_1")
    local pos_y = init_tab:getPositionY()
    for i = 1, 2 do
        local tab = i == 1 and init_tab or init_tab:clone()
        local checkbox = tab:getChildByName("CheckBox_1")
        local img_red = tab:getChildByName("img_red")
        local text_blight = tab:getChildByName("text_blight")
        local text_dark = tab:getChildByName("text_dark")
        text_blight:setString(self.PAGE_NAME[i])
        text_dark:setString(self.PAGE_NAME[i])
        checkbox:setTag(i)

        local state = i == self._curIndex
        checkbox:setTouchEnabled(not state)
        checkbox:setSelected(state)
        text_blight:setVisible(state)
        text_dark:setVisible(not state)

        checkbox:addEventListener(function(sender, eventType)
            uq.playSoundByID(uq.config.constant.COMMON_SOUND.CHANGE)
            self._curIndex = sender:getTag()
            for k, v in ipairs(self._tabList) do
                local text_blight = v:getChildByName("text_blight")
                local text_dark = v:getChildByName("text_dark")
                local checkbox = v:getChildByName("CheckBox_1")
                checkbox:setTouchEnabled(self._curIndex ~= k)
                checkbox:setSelected(self._curIndex == k)
                text_blight:setVisible(self._curIndex == k)
                text_dark:setVisible(self._curIndex ~= k)
            end
            self:updateBaseInfo()
        end)
        if i ~= 1 then
            self._panelTab:addChild(tab)
            tab:setPositionY(pos_y - 120 * (i - 1))
        end
        table.insert(self._tabList, tab)
    end
end

function GeneralsEquipInfo:onBtnStrengthOne(event)
    if event.name ~= "ended" then
        return
    end
    self:sendStrengthInfo()
end

function GeneralsEquipInfo:onBtnStrengthMore(event)
    if event.name ~= "ended" then
        return
    end
    self:sendStrengthInfo(self._strengthLevel)
end

function GeneralsEquipInfo:sendStrengthInfo(lvl, action_id)
    local info = data or self._curEquipInfo
    local event_id = action_id or 1
    local level = lvl or 1
    if self._curEquipInfo.lvl >= uq.cache.role.master_lvl then
        uq.fadeInfo(StaticData["local_text"]["equip.strength.level"])
        return
    end
    for i = 1, 2 do
        local info = self._strengthMoneyInfo[i]
        if info then
            local effect_num = math.ceil(info.num * (1 - info.dec_rate))
            if not uq.cache.role:checkRes(info.type, effect_num, info.id) then
                uq.fadeInfo(string.format(StaticData["local_text"]["label.res.tips.less"], StaticData.getCostInfo(info.type, info.id).name))
                return
            end
        end
    end
    network:sendPacket(Protocol.C_2_S_EQUIPMENT_ACTION, {equipmentId = info.db_id, actionId = event_id, upLevel = level, isForceIntersify = 0})
end

function GeneralsEquipInfo:onBtnReplace(event)
    if event.name ~= "ended" then
        return
    end
    local info = uq.cache.equipment:getChangeEquipInfoExpDBId(self._curEquipInfo.db_id)
    if info == nil or #info == 0 then
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
        uq.fadeInfo(StaticData["local_text"]["label.no.change"])
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    self._isCloseEquipState = false
    uq.ModuleManager:getInstance():show(uq.ModuleManager.GENERALS_EQUIP_BAG_MODULE, {info = self._curEquipInfo, generals_id = self._curEquipInfo.general_id, type = 0})
end

function GeneralsEquipInfo:_onShowEquipEffect(msg)
    for k, v in ipairs(msg.data) do
        local data = uq.cache.equipment:_getEquipInfoByDBId(v)
        local xml_data = data.xml
        if xml_data == nil  then
            xml_data = StaticData['items'][data.temp_id]
        end
        local item = self._panelItem:getChildByName("item")
        if not item then
            return
        end
        uq:addEffectByNode(item, 900010, 1, true)
        local equip_item = self._panelRightItems[self._curEquipInfo.xml.type]:getChildByName("item")
        uq:addEffectByNode(equip_item, 900010, 1, true)

        local info = uq.cache.equipment:getInfoByTypeAndGeneralId(self._curEquipInfo.xml.type, self._generalsId)
        self._curEquipInfo = info
        self._curEquipInfo.id = info.temp_id
        self._curEquipInfo.type = uq.config.constant.COST_RES_TYPE.EQUIP
        item:setInfo(self._curEquipInfo)
        item:showName(false)
        equip_item:setInfo(self._curEquipInfo)
        equip_item:showName(false)
        equip_item:setLockedImgState(false)
        self:updateRed()
        self:updateBaseInfo()
    end
end

function GeneralsEquipInfo:onUnload(event)
    if event.name ~= "ended" then
        return
    end
    network:sendPacket(Protocol.C_2_S_UNEQUIP_ITEM, {general_id = self._curEquipInfo.general_id, item_id = self._curEquipInfo.db_id})
    self:disposeSelf()
end

function GeneralsEquipInfo:updateBaseInfo()
    self._panelRebuild:setVisible(false)
    self._panelStrength:setVisible(false)
    if self._curIndex == self.PAGE.STRENGTH_VIEW then
        self:updateStrengthInfo()
    elseif self._curIndex == self.PAGE.INJECT_VIEW then
        self:updateRisingPage()
    end
end

function GeneralsEquipInfo:updateStrengthInfo()
    self._panelStrength:setVisible(true)
    local item_xml = StaticData['items'][self._curEquipInfo.temp_id]
    if not item_xml then
        uq.log("error GeneralsEquipBag:updateEquipInfo ")
    end
    local item = EquipItem:create({info = self._curEquipInfo})
    self._panelItem:removeAllChildren()
    item:setName("item")
    item:showName(false)
    self._panelItem:addChild(item)
    item:setTouchEnabled(true)
    item:addClickEventListener(function(sender)
        local info = sender:getEquipInfo()
        uq.showItemTips(info)
    end)
    item:setPosition(cc.p(self._panelItem:getContentSize().width * 0.5, self._panelItem:getContentSize().height * 0.5))

    self._checkBox:setSelected(self._curEquipInfo.bind_type == 0)
    local item_quality_info = StaticData['types'].ItemQuality[1].Type[item_xml.qualityType]
    self._nameLabel:setString(item_xml.name)
    self._nameLabel:setTextColor(uq.parseColor(item_quality_info.color))
    local max_level = uq.cache.role.master_lvl
    self._curLvl = self._curEquipInfo.lvl
    self._txtPreStrengthLvl:setString(self._curEquipInfo.lvl .. "/" .. max_level)
    local effect_type = self._curEquipInfo.xml.effectType
    local effect_add = 0
    for _, k in ipairs(StaticData['intensify']) do
        if k.itemType == self._curEquipInfo.xml.type and k.qualityType == self._curEquipInfo.xml.qualityType then
            effect_add = k.increase
            break
        end
    end
    local pre_value = effect_add * self._curEquipInfo.lvl
    local cur_value = uq.cache.equipment:getBaseValue(self._curEquipInfo.db_id)
    local effect_info = StaticData['types'].Effect[1].Type[effect_type]
    self._arrBaseText[1].value:setString(string.format(StaticData['local_text']['equip.rising.base.attr.tip'], effect_info.name, cur_value, effect_add))
    for i = 1, 3 do
        local state = self._curEquipInfo.attributes[i] ~= nil
        self._arrBaseText[i + 1].node:setVisible(state)
        if state then
            local info = self._curEquipInfo.attributes[i]
            local effect_info = StaticData['types'].Effect[1].Type[info.attr_type]
            local value = uq.cache.generals:getNumByEffectType(info.attr_type, info.value)
            self._arrBaseText[i + 1].name:setString(effect_info.name)
            self._arrBaseText[i + 1].value:setString(value)
        end
    end

    self._arrBaseText[5].node:setVisible(self._curEquipInfo.xml.suitId ~= nil)
    if self._curEquipInfo.xml.suitId then
        local suit_data = StaticData['item_suit'][self._curEquipInfo.xml.suitId]
        local num = uq.cache.equipment:getNumBySuitIdAndGeneral(self._curEquipInfo.xml.suitId, self._curEquipInfo.general_id)
        local arr_id = string.split(suit_data.itemId, ',')
        self._arrBaseText[5].name:setString(string.format("%s(%s/%s)", suit_data.name, num, #arr_id))
        self._arrBaseText[5].node:setPositionY(self._arrBasePosY[#self._curEquipInfo.attributes + 2])
    end

    self._txtAttrName:setString(effect_info.name)
    self._txtAttrName1:setString(effect_info.name)
    self._txtAttrPre:setString("+" .. pre_value)

    local state = self._curEquipInfo.lvl >= max_level
    self._txtStrengthFullTip:setVisible(state)
    self._txtStrengthFullTip2:setVisible(state)
    self._txtStrengthFullTip2:setString(string.format(StaticData['local_text']['general.equip.cannot'], max_level + 1))

    self._panelNotFullStrength:setVisible(not state)
    self._btnStrengthMore:setEnabled(not state)
    self._btnStrengthOne:setEnabled(not state)
    self._txtNextStrengthLvl:setString(self._curEquipInfo.lvl + 1 .. "/" .. max_level)
    local next_value = effect_add + pre_value
    self._txtAttrNext:setString('+' .. next_value)
    self._curCostInfo = StaticData['item_level'][self._curEquipInfo.lvl].cost
    self._strengthMoneyInfo = {}
    if self._curCostInfo ~= "" then
        local info = string.split(self._curCostInfo, '|')
        for k, v in ipairs(info) do
            local item = uq.RewardType:create(v)
            local info = item:toEquipWidget()
            table.insert(self._strengthMoneyInfo, info)
        end
    end

    self:updateStrengthPriceItem()
end

function GeneralsEquipInfo:updateStrengthPriceItem()
    local build_type = uq.cache.role:getBuildType(uq.config.constant.BUILD_ID.PRODUCE)
    local dec_rate = uq.cache.role:getBuildOfficerPropertyAdd(build_type, uq.config.constant.BUILD_OFFICER_EFFECT.TYPE_STRENGTH_COST)
    self._strengthMoney = {}
    self:updateStrengthMore()
    for i = 1, 4 do
        local node = self._panelNotFullStrength:getChildByName("Node_" .. i)
        node:setVisible(self._strengthMoneyInfo[i] ~= nil)
        if self._strengthMoneyInfo[i] then
            local info = StaticData.getCostInfo(self._strengthMoneyInfo[i].type, self._strengthMoneyInfo[i].id)
            node:getChildByName("Sprite_1"):setTexture("img/common/ui/" .. info.miniIcon)
            local effect_num = math.ceil(self._strengthMoneyInfo[i].num * (1 - dec_rate))
            self._strengthMoneyInfo[i].dec_rate = dec_rate
            local text = node:getChildByName("label_cost")
            text:setString(effect_num)
            if uq.cache.role:checkRes(self._strengthMoneyInfo[i].type, effect_num, self._strengthMoneyInfo[i].id) then
                text:setTextColor(uq.parseColor("ffffff"))
            else
                text:setTextColor(uq.parseColor("c7280b"))
            end
        end
    end
end

function GeneralsEquipInfo:updateRisingPage()
    self._panelRebuild:setVisible(true)
    local full_state = self._curEquipInfo.star >= self._curEquipInfo.xml.fullStar
    self._nodeRisingFull:setVisible(full_state)
    self._imgRisingFull:setVisible(full_state)
    self._nodeRisingPrice:setVisible(not full_state)
    self._nodeRisingNotFull:setVisible(not full_state)
    self._nodeRisingPrice:setVisible(false)
    self._risingPrice = {}
    self._curNode = full_state and self._nodeRisingFull or self._nodeRisingNotFull
    self._panelNum = full_state and 1 or 2
    self._infoNum = full_state and 4 or 6
    for i = 1, self._panelNum do
        local panel = self._curNode:getChildByName("Panel_3_" .. i - 1)
        local item = panel:getChildByName("item")
        if not item then
            item = EquipItem:create()
            local size = item:getContentSize()
            local scale = 1
            item:setScale(scale)
            item:setPosition(cc.p(size.width / 2 * scale - 5, size.height / 2 * scale - 5))
            item:setName("item")
            panel:addChild(item)
        end
        item:setInfo(self._curEquipInfo)
        item:showName(false)
        item:setVisible(i == 1)
    end

    local effect_info = StaticData['types'].Effect[1].Type[self._curEquipInfo.xml.effectType]
    if not effect_info then
        return
    end
    local pre_info = self._curEquipInfo.xml.UpStar[self._curEquipInfo.star]
    for i = 1, self._infoNum do
        local text = self._curNode:getChildByName("Text_" .. i)
        if i == 1 or i == 2 then
            text:setString(effect_info.dex)
        elseif i == 3 or i == 5 then
            text:setString(string.format("+%s%%", math.floor(pre_info.effectProp / 10)))
        elseif i == 4 or i == 6 then
            text:setString("+" .. pre_info.effectValue)
        end
    end

    self._allMaterials = uq.cache.equipment:getRisingMaterialsByEquipDBId(self._curEquipInfo.db_id)
    for k, v in ipairs(self._allMaterials) do
        v.id = v.temp_id
        v.type = uq.config.constant.COST_RES_TYPE.EQUIP
    end
    self:sortTableView()

    for i = 1, 6 do
        local panel = self._panelMaterials[i]
        local item = panel:getChildByName("item")
        if not item then
            item = self:addEquipItem(handler(self, self.removeSelectedItem), 0.6, true)
            panel:addChild(item)
        end
        item:setVisible(false)
    end
    self._selectedMaterials = {}
end

function GeneralsEquipInfo:updateRisingInfo()
    if self._curEquipInfo.star >= self._curEquipInfo.xml.fullStar then
        return
    end
    local total_star = self._curEquipInfo.star
    for k, v in ipairs(self._selectedMaterials) do
        total_star = total_star + v.star + 1
    end
    total_star = math.min(total_star, self._curEquipInfo.xml.fullStar)

    self:caculateRisingPrice()
    if next(self._risingPrice) ~= nil then
        local info = StaticData.getCostInfo(self._risingPrice[1].type, self._risingPrice[1].id)
        self._imgRebuild:setTexture("img/common/ui/" .. info.miniIcon)
        self._txtRebuild:setString(self._risingPrice[1].num)
        if uq.cache.role:checkRes(self._risingPrice[1].type, self._risingPrice[1].num, self._risingPrice[1].id) then
            self._txtRebuild:setTextColor(uq.parseColor("ffffff"))
        else
            self._txtRebuild:setTextColor(uq.parseColor("c7280b"))
        end
    end
    self._nodeRisingPrice:setVisible(next(self._risingPrice) ~= nil)

    local next_info = self._curEquipInfo.xml.UpStar[total_star]
    for i = 5, 6 do
        local text = self._nodeRisingNotFull:getChildByName("Text_" .. i)
        if i == 6 then
            text:setString("+" .. next_info.effectValue)
        elseif i == 5 then
            text:setString(string.format("+%s%%", math.floor(next_info.effectProp / 10)))
        end
    end

    local panel = self._nodeRisingNotFull:getChildByName("Panel_3_1")
    local item = panel:getChildByName("item")
    if not item then
        item = self:addEquipItem(nil, 0.8)
        item:setInfo(self._curEquipInfo)
        panel:addChild(item)
    end
    item:setVisible(next(self._selectedMaterials) ~= nil)
    item:showName(false)
    item:updateStar(total_star)
end

function GeneralsEquipInfo:caculateRisingPrice()
    local arr_price = {}
    self._risingPrice = {}
    for k, v in ipairs(self._selectedMaterials) do
        if v.xml.materialValue and v.xml.materialValue ~= "" then
            local arr_string = uq.RewardType.parseRewards(v.xml.materialValue)
            for _, price in ipairs(arr_string) do
                local info = price:toEquipWidget()
                local cur_price = info.num * (v.star + 1)
                if not arr_price[info.type] then
                    arr_price[info.type] = {}
                end
                arr_price[info.type][info.id] = arr_price[info.type][info.id] and arr_price[info.type][info.id] + cur_price or cur_price
            end
        end
    end

    for k, v in pairs(arr_price) do
        for id, info in pairs(v) do
            table.insert(self._risingPrice, {id = id, type = k, num = info})
        end
    end
end

function GeneralsEquipInfo:initTableView()
    local size = self._panelTableView:getContentSize()
    self._tableView = cc.TableView:create(cc.size(size.width,size.height))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setAnchorPoint(cc.p(0,0))
    self._tableView:setDelegate()
    self._panelTableView:addChild(self._tableView)

    self._tableView:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
end

function GeneralsEquipInfo:cellSizeForTable()
    return 553, 110
end

function GeneralsEquipInfo:itemTouchCallBack(info)
    if not info.db_id then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
    if info.bind_type == 1 then
        uq.fadeInfo(StaticData['local_text']['equip.please.unlock'])
        return
    end
    if #self._selectedMaterials >= 6 then
        return
    end

    if info.star >= self._curEquipInfo.xml.fullStar then
        return
    end

    local total_star = self._curEquipInfo.star
    for k, v in ipairs(self._selectedMaterials) do
        total_star = total_star + v.star + 1
    end
    if total_star >= self._curEquipInfo.xml.fullStar then
        uq.fadeInfo(StaticData['local_text']['equip.could.rising.full1'])
        return
    end

    if total_star + info.star + 1 > self._curEquipInfo.xml.fullStar then
        local confirm = function()
            self:addSelectedItem(info)
        end
        local data = {
            content = StaticData['local_text']['equip.could.rising.full2'],
            confirm_callback = confirm
        }
        uq.addConfirmBox(data)
        return
    end
    self:addSelectedItem(info)
end

function GeneralsEquipInfo:addSelectedItem(info)
    for k, v in ipairs(self._allMaterials) do
        if info.db_id == v.db_id then
            table.insert(self._selectedMaterials, v)
            table.remove(self._allMaterials, k)
            break
        end
    end
    local panel = self._panelMaterials[#self._selectedMaterials]
    local item = panel:getChildByName("item")
    if not item then
        item = self:addEquipItem(handler(self, self.removeSelectedItem), 0.6, true)
        panel:addChild(item)
    end
    item:setInfo(info)
    item:setVisible(true)
    item:setVisible(true)
    self._tableView:reloadData()
    self:updateRisingInfo()
    uq.fadeInfo(StaticData['local_text']['label.add.success'])
end

function GeneralsEquipInfo:removeSelectedItem(sender)
    local info = sender:getEquipInfo()
    local index = 1
    for k, v in ipairs(self._selectedMaterials) do
        if v.db_id == info.db_id then
            index = k
            table.insert(self._allMaterials, v)
            table.remove(self._selectedMaterials, k)
            break
        end
    end

    for i = index, 6 do
        local panel = self._panelMaterials[i]
        local item = panel:getChildByName("item")
        if not item then
            item = self:addEquipItem(handler(self, self.removeSelectedItem), 0.6, true)
            panel:addChild(item)
        end
        local info = self._selectedMaterials[i]
        item:setVisible(info ~= nil)
        if info then
            item:setInfo(self._selectedMaterials[i])
        end
    end

    self:sortTableView()
    self:updateRisingInfo()
end

function GeneralsEquipInfo:sortTableView()
    table.sort(self._allMaterials, function(a, b)
        if a.bind_type ~= b.bind_type then
            return a.bind_type < b.bind_type
        elseif a.star ~= b.star then
            return a.star < b.star
        else
            return a.lvl < b.lvl
        end
    end)
    self._tableView:reloadData()
end

function GeneralsEquipInfo:addEquipItem(callback, scale, can_touch)
    scale = scale or 1
    can_touch = can_touch or false
    local item = EquipItem:create()
    local size = item:getContentSize()
    item:setScale(scale)
    item:setPosition(cc.p((size.width / 2 - 2)  * scale, (size.height / 2 - 2) * scale))
    item:setTouchEnabled(can_touch)
    item:setName("item")
    if callback then
        item:addClickEventListener(callback)
    end
    return item
end

function GeneralsEquipInfo:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx * 5 + 1
    local scale = 0.8
    if not cell then
        cell = cc.TableViewCell:new()
        for i = 0, 4, 1 do
            local img = self._imgTabBlack:clone()
            local size = img:getContentSize()
            img:setName("img" .. i)
            img:setPosition(cc.p((125 * scale + 5) * (i + 0.5) + 15, 120 / 2 * scale))
            img:setVisible(true)
            cell:addChild(img)
            local info = self._allMaterials[index]
            if info then
                local item = EquipItem:create()
                item:setInfo(info)
                item:setNodeLockedVisible(info.bind_type == 1)
                item:setName("item" .. i)
                item:setScale(scale)
                item:setPosition(cc.p((125 * scale + 5) * (i + 0.5) + 15, 120 / 2 * scale))
                table.insert(self._cellArray, item)
                cell:addChild(item)
                item:enableEvent(nil, handler(self, self.itemTouchCallBack))
                item:setSwallow(false)
            end
            index = index + 1
        end
    else
        for i = 0, 4, 1 do
            local item = cell:getChildByName("item" .. i)
            local info = self._allMaterials[index]
            if item then
                item:setVisible(info ~= nil)
            end
            if info then
                if not item then
                    item = EquipItem:create()
                    local size = item:getContentSize()
                    item:setName("item" .. i)
                    item:setScale(0.8)
                    item:setPosition(cc.p((125 * scale + 5) * (i + 0.5) + 15, 120 / 2 * scale))
                    table.insert(self._cellArray, item)
                    cell:addChild(item)
                end
                item:setInfo(info)
                item:setNodeLockedVisible(info.bind_type == 1)
                item:enableEvent(nil, handler(self, self.itemTouchCallBack))
                item:setSwallow(false)
            end
            index = index + 1
        end
    end
    return cell
end

function GeneralsEquipInfo:numberOfCellsInTableView()
    return math.max(math.ceil(#self._allMaterials / 5), 3)
end

function GeneralsEquipInfo:updateStrengthMore()
    local strength_more_money = {}
    self._strengthMoreLevel = 0
    local level = self._strengthMaxLvl - self._curEquipInfo.lvl
    self._strengthLevel = math.min(level, 10)
    self._strengthLevel = math.max(self._strengthLevel, 1)
    local name = 'label.common.num' .. self._strengthLevel
    local des = StaticData['local_text'][name]
    self._btnStrengthMore:getChildByName("label_name_0"):setString(string.format(StaticData['local_text']['general.strength.chance'], des))
    for i = 0, level - 1 do
        local item_info = StaticData['item_level'][self._curEquipInfo.lvl + i]
        if item_info and item_info.cost ~= "" then
            local cost_array = uq.RewardType.parseRewards(item_info.cost)
            local return_state = false
            for k, v in ipairs(cost_array) do
                local data = v:toEquipWidget()
                local total_num = 0
                if not strength_more_money[data.id] then
                    strength_more_money[data.id] = {}
                end
                if strength_more_money[data.id][data.type] then
                    local add_num = strength_more_money[data.id][data.type].add_num or 0
                    strength_more_money[data.id][data.type].num = strength_more_money[data.id][data.type].num + add_num
                    strength_more_money[data.id][data.type].add_num = data.num
                    total_num = strength_more_money[data.id][data.type].num + add_num
                else
                    strength_more_money[data.id][data.type] = data
                    total_num = data.num
                end
                if not uq.cache.role:checkRes(data.type, total_num, data.id) then
                    return_state = true
                end
            end
            if return_state then
                local index = 3
                for _, v in pairs(strength_more_money) do
                    for k, info in pairs(v) do
                        self._strengthMoneyInfo[index] = info
                        index = index + 1
                    end
                end
                return
            end
        end
        self._strengthMoreLevel = self._strengthMoreLevel + 1
    end

    local index = 3
    for k, v in pairs(strength_more_money) do
        for k, info in pairs(v) do
            local add_num = info.add_num or 0
            info.num = info.num + add_num
            self._strengthMoneyInfo[index] = info
            index = index + 1
        end
    end
end

function GeneralsEquipInfo:_onRising(evt)
    if evt.name ~= "ended" then
        return
    end
    if next(self._selectedMaterials) == nil then
        return
    end

    for k, v in ipairs(self._risingPrice) do
        if not uq.cache.role:checkRes(v.type, v.num, v.id) then
            local info = StaticData.getCostInfo(v.type, v.id)
            if info and info.name then
                uq.fadeInfo(string.format(StaticData['local_text']['equip.rising.material.less'], info.name))
            end
            return
        end
    end

    local ids = {}
    for k, v in ipairs(self._selectedMaterials) do
        table.insert(ids, v.db_id)
    end
    local data = {
        db_id = self._curEquipInfo.db_id,
        count = #ids,
        db_ids = ids
    }
    network:sendPacket(Protocol.C_2_S_EQUIPMENT_BREAK_THROUGH, data)
end

function GeneralsEquipInfo:dispose()
    if self._isCloseEquipState then
        services:dispatchEvent({name = services.EVENT_NAMES.ON_CLOSE_EQUIP_SELECT_STATE})
    end
    if self._panelRightItems and next(self._panelRightItems) ~= nil then
        for k, v in ipairs(self._panelRightItems) do
            local item = v:getChildByName("item")
            if item then
                item:onExit()
            end
        end
    end
    for k, v in ipairs(self._cellArray) do
        v:onExit()
    end
    services:removeEventListenersByTag("_onEquipmentAction" .. tostring(self))
    services:removeEventListenersByTag('_onEquipBindAction' .. tostring(self))
    services:removeEventListenersByTag('_onShowEquipEffect' .. tostring(self))
    services:removeEventListenersByTag("_onRisingResult" .. tostring(self))
    GeneralsEquipInfo.super.dispose(self)

end

return GeneralsEquipInfo