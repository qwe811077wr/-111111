local AreaCity = class("AreaCity", require('app.base.ChildViewBase'))

AreaCity.RESOURCE_FILENAME = "area/AreaCity.csb"
AreaCity.RESOURCE_BINDING = {
    ["Image_1"]  ={["varname"]="_imgCity",["events"]={{["event"]="touch",["method"]="onCityTouch"}}},
    ["Text_1_0"] ={["varname"]="_txtFlagName"},
    ["Text_1"]   ={["varname"]="_txtPlayerName"},
}

function AreaCity:onCreate()
    AreaCity.super.onCreate(self)
end

function AreaCity:setData(data)
    self._cityData  = data
    self._txtFlagName:setString(data.flagName)
    self._txtPlayerName:setString(data.playerName .. ' lv' .. data.owner_lvl)

    if data.city_skin == 0 then
        self._imgCity:loadTexture('img/areaicon/qycc_10.png')
    else
        local config = StaticData['city_facades'][data.city_skin]
        self._imgCity:loadTexture('img/areaicon/' .. config.file .. '.png')
    end
end

function AreaCity:onCityTouch(event)
    if event.name == "ended" then
        local data = {
            world_area_id   = self._cityData.area_index,
            area_zone_index = self._cityData.part_index,
            zone_index      = self._cityData.seq_no,
            name_len        = self._cityData.playerNameLen,
            player_name     = self._cityData.playerName
        }
        network:sendPacket(Protocol.C_2_S_AREA_CITYINFO, data)

        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.AREA_CITY_INFO, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
        if panel then
            panel:setData(self._cityData)
        end
    end
end

return AreaCity