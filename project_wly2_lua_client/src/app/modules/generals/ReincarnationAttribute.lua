local ReincarnationAttribute = class("ReincarnationAttribute", require('app.base.PopupBase'))

ReincarnationAttribute.RESOURCE_FILENAME = "generals/generalReinSuccess.csb"
ReincarnationAttribute.RESOURCE_BINDING = {
    ["Image_3"]                 = {["varname"] = "_imgHead"},
    ["Panel_Attr"]              = {["varname"] = "_panelAttribute"},
    ["open_lvl"]                = {["varname"] = "_openLvl"},
    ["cur_lvl"]                 = {["varname"] = "_curLvl"},
    ["next_lvl"]                = {["varname"] = "_nextLvl"},
    ["txt_head"]                = {["varname"] = "_txtHead"},
    ["Panel_4"]                 = {["varname"] = "_panelItem"},
    ["Image_1"]                 = {["varname"] = "_imgBg"},
    ["Image_4"]                 = {["varname"] = "_imgRein"},
    ["Image_5"]                 = {["varname"] = "_imgSuccess"},
    ["Node_1"]                  = {["varname"] = "_nodeEffect"},
    ["Node_2"]                  = {["varname"] = "_nodeLight"},
}

function ReincarnationAttribute:ctor(name, params)
    ReincarnationAttribute.super.ctor(self, name, params)
    self:centerView()
    self._generalInfo = params.info
    self._showImg = params.type
    uq.AnimationManager:getInstance():getEffect('txf_27_1')
    self:initDialog()
end

function ReincarnationAttribute:initDialog()
    if not self._generalInfo then
        return
    end
    self._txtHead:setVisible(not self._showImg)
    self._imgHead:setVisible(self._showImg)

    local cur_rein_info = self:getReinInfo(self._generalInfo.reincarnation_tims)
    local next_rein_info = self:getReinInfo(self._generalInfo.reincarnation_tims + 1)
    local lvl = StaticData['game_config'].InitReincarnationLvl + 5 * (self._generalInfo.reincarnation_tims + 1)
    self._openLvl:setString(string.format(StaticData['local_text']['general.currein.maxlvl'], lvl))

    self._curLvl:setString(self._generalInfo.reincarnation_tims)
    self._nextLvl:setString(self._generalInfo.reincarnation_tims + 1)
    for i = 1, 3 do
        self._panelAttribute:getChildByName("Panel_" .. i):getChildByName("Text_Now"):setString(cur_rein_info[i])
        self._panelAttribute:getChildByName("Panel_" .. i):getChildByName("Text_next"):setString(next_rein_info[i])
    end


    if not self._showImg then
        self._panelItem:setPosition(cc.p(0, -160))
    else
        self:playReinSuccessAction()
    end
end

function ReincarnationAttribute:setClickState(state)
    self._panelItem:setTouchEnabled(state)
end

function ReincarnationAttribute:playReinSuccessAction()
    local rein_pos_x, rein_pos_y = self._imgRein:getPosition()
    local success_pos_x, success_pos_y = self._imgSuccess:getPosition()
    local size = self._imgBg:getContentSize()
    local rein_size = self._imgRein:getContentSize()
    local succedd_size = self._imgSuccess:getContentSize()
    self._imgRein:setPositionX(rein_size.width / 2)
    self._imgSuccess:setPositionX(size.width - succedd_size.width / 2)

    self._imgRein:runAction(cc.MoveTo:create(0.15, cc.p(rein_pos_x, rein_pos_y)))
    self._imgSuccess:runAction(cc.Sequence:create(cc.MoveTo:create(0.15, cc.p(success_pos_x, success_pos_y)), cc.CallFunc:create(function()
        uq:addEffectByNode(self._nodeEffect, 900046, 1, true, cc.p(-41, -145), nil, nil, 0.5, true)
    end)))
    self._imgSuccess:runAction(cc.Sequence:create(cc.DelayTime:create(1 / 16 * 3 + 0.15), cc.CallFunc:create(function()
        uq:addEffectByNode(self._nodeEffect, 900075, 1, true)
    end)))
    self._imgSuccess:runAction(cc.Sequence:create(cc.DelayTime:create(1 / 16 * 11 + 0.15), cc.CallFunc:create(function()
        uq:addEffectByNode(self._nodeLight, 900048, 1, true)
    end)))
end

function ReincarnationAttribute:getReinInfo(rein_num)
    local xml_data = StaticData['general'][self._generalInfo.temp_id]
    local cur_rein_info = {
        StaticData['rebirth'][rein_num].strengthEffect * xml_data.strengthIncrease + xml_data.strength,
        StaticData['rebirth'][rein_num].leaderEffect * xml_data.leaderIncrease + xml_data.leader,
        StaticData['rebirth'][rein_num].intellectEffect * xml_data.intellectIncrease + xml_data.intellect,
    }
    return cur_rein_info
end

function ReincarnationAttribute:dispose()
    ReincarnationAttribute.super.dispose(self)
end

return ReincarnationAttribute