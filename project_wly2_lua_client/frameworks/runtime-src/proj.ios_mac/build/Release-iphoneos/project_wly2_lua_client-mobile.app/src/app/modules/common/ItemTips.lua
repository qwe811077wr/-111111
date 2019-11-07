local ItemTips = class("ItemTips", require("app.base.PopupBase"))
local EquipItem = require("app.modules.common.EquipItem")

ItemTips.RESOURCE_FILENAME = "common/ItemTips.csb"

ItemTips.RESOURCE_BINDING  = {
    ["Panel_1/Panel_item"]                                      ={["varname"] = "_panelItem"},
    ["Panel_1/label_name"]                                      ={["varname"] = "_nameLabel"},
    ["Panel_1/label_base"]                                      ={["varname"] = "_baseNumName"},
    ["Panel_1/label_base_num"]                                  ={["varname"] = "_baseNumLabel"},
    ["Panel_1/label_crit_num"]                                  ={["varname"] = "_critNumLabel"},
    ["Panel_1/label_dec_injure"]                                ={["varname"] = "_decInjureLabel"},
    ["Panel_1/label_beat_back_num"]                             ={["varname"] = "_beatBackNumLabel"},
    ["label_lvl"]                                               ={["varname"] = "_desScore"},
    ["label_lvl_0"]                                             ={["varname"] = "_txtQualtiy"},
    ["Text_4"]                                                  ={["varname"] = "_labelNoSuit"},
    ["ScrollView_2"]                                            ={["varname"] = "_scrollEquip"},
    ["Panel_1/label_1"]                                         ={["varname"] = "_panelTitle1"},
    ["Panel_1/label_2"]                                         ={["varname"] = "_panelTitle2"},
    ["Panel_1/label_3"]                                         ={["varname"] = "_panelTitle3"},
    ["CheckBox_1"]                                              ={["varname"] = "_checkBox"},
}

function ItemTips:ctor(name, args)
    ItemTips.super.ctor(self, name, args)
    self._curItemInfo = args.info
    self._curItemInfo.lvl = self._curItemInfo.lvl or 0
    self._curItemInfo.attributes = self._curItemInfo.attributes or {}
    self._preEquipId = args.pre_equip_id or (self._curItemInfo.db_id or 0)
    self._arrValue = {self._critNumLabel, self._beatBackNumLabel, self._decInjureLabel}
    self._arrTitle = {self._panelTitle1, self._panelTitle2, self._panelTitle3}
    services:addEventListener(services.EVENT_NAMES.ON_BIND_EQUIP, handler(self, self._onEquipBindAction), '_onEquipBindAction' .. tostring(self))
end

function ItemTips:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self:updateInfo()
    self._checkBox:addEventListener(function(sender, eventType)
        network:sendPacket(Protocol.C_2_S_EQUIP_BIND, {eqid = self._curItemInfo.db_id, bind_type = eventType})
    end)
end

function ItemTips:_onEquipBindAction(msg)
    if self._curItemInfo.db_id ~= msg.data.eqid then
        return
    end
    self._curItemInfo.bind_type = msg.data.bind_type
    local item = self._panelItem:getChildByName("item")
    if not item then
        return
    end
    item:refreshLockedImgState()
end

function ItemTips:updateEquipInfo()
    local item_xml = StaticData['items'][self._curItemInfo.id]
    if not item_xml then
        uq.log("error ItemTips:updateEquipInfo ")
    end

    if next(self._curItemInfo.attributes) == nil and self._curItemInfo.db_id then
        self._curItemInfo = uq.cache.equipment:_getEquipInfoByDBId(self._curItemInfo.db_id)
    end
    for i = 1, 3 do
        local state = self._curItemInfo.attributes[i] ~= nil
        self._arrTitle[i]:setVisible(state)
        self._arrValue[i]:setVisible(state)
        if state then
            local info = self._curItemInfo.attributes[i]
            local effect_info = StaticData['types'].Effect[1].Type[info.attr_type]
            local value = uq.cache.generals:getNumByEffectType(info.attr_type, info.value)
            self._arrTitle[i]:setString(effect_info.name)
            self._arrValue[i]:setString(value)
        end
    end
    self._checkBox:setVisible(self._curItemInfo.bind_type ~= nil)
    if self._curItemInfo.bind_type ~= nil then
        self._checkBox:setSelected(self._curItemInfo.bind_type == 0)
    end

    local pre_value = uq.cache.equipment:getBaseValue(self._curItemInfo.db_id)
    self._baseNumLabel:setString("+" .. pre_value)
    local effect_info = StaticData['types'].Effect[1].Type[self._curItemInfo.xml.effectType]
    if not effect_info then
        return
    end
    self._baseNumName:setString(effect_info.name)

    self._labelNoSuit:setVisible(item_xml.suitId == nil)
    self._scrollEquip:removeAllChildren()
    if item_xml.suitId then
        local num = uq.cache.equipment:getNumBySuitIdAndGeneral(item_xml.suitId, self._curItemInfo.general_id)
        local suit_data = StaticData['item_suit'][item_xml.suitId]
        local arr_suit = string.split(suit_data.suitEffect, '|')
        local height = #arr_suit * 30 + 22
        local size = self._scrollEquip:getContentSize()
        if size.height < height then
            self._scrollEquip:setInnerContainerSize(cc.size(size.width, height))
        end
        local pos_y = math.ceil(size.height, height)
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
            text:setString(type_info.name .. "  +" ..value)
            text:setPosition(cc.p(100, pos_y))
            self._scrollEquip:addChild(text)
            pos_y = pos_y - 30
        end
    end

    local pre_score = StaticData['item_score'].EffectTypeScore[item_xml.effectType].score
    if not pre_score then
        return
    end
    local total_score = math.ceil(item_xml.effectValue * pre_score)
    self._desScore:setString(total_score)
end

function ItemTips:updateInfo()
    if not self._curItemInfo or (self._curItemInfo.type and self._curItemInfo.type <= 0) then
        return
    end
    local item = EquipItem:create({info = self._curItemInfo})
    item:setScale(0.9)
    self._panelItem:removeAllChildren()
    item:setName("item")
    self._panelItem:addChild(item)
    item:showName(false)
    item:setPosition(cc.p(self._panelItem:getContentSize().width * 0.5, self._panelItem:getContentSize().height * 0.5))
    local xml_info = StaticData.getCostInfo(self._curItemInfo.type, self._curItemInfo.id)
    local item_quality_info = StaticData['types'].ItemQuality[1].Type[tonumber(xml_info.qualityType)]
    self._nameLabel:setString(xml_info.name)
    self._txtQualtiy:setString(string.format(StaticData['local_text']['equip.item.quality'], item_quality_info.name, item_quality_info.ident))
    if item_quality_info then
        self._nameLabel:setTextColor(uq.parseColor(item_quality_info.color))
        self._txtQualtiy:setTextColor(uq.parseColor(item_quality_info.color))
    end
    if self._curItemInfo.type == uq.config.constant.COST_RES_TYPE.EQUIP then
        if self._curItemInfo.xml == nil then
            self._curItemInfo.xml = StaticData['items'][self._curItemInfo.id]
        end
        self:updateEquipInfo()
    end
end

function ItemTips:getLabel(size, color, font)
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

function ItemTips:dispose()
    services:removeEventListenersByTag('_onEquipBindAction' .. tostring(self))
    ItemTips.super.dispose(self)
end

return ItemTips
