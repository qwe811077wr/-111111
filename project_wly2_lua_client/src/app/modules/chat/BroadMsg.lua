local BroadMsg = class("BroadMsg", require('app.base.ChildViewBase'))

BroadMsg.RESOURCE_FILENAME = "chat/BroadMsg.csb"
BroadMsg.RESOURCE_BINDING = {
    ["Panel_1"]       = {["varname"] = "_panelBg"},
}

function BroadMsg:ctor(name, params)
    BroadMsg.super.ctor(self, name, params)

    self._playing = false
    self._msgQuene = {}
end

function BroadMsg:onCreate()
    BroadMsg.super.onCreate(self)

    self:setPositionY(display.height / 2 - 147)

    self._bgSize = self._panelBg:getContentSize()
    self._richText = uq.RichText:create()
    self._richText:setDefaultFont("res/font/hwkt.ttf")
    self._richText:setFontSize(22)
    self._richText:setContentSize(cc.size(0, self._bgSize.height))
    self._richText:setPosition(cc.p(0, self._bgSize.height / 2))
    self._panelBg:addChild(self._richText)

    uq.TimerProxy:addTimer("updateMsg", handler(self, self.updateMsg), nil, -1)
end

function BroadMsg:updateMsg(timer_trace, dt)
    if not self._playing then
        if #self._msgQuene > 0 then
            if uq.curServerSecond() < self._msgQuene[1].time then
                self:setVisible(false)
                return
            end
            self:setVisible(true)
            self._playing = true
            self._richText:setTextColor(uq.parseColor('ffffff'))
            self._richText:setText(self._msgQuene[1].content)
            self._richText:formatText()
            self._textWidth = self._richText:getTextRealSize().width
            self._richText:setPositionX(self._bgSize.width + self._textWidth)
            self._startTime = uq.curMillSecond()
            self._startX = self._richText:getPositionX()
            local item = self._msgQuene[1]
            table.remove(self._msgQuene, 1)
            item.time = item.time + item.interval
            if item.interval > 0 and item.time < item.end_time then
                self:pushData(item)
            end
            return
        else
            self:setVisible(false)
            return
        end
    end

    local pos_x = self._startX - (uq.curMillSecond() - self._startTime) / 7
    self._richText:setPositionX(pos_x)

    if self._richText:getPositionX() < -self._textWidth then
        self._playing = false
    end
end

function BroadMsg:pushData(data)
    for k, v in ipairs(self._msgQuene) do
        if v.time > data.time then
            table.insert(self._msgQuene, k, data)
            return
        end
    end
    table.insert(self._msgQuene, data)
end

function BroadMsg:onExit()
    uq.TimerProxy:removeTimer("updateMsg")
    BroadMsg.super.onExit(self)
end

return BroadMsg