local ArmyDraftItem = class("ArmyDraftItem", require('app.base.ChildViewBase'))

ArmyDraftItem.RESOURCE_FILENAME = "instance/ArmyDraftItem.csb"
ArmyDraftItem.RESOURCE_BINDING = {
    ["Text_1"]   = {["varname"] = "_txtName"},
    ["Text_1_0"] = {["varname"] = "_txtTime"},
}

function ArmyDraftItem:onCreate()
    ArmyDraftItem.super.onCreate(self)
end

function ArmyDraftItem:setData(general_data, speed)
    self._generalData = general_data
    self._armySpeed = speed
    self._txtName:setString(general_data.name)
    self._txtTime:setString('00:00:00')
    self:refreshCdTime()
end

function ArmyDraftItem:refreshCdTime()
    local left_time = uq.cache.role:getDraftLeftTime(self._generalData.max_soldiers - self._generalData.current_soldiers, self._armySpeed)
    local function timer_end()
        if self._timerField then
            self._timerField:dispose()
            self._timerField = nil
        end
        self._txtTime:setString('00:00:00')
        services:dispatchEvent({name = services.EVENT_NAMES.ON_ARMY_REFRESH})
    end

    if left_time <= 0 then
        timer_end()
        return
    end
    if self._timerField then
        self._timerField:setTime(left_time)
    else
        self._timerField = uq.ui.TimerField:create(self._txtTime, left_time, timer_end)
    end
end

function ArmyDraftItem:onExit()
    if self._timerField then
        self._timerField:dispose()
        self._timerField = nil
    end
    ArmyDraftItem.super.onExit(self)
end

function ArmyDraftItem:getGeneralData()
    return self._generalData
end

return ArmyDraftItem