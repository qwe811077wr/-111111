local BuffIntroductionCell = class("BuffIntroductionCell", require('app.base.ChildViewBase'))

BuffIntroductionCell.RESOURCE_FILENAME = "battle/BuffIntroductionCell.csb"
BuffIntroductionCell.RESOURCE_BINDING = {
    ["Image_1"]             = {["varname"] = "_imgBg"},
    ["Node_1"]              = {["varname"] = "_nodeBuffAction"},
    ["Text_2"]              = {["varname"] = "_txtBuffName"},
    ["Panel_1"]             = {["varname"] = "_panelBuffDes"},
}

function BuffIntroductionCell:ctor(name, params)
    BuffIntroductionCell.super.ctor(self, name, params)
end

function BuffIntroductionCell:onCreate()
    BuffIntroductionCell.super.onCreate(self)
    self:setContentSize(self._imgBg:getContentSize())
    self._richText = uq.RichText:create()
    self._richText:setAnchorPoint(cc.p(0.5, 0.5))
    self._richText:setDefaultFont("res/font/hwkt.ttf")
    self._richText:setFontSize(18)
    local size = self._panelBuffDes:getContentSize()
    self._richText:setContentSize(cc.size(size.width, size.height))
    self._richText:setMultiLineMode(true)
    self._richText:setTextColor(cc.c3b(255,255,255))
    self._richText:setPosition(cc.p(size.width * 0.5, size.height * 0.5))
    self._panelBuffDes:addChild(self._richText)
end

function BuffIntroductionCell:setData(buff_data)
    self._buffData = buff_data
    self._txtBuffName:setString(self._buffData.name)
    self._richText:setText(self._buffData.tooltip)
    self:addEffect(tonumber(self._buffData.buffIcon), true)
end

function BuffIntroductionCell:addEffect(effect_id, repeated, callback)
    self._nodeBuffAction:removeAllChildren()
    local effect_data = StaticData['effect'][effect_id]
    if not effect_data then
        return
    end

    local node_effect = uq.createPanelOnly('common.EffectNode')
    self._nodeBuffAction:addChild(node_effect)
    local ret = node_effect:playEffectNormal(effect_id, repeated, callback)
    if not ret then
        return
    end

    -- local pos_x, pos_y = self:_nodeBuffAction:getPosition()
    node_effect:setPosition(cc.p(tonumber(effect_data.X1),tonumber(effect_data.Y1)))

    node_effect:setScale(0.7)
end

function BuffIntroductionCell:onExit()
    BuffIntroductionCell.super.onExit(self)
end

return BuffIntroductionCell