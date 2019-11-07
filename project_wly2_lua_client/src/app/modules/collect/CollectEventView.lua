local CollectEventView = class("CollectEventView", require('app.base.PopupBase'))

CollectEventView.RESOURCE_FILENAME = "collect/CollectEventView.csb"
CollectEventView.RESOURCE_BINDING = {
    ["Text_event_name"]     = {["varname"] = "_txtEventName"},
    ["Text_event_content"]  = {["varname"] = "_txtEventContent"},
    ["Text_event1"]         = {["varname"] = "_txtEvent1"},
    ["Text_event2"]         = {["varname"] = "_txtEvent2"},
    ["Button_4"]            = {["varname"] = "_btnEvent1",["events"] = {{["event"] = "touch",["method"] = "onEventSlelect1"}}},
    ["Button_4_0"]          = {["varname"] = "_btnEvent2",["events"] = {{["event"] = "touch",["method"] = "onEventSlelect2"}}},
}

function CollectEventView:ctor(name, params)
    CollectEventView.super.ctor(self, name, params)
    self._eventId = params.event_id
    self._eventNum = params.event_num
end

function CollectEventView:init()
    self:centerView()
    self:parseView()
    self:initDialog()
    self:adaptBgSize()
end

function CollectEventView:initDialog()
    local config = StaticData['LevyEventCfg'][id]
    if not config then return end

    self._txtEventName:setString(config.name)
    self._txtEventContent:setString(config.Content[1].Content)

    local index = 1
    for k, item in pairs(config.Option) do
        if index == 1 then
            self._txtEvent1:setString(config.Option[k].label)
        elseif index == 2 then
            self._txtEvent2:setString(config.Option[k].label)
        end
        index = index + 1
    end
end

function CollectEventView:onEventSlelect1(event)
    if event.name ~= "ended" then
        return
    end
    local data = {
        index = 1,
        event_index = self._eventNum - 1,
    }
    network:sendPacket(Protocol.C_2_S_EVENT_SELECT, data)
    self:disposeSelf()
end

function CollectEventView:onEventSlelect2(event)
    if event.name ~= "ended" then
        return
    end
    local data = {
        index = 2,
        event_index = self._eventNum - 1,
    }
    network:sendPacket(Protocol.C_2_S_EVENT_SELECT, data)
    self:disposeSelf()
end

function CollectEventView:dispose()
    CollectEventView.super.dispose(self)
end

return CollectEventView

