local GeneralsTips = class("GeneralsTips", require("app.base.PopupBase"))
local EquipItem = require("app.modules.common.EquipItem")

GeneralsTips.RESOURCE_FILENAME = "common/GeneralsTips.csb"

GeneralsTips.RESOURCE_BINDING  = {
    ["Panel_11"]            = {["varname"] = "_panelItem"},
    ["Text_31"]             = {["varname"] = "_txtName"},
    ["Text_32"]             = {["varname"] = "_txtNum"},
    ["Image_23"]            = {["varname"] = "_imgType"},
    ["Text_30"]             = {["varname"] = "_itemDesc"},
    ["label_captain_num"]   = {["varname"] = "_leaderNumLabel"},
    ["label_brains_num"]    = {["varname"] = "_mentalNumLabel"},
    ["label_force_num"]     = {["varname"] = "_attNumLabel"},
    ["label_gongcheng_num"] = {["varname"] = "_battleNumLabel"},
    ["label_general_type"]  = {["varname"] = "_generalSoldierNum"},
    ["ScrollView_1"]        = {["varname"] = "_scrollView"},
    ["label_skillname"]     = {["varname"] = "_skillNameLabel"},
    ["label_skilldes"]      = {["varname"] = "_skillDesLabel"},
    ["Panel_3"]             = {["varname"] = "_panelItems"},
    ["Panel_1"]             = {["varname"] = "_panelSkill"},
    ["Button_4"]            = {["varname"] = "_btnJump1", ["events"] = {{["event"] = "touch", ["method"] = "_onResourceFrom"}}},
    ["Button_1"]            = {["varname"] = "_btnBaseInfo", ["events"] = {{["event"] = "touch", ["method"] = "onSwitch"}}},
    ["Button_1_0"]          = {["varname"] = "_btnInternal", ["events"] = {{["event"] = "touch", ["method"] = "onSwitch"}}},
    ["Text_baseinfo"]       = {["varname"] = "_txtBaseInfo"},
    ["Text_internal"]       = {["varname"] = "_txtInternal"},
    ["Panel_2"]             = {["varname"] = "_panelInfo1"},
    ["Node_1"]              = {["varname"] = "_nodeInternal"},
    ["Image_1"]             = {["varname"] = "_imgBg"},
}

function GeneralsTips:ctor(name, args)
    GeneralsTips.super.ctor(self, name, args)
    self._itemId = args.general_id or 0
    self._type = args._type or uq.config.constant.COST_RES_TYPE.GENERALS
    if self._type == uq.config.constant.COST_RES_TYPE.GENERALS then
        self._generalsId = math.floor(self._itemId / 10)
    else
        self._generalsId = self._itemId
    end
end

function GeneralsTips:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self._openBaseInfo = true
    if self._generalsId == 0 then
        return
    end
    self._imgSkillTypePosX = {-220, -240}
    self:updateInfo()
    self:refreshSwitch()
end

function GeneralsTips:refreshSwitch()
    self._btnBaseInfo:setEnabled(not self._openBaseInfo)
    self._btnInternal:setEnabled(self._openBaseInfo)
    self._panelInfo1:setVisible(self._openBaseInfo)
    self._panelSkill:setVisible(self._openBaseInfo)
    self._nodeInternal:setVisible(not self._openBaseInfo)
    if self._openBaseInfo then
        self._txtBaseInfo:setTextColor(uq.parseColor('#FFFFFF'))
        self._txtInternal:setTextColor(uq.parseColor('#7FB5BF'))
        self._imgBg:loadTexture('img/generals/s03_00234.png')
    else
        self._txtBaseInfo:setTextColor(uq.parseColor('#7FB5BF'))
        self._txtInternal:setTextColor(uq.parseColor('#FFFFFF'))
        self._imgBg:loadTexture('img/generals/s03_00267.png')
    end
end

function GeneralsTips:onSwitch(event)
    if event.name == "ended" then
        self._openBaseInfo = not self._openBaseInfo
        self:refreshSwitch()
    end
end

function GeneralsTips:updateInfo()
    self._panelItem:removeAllChildren()
    local generals_xml = uq.cache.generals:getGeneralDataXML(tonumber(self._generalsId .. 1))
    if not generals_xml then
        uq.log("error generals info  ", self._generalsId .. 1)
        return
    end
    local generals_grade = StaticData['types'].GeneralGrade[1].Type[generals_xml.grade]
    local quality_info = StaticData['types'].ItemQuality[1].Type[tonumber(generals_grade.qualityType)]
    local name = generals_xml.name
    if self._type == uq.config.constant.COST_RES_TYPE.SPIRIT then
        name = name .. StaticData['local_text']['general.spirit.name']
    end
    self._txtName:setString(name)
    self._txtName:setTextColor(uq.parseColor("#" .. quality_info.color))

    self._imgType:loadTexture("img/generals/" .. generals_grade.image)
    self._txtNum:setVisible(self._type == uq.config.constant.COST_RES_TYPE.SPIRIT)
    if self._type == uq.config.constant.COST_RES_TYPE.SPIRIT then
        local num = uq.cache.role:getResNum(self._type, self._generalsId)
        local des = string.format(StaticData['local_text']['general.has.num'], num)
        self._txtNum:setHTMLText(des)
    end
    self._itemDesc:getVirtualRenderer():setLineHeight(30)
    local str = StaticData['types'].Cost[1].Type[uq.config.constant.COST_RES_TYPE.SPIRIT].desc
    self._itemDesc:setString(string.format(str, generals_xml.composeNums, generals_xml.name, generals_xml.name))

    self._panelItem:removeAllChildren()
    local item = EquipItem:create({info = {id = self._itemId, type = self._type}})
    local size = self._panelItem:getContentSize()
    item:setPosition(cc.p(size.width / 2, size.height / 2))
    self._panelItem:addChild(item)

    local skill_data = string.split(generals_xml.skillType, ',')
    for i = 1, #skill_data do
        local data = StaticData['types'].SkillType[1].Type[tonumber(skill_data[i])]
        local img = self._panelSkill:getChildByName("Image_5_" .. i)
        local img1 = self._panelItems:getChildByName("Image_" .. i)
        img:loadTexture("img/generals/" .. data.icon)
        img1:loadTexture("img/generals/" .. data.icon)
        local count = #skill_data > 2 and 2 or #skill_data
        img:setPositionX(self._imgSkillTypePosX[count])
    end
    self._panelSkill:getChildByName("Image_5_2"):setVisible(#skill_data > 1)
    self._panelItems:getChildByName("Image_2"):setVisible(#skill_data > 1)

    local occupation_data = StaticData['types'].Occupation[1].Type[generals_xml.occupationType]
    for i = 1, 2 do
        local soldier_type = occupation_data["soldierId" .. i]
        if soldier_type > 8 then
            soldier_type = StaticData['soldier'][soldier_type].type
        end
        local img = StaticData['types'].Soldier[1].Type[soldier_type].miniIcon2
        self._panelItems:getChildByName("Image_" .. i + 2):loadTexture("img/generals/" .. img)
    end
    self:updateSkill(generals_xml.skillId)
    self._leaderNumLabel:setString(generals_xml.leader)
    self._attNumLabel:setString(generals_xml.strength)
    self._mentalNumLabel:setString(generals_xml.intellect)
    self._battleNumLabel:setString(generals_xml.siege)
    local stgeneral = StaticData['types'].ItemQuality[1].Type[generals_xml.qualityType]
    self._generalSoldierNum:setString(generals_xml.soldierNum)

    self:refreshInteral()
end

function GeneralsTips:refreshInteral()
    local values = uq.cache.generals:getGeneralBuildOfficerPropertyAdd(self._generalsId, true)
    for i = 1, 7 do
        self._nodeInternal:getChildByName('property_' .. i):setString(values[i][1])
        self._nodeInternal:getChildByName('add_' .. i):setString(string.format('（+%s）', tostring(values[i][2])))
    end
end

function GeneralsTips:_onResourceFrom(event)
    if event.name ~= "ended" then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.INSIGHT_RES_FROM_MODULE, {id = self._generalsId, type = uq.config.constant.COST_RES_TYPE.SPIRIT})
end

function GeneralsTips:updateSkill(skill_id)
    local skill_xml = StaticData['skill'][skill_id]
    if not skill_xml then
        return
    end
    local size = self._scrollView:getContentSize()
    local text = ccui.Text:create()
    text:setFontSize(self._skillDesLabel:getFontSize())
    text:setFontName("font/hwkt.ttf")
    text:getVirtualRenderer():setLineHeight(30)
    text:setTextAreaSize(cc.size(size.width, 0))
    text:setString(skill_xml.tooltip)

    local text_size = text:getContentSize()
    self._skillNameLabel:setString(skill_xml.name)
    self._skillDesLabel:setContentSize(cc.size(size.width, text_size.height))
    self._skillDesLabel:setHTMLText(skill_xml.tooltip, nil, nil, nil, true, 30)
end

return GeneralsTips
