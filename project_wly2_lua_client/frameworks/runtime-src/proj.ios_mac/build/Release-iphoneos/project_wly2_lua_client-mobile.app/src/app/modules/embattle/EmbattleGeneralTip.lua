local EmbattleGeneralTip = class("EmbattleGeneralTip", require('app.base.ChildViewBase'))

EmbattleGeneralTip.RESOURCE_FILENAME = "embattle/EmbattleTip.csb"
EmbattleGeneralTip.RESOURCE_BINDING = {
    ["label_skill_name"]        = {["varname"] = "_txtSkillName"},
    ["Panel_2"]                 = {["varname"] = "_panelGeneral"},
    ["node_img"]                = {["varname"] = "_imgNode"},
    ["ScrollView_1_0"]          = {["varname"] = "_soldierScrollView"},
    ["skill_desc_1"]            = {["varname"] = "_soldierDesc"},
    ["Text_27"]                 = {["varname"] = "_soldierName"},
    ["Panel_eff"]               = {["varname"] = "_effNode"},
    ["Panel_1"]                 = {["varname"] = "_panelCurValue"},
    ["skill_desc"]              = {["varname"] = "_txtDescSkill"},
    ["Node_1"]                  = {["varname"] = "_nodeTop"},
    ["Image_55"]                = {["varname"] = "_nodeBaseImg"},
    ["Button_30"]               = {["varname"] = "_btnChange",["events"] = {{["event"] = "touch",["method"] = "onBtnRebuild"}}},
}

function EmbattleGeneralTip:ctor(name, params)
    EmbattleGeneralTip.super.ctor(self, name, params)
    self:parseView()
    self._bgHalfSize = self._nodeBaseImg:getContentSize().width * 0.5
    self._effNode:setScale(0.9)
    self._textArray = {}
    for i = 1, 6 do
        local panel = self._panelCurValue:getChildByName("Panel_6_" .. i)
        local text = panel:getChildByName("text")
        table.insert(self._textArray, text)
    end
    self._baseSize = self._nodeBaseImg:getContentSize()
end

function EmbattleGeneralTip:setTipPosition(pos)
    local off_x = 0
    if pos.x < self._bgHalfSize then
        off_x = pos.x - self._bgHalfSize
        pos.x = self._bgHalfSize
    elseif pos.x > CC_DESIGN_RESOLUTION.width - self._bgHalfSize then
        off_x = pos.x > (CC_DESIGN_RESOLUTION.width - self._bgHalfSize)
        pos.x = CC_DESIGN_RESOLUTION.width - self._bgHalfSize
    end

    self:setPosition(pos)
end

function EmbattleGeneralTip:setInfoData(info)
    self._roleInfo = info
    local soldier_xml1 = StaticData['soldier'][self._roleInfo.battle_soldier_id]
    if soldier_xml1 == nil then
        uq.log("error ArmsResInfoItem updateBaseInfo  soldier_xml1")
        return
    end

    local state = info.soldierId1 == nil or info.soldierId2 == nil
    self._btnChange:setVisible(not state)
    self._soldierName:setString(soldier_xml1.name)
    local skill_xml = StaticData['skill'][self._roleInfo.skill_id]
    if not skill_xml then
        return
    end
    self._txtSkillName:setString(skill_xml.name)
    self._txtDescSkill:setContentSize(cc.size(360, 80))
    self._txtDescSkill:ignoreContentAdaptWithSize(false)
    self._txtDescSkill:setHTMLText(skill_xml.tooltip, nil, nil, nil, true)
    local height = self._txtDescSkill:getContentSize().height
    local delta = height - 50
    self._nodeBaseImg:setContentSize(cc.size(self._baseSize.width, self._baseSize.height + delta))
    self._nodeTop:setPositionY(delta)

    local scroll_size = self._soldierScrollView:getContentSize()
    self._soldierDesc:setTextAreaSize(cc.size(scroll_size.width, 0))
    self._soldierDesc:setString(soldier_xml1.Content)
    local soldier_size = self._soldierDesc:getContentSize()
    if scroll_size.height < soldier_size.height then
        self._soldierDesc:setPositionY(soldier_size.height)
        self._soldierScrollView:setInnerContainerSize(soldier_size)
    end
    local skill_des = string.split(skill_xml.skillType, ',')
    self._imgNode:removeAllChildren()
    for i = 1, #skill_des do
        local img_icon = StaticData['types'].SkillType[1].Type[tonumber(skill_des[i])].icon
        local img = ccui.ImageView:create("img/generals/" .. img_icon)
        local size = img:getContentSize()
        img:setPositionX((size.width + 10) * (i - 1))
        self._imgNode:addChild(img)
    end


    self._effNode:removeAllChildren()
    local group = uq.AnimationManager:getInstance():getAction('idle', soldier_xml1.idleAction)
    self._anim = require('app/modules/battle/ObjectAnimation'):create(self._effNode, group)
    self._anim:setPosition(cc.p(self._effNode:getContentSize().width * 0.5, self._effNode:getContentSize().height * 0.5))
    self._anim:play(uq.config.constant.ACTION_TYPE.ANIMATION_NAME_IDLE, true)
    local scale = soldier_xml1.idleScale or 1
    self._anim:setScale(0.7 * scale)
    self:updateQuality(soldier_xml1)
end

function EmbattleGeneralTip:updateQuality(soldier_xml)
    local attack_arry = StaticData['types'].AttackQuotiety[1].Type
    local rate_array = {
        soldier_xml.leaderAtkRate,
        soldier_xml.strengthAtkRate,
        soldier_xml.intellectAtkRate,
    }
    for k, v in ipairs(rate_array) do
        local info = StaticData.getAttackAndDefInfo(attack_arry, v)
        self._textArray[k]:setString(string.format("%.2f", v))
        if info and info.color and info.color ~= "" then
            self._textArray[k]:setTextColor(uq.parseColor(info.color))
        end
    end

    local def_arry = StaticData['types'].RecoveryQuotiety[1].Type
    rate_array = {
        soldier_xml.leaderDefRate,
        soldier_xml.strengthDefRate,
        soldier_xml.intellectDefRate,
    }
    for k, v in ipairs(rate_array) do
        self._textArray[k + 3]:setString(string.format("%.2f", v))
        local info = StaticData.getAttackAndDefInfo(def_arry, v)
        if info then
            self._textArray[k + 3]:setTextColor(uq.parseColor(info.color))
        end
    end
end

function EmbattleGeneralTip:onBtnRebuild(event)
    if event.name ~= "ended" then
        return
    end
    local soldier_id = self._roleInfo.soldierId1 == self._roleInfo.battle_soldier_id and self._roleInfo.soldierId2 or self._roleInfo.soldierId1
    network:sendPacket(Protocol.C_2_S_GENARAL_SET_BATTLE_SOLDIER, {general_id = self._roleInfo.id, soldier_id = soldier_id})
end

function EmbattleGeneralTip:playEndAction()
    self._view:runAction(cc.FadeOut:create(0.2), cc.CallFunc:create(handler(self, self.dispose)))
end

function EmbattleGeneralTip:dispose()
    self._anim:dispose()
    EmbattleGeneralTip.super.dispose(self)
end

return EmbattleGeneralTip