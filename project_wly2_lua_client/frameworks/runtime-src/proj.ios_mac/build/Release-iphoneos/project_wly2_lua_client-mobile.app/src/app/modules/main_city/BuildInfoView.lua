local BuildInfoView = class('BuildInfoView', require("app.base.PopupBase"))

BuildInfoView.RESOURCE_FILENAME = "main_city/BuildInfoView.csb"
BuildInfoView.RESOURCE_BINDING = {
    ["builder_speed_up_btn"]    = {["varname"] = "_btnSpeedUp",["events"] = {{["event"] = "touch",["method"] = "onSpeedUp"}}},
    ["builder_go_btn"]          = {["varname"] = "_btnBuilder",["events"] = {{["event"] = "touch",["method"] = "openViewByTag"}}},
    ["tech_go_btn"]             = {["varname"] = "_btnTech",["events"] = {{["event"] = "touch",["method"] = "openViewByTag"}}},
    ["farm_go_btn"]             = {["varname"] = "_btnFarm",["events"] = {{["event"] = "touch",["method"] = "openViewByTag"}}},
    ["main_build_lvl_txt"]      = {["varname"] = "_txtBuildLevel"},
    ["main_build_cd_timer_txt"] = {["varname"] = "_txtBuildCD"},
    ["tech_txt"]                = {["varname"] = "_txtTech"},
    ["tech_cd_timer_txt"]       = {["varname"] = "_txtTechCD"},
    ["train_txt"]               = {["varname"] = "_txtTrain"},
    ["train_flyable_txt"]       = {["varname"] = "_txtTrainDesc"},
    ["farm_txt"]                = {["varname"] = "_txtFarm"},
    ["farm_harvestable_txt"]    = {["varname"] = "_txtFarmDesc"},
}

function BuildInfoView:onCreate()
    BuildInfoView.super.onCreate(self)

    self:centerView()
    self:parseView()
    self:setLayerColor()

    self:updateMainBuild()
    self:updateTech()
    self:updateTrain()
    self:updateFarm()

    self._builderEventTag = services.EVENT_NAMES.ON_MAIN_CITY_REFRESH_BUILD .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_MAIN_CITY_REFRESH_BUILD, handler(self, self.updateMainBuild), self._builderEventTag)

    self._techCDEvent = services.EVENT_NAMES.ON_TECH_CD_TIME_CHANGED .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_TECH_CD_TIME_CHANGED, handler(self, self.updateTech), self._techCDEvent)

    self._trainEvent = services.EVENT_NAMES.ON_TRAIN_NUM_CHANGED .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_TRAIN_NUM_CHANGED, handler(self, self.updateTrain), self._trainEvent)

    self._farmEvent = services.EVENT_NAMES.ON_FARM_NUM_CHANGED .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_FARM_NUM_CHANGED, handler(self, self.updateFarm), self._farmEvent)
end

function BuildInfoView:openViewByTag(event)
    if event.name == "ended" then
        if event.target == self._btnBuilder then
            uq.jumpToModule(0, {build_id = 0})
        else
            uq.jumpToModule(event.target:getTag())
        end
        self:disposeSelf()
    end
end

function BuildInfoView:onSpeedUp(event)
    if event.name ~= "ended" then
        return
    end

    local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.BUILD_SPEED_UP, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
    panel:setData(self._buildId)
end

function BuildInfoView:updateMainBuild()
    self._txtBuildLevel:setString(string.format(StaticData['local_text']['main.city.main.build.lvl'], uq.cache.role:level()))
    self._buildId = 0
    self._buildData = uq.cache.role.buildings[self._buildId]
    self._xmlData = StaticData['buildings']['CastleMap'][self._buildData.build_id]

    self:refreshCdTime()
end

function BuildInfoView:refreshCdTime()
    local left_time = self._buildData.cd_time - os.time()

    self._txtBuildCD:setVisible(left_time > 0)
    self._btnSpeedUp:setVisible(left_time > 0)
    self._btnBuilder:setVisible(left_time <= 0)

    if left_time <= 0 then
        if self._timerFieldBuilder then
            self._timerFieldBuilder:dispose()
            self._timerFieldBuilder = nil
        end
        return
    end

    local function timer_end()
        self:refreshCdTime()
    end

    local function timer_call(left_time)
        self._gold = uq.cache.role:getLevelUpCDGold(left_time, self._xmlData.freeTime)
    end

    if self._timerFieldBuilder then
        self._timerFieldBuilder:setTime(left_time)
    else
        self._timerFieldBuilder = uq.ui.TimerField:create(self._txtBuildCD, left_time, timer_end, nil, timer_call)
    end
end

function BuildInfoView:updateTech()
    local left_time = 0
    self._txtTechCD:setVisible(left_time > 0)
    if left_time > 0 then
        self._txtTech:setString(StaticData['local_text']['main.city.tech.level.up.0'])
        if self._techTimerField then
            self._techTimerField:setTime(left_time)
        else
            self._techTimerField = uq.ui.TimerField:create(self._txtTechCD, left_time, handler(self, self._onTechTimerFinished))
        end
    else
        self._txtTech:setString(StaticData['local_text']['main.city.tech.level.up.1'])
    end
end

function BuildInfoView:_onTechTimerFinished()
    self:updateTech()
end

function BuildInfoView:updateTrain()
    local train_num = 0
    local max_train_num = 4
    self._txtTrainDesc:setVisible(train_num > 0)
    self._txtTrain:setString(string.format(StaticData['local_text']['main.city.train'], train_num, max_train_num))
end

function BuildInfoView:updateFarm()
    local farm_num = 0
    local max_farm_num = 5
    self._txtFarmDesc:setVisible(farm_num > 0)
    self._txtFarm:setString(string.format(StaticData['local_text']['main.city.farm'], farm_num, max_farm_num))
end

function BuildInfoView:onExit()
    if self._techTimerField then
        self._techTimerField:dispose()
        self._techTimerField = nil
    end
    if self._timerFieldBuilder then
        self._timerFieldBuilder:dispose()
        self._timerFieldBuilder = nil
    end
    services:removeEventListenersByTag(self._builderEventTag)
    services:removeEventListenersByTag(self._farmEvent)
    services:removeEventListenersByTag(self._trainEvent)
    services:removeEventListenersByTag(self._techCDEvent)

    BuildInfoView.super.onExit(self)
end

return BuildInfoView