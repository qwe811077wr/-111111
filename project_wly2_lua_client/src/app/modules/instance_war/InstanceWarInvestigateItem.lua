local InstanceWarInvestigateItem = class("InstanceWarInvestigateItem", require('app.base.ChildViewBase'))

InstanceWarInvestigateItem.RESOURCE_FILENAME = "instance_war/InstanceWarInvestigateItem.csb"
InstanceWarInvestigateItem.RESOURCE_BINDING = {
    ["Text_1"]   = {["varname"]="_txtCityName"},
    ["Text_1_0"] = {["varname"]="_txtTroopName"},
    ["Node_1"]   = {["varname"]="_nodeGeneral"},
    ["Button_1"] = {["varname"] = "_btnInvestigate",["events"] = {{["event"] = "touch",["method"] = "onEmbattle"}}},
}

function InstanceWarInvestigateItem:onCreate()
    InstanceWarInvestigateItem.super.onCreate(self)

end

function InstanceWarInvestigateItem:setData(troop_id, city_id)
    local instance_id = uq.cache.instance_war:getCurInstanceId()
    local troop_data = uq.cache.instance_war:getTroopConfig(instance_id, troop_id)
    self._txtCityName:setString(StaticData['instance_city'][city_id].name)
    self._txtTroopName:setString(troop_data.name)

    local space = 0
    local node_parent = cc.Node:create()
    local total_width = 0
    for k, item in ipairs(troop_data.Army) do
        local panel = uq.createPanelOnly("instance.NpcGuideListItem")
        local size = panel:getContentSize()
        local x = (k - 1) * (size.width + space) + size.width / 2
        local y = 0
        panel:setPosition(cc.p(x, y))
        panel:setData({item.generalId, 1, item.generalId})
        panel:setScale(0.9)
        node_parent:addChild(panel)
        total_width = total_width + size.width + space
    end
    total_width = total_width - space
    node_parent:setPositionX(-total_width / 2)
    self._nodeGeneral:addChild(node_parent)
    self._troopId = troop_id

    local instance_id = uq.cache.instance_war:getCurInstanceId()
    local troop_data = uq.cache.instance_war:getTroopConfig(instance_id, self._troopId)
    local formation_data = StaticData['formation'][troop_data.formationId]
    self._btnInvestigate:loadTextureNormal('img/instance_war/' .. formation_data.button1)
    self._btnInvestigate:loadTextureDisabled('img/instance_war/' .. formation_data.button1)
end

function InstanceWarInvestigateItem:onEmbattle(event)
    if event.name ~= "ended" then
        return
    end

    local army_data = {
        ids    = {1},
        array  = {'army_1'},
        army_1 = {}
    }

    local instance_id = uq.cache.instance_war:getCurInstanceId()
    local troop_data = uq.cache.instance_war:getTroopConfig(instance_id, self._troopId)
    local enemy_data = troop_data.Army
    local data = {
        army_data = {army_data},
        enemy_data = enemy_data,
        embattle_type = uq.config.constant.TYPE_EMBATTLE.ENEMY,
    }
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ARRANGED_BEFORE_WAR, data)
end

return InstanceWarInvestigateItem