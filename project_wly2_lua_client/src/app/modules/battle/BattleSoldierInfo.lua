local BattleSoldierInfo = class("BattleSoldierInfo", require('app.base.ChildViewBase'))

BattleSoldierInfo.RESOURCE_FILENAME = "battle/SoldierInfo.csb"
BattleSoldierInfo.RESOURCE_BINDING = {
    ["Text_1"]     = {["varname"] = "_txtName"},
    ["Text_1_0"]   = {["varname"] = "_txtSoldier"},
    ["Text_1_0_0"] = {["varname"] = "_txtSkill"},
    ["Text_1_0_1"] = {["varname"] = "_txtSkillDesc"},
}

function BattleSoldierInfo:onCreate()
    BattleSoldierInfo.super.onCreate(self)
end

function BattleSoldierInfo:setData(data)
    local general_config = StaticData['general'][data.id]
    local color_config = StaticData['types']['ItemQuality'][1].Type[general_config.qualityType]
    local soldier_data = StaticData['soldier'][data.soldier_id]
    local skill_data = StaticData['skill'][data.skill_id]

    self._txtName:setString(string.format('%s Lv.%d', data.name, data.level))
    self._txtSoldier:setString(StaticData['local_text']['label.arms'] .. ':' .. soldier_data.name)
    self._txtSkill:setString(skill_data.name)
    self._txtSkillDesc:setString(skill_data.tooltip)
    self._txtSkillDesc:getVirtualRenderer():setLineSpacing(5)
end

function BattleSoldierInfo:updateMoral(cur_moral, max_moral)
    -- local moral = cur_moral > max_moral and max_moral or cur_moral
    -- self._loadMoral:setPercent(cur_moral * 100 / max_moral)
    -- self._txtMoral:setString(math.floor(cur_moral) .. '/' .. max_moral)
    -- self._imgMoralHead:setPositionX(moral / max_moral * 266 - 9)
end

function BattleSoldierInfo:updateHP(cur_hp, max_hp)
    -- local hp = cur_hp > max_hp and max_hp or cur_hp
    -- self._loadHP:setPercent(cur_hp * 100 / max_hp)
    -- self._txtHP:setString(math.floor(cur_hp) .. '/' .. max_hp)
    -- self._imgHPHead:setPositionX(hp / max_hp * 266 - 9)
end

function BattleSoldierInfo:setBuff(buffs)
    -- self._nodeBuff:removeAllChildren()
    -- local index = 0
    -- for k, item in pairs(buffs) do
    --     if item > 0 then
    --         local buff_xml = StaticData['buff'][k]
    --         local buff_icon = self._spriteBuff:clone()
    --         buff_icon:getChildByName('num'):setString(tostring(item))
    --         buff_icon:setVisible(true)
    --         buff_icon:loadTexture('img/battle/' .. buff_xml.buffIcon)
    --         self._nodeBuff:addChild(buff_icon)
    --         buff_icon:setPositionX(-22 - index * 45)
    --         index = index + 1
    --     end
    -- end
end

return BattleSoldierInfo