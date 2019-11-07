local InstanceWarEnemyDesc = class("InstanceWarEnemyDesc", require('app.base.PopupBase'))

InstanceWarEnemyDesc.RESOURCE_FILENAME = "instance_war/InstanceWarEnemyDesc.csb"
InstanceWarEnemyDesc.RESOURCE_BINDING = {
    ["Text_2"] = {["varname"] = "_txtDesc"},
}

function InstanceWarEnemyDesc:onCreate()
    InstanceWarEnemyDesc.super.onCreate(self)
    self:centerView()
    self:parseView()
    self:setLayerColor()
end

function InstanceWarEnemyDesc:onExit()
    if self._callBack then
        self._callBack()
    end
    InstanceWarEnemyDesc.super.onExit(self)
end

function InstanceWarEnemyDesc:setData(data, call_back)
    local instance_id = uq.cache.instance_war:getCurInstanceId()

    local city_config = StaticData['instance_city'][data.battle_list[1].from_city]
    local city_data = uq.cache.instance_war:getCityData(data.battle_list[1].from_city)
    local power_data = uq.cache.instance_war:getPowerConfig(instance_id, city_data.power)
    local troop_data = uq.cache.instance_war:getTroopConfig(instance_id, data.battle_list[1].atk[1].troop_id)

    local city_data_self = uq.cache.instance_war:getCityData(data.city_id)
    local power_data_self = uq.cache.instance_war:getPowerConfig(instance_id, city_data_self.power)
    local city_data_self_name = StaticData['instance_city'][data.city_id]
    local troop_data_self = uq.cache.instance_war:getTroopConfig(instance_id, data.battle_list[1].def[1].troop_id)

    local atk_name = ''
    if troop_data then
        atk_name = troop_data.name .. '军'
    elseif #data.battle_list[1].atk[1].generals > 0 then
        local id = data.battle_list[1].atk[1].generals[1]
        local general_data = StaticData['general'][data.battle_list[1].atk[1].generals[1] * 10 + 1]
        atk_name = general_data and general_data.name .. '军' or ''
    end

    local def_name = ''
    if troop_data_self then
        def_name = troop_data_self.name .. '军'
    elseif #data.battle_list[1].def[1].generals > 0 then
        local general_data = StaticData['general'][data.battle_list[1].def[1].generals[1] * 10 + 1]
        def_name = general_data and general_data.name .. '军' or ''
    end

    local power_name_atk = power_data.Name == '玩家' and uq.cache.role.name or power_data.Name
    local power_name_def = power_data_self.Name == '玩家' and uq.cache.role.name or power_data_self.Name

    if power_name_atk == '无' then
        power_name_atk = ''
    else
        power_name_atk = power_name_atk .. '势力'
    end

    if power_name_def == '无' then
        power_name_def = ''
    else
        power_name_def = power_name_def .. '势力'
    end

    self._txtDesc:setString(string.format('%s%s%s攻击%s%s%s!', city_config.name, power_name_atk, atk_name, city_data_self_name.name, power_name_def, def_name))
    self._callBack = call_back
end

return InstanceWarEnemyDesc