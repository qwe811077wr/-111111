local EmbattleListItem = class("EmbattleListItem", require('app.base.ChildViewBase'))

EmbattleListItem.RESOURCE_FILENAME = "embattle/LeftCellItem.csb"
EmbattleListItem.RESOURCE_BINDING = {
    ["Text_2"]  = {["varname"]="_textName"},
    ["Text_1"]  = {["varname"]="_txtType"},
    ["Image_4"] = {["varname"]="_imgSelect"},
    ["img_bg"]  = {["varname"]="_imageNormal"},
    ["Image_3"] = {["varname"]="_imageIcon"},
}

function EmbattleListItem:onCreate()
    self._formationIndex = 0
end

function EmbattleListItem:_onBg(evt)
    if evt.name ~= "ended" then
        return
    end
end

function EmbattleListItem:setData(formIndex)
    self._formationIndex = tonumber(formIndex)

    local data = StaticData['formation'][formIndex]
    local techIndex = data['techId']
    self._imgSelect:setVisible(false)
    self._imgIndex = formIndex
    self._imageIcon:loadTexture("img/embattle/" .. data.button1)
    local info = StaticData['tech'][techIndex]
    self._textName:setString(info.name)
    local effect = info.effectType
    local effect_info = StaticData['types'].Effect[1].Type[effect]
    if not effect_info then
        return
    end
    self._txtType:setString(effect_info.name)
end

function EmbattleListItem:setSelected(flag)
    self._imgSelect:setVisible(flag)
end

function EmbattleListItem:setCallback(call_back)
    self._callBack = call_back
end

return EmbattleListItem