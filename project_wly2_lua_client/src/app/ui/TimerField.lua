local TimerField = class('TimerField')

function TimerField:ctor(tf, val, finish_cb, formator, timer_callback, change_color)
    self._textField = tf
    self._changeColor = change_color
    self._endTime = os.time() + val
    self._finishCB = finish_cb
    self._formator = formator
    self._timerCallback = timer_callback
    if not self._formator then
        local function normal_format(t)
            return string.format("%02d:%02d:%02d", math.floor(t / 3600), math.floor(t % 3600 / 60), t % 60)
        end
        self._formator = normal_format
    end
    self:_updateTime()
    self._timerTag = '_onTextFieldTimer' .. tostring(self)
    self._hasTimer = false
    if val > 0 then
        uq.TimerProxy:addTimer(self._timerTag, handler(self, self._updateTime), 1, -1)
        self._hasTimer = true
    end
end

function TimerField:setTime(t)
    self._endTime = os.time() + t
    if t > 0 and not self._hasTimer then
        uq.TimerProxy:addTimer(self._timerTag, handler(self, self._updateTime), 1, -1)
        self._hasTimer = true
    end
end

function TimerField:getTime()
    local left_time = self._endTime - os.time()
    left_time = left_time < 0 and 0 or left_time
    return left_time
end

function TimerField:_updateTime()
    local now = os.time()
    local left_time = self._endTime - now
    if left_time < 0 then
        left_time = 0
    end
    if self._textField then
        if self._changeColor then
            self._textField:setHTMLText(self._formator(left_time))
        else
            self._textField:setString(self._formator(left_time))
        end
    end
    if self._timerCallback then
        self._timerCallback(left_time)
    end
    if left_time == 0 then
        if self._hasTimer then
            uq.TimerProxy:removeTimer(self._timerTag)
            self._hasTimer = false
        end
        if self._finishCB then
            if not pcall(self._finishCB) then
                print(debug.traceback())
            end
        end
    end
end

function TimerField:dispose()
    if self._hasTimer then
        uq.TimerProxy:removeTimer(self._timerTag)
        self.hasTimer = false
    end
end

return TimerField