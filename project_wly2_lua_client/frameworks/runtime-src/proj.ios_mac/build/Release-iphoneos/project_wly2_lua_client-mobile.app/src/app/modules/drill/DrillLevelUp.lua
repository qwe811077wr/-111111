local DrillLevelUp = class("DrillLevelUp", require('app.base.PopupBase'))
local EquipItem = require("app.modules.common.EquipItem")

DrillLevelUp.RESOURCE_FILENAME = 'drill/DrillSkillUp.csb'
DrillLevelUp.RESOURCE_BINDING = {
    ["Text_1"]                = {["varname"] = "_txtTitle"},
    ["Node_1/Text_2"]         = {["varname"] = "_txtLvl"},
    ["att_icon_spr"]          = {["varname"] = "_spriteIcon"},
    ["Node_5"]                = {["varname"] = "_nodeFull"},
    ["Node_4"]                = {["varname"] = "_nodeNormal"},
    ["info_items_node"]       = {["varname"] = "_nodeItems"},
    ["coin_min_txt"]          = {["varname"] = "_txtMinCoin"},
    ["coin_spr"]              = {["varname"] = "_sprCoin"},
    ["Type_1"]                = {["varname"] = "_nodeType1"},
    ["Type_2"]                = {["varname"] = "_nodeType2"},
    ["Node_1"]                = {["varname"] = "_nodeLeftPage"},
    ["Node_10"]               = {["varname"] = "_nodeEffect"},
    ["up_btn"]                = {["varname"] = "_btnLevelUp", ["events"] = {{["event"] = "touch",["method"] = "onLevelUp"}}},
}

function DrillLevelUp:ctor(name, params)
    DrillLevelUp.super.ctor(self, name, params)
    self._info = params.data
    self._data = uq.cache.drill:getDrillInfoById(self._info.index)
end

function DrillLevelUp:init()
    self:setLayerColor()
    self:parseView()
    self:centerView()
    if not self._info then
        return
    end
    self:initPage()
    services:addEventListener(services.EVENT_NAMES.ON_DRILL_SKILL_CHANGE, handler(self, self.onGetLevelUp), 'on_drill_skill_change' .. tostring(self))
end

function DrillLevelUp:onGetLevelUp()
    self:refreshPage()
end

function DrillLevelUp:initPage()
    self._arrItem = {}
    self._scale = 0.7
    for i = 1, 3 do
        local item = EquipItem:create()
        item:setTouchEnabled(true)
        item:setPosition(cc.p(ox, 0))
        item:setScale(self._scale)

        item:addClickEventListenerWithSound(function(sender)
            local info = sender:getEquipInfo()
            uq.showItemTips(info)
        end)
        table.insert(self._arrItem, item)
        self._nodeItems:addChild(item)
    end
    self._spriteIcon:setTexture("img/drill/" .. self._info.icon)
    self._txtTitle:setString(self._info.name)
    self._arrTypeNode = {self._nodeType1, self._nodeType2}
    self:refreshPage(true)
end

function DrillLevelUp:refreshAttStr(data, add_idx, isFull)
    if not data or not data.effectValue or data.effectValue == "" then
        return
    end
    local tab_att = string.split(data.effectValue, "|")
    for i = 1, 2 do
        self._nodeNormal:getChildByName("Node_" .. i):setVisible(tab_att[i] ~= nil)
        self._nodeFull:getChildByName("Node_" .. i):setVisible(tab_att[i] ~= nil)
        if tab_att[i] then
            local tab_str = string.split(tab_att[i], ",")
            if tab_str[1] then
                local node = isFull and self._nodeFull:getChildByName("Node_" .. i) or self._nodeNormal:getChildByName("Node_" .. i)
                local tab_types = StaticData['bosom']['attr_type'][tonumber(tab_str[1])]
                if tab_types and tab_types.display and add_idx == 0 then
                    node:getChildByName("att_" .. i + add_idx .. "_txt"):setString(tab_types.display)
                end
                local str = uq.cache.generals:getNumByEffectType(tonumber(tab_str[1]), tonumber(tab_str[2]))
                node:getChildByName("add_" .. i + add_idx .. "_txt"):setString("+" .. str)
            end
        end
    end
end

function DrillLevelUp:refreshPage(is_init_state)
    if not is_init_state then
        uq:addEffectByNode(self._nodeEffect, 900128, 1, true)
    end
    self._level = uq.cache.drill:getSkillInfoById(self._info.ident, self._data.id)
    local state = self._level >= self._info.maxLevel
    self._nodeFull:setVisible(state)
    self._nodeNormal:setVisible(not state)
    self._txtLvl:setString("Lv." .. self._level)
    for i = 1, self._level do
        self._nodeLeftPage:getChildByName("lv_" .. i .."_img"):setVisible(true)
    end
    self._btnTips = ''

    self:refreshAttStr(self._info.SkillLevel[self._level + 1], 0, state)
    if state then
        return
    end
    self:refreshAttStr(self._info.SkillLevel[self._level + 2], 2, false)
    local items_idx = 1
    local tab_skill = self._info.SkillLevel[self._level + 1] or {}
    if not tab_skill or next(tab_skill) == nil then
        return
    end

    local is_limit = false
    local limit_level = 0
    local pre_type_state = tab_skill.preSkillLimit and tab_skill.preSkillLimit ~= ""
    self._curIndex = 1
    if pre_type_state then
        is_limit = true
        local tab_split = string.split(tab_skill.preSkillLimit, ";")
        for i, v in ipairs(tab_split) do
            local tab_str = string.split(v, ",")
            if tab_str[1] then
                local att_lv = uq.cache.drill:getSkillInfoById(tonumber(tab_str[1]), self._info.index)
                if att_lv >= tonumber(tab_str[2]) then
                    is_limit = false
                    limit_level = tab_str[2]
                    break
                elseif att_lv > 0 then
                    limit_level = tab_str[2]
                end
            end
        end
        self:updateLockedState(self._nodeType1, not is_limit, StaticData['local_text']['drill.before.lv'], limit_level)
        self._curIndex = 2
    end

    if is_limit then
        self._btnTips = StaticData["local_text"]["drill.before.lv.less"]
    end

    if tab_skill.groundLimit then
        if self._data.level < tab_skill.groundLimit then
            self._btnTips = StaticData["local_text"]["drill.lv.less"]
        end
        self:updateLockedState(self._arrTypeNode[self._curIndex], self._data.level >= tab_skill.groundLimit, StaticData['local_text']['drill.lv'], tab_skill.groundLimit)
        self._curIndex = self._curIndex + 1
    end
    for i = self._curIndex, 2 do
        self._arrTypeNode[i]:setVisible(false)
    end

    local tab_award = uq.RewardType.parseRewards(tab_skill.cost)
    local size = self._arrItem[1]:getContentSize()
    local delta = -(size.width * self._scale * (#tab_award - 2)) / 2
    for i = 1, 4 do
        local can_level_up = true
        if i == 1 then
            local award = tab_award[i]:toEquipWidget()
            local info_award = StaticData.getCostInfo(award.type, award.id)
            self._txtMinCoin:setString(tostring(award.num))
            local coin_state = uq.cache.role:checkRes(award.type, award.num, award.id)
            can_level_up = can_level_up and coin_state
            if coin_state then
                self._txtMinCoin:setTextColor(uq.parseColor("#effdff"))
            else
                self._txtMinCoin:setTextColor(uq.parseColor("#ff0000"))
            end
            if info_award.miniIcon and info_award.miniIcon ~= "" then
                self._sprCoin:setTexture("img/common/ui/" .. info_award.miniIcon)
            end
        else
            self._arrItem[i - 1]:setVisible(tab_award[i] ~= nil)
            if tab_award[i] == nil then
                break
            end
            local award = tab_award[i]:toEquipWidget()
            self._arrItem[i - 1]:setPositionX(delta)
            self._arrItem[i - 1]:setInfo(award)
            self._arrItem[i - 1]:showName(true, uq.cache.role:getResNum(award.type, award.id) .. "/" .. award.num)
            local res_state = uq.cache.role:checkRes(award.type, award.num, award.id)
            can_level_up = res_state and can_level_up
            if not res_state then
                self._arrItem[i - 1]:setNameColor(uq.parseColor("#ff0000"))
            else
                self._arrItem[i - 1]:setNameColor(uq.parseColor("#effdff"))
            end
            delta = delta + size.width * self._scale
        end
        if not can_level_up then
            self._btnTips = StaticData["local_text"]["drill.not.enought.res"]
        end
    end
end

function DrillLevelUp:updateLockedState(node, state, str, lvl)
    local txt_limit = node:getChildByName("limit_1_txt")
    local txt_level = node:getChildByName("state_1_txt")
    local img_lock  = node:getChildByName("lock_1_img")
    local img_open  = node:getChildByName("lock_1_img_0")
    txt_limit:setString(str)
    txt_level:setString(lvl .. StaticData['local_text']['label.level2'])
    img_lock:setVisible(not state)
    img_open:setVisible(state)
    if state then
        txt_limit:setTextColor(uq.parseColor("#1CF40C"))
        txt_level:setTextColor(uq.parseColor("#1CF40C"))
    else
        txt_limit:setTextColor(uq.parseColor("#F60A0A"))
        txt_level:setTextColor(uq.parseColor("#F60A0A"))
    end
end

function DrillLevelUp:onLevelUp(event)
    if event.name ~= "ended" then
        return
    end

    if self._btnTips ~= '' then
        uq.fadeInfo(self._btnTips)
    else
        network:sendPacket(Protocol.C_2_S_DRILL_GROUND_SKILL_UP, {id = self._info.ident})
    end
end

function DrillLevelUp:dispose()
    services:removeEventListenersByTag('on_drill_skill_change' .. tostring(self))
    local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.DRILL_UP_LV)
    if panel then
        panel:onLvlUpCallBack()
    end
    DrillLevelUp.super.dispose(self)
end

return DrillLevelUp