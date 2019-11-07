local Formation = class("Formation")

Formation.ROLE = {
    ROLE_GENERAL = 1,
    ROLE_BOSOM = 2
}

function Formation:ctor()
    self._allFormationData = nil
    self._allListDown = {} --当前阵型中未上阵的武将信息
    self._roleType = self.ROLE.ROLE_GENERAL --当前布阵显示
    network:addEventListener(Protocol.S_2_C_ALL_FORMATION_INFOS, handler(self, self._formationInfoRet), '_formationInfoRet')
    network:addEventListener(Protocol.S_2_C_SET_DEFAULTFORMATION_RES, handler(self, self._formationConfirmRet), '_formationConfirmRet')
    network:addEventListener(Protocol.S_2_C_FORMATION_GENARAL_CHANGE_RES, handler(self, self._setGeneralForamtion))
    network:addEventListener(Protocol.S_2_C_BOSOM_FRIEND_BATTLE, handler(self, self._setBosomFormation))
end

function Formation:setAllListDown(data, roleType)
    self._allListDown[roleType] = data
end

function Formation:getAllFormation()
    return self._allFormationData
end

function Formation:_formationInfoRet(msg)
    self._allFormationData = msg.data
    self:reFreshPage()
    uq.cache.generals:updataQualityRed()
end

function Formation:getDefaultFormationFirstGeneral()
    local formationData = self:getFormationData(self._allFormationData.default_id)
    if formationData.general_loc[1] then
        return formationData.general_loc[1].general_id
    else
        return 0
    end
end

function Formation:getDefaultFormation()
    if not self._allFormationData then
        return {}
    end
    return self:getFormationData(self._allFormationData.default_id)
end

function Formation:reFreshPage()
    local formationView = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.EMBATTLE_MODULE)
    if formationView then
        formationView:allFormationRet(self._allFormationData)
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_GET_ALL_FORMATION_DATA, data = self._allFormationData})
end

function Formation:getFormationNum()
    self._availableForamtion = {}
    for k, formation in pairs(self._allFormationData.formations) do
        if formation.lvl >= 1 then
            table.insert(self._availableForamtion, formation)
        end
    end
    return #self._availableForamtion
end

function Formation:setFormationLevel(id, lvl)
    for k, formation in pairs(self._allFormationData.formations) do
        if formation.formation_id == id then
            self._allFormationData.formations[k].lvl = lvl
        end
    end
end

function Formation:getFormationIdByIndex(index)
    if self._availableForamtion[index] then return self._availableForamtion[index].formation_id end
end

function Formation:_setGeneralForamtion(msg)
    local data = msg.data
    local formationDt = self:getFormationData(data.formation_id)
    if data.formation_pos then
        local findGeneral = false
        local bosom_id = self:findBosomDtById(data.formation_id, data.general_id)
        local old_bosom_id = self:findBosomDtById(data.formation_id, data.old_general_id)

        for k, v in pairs(formationDt.general_loc) do
            if data.formation_pos == v.index then
                formationDt.general_loc[k].bosom_id = bosom_id
                formationDt.general_loc[k].general_id = data.general_id
                if data.general_id == 0 then
                    table.remove(formationDt.general_loc, k)
                end
                findGeneral = true
            elseif data.old_pos == v.index then
                formationDt.general_loc[k].bosom_id = old_bosom_id
                formationDt.general_loc[k].general_id = data.old_general_id
                if data.old_general_id == 0 then
                    table.remove(formationDt.general_loc, k)
                end
            end
        end
        if not findGeneral and data.general_id ~= 0 then
            local data = {
                index = data.formation_pos,
                bosom_id = nil,
                general_id = data.general_id
            }
            table.insert(formationDt.general_loc, data)
        end
        formationDt.general_nums = #formationDt.general_loc
    end

    self:setFormationCellData(formationDt)
    self:reFreshPage()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_FORMATION_CHANGES})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_EQUIPMENTINFO})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_ALL_GENERAL_RED})
end

function Formation:findBosomDtById(formation_id, general_id)
    local formationDt = self:getFormationData(formation_id)
    for k, v in pairs(formationDt.general_loc) do
        if v.general_id == general_id then
            return v.bosom_id
        end
    end
    return nil
end

function Formation:_setBosomFormation(msg)
    local data = msg.data
    local formationDt = self:getFormationData(data.formation_id)
    for k, v in pairs(formationDt.general_loc) do
        local findBosom = false
        for _, bosomForamtion in pairs(data.bosom_formation) do
            if bosomForamtion.pos == v.index then
                findBosom = true
                formationDt.general_loc[k].bosom_id = bosomForamtion.bosom_id
                break
            end
        end
        if not findBosom then formationDt.general_loc[k].bosom_id = nil end
    end
    self:setFormationCellData(formationDt)
    self:reFreshPage()
end

function Formation:getDefaultIndex()
    if self._allFormationData then
        return self._allFormationData.default_id
    else
        return 0
    end
end

function Formation:getCurRoleType()
    return self._roleType
end

function Formation:setCurRoleType(role_type)
    self._roleType = role_type
end

function Formation:getBosomShowState()
    if self.ROLE.ROLE_GENERAL == self._roleType then
        return false
    else
        return true
    end
end

function Formation:getIsCanBattle()
    if not self._allFormationData then
        return false
    end

    local formation_data = self:getFormationData(self._allFormationData.default_id)
    if formation_data and formation_data.general_nums > 0 then
        return true
    end
    return false
end

function Formation:getFormationData(formationID)
    if self._allFormationData then
        for _,formationData in ipairs(self._allFormationData.formations) do
            if formationData.formation_id == formationID then
                return formationData
            end
        end
        return nil
    else
        return nil
    end
end

function Formation:setFormationCellData(formationDt)
    if self._allFormationData and formationDt then
        for i, formationData in ipairs(self._allFormationData.formations) do
            if formationData.formation_id == formationDt.formation_id then
                self._allFormationData.formations[i] = formationDt
            end
        end
    end
end

function Formation:checkGeneralIsInFormationById(general_id)
    local is_formation = false
    if not self._allFormationData then
        return is_formation
    end
    for _,formationData in ipairs(self._allFormationData.formations) do
        for k,v in ipairs(formationData.general_loc) do
            if v.general_id == general_id then
                return true
            end
        end
    end
    return is_formation
end

function Formation:checkGeneralIsInDefaultFormation(general_id)
    local formationData = self:getFormationData(self._allFormationData.default_id)
    for k, v in pairs(formationData.general_loc) do
        if v.general_id == general_id then
            return true
        end
    end
    return false
end

function Formation:getFormationDesc(formid)
    local desc = StaticData['types'].Formation[1].Type[formid].desc
    return desc
end

function Formation:getFormationAdd(formid)
    local formData = self:getFormationData(formid)
    local level = formData and formData.lvl or 0
    local techId = StaticData['formation'][formid].techId
    local add = StaticData['tech'][techId].Effect[level].value
    return add
end

function Formation:getRoleDataNotInFormation(index, role_type)
    return self._allListDown[role_type][index]
end

function Formation:roleDown(role_data, role_type)
    for k, v in pairs(self._allListDown[role_type]) do
        if v.id == role_data.id then
            self._allListDown[role_type][k].state = false
            break
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CHANGE_EMBATTLE})
end

function Formation:checkBosomStateById(bosom_id)
    local formationDt = self:getFormationData(self._allFormationData.default_id)
    if formationDt and formationDt.general_loc then
        for k, v in pairs(formationDt.general_loc) do
            if bosom_id == v.bosom_id then
                return true
            end
        end
    end
    return false
end

function Formation:removeRoleDown(role_data)
    for k,item in ipairs(self._allListDown[self._roleType]) do
        if item.id == role_data.id then
            self._allListDown[self._roleType][k].state = true
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CHANGE_EMBATTLE})
end

function Formation:_formationConfirmRet(msg)
    if msg.data.res == 0 then
        self._allFormationData.default_id = msg.data.formation_id
        services:dispatchEvent({name = services.EVENT_NAMES.ON_FORMATION_CONFIRM, data = self._allFormationData})
        services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_ALL_GENERAL_RED})
    end
end

function Formation:clipHead(sprite_head, node_bg, pos)
    local node_clip = cc.ClippingNode:create()
    local stencil_node = cc.DrawNode:create()
    stencil_node:drawSolidCircle(cc.p(0, 0), 20, math.pi, 50, 1, 1, cc.c4b(1, 0, 0, 1))
    node_clip:setStencil(stencil_node)

    sprite_head:removeFromParent()
    pos = pos or cc.p(0, 0)
    sprite_head:setPosition(pos)

    node_clip:addChild(sprite_head)
    node_clip:setInverted(false)
    node_bg:addChild(node_clip)
end

return Formation