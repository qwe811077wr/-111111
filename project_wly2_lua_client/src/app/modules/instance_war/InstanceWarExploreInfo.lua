local InstanceWarExploreInfo = class("InstanceWarExploreInfo", require('app.base.PopupBase'))

InstanceWarExploreInfo.RESOURCE_FILENAME = "instance_war/InstanceWarCityInfo.csb"
InstanceWarExploreInfo.RESOURCE_BINDING = {
    ["Image_4"]   = {["varname"] = "_btnExplore",["events"] = {{["event"] = "touch",["method"] = "onExplore"}}},
    ["Button_1"]  = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onClose"}}},
    ["Node_13"]   = {["varname"] = "_nodeGeneral"},
    ["Node_13_0"] = {["varname"] = "_nodeItem"},
}

function InstanceWarExploreInfo:onCreate()
    InstanceWarExploreInfo.super.onCreate(self)
    self:centerView()
    self:parseView()
    self:setLayerColor()
end

function InstanceWarExploreInfo:onClose(event)
    if event.name ~= 'ended' then
        return
    end
    self:disposeSelf()
end

function InstanceWarExploreInfo:onExplore(event)
    if event.name ~= 'ended' then
        return
    end

    if self._cityData.power ~= 1 then
        uq.fadeInfo('只能探索己方势力')
        return
    end

    if uq.cache.instance_war._roundExploreCity[self._cityXml.city] then
        uq.fadeInfo('本轮回合已经探索过次城池')
        return
    end

    network:sendPacket(Protocol.C_2_S_CAMPAIGN_EXPLORE, {city_id = self._cityXml.city})
    uq.cache.instance_war._roundExploreCity[self._cityXml.city] = true
    self:disposeSelf()
end

function InstanceWarExploreInfo:setData(city_xml)
    self._cityXml = city_xml
    local city_data = uq.cache.instance_war:getCityData(city_xml.city)
    self._cityData = city_data
    self._generals = self._cityData.out_general

    local node_parent = cc.Node:create()
    local total_width = 0
    for k, item in ipairs(self._generals) do
        local panel = uq.createPanelOnly('instance_war.InstanceWarGeneralCard')
        panel:setScale(0.9)
        local size = panel:getContentSize()
        local x = (k - 1) * (size.width - 25) + size.width / 2
        local y = -10
        panel:setPosition(cc.p(x, y))
        panel:setData(item)
        node_parent:addChild(panel)

        total_width = total_width + size.width - 25
    end
    total_width = total_width + 20
    node_parent:setPositionX(-total_width / 2)
    self._nodeGeneral:addChild(node_parent)


    local rwds = ''
    for i = 1, #city_data.left_resource do
        local item_data = city_data.left_resource[i]
        local item_xml = city_xml.resources[item_data.id]
        local strs = string.split(item_xml.one, ';')
        rwds = rwds .. string.format('%d;%d;%d', tonumber(strs[1]), item_data.num * tonumber(strs[2]), tonumber(strs[3]))
        if i ~= #city_data.left_resource then
            rwds = rwds .. '|'
        end
    end
    local reward_items = uq.RewardType.parseRewards(rwds)
    local reward_node, total_width = uq.rewardToGrid(reward_items, 20, 'instance.DropItem', true)
    reward_node:setPositionX(-total_width / 2)
    self._nodeItem:addChild(reward_node)

    local childs = reward_node:getChildren()
    for k, item in ipairs(childs) do
        item:setGameMode(uq.config.constant.GAME_MODE.INSTANCE_WAR)
    end

    if uq.cache.instance_war._roundExploreCity[self._cityXml.city] or city_data.power ~= 1 then
        --本轮回合已经探索过
        uq.ShaderEffect:setGrayAndChild(self._btnExplore)
    else
        uq.ShaderEffect:setRemoveGrayAndChild(self._btnExplore)
    end
end

return InstanceWarExploreInfo