local RandomReward = class("RandomReward", require('app.base.PopupBase'))

RandomReward.RESOURCE_FILENAME = "random_event/RandomReward.csb"
RandomReward.RESOURCE_BINDING = {
    ["node_reward"]    = {["varname"] = "_nodeReward"},
    ["lable_reward"]   = {["varname"] = "_lableReward"},
    ["button_confirm"] = {["varname"] = "_btnConfirm",["events"] = {{["event"] = "touch",["method"] = "onConfirm"}}},
}

function RandomReward:onCreate()
    RandomReward.super.onCreate(self)
    self:centerView()
    self:setLayerColor(0.4)
    self:parseView()
end

function RandomReward:onConfirm(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

function RandomReward:setData(data)
    self._lableReward:setString(data.multi)

    local rwds = ''
    for i = 1, #data.rwds do
        local rwd_str = string.format('%d;%d;%d', data.rwds[i].type, data.rwds[i].num, data.rwds[i].paraml)
        rwds = rwds .. rwd_str
        if i ~= #data.rwds then
            rwds = rwds .. '|'
        end
    end
    local reward_items = uq.RewardType.parseRewards(rwds)
    local reward_node, total_width = uq.rewardToGrid(reward_items, 3, 'instance.DropItem', true)
    reward_node:setPositionX(-total_width / 2)
    self._nodeReward:addChild(reward_node)
    self._nodeReward:setScale(0.8)
    uq.playSoundByID(85)
end

return RandomReward