local RandomEgg = class("RandomEgg", require('app.base.PopupBase'))

RandomEgg.RESOURCE_FILENAME = "random_event/RandomAnswer.csb"
RandomEgg.RESOURCE_BINDING = {
    ["Text_1"]   = {["varname"] = "_txtQuestion"},
    ["Button_1"] = {["varname"] = "_btn1",["events"] = {{["event"] = "touch",["method"] = "onAnswer1"}}},
    ["Button_2"] = {["varname"] = "_btn2",["events"] = {{["event"] = "touch",["method"] = "onAnswer2"}}},
}

function RandomEgg:onCreate()
    RandomEgg.super.onCreate(self)

    self:centerView()
    self:setLayerColor(0.4)
    self:parseView()

    self._eventRereshRandomEvent = services.EVENT_NAMES.ON_REFRESH_RANDOM_EVENT .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_REFRESH_RANDOM_EVENT, handler(self, self.refreshRandomEvent), self._eventRereshRandomEvent)
end

function RandomEgg:onExit()
    services:removeEventListenersByTag(self._eventRereshRandomEvent)
    RandomEgg.super.onExit(self)
end

function RandomEgg:onAnswer1(event)
    if event.name ~= "ended" then
        return
    end

    if self._randomData.time == 0 then
        network:sendPacket(Protocol.C_2_S_RANDOM_EVENT_DRAW_EGG, {id = self._randomId, answerid = 1})
    end
end

function RandomEgg:onAnswer2(event)
    if event.name ~= "ended" then
        return
    end

    if self._randomData.time == 0 then
        network:sendPacket(Protocol.C_2_S_RANDOM_EVENT_DRAW_EGG, {id = self._randomId, answerid = 2})
    end
end

function RandomEgg:setData(type, id)
    self._randomData = uq.cache.random_event:getRandomDataItem(type, id)
    self._randomType = type
    self._randomId = id
    self._xmlData = StaticData['random_event'].Egg[self._randomId]

    self._txtQuestion:setString(self._xmlData.question)
    self._txtQuestion:getVirtualRenderer():setLineSpacing(3)

    self:setAnswer()
end

function RandomEgg:setAnswer()
    if self._randomData.time == 0 then
        self._btn1:setTitleText(self._xmlData.answers[1].answer)
        self._btn2:setTitleText(self._xmlData.answers[2].answer)
        self:setButton(self._btn1, 'img/common/ui/j02_00000191.png')
        self:setButton(self._btn2, 'img/common/ui/j02_00000191.png')
    else
        self._btn1:setTitleText(self._xmlData.answers[1].explanation)
        self._btn2:setTitleText(self._xmlData.answers[2].explanation)
        if self._randomData.choose == 1 then
            self:setButton(self._btn1, 'img/common/ui/j02_00000190.png')
            self:setButton(self._btn2, 'img/common/ui/j02_00000191.png')
        else
            self:setButton(self._btn1, 'img/common/ui/j02_00000191.png')
            self:setButton(self._btn2, 'img/common/ui/j02_00000190.png')
        end
    end
end

function RandomEgg:refreshRandomEvent()
    self:setData(self._randomType, self._randomId)
end

function RandomEgg:setButton(btn, bg)
    btn:loadTextureNormal(bg)
    btn:loadTexturePressed(bg)
end

return RandomEgg