local GeneralsEquipBag = class("GeneralsEquipBag", require("app.base.PopupBase"))
local EquipItem = require("app.modules.common.EquipItem")

GeneralsEquipBag.RESOURCE_FILENAME = "generals/GeneralsEquipBag.csb"

GeneralsEquipBag.RESOURCE_BINDING  = {
    ["btn_equip"]           ={["varname"] = "_btnEquip",["events"] = {{["event"] = "touch",["method"] = "onBtnEquip",["sound_id"] = 52}}},
    ["Panel_3"]             ={["varname"] = "_panelItem"},
    ["label_name"]          ={["varname"] = "_nameLabel"},
    ["label_des"]           ={["varname"] = "_desLabel"},
    ["label_base"]          ={["varname"] = "_baseLabel"},
    ["label_base_num"]      ={["varname"] = "_baseNumLabel"},
    ["label_crit_num"]      ={["varname"] = "_critNumLabel"},
    ["label_beat_back_num"] ={["varname"] = "_beatBackNumLabel"},
    ["label_dec_injure"]    ={["varname"] = "_decInjureLabel"},
    ["Panel_10"]            ={["varname"] = "_panelNotPress"},
    ["Panel_9"]             ={["varname"] = "_panelTableView"},
    ["Panel_1"]             ={["varname"] = "_panelRight"},
    ["Panel_5"]             ={["varname"] = "_panelLeft"},
    ["Button_1"]            ={["varname"] = "_btnExit", ["events"] = {{["event"] = "touch",["method"] = "_onTouchExit",["sound_id"] = 0}}},
    ["label_name_0"]        ={["varname"] = "_btnText"},
    ["label_lvl"]           ={["varname"] = "_desScore"},
    ["Text_53"]             ={["varname"] = "_txtQualtiy"},
    ["Text_4"]              ={["varname"] = "_labelNoSuit"},
    ["ScrollView_2"]        ={["varname"] = "_scrollEquip"},
    ["label_1"]             ={["varname"] = "_panelTitle1"},
    ["label_2"]             ={["varname"] = "_panelTitle2"},
    ["label_3"]             ={["varname"] = "_panelTitle3"},
    ["CheckBox_1"]          ={["varname"] = "_checkBox"},
}
function GeneralsEquipBag:ctor(name, args)
    GeneralsEquipBag.super.ctor(self, name, args)
    self._curEquipInfo = args.info or nil
    self._generalsId = args.generals_id or 0
    self._generalsLvl = 0
    self._type = args.type or 0  --0正常装备，1用于洗练界面选择装备祭品
    self._curTypeInfo = nil
    self._tableViewNum = 0
    self._curTableViewInfo = nil
    self._curTableViewIndex = -1
    self._itemArray = {}
    self._arrValue = {self._critNumLabel, self._beatBackNumLabel, self._decInjureLabel}
    self._arrTitle = {self._panelTitle1, self._panelTitle2, self._panelTitle3}
end

function GeneralsEquipBag:init()
    self:parseView(self._view)
    self:centerView(self._view)
    self:setLayerColor()
    self:initUi()
    services:addEventListener(services.EVENT_NAMES.ON_BIND_EQUIP, handler(self, self._onEquipBindAction), '_onEquipBindAction' .. tostring(self))
    self._checkBox:addEventListener(function(sender, eventType)
        network:sendPacket(Protocol.C_2_S_EQUIP_BIND, {eqid = self._curTableViewInfo.db_id, bind_type = eventType})
    end)
end

function GeneralsEquipBag:_onEquipBindAction(msg)
    if self._curTableViewInfo.db_id ~= msg.data.eqid then
        return
    end
    self._curTableViewInfo.bind_type = msg.data.bind_type
    local item = self._panelItem:getChildByName("item")
    if not item then
        return
    end
    item:refreshLockedImgState()
    self._selectedItem:refreshLockedImgState()
end

function GeneralsEquipBag:getLabel(size, color, font)
    size = size or 26
    font = font or "font/hwkt.ttf"
    color = color or "#ffffff"
    local lbl_desc = ccui.Text:create()
    lbl_desc:setFontSize(size)
    lbl_desc:setFontName(font)
    lbl_desc:setTextColor(uq.parseColor(color))
    lbl_desc:setAnchorPoint(cc.p(0, 1))
    lbl_desc:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    return lbl_desc
end

function GeneralsEquipBag:initUi()
    self:addExceptNode(self._panelNotPress)
    self._btnEquip:setPressedActionEnabled(true)
    self._panelTableView:removeAllChildren()
    self._panelTableView:setClippingEnabled(true)

    if self._curEquipInfo == nil then
        return
    end
    if self._type == 0 then
        if self._curEquipInfo.db_id ~= nil then
            self._curTypeInfo = uq.cache.equipment:getChangeEquipInfoExpDBId(self._curEquipInfo.db_id)
        else
            self._curTypeInfo = uq.cache.equipment:getInfoByType(self._curEquipInfo.id, nil, false)
        end
        self._btnEquip:getChildByName("label_name_0"):setString(StaticData['local_text']['label.equip'])
        self:initInfo()
        uq.cache.equipment:sortByQuality(self._curTypeInfo)
    else
        self._curTypeInfo = uq.cache.equipment:getEqualTypeEquipInfoExpDBId(self._curEquipInfo.db_id)
        self._btnEquip:getChildByName("label_name_0"):setString(StaticData['local_text']['label.common.replace'])
        uq.cache.equipment:sortByQuality(self._curTypeInfo)
    end
    if self._curTypeInfo then
        for _, v in pairs(self._curTypeInfo) do
            v.id = v.temp_id
            v.type = uq.config.constant.COST_RES_TYPE.EQUIP
        end
    end
    if self._curTypeInfo == nil then
        self._curTypeInfo = {}
    end
    self._tableViewNum = (#self._curTypeInfo + 3) / 4
    self:initTableView()
end

function GeneralsEquipBag:initInfo()
    local general_info = uq.cache.generals:getGeneralDataByID(self._generalsId)
    if general_info == nil then
        return
    end
    self._generalsLvl = general_info.lvl
end

function GeneralsEquipBag:onBtnEquip(event)
    if event.name ~= "ended" then
        return
    end
    if self._type == 0 then
        local item_xml = StaticData['items'][self._curTableViewInfo.temp_id]
        if item_xml == nil or self._generalsLvl < item_xml.needLevel then
            uq.fadeInfo(StaticData["local_text"]["label.general.level.less"])
            return
        end
        network:sendPacket(Protocol.C_2_S_EQUIP_ITEM, {general_id = self._generalsId, item_id = self._curTableViewInfo.db_id})
    else
        services:dispatchEvent({name="onSelectEquipBgInfo", data = self._curTableViewInfo})
    end
    self:disposeSelf()
end

function GeneralsEquipBag:updateEquipInfo()
    local item_xml = StaticData['items'][self._curTableViewInfo.temp_id]
    if not item_xml then
        uq.log("error GeneralsEquipBag:updateEquipInfo ")
    end

    for i = 1, 3 do
        local state = self._curTableViewInfo.attributes[i] ~= nil
        self._arrTitle[i]:setVisible(state)
        self._arrValue[i]:setVisible(state)
        if state then
            local info = self._curTableViewInfo.attributes[i]
            local effect_info = StaticData['types'].Effect[1].Type[info.attr_type]
            local value = uq.cache.generals:getNumByEffectType(info.attr_type, info.value)
            self._arrTitle[i]:setString(effect_info.name)
            self._arrValue[i]:setString(value)
        end
    end

    local pre_value = uq.cache.equipment:getBaseValue(self._curTableViewInfo.db_id)
    self._baseNumLabel:setString("+" .. pre_value)
    local effect_info = StaticData['types'].Effect[1].Type[self._curTableViewInfo.xml.effectType]
    if not effect_info then
        return
    end
    self._baseLabel:setString(effect_info.name)

    local item = EquipItem:create({info = self._curTableViewInfo})
    item:setScale(0.9)
    self._panelItem:removeAllChildren()
    item:setName("item")
    self._panelItem:addChild(item)
    item:setPosition(cc.p(self._panelItem:getContentSize().width * 0.5, self._panelItem:getContentSize().height * 0.5))
    item:showName(false)
    self._checkBox:setSelected(self._curTableViewInfo.bind_type == 0)


    self._labelNoSuit:setVisible(item_xml.suitId == nil)
    self._scrollEquip:removeAllChildren()
    if item_xml.suitId then
        local suit_data = StaticData['item_suit'][item_xml.suitId]
        local arr_suit = string.split(suit_data.suitEffect, '|')
        local height = #arr_suit * 30 + 22
        local size = self._scrollEquip:getContentSize()
        if size.height < height then
            self._scrollEquip:setInnerContainerSize(cc.size(size.width, height))
        end
        local pos_y = math.ceil(size.height, height)
        local num = uq.cache.equipment:getNumBySuitIdAndGeneral(item_xml.suitId, self._generalsId)
        local cur_type_info = uq.cache.equipment:getInfoByTypeAndGeneralId(item_xml.type, self._generalsId)
        num = (not cur_type_info or (cur_type_info.xml.suitId and cur_type_info.xml.suitId ~= item_xml.suitId)) and num + 1 or num
        local text = self:getLabel(22, "#f6ff61")
        local arr_id = string.split(suit_data.itemId, ',')
        text:setString(string.format("%s(%s/%s)", suit_data.name, num, #arr_id))
        text:setPosition(cc.p(10, pos_y))
        pos_y = pos_y - 32
        self._scrollEquip:addChild(text)
        for k, v in ipairs(arr_suit) do
            local str_info = string.split(v, ',')
            local color = tonumber(str_info[1]) <= num and "#09F71F" or "#ffffff"
            local text = self:getLabel(20, color)
            text:setString(string.format(StaticData['local_text']['equip.suit.cur.num'], str_info[1]))
            text:setPosition(cc.p(10, pos_y))
            self._scrollEquip:addChild(text)

            local type_info = StaticData['types'].Effect[1].Type[tonumber(str_info[2])]
            local text = self:getLabel(20, color)
            local value = uq.cache.generals:getNumByEffectType(tonumber(str_info[2]), tonumber(str_info[3]))
            text:setString(type_info.name .. "  +" .. value)
            text:setPosition(cc.p(100, pos_y))
            self._scrollEquip:addChild(text)
            pos_y = pos_y - 30
        end
    end

    local item_quality_info = StaticData['types'].ItemQuality[1].Type[item_xml.qualityType]
    self._nameLabel:setString(item_xml.name)
    self._txtQualtiy:setString(string.format(StaticData['local_text']['equip.item.quality'], item_quality_info.name, item_quality_info.ident))
    self._nameLabel:setTextColor(uq.parseColor(item_quality_info.color))
    self._txtQualtiy:setTextColor(uq.parseColor(item_quality_info.color))
    local generals_xml = StaticData['general'][tonumber(self._curTableViewInfo.general_id .. 1)]
    local pre_score = StaticData['item_score'].EffectTypeScore[self._curTableViewInfo.xml.effectType].score
    if not pre_score then
        return
    end
    local total_score = math.ceil(self._curTableViewInfo.xml.effectValue * pre_score)
    self._desScore:setString(total_score)
end

function GeneralsEquipBag:initTableView()
    local size = self._panelTableView:getContentSize()
    self._tableView = cc.TableView:create(cc.size(size.width, size.height))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setAnchorPoint(cc.p(0, 0))
    self._tableView:setDelegate()
    self._panelTableView:addChild(self._tableView)

    self._tableView:registerScriptHandler(handler(self,self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:reloadData()
end

function GeneralsEquipBag:cellSizeForTable(view, idx)
    return 466, 170
end

function GeneralsEquipBag:numberOfCellsInTableView(view)
    return self._tableViewNum
end

function GeneralsEquipBag:tableCellTouched(view, cell, touch)
    local touch_point = touch:getLocation()
    local index = cell:getIdx() * 4 + 1
    for i = 0, 3, 1 do
        local item = cell:getChildByName("item"..i)
        if item == nil then
            return
        end
        if not self._curTypeInfo[index] then
            return
        end
        local pos=item:convertToNodeSpace(touch_point)
        local rect=cc.rect(0, 0, item:getContentSize().width, item:getContentSize().height)
        if cc.rectContainsPoint(rect, pos) then
            if self._curTableViewIndex == index then
                return
            end
            for _, v in ipairs(self._itemArray) do
                v:setSelectImgVisible(false)
            end
            self._curTableViewIndex = index
            self._curTableViewInfo = self._curTypeInfo[index]
            item:setSelectImgVisible(true)
            self._selectedItem = item
            self:updateEquipInfo()
            break
        end
        index = index + 1
    end
end

function GeneralsEquipBag:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx * 4 + 1
    if not cell then
        cell = cc.TableViewCell:new()
        for i = 0, 3, 1 do
            local info = self._curTypeInfo[index]
            local width = 0
            local euqip_item = nil
            if info ~= nil then
                euqip_item = EquipItem:create({info = info})
                width = euqip_item:getContentSize().width
                euqip_item:setPosition(cc.p((width * 0.5 + 15) + (width + 15) * i - 10, 85))
                euqip_item:setEquipNameVisible(true)
                cell:addChild(euqip_item, 1)
                euqip_item:setName("item" .. i)
                if self._type == 0 then
                    euqip_item:showGray(info.xml.needLevel > self._generalsLvl)
                end
                if index == 1 then
                    self._curTableViewIndex = index
                    self._curTableViewInfo = info
                    euqip_item:setSelectImgVisible(true)
                    self._selectedItem = euqip_item
                    self:updateEquipInfo()
                end
                table.insert(self._itemArray, euqip_item)
            else
                euqip_item = EquipItem:create()
                width = euqip_item:getContentSize().width
                euqip_item:setPosition(cc.p((width * 0.5 + 15) + (width + 15) * i - 10, 85))
                cell:addChild(euqip_item, 1)
                euqip_item:setName("item"..i)
                euqip_item:setVisible(false)
                table.insert(self._itemArray, euqip_item)
            end
            index = index + 1
        end
    else
        for i = 0, 3, 1 do
            local info = self._curTypeInfo[index]
            local euqip_item = cell:getChildByName("item"..i)
            if info ~= nil then
                euqip_item:setInfo(info)
                euqip_item:setVisible(true)
                if self._type == 0 then
                    euqip_item:showGray(info.xml.needLevel > self._generalsLvl)
                end
            elseif euqip_item then
                euqip_item:setVisible(false)
            end
            index = index + 1
        end
    end
    return cell
end

function GeneralsEquipBag:dispose()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CLOSE_EQUIP_SELECT_STATE})
    services:removeEventListenersByTag('_onEquipBindAction' .. tostring(self))
    self._itemArray = {}
    GeneralsEquipBag.super.dispose(self)
end

return GeneralsEquipBag