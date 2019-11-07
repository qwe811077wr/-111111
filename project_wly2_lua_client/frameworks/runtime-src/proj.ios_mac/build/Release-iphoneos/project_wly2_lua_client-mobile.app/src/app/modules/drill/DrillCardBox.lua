local DrillCardBox = class("DrillCardBox", require('app.base.ChildViewBase'))

DrillCardBox.RESOURCE_FILENAME = "drill/DrillCardBox.csb"
DrillCardBox.RESOURCE_BINDING  = {
    ["Node_1"]                                 = {["varname"] = "_nodeBase"},
    ["tips_txt_1"]                             = {["varname"] = "_txtHeightestDiffculty"},
    ["tips_txt_2"]                             = {["varname"] = "_txtOpenTime"},
    ["icon_spr"]                               = {["varname"] = "_imgSoldier"},
    ["Node_7"]                                 = {["varname"] = "_nodeSoldier"},
    ["Text_7"]                                 = {["varname"] = "_txtTitle"},
    ["bg_1_img"]                               = {["varname"] = "_imgSelect"},
    ["bg_3_img"]                               = {["varname"] = "_imgLocked"},
    ["Image_19"]                               = {["varname"] = "_imgDoing"},
    ["bg_2_img"]                               = {["varname"] = "_imgNormal", ["events"] = {{["event"] = "touch", ["method"] = "_onSelected"}}},
}

function DrillCardBox:ctor(name, params)
    DrillCardBox.super.ctor(self, name, params)
    self:parseView()
    self._timerTag = 'update_time' .. tostring(self)
    self._nodeSoldier:setVisible(false)
    self._imgNormal:setTouchEnabled(true)
    services:addEventListener(services.EVENT_NAMES.ON_DRILL_SKILL_END, handler(self, self.refreshMode), 'ON_DRILL_END' .. tostring(self))
end

function DrillCardBox:setDoingState(is_visible, id)
    if not is_visible then
        self._imgDoing:setVisible(false)
        return
    end
    self._imgDoing:setVisible(id == self._info.ident)
    self:refreshMode()
end

function DrillCardBox:setInfo(info)
    self._info = info
    if not self._info then
        return
    end
    self:refreshPage()
    local id = uq.cache.drill:getDrillIdOperation()
    self:setDoingState(id ~= 0, id)
    self:initTimer()
    self:refreshMode()
end

function DrillCardBox:refreshMode()
    local info = uq.cache.drill:getDrillInfoById(self._info.ident)
    local str = info.mode == 0 and StaticData['local_text']['label.diff.none'] or self._info.Mode[info.mode].name
    self._txtHeightestDiffculty:setHTMLText(str)
end

function DrillCardBox:refreshPage()
    self._nodeSoldier:removeAllChildren()
    local group = uq.AnimationManager:getInstance():getAction('idle', self._info.effect)
    local animation = require('app/modules/battle/ObjectAnimation'):create(self._nodeSoldier, group)
    local scale = self._info.scale or 1
    animation:play(uq.config.constant.ACTION_TYPE.ANIMATION_NAME_IDLE, true)
    self._nodeSoldier:setScale(scale)

    self._imgSoldier:setTexture("img/common/soldier/" .. self._info.icon)
    self._imgSoldier:setScale(scale)
    self._imgLocked:setVisible(not self._info.open_state)
    self._txtTitle:setString(self._info.name)

    if not self._info.open_state then
        local arr_time = string.split(self._info.openDay, ',')
        local str = nil
        uq.log(arr_time)
        for k, v in ipairs(arr_time) do
            local num = tonumber(v)
            if not str then
                str = StaticData['local_text']['weekday.one' .. num]
            else
                str = str .. ' ' .. StaticData['local_text']['weekday.one' .. num]
            end
        end
        self._txtOpenTime:setString(str)
    end
end

function DrillCardBox:initTimer()
    if (not uq.cache.drill:checkDrillStateByDay(self._info.openDay) and self._info.open_state)
        or (uq.cache.drill:checkDrillStateByDay(self._info.openDay) and not self._info.open_state) then
        services:dispatchEvent({name = services.EVENT_NAMES.ON_REFRESH_DRILL_OPEN_TIME})
        return
    end
    if not self._info.open_state then
        return
    end
    local time = uq.getCountDownTime()
    uq.TimerProxy:addTimer(self._timerTag, function()
        local str = uq.getTime(time, uq.config.constant.TIME_TYPE.HHMMSS)
        self._txtOpenTime:setString(StaticData['local_text']['label.train.time'] .. ' ' .. str)
        time = time - 1
        if time <= 0 then
            uq.TimerProxy:removeTimer(self._timerTag)
            services:dispatchEvent({name = services.EVENT_NAMES.ON_REFRESH_DRILL_OPEN_TIME})
        end
    end, 1, -1)
end

function DrillCardBox:setCallBack(callback)
    self._callback = callback
end

function DrillCardBox:_onSelected(event)
    if event.name ~= "ended" or not self._info.open_state or self._imgSelect:isVisible() then
        return
    end
    local index = uq.cache.drill:getDrillIdOperation()
    if index ~= 0 and index ~= self._info.ident then
        uq.fadeInfo(StaticData['local_text']['drill.other.loading'])
        return
    end
    if self._callback then
        self._callback(self._info)
    end
    self:setImgSelectedState(true)
end

function DrillCardBox:setImgSelectedState(visible)
    self._imgSelect:setVisible(visible)
    self._imgSoldier:setVisible(not visible)
    self._nodeSoldier:setVisible(visible)
end

function DrillCardBox:getItemContentSize()
    return self._imgSelect:getContentSize()
end

function DrillCardBox:showAction()
    uq.intoAction(self._nodeBase)
end

function DrillCardBox:onExit()
    uq.TimerProxy:removeTimer(self._timerTag)
    services:removeEventListenersByTag('ON_DRILL_END' .. tostring(self))
    DrillCardBox.super.onExit(self)
end

return DrillCardBox