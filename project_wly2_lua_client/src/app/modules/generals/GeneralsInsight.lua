local GeneralsInsight = class("GeneralsInsight", require("app.base.TableViewBase"))
local EquipItem = require("app.modules.common.EquipItem")

GeneralsInsight.RESOURCE_FILENAME = "generals/GeneralsInsight.csb"

GeneralsInsight.RESOURCE_BINDING  = {
    ["Panel_2/Node_1/btn_insight"]                  ={["varname"] = "_btnInsight",["events"] = {{["event"] = "touch",["method"] = "onBtnInsight"}}},
    ["Panel_2/Node_3/label_captain_num_0"]          ={["varname"] = "_leaderNumAddLabel"},
    ["Panel_2/Node_3/label_force_num_0"]            ={["varname"] = "_attNumAddLabel"},
    ["Panel_2/Node_3/label_brains_num_0"]           ={["varname"] = "_mentalAddNumLabel"},
    ["Panel_2/Node_3/label_battlecity_num_0"]       ={["varname"] = "_battleCityAddNumLabel"},
    ["Panel_2/Node_5/label_captain_num"]            ={["varname"] = "_leaderNumLabel"},
    ["Panel_2/Node_5/label_force_num"]              ={["varname"] = "_attNumLabel"},
    ["Panel_2/Node_5/label_brains_num"]             ={["varname"] = "_mentalNumLabel"},
    ["Panel_2/Node_5/label_battlecity_num"]         ={["varname"] = "_battleCityNumLabel"},
    ["Panel_2/Node_4/img_base_soldier_0"]           ={["varname"] = "_soldierAddImg"},
    ["Panel_2/Node_6"]                              ={["varname"] = "_nodeMax"},
    ["Panel_2/Node_5"]                              ={["varname"] = "_nodeBaseLabel"},
    ["Panel_2/skill_name"]                          ={["varname"] = "_skillNameLabel"},
    ["Panel_2/Node_7"]                              ={["varname"] = "_nodeNotMax"},
    ["Panel_2/Node_7/Node_1"]                       ={["varname"] = "_nodeRes"},
    ["Panel_2/Node_7/Node_2"]                       ={["varname"] = "_nodeItems"},
    ["Text_25_0"]                                   ={["varname"] = "_nodeTips1"},
    ["Node_18"]                                     ={["varname"] = "_nodeTips2"},
    ["Node_21"]                                     ={["varname"] = "_nodeItem3"},
    ["Button_3"]                                    ={["varname"] = "_btnShowTips",["events"] = {{["event"] = "touch",["method"] = "onBtnShowTip",["sound_id"] = 0}}},
}
function GeneralsInsight:ctor(name, args)
    GeneralsInsight.super.ctor(self)
end

function GeneralsInsight:init()
    self:parseView()
    self._curInfo = {}
    self:initUi()
    self:initProtocal()
end

function GeneralsInsight:initUi()
    self._btnInsight:setPressedActionEnabled(true)
end

function GeneralsInsight:onBtnInsight(event)
    if event.name ~= "ended" then
        return
    end
    local generals_xml = StaticData['general'][self._curInfo.temp_id]
    local cost_array = string.split(generals_xml.evolutionCost, "|")
    for k,v in pairs(cost_array) do
        local info = string.split(v, ";")
        if not uq.cache.role:checkRes(tonumber(info[1]), tonumber(info[2]), tonumber(info[3])) then
            uq.fadeInfo(StaticData["local_text"]["insight.res.less"])
            return
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CLOSE_TIMER_TRAIN_TIME})
    network:sendPacket(Protocol.C_2_S_GENERAL_EPIPHANY, {general_id = self._curInfo.id})
end

function GeneralsInsight:initProtocal()
    services:addEventListener(services.EVENT_NAMES.ON_CHANGE_GENERALS,handler(self,self._onUpdateDialog),"_onUpdateDialog")
    services:addEventListener(services.EVENT_NAMES.ON_INIT_GENERALS_INFO,handler(self,self._onInitDialog),"_onInitDialogByInsight")
    services:addEventListener(services.EVENT_NAMES.ON_CONSUME_RES_CHANGE,handler(self,self._onUpdateResChange),"_onUpdateResChangeByGeneralsInsight")
end

function GeneralsInsight:_onUpdateResChange()
    self:updateSightRes()
end

function GeneralsInsight:_onInitDialog(evt)--切换tab时，如果界面首次打开需要传入数据
    services:removeEventListenersByTag("_onInitDialogByInsight")
    self._curInfo = evt.data
    self:updateBaseInfo()
    self:updateSightRes()
end

function GeneralsInsight:onBtnShowTip(evt)
    if evt.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    local generals_xml = StaticData['general'][self._curInfo.temp_id]
    local next_general_xml = StaticData['general'][generals_xml.nextId]
    local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.GENERAL_SKILL_MODULE, {skill_id = next_general_xml.skillId})
    local pos_x, pos_y = self._btnShowTips:getPosition()
    local size = panel:getChildByName("Node"):getChildByName("Image_2"):getContentSize()
    local pos = self._nodeTips2:convertToWorldSpace(cc.p(pos_y, pos_y))
    panel:setPosition(cc.p(pos.x - size.width / 2 + 20, pos.y + size.height + 20))
end

function GeneralsInsight:_onUpdateDialog(evt)
    self._curInfo = evt.data
    if self:isVisible() then
        self._isChangeInfo = false
        self:updateBaseInfo()
        self:updateSightRes()
    else
        self._isChangeInfo = true
    end
end

function GeneralsInsight:update(param)
    if self._isChangeInfo then
        self._isChangeInfo = false
        self:updateBaseInfo()
        self:updateSightRes()
    end
end

function GeneralsInsight:updateSightRes()
    local generals_xml = StaticData['general'][self._curInfo.temp_id]
    if not generals_xml or generals_xml.evolutionCost == "" then
        uq.log("error GeneralsInsight updateSightRes")
        return
    end
    local cost_array = uq.RewardType.parseRewards(generals_xml.evolutionCost)
    for i = 1, 2 do
        local panel = self._nodeRes:getChildByName("Panel_5_" .. i)
        local info = cost_array[i]:toEquipWidget()
        local item = panel:getChildByName("item")
        if not item then
            item = EquipItem:create({info = info})
            item:setScale(0.7)
            item:setNameVisible(false)
            item:setTouchEnabled(true)
            item:addClickEventListener(function(sender)
                local info = sender:getEquipInfo()
                uq.ModuleManager:getInstance():show(uq.ModuleManager.INSIGHT_RES_FROM_MODULE, info)
            end)
            panel:addChild(item)
            local size = panel:getContentSize()
            item:setPosition(cc.p(size.width / 2, size.height / 2))
        else
            item:setInfo(info)
        end
        local item_info = StaticData.getCostInfo(info.type, info.id)
        local txt = self._nodeRes:getChildByName("Text_27_" .. i)

        local quality_type = item_info.qualityType
        local name = item_info.name
        if info.type == uq.config.constant.COST_RES_TYPE.SPIRIT then
            local generals_grade = StaticData['types'].GeneralGrade[1].Type[generals_xml.grade]
            name = name .. StaticData['local_text']['general.spirit.name']
            quality_type = generals_grade.qualityType
        end
        local quality_info = StaticData['types'].ItemQuality[1].Type[tonumber(quality_type)]
        if not quality_info then
            return
        end
        txt:setString(name)
        txt:setTextColor(uq.parseColor("#" .. quality_info.color))

        local txt_num = self._nodeRes:getChildByName("Text_28_" .. i)
        local num = uq.cache.role:getResNum(info.type, info.id)
        local des = ''
        if num < info.num then
            des = string.format(StaticData['local_text']['general.insight.desc10'],'#D63D3D' , num, info.num)
        else
            des = string.format(StaticData['local_text']['general.insight.desc10'],'#32D61C' , num, info.num)
        end
        txt_num:setHTMLText(des)
    end
end

function GeneralsInsight:updateBaseInfo()
    local generals_xml = StaticData['general'][self._curInfo.temp_id]
    if not generals_xml then
        uq.log("error GeneralsInsight updateBaseInfo")
        return
    end
    self._leaderNumLabel:setString(generals_xml.leader)
    self._attNumLabel:setString(generals_xml.strength)
    self._mentalNumLabel:setString(generals_xml.intellect)
    self._battleCityNumLabel:setString(generals_xml.siege)
    local stgeneral = StaticData['types'].ItemQuality[1].Type[generals_xml.qualityType]
    local is_max = generals_xml.nextId == 0
    self._nodeNotMax:setVisible(not is_max)
    self._nodeMax:setVisible(is_max)
    if is_max then --已达最高
        self._nodeBaseLabel:setPositionX(-30)
        self._nodeItem3:getChildByName("Image_29"):loadTexture("img/common/general_head/" .. generals_xml.miniIcon)
        local node_star = self._nodeItem3:getChildByName("Node_8")
        for j = 1, generals_xml.qualityType do
            node_star:getChildByName("Image_1_" .. j):loadTexture("img/generals/s03_00006.png")
        end

        self._nodeTips1:setVisible(true)
        self._nodeTips2:setVisible(false)
    else
        self._nodeBaseLabel:setPositionX(-86)
        local next_generals_xml = StaticData['general'][generals_xml.nextId]
        local next_general = StaticData['types'].ItemQuality[1].Type[next_generals_xml.qualityType]
        self._leaderNumAddLabel:setString(next_generals_xml.leader)
        self._attNumAddLabel:setString(next_generals_xml.strength)
        self._mentalAddNumLabel:setString(next_generals_xml.intellect)
        self._battleCityAddNumLabel:setString(next_generals_xml.siege)

        for i = 1, 2 do
            self._nodeItems:getChildByName("Image_29_" .. i):loadTexture("img/common/general_head/" .. generals_xml.miniIcon)
            local node_star = self._nodeItems:getChildByName("Node_8_" .. i)
            for j = 1, 5 do
                if j <= generals_xml.qualityType + i - 1 then
                    node_star:getChildByName("Image_1_" .. j):loadTexture("img/generals/s03_00006.png")
                else
                    node_star:getChildByName("Image_1_" .. j):loadTexture("img/generals/s03_00005.png")
                end
            end
        end

        local state = generals_xml.skillId == next_generals_xml.skillId
        self._nodeTips1:setVisible(state)
        self._nodeTips2:setVisible(not state)
        local skill_xml = StaticData['skill'][next_generals_xml.skillId]
        self._skillNameLabel:setString(skill_xml.name)
    end

    self._btnInsight:setEnabled(not self._curInfo.down)
end

function GeneralsInsight:addEffect(node, ident)
    if node.effect then
        node:removeAllChildren()
    end
    uq:addEffectByNode(node, 900010 + ident * 2, -1, true)
end

function GeneralsInsight:dispose()
    services:removeEventListenersByTag("_onUpdateDialog")
    services:removeEventListenersByTag("_onInitDialogByInsight")
    services:removeEventListenersByTag("_onUpdateResChangeByGeneralsInsight")
end

return GeneralsInsight