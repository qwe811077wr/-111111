local GeneralsAttrNode = class("GeneralsAttrNode", require("app.base.TableViewBase"))
local EquipItem = require("app.modules.common.EquipItem")

GeneralsAttrNode.RESOURCE_FILENAME = "generals/GeneralsAttrNode.csb"

GeneralsAttrNode.RESOURCE_BINDING  = {
    ["Panel_1/get_txt"]             ={["varname"] = "_txtGet"},
    ["Panel_1/txt_name"]            ={["varname"] = "_txtName"},
    ["Panel_1/txt_num"]             ={["varname"] = "_txtNum"},
    ["Panel_1/Node_1"]              ={["varname"] = "_generalItemNode"},
    ["img_soldiertype1"]            = {["varname"] = "_imgSoldierType1"},
    ["img_soldiertype2"]            = {["varname"] = "_imgSoldierType2"},
    ["label_soldier_num"]           ={["varname"] = "_soldierNumLabel"},
    ["label_captain_num"]           ={["varname"] = "_leaderNumLabel"},
    ["label_force_num"]             ={["varname"] = "_attNumLabel"},
    ["label_brains_num"]            ={["varname"] = "_mentalNumLabel"},
    ["label_gongcheng_num"]         ={["varname"] = "_battleNumLabel"},
    ["label_skill_name"]            ={["varname"] = "_skillNameLabel"},
    ["label_skilldes"]              ={["varname"] = "_skillDesLabel"},
    ["node_img"]                    ={["varname"] = "_nodeImg"},
    ["Button_1"]                    = {["varname"] = "_btnRight", ["events"] = {{["event"] = "touch",["method"] = "onAccess",["sound_id"] = 0}}},
}

function GeneralsAttrNode:ctor(name, args)
    GeneralsAttrNode.super.ctor(self)
end

function GeneralsAttrNode:init()
    self:parseView()
    self._tabAccess = {}
    self._curGeneralInfo = {}
    self._curPieceNum = 0
    self._curPieceComposeNum = 0
    self:initProtocal()
    self._desLabelWidth = self._skillDesLabel:getContentSize().width
end

function GeneralsAttrNode:initProtocal()
    services:addEventListener(services.EVENT_NAMES.ON_CHANGE_GENERALS, handler(self,self._onUpdateDialog), "_onUpNodedateDialog")
    services:addEventListener(services.EVENT_NAMES.ON_INIT_GENERALS_INFO, handler(self,self._onInitDialog), "_onInitNodeDialogByAttr")
    network:addEventListener(Protocol.S_2_C_GENERAL_COMPOSE, handler(self, self._onPieceCompose), "_onPieceCompose")
end

function GeneralsAttrNode:_onInitDialog(evt)--切换tab时，如果界面首次打开需要传入数据
    services:removeEventListenersByTag("_onInitDialogByAttr")
    self._curGeneralInfo = evt.data
    self._curPieceNum = uq.cache.role:getResNum(uq.config.constant.COST_RES_TYPE.SPIRIT, self._curGeneralInfo.id)
    self:updateBaseInfo()
end

function GeneralsAttrNode:_onPieceCompose(evt)
    if self._curGeneralInfo.temp_id ~= evt.data.temp_id then
        return
    end
    self._curGeneralInfo.unlock = true
    self:updateBaseInfo()
end

function GeneralsAttrNode:_onUpdateDialog(evt)
    self._curGeneralInfo = evt.data
    if self:isVisible() then
        self._isChangeInfo = false
        self:updateBaseInfo()
    else
        self._isChangeInfo = true
    end
end

function GeneralsAttrNode:update(param)
    if self._isChangeInfo then
        self._isChangeInfo = false
        self:updateBaseInfo()
    end
end

function GeneralsAttrNode:onAccess(event)
    if event.name ~= "ended" then
        return
    end
    if not self._tabAccess or next(self._tabAccess) == nil then
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.INSIGHT_RES_FROM_MODULE, self._tabAccess)
end

function GeneralsAttrNode:updateBaseInfo()
    local generals_xml = StaticData['general'][self._curGeneralInfo.temp_id]
    local grade_xml = StaticData['types']['GeneralGrade'][1]['Type'][generals_xml.grade]
    self._curPieceComposeNum = generals_xml.composeNums
    self._curPieceNum = uq.cache.role:getResNum(uq.config.constant.COST_RES_TYPE.SPIRIT, self._curGeneralInfo.id)
    local color_txt = self._curPieceNum < self._curPieceComposeNum and "general.attr.num" or "general.attr.num1"
    self._txtNum:setHTMLText(string.format(StaticData['local_text'][color_txt], self._curPieceNum, self._curPieceComposeNum))
    self._txtName:setString(generals_xml.name .. StaticData['local_text']['general.spirit.name'])
    local equip_node = EquipItem:create({info = {type = uq.config.constant.COST_RES_TYPE.SPIRIT, quality_type = grade_xml.qualityType, id = self._curGeneralInfo.id}})
    equip_node:setScale(0.7)
    self._generalItemNode:addChild(equip_node)
    equip_node:setTouchEnabled(true)
    equip_node:addClickEventListenerWithSound(function(sender)
        local info = sender:getEquipInfo()
        uq.ModuleManager:getInstance():show(uq.ModuleManager.INSIGHT_RES_FROM_MODULE, {["type"] = info.type, ["id"] = info.id, ["curNum"] = self._curPieceNum, ["totalNum"] = self._curPieceComposeNum})
    end)
    local generals_xml = StaticData['general'][self._curGeneralInfo.temp_id]
    self._txtGet:setTextAreaSize(cc.size(560, 0))
    self._txtGet:setString(generals_xml.accessMethod)
    self._leaderNumLabel:setString(tostring(generals_xml.leader))
    self._attNumLabel:setString(tostring(generals_xml.intellect))
    self._mentalNumLabel:setString(tostring(generals_xml.strength))
    self._battleNumLabel:setString(tostring(generals_xml.siege))
    self._soldierNumLabel:setString(tostring(generals_xml.soldierNum))
    self:updateSkill()
    self:updateSoldierInfo()
    self._tabAccess = {["type"] = uq.config.constant.COST_RES_TYPE.SPIRIT, ["id"] = self._curGeneralInfo.id, ["curNum"] = self._curPieceNum, ["totalNum"] = self._curPieceComposeNum}
end

function GeneralsAttrNode:updateSoldierInfo()
    local soldier_xml1 = StaticData['soldier'][self._curGeneralInfo.soldierId1]
    if soldier_xml1 == nil then
        return
    end
    local type_solider1 = StaticData['types'].Soldier[1].Type[soldier_xml1.type]
    self._imgSoldierType1:loadTexture("img/generals/" .. type_solider1.miniIcon2)

    local soldier_xml2 = StaticData['soldier'][self._curGeneralInfo.soldierId2]
    if soldier_xml2 == nil then
        return
    end
    local type_solider2 = StaticData['types'].Soldier[1].Type[soldier_xml2.type]
    self._imgSoldierType2:loadTexture("img/generals/" .. type_solider2.miniIcon2)
end

function GeneralsAttrNode:updateSkill()
    local generals_xml = StaticData['general'][self._curGeneralInfo.temp_id]
    if not generals_xml then
        return
    end
    local skill_xml = StaticData['skill'][generals_xml.skillId]
    if not skill_xml then
        return
    end
    self._skillNameLabel:setString(skill_xml.name)
    local pos_x = self._skillNameLabel:getPositionX()
    local name_size = self._skillNameLabel:getContentSize()
    self._nodeImg:setPositionX(pos_x + name_size.width + 10)
    self._skillDesLabel:setContentSize(cc.size(self._desLabelWidth, 70))
    self._skillDesLabel:setHTMLText(skill_xml.tooltip, nil, nil, nil, true)
    local skill_des = string.split(skill_xml.skillType, ',')
    self._nodeImg:removeAllChildren()
    for i = 1, #skill_des do
        local aa = StaticData['types'].SkillType[1]
        local img_icon = StaticData['types'].SkillType[1].Type[tonumber(skill_des[i])].icon
        local img = ccui.ImageView:create("img/generals/" .. img_icon)
        local size = img:getContentSize()
        img:setPositionX((size.width + 10) * (i - 0.5))
        self._nodeImg:addChild(img)
    end
end


function GeneralsAttrNode:dispose()
    services:removeEventListenersByTag("_onUpNodedateDialog")
    services:removeEventListenersByTag("_onInitNodeDialogByAttr")
    network:removeEventListenerByTag("_onPieceCompose")
end

return GeneralsAttrNode