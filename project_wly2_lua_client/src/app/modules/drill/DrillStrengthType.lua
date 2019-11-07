local DrillStrengthType = class('DrillStrengthType', require("app.base.ChildViewBase"))

DrillStrengthType.RESOURCE_FILENAME = 'drill/DrillStrengthType.csb'
DrillStrengthType.RESOURCE_BINDING = {
    ["Node_1"]                     = {["varname"] = "_nodeBase"},
    ["Text_1"]                     = {["varname"] = "_txtTitle"},
    ["Text_2"]                     = {["varname"] = "_txtPrecent"},
    ["Image_5"]                    = {["varname"] = "_imgPrecent"},
    ["Panel_1"]                    = {["varname"] = "_panelLocked"},
    ["Image_6"]                    = {["varname"] = "_imgRed"},
    ["Image_2"]                    = {["varname"] = "_imgBg"},
    ["Image_1"]                    = {["varname"] = "_imgSelect"},
}

function DrillStrengthType:ctor(name, params)
    DrillStrengthType.super.ctor(self, name, params)
    self._size = self._imgPrecent:getContentSize()
    self._imgBg:setTouchEnabled(true)
    self._imgBg:addClickEventListener(handler(self, self.onBtnOk))
    self._imgBg:setSwallowTouches(false)
end

function DrillStrengthType:setInfo(info)
    self._info = info
    if not self._info then
        return
    end
    local data = uq.cache.drill:getSkillTree(self._info.index, self._info.drill_type)
    self._txtTitle:setString(data.desc)
    self:refreshPage()
end

function DrillStrengthType:setCallback(callback)
    self._callBack = callback
end

function DrillStrengthType:refreshPage()
    local skill_info = StaticData['drill_ground'].DrillGround[self._info.index].drillSkill
    local skill_array = string.split(skill_info, '|')
    local limit_level = 0
    for k, v in ipairs(skill_array) do
        local info = string.split(v, ',')
        if tonumber(info[1]) == self._info.drill_type then
            limit_level = tonumber(info[2])
            break
        end
    end
    local info = uq.cache.drill:getDrillInfoById(self._info.index)
    local state = info.level >= limit_level
    self._panelLocked:setVisible(not state)

    local cur_num, total_num = uq.cache.drill:getSkillTypePrecent(self._info.index, self._info.drill_type)
    local percent = total_num == 0 and 0 or cur_num / total_num
    self._txtPrecent:setString(math.floor(percent * 100) .. '%')
    local width = percent * self._size.width
    self._imgPrecent:setContentSize(cc.size(width, self._size.height))

    self._imgRed:setVisible(uq.cache.drill:checkDrillTypeCouldLvl(self._info.index, self._info.drill_type))
end

function DrillStrengthType:onBtnOk(event)
    if self._panelLocked:isVisible() or self._imgSelect:isVisible() then
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    local panel = uq.ModuleManager:getModule(uq.ModuleManager.DRILL_UP_LV)
    if not panel then
        uq.ModuleManager:getInstance():show(uq.ModuleManager.DRILL_UP_LV, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, data = {index = self._info.index, drill_type = self._info.drill_type}})
    else
        if self._callBack then
            self._callBack()
        end
        panel:setInfo(self._info.drill_type)
        self._imgSelect:setVisible(true)
    end
end

function DrillStrengthType:setImgSelectVisible(visible)
    self._imgSelect:setVisible(visible)
end

function DrillStrengthType:getItemContentSize()
    return self._imgBg:getContentSize()
end

function DrillStrengthType:showAction()
    uq.intoAction(self._view)
end

return DrillStrengthType