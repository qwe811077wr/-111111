local DrillInfoView = class("GeneralShop", require("app.base.TableViewBase"))
local DrillDiffcultyBox = require("app.modules.drill.DrillDiffcultyBox")

DrillInfoView.RESOURCE_FILENAME = "drill/DrillInfoView.csb"
DrillInfoView.RESOURCE_BINDING = {
    ["Node_1"]                 = {["varname"] = "_nodeBase"},
    ["Text_21"]                = {["varname"] = "_txtTitle"},
    ["Image_8"]                = {["varname"] = "_imgTitleBg"},
    ["right_lbr"]              = {["varname"] = "_loadingBar"},
    ["Text_75"]                = {["varname"] = "_txtPrecent"},
    ["Text_5_0"]               = {["varname"] = "_txtLevel"},
    ["Image_7"]                = {["varname"] = "_imgSoldier"},
    ["Node_3"]                 = {["varname"] = "_nodeInfo"},
    ["Button_12"]              = {["varname"] = "_btnOpenSkill", ["events"] = {{["event"] = "touch",["method"] = "onOpenSkill"}}},
    ["Panel_28"]               = {["varname"] = "_panelItem"},
    ["Panel_6"]                = {["varname"] = "_panelLevel"},
}

function DrillInfoView:ctor(name, params)
    DrillInfoView.super.ctor(self, name, params)
    self._curIndex = params.cur_index or 1
    self._typeIndex = params.type_index or 1
end

function DrillInfoView:init()
    services:addEventListener(services.EVENT_NAMES.ON_DRILL_BATTLE_END, handler(self, self.refreshLvlInfo), 'on_drill_battle_end' .. tostring(self))
    services:addEventListener(services.EVENT_NAMES.ON_DRILL_SKILL_CHANGE, handler(self, self.refreshSkillInfo), 'on_drill_skill_change' .. tostring(self))
    self:parseView()
    self:initPage()
end

function DrillInfoView:refreshLvlInfo(data)
    if data and data.data ~= self._curIndex then
        return
    end
    local info = uq.cache.drill:getDrillInfoById(self._curIndex)
    local xml_info = StaticData['drill_ground'].GroundLevel[info.level]
    self._txtLevel:setString("Lv." .. info.level)
    self._txtPrecent:setString(info.exp .. '/' .. xml_info.exp)
    self._loadingBar:setPercent(info.exp / xml_info.exp * 100)

    for k, v in ipairs(self._tabArray) do
        v:updateLvl()
    end
end

function DrillInfoView:initPage()
    self._info = StaticData['drill_ground'].DrillGround
    self._tabArray = {}
    local size = self._panelItem:getContentSize()
    self._panelItem:removeAllChildren()
    local pos_y = size.height
    for i = 1, #self._info do
        local item = uq.createPanelOnly("drill.DrillCardBoxLvl")
        local item_size = item:getItemContentSize()
        item:setCallBack(handler(self, self._onTabChanged))
        item:setInfo(self._info[i])
        item:setPosition(cc.p(size.width / 2, pos_y - item_size.height / 2))
        item:setImgSelectedState(i == 1)
        table.insert(self._tabArray, item)
        self._panelItem:addChild(item)
        pos_y = pos_y - item_size.height + 5
    end

    self._tabTypeArray = {}
    for i = 1, 3 do
        local item = uq.createPanelOnly("drill.DrillStrengthType")
        local size = item:getItemContentSize()
        item:setPosition(cc.p((size.width + 5) * (i - 0.5) - 5, size.height / 2))
        item:setInfo({index = self._curIndex, drill_type = i})
        table.insert(self._tabTypeArray, item)
        self._panelLevel:addChild(item, 4 - i)
    end

    self:refreshPage()
end

function DrillInfoView:_onTabChanged(index)
    for k, v in ipairs(self._tabArray) do
        v:setImgSelectedState(false)
    end
    self._curIndex = index
    self:refreshPage()
end

function DrillInfoView:refreshSkillInfo()
    local tab_att = uq.cache.drill:getAllAttAddByDrillId(self._curIndex)
    local all_att = string.split(self._info[self._curIndex].effectTypeList, ",")
    for i = 1, 12 do
        local txt = self._nodeInfo:getChildByName("att_" .. i .."_txt")
        local add = self._nodeInfo:getChildByName("add_" .. i .."_txt")
        txt:setVisible(all_att[i] ~= nil)
        add:setVisible(all_att[i] ~= nil)
        if all_att[i] then
            local att_type = tonumber(all_att[i])
            local type_info = StaticData['types'].Effect[1].Type[att_type]
            txt:setString(type_info.name)

            local value = tab_att[att_type] or 0
            local add_string = uq.cache.generals:getNumByEffectType(att_type, value)
            add:setString(add_string)
        end
    end
    self:refreshSkillType()
end

function DrillInfoView:refreshSkillType()
    for k, v in ipairs(self._tabTypeArray) do
        v:setInfo({index = self._curIndex, drill_type = k})
    end

    for k, v in ipairs(self._tabArray) do
        v:refreshRed()
    end
end

function DrillInfoView:refreshPage()
    self._txtTitle:setString(self._info[self._curIndex].skillTitle)
    self._imgTitleBg:loadTexture("img/drill/" .. self._info[self._curIndex].bannerImg)

    local soldier_info = StaticData['types'].Soldier[1].Type[self._info[self._curIndex].type]
    self._imgSoldier:loadTexture("img/generals/" .. soldier_info.miniIcon2)
    self:refreshSkillInfo()
    self:refreshLvlInfo()
end

function DrillInfoView:update()
end

function DrillInfoView:onOpenSkill(event)
    if event.name ~= "ended" then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.DRILL_UP_LV, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, data = {index = self._curIndex, drill_type = self._typeIndex}})
end

function DrillInfoView:showAction()
    uq.intoAction(self._nodeBase, cc.p(uq.config.constant.MOVE_DISTANCE, 0))
    uq.intoAction(self._panelItem, cc.p(-uq.config.constant.MOVE_DISTANCE, 0))
    for i, v in ipairs(self._tabArray) do
        v:showAction()
    end
    for i, v in ipairs(self._tabTypeArray) do
        v:showAction()
    end
end

function DrillInfoView:dispose()
    services:removeEventListenersByTag('on_drill_battle_end' .. tostring(self))
    services:removeEventListenersByTag('on_drill_skill_change' .. tostring(self))
    DrillInfoView.super.dispose(self)
end

return DrillInfoView