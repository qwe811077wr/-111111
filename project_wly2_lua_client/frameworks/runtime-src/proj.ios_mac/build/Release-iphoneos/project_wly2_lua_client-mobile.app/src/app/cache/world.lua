local world = class("world")

function world:ctor()
    self._curworldInfo = nil
    network:addEventListener(Protocol.S_2_C_WORLD_AREA_OPENED, handler(self, self._onWorldAreaOpened))
    network:addEventListener(Protocol.S_2_C_MOVEIN_RES, handler(self, self._onMoveinRes))
end

function world:_onMoveinRes(evt)
    uq.log('_onMoveinRes-----', evt.data)
    if evt.data.res == 0 then
        uq.cache.role.world_area_id = evt.data.new_world_id
        services:dispatchEvent({name = "onMoveInRes"})
    end
end

function world:_onWorldAreaOpened(evt)
    uq.log('_onWorldAreaOpened-----', evt.data)
    self._curworldInfo = evt.data.world_data
    services:dispatchEvent({name = "onWorldAreaOpened"})
end

function world:getworldInfo()
    return self._curworldInfo
end

return world