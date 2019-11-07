local WordWave = class('WordWave')

function WordWave:ctor(container, txt, size, color)
    self._words = {}
    self._speed = 6
    self._timeY = 6
    self._waveStartTime = os.time()
    self._container = container
    size = size or 24
    local words = string.toChars(txt)
    for i = 1, #words do
        local txt = ccui.Text:create()
        txt:setString(words[i])
        txt:setFontSize(size)
        txt:setFontName("font/fzzzhjt.ttf")
        txt:setPosition(cc.p((i - 1) * size + 10, 0))
        if color then
            txt:setTextColor(color)
        end
        container:addChild(txt)
        table.insert(self._words, txt)
    end
    self._timerTag = '_onTextFieldTimer' .. tostring(self)
    uq.TimerProxy:addTimer(self._timerTag, handler(self, self._updateTime), 0.1, -1)
end

function WordWave:_updateTime()
    local delta_t = os.clock() - self._waveStartTime
    for _, v in pairs(self._words) do
        local y = math.sin(v:getPositionX() + delta_t * self._speed)
        v:setPositionY(y * self._timeY)
    end
end

function WordWave:dispose()
    uq.TimerProxy:removeTimer(self._timerTag)
    for _, v in pairs(self._words) do
        v:removeSelf()
    end
    self._words = {}
end

return WordWave