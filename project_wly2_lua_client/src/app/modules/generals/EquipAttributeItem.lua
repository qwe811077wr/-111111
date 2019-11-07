local EquipAttributeItem = class("EquipAttributeItem", require('app.base.ChildViewBase'))

EquipAttributeItem.RESOURCE_FILENAME = "generals/GeneralsAttributeItem.csb"
EquipAttributeItem.RESOURCE_BINDING = {
    ["label_0_0"]                     = {["varname"] = "_txtTitle"},
    ["Node_3"]                        = {["varname"] = "_nodeBase"},
    ["Node_3/Panel_1"]                = {["varname"] = "_panelItem"},
    ["Node_4"]                        = {["varname"] = "_nodeSuit"},
    ["Node_4/Panel_1"]                = {["varname"] = "_panelSuitItem"},
    ["Node_2"]                        = {["varname"] = "_nodeGenerals"},
}

function EquipAttributeItem:ctor(name, params)
    EquipAttributeItem.super.ctor(self, name, params)
end

function EquipAttributeItem:onCreate()
    EquipAttributeItem.super.onCreate(self)
    self._nodeGenerals:setVisible(false)
    self._panelItem:setTag(1)
    self._arrItems = {self._panelItem}

    self._panelSuitItem:setTag(1)
    self._arrSuits = {self._panelSuitItem}
end

function EquipAttributeItem:setInfo(info, is_suit)
    self._info = info
    if not info then
        return
    end
    self._nodeBase:setVisible(not is_suit)
    self._nodeSuit:setVisible(is_suit)
    if not is_suit then
        self:refreshPage()
    else
        self:refreshSuitPage()
    end
end

function EquipAttributeItem:refreshSuitPage()
    self._txtTitle:setString(StaticData['local_text']['equip.suit.attribute'])
    local pos_y = -41
    for k, v in ipairs(self._info) do
        local item = self._arrSuits[k]
        if not item then
            item = self._panelSuitItem:clone()
            item:setTag(k)
            table.insert(self._arrSuits, item)
            self._nodeSuit:addChild(item)
        end
        item:setVisible(true)
        item:setPositionY(pos_y)
        pos_y = -self:setSuitInfo(item, v) + pos_y
    end
    for i = #self._info + 1, #self._arrSuits do
        self._arrSuits[i]:setVisible(false)
    end
end

function EquipAttributeItem:setSuitInfo(item, info)
    local title = item:getChildByName("Text_1")
    local node_text = item:getChildByName("Panel_4")
    node_text:removeAllChildren()
    local panel = item:getChildByName("Panel_6")
    local suit_info = StaticData['item_suit'][info.id]
    local arr_id = string.split(suit_info.itemId, ',')
    title:setString(string.format("%s(%s/%s)", suit_info.name, info.num, #arr_id))

    local size = panel:getContentSize()
    panel:setContentSize(cc.size(size.with, pos_y))
    local arr_suit = string.split(suit_info.suitEffect, '|')
    local pos_y = 0
    for k, v in ipairs(arr_suit) do
        local str_info = string.split(v, ',')
        local acheive_state = info.num >= tonumber(str_info[1])
        local text = self:getLabel(acheive_state)
        text:setString(string.format(StaticData['local_text']['equip.suit.cur.num'], str_info[1]))
        text:setPosition(cc.p(10, pos_y))
        node_text:addChild(text)

        local type_info = StaticData['types'].Effect[1].Type[tonumber(str_info[2])]
        local text = self:getLabel(acheive_state)
        local value = uq.cache.generals:getNumByEffectType(tonumber(str_info[2]), tonumber(str_info[3]))
        text:setString(type_info.name .. "  +" ..value)
        text:setPosition(cc.p(100, pos_y))
        node_text:addChild(text)
        pos_y = pos_y - 30
    end

    return -pos_y + 50
end

function EquipAttributeItem:getLabel(acheive_state)
    local color = acheive_state and "#09F71F" or "#ffffff"
    local lbl_desc = ccui.Text:create()
    lbl_desc:setFontSize(20)
    lbl_desc:setFontName("font/hwkt.ttf")
    lbl_desc:setTextColor(uq.parseColor(color))
    lbl_desc:setAnchorPoint(cc.p(0, 1))
    lbl_desc:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    return lbl_desc
end

function EquipAttributeItem:refreshPage()
    self._txtTitle:setString(self._info.title)
    for i = 1, math.ceil(#self._info.List / 2) do
        local item = self._arrItems[i]
        if not item then
            item = self._panelItem:clone()
            item:setTag(i)
            local size = item:getContentSize()
            item:setPositionY(-(size.height + 2) * (i - 1))
            table.insert(self._arrItems, item)
            self._nodeBase:addChild(item)
        end
        item:setVisible(true)
        self:setItemInfo(item, self._info.List[2 * i - 1], self._info.List[2 * i])
    end
    for i = math.ceil(#self._info.List / 2) + 1, #self._arrItems do
        self._arrItems[i]:setVisible(false)
    end
end

function EquipAttributeItem:setItemInfo(item, info, info1)
    local title = item:getChildByName("Text_1")
    local name = info.name or StaticData['types'].Effect[1].Type[info.effectType].name
    title:setString(name)
    local text = item:getChildByName("Text_2")
    local value = uq.cache.generals:getNumByEffectType(info.effectType, info.value)
    text:setString(value)

    local title1 = item:getChildByName("Text_3")
    local text1 = item:getChildByName("Text_4")
    title1:setVisible(info1 ~= nil)
    text1:setVisible(info1 ~= nil)
    if info1 then
        local name1 = info1.name or StaticData['types'].Effect[1].Type[info1.effectType].name
        title1:setString(name1)
        local value1 = uq.cache.generals:getNumByEffectType(info1.effectType, info1.value)
        text1:setString(value1)
    end
end

return EquipAttributeItem