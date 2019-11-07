local UnlockedSuccessView = class("GeneralsAttrNode", require("app.base.PopupBase"))

UnlockedSuccessView.RESOURCE_FILENAME = "generals/GeneralUnlocked.csb"
UnlockedSuccessView.RESOURCE_BINDING = {
    ["Text_31"]                 = {["varname"] = "_txtName"},
    ["Image_3_0"]               = {["varname"] = "_imgType"},
    ["Image_1"]                 = {["varname"] = "_imgQualityTypeBg"},
    ["Button_1"]                = {["varname"] = "_btnShare", ["events"] = {{["event"] = "touch", ["method"] = "_onTouchExit"}}},
    ["Panel_15"]                = {["varname"] = "_nodeGeneral"},
    ["Text_1"]                  = {["varname"] = "_txtTip"},
    ["label_soldier_num"]       = {["varname"] = "_soldierNumLabel"},
    ["label_captain_num"]       = {["varname"] = "_leaderNumLabel"},
    ["label_force_num"]         = {["varname"] = "_attNumLabel"},
    ["label_brains_num"]        = {["varname"] = "_mentalNumLabel"},
    ["label_gongcheng_num"]     = {["varname"] = "_battleNumLabel"},
    ["Image_6"]                 = {["varname"] = "_imgSkillType"},
    ["Text_38"]                 = {["varname"] = "_skillNameLabel"},
    ["Text_39"]                 = {["varname"] = "_skillDesLabel"},
    ["Panel_left"]              = {["varname"] = "_panelInfoLeft"},
    ["Image_3"]                 = {["varname"] = "_imgTitle"},
    ["Image_4"]                 = {["varname"] = "_leftLineImage"},
    ["Image_27"]                = {["varname"] = "_rightLineImage"},
    ["Panel_right"]             = {["varname"] = "_panelTxt"},
    ["Panel_3"]                 = {["varname"] = "_panelTxt1"},
    ["Panel_5"]                 = {["varname"] = "_panelAttr"},
    ["Panel_7"]                 = {["varname"] = "_panelTips"},
    ["Node_2"]                  = {["varname"] = "_nodeCard"},
    ["Node_1"]                  = {["varname"] = "_nodeInfo"},
}

function UnlockedSuccessView:ctor(name, params)
    params._isStopAction = true
    UnlockedSuccessView.super.ctor(self, name, params)
    self:parseView()
    self:centerView()
    local data = params.info
    self._info = uq.cache.generals:getGeneralDataByID(data.info)
    if not self._info then
        return
    end
    self._isNew = data.is_new
    self._func = data.func
    uq.AnimationManager:getInstance():getEffect('txf_81_1')
end

function UnlockedSuccessView:init()
    if not self._info then
        return
    end
    local general_xml = StaticData['general'][self._info.rtemp_id]
    local grade_xml = StaticData['types']['GeneralGrade'][1]['Type'][self._info.grade]
    local quality_info = StaticData['types'].ItemQuality[1].Type[tonumber(grade_xml.qualityType)]
    self._txtName:setString(self._info.name)
    self._txtName:setTextColor(uq.parseColor("#" .. quality_info.color))
    self._imgType:loadTexture("img/generals/" .. grade_xml.image)
    self._imgQualityTypeBg:loadTexture("img/generals/" .. grade_xml.hengFu)
    local pre_path = "animation/spine/" .. general_xml.imageId .. '/' .. general_xml.imageId
    local scale = 0.8
    if cc.FileUtils:getInstance():isFileExist(pre_path .. '.skel') then
        local anim = sp.SkeletonAnimation:createWithBinaryFile(pre_path .. '.skel', pre_path .. '.atlas', 1)
        anim:setAnimation(0, 'idle', true)
        anim:setPosition(cc.p(general_xml.imageX * scale - 200, general_xml.imageY * scale - 90))
        anim:setScale(general_xml.imageRatio * scale)
        self._nodeGeneral:addChild(anim)
    else
        local img = ccui.ImageView:create(pre_path .. '.png')
        self._nodeGeneral:addChild(img)
        img:setAnchorPoint(cc.p(0.5, 1))
        local size = self._nodeGeneral:getContentSize()
        img:setScale(general_xml.imageRatio * scale)
        img:setPosition(cc.p(size.width * 0.5 + general_xml.imageX * scale - 50, size.height + general_xml.imageY * scale + 50))
    end
    self._imgType:setCascadeOpacityEnabled(true)

    self._txtTip:setVisible(not self._isNew)
    self._txtTip:setHTMLText(string.format(StaticData['local_text']['general.spirit.describe'], general_xml.toPiece))

    self._arrayTxt = {self._leaderNumLabel, self._attNumLabel, self._mentalNumLabel, self._battleNumLabel, self._soldierNumLabel}
    self._arrayTxtValue = {"leader", "attack", "mental", "siege", "max_soldiers"}
    local max_value = 0
    self._maxIdent = 0
    for i = 1, 5 do
        if i ~= 5 then
            local state = max_value > self._info[self._arrayTxtValue[i]]
            self._maxIdent = state and self._maxIdent or i
            max_value = state and max_value or self._info[self._arrayTxtValue[i]]
        end
        self._arrayTxt[i]:setString(self._info[self._arrayTxtValue[i]])
    end
    self._arrayTxt[self._maxIdent]:setTextColor(uq.parseColor('#34e626'))
    local skill_xml = StaticData['skill'][self._info.skill_id]
    if not skill_xml then
        return
    end
    self._skillNameLabel:setString(skill_xml.name)
    self._skillDesLabel:setHTMLText(skill_xml.tooltip, nil, nil, nil, true, nil, 30)
    local skill_des = string.split(skill_xml.skillType, ',')
    local img_icon = StaticData['types'].SkillType[1].Type[tonumber(skill_des[1])].getIcon
    self._imgSkillType:loadTexture("img/generals/" .. img_icon)
    self:runOpenAction()
end

function UnlockedSuccessView:runOpenAction()
    local delta = 1 / 12
    self:setLayerColor(0.8)
    local layer = self:getChildByName("layer_color")
    layer:runAction(cc.FadeTo:create(delta * 5, 255))

    uq:addEffectByNode(self._nodeCard, 900135, 1, true, cc.p(-5, -2))

    self._imgTitle:setVisible(false)
    self._imgQualityTypeBg:setVisible(false)
    self._imgQualityTypeBg:setScale(1.2)
    self._imgTitle:setScale(0.3)
    local title_sequence = cc.Spawn:create(cc.ScaleTo:create(delta, 1.2), cc.CallFunc:create(function()
        self._imgTitle:setVisible(true)
        uq:addEffectByNode(self._imgTitle, 900138, 1, true, cc.p(293, 120))
        self._imgQualityTypeBg:setVisible(true)
        self._nodeGeneral:setVisible(true)
        self._nodeInfo:setVisible(true)
        local quality_sequence = cc.Spawn:create(cc.ScaleTo:create(delta, 1), cc.CallFunc:create(function()
            uq:addEffectByNode(self._imgQualityTypeBg, 900136, -1, true, cc.p(481, 376))
        end))
        self._imgQualityTypeBg:runAction(quality_sequence)
    end))
    self._imgTitle:runAction(cc.Sequence:create(cc.DelayTime:create(9 * delta), title_sequence))
    local array_anim = {self._leftLineImage, self._panelTxt, self._panelTxt1, self._panelAttr, self._skillDesLabel, self._panelTips}
    local attr_pos_x = self._panelAttr:getPositionX()
    self._panelAttr:setPositionX(attr_pos_x - 100)
    local skill_pos_y = self._skillDesLabel:getPositionY()
    self._skillDesLabel:setPositionY(skill_pos_y - 100)

    self._animTag = "run_open_ation" .. tostring(self)
    local index = 1
    uq.TimerProxy:removeTimer(self._animTag)
    uq.TimerProxy:addTimer(self._animTag, function()
        array_anim[index]:setVisible(true)
        if index == 4 then
            array_anim[index]:runAction(cc.Sequence:create(cc.MoveBy:create(delta, cc.p(100, 0)), cc.CallFunc:create(function()
                local txt = self._arrayTxt[self._maxIdent]
                local txt_size = txt:getContentSize()
                uq:addEffectByNode(txt, 900137, 1, true, cc.p(txt_size.width / 2, txt_size.height / 2))
            end)))
        elseif index == 5 then
            array_anim[index]:runAction(cc.MoveBy:create(delta, cc.p(0, 100)))
        end
        index = index + 1
    end, delta, 6, delta * 17)
end

function UnlockedSuccessView:setEndCallBack(end_call)
    self._endCall = end_call
end

function UnlockedSuccessView:dispose()
    if self._func then
        self._func()
    end
    local end_call = self._endCall
    uq.TimerProxy:removeTimer(self._animTag)
    UnlockedSuccessView.super.dispose(self)
    uq.refreshNextNewGeneralsShow(end_call)
end

return UnlockedSuccessView