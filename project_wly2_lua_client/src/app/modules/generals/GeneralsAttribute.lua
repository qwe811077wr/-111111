local GeneralsAttribute = class("GeneralsAttribute", require("app.base.TableViewBase"))
local EquipItem = require("app.modules.common.EquipItem")

GeneralsAttribute.RESOURCE_FILENAME = "generals/GeneralsAttribute.csb"

GeneralsAttribute.RESOURCE_BINDING  = {
    ["label_level"]         = {["varname"] = "_levelLabel"},
    ["Node_1"]              = {["varname"] = "_nodePressure"},
    ["label_cost3"]         = {["varname"] = "_txtCoinNum1"},
    ["img_cost1"]           = {["varname"] = "_imgCoin1"},
    ['img_cost2']           = {["varname"] = "_imgCoin2"},
    ['img_cost3']           = {["varname"] = "_imgCoin3"},
    ["label_cost1"]         = {["varname"] = "_txtGesteNum1"},
    ["label_cost2"]         = {["varname"] = "_txtGesteNum2"},
    ["Node_2"]              = {["varname"] = "_goldNode"},
    ["img_check_bg"]        = {["varname"] = "_checkBg"},
    ["img_check_select"]    = {["varname"] = "_checkSelect"},
    ["label_select"]        = {["varname"] = "_txtSelect"},
    ["img_soldiertype1"]    = {["varname"] = "_imgSoldierType1"},
    ["img_soldiertype2"]    = {["varname"] = "_imgSoldierType2"},
    ["label_soldier_num"]   = {["varname"] = "_soldierNumLabel"},
    ["label_captain_num"]   = {["varname"] = "_leaderNumLabel"},
    ["label_force_num"]     = {["varname"] = "_attNumLabel"},
    ["label_brains_num"]    = {["varname"] = "_mentalNumLabel"},
    ["label_gongcheng_num"] = {["varname"] = "_battleNumLabel"},
    ["label_skill_name"]    = {["varname"] = "_skillNameLabel"},
    ["label_skilldes"]      = {["varname"] = "_skillDesLabel"},
    ["btn_level_up1"]       = {["varname"] = "_btnLevelUp1",["events"] = {{["event"] = "touch",["method"] = "onLevelUp1",["sound_id"] = 0}}},
    ["btn_level_up5"]       = {["varname"] = "_btnLevelUp2",["events"] = {{["event"] = "touch",["method"] = "onLevelUp2",["sound_id"] = 0}}},
    ["node_img"]            = {["varname"] = "_nodeImg"},
    ["Panel_2"]             = {["varname"] = "_pnlBase"},
    ["Image_9"]             = {["varname"] = "_imgInternal",["events"] = {{["event"] = "touch",["method"] = "onInternal",["sound_id"] = 0}}},
    ["btn_down"]            = {["varname"] = "_btnDownRole",["events"] = {{["event"] = "touch",["method"] = "onDownRole"}}},
    ["Button_17"]           = {["varname"] = "_btnAttribute",["events"] = {{["event"] = "touch",["method"] = "onShowAttribute",["sound_id"] = 0}}},
}

function GeneralsAttribute:ctor(name, args)
    GeneralsAttribute.super.ctor(self)
    self._oneToExp = StaticData["general_level"].Info[1].onetoExp
    self._curSelectState = true
    self._canLevelUpOne = false
    self._canLevelUpMore = false
    self._goldNum = 0
end

function GeneralsAttribute:init()
    self:parseView()
    self._curGeneralInfo = {}
    self:initUi()
    self:initProtocal()
end

function GeneralsAttribute:initUi()
    self._checkBg:setTouchEnabled(true)
    self._checkBg:addClickEventListener(function()
        self._curSelectState = not self._curSelectState
        self._checkSelect:setVisible(self._curSelectState)
        self._btnLevelUp1:setEnabled(self._curSelectState or self._gesteState1)
        self._btnLevelUp2:setEnabled(self._curSelectState or self._gesteState2)
        self._goldNode:setVisible(self._curSelectState and self._goldNum > 0)
        self:updateState()
    end)
    self._checkSelect:setVisible(self._curSelectState)
    self._btnLevelUp1:setPressedActionEnabled(true)
    self._btnLevelUp2:setPressedActionEnabled(true)
    self._desLabelWidth = self._skillDesLabel:getContentSize().width

    local coin_xml1 = StaticData['types'].Cost[1].Type[uq.config.constant.COST_RES_TYPE.GESTE]
    if coin_xml1 and coin_xml1.icon then
        self._imgCoin1:loadTexture("img/common/ui/" .. coin_xml1.icon)
        self._imgCoin2:loadTexture("img/common/ui/" .. coin_xml1.icon)
    end

    local coin_xml2 = StaticData['types'].Cost[1].Type[uq.config.constant.COST_RES_TYPE.GOLDEN]
    if coin_xml2 and coin_xml2.icon then
        self._imgCoin3:loadTexture("img/common/ui/" .. coin_xml2.icon)
    end
end

function GeneralsAttribute:onShowAttribute(evt)
    if evt.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.GENERAL_ATTRIBUTE_MODULE)
    if panel then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.GENERAL_ATTRIBUTE_MODULE, {id = self._curGeneralInfo.id})
end

function GeneralsAttribute:onDownRole(evt)
    if evt.name ~= "ended" then
        return
    end
    local info = StaticData['general'][self._curGeneralInfo.temp_id]
    if info.isJiuguan == 0 then
        return
    end
    if uq.cache.generals:checkGeneralIsInFormationById(self._curGeneralInfo.id) then
        uq.fadeInfo(string.format(StaticData['local_text']['general.cannot.down.embattle'], self._curGeneralInfo.name))
    elseif uq.cache.role:checkGeneralIsInBuild(self._curGeneralInfo.id) then
        uq.fadeInfo(string.format(StaticData['local_text']['general.connot.down.build'], self._curGeneralInfo.name))
    else
        local function confirm()
            network:sendPacket(Protocol.C_2_S_GENERAL_DELETE, {general_id = self._curGeneralInfo.id})
        end
        local des = string.format(StaticData['local_text']['tavern.general.downrole.tip1'], self._curGeneralInfo.name)
        local data = {
            content = des,
            tip = StaticData['local_text']['tavern.general.downrole.tip2'],
            confirm_callback = confirm
        }
        uq.addConfirmBox(data)
    end
end

function GeneralsAttribute:updateState()
    self._canLevelUpOne = self._gesteState1
    if not self._canLevelUpOne and (self._curSelectState and self._goldenState1) then
        self._canLevelUpOne = true
    end

    self._canLevelUpMore = self._gesteState2
    if not self._canLevelUpMore and (self._curSelectState and self._goldenState2) then
        self._canLevelUpMore = true
    end
end

function GeneralsAttribute:onLevelUp1(event)
    if event.name ~= "ended" or not self:checkIsCanSuddenFly(1) then
        return
    end
    self:sendSuddenFly(1)
end

function GeneralsAttribute:onLevelUp2(event)
    if event.name ~= "ended" or not self:checkIsCanSuddenFly(self._level) then
        return
    end
    self:sendSuddenFly(self._level)
end

function GeneralsAttribute:checkIsCanSuddenFly(level)
    if self._gameMode == uq.config.constant.GAME_MODE.INSTANCE_WAR then
        if level == 1 then
            if not self._gesteState1 then
                uq.fadeInfo('战功不足')
                return false
            end
        elseif not self._gesteState2 then
            uq.fadeInfo('战功不足')
            return false
        end
    end
    if self._curGeneralInfo.lvl >= uq.cache.role.master_lvl then
        uq.fadeInfo(StaticData['local_text']['train.cannot.levelup'])
        return false
    end

    if self._gameMode == uq.config.constant.GAME_MODE.INSTANCE_WAR then
        return true
    end

    if level == 1 then
        if not self._canLevelUpOne then
            uq.fadeInfo(StaticData['local_text']['train.not.enough.gold'])
            return false
        end
    elseif not self._canLevelUpMore then
        uq.fadeInfo(StaticData['local_text']['train.not.enough.gold'])
        return false
    end
    return true
end

function GeneralsAttribute:sendSuddenFly(level)
    local data = {
        general_id = self._curGeneralInfo.id,
        level      = level
    }
    if self._gameMode == uq.config.constant.GAME_MODE.INSTANCE_WAR then
        network:sendPacket(Protocol.C_2_S_CAMPAIGN_GENERAL_LEVEL_UP, data)
    else
        network:sendPacket(Protocol.C_2_S_SUDDEN_FLIGHT, data)
    end
    uq.playSoundByID(48)
end

function GeneralsAttribute:initProtocal()
    services:addEventListener(services.EVENT_NAMES.ON_CHANGE_GENERALS, handler(self,self._onUpdateDialog), "_onUpdateDialog")
    services:addEventListener(services.EVENT_NAMES.ON_INIT_GENERALS_INFO, handler(self,self._onInitDialog), "_onInitDialogByAttr")
    services:addEventListener(services.EVENT_NAMES.ON_UPDATE_GENERAL_LEVEL, handler(self, self._onLevelUpSuccess), "_onLevelUpSuccess")
    --network:addEventListener(Protocol.S_2_C_SUDDLEN_RES, handler(self, self._onLevelUpSuccess),"_onLevelUpSuccess")
end

function GeneralsAttribute:_onInitDialog(evt)--切换tab时，如果界面首次打开需要传入数据
    services:removeEventListenersByTag("_onInitDialogByAttr")
    self._curGeneralInfo = evt.data
    self._gameMode = evt.mode or uq.config.constant.GAME_MODE.NORMAL
    self._maxLvl = uq.cache.role.master_lvl
    self._curLvl = self._curGeneralInfo.lvl
    self:updateBaseInfo()
    self:updateSkill()
end

function GeneralsAttribute:_onLevelUpSuccess(msg)
    if self._curGeneralInfo.id ~= msg.data.general_id then
        return
    end
    local pre_level = self._curLvl
    local times = self._curGeneralInfo.lvl - pre_level
    local lvl_msg = string.format(StaticData['local_text']["general.level.des"], self._curGeneralInfo.lvl, self._maxLvl)
    self._levelLabel:stopAllActions()
    self._levelLabel:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 2), cc.ScaleTo:create(0.3, 1), nil))
    uq.TimerProxy:removeTimer("on_general_update_level_anim_play")
    uq.TimerProxy:addTimer("on_general_update_level_anim_play", function()
        pre_level = pre_level + 1
        local lvl_msg = string.format(StaticData['local_text']["general.level.des"], pre_level, self._maxLvl)
        self._levelLabel:setHTMLText(lvl_msg)
    end, 0.2 / times, times)
    uq.fadeInfo(StaticData['local_text']['fly.nail.battle.des10'])
    local info = self:calculateLvlAddAttr(self._curGeneralInfo.lvl, pre_level)
    if info and next(info) ~= nil then
        self:runLevelUpAction(info)
    end
    self._curLvl = self._curGeneralInfo.lvl
    self:updateBaseInfo()
end

function GeneralsAttribute:runLevelUpAction(arr_attr)
    local pos = self._view:convertToWorldSpace(cc.p(self._pnlBase:getPosition()))
    local pos_y = -220
    for k, v in ipairs(arr_attr) do
        local xml_data = StaticData['types'].Effect[1].Type[v.id]
        if not xml_data then
            return
        end
        local value = uq.cache.generals:getNumByEffectType(v.id, v.num)
        uq.fadeAttr(xml_data.name .. "+ " .. value, pos.x / 2, display.height / 2 + pos_y, "#ffff00", 28, "fzzzhjt.ttf")
        pos_y = pos_y + 50
    end
end

function GeneralsAttribute:calculateLvlAddAttr(cur_lvl, pre_lvl)
    if not cur_lvl or not pre_lvl then
        return nil
    end
    local pre_data = StaticData['general_level'].GeneralLevel[pre_lvl]
    if not pre_data.attributes or pre_data.attributes == "" then
        return nil
    end
    local arr_pre_attr = {}
    for k, v in ipairs(string.split(pre_data.attributes, ';')) do
        local info = string.split(v, ',')
        arr_pre_attr[tonumber(info[1])] = tonumber(info[2])
    end

    local cur_data = StaticData['general_level'].GeneralLevel[cur_lvl]
    if not cur_data.attributes or cur_data.attributes == "" then
        return nil
    end
    local arr_delta_attr = {}
    for k, v in ipairs(string.split(cur_data.attributes, ';')) do
        local info = string.split(v, ',')
        local pre_attr = arr_pre_attr[tonumber(info[1])] or 0
        local delta = tonumber(info[2]) - pre_attr
        if delta > 0 then
            table.insert(arr_delta_attr, {id = tonumber(info[1]), num = delta})
        end
    end
    return arr_delta_attr
end

function GeneralsAttribute:_onUpdateDialog(evt)
    if evt.data.id ~= self._curGeneralInfo.id then
        self._curLvl = evt.data.lvl
    end

    self._curGeneralInfo = evt.data
    if self:isVisible() then
        self._isChangeInfo = false
        self:updateBaseInfo()
        self:updateSkill()
    else
        self._isChangeInfo = true
    end
end

function GeneralsAttribute:update(param)
    if self._isChangeInfo then
        self._curLvl = self._curGeneralInfo.lvl
        self._isChangeInfo = false
        self:updateBaseInfo()
        self:updateSkill()
    end
end

function GeneralsAttribute:updateBaseInfo()
    self._maxLvl = uq.cache.role.master_lvl
    self._curLvl = self._curGeneralInfo.lvl == 1 and self._curGeneralInfo.lvl or self._curLvl
    local lvl_msg = string.format(StaticData['local_text']["general.level.des"], self._curGeneralInfo.lvl, self._maxLvl)
    self._levelLabel:setHTMLText(lvl_msg)
    self._level = self._maxLvl - self._curGeneralInfo.lvl > 5 and 5 or self._maxLvl - self._curGeneralInfo.lvl
    self._level = self._level > 0 and self._level or 1
    self._btnLevelUp2:getChildByName("label_cost1_0"):setString(string.format(StaticData['local_text']['general.levelup.num'], self._level))

    local general_xml = StaticData['general'][self._curGeneralInfo.temp_id]
    self._btnDownRole:setVisible(general_xml.isJiuguan ~= 0)

    local has_num = uq.cache.role:getResNum(uq.config.constant.COST_RES_TYPE.GESTE)
    local cost_xml = StaticData['general_level'].CostCoef[uq.cache.role.master_lvl]
    if not cost_xml then
        return
    end
    local coef = cost_xml.coef
    self._gesteNum1 = self:getGesteNum(1)
    local one_need_gold = (self._gesteNum1 - has_num) < 0 and 0 or (self._gesteNum1 - has_num)
    self._goldNumOne = one_need_gold * coef
    self._gesteNum2 = self:getGesteNum(self._level)
    local more_need_gold = (self._gesteNum2 - has_num) < 0 and 0 or (self._gesteNum2 - has_num)
    self._goldNum = more_need_gold * coef
    self._txtGesteNum1:setString(self._gesteNum1)
    self._txtGesteNum2:setString(self._gesteNum2)
    self._txtCoinNum1:setString(math.ceil(self._goldNum))

    if self._gameMode == uq.config.constant.GAME_MODE.INSTANCE_WAR then
        self._gesteState1 = uq.cache.instance_war:checkRes(uq.config.constant.COST_RES_TYPE.GESTE, self._gesteNum1)
        self._gesteState2 = uq.cache.instance_war:checkRes(uq.config.constant.COST_RES_TYPE.GESTE, self._gesteNum2)
    else
        self._gesteState1 = uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GESTE, self._gesteNum1)
        self._gesteState2 = uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GESTE, self._gesteNum2)
    end

    self._goldenState1 = uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN, self._goldNumOne)
    self._goldenState2 = uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN, self._goldNum)

    self:setTextColorByState(self._txtGesteNum1, self._gesteState1)
    self:setTextColorByState(self._txtGesteNum2, self._gesteState2)
    self:setTextColorByState(self._txtCoinNum1, self._goldenState2)

    self._goldNode:setVisible(self._curSelectState and self._goldNum > 0)
    self._btnLevelUp1:setEnabled(self._curSelectState or self._gesteState1)
    self._btnLevelUp2:setEnabled(self._curSelectState or self._gesteState2)

    self:updateState()
    local msg = string.format(StaticData['local_text']["general.relive.level"], self._curGeneralInfo.reincarnation_tims)

    self._leaderNumLabel:setString(self._curGeneralInfo.leader)
    self._attNumLabel:setString(self._curGeneralInfo.attack)
    self._mentalNumLabel:setString(self._curGeneralInfo.mental)
    self._battleNumLabel:setString(self._curGeneralInfo.siege)
    self._soldierNumLabel:setString(self._curGeneralInfo.max_soldiers)
    self:updateSoldierInfo()

    if self._gameMode == uq.config.constant.GAME_MODE.INSTANCE_WAR then
        self._checkBg:setVisible(false)
        self._checkSelect:setVisible(false)
        self._txtSelect:setVisible(false)
        self._imgInternal:setVisible(false)
    end
end

function GeneralsAttribute:setTextColorByState(txt_node, state)
    if state then
        txt_node:setTextColor(uq.parseColor("#EFFDFF"))
    else
        txt_node:setTextColor(uq.parseColor("#c7280b"))
    end
end

function GeneralsAttribute:updateSoldierInfo()
    local soldier_xml1 = StaticData['soldier'][self._curGeneralInfo.soldierId1]
    if soldier_xml1 == nil then
        self._imgSoldierType1:setVisible(false)
    else
        local type_solider1 = StaticData['types'].Soldier[1].Type[soldier_xml1.type]
        self._imgSoldierType1:loadTexture("img/generals/" .. type_solider1.miniIcon2)
    end

    local soldier_xml2 = StaticData['soldier'][self._curGeneralInfo.soldierId2]
    if soldier_xml2 == nil then
        self._imgSoldierType2:setVisible(false)
    else
        local type_solider2 = StaticData['types'].Soldier[1].Type[soldier_xml2.type]
        self._imgSoldierType2:loadTexture("img/generals/" .. type_solider2.miniIcon2)
    end
end

function GeneralsAttribute:updateSkill()
    local skill_xml = StaticData['skill'][self._curGeneralInfo.skill_id]
    if not skill_xml then
        return
    end
    self._skillNameLabel:setString(skill_xml.name)
    local pos_x = self._skillNameLabel:getPositionX()
    local name_size = self._skillNameLabel:getContentSize()
    self._nodeImg:setPositionX(pos_x + name_size.width + 50)
    self._skillDesLabel:setContentSize(cc.size(self._desLabelWidth, 40))
    self._skillDesLabel:setTextColor(uq.parseColor("#7fadb4"))
    self._skillDesLabel:setHTMLText(skill_xml.tooltip, nil, nil, nil, true,nil, 30)
    local skill_type = skill_xml.skillType
    if skill_type == "" or not skill_type then
        return
    end
    local skill_des = string.split(skill_type, ',')
    self._nodeImg:removeAllChildren()
    for i = 1, #skill_des do
        local img_icon = StaticData['types'].SkillType[1].Type[tonumber(skill_des[i])].icon
        local img = ccui.ImageView:create("img/generals/" .. img_icon)
        local size = img:getContentSize()
        img:setPositionX((size.width + 10) * (i - 1))
        self._nodeImg:addChild(img)
    end

    local fire = skill_xml.launchMorale / 25
    for i = 1, 4 do
        local node = self._nodePressure:getChildByName("CheckBox_" .. i)
        node:setSelected(i <= fire)
    end
end

function GeneralsAttribute:getGesteNum(level)
    local total_exp = self:getTotalExp(level)
    return math.ceil(total_exp / self._oneToExp)
end

function GeneralsAttribute:getTotalExp(level, start_level)
    local total_exp = 0
    start_level = start_level or self._curGeneralInfo.lvl
    local distance = start_level and start_level - self._curGeneralInfo.lvl or 0
    for i = 0, level - distance - 1 do
        if not StaticData['general_level']['GeneralLevel'][start_level + i] then
            return total_exp
        end
        total_exp = total_exp + StaticData['general_level']['GeneralLevel'][start_level + i].exp
    end
    return total_exp
end

function GeneralsAttribute:dispose()
    services:removeEventListenersByTag("_onUpdateDialog")
    uq.TimerProxy:removeTimer("on_general_update_level_anim_play")
    services:removeEventListenersByTag("_onInitDialogByAttr")
    services:removeEventListenersByTag("_onLevelUpSuccess")
end

function GeneralsAttribute:onInternal(event)
    if event.name == "ended" then
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.GENERAL_INTERNAL, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
        panel:setData(self._curGeneralInfo.temp_id, self._curGeneralInfo.id)
    end
end

return GeneralsAttribute