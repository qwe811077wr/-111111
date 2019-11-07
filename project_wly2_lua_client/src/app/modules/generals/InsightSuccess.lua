local InsightSuccess = class("InsightSuccess", require("app.base.PopupBase"))

InsightSuccess.RESOURCE_FILENAME = "generals/InsightSuccess.csb"

InsightSuccess.RESOURCE_BINDING  = {
    ["Image_1"]                     ={["varname"] = "_imgType"},
    ["Panel_10"]                    ={["varname"] = "_panelGeneral"},
    ["Panel_1"]                     ={["varname"] = "_panelAttr"},
    ["Panel_7"]                     ={["varname"] = "_panelSkill"},
    ["Panel_15"]                    ={["varname"] = "_nodeGeneral"},
    ["label_captain_num"]           ={["varname"] = "_leaderNumLabel"},
    ["label_force_num"]             ={["varname"] = "_attNumLabel"},
    ["label_brains_num"]            ={["varname"] = "_mentalNumLabel"},
    ["label_solider_num"]           ={["varname"] = "_soldierNumLabel"},
    ["label_captain_num_0"]         ={["varname"] = "_leaderNumAddLabel"},
    ["label_force_num_0"]           ={["varname"] = "_attNumAddLabel"},
    ["label_solider_num_0"]         ={["varname"] = "_soldierNumAddLabel"},
    ["label_brains_num_0"]          ={["varname"] = "_mentalAddNumLabel"},
    ["label_skill_name"]            ={["varname"] = "_skillNameLabel"},
    ["Text_25_0"]                   ={["varname"] = "_nodeTips1"},
    ["Panel_2"]                     ={["varname"] = "_panelItems"},
    ["Node_18"]                     ={["varname"] = "_nodeTips2"},
    ["Panel_10/Panel_4"]            ={["varname"] = "_panelStar"},
    ["label_siege_num_0"]           ={["varname"] = "_siegeNumAddLabel"},
    ["label_siege_num"]             ={["varname"] = "_siegeNumLabel"},
    ["Panel_12"]                    ={["varname"] = "_panelHead"},
    ["Button_3"]                    ={["varname"] = "_btnShowTips",["events"] = {{["event"] = "touch",["method"] = "onBtnShowTip",["sound_id"] = 0}}},
    ["img_base_intelligence_0"]     ={["varname"] = "_imgLeader"},
    ["img_base_captain"]            ={["varname"] = "_imgForce"},
    ["img_base_force"]              ={["varname"] = "_imgIntel"},
    ["img_base_intelligence"]       ={["varname"] = "_imgSiege"},
    ["img_base_intelligence_0_0"]   ={["varname"] = "_imgSoldier"},
    ["Panel_7/Image_59"]            ={["varname"] = "_imgSkillBg"},
    ["Image_13"]                    ={["varname"] = "_imgHead"},
}
function InsightSuccess:ctor(name, args)
    args._isStopAction = true
    InsightSuccess.super.ctor(self, name, args)
    self._tempId = args.temp_id or 0
    self._preGeneralId = args.general_id or 0
    self._playAnimTag = "play_anim_tag" .. tostring(self)
    self:setLayerColor()
end

function InsightSuccess:init()
    self:parseView(self._view)
    self:centerView(self._view)
    self:initUi()
end

function InsightSuccess:initUi()
    self:updateBaseInfo()
    self:runOpenAction()
end

function InsightSuccess:runOpenAction()
    self._panelGeneral:setOpacity(0)
    self._panelHead:setScale(0.4)
    self._panelAttr:setVisible(false)
    self._panelItems:setOpacity(0)
    self._panelHead:setVisible(false)
    self._panelSkill:setScale(0)
    local pos_y = self._panelItems:getPositionY()
    self._panelItems:setPositionY(pos_y - 100)
    local text_array = {self._leaderNumAddLabel, self._attNumAddLabel, self._mentalAddNumLabel, self._siegeNumAddLabel}
    local img_array = {self._imgLeader, self._imgForce, self._imgIntel, self._imgSiege}
    local delta = 1 / 12

    local pos_x = self._panelGeneral:getPositionX()
    self._panelGeneral:setPositionX(pos_x - 100)
    local general_action = cc.Spawn:create(cc.MoveBy:create(4 * delta, cc.p(100, 0)), cc.FadeIn:create( 4 * delta))
    self._panelGeneral:runAction(general_action)
    self._panelStar:runAction(cc.Sequence:create(cc.DelayTime:create(4 * delta), cc.CallFunc:create(function()
        self._panelHead:setVisible(true)
        self._panelHead:runAction(cc.Spawn:create(cc.ScaleTo:create(delta, 1), cc.CallFunc:create(function()
            uq.playSoundByID(47)
            uq:addEffectByNode(self._imgHead, 900011, 1, true, cc.p(288, 74))
        end)))


        local generals_xml = StaticData['general'][self._tempId]
        for i = 1, generals_xml.qualityType do
            local image = self._panelStar:getChildByName("Image_" .. i)
            image:runAction(cc.Sequence:create(cc.DelayTime:create(delta * i), cc.CallFunc:create(handler(image, function(image)
                local size = image:getContentSize()
                uq:addEffectByNode(image, 900023, 1, true, cc.p(0, 17.5), nil, 0.4)
                image:loadTexture("img/generals/s03_00006.png")
            end))))
        end
    end)))

    self._panelAttr:runAction(cc.Sequence:create(cc.DelayTime:create(7 * delta), cc.CallFunc:create(function()
        self._panelAttr:setVisible(true)
    end)))
    local items_action = cc.Spawn:create(cc.FadeIn:create(delta * 3), cc.MoveBy:create(delta * 3, cc.p(0, 100)))
    self._panelItems:runAction(cc.Sequence:create(cc.DelayTime:create(8 * delta), items_action, cc.CallFunc:create(function()
        local index = 1
        uq.TimerProxy:addTimer(self._playAnimTag, function()
            local tag = math.floor((index + 1) / 2)
            if index % 2 == 1 then
                uq:addEffectByNode(img_array[tag], 900012, 1, true, cc.p(134, 12))
            else
                text_array[tag]:setVisible(true)
            end
            index = index + 1
        end, delta, 8)
    end)))
    local action = cc.Sequence:create(cc.ScaleTo:create(delta, 0.3), cc.ScaleTo:create(delta, 1.2), cc.ScaleTo:create(delta, 1))
    local skill_action = cc.Spawn:create(action, cc.CallFunc:create(function()
        uq:addEffectByNode(self._imgSkillBg, 900013, 1, true)
    end))
    self._panelSkill:runAction(cc.Sequence:create(cc.DelayTime:create(delta * 19), skill_action))
end

function InsightSuccess:onBtnShowTip(evt)
    if evt.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    local generals_xml = StaticData['general'][self._tempId]
    local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.GENERAL_SKILL_MODULE, {skill_id = generals_xml.skillId})
    local pos_x, pos_y = self._btnShowTips:getPosition()
    local pos = self._nodeTips2:convertToWorldSpace(cc.p(pos_y, pos_y))
    panel:setPosition(pos)
end

function InsightSuccess:updateBaseInfo()
    local generals_xml = StaticData['general'][self._tempId]
    if not generals_xml then
        uq.log("error InsightSuccess updateBaseInfo")
        return
    end
    local pre_generals_xml = StaticData['general'][self._preGeneralId]
    if not pre_generals_xml then
        uq.log("error InsightSuccess updateBaseInfo")
        return
    end

    local state = pre_generals_xml.skill_id == generals_xml.skill_id
    self._nodeTips1:setVisible(state)
    self._nodeTips2:setVisible(not state)

    self._leaderNumLabel:setString(pre_generals_xml.leader)
    self._attNumLabel:setString(pre_generals_xml.strength)
    self._mentalNumLabel:setString(pre_generals_xml.intellect)
    self._soldierNumLabel:setString(pre_generals_xml.soldierNum)
    self._siegeNumLabel:setString(pre_generals_xml.siege)

    self._leaderNumAddLabel:setString(string.format(StaticData['local_text']['general.insight.desc11'], generals_xml.leader, generals_xml.leader - pre_generals_xml.leader))
    self._attNumAddLabel:setString(string.format(StaticData['local_text']['general.insight.desc11'], generals_xml.strength, generals_xml.strength - pre_generals_xml.strength))
    self._mentalAddNumLabel:setString(string.format(StaticData['local_text']['general.insight.desc11'], generals_xml.intellect, generals_xml.intellect - pre_generals_xml.intellect))
    self._soldierNumAddLabel:setString(string.format(StaticData['local_text']['general.insight.desc11'], generals_xml.soldierNum, generals_xml.soldierNum - pre_generals_xml.soldierNum))
    self._siegeNumAddLabel:setString(string.format(StaticData['local_text']['general.insight.desc11'], generals_xml.siege, generals_xml.siege - pre_generals_xml.siege))
    local pre_path = "animation/spine/" .. generals_xml.imageId .. '/' .. generals_xml.imageId
    local scale = 0.8
    if cc.FileUtils:getInstance():isFileExist(pre_path .. '.skel') then
        local anim = sp.SkeletonAnimation:createWithBinaryFile(pre_path .. '.skel', pre_path .. '.atlas', 1)
        anim:setAnimation(0, 'idle', true)
        anim:setScale(generals_xml.imageRatio * scale)
        anim:setPosition(cc.p(generals_xml.imageX * scale - 150, generals_xml.imageY * scale - 30))
        self._nodeGeneral:addChild(anim)
    else
        local img = ccui.ImageView:create(pre_path .. '.png')
        self._nodeGeneral:addChild(img)
        img:setAnchorPoint(cc.p(0.5, 1))
        local size = self._nodeGeneral:getContentSize()
        img:setScale(generals_xml.imageRatio * scale)
        img:setPosition(cc.p(size.width * 0.5 + generals_xml.imageX * scale - 70, size.height + generals_xml.imageY * scale + 30))
    end
end

function InsightSuccess:dispose()
    uq.TimerProxy:removeTimer(self._playAnimTag)
    InsightSuccess.super.dispose(self)
    display.removeUnusedSpriteFrames()
end

return InsightSuccess