local RandomEventRelationShip = class("RandomEventRelationShip", require('app.base.PopupBase'))

RandomEventRelationShip.RESOURCE_FILENAME = "random_event/RandomBoxReward.csb"
RandomEventRelationShip.RESOURCE_BINDING = {
    ["Text_3"]   = {["varname"] = "_txtTitle"},
    ["Text_1"]   = {["varname"] = "_txtContent"},
    ["Node_1"]   = {["varname"] = "_nodeItem"},
    ["Button_4"] = {["varname"] = "_btnGet",["events"] = {{["event"] = "touch",["method"] = "onGet"}}},
}

function RandomEventRelationShip:onCreate()
    RandomEventRelationShip.super.onCreate(self)
    self:centerView()
    self:setLayerColor(0.4)
    self:parseView()
end

function RandomEventRelationShip:setData(build_id)
    self._buildId = build_id
    local event_id = uq.cache.random_event._randomData[uq.cache.random_event.RANDOM_EVENT_TYPE.RELATION][build_id]
    self._xmlData = StaticData['random_event'].relationship[event_id]
    self._txtTitle:setString(self._xmlData.title)
    self._txtContent:setString(self._xmlData.desc)
    if self._xmlData.type == 1 then
        self._btnGet:setTitleText(StaticData['local_text']['label.receive'])
    else
        self._btnGet:setTitleText(StaticData['local_text']['label.bosom.btn.ok2'])
    end

    local level = uq.cache.role.buildings[build_id].level
    local xml_data = nil
    for k, item in ipairs(StaticData['random_event'].reward) do
        if item.castleMapId == build_id then
            xml_data = item
        end
    end

    local rewards = uq.RewardType.parseRewards(xml_data.allReward[level].Reward)

    local node_parent = cc.Node:create()
    local total_width = 0
    local space = 15
    for i = 1, #rewards do
        local equip_item = require("app.modules.common.EquipItem"):create({info = rewards[i]:toEquipWidget()})
        equip_item:enableEvent()
        local size = equip_item:getContentSize()
        local x = (i - 1) * (size.width + space) + size.width / 2
        local y = 0
        equip_item:setPosition(cc.p(x, y))
        node_parent:addChild(equip_item)
        total_width = total_width + size.width + space
    end
    total_width = total_width - space
    node_parent:setPositionX(-total_width / 2)
    self._nodeItem:addChild(node_parent)
end

function RandomEventRelationShip:onExit()
    RandomEventRelationShip.super.onExit(self)
end

function RandomEventRelationShip:onGet(event)
    if event.name ~= "ended" then
        return
    end
    network:sendPacket(Protocol.C_2_S_RANDOM_EVENT_BUILD_DRAW, {build_id = self._buildId})
    self:disposeSelf()
end

return RandomEventRelationShip