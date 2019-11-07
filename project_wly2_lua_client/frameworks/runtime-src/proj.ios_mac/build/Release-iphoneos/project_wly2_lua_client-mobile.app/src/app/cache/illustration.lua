local Illustration = class("Illustration")

function Illustration:ctor()
    self.illustration_info = nil
    self.action_over = true
    self.isActive = false
    network:addEventListener(Protocol.S_2_C_ILLUSTRATION_LOAD, handler(self, self._illustrationLoad))
    network:addEventListener(Protocol.S_2_C_ILLUSTRATION_NEW_ACTIVE, handler(self, self._illustrationNewActive))
    network:addEventListener(Protocol.S_2_C_ILLUSTRATION_ACTIVE, handler(self, self._illustrationActive))
    network:addEventListener(Protocol.S_2_C_ILLUSTRATION_DRAW, handler(self, self._illustrationDraw))
    network:addEventListener(Protocol.S_2_C_ILLUSTRATION_ACTIVE_GROWTH, handler(self, self._illustrationActiveGrowth))
    network:addEventListener(Protocol.S_2_C_ILLUSTRATION_NEW_GROWTH, handler(self, self._illustrationNewGrowth))
end

function Illustration:_illustrationDraw(evt)
    local info = self:getIllustrationInfoById(evt.data.ill_id)
    info.draw = 1
    self:updateRed()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ILLUSTRATION_DRAW})
end

function Illustration:_illustrationActiveGrowth(evt)
    local info = self:getIllustrationInfoById(evt.data.ill_id)
    info.growth[evt.data.growth_id].growth_state = 2
    self:updateRed()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ILLUSTRATION_ACTIVE_GROWTH, id = evt.data.growth_id})
end

function Illustration:_illustrationNewGrowth(evt)
    local data = uq.cache.illustration.illustration_info
    for k2, v2 in ipairs(data.items) do
        local info = StaticData['Illustration'].Illustration[v2.id]
        if info ~= nil and (info.generalId == evt.data.general_id) then
            v2.growth = evt.data.growth
            break
        end
    end
    self:updateRed()
end

function Illustration:_illustrationActive(evt)
    local is_level_up = false
    if evt.data.ret == 0 then
        local pre_exp = self.illustration_info.total_exp
        local cur_exp = evt.data.exp
        local stage_info = {}
        for k, v in pairs(StaticData['Illustration'].Stage) do
            table.insert(stage_info, v)
        end
        table.sort(stage_info, function(a, b)
            return a.ident < b.ident
        end)
        local exp = 0
        for k, v in ipairs(stage_info) do
            exp = exp + v.exp
            if exp > pre_exp and exp <= cur_exp  then
                self.isActive = true
                is_level_up = true
                break
            end
        end
        self.illustration_info.total_exp = evt.data.exp
        for k,v in ipairs(self.illustration_info.items) do
            if v.id == evt.data.id then
                v.state = 2
                break
            end
        end
        if is_level_up then
            uq.ModuleManager:getInstance():show(uq.ModuleManager.MAP_GUIDE_LEVEL_UP)
        end
        self:updateRed()
        services:dispatchEvent({name = services.EVENT_NAMES.ON_ILLUSTRATION_ACTIVE,data = evt.data.id})
    end
end

function Illustration:_illustrationNewActive(evt)
    for k, v in pairs(evt.data.ids) do
        self.illustration_info.items[v].state = 1
    end
    self:updateRed()
end

function Illustration:getIllustrationInfoById(id)
    for k, v in pairs(self.illustration_info.items) do
        if v.id == id then
            return self.illustration_info.items[k]
        end
    end
    return nil
end

function Illustration:_illustrationLoad(evt)
    self.illustration_info = evt.data
    self:updateRed()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ILLUSTRATION_LOAD})
end

function Illustration:checkIllustrationRed(info)
    for k, v in pairs(info.growth) do
        if v.growth_state == 1 then
            return true
        end
    end
    return (info.draw == 0 and info.state >= 1)
end

function Illustration:updateRed()
    local is_red = self.isActive
    for k2, v2 in ipairs(self.illustration_info.items) do
        local info = StaticData['Illustration'].Illustration[v2.id]
        if info ~= nil and (info.camp == 0 or info.camp == uq.cache.role.country_id) then
            if v2.state == 1 and info.level <= uq.cache.role:level() then --可激活
                is_red = true
                break
            end
            is_red = self:checkIllustrationRed(v2)
            if is_red then
                break
            end
        end
    end
    if is_red then
        is_red = uq.jumpToModule(105, nil, true)
    end
    uq.cache.hint_status.status[uq.cache.hint_status.RED_TYPE.MAP_GUIDE] = is_red
    uq.cache.generals:updateRed()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ILLUSTRATION_RED})
end

return Illustration