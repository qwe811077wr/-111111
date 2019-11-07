local WordMarquee = class('WordMarquee')

function WordMarquee:ctor(tf, str, finish_cb, interval)
    self._textField = tf
    self._string = str
    self._words = string.toChars(str)
    self._index = 1
    self._cb = finish_cb
    self._showWords = ''
    self._timerTag = '_onTextFieldTimer' .. tostring(self)
    self._interval = interval or 0.1
    uq.TimerProxy:addTimer(self._timerTag, handler(self, self._updateTime), self._interval, -1)
    self._hasTimer = true
end

function WordMarquee:showAll()
    if self:finished() then
        return
    end
    if self._hasTimer then
        uq.TimerProxy:removeTimer(self._timerTag)
        self.hasTimer = false
    end
    for i = self._index, #self._words do
        self._showWords = self._showWords .. self._words[i]
    end
    self._index = #self._words + 1
    self._textField:setString(self._showWords)
    if self._cb then
        pcall(self._cb)
    end
end

function WordMarquee:finished()
    return self._index > #self._words
end

function WordMarquee:_updateTime()
    if self._index >= #self._words then
        if self._hasTimer then
            uq.TimerProxy:removeTimer(self._timerTag)
            self.hasTimer = false
        end
        if self._index > #self._words then
            return
        end
    end
    self._showWords = self._showWords .. self._words[self._index]
    self._index = self._index + 1
    if self._index >= #self._words then
        self._textField:setString(self._showWords)
        if self._cb then
            pcall(self._cb)
        end
    else
        self._textField:setString(self._showWords .. '_')
    end
end

function WordMarquee:dispose()
    if self._hasTimer then
        uq.TimerProxy:removeTimer(self._timerTag)
        self.hasTimer = false
    end
end

return WordMarquee