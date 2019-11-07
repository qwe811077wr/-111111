local EquipSuitInfo = class("EquipSuitInfo", require('app.base.PopupBase'))

EquipSuitInfo.RESOURCE_FILENAME = "equip/EquipSuitInfo.csb"
EquipSuitInfo.RESOURCE_BINDING = {
    ["Image_1"]                = {["varname"] = "_imgBase"},
    ["Node_1"]                 = {["varname"] = "_nodeBase"},
}

function EquipSuitInfo:ctor(name, params)
    EquipSuitInfo.super.ctor(self, name, params)
    self._suitNum = params.num
    self._suitId = params.id
end

function EquipSuitInfo:init()
    local suit_data = StaticData['item_suit'][self._suitId]
    if not suit_data then
        return
    end
    local arr_suit = string.split(suit_data.suitEffect, '|')
    local pos_y = -5
    local text = self:getLabel(22, "#f6ff61")
    local arr_id = string.split(suit_data.itemId, ',')
    text:setString(string.format("%s(%s/%s)", suit_data.name, self._suitNum, #arr_id))
    text:setPosition(cc.p(5, pos_y))
    pos_y = pos_y - 32
    self._nodeBase:addChild(text)
    for k, v in ipairs(arr_suit) do
        local str_info = string.split(v, ',')
        local color = tonumber(str_info[1]) <= self._suitNum and "#09F71F" or "#ffffff"
        local text = self:getLabel(20, color)
        text:setString(string.format(StaticData['local_text']['equip.suit.cur.num'], str_info[1]))
        text:setPosition(cc.p(5, pos_y))
        self._nodeBase:addChild(text)

        local type_info = StaticData['types'].Effect[1].Type[tonumber(str_info[2])]
        local text = self:getLabel(20, color)
        local value = uq.cache.generals:getNumByEffectType(tonumber(str_info[2]), tonumber(str_info[3]))
        text:setString(type_info.name .. " +" ..value)
        text:setPosition(cc.p(95, pos_y))
        self._nodeBase:addChild(text)
        pos_y = pos_y - 30
    end
    local size = self._imgBase:getContentSize()
    self._imgBase:setContentSize(cc.size(size.width, -pos_y + 10))
end


function EquipSuitInfo:getLabel(size, color, font)
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

function EquipSuitInfo:dispose()
    EquipSuitInfo.super.dispose(self)
end

return EquipSuitInfo