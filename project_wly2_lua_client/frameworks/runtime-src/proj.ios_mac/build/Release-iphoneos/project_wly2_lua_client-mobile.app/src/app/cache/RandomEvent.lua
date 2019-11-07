local RandomEvent = class("RandomEvent")

RandomEvent.RANDOM_EVENT_TYPE = {
    EGG      = 0,
    BOX      = 1,
    RELATION = 2,
}

function RandomEvent:ctor()
    self._randomData = {}
    self._randomData[self.RANDOM_EVENT_TYPE.BOX]      = {}
    self._randomData[self.RANDOM_EVENT_TYPE.EGG]      = {}
    self._randomData[self.RANDOM_EVENT_TYPE.RELATION] = {map_hide = 1}

    network:addEventListener(Protocol.S_2_C_RANDOM_EVENT_INFO_LOAD, handler(self, self.randomEventInfo))
    network:addEventListener(Protocol.S_2_C_RANDOM_EVENT_UPDATE_INFO, handler(self, self.updateEventInfo))
    network:addEventListener(Protocol.S_2_C_RANDOM_EVENT_DRAW_BOX, handler(self, self.randomEventDrawBox))
    network:addEventListener(Protocol.S_2_C_RANDOM_EVENT_DRAW_EGG, handler(self, self.randomEventDrawEgg))
    network:addEventListener(Protocol.S_2_C_RANDOM_EVENT_NOTICE_BUILD, handler(self, self.randomRelationShip))
    network:addEventListener(Protocol.S_2_C_RANDOM_EVENT_BUILD_DRAW, handler(self, self.randomBuildDraw))
end

function RandomEvent:randomEventInfo(evt)
    for k, item in ipairs(evt.data.box) do
        self._randomData[self.RANDOM_EVENT_TYPE.BOX][item.id] = {time = item.draw_time}
    end

    for k, item in ipairs(evt.data.egg) do
        self._randomData[self.RANDOM_EVENT_TYPE.EGG][item.id] = {time = item.draw_time, choose = item.choose}
    end

    for k, item in ipairs(evt.data.relation) do
        self._randomData[self.RANDOM_EVENT_TYPE.RELATION][item.build_type] = item.event_id
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_REFRESH_RANDOM_EVENT})
end

function RandomEvent:updateEventInfo(evt)
    self._randomData[evt.data.event_type][evt.data.event_id] = {time = 0}
    services:dispatchEvent({name = services.EVENT_NAMES.ON_REFRESH_RANDOM_EVENT, event_data = evt.data})
end

function RandomEvent:getRandomDataItem(type, id)
    return self._randomData[type][id]
end

function RandomEvent:getRandomData()
    return self._randomData
end

function RandomEvent:removeRandomData(type, id)
    self._randomData[type][id] = nil
end

function RandomEvent:randomEventDrawBox(evt)
    self:drawReward(uq.cache.random_event.RANDOM_EVENT_TYPE.BOX, evt)
end

function RandomEvent:randomEventDrawEgg(evt)
    self:drawReward(uq.cache.random_event.RANDOM_EVENT_TYPE.EGG, evt)
end

function RandomEvent:drawReward(event_type, evt)
    local cd_time = 1800
    self._randomData[event_type][evt.data.id].time = uq.curServerSecond() + cd_time
    self._randomData[event_type][evt.data.id].reward_data = evt.data
    self._randomData[event_type][evt.data.id].choose = evt.data.answerid

    local event_data = {event_type = event_type, event_id = evt.data.id}
    services:dispatchEvent({name = services.EVENT_NAMES.ON_REFRESH_RANDOM_EVENT, event_data = event_data})

    self:showReward(evt.data)
end

function RandomEvent:showReward(reward_data)
    local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.RANDOM_REWARD, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
    if panel then
        panel:setData(reward_data)
    end
end

function RandomEvent:randomRelationShip(evt)
    for k, item in ipairs(evt.data.relations) do
        self._randomData[self.RANDOM_EVENT_TYPE.RELATION][item.build_type] = item.event_id
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_RELATION_SHIP_REFRESH})
end

function RandomEvent:randomBuildDraw(evt)
    if evt.data.ret ~= 0 then
        return
    end

    local build_type = evt.data.build_type
    local level = uq.cache.role:getMaxLevelBuild(build_type)
    local xml_data = nil
    for k, item in ipairs(StaticData['random_event'].reward) do
        if item.castleMapType == build_type then
            xml_data = item
        end
    end

    local event_id = self._randomData[self.RANDOM_EVENT_TYPE.RELATION][build_type]
    local event_data = StaticData['random_event'].relationship[event_id]

    if event_data.type == 1 then
        uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, {rewards = xml_data.allReward[level].Reward})
    end

    self._randomData[self.RANDOM_EVENT_TYPE.RELATION][build_type] = nil
    services:dispatchEvent({name = services.EVENT_NAMES.ON_RELATION_SHIP_REFRESH})
end

return RandomEvent