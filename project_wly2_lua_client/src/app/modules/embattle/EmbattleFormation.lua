local EmbattleFormation = class("EmbattleFormation", require('app.base.ChildViewBase'))

EmbattleFormation.RESOURCE_FILENAME = "embattle/EmbattleFormation.csb"
EmbattleFormation.RESOURCE_BINDING = {
    ["img_formation"]    ={["varname"]="_imgFormation"},
    ["layer_posistions"] ={["varname"]="_layerPosistions"},
}

function EmbattleFormation:ctor()
    EmbattleFormation.super.ctor(self)
    --
    self._tFormationItem = {}    -- 每个位置的士兵
    self._generalConfig = StaticData['general']
    self._soldierConfig = StaticData['soldier']
end

--[[
    @ param： formation_info 阵型信息
]]
function EmbattleFormation:initFormation(formation_info)
    self._imgFormation:loadTexture(string.format("img/embattle/g05_0000%s.png", formation_info.formation_id))
    for _, info in ipairs(formation_info.generals) do
        local pos = info.pos
        local item = uq.createPanelOnly("embattle.EmbattleFormationItem")
        local general_name = self._generalConfig[info.general_id].name
        local soldier_mg = self._soldierConfig[info.soldier_id].file
        item:initItem(general_name, soldier_mg)
        self._layerPosistions:getChildByName(tostring(pos)):addChild(item)
        item:setIndex(pos)
        table.insert(self._tFormationItem, item)
    end
end

function EmbattleFormation:setParent(parent)
    parent:addChild(self)
end

function EmbattleFormation:setPos(posX, posY)
    self:setPosition(cc.p(posX, posY))
end

function EmbattleFormation:dispose()
    for _, item in pairs(self._tFormationItem) do
        item:dispose()
    end
    self._tFormationItem = {}
end

return EmbattleFormation