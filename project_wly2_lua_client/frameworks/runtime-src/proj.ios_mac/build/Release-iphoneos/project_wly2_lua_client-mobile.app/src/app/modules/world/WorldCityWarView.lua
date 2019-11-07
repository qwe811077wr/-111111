local WorldCityWarView = class("WorldCityWarView", require('app.base.ChildViewBase'))

WorldCityWarView.RESOURCE_FILENAME = "world/WorldCityWarView.csb"
WorldCityWarView.RESOURCE_BINDING = {
    ["btn_world"]                                               = {["varname"] = "_btnWorld",["events"] = {{["event"] = "touch",["method"] = "onEnterWorld"}}},
    ["node_left_middle"]                                        = {["varname"] = "_nodeLeftMiddle"},
    ["node_right_middle"]                                       = {["varname"] = "_nodeRightMiddle"},
    ["node_top_middle"]                                         = {["varname"] = "_nodeTopMidddle"},
    ["node_right_bottom"]                                       = {["varname"] = "_nodeRightBottom"},
    ["node_right_middle/army_num"]                              = {["varname"] = "_armyNumLabel"},
    ["node_left_middle/Button_10"]                              = {["varname"] = "_btnChange",["events"] = {{["event"] = "touch",["method"] = "onChangeRank"}}},
    ["node_left_middle/Node_3/btn_report"]                      = {["varname"] = "_btnReport",["events"] = {{["event"] = "touch",["method"] = "onReport"}}},
    ["node_left_middle/Node_3/btn_report/Image_num"]            = {["varname"] = "_reportRed"},
    ["node_left_middle/Node_3/btn_report/Image_num/Text_num"]   = {["varname"] = "_reportNumLabel"},
    ["node_top_middle/Text_3_3"]                                = {["varname"] = "_defSoldierNumLabel"},
    ["node_top_middle/Text_3_0"]                                = {["varname"] = "_attackSoldierNumLabel"},
    ["node_top_middle/Text_3_1"]                                = {["varname"] = "_timeLabel"},
    ["node_top_middle/Text_3_2"]                                = {["varname"] = "_cityNameLabel"},
}

function WorldCityWarView:onCreate()
    WorldCityWarView.super.onCreate(self)

    self:setContentSize(display.size)
    self:setPosition(display.center)
    self._rankDialogShow = true
    self._nodeRightBottom:setPosition(display.right_bottom)
    self._nodeRightMiddle:setPosition(cc.p(display.right_center.x - uq.getAdaptOffX(), display.right_center.y))
    self._nodeLeftMiddle:setPosition(cc.p(display.left_center.x + uq.getAdaptOffX(), display.left_center.y))
    self._nodeTopMidddle:setPosition(display.top_center)
    self._cdTime = 0
    self:updateBattleTime()
    services:addEventListener(services.EVENT_NAMES.ON_BATTLE_REPORT_NOTIFY, handler(self, self._onBattleReportNotify), "onBattleReportLoadByWorldWarView")

    self._panelArmy = uq.createPanelOnly('instance.ArmyDraft')
    self._nodeLeftMiddle:addChild(self._panelArmy)
    self._panelArmy:setPosition(cc.p(110, 133))
    local temp = StaticData['world_city'][uq.cache.world_war.battle_city_info.city_id]
    if temp == nil then
        return
    end
    self._cityNameLabel:setString(temp.name)
    self._timerFlag = "timer" .. tostring(self)
    if not uq.TimerProxy:hasTimer(self._timerFlag) then
        uq.TimerProxy:addTimer(self._timerFlag, handler(self , self.onTimer), 1, -1)
    end
end

function WorldCityWarView:updateBattleTime()
    self._timeCd = 0
    if uq.cache.world_war.battle_city_info.battle_time > 0 then --战斗中
        local temp = StaticData['world_city'][uq.cache.world_war.battle_city_info.city_id]
        self._timeCd = temp.battleTime - (uq.cache.world_war.battle_city_info.battle_time + (os.time() - uq.cache.world_war.battle_city_info.cur_time))
    elseif uq.cache.world_war.battle_city_info.declare_time > 0 then --备战中
        self._timeCd = 15 * 60 - (uq.cache.world_war.battle_city_info.declare_time + (os.time() - uq.cache.world_war.battle_city_info.cur_time))
    end
    self._timeLabel:setString(uq.getTime(self._timeCd, uq.config.constant.TIME_TYPE.MMSS))
end

function WorldCityWarView:onTimer(dt)
    if self._timeCd <= 0 then
        return
    end
    self._timeCd = self._timeCd - 1
    if self._timeCd < 0 then
        self._timeCd = 0
    end
    self._timeLabel:setString(uq.getTime(self._timeCd, uq.config.constant.TIME_TYPE.MMSS))
end

function WorldCityWarView:onCloseArmyItemView()
    for k, v in ipairs(self._armyArray) do
        v:setState(false)
    end
end

function WorldCityWarView:initDialog()
    self:initRightView()
end

function WorldCityWarView:initRightView()
    self._armyArray = {}
    for k = 1, 2 do
        local node = self._nodeRightMiddle:getChildByName("Node_" .. k)
        local item = uq.createPanelOnly("world.WorldCityWarArmyItem")
        node:addChild(item)
        item:setName("item")
        item:setBgTouchClick(function()
            local index = 1
            if k == 1 then
                index = 2
            end
            local node = self._nodeRightMiddle:getChildByName("Node_" .. index)
            local item = node:getChildByName("item")
            item:setState(false)
        end)
        item:setViewType(2, k)
        table.insert(self._armyArray, item)
    end
    self:_onBattleReportNotify()
end

function WorldCityWarView:updateTopArmyView()
    self._attackSoldierNumLabel:setString(uq.cache.world_war.battle_field_info.attack_num)
    self._defSoldierNumLabel:setString(uq.cache.world_war.battle_field_info.defend_num)
end

function WorldCityWarView:updateRightArmyView()
    local info_array = uq.cache.world_war.cur_army_info
    local num = 0
    for k, v in ipairs(self._armyArray) do
        local info = info_array[k]
        if info.cur_city == uq.cache.world_war.battle_city_info.city_id and #info.generals > 0 then
            num = num + 1
            v:setData(info)
        else
            v:setData(nil)
        end
    end
    self._armyNumLabel:setString(num .. "/2")
end

function WorldCityWarView:closeArmyLayer()
    for k, v in ipairs(self._armyArray) do
        v:setState(false)
    end
end

function WorldCityWarView:onChangeRank(event)
    if event.name ~= "ended" then
        return
    end
    self:onCloseArmyItemView()
    uq.ModuleManager:getInstance():show(uq.ModuleManager.WORLD_CITY_RANK, {})
end

function WorldCityWarView:onReport(event)
    if event.name ~= "ended" then
        return
    end
    self:onCloseArmyItemView()
    uq.ModuleManager:getInstance():show(uq.ModuleManager.BATTLE_REPORT_INFO, {})
end

function WorldCityWarView:onExit()
    uq.TimerProxy:removeTimer(self._timerFlag)
    services:removeEventListenersByTag('onBattleReportLoadByWorldWarView')
    WorldCityWarView.super.onExit(self)
end

function WorldCityWarView:_onBattleReportNotify()
    if uq.ModuleManager:getInstance():getModule(uq.ModuleManager.BATTLE_REPORT_INFO) or uq.cache.world_war.not_read_nums == 0 then
        self._reportRed:setVisible(false)
    else
        self._reportRed:setVisible(true)
        self._reportNumLabel:setString(uq.cache.world_war.not_read_nums)
    end
end

function WorldCityWarView:onEnterWorld(event)
    if event.name ~= "ended" then
        return
    end
    uq.cache.world_war:clearBattleFieldData()
    uq.runCmd('enter_world')
end

return WorldCityWarView