local InstanceWarExploreResult = class("InstanceWarExploreResult", require('app.base.PopupBase'))

InstanceWarExploreResult.RESOURCE_FILENAME = "instance_war/InstanceWarCityExplore.csb"
InstanceWarExploreResult.RESOURCE_BINDING = {
    ["Button_1"]     = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onClose"}}},
    ["Button_2"]     = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onClose"}}},
    ["ListView_1_0"] = {["varname"] = "_dropList"},
    ["ListView_1"]   = {["varname"] = "_generalList"},
}

function InstanceWarExploreResult:onCreate()
    InstanceWarExploreResult.super.onCreate(self)
    self:centerView()
    self:parseView()
    self:setLayerColor()
end

function InstanceWarExploreResult:onExit()
    if self._callback then
        self._callback()
    end
    InstanceWarExploreResult.super.onExit(self)
end

function InstanceWarExploreResult:setData(explore_data, callback)
    self._callback = callback
    local node_parent = cc.Node:create()
    local total_width = 0

    local generals = {}
    local resources = {}
    for k, item in ipairs(explore_data.explore_list) do
        for k, general_id in ipairs(item.general_id) do
            table.insert(generals, general_id)
        end
        for k, res in ipairs(item.resources) do
            table.insert(resources, res)
        end
    end

    self._generalList:setScrollBarEnabled(false)
    for k = 1, #generals do
        local widget = ccui.Widget:create()
        widget:setContentSize(cc.size(175, 230))
        widget:setTouchEnabled(true)
        self._generalList:pushBackCustomItem(widget)

        local general_data = uq.cache.instance_war:getGeneralData(generals[k])
        local panel = uq.createPanelOnly('instance_war.InstanceWarGeneralCard')
        panel:setScale(0.75)
        panel:setData(general_data.temp_id)
        panel:setPosition(cc.p(87, 112))
        widget:addChild(panel)
    end

    self._dropList:setScrollBarEnabled(false)
    local num = math.ceil(#resources / 4)
    for i = 1, num do
        local widget = ccui.Widget:create()
        widget:setContentSize(cc.size(545, 100))
        widget:setTouchEnabled(true)
        self._dropList:pushBackCustomItem(widget)
        for j = 1, 4 do
            local index = (i - 1) * 4 + j
            if resources[index] then
                local panel_item = uq.createPanelOnly('instance.DropItem')
                panel_item:setData(string.format('%d;%d;0', resources[index].type, resources[index].value))
                panel_item:setScale(0.8)
                panel_item:setPosition(cc.p(70 + (j - 1) * 135, 50))
                panel_item:setSwallow(false)
                panel_item:setGameMode(uq.config.constant.GAME_MODE.INSTANCE_WAR)
                widget:addChild(panel_item)
            end
        end
    end
end

function InstanceWarExploreResult:onClose(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

return InstanceWarExploreResult