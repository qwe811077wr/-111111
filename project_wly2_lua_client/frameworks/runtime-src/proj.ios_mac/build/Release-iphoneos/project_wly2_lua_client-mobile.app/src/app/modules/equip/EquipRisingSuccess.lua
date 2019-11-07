local EquipRisingSuccess = class("EquipRisingSuccess", require('app.base.PopupBase'))
local EquipItem = require("app.modules.common.EquipItem")

EquipRisingSuccess.RESOURCE_FILENAME = "equip/EquipRisingSuccess.csb"
EquipRisingSuccess.RESOURCE_BINDING = {
    ["Node_6"]                   = {["varname"] = "_nodeInfo"},
    ["Image_2"]                  = {["varname"] = "_imgBg"},
    ["Image_13"]                 = {["varname"] = "_imgText"},
    ["Panel_3_0"]                = {["varname"] = "_panelLeft"},
    ["Panel_3_1"]                = {["varname"] = "_panelRight"},
    ["Image_42"]                 = {["varname"] = "_imgArrow"},
    ["Image_119"]                = {["varname"] = "_imgArrowUp"},
    ["Image_120"]                = {["varname"] = "_imgArrowDown"},
}

function EquipRisingSuccess:ctor(name, params)
    EquipRisingSuccess.super.ctor(self, name, params)
    self._preStar = params.star
    self._db_id = params.db_id
    self._animShowTag = "anim_show_tag" .. tostring(self)
end

function EquipRisingSuccess:init()
    self:centerView()
    self:setLayerColor()
    self._info = uq.cache.equipment:_getEquipInfoByDBId(self._db_id)
    if not self._info then
        return
    end
    self._arrPanel = {self._panelLeft, self._panelRight}
    self._arrItem = {}
    for i = 1, 2 do
        local panel = self._arrPanel[i]
        local item = panel:getChildByName("item")
        if not item then
            item = EquipItem:create()
            item:setVisible(false)
            local size = item:getContentSize()
            item:setPosition(cc.p(size.width / 2 - 10, size.height / 2 - 10))
            item:setName("item")
            table.insert(self._arrItem, item)
            panel:addChild(item)
        end
        item:setInfo(self._info)
        item:showName(false)
        if i == 1 then
            item:updateStar(self._preStar)
        end
    end

    local effect_info = StaticData['types'].Effect[1].Type[self._info.xml.effectType]
    if not effect_info then
        return
    end
    local pre_info = self._info.xml.UpStar[self._preStar]
    local cur_info = self._info.xml.UpStar[self._info.star]
    for i = 1, 8 do
        local text = self._nodeInfo:getChildByName("Text_" .. i)
        if i == 1 or i == 2 or i == 7 or i == 8 then
            text:setString(effect_info.dex)
        elseif i == 3 then
            text:setString(pre_info.effectValue)
        elseif i == 5 then
            text:setString(cur_info.effectValue)
        elseif i == 4 then
            text:setString(string.format("%s%%", math.floor(pre_info.effectProp / 10)))
        elseif i == 6 then
            text:setString(string.format("%s%%", math.floor(cur_info.effectProp / 10)))
        end
    end
    self:runOpenAction()
end

function EquipRisingSuccess:runOpenAction()
    local delta = 1 / 12
    local bg_pos_y = self._imgBg:getPositionY()
    self._imgBg:setPositionY(bg_pos_y - 400)
    self._imgBg:setVisible(true)
    self._imgBg:runAction(cc.MoveBy:create(delta * 2, cc.p(0, 400)))

    self._imgText:runAction(cc.Sequence:create(cc.DelayTime:create(delta), cc.CallFunc:create(function()
        self._imgText:setScale(0.5)
        self._imgText:setVisible(true)
        self._imgText:runAction(cc.Sequence:create(cc.ScaleTo:create(delta, 1.2), cc.ScaleTo:create(delta * 2, 1)))
        uq:addEffectByNode(self._imgText, 900138, 1, true, cc.p(216, 116))
    end)))

    self._panelLeft:runAction(cc.Sequence:create(cc.DelayTime:create(delta * 3), cc.CallFunc:create(function()
        self._arrItem[1]:setScaleX(0.3)
        self._arrItem[1]:setVisible(true)
        self._arrItem[1]:runAction(cc.Sequence:create(cc.ScaleTo:create(delta, 1), cc.CallFunc:create(function()
            self._imgArrow:setVisible(true)
        end)))

        uq:addEffectByNode(self._panelLeft, 900066, 1, true, cc.p(59.5, 84), nil, 1.1)
    end)))

    self._panelRight:runAction(cc.Sequence:create(cc.DelayTime:create(delta * 6), cc.CallFunc:create(function()
        self._arrItem[2]:setScaleX(0.3)
        self._arrItem[2]:setVisible(true)
        self._arrItem[2]:runAction(cc.ScaleTo:create(delta, 1))
        uq:addEffectByNode(self._panelRight, 900066, 1, true, cc.p(59.5, 84), nil, 1.1)
    end)))

    uq.TimerProxy:removeTimer(self._animShowTag)
    local index = 1
    local arr_add = {0, 0, 4}
    uq.TimerProxy:addTimer(self._animShowTag, function()
        if index == 1 or index == 3 then
            for i = 1 + arr_add[index], 4 + arr_add[index] do
                local text = self._nodeInfo:getChildByName("Text_" .. i)
                text:setVisible(true)
                if i == 1 or i == 2 then
                    uq:addEffectByNode(text, 900012, 1, true, cc.p(149, 16))
                end
            end
        elseif index == 2 then
            self._imgArrowUp:setVisible(true)
            self._imgArrowDown:setVisible(true)
        end
        index = index + 1
    end, delta, 3, delta * 8)
end

function EquipRisingSuccess:dispose()
    uq.TimerProxy:removeTimer(self._animShowTag)
    EquipRisingSuccess.super.dispose(self)
end

return EquipRisingSuccess