local WorldTrendsHeroesItem = class("WorldTrendsHeroesItem", require('app.base.ChildViewBase'))
local EquipItem = require("app.modules.common.EquipItem")

WorldTrendsHeroesItem.RESOURCE_FILENAME = "world/WorldTrendsHeroesItem.csb"
WorldTrendsHeroesItem.RESOURCE_BINDING = {
    ["Node_1/Image_1"]                  = {["varname"] = "_imgState"},
    ["Node_1/Panel_info"]               = {["varname"] = "_infoPanel"},
    ["Node_1/label_name"]               = {["varname"] = "_nameLabel"},
    ["Node_1/label_target"]             = {["varname"] = "_targetLabel"},
    ["Node_1/label_des"]                = {["varname"] = "_desLabel"},
    ["Node_1/Panel_item"]               = {["varname"] = "_itemPanel"},
    ["Node_1/Panel_mash"]               = {["varname"] = "_mashPanel"},
    ["Node_1/Image_state"]              = {["varname"] = "_rewardStateImg"},
    ["Node_1/btn_detail"]               = {["varname"] = "_btnDetail",["events"] = {{["event"] = "touch",["method"] = "onBtnDetail"}}},
    ["Node_1/btn_advanced"]             = {["varname"] = "_btnAdvance",["events"] = {{["event"] = "touch",["method"] = "onBtnReward"}}},
}

WorldTrendsHeroesItem._statePath = {
    "img/world/s03_0007039.png",
    "img/world/s03_0007040.png",
    "img/world/s03_0007038.png",
}

WorldTrendsHeroesItem.STATE = {
    ST_INIT = 0,
    ST_FINISHED = 1,
    ST_TIMEOUT = 2,
}

function WorldTrendsHeroesItem:onCreate()
    WorldTrendsHeroesItem.super.onCreate(self)
end

function WorldTrendsHeroesItem:onExit()
    WorldTrendsHeroesItem.super.onExit(self)
end

function WorldTrendsHeroesItem:getReward()
    local str_reward = self._info.xml.reward1
    if str_reward == "" then
        local str_reward = self:getSelfReward()
        if self._info.xml.type ~= 5 then
            str_reward = self:getRankReward(1)
        end
    end
    return str_reward
end

function WorldTrendsHeroesItem:getSelfReward()
    local info = nil
    for k, v in ipairs(self._info.crops) do
        if v.id == uq.cache.role.cropsId then
            info = v
            break
        end
    end
    if not info then
        return nil
    end
    return self:getRankReward(info.rank)
end

function WorldTrendsHeroesItem:getRankReward(rank)
    local rank_reward = string.split(self._info.xml.reward2, "%")
    return rank_reward[rank] or nil
end

function WorldTrendsHeroesItem:updateDialog()
    self._mashPanel:setVisible(self._info.begin_time == 0)
    self._imgState:setVisible(self._info.begin_time > 0)
    self._btnDetail:setVisible(self._info.begin_time > 0 and self._info.xml.type == 5 and self._info.id > uq.cache.world_war.battle_task_info.now_id)
    self._nameLabel:setString(self._info.xml.title)
    self._targetLabel:setString(self._info.xml.goal)
    self._desLabel:setString(self._info.xml.desc)
    local reward = self:getSelfReward()
    if self._info.xml.type ~= 5 then
        reward = self:getRankReward(1)
    end
    local reward_state = uq.cache.world_war:checkTaskReward(self._info.id)
    if self._info.end_time > 0 then
        self._rewardStateImg:loadTexture("img/world/s03_0007037.png")
        if self._info.xml.type == 5 then
            self._btnAdvance:setVisible(not reward_state and reward ~= nil)
            self._rewardStateImg:setVisible(reward_state or reward == nil)
            if reward == nil then
                self._rewardStateImg:loadTexture("img/world/s03_0007036.png")
            end
        elseif self._info.xml.type == 4 then
            self._btnAdvance:setVisible(not reward_state and self._info.state == self.STATE.ST_FINISHED)
            self._rewardStateImg:setVisible(reward_state or self._info.state ~= self.STATE.ST_FINISHED)
            if self._info.state ~= self.STATE.ST_FINISHED then
                self._rewardStateImg:loadTexture("img/world/s03_0007036.png")
            end
        else
            self._btnAdvance:setVisible(not reward_state)
            self._rewardStateImg:setVisible(reward_state)
        end
        if self._info.state == self.STATE.ST_FINISHED then
            self._imgState:loadTexture(self._statePath[1])
        else
            self._imgState:loadTexture(self._statePath[2])
        end
    elseif self._info.begin_time > 0 and self._info.end_time == 0 then
            if self._info.state == self.STATE.ST_FINISHED then
                self._imgState:loadTexture(self._statePath[1])
            else
                self._imgState:loadTexture(self._statePath[3])
            end
            self._btnAdvance:setVisible(self._info.state == self.STATE.ST_FINISHED and not reward_state)
            self._rewardStateImg:setVisible(self._info.state ~= self.STATE.ST_FINISHED or reward_state)
            if reward_state then
                self._rewardStateImg:loadTexture("img/world/s03_0007037.png")
            else
                self._rewardStateImg:loadTexture("img/world/s03_0007036.png")
            end
    else
        self._btnAdvance:setVisible(false)
        self._rewardStateImg:setVisible(false)
    end
    self._itemPanel:removeAllChildren()
    local str_reward = self._info.xml.reward1
    if str_reward == "" then
        str_reward = reward
    end
    local reward_array = uq.RewardType.parseRewards(str_reward)
    local item_posX = 55
    for _, t in ipairs(reward_array) do
        local euqip_item = EquipItem:create({info = t:toEquipWidget()})
        euqip_item:setPosition(cc.p(item_posX, self._itemPanel:getContentSize().height * 0.5))
        euqip_item:setScale(0.8)
        self._itemPanel:addChild(euqip_item)
        item_posX = item_posX + 110
    end
    self._infoPanel:removeAllChildren()
    local task_item = uq.createPanelOnly("world.WorldTrendsTaskItem")
    local data = {
        id = self._info.id,
        icon = self._info.xml.background,
        cur_num = self._info.num,
        total_num = self._info.xml.num,
        duration = self._info.xml.duration,
        begin_time = self._info.begin_time,
        end_time = self._info.end_time,
    }
    task_item:setData(data)
    task_item:setPosition(cc.p(self._infoPanel:getContentSize().width * 0.5, self._infoPanel:getContentSize().height * 0.5))
    self._infoPanel:addChild(task_item)
end

function WorldTrendsHeroesItem:setData(info)
    self._info = info
    self:updateDialog()
end

function WorldTrendsHeroesItem:getData()
    return self._info
end

function WorldTrendsHeroesItem:onBtnReward(event)
    if event.name ~= "ended" then
        return
    end
    network:sendPacket(Protocol.C_2_S_NATION_BATTLE_DRAW_TASK, {task_id = self._info.id})
end

function WorldTrendsHeroesItem:onBtnDetail(event)
    if event.name ~= "ended" then
        return
    end
    if self._info.id > uq.cache.world_war.battle_task_info.now_id then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.WORLD_TRENDS_INFO, {info = self._info})
end

return WorldTrendsHeroesItem