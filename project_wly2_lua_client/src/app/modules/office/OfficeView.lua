local OfficeView = class("OfficeView", require('app.modules.common.BaseViewWithHead'))

OfficeView.RESOURCE_FILENAME = "office/OfficeView.csb"
OfficeView.RESOURCE_BINDING = {
    ["Button_3"]            = {["varname"] = "_btnGet",["events"] = {{["event"] = "touch",["method"] = "onGet"}}},
    ["Text_1"]              = {["varname"] = "_txtAtkAdd"},
    ["Text_1_0"]            = {["varname"] = "_txtDefAdd"},
    ["Text_1_guanzhi"]      = {["varname"] = "_txtOfficial"},
    ["Text_1_0_0_0"]        = {["varname"] = "_txtNextTitle"},
    ["Text_next_atkadd"]    = {["varname"] = "_txtNextAtkAdd"},
    ["Text_next_defadd"]    = {["varname"] = "_txtNextDefAdd"},
    ["Text_need_shengwang"] = {["varname"] = "_txtNeedPre"},
    ["Text_money"]          = {["varname"] = "_txtMoney"},
    ["Text_geste"]          = {["varname"] = "_txtGeste"},
    ["Text_next_canget"]    = {["varname"] = "_txtNextCanGet"},
}

function OfficeView:ctor(name, params)
    OfficeView.super.ctor(self, name, params)
end

function OfficeView:init()
    local coin_group = {
        uq.config.constant.COST_RES_TYPE.MONEY,
        uq.config.constant.COST_RES_TYPE.GOLDEN,
        uq.config.constant.COST_RES_TYPE.GESTE
    }
    self:addShowCoinGroup(coin_group)
    self:centerView()
    self:parseView()
    self:adaptBgSize()

    network:sendPacket(Protocol.C_2_S_LOAD_OFFICIALPOSITION)
end

function OfficeView:refreshPage()
    local next_config = uq.cache.official:getNextOfficialConfig()
    local cur_config = uq.cache.official:getCurOfficialConfig()

    --self._btnGet:setEnabled(uq.cache.official:getCanGetSalary())
    if cur_config then
        self._txtAtkAdd:setString(string.format(StaticData['local_text']['label.official.atkadd'], cur_config.atkDamageRate))
        self._txtDefAdd:setString(string.format(StaticData['local_text']['label.official.defadd'], cur_config.defDamageRate))
        self._txtOfficial:setString(cur_config.name)
    else
        self._txtAtkAdd:setString(string.format(StaticData['local_text']['label.official.atkadd'], 0))
        self._txtDefAdd:setString(string.format(StaticData['local_text']['label.official.defadd'], 0))
        self._txtOfficial:setString(StaticData['local_text']['label.none'])
    end

    local txt_none = StaticData['local_text']['label.none']
    if next_config then
        self._txtNextTitle:setString(next_config.name)
        self._txtNextAtkAdd:setString(string.format(StaticData['local_text']['label.official.atkadd'], next_config.atkDamageRate))
        self._txtNextDefAdd:setString(string.format(StaticData['local_text']['label.official.defadd'], next_config.defDamageRate))
        self._txtNeedPre:setString(next_config.prestige)
        self._txtMoney:setString(next_config.salary)
        self._txtGeste:setString(next_config.jade)
        if next_config.Recruit and #next_config.Recruit > 0 then
            local general_id = uq.cache.official:getNextConfigGeneralID(uq.cache.role.country_id)
            local name = uq.cache.generals:getGeneralNameByID(general_id)
            if name then
                self._txtNextCanGet:setString(StaticData['local_text']['label.official.canget'] .. name)
            else
                self._txtNextCanGet:setString(StaticData['local_text']['label.official.canget'] .. txt_none)
            end
        else
            self._txtNextCanGet:setString(StaticData['local_text']['label.official.canget'] .. txt_none)
        end
    else
        self._txtNextTitle:setString(txt_none)
        self._txtNextAtkAdd:setString(string.format(StaticData['local_text']['label.official.atkadd'], 0))
        self._txtNextDefAdd:setString(string.format(StaticData['local_text']['label.official.defadd'], 0))
        self._txtNeedPre:setString('0')
        self._txtMoney:setString('0')
        self._txtGeste:setString('0')
        self._txtNextCanGet:setString(StaticData['local_text']['label.official.canget'] .. txt_none)
    end
end

function OfficeView:onGet(event)
    if event.name == 'ended' then
        network:sendPacket(Protocol.C_2_S_DRAW_SALARY)
    end
end

return OfficeView