local InstanceWarBattleItem = class("InstanceWarBattleItem", require('app.base.ChildViewBase'))

InstanceWarBattleItem.RESOURCE_FILENAME = "instance_war/InstanceWarBattleItem.csb"
InstanceWarBattleItem.RESOURCE_BINDING = {
    ["Text_1"]     = {["varname"]="_txtNameAtt"},
    ["Text_1_1"]   = {["varname"]="_txtNameDef"},
    ["Image_3"]    = {["varname"]="_imgResultAtt"},
    ["Image_3_0"]  = {["varname"]="_imgResultDef"},
    ["Text_1_0"]   = {["varname"]="_txtTroopAtt"},
    ["Text_1_0_0"] = {["varname"]="_txtTroopDef"},
    ["Image_5"]    = {["varname"]="_imgGeneralLeft"},
    ["Image_6"]    = {["varname"]="_imgGeneralRight"},
    ["Node_2"]     = {["varname"]="_nodeTitle"},
    ["Node_3"]     = {["varname"]="_nodeRound"},
    ["Node_1"]     = {["varname"]="_nodeBattle"},
}

function InstanceWarBattleItem:onCreate()
    InstanceWarBattleItem.super.onCreate(self)
    self._nodeTitle:setVisible(false)
    self._nodeRound:setVisible(false)
end

function InstanceWarBattleItem:setData(item, battle_data)
    local city_name = StaticData['instance_city'][battle_data.city_id].name
    self._txtNameAtt:setString(StaticData['instance_city'][item.from_city].name)
    self._txtNameDef:setString(city_name)

    if item.result > 0 then
        self._imgResultAtt:loadTexture('img/instance_war/s04_00296.png')
        self._imgResultDef:loadTexture('img/instance_war/s04_00297.png')
    else
        self._imgResultAtt:loadTexture('img/instance_war/s04_00297.png')
        self._imgResultDef:loadTexture('img/instance_war/s04_00296.png')
    end
    local instance_id = uq.cache.instance_war:getCurInstanceId()
    local troop_data1 = uq.cache.instance_war:getTroopConfig(instance_id, item.atk[1].troop_id)
    local troop_data2 = uq.cache.instance_war:getTroopConfig(instance_id, item.def[1].troop_id)

    if troop_data1 then
        self._txtTroopAtt:setString(troop_data1.name .. '军')
        self._imgGeneralLeft:loadTexture('img/common/half_body/' .. StaticData['general'][troop_data1.Army[1].generalId].skillImage)
    elseif #item.atk[1].generals > 0 then
        local from_city_data = uq.cache.instance_war:getCityConfig(instance_id, item.from_city)
        self._imgGeneralLeft:loadTexture('img/common/half_body/' .. StaticData['general'][from_city_data.showGeneral].skillImage)
        local general_data = StaticData['general'][item.atk[1].generals[1] * 10 + 1]
        if general_data then
            self._txtTroopAtt:setString(general_data.name  .. '军')
        else
            self._txtTroopAtt:setString('无')
        end
    end

    if troop_data2 then
        self._txtTroopDef:setString(troop_data2.name .. '军')
        self._imgGeneralRight:loadTexture('img/common/half_body/' .. StaticData['general'][troop_data2.Army[1].generalId].skillImage)
    elseif #item.def[1].generals > 0 then
        local to_city_data = uq.cache.instance_war:getCityConfig(instance_id, battle_data.city_id)
        self._imgGeneralRight:loadTexture('img/common/half_body/' .. StaticData['general'][to_city_data.showGeneral].skillImage)

        local general_data = StaticData['general'][item.def[1].generals[1] * 10 + 1]
        if general_data then
            self._txtTroopDef:setString(general_data.name .. '军')
        else
            self._txtTroopDef:setString('无')
        end
    end
end

function InstanceWarBattleItem:setListData(item_data)
    self._nodeTitle:setVisible(false)
    self._nodeRound:setVisible(false)
    self._nodeBattle:setVisible(false)

    if item_data.show_type == 1 then
        self._nodeTitle:setVisible(true)
    elseif item_data.show_type == 2 then
        self._nodeRound:setVisible(true)
    elseif item_data.show_type == 3 then
        self._nodeBattle:setVisible(true)
    end
end

return InstanceWarBattleItem