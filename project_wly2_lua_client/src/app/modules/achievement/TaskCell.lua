local TaskCell = class("TaskCell", require('app.base.ChildViewBase'))
local EquipItem = require("app.modules.common.EquipItem")

TaskCell.RESOURCE_FILENAME = "achievement/TaskCell.csb"
TaskCell.RESOURCE_BINDING = {
    ["Text_8"]              = {["varname"] = "_txtContent"},
    ["Text_9"]              = {["varname"] = "_txtNum"},
    ["Text_13"]             = {["varname"] = "_txtCompleted"},
    ["Image_5"]             = {["varname"] = "_imgSign"},
    ["Node_1"]              = {["varname"] = "_nodeReward"},
    ["Text_12"]             = {["varname"] = "_txtGoto"},
    ["Button_2"]            = {["varname"] = "_btnRunCmd", ["events"] = {{["event"] = "touch",["method"] = "onRunCmd"}}},
}

function TaskCell:ctor(name, params)
    TaskCell.super.ctor(self, name, params)
end

function TaskCell:onCreate()
    TaskCell.super.onCreate(self)
    self:parseView()
end

function TaskCell:initCell()
    self._txtCompleted:setVisible(false)
    self._btnRunCmd:setVisible(true)
    if self._xmlData.module == -1 and self._cacheData.state == uq.config.constant.TYPE_ACHIEVEMENT_STATE.INIT then
        self._btnRunCmd:setVisible(false)
    end
end

function TaskCell:setData(xml_data, state_data)
    self._xmlData = xml_data
    self._cacheData = state_data

    self:initCell()
    self._txtContent:setHTMLText(xml_data.des1 .. ":" .. xml_data.des)
    self._txtNum:setString(string.format(StaticData['local_text']['achieve.label.num'], state_data.value, xml_data.num))

    self._rewards = xml_data.reward
    self:refreshReward(xml_data.reward)

    self._state = state_data.state
    if xml_data.module ~= -1 or state_data.state ~= uq.config.constant.TYPE_ACHIEVEMENT_STATE.INIT then
        self:refreshBtnState(state_data.state)
    end
end

function TaskCell:refreshReward(reward)
    local item_list = uq.RewardType.parseRewards(reward)
    for i, v in pairs(item_list) do
        local reward = self._nodeReward:getChildByName(string.format("Image_6_%d", i))
        local num = reward:getChildByName("Text_10")
        num:setString(v:num())
        local img = reward:getChildByName("Image_7")
        img:loadTexture("img/common/ui/" .. v:miniIcon())
    end
end

function TaskCell:refreshBtnState(state)
    self._btnRunCmd:setVisible(true)
    self._txtCompleted:setVisible(false)
    self._txtGoto:enableShadow(uq.parseColor("#000000"), cc.p(1, -1), 0.5)
    self._imgSign:loadTexture("img/common/ui/q02_000003-1.png")

    if state == uq.config.constant.TYPE_ACHIEVEMENT_STATE.INIT then
        self._btnRunCmd:loadTextures("img/common/ui/q02_000001.png", "img/common/ui/q02_000001.png")
        self._txtGoto:setString(StaticData['local_text']['label.common.goto'])
    elseif state == uq.config.constant.TYPE_ACHIEVEMENT_STATE.FINISHED then
        self._btnRunCmd:loadTextures("img/common/ui/q02_000001-2.png", "img/common/ui/q02_000001-2.png")
        self._txtGoto:setString(StaticData['local_text']['label.receive.reward'])
    elseif state == uq.config.constant.TYPE_ACHIEVEMENT_STATE.REWARD then
        self._btnRunCmd:setVisible(false)
        self._txtCompleted:setVisible(true)
        self._imgSign:loadTexture("img/common/ui/q02_000003-2.png")
    end

    if state == uq.config.constant.TYPE_ACHIEVEMENT_STATE.FINISHED then
        return
    end

    if self._xmlData.module == -1 or StaticData['module'][self._xmlData.module]['jumpType'] == 2 then
        self._btnRunCmd:setVisible(false)
    end
end

function TaskCell:onRunCmd(event)
    if event.name ~= "ended" then
        return
    end

    if self._state == uq.config.constant.TYPE_ACHIEVEMENT_STATE.INIT then
        --前往
        local data = StaticData['module'][self._xmlData.module]
        if data['jumpObject'] ~= "" then
            services:dispatchEvent({name = services.EVENT_NAMES.ON_MAIN_CITY_BUILD_TO_POS, build_id = tonumber(data.jumpObject)})
            uq.ModuleManager:getInstance():dispose(uq.ModuleManager.MAIN_TASK)
            return
        end

        if data['jumpType'] == 1 then
            uq.jumpToModule(self._xmlData.module)
            return
        end

        uq.jumpToModule(uq.config.constant.MODULE_ID.INSTANCE, {chapter_id = self._xmlData.param})
    elseif self._state == uq.config.constant.TYPE_ACHIEVEMENT_STATE.FINISHED then
        --领取奖励
        local data = {
            id = self._xmlData.ident,
            chapter_id = self._cacheData.chapter_id,
            rwd_type = uq.config.constant.TYPE_ACHIEVEMENT_REWARD.TASK
        }
        network:sendPacket(Protocol.C_2_S_ACHIEVEMENT_DRAW, data)
        uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, {rewards = self._rewards})

        self._cacheData.state = uq.config.constant.TYPE_ACHIEVEMENT_STATE.REWARD
    end
end

return TaskCell