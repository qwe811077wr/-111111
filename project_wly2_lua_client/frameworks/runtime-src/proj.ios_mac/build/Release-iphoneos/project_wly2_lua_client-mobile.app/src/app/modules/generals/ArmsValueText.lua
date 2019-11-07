local ArmsValueText = class("ArmsValueText", require('app.base.ChildViewBase'))

ArmsValueText.RESOURCE_FILENAME = "generals/ArmsValueText.csb"
ArmsValueText.RESOURCE_BINDING = {
    ["Panel_1"]             = {["varname"] = "_panelNode"},
    ["Text_1"]              = {["varname"] = "_txtAdvantage"},
    ["Text_2"]              = {["varname"] = "_txtDisadvantage"},
    ["Text_3"]              = {["varname"] = "_skilldes"},
    ["Image_6"]             = {["varname"] = "_imgBg"},
}

function ArmsValueText:onCreate()
    ArmsValueText.super.onCreate(self)
    self:parseView()
    self._battleSoldierId = 0
    self._textArray = {}
    for i = 1, 6 do
        local text = self._panelNode:getChildByName("Text_6_" .. i .. '_0')
        table.insert(self._textArray, text)
    end

    local size = self._skilldes:getContentSize()
    self._skilldes:setTextAreaSize(size)
end

function ArmsValueText:setData(battle_soldier_id)
    self._battleSoldierId = battle_soldier_id
    local soldier_xml = StaticData['soldier'][self._battleSoldierId]
    if soldier_xml == nil then
        uq.log("error  ArmsValueText  soldier_xml",    battle_soldier_id)
        return
    end
    self._skilldes:setString(soldier_xml.Content)

    local soldier_type = soldier_xml.type
    local type_info = StaticData['types'].Soldier[1].Type[soldier_type]
    local attack_arry = StaticData['types'].AttackQuotiety[1].Type
    local rate_array = {
        soldier_xml.leaderAtkRate,
        soldier_xml.strengthAtkRate,
        soldier_xml.intellectAtkRate,
    }
    for k, v in ipairs(rate_array) do
        local info = StaticData.getAttackAndDefInfo(attack_arry, v)
        self._textArray[k]:setString(string.format("%.2f", v))
        if info and info.color and info.color ~= "" then
            self._textArray[k]:setTextColor(uq.parseColor(info.color))
        end
    end

    local def_arry = StaticData['types'].RecoveryQuotiety[1].Type
    rate_array = {
        soldier_xml.leaderDefRate,
        soldier_xml.strengthDefRate,
        soldier_xml.intellectDefRate,
    }
    for k, v in ipairs(rate_array) do
        self._textArray[k + 3]:setString(string.format("%.2f", v))
        local info = StaticData.getAttackAndDefInfo(def_arry, v)
        if info then
            self._textArray[k + 3]:setTextColor(uq.parseColor(info.color))
        end
    end

    if type_info then
        if type_info.ke_zhi == "" then
            self._txtAdvantage:setString(StaticData['local_text']['label.none'])
        else
            local des = nil
            local array = string.split(type_info.ke_zhi, ',')
            for k, v in ipairs(array) do
                local data = StaticData['types'].Soldier[1].Type[tonumber(v)]
                if des == nil then
                    des = data.name
                else
                    des = des .. ',' .. data.name
                end
            end
            self._txtAdvantage:setString(des)
        end

        if type_info.bei_kezhi == "" then
            self._txtDisadvantage:setString(StaticData['local_text']['label.none'])
        else
            local des = nil
            local array = string.split(type_info.bei_kezhi, ',')
            for k, v in ipairs(array) do
                local data = StaticData['types'].Soldier[1].Type[tonumber(v)]
                if des == nil then
                    des = data.name
                else
                    des = des .. ',' .. data.name
                end
            end
            self._txtDisadvantage:setString(des)
        end
    end
end

function ArmsValueText:setImgBgVisible(visible)
    self._imgBg:setVisible(visible)
end

function ArmsValueText:getBattleId()
    return self._battleSoldierId
end

return ArmsValueText
