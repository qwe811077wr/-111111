local TaskDaySevenCell = class("TaskDaySevenCell", require('app.base.ChildViewBase'))
local EquipItem = require("app.modules.common.EquipItem")

TaskDaySevenCell.RESOURCE_FILENAME = "achievement/TaskDaySevenCell.csb"
TaskDaySevenCell.RESOURCE_BINDING = {
    ["Text_titile"]          = {["varname"] = "_txtTitle"},
    ["Text_cur_schedule"]    = {["varname"] = "_txtCurSchedule"},
    ["Panel_reward"]         = {["varname"] = "_panelReward"},
    ["Button_1"]             = {["varname"] = "_btnRunCmd",["events"] = {{["event"] = "touch",["method"] = "onRunCmd"}}},
    ["Text_14"]              = {["varname"] = "_txtBtnContent"},
    ["Image_37"]             = {["varname"] = "_imgCompleted"},
    ["Node_1"]               = {["varname"] = "_nodeSpeed"},
}

function TaskDaySevenCell:ctor(name, params)
    TaskDaySevenCell.super.ctor(self, name, params)
    self:parseView()
end

function TaskDaySevenCell:onCreate()
    TaskDaySevenCell.super.onCreate(self)
end

function TaskDaySevenCell:initCell(xml_data, state_data)
    self._imgCompleted:setVisible(false)
    self._btnRunCmd:setVisible(xml_data.module ~= -1 or state_data.state ~= uq.config.constant.TYPE_ACHIEVEMENT_STATE.INIT)
end

function TaskDaySevenCell:setData(xml_data, state_data)
    self._xmlData = xml_data
    self._cacheData = state_data

    self:initCell(xml_data, state_data)
    self._txtTitle:setHTMLText(xml_data.desc)
    self._txtCurSchedule:setString(uq.formatResource(state_data.num, true) .. "/" .. uq.formatResource(xml_data.nums, true))
    self._rewards = xml_data.reward
    self:refreshReward(xml_data.reward)
    self._state = state_data.state
    self:refreshBtnState(state_data.state)
end

function TaskDaySevenCell:refreshReward(reward)
    self._panelReward:removeAllChildren()
    local item_list = uq.RewardType.parseRewards(reward)
    for i, item in ipairs(item_list) do
        local euqip_item = EquipItem:create({info = item:toEquipWidget()})
        self._panelReward:addChild(euqip_item)
        euqip_item:setScale(0.6)
        euqip_item:setPosition(cc.p((i - 1) * 80, 0))
        euqip_item:setTouchEnabled(true)
        euqip_item:addClickEventListenerWithSound(function(sender)
            local info = sender:getEquipInfo()
            uq.showItemTips(info)
        end)
        euqip_item:setSwallowTouches(false)
    end
end

function TaskDaySevenCell:refreshBtnState(state)
    self._btnRunCmd:setVisible(state ~= uq.config.constant.TYPE_ACHIEVEMENT_STATE.REWARD)
    self._imgCompleted:setVisible(state == uq.config.constant.TYPE_ACHIEVEMENT_STATE.REWARD)
    self._nodeSpeed:setVisible(state ~= uq.config.constant.TYPE_ACHIEVEMENT_STATE.REWARD)
    if state == uq.config.constant.TYPE_ACHIEVEMENT_STATE.INIT then
        self._txtBtnContent:setString(StaticData["local_text"]['achieve.label.goto'])
    elseif state == uq.config.constant.TYPE_ACHIEVEMENT_STATE.FINISHED then
        self._txtBtnContent:setString(StaticData["local_text"]['activity.seven.reward'])
    end
end

function TaskDaySevenCell:onRunCmd(event)
    if event.name ~= "ended" then
        return
    end

    if self._state == uq.config.constant.TYPE_ACHIEVEMENT_STATE.INIT then
        --前往
        uq.jumpToModule(self._xmlData.module)
    elseif self._state == uq.config.constant.TYPE_ACHIEVEMENT_STATE.FINISHED then
        --领取奖励
        local data = {
            id = self._xmlData.ident
        }
        network:sendPacket(Protocol.C_2_S_TASK_DAY7_DRAW, data)
        local rewards = self._rewards
        self._cacheData.state = uq.config.constant.TYPE_ACHIEVEMENT_STATE.REWARD
        local seven_day = uq.cache.achievement._taskDaySevenInfo
        seven_day.finished_num = seven_day.finished_num + 1
        services:dispatchEvent({name = services.EVENT_NAMES.ON_TASK_DAY_ITEM_REFRESH})
        uq.cache.achievement:updataSevenRed()
        uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, {rewards = rewards})
    end
end

return TaskDaySevenCell