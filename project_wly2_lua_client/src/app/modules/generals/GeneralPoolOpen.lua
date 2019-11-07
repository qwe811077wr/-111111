local GeneralPoolOpen = class("GeneralPoolOpen", require('app.base.PopupBase'))

GeneralPoolOpen.RESOURCE_FILENAME = "generals/GeneralPoolOpen.csb"
GeneralPoolOpen.RESOURCE_BINDING = {
    ["img_bg_adapt"]            = {["varname"] = "_imgBg"},
    ["Image_title"]             = {["varname"] = "_imgTitle"},
    ["Image_open"]              = {["varname"] = "_imgOpen"},
    ["Panel_shade"]             = {["varname"] = "_panelShade"},
    ["Node_action"]             = {["varname"] = "_nodeAction"},
}

function GeneralPoolOpen:ctor(name, params)
    GeneralPoolOpen.super.ctor(self, name, params)
    self:centerView()
    self:parseView()

    self._data = params.data or {}
    self._xmlData = StaticData['general_appoint']['GeneralAppoint'][self._data.id]
    self:initLayer()
    uq.AnimationManager:getInstance():getEffect('txf_100_3', nil, nil, true)
    uq.AnimationManager:getInstance():getEffect('txf_100_4', nil, nil, true)
end

function GeneralPoolOpen:initLayer()
    self._imgTitle:loadTexture("img/general_pool/" .. self._xmlData.tipImg)
    self:runOpenAction()
end

function GeneralPoolOpen:runOpenAction()
    local time = 1 / 12
    uq:addEffectByNode(self._nodeAction, 900184, 1, true, nil, nil, 2)
    local action_delay = cc.DelayTime:create(time * 40)
    local action_func = cc.CallFunc:create(function()
            uq:addEffectByNode(self._nodeAction, 900185, 1, true, nil, nil, 1)
    end)
    self._nodeAction:runAction(cc.Sequence:create(action_delay, action_func))
    local bg_fade_in_step = cc.FadeIn:create(time * 10)
    local bg_delay_step = cc.DelayTime:create(time * 54)
    local bg_fade_out_step = cc.FadeOut:create(time * 7)
    local dispose_func = cc.CallFunc:create(function()
            self:disposeSelf()
    end)
    self._imgBg:runAction(cc.Sequence:create(bg_fade_in_step, bg_delay_step, bg_fade_out_step, dispose_func))
    local open_show = cc.CallFunc:create(function()
            self._imgOpen:setVisible(true)
    end)
    local open_delay_step = cc.DelayTime:create(time * 11)
    self._imgOpen:runAction(cc.Sequence:create(open_delay_step, open_show))
    local title_clone_1 = self._imgTitle:clone()
    self._imgTitle:getParent():addChild(title_clone_1)
    local title_delay_step = cc.DelayTime:create(time * 10)
    local show_func_1 = cc.CallFunc:create(function()
            title_clone_1:setVisible(true)
    end)
    local title_scale_step_1 = cc.ScaleTo:create(time * 1, 1)
    local title_delay_step_1 = cc.DelayTime:create(time * 6)
    local title_fade_step_1 = cc.FadeOut:create(time * 9)
    local hide_func_1 = cc.CallFunc:create(function()
            title_clone_1:removeFromParent()
    end)
    title_clone_1:runAction(cc.Sequence:create(title_delay_step, show_func_1, title_scale_step_1, title_delay_step_1, title_fade_step_1, hide_func_1))
    local title_clone_2 = self._imgTitle:clone()
    self._imgTitle:getParent():addChild(title_clone_2)
    local show_func_2 = cc.CallFunc:create(function()
            title_clone_2:setVisible(true)
            title_clone_2:setScale(1.5)
    end)
    local title_scale_step_2 = cc.ScaleTo:create(time * 7, 1.7)
    local title_delay_step_2 = cc.DelayTime:create(time * 1)
    local title_fade_step_2 = cc.FadeOut:create(time * 7)
    local hide_func_2 = cc.CallFunc:create(function()
            title_clone_2:removeFromParent()
    end)
    title_clone_2:runAction(cc.Sequence:create(title_delay_step, title_delay_step_2, show_func_2, cc.Spawn:create(title_scale_step_2, title_fade_step_2), hide_func_2))
    local title_scale_step = cc.ScaleTo:create(time * 1, 1)
    local show_func = cc.CallFunc:create(function()
            self._imgTitle:setVisible(true)
    end)
    self._imgTitle:runAction(cc.Sequence:create(title_delay_step, show_func, title_scale_step))
    for i = 1, 4 do
        self:shadeAction(i)
    end
end

function GeneralPoolOpen:shadeAction(index)
    local time = 1 / 12
    local width = 481
    if index == 1 then
        width = 708
    elseif index == 2 then
        width = 830
    elseif index == 3 then
        width = 990
    elseif index == 4 then
        width = 1183
    end
    local shade_clone = self._panelShade:clone()
    self._panelShade:getParent():addChild(shade_clone)
    local shade_func = cc.CallFunc:create(function()
            shade_clone:setContentSize(cc.size(width, shade_clone:getContentSize().height))
    end)
    local shade_fade = cc.FadeIn:create(time * 4)
    local shade_delay_step = cc.DelayTime:create(time * (47 + 4 * (index - 1)))
    shade_clone:runAction(cc.Sequence:create(shade_delay_step, shade_func, shade_fade))
end

return GeneralPoolOpen