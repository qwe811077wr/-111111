local CityStatusItem = class("CityStatusItem", require('app.base.ChildViewBase'))

CityStatusItem.RESOURCE_FILENAME = "world/CityStatusItem.csb"
CityStatusItem.RESOURCE_BINDING = {
    ["Image_1"]                 = {["varname"] = "_bgImg"},
    ["Text_des"]                = {["varname"] = "_desLabel"},
    ["Text_time"]               = {["varname"] = "_timeLabel"},
}

function CityStatusItem:onCreate()
    CityStatusItem.super.onCreate(self)
    self._timerFlag = 'timer_flag' .. tostring(self)
    self.cdTime = 0
end

function CityStatusItem:setClick()
    self._bgImg:setTouchEnabled(true)
    self._bgImg:addClickEventListenerWithSound(function(sender)
        uq.ModuleManager:getInstance():show(uq.ModuleManager.CITY_STATE_MODULE)
    end)
end

function CityStatusItem:setType(st_type)
    self._type = st_type
    self._desLabel:setString(StaticData["local_text"]["world.city.state.des" .. self._type])
    if self._type == 1 then
        if not uq.TimerProxy:hasTimer(self._timerFlag) then
            local tab_server_time = os.date("*t", uq.cache.server_data:getServerTime())
            self.cdTime = 8 * 3600 - tab_server_time.hour * 3600 - tab_server_time.min * 60 - tab_server_time.sec
            self._timeLabel:setString(uq.getTime(self.cdTime, uq.config.constant.TIME_TYPE.HHMMSS))
            uq.TimerProxy:addTimer(self._timerFlag, handler(self , self.onTimer), 1, -1)
        end
    end
    self._timeLabel:setVisible(self._type == 1)
end

function CityStatusItem:onTimer()
    self.cdTime = self.cdTime - 1
    if self.cdTime <= 0 then
        self.cdTime = 0
        uq.TimerProxy:removeTimer(self._timerFlag)
    end
    self._timeLabel:setString(uq.getTime(self.cdTime, uq.config.constant.TIME_TYPE.HHMMSS))
end

function CityStatusItem:onExit()
    uq.TimerProxy:removeTimer(self._timerFlag)
    CityStatusItem.super.onExit(self)
end

return CityStatusItem