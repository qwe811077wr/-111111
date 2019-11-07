local ArmsValueItem = class("ArmsValueItem", require('app.base.ChildViewBase'))

ArmsValueItem.RESOURCE_FILENAME = "generals/ArmsValueItem.csb"
ArmsValueItem.RESOURCE_BINDING = {
    ["Panel_62"]            = {["varname"] = "_panelDraw"},
    ["Panel_1"]             = {["varname"] = "_panelNode"},
}

function ArmsValueItem:onCreate()
    ArmsValueItem.super.onCreate(self)
    self:parseView()
    self._battleSoldierId = 0
    self._drawNode = cc.DrawNode:create()
    self._panelDraw:addChild(self._drawNode)
    ArmsValueItem._TYPES_EFFECT = {
        uq.config.constant.TYPES_EFFECT.ATTACK_PERCENT,
        uq.config.constant.TYPES_EFFECT.BATTLE_ATTACK_PERCENT,
        uq.config.constant.TYPES_EFFECT.PLAN_ATTACK_PERCENT,
        uq.config.constant.TYPES_EFFECT.PLAN_DEF_PERCENT,
        uq.config.constant.TYPES_EFFECT.BATTLE_DEF_PERCENT,
        uq.config.constant.TYPES_EFFECT.ATTACK_DEF_PERCENT,
    }
    self._imgArray = {}
    for i = 1, 6 do
        local panel = self._panelNode:getChildByName("Panel_6_" .. i)
        local img = panel:getChildByName("img_type")
        table.insert(self._imgArray, img)
    end
end

function ArmsValueItem:setData(battle_soldier_id)
    self._battleSoldierId = battle_soldier_id
    local soldier_xml = StaticData['soldier'][self._battleSoldierId]
    if soldier_xml == nil then
        uq.log("error  ArmsValueItem  soldier_xml",    battle_soldier_id)
        return
    end
    local data_array = {}
    local attack_arry = StaticData['types'].AttackQuotiety[1].Type
    local rate_array = {
        soldier_xml.leaderAtkRate,
        soldier_xml.strengthAtkRate,
        soldier_xml.intellectAtkRate,
    }
    for k, v in ipairs(rate_array) do
        local info = StaticData.getAttackAndDefInfo(attack_arry, v)
        if info then
            local data = StaticData['soldier_grades'].getGrade(info.ident, self._TYPES_EFFECT[k])
            table.insert(data_array, data)
            self._imgArray[k]:loadTexture("img/generals/" .. info.icon)
        end
    end

    local def_arry = StaticData['types'].RecoveryQuotiety[1].Type
    rate_array = {
        soldier_xml.leaderDefRate,
        soldier_xml.strengthDefRate,
        soldier_xml.intellectDefRate,
    }
    for k, v in ipairs(rate_array) do
        local info = StaticData.getAttackAndDefInfo(def_arry, v)
        if info then
            local data = StaticData['soldier_grades'].getGrade(info.ident, self._TYPES_EFFECT[k + 3])
            table.insert(data_array, data)
            self._imgArray[k + 3]:loadTexture("img/generals/" .. info.icon)
        end
    end
    local pPolygonPtArr = {}
    for k, v in ipairs(data_array) do
        local pos_array = string.split(v, ",")
        table.insert(pPolygonPtArr, cc.p(math.floor(tonumber(pos_array[1])), math.floor(tonumber(pos_array[2]))))
    end
    local fillColor = cc.c4f(0.905, 0.909, 0.663, 1)
    self._drawNode:clear()
    self._drawNode:drawPolygon(pPolygonPtArr, #pPolygonPtArr, fillColor, 1, fillColor)
end

function ArmsValueItem:getBattleId()
    return self._battleSoldierId
end

return ArmsValueItem
