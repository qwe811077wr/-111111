local MainCitySeason = class("MainCitySeason", require('app.base.PopupBase'))

MainCitySeason.RESOURCE_FILENAME = "main_city/SeasonView.csb"
MainCitySeason.RESOURCE_BINDING = {
    ["txt_season"] = {["varname"] = "_txtSeason"},
    ["txt_time"]   = {["varname"] = "_txtTime"},
}

function MainCitySeason:onCreate()
    MainCitySeason.super.onCreate(self)
    self:centerView()
    self:parseView()
    self:refreshPage()

    self._eventRefreshSeason = services.EVENT_NAMES.REFRESH_SEASON .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.REFRESH_SEASON, handler(self, self.refreshPage), self._eventRefreshSeason)

    uq.TimerProxy:addTimer("timer_season", handler(self, self.refreshTime), 1, -1)
end

function MainCitySeason:onExit()
    uq.TimerProxy:removeTimer('timer_season')
    services:removeEventListenersByTag(self._eventRefreshSeason)

    MainCitySeason.super.onExit(self)
end

function MainCitySeason:refreshPage()
    self._txtSeason:setString(string.format(StaticData['local_text']['main.city.season.desc1'], uq.cache.server.year, StaticData['local_text']['season.' .. uq.cache.server.season]))

    local now = uq.curServerSecond()
    self._timeLeft = math.floor((now + 24 * 3600) / (24 * 3600)) * (24 * 3600) + 4 * 3600 - now

    local season = uq.cache.server.season + 1
    if season > 3 then
        season = 0
    end
    self._textSeason = StaticData['local_text']['season.' .. season]
    self:refreshTime()
end

function MainCitySeason:refreshTime()
    self._txtTime:setString(string.format(StaticData['local_text']['main.city.season.desc2'], self._textSeason, uq.getTime(self._timeLeft, uq.config.constant.TIME_TYPE.HHMMSS)))
    if self._timeLeft > 0 then
        self._timeLeft = self._timeLeft - 1
    end
end

return MainCitySeason