local BosomAttrModule = class("BosomAttrModule", require('app.base.ModuleBase'))

function BosomAttrModule:ctor(name, params)
    BosomAttrModule.super.ctor(self, name, params)
end

function BosomAttrModule:init()
    self:setView(cc.CSLoader:createNode("bosom/AttrAddupView.csb"))
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

    local this = self
    local btn = self._view:getChildByName('Panel_1')
    btn:addClickEventListenerWithSound(function()
        this:disposeSelf()
    end)
end

function BosomAttrModule:dispose()
    BosomAttrModule.super.dispose(self)

    display.removeUnusedSpriteFrames()
end

return BosomAttrModule