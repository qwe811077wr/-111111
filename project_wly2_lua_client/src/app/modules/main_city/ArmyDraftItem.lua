local ArmyDraftItem = class("ArmyDraftItem", require('app.base.ChildViewBase'))

ArmyDraftItem.RESOURCE_FILENAME = "main_city/DraftItem.csb"
ArmyDraftItem.RESOURCE_BINDING = {
    ["Text_1"]   = {["varname"] = "_txtName"},
    ["Text_1_0"] = {["varname"] = "_txtTime"},
    ["Button_1"] = {["varname"] = "_btnSpeed",["events"] = {{["event"] = "touch",["method"] = "onSpeed"}}},
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

function ArmyDraftItem:onSpeed(event)
    if event.name ~= "ended" then
        return
    end

    local res_num = uq.cache.role:getResNum(uq.config.constant.COST_RES_TYPE.REDIF)
    if res_num == 0 then
        uq.fadeInfo(StaticData['local_text']['label.draft.not.soldier'])
        return
    end

    local function confirm()
        network:sendPacket(Protocol.C_2_S_DRAFT_SPEED, {general_id = self._generalData.id})
    end

    local general_data = uq.cache.generals:getGeneralDataByID(self._generalData.id)
    local off_num = general_data.max_soldiers - general_data.current_soldiers
    local str = string.format(StaticData['local_text']['label.draft.speed'], self._generalData.name, off_num, res_num)
    local data = {
        content = str,
        confirm_callback = confirm,
    }
    uq.addConfirmBox(data, uq.config.constant.CONFIRM_TYPE.DRAFT_SOLDIER)
end

function ArmyDraftItem:onExit()
    if self._timerField then
        self._timerField:dispose()
        self._timerField = nil
    end
    ArmyDraftItem.super.onExit(self)
end

return ArmyDraftItem