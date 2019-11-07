local InstanceWarPopMenu = class("InstanceWarPopMenu", require('app.base.ChildViewBase'))

InstanceWarPopMenu.RESOURCE_FILENAME = "instance_war/InstanceWarPopMenu.csb"
InstanceWarPopMenu.RESOURCE_BINDING = {
    ["btn_explore"]     = {["varname"] = "_btnExplore",["events"] = {{["event"] = "touch",["method"] = "onExplore"}}},
    ["btn_battle"]      = {["varname"] = "_btnConquer",["events"] = {{["event"] = "touch",["method"] = "onConquer"}}},
    ["btn_move"]        = {["varname"] = "_btnMove",["events"] = {{["event"] = "touch",["method"] = "onMove"}}},
    ["btn_investigate"] = {["varname"] = "_btnInvestigate",["events"] = {{["event"] = "touch",["method"] = "onInvestigate"}}},
    ["Node_4_1"]        = {["varname"] = "_nodeExplore"},
    ["Node_4_0_0"]      = {["varname"] = "_nodeConquer"},
    ["Node_4_0"]        = {["varname"] = "_nodeInvestigate"},
    ["Node_4"]          = {["varname"] = "_nodeMove"},
}

function InstanceWarPopMenu:onCreate()
    InstanceWarPopMenu.super.onCreate(self)

end

function InstanceWarPopMenu:setData(city_xml, conquer_call, move_call)
    self._cityXml = city_xml
    self._conquerCall = conquer_call
    self._moveCall = move_call
    self._cityData = uq.cache.instance_war:getCityData(city_xml.city)

    if self._cityData.power == 1 then
        self._nodeInvestigate:setVisible(false)
        self._nodeConquer:setVisible(true)
        self._nodeMove:setVisible(true)
        self._nodeExplore:setVisible(true)
        self._nodeConquer:setPosition(cc.p(0, 80))
        self._nodeMove:setPosition(cc.p(86, 9))
        self._nodeExplore:setPosition(cc.p(-85, 8))
    else
        self._nodeInvestigate:setVisible(true)
        self._nodeConquer:setVisible(false)
        self._nodeMove:setVisible(false)
        self._nodeExplore:setVisible(true)
        self._nodeExplore:setPosition(cc.p(-36, 70))
        self._nodeInvestigate:setPosition(cc.p(38, 70))
    end
end

function InstanceWarPopMenu:onExplore(event)
    if event.name ~= 'ended' then
        return
    end
    local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.INSTANCE_WAR_EXPLORE_INFO, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
    panel:setData(self._cityXml)
    self:setVisible(false)
end

function InstanceWarPopMenu:onConquer(event)
    if event.name ~= 'ended' then
        return
    end

    if self._cityData.power ~= 1 then
        uq.fadeInfo('只能从己方势力出征')
        return
    end

    --征战
    if self._conquerCall then
        self._conquerCall()
        self:setVisible(false)
    end
end

function InstanceWarPopMenu:onMove(event)
    if event.name ~= 'ended' then
        return
    end

    if self._cityData.power ~= 1 then
        uq.fadeInfo('只能从己方势力调动')
        return
    end

    if self._moveCall then
        self._moveCall()
        self:setVisible(false)
    end
end

function InstanceWarPopMenu:onInvestigate(event)
    if event.name ~= 'ended' then
        return
    end

    if self._cityData.power == 1 then
        uq.fadeInfo('只能侦查非己方城池')
        return
    end

    network:sendPacket(Protocol.C_2_S_CAMPAIGN_SPY, {city_id = self._cityXml.city})
    self:setVisible(false)
end

return InstanceWarPopMenu