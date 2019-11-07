local BuildOfficerGift = class("BuildOfficerGift", require('app.base.PopupBase'))

BuildOfficerGift.RESOURCE_FILENAME = "build_officer/BuildOfficerGift.csb"
BuildOfficerGift.RESOURCE_BINDING = {
    ["Text_2_1"]   = {["varname"] = "_txtReworkTime"},
    ["Text_2_1_0"] = {["varname"] = "_txtClearTire"},
    ["Node_1"]     = {["varname"] = "_nodeItem"},
    ["Button_1"]   = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onBtnClose"}}},
}

function BuildOfficerGift:ctor(name, params)
    BuildOfficerGift.super.ctor(self, name, params)
    self:centerView()
    self:parseView()
end

function BuildOfficerGift:onCreate()
    BuildOfficerGift.super.onCreate(self)

    self._refreshEventTag = services.EVENT_NAMES.ON_BUILD_OFFICER_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_BUILD_OFFICER_REFRESH, handler(self, self.onEventRefresh), self._refreshEventTag)
end

function BuildOfficerGift:setData(general_id)
    self._generalId = general_id
    self:onEventRefresh()

    local xml_data = StaticData['officer_level'].RecoverItem

    local node_parent = cc.Node:create()
    local total_width = 0
    local space = 15
    for i = 1, #xml_data do
        local panel = uq.createPanelOnly('build_officer.BuildOfficerGiftItem')
        local size = panel:getContentSize()
        local x = (i - 1) * (size.width + space) + size.width / 2
        local y = 0
        panel:setPosition(cc.p(x, y))
        node_parent:addChild(panel)
        panel:setData(xml_data[i], self._generalId)
        total_width = total_width + size.width + space
    end
    total_width = total_width - space
    node_parent:setPositionX(-total_width / 2)
    self._nodeItem:addChild(node_parent)
end

function BuildOfficerGift:onEventRefresh()
    self:refreshCdTimeRework()
    self:refreshCdTimeClear()
end

function BuildOfficerGift:refreshCdTimeRework()
    self._txtReworkTime:setString('00:00:00')
    local left_time = uq.cache.generals:getTireCdTime(self._generalId, StaticData['officer_level'].Info[1].reWorkTired)
    if left_time <= 0 then
        if self._timerFieldRework then
            self._timerFieldRework:dispose()
            self._timerFieldRework = nil
        end
        return
    end

    local function timer_end()
        self:refreshCdTimeRework()
    end

    if self._timerFieldRework then
        self._timerFieldRework:setTime(left_time)
    else
        self._timerFieldRework = uq.ui.TimerField:create(self._txtReworkTime, left_time, timer_end)
    end
end

function BuildOfficerGift:refreshCdTimeClear()
    self._txtClearTire:setString('00:00:00')
    local left_time = uq.cache.generals:getTireCdTime(self._generalId, 0)
    if left_time <= 0 then
        if self._timerFieldClear then
            self._timerFieldClear:dispose()
            self._timerFieldClear = nil
        end
        return
    end

    local function timer_end()
        self:refreshCdTimeClear()
    end

    if self._timerFieldClear then
        self._timerFieldClear:setTime(left_time)
    else
        self._timerFieldClear = uq.ui.TimerField:create(self._txtClearTire, left_time, timer_end)
    end
end

function BuildOfficerGift:onExit()
    if self._timerFieldRework then
        self._timerFieldRework:dispose()
        self._timerFieldRework = nil
    end
    if self._timerFieldClear then
        self._timerFieldClear:dispose()
        self._timerFieldClear = nil
    end
    services:removeEventListenersByTag(self._refreshEventTag)
    BuildOfficerGift.super.onExit(self)
end

function BuildOfficerGift:onBtnClose(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

return BuildOfficerGift

