local GeneralPoolCell = class("GeneralPoolCell", require('app.base.ChildViewBase'))

GeneralPoolCell.RESOURCE_FILENAME = "generals/GeneralPoolCell.csb"
GeneralPoolCell.RESOURCE_BINDING = {
    ["Text_name"]           = {["varname"] = "_txtName"},
    ["Text_left_time"]      = {["varname"] = "_txtLeftTime"},
    ["Image_select"]        = {["varname"] = "_imgSelect"},
    ["Image_red"]           = {["varname"] = "_imgRed"},
}

function GeneralPoolCell:ctor(name, params)
    GeneralPoolCell.super.ctor(self, name, params)
end

function GeneralPoolCell:onCreate()
    GeneralPoolCell.super.onCreate(self)
    services:addEventListener(services.EVENT_NAMES.ON_GENERAL_POOL_RED_REFRESH, handler(self, self._refreshRed), "on_refresh_red" .. tostring(self))
end

function GeneralPoolCell:setData(pool_data)
    self._poolData = pool_data
    if not self._poolData then
        return
    end
    self._duration = self._poolData.duration
    if self._poolData.xml then
        self._txtName:setString(self._poolData.xml.name)
    end
    self:refreshTimerLeftTime()
    local need_red = false
    if not uq.cache.generals:isInGenerelPoolsRedInfo(self._poolData.id, self._poolData.duration) or uq.cache.generals:isGenerelPoolFree(self._poolData.id, self._poolData.duration) then
        need_red = true
    end
    self._imgRed:setVisible(need_red)
end

function GeneralPoolCell:refreshTimerLeftTime()
    uq.TimerProxy:removeTimer("update_timer_left_time" .. self._poolData.id .. tostring(self))
    self:setLeftTimeTxt()
    uq.TimerProxy:addTimer("update_timer_left_time" .. self._poolData.id .. tostring(self), handler(self, self.setLeftTimeTxt), 1, -1)
end

function GeneralPoolCell:setLeftTimeTxt()
    local str_left_time = StaticData['local_text']['instance.not.limit']
    if self._duration >= 0 then
        local server_time = uq.cache.server_data:getServerTime()
        local left_time = self._duration == 0 and self._duration or (self._duration - server_time)
        local hours, minutes, seconds, day = uq.getTime(left_time >= 0 and left_time or 0)
        if day >= 1 then
            str_left_time = day .. StaticData['local_text']['label.common.day']
        elseif hours >= 1 then
            str_left_time = hours .. StaticData['local_text']['label.train.time.hour']
        elseif minutes >= 1 then
            str_left_time = minutes .. StaticData['local_text']['label.train.time.minute']
        else
            str_left_time = seconds .. StaticData['local_text']['label.common.second']
        end
    end
    self._txtLeftTime:setString(str_left_time)
end

function GeneralPoolCell:setSelected(is_selected)
    self._imgSelect:setVisible(is_selected)
    self._txtName:setTextColor(uq.parseColor(is_selected and "#FDF2D3" or "#BDAA87"))
    if self._poolData then
        local need_red = false
        if not uq.cache.generals:isInGenerelPoolsRedInfo(self._poolData.id, self._poolData.duration) or uq.cache.generals:isGenerelPoolFree(self._poolData.id, self._poolData.duration) then
            need_red = true
        end
        self._imgRed:setVisible(need_red)
    end
end

function GeneralPoolCell:_refreshRed(msg)
    if self._poolData then
        local need_red = false
        if not uq.cache.generals:isInGenerelPoolsRedInfo(self._poolData.id, self._poolData.duration) or uq.cache.generals:isGenerelPoolFree(self._poolData.id, self._poolData.duration) then
            need_red = true
        end
        self._imgRed:setVisible(need_red)
    end
end

function GeneralPoolCell:getCellSize()
    return self._imgSelect:getContentSize()
end

function GeneralPoolCell:onExit()
    services:removeEventListenersByTag("on_refresh_red" .. tostring(self))
    uq.TimerProxy:removeTimer("update_timer_left_time" .. self._poolData.id .. tostring(self))
    GeneralPoolCell.super.onExit(self)
end

return GeneralPoolCell