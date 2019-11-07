local TavernItem = class("TavernItem", require('app.base.ChildViewBase'))

TavernItem.RESOURCE_FILENAME = "tavern/TavernItem.csb"
TavernItem.RESOURCE_BINDING = {
    ["Button_3"]                       = {["varname"] = "_btnSelect"},
    ["Node_3/Text_1_0"]                = {["varname"] = "_txtName"},
    ["Node_3/lock_node/Image_8"]       = {["varname"] = "_imgJar"},
    ["Node_3/lock_node"]               = {["varname"] = "_nodeLock"},
    ["Node_3/unlock_node"]             = {["varname"] = "_nodeUnlock"},
    ["Node_3/unlock_node/Text_8"]      = {["varname"] = "_txtLv"},
    ["Node_3/lock_node/Image_8/Node_6"]= {["varname"] = "_nodeWater"},
    ["Node_3"]                         = {["varname"] = "_nodeAction"},
}

function TavernItem:onCreate()
    TavernItem.super.onCreate(self)
end

function TavernItem:initlayer(func)
    local move1 = cc.MoveBy:create(3, cc.p(0, 5))
    local move2 = cc.MoveBy:create(6, cc.p(0, -10))
    self._imgJar:runAction(cc.RepeatForever:create(cc.Sequence:create(move1, move2, move1, nil)))
    uq:addEffectByNode(self._nodeWater, 900033, -1, true, cc.p(0, -180))
    self._btnSelect:addClickEventListenerWithSound(function ()
        if not self._index  then
            return
        end
        if not self._data or next(self._data) == nil then
            return
        end
        if uq.cache.role:level() < self._data.showLevel then
            uq.fadeInfo(string.format(StaticData["local_text"]["tavern.lv.limit"], self._data.showLevel, self._data.city))
            return
        end
        if func then
            func(self._index)
        end
    end)
end

function TavernItem:refreshData(data, index, is_bool)
    self._data = data or {}
    self._index = index
    if not self._data or next(self._data) == nil then
        return
    end
    local str = ""
    local tab_char = string.toChars(self._data.city)
    for i, v in ipairs(tab_char) do
        if str == "" then
            str = str .. v
        else
            str = str .. "\n" .. v
        end
    end
    self._txtName:setString(str)
    self._txtLv:setString(tostring(self._data.showLevel))
    self._nodeUnlock:setVisible(uq.cache.role:level() < self._data.showLevel)
    self._nodeLock:setVisible(uq.cache.role:level() >= self._data.showLevel)
    if is_bool then
        self._txtName:setString(str)
        return
    end
    self._nodeAction:stopAllActions()
    self._nodeAction:setOpacity(255)
    self._nodeAction:runAction(
        cc.Sequence:create(cc.FadeOut:create(0.2),
            cc.CallFunc:create(function ()
                self._txtName:setString(str)
            end),
            cc.FadeIn:create(0.2),
            cc.CallFunc:create(function ()
            end)))
    self._nodeWater:stopAllActions()
    self._nodeWater:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0),cc.ScaleTo:create(0.2, 1)))
end

return TavernItem