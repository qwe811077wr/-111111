local Official = class("Official")

function Official:ctor()
    self._curPrestige = 0
    self._isDrawSalary = 0
    network:addEventListener(Protocol.S_2_C_LOAD_OFFICIALPOSITION, handler(self, self._officialPosition), '_officialPosition')
end

function Official:_officialPosition(msg)
    uq.log('_officialPosition', msg.data)
    self._isDrawSalary = msg.data.IsDrawSalary
    self._curPrestige = msg.data.curCanGetPrestige
    self:refreshPage()
end

function Official:getCanGetSalary()
    return self._isDrawSalary == 1
end

function Official:refreshPage()
    local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.OFFICIAL_MODULE)
    if panel then
        panel:refreshPage()
    end
end

function Official:getNextOfficialConfig()
    local static_data = StaticData['PrestigeCfg']
    for i=1,109 do
        if static_data[i] and self._curPrestige < static_data[i].prestige then
            return static_data[i]
        end
    end
    return nil
end

function Official:getCurOfficialConfig()
    return self:getOfficialConfig(self._curPrestige)
end

function Official:getOfficialConfig(prestige)
    local static_data = StaticData['PrestigeCfg']
    for i = 109, 1, -1 do
        if static_data[i] then
            if prestige >= static_data[i].prestige then
                return static_data[i]
            end
        end
    end
    return nil
end

function Official:getNextConfigGeneralID(country_id)
    local next_config = self:getNextOfficialConfig()
    if next_config then
        if #next_config.Recruit > 0 then
            for _,item in ipairs(next_config.Recruit) do
                if item.countryType == country_id then
                    return item.generalId
                end
            end
        else
            return 0
        end
    else
        return 0
    end
end

return Official