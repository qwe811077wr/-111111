local WorldTrendsTaskItem = class("WorldTrendsTaskItem", require('app.base.ChildViewBase'))
WorldTrendsTaskItem.RESOURCE_FILENAME = "world/WorldTrendsTaskItem.csb"
WorldTrendsTaskItem.RESOURCE_BINDING = {
    ["Node_1/Image_8"]                      = {["varname"] = "_imgIcon"},
    ["Node_1/label_percent"]                = {["varname"] = "_percentLabel"},
    ["Node_1/label_time"]                   = {["varname"] = "_timeLabel"},
    ["Node_1/Image_2"]                      = {["varname"] = "_percentBgImg"},
    ["Node_1/Image_percent"]                = {["varname"] = "_percentImg"},
    ["Node_1/Node_img1/Image_select"]       = {["varname"] = "_imgSelect1"},
    ["Node_1/Node_img2/Image_select"]       = {["varname"] = "_imgSelect2"},
    ["Node_1/Node_img3/Image_select"]       = {["varname"] = "_imgSelect3"},
    ["Node_1/Node_img4/Image_select"]       = {["varname"] = "_imgSelect4"},
}

WorldTrendsTaskItem.STATE = {
    ST_INIT = 0,
    ST_FINISHED = 1,
    ST_TIMEOUT = 2,
}

function WorldTrendsTaskItem:onCreate()
    WorldTrendsTaskItem.super.onCreate(self)
    self._imgArray = {self._imgSelect1, self._imgSelect2, self._imgSelect3, self._imgSelect4}
    self._imgSize = self._percentBgImg:getContentSize()
    self._timerFlag = "time_flag" .. tostring(self)
end

function WorldTrendsTaskItem:onExit()
    uq.TimerProxy:removeTimer(self._timerFlag)
    WorldTrendsTaskItem.super.onExit(self)
end

function WorldTrendsTaskItem:onTimer(dt)
    if self._time <= 0 then
        return
    end
    self._time = self._time - 1
    self._timeLabel:setString(StaticData["local_text"]["world.trends.des7"] .. uq.getTime(self._time, uq.config.constant.TIME_TYPE.HHMMSS))
end

function WorldTrendsTaskItem:updateDialog()
    uq.TimerProxy:removeTimer(self._timerFlag)
    local cur_num = math.floor(self._info.cur_num * #self._imgArray / self._info.total_num)
    for i = 1, cur_num, 1 do
        if self._imgArray[i] then
            self._imgArray[i]:setVisible(true)
        end
    end
    for i = cur_num + 1, #self._imgArray, 1 do
        if self._imgArray[i] then
            self._imgArray[i]:setVisible(false)
        end
    end
    self._percentLabel:setString(self._info.cur_num .. "/" .. self._info.total_num)
    self._percentImg:setContentSize(cc.size(math.floor(self._info.cur_num / self._info.total_num * self._imgSize.width), self._imgSize.height))
    self._imgIcon:loadTexture("img/world/" .. self._info.icon)
    if self._info.end_time == 0 and self._info.begin_time > 0 then
        self._time = self._info.duration - (uq.cache.server_data:getServerTime() - self._info.begin_time)
        self._timeLabel:setString(StaticData["local_text"]["world.trends.des7"] .. uq.getTime(self._time, uq.config.constant.TIME_TYPE.HHMMSS))
        uq.TimerProxy:addTimer(self._timerFlag, handler(self , self.onTimer), 1, -1)
    elseif self._info.end_time > 0 then
        local cur_date = os.date("*t", self._info.end_time)
        if self._info.state == self.STATE.ST_FINISHED then
            self._timeLabel:setString(string.format(StaticData["local_text"]["world.trends.des5"], cur_date.year, cur_date.month, cur_date.day))
        else
            self._timeLabel:setString(string.format(StaticData["local_text"]["world.trends.des6"], cur_date.year, cur_date.month, cur_date.day))
        end
    else
        self._timeLabel:setString(StaticData["local_text"]["world.trends.des12"])
    end
end

function WorldTrendsTaskItem:setData(info)
    self._info = info
    self:updateDialog()
end

return WorldTrendsTaskItem