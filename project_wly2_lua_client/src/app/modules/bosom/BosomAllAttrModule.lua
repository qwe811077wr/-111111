local BosomAllAttrModule = class("BosomAllAttrModule", require('app.base.ModuleBase'))

function BosomAllAttrModule:ctor(name, params)
    BosomAllAttrModule.super.ctor(self, name, params)
end

function BosomAllAttrModule:init()
    self:setView(cc.CSLoader:createNode("bosom/BothAddrAddupView.csb"))
    self:parseView()

    local attrs = {}
    local npc_num = 0

    for k, v in pairs(uq.cache.role.bosom.bosoms) do
        if v.type == uq.config.constant.BOSOM_TYPE.BOSOM then
            npc_num = npc_num + 1
            local base_info = v
            local temp = StaticData['bosom']['women'][k]
            if temp then
                local level = base_info.lvl
                local happy_level = base_info.happy_lvl or 0
                local attrs1 = string.splitString(temp.effectValue, '|')
                local attrs2 = string.splitString(temp.effectValue2, '|')
                if not attrs[temp.attrType] then
                    attrs[temp.attrType] = 0
                end
                attrs[temp.attrType] = tonumber(attrs1[level + 1]) + tonumber(attrs2[happy_level + 1])
            end
        end
    end
    if npc_num <= 0 then
        self._view:getChildByName('attr_container'):setVisible(false)
        self._view:getChildByName('no_bosom_notice'):setVisible(true)
    else
        for i = 1, 6 do
            if not attrs[i] then
                attrs[i] = 0
            end
        end
        local container = self._view:getChildByName('attr_container')
        for k, v in pairs(attrs) do
            local attr_name = container:getChildByName('attr_name_' .. k)
            if attr_name then
                attr_name:setString(StaticData['bosom']['attr_type'][k].name)
                container:getChildByName('attr_value_' .. k):setString(string.format('%+d%%', v))
            end
        end
    end

    if uq.cache.role.bosom.wife_id <= 0 then
        self._view:getChildByName('attr_container_0'):setVisible(false)
        self._view:getChildByName('no_wife_notice'):setVisible(true)
    else
        local container = self._view:getChildByName('attr_container_0')
        local temp = StaticData['bosom']['women'][uq.cache.role.bosom.wife_id]
        local wife_attrs = StaticData['wife']['effect'][temp.qualityType - 2]
        local base_info = uq.cache.role.bosom.bosoms[temp.ident]
        for i = 1, 6 do
            container:getChildByName('attr_name_' .. i):setString(StaticData['bosom']['attr_type'][i].name)
            container:getChildByName('attr_value_' .. i):setString(string.format('%+d%%', wife_attrs[base_info.lvl] * 100))
        end
    end

    local this = self
    local btn = self._view:getChildByName('Panel_1')
    btn:addClickEventListenerWithSound(function()
        this:disposeSelf()
    end)
end

function BosomAllAttrModule:dispose()
    BosomAllAttrModule.super.dispose(self)

    display.removeUnusedSpriteFrames()
end

return BosomAllAttrModule