local InstanceWarCityMove = class("InstanceWarCityMove", require('app.base.PopupBase'))

InstanceWarCityMove.RESOURCE_FILENAME = "instance_war/InstanceWarCityMove.csb"
InstanceWarCityMove.RESOURCE_BINDING = {
    ["Text_4_1_0"]   = {["varname"] = "_txtToCityName"},
    ["Node_1"]       = {["varname"] = "_nodeGeneral"},
    ["Text_4_0"]     = {["varname"] = "_txtSolder"},
    ["Text_4_2_0"]   = {["varname"] = "_txtMoveSolder"},
    ["Text_4_2_0_0"] = {["varname"] = "_txtFood"},
    ["Slider_1"]     = {["varname"] = "_slider"},
    ["ListView_1"]   = {["varname"] = "_dropList"},
    ["Button_1"]     = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onClose"}}},
    ["Button_2_0"]   = {["varname"] = "_btnCancle",["events"] = {{["event"] = "touch",["method"] = "onCancle"}}},
    ["Button_2"]     = {["varname"] = "_btnConfirm",["events"] = {{["event"] = "touch",["method"] = "onConfirm"}}},
    ["Button_4"]     = {["varname"] = "_btnDec",["events"] = {{["event"] = "touch",["method"] = "onDec"}}},
    ["Button_4_0"]   = {["varname"] = "_btnAdd",["events"] = {{["event"] = "touch",["method"] = "onAdd"}}},
}

function InstanceWarCityMove:onCreate()
    InstanceWarCityMove.super.onCreate(self)
    self:centerView()
    self:parseView()
    self:setLayerColor()
    self._slider:onEvent(handler(self, self.onSliderChange))
end

function InstanceWarCityMove:setData(from_city, to_city)
    self._slider:setPercent(0)
    self._fromCity = from_city
    self._toCity = to_city
    local city_info = StaticData['instance_city'][to_city]
    self._txtToCityName:setString(city_info.name)

    local city_data = uq.cache.instance_war:getCityData(from_city)
    self._cityData = city_data
    self._txtSolder:setString(city_data.soldier)
    self._generalsPanel = {}

    self._dropList:setScrollBarEnabled(false)
    local num = math.ceil(#city_data.generals / 4)
    for i = 1, num do
        local widget = ccui.Widget:create()
        widget:setContentSize(cc.size(545, 100))
        widget:setTouchEnabled(true)
        self._dropList:pushBackCustomItem(widget)
        for j = 1, 4 do
            local index = (i - 1) * 4 + j
            if city_data.generals[index] then
                local general_data = uq.cache.instance_war:getGeneralData(city_data.generals[index])
                local panel_item = uq.createPanelOnly('instance.DropItem')
                panel_item:setData(string.format('153;%d;%d', 0, general_data.temp_id), uq.config.constant.GAME_MODE.INSTANCE_WAR)
                panel_item:setSwallow(false)
                panel_item:setPosition(cc.p(73 + (j - 1) * 135, 50))
                panel_item:setCheckboxVisible(true)
                panel_item.general_id = city_data.generals[index]
                widget:addChild(panel_item)
                panel_item:setScale(0.8)
                panel_item:setPresssLong()
                panel_item:setListenerSwallow(false)
                panel_item:setGameMode(uq.config.constant.GAME_MODE.INSTANCE_WAR)
                table.insert(self._generalsPanel, panel_item)
                panel_item:setTouch(function()
                    if panel_item:isSelect() then
                        panel_item:setCheckboxSelect(false)
                    else
                        panel_item:setCheckboxSelect(true)
                    end
                end)
            end
        end
    end

    self:refrshPage()
end

function InstanceWarCityMove:onSliderChange(event)
    if event.name == "ON_PERCENTAGE_CHANGED" then
        self:refrshPage()
    end
end

function InstanceWarCityMove:refrshPage()
    self._moveSolder = math.floor(self._slider:getPercent() * self._cityData.soldier / 100)
    self._txtMoveSolder:setHTMLText(string.format("<font color='#00ff0c'>%d</font>/%d", self._moveSolder, self._cityData.soldier))

    local food_total = uq.cache.instance_war:getRes(uq.config.constant.COST_RES_TYPE.FOOD)
    local food = math.ceil(self._moveSolder * 0.1)
    if food > food_total then
        self._txtFood:setHTMLText(string.format("<font color='#ff0000'>%d</font>/%d", food, food_total))
    else
        self._txtFood:setHTMLText(string.format("<font color='#00ff0c'>%d</font>/%d", food, food_total))
    end
end

function InstanceWarCityMove:onClose(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

function InstanceWarCityMove:onCancle(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

function InstanceWarCityMove:onConfirm(event)
    if event.name ~= "ended" then
        return
    end

    self._generals = {}
    for k, item in ipairs(self._generalsPanel) do
        if item:isSelect() then
            table.insert(self._generals, item.general_id)
        end
    end
    local soldier = self._moveSolder

    if soldier == 0 and #self._generals == 0 then
        uq.fadeInfo('没有武将兵力调动')
        return
    end

    local food_total = uq.cache.instance_war:getRes(uq.config.constant.COST_RES_TYPE.FOOD)
    local food = math.ceil(self._moveSolder * 0.1)
    if food > food_total then
        uq.fadeInfo('粮草不足')
        return
    end

    local data = {
        from_city_id = self._fromCity,
        to_city_id = self._toCity,
        soldier = soldier,
        count = #self._generals,
        general_id = self._generals
    }
    network:sendPacket(Protocol.C_2_S_CAMPAIGN_MOVE, data)

    self:disposeSelf()
end

function InstanceWarCityMove:onDec(event)
    if event.name == "ended" then
        self._slider:setPercent(self._slider:getPercent() - 1)
        self:refrshPage()
    end
end

function InstanceWarCityMove:onAdd(event)
    if event.name == "ended" then
        self._slider:setPercent(self._slider:getPercent() + 1)
        self:refrshPage()
    end
end

return InstanceWarCityMove