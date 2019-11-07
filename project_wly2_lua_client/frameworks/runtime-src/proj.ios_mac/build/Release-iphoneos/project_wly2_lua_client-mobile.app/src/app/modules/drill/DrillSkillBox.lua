local DrillSkillBox = class("DrillSkillBox", require('app.base.ChildViewBase'))

DrillSkillBox.RESOURCE_FILENAME = "drill/DrillSkill.csb"
DrillSkillBox.RESOURCE_BINDING  = {
    ["lv_1_img"]                               = {["varname"] = "_img1"},
    ["lv_2_img"]                               = {["varname"] = "_img2"},
    ["lv_3_img"]                               = {["varname"] = "_img3"},
    ["lv_4_img"]                               = {["varname"] = "_img4"},
    ["lv_5_img"]                               = {["varname"] = "_img5"},
    ["Sprite_1"]                               = {["varname"] = "_spriteIcon"},
    ["img_bg"]                                 = {["varname"] = "_imgBg"},
    ["lock_img"]                               = {["varname"] = "_imgLocked"},
    ["Image_6"]                                = {["varname"] = "_imgRed"},
    ["Node_2"]                                 = {["varname"] = "_nodeEffect"},
    ["click_btn"]                              = {["varname"] = "_btnClick", ["events"] = {{["event"] = "touch",["method"] = "onOpenLvlUp"}}}
}

function DrillSkillBox:ctor(name, params)
    DrillSkillBox.super.ctor(self, name, params)
end

function DrillSkillBox:refreshPage(info)
    self._info = info.info
    self._info.index = info.index
    self._spriteIcon:setTexture("img/drill/" .. self._info.icon)
    self._openLimit = info.open_ground_level
    self._openLevel = info.open_skill
    self._groundLimit = info.ground_limit_level
    self._levelLimit = info.skill_limit_level
    self._name = info.name

    for i = 1, 5 do
        self["_img" .. i]:setVisible(i <= info.lvl)
    end

    local state = self._openLimit and self._openLevel
    self._imgBg:setVisible(state)
    if info.lvl >= 5 then
        self._imgRed:setVisible(false)
    else
        self._imgRed:setVisible(uq.cache.drill:checkDrillCouldLvl(self._info.SkillLevel[info.lvl + 1], nil, self._info.index))
    end
end

function DrillSkillBox:setLockState(visible)
    self._imgLocked:setVisible(visible)
end

function DrillSkillBox:playUnlocked()
    uq:addEffectByNode(self._nodeEffect, 900130, 1, true)
    self._imgLocked:runAction(cc.Sequence:create(cc.DelayTime:create(9 / 12), cc.CallFunc:create(function()
        self._imgLocked:setVisible(false)
    end)))
end

function DrillSkillBox:getBgState()
    return self._imgBg:isVisible()
end

function DrillSkillBox:getLockedState()
    return self._imgLocked:isVisible()
end

function DrillSkillBox:getSkillInfo()
    return self._info
end

function DrillSkillBox:onOpenLvlUp(event)
    if event.name ~= "ended" then
        return
    end
    if not self._openLimit then
        uq.fadeInfo(string.format(StaticData["local_text"]["drill.skill.condition.not.open1"], self._name, self._groundLimit))
    elseif not self._openLevel then
        uq.fadeInfo(string.format(StaticData["local_text"]["drill.skill.condition.not.open2"], self._levelLimit))
    else
        uq.ModuleManager:getInstance():show(uq.ModuleManager.DRILL_OPEN_LEVEL_UP, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, data = self._info})
    end
end

return DrillSkillBox