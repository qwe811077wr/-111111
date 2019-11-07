local FindSecretRoom = class("FindSecretRoom", require('app.base.PopupBase'))

FindSecretRoom.RESOURCE_FILENAME = "ancient_city/AncientCityFindSecretRoom.csb"
FindSecretRoom.RESOURCE_BINDING = {
    ["label_cost"]           = {["varname"] = "_costLabel"},
    ["label_time"]           = {["varname"] = "_timeLabel"},
    ["Text_2"]               = {["varname"] = "_txtDec"},
    ["btn_exit"]             ={["varname"] = "_btnExit",["events"] = {{["event"] = "touch",["method"] = "_onBtnExit"}}},
    ["btn_see"]              ={["varname"] = "_btnSee",["events"] = {{["event"] = "touch",["method"] = "_onBtnSee"}}},
    ["Button_1"]             ={["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "_onBtnExit"}}},
}

function FindSecretRoom:ctor(name, args)
    FindSecretRoom.super.ctor(self, name, args)
    self._curInfo = args.rewards
end

function FindSecretRoom:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self._xml = StaticData['ancient_info'][1] or {}
    self:initUi()
end

function FindSecretRoom:initUi()
    self._btnSee:setPressedActionEnabled(true)
    self._btnExit:setPressedActionEnabled(true)
    self._txtDec:setHTMLText(StaticData["local_text"]["ancient.dec.mijing2"])
    local reward = uq.RewardType.new(self._xml.sevenFloorCost)
    local color = uq.cache.role:checkRes(reward:type(), reward:num()) and "#FFFFFF" or "#F10000"
    self._costLabel:setString(tostring(reward:num()))
    self._costLabel:setTextColor(uq.parseColor(color))
    self._auto_exit = "auto_exit" .. tostring(self)
    if not uq.cache.ancient_city.sweep_over then
        self._timeNum = 20
        self._timeLabel:setString(string.format(StaticData["local_text"]["ancient.find.room.time.des"], self._timeNum))
        self._timeLabel:setVisible(true)
        uq.TimerProxy:addTimer(self._auto_exit, function()
            self._timeNum = self._timeNum - 1
            self._timeLabel:setString(string.format(StaticData["local_text"]["ancient.find.room.time.des"], self._timeNum))
            if self._timeNum == 0 then
                uq.TimerProxy:removeTimer(self._auto_exit)
                self:_onBtnExit({name = "ended"})
                return
            end
        end, 1, -1)
    end
end

function FindSecretRoom:_onBtnExit(event)
    if event.name ~= "ended" then
        return
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ANCIENT_CITY_CLEARANCE_REWARD})
    uq.cache.ancient_city.sweep_over = true
    self:disposeSelf()
end

function FindSecretRoom:_onBtnSee(event)
    if event.name ~= "ended" then
        return
    end
    local reward = uq.RewardType.new(self._xml.sevenFloorCost)
    if not uq.cache.role:checkRes(reward:type(), reward:num()) then
        uq.fadeInfo(StaticData["local_text"]["ancient.gold.less"])
        return
    end
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_REPAIR_SECRET_ROOM, {})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_ANCIENT_CITY_ENTER_SCENE})
    self:disposeSelf()
end

function FindSecretRoom:dispose()
    uq.TimerProxy:removeTimer(self._auto_exit)
    FindSecretRoom.super.dispose(self)
end
return FindSecretRoom