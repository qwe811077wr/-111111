local ArenaHelpItem = class("ArenaHelpItem", require('app.base.ChildViewBase'))

ArenaHelpItem.RESOURCE_FILENAME = "arena/ArenaHelpItem.csb"
ArenaHelpItem.RESOURCE_BINDING = {
    ["Text_34"]     = {["varname"] = "_txtRank"},
    ["Panel_2"]     = {["varname"] = "_panelReward"}
}

function ArenaHelpItem:setData(data)
    self._txtRank:setString(data.name)

    self._panelReward:removeAllChildren()
    self._panelReward:setScale(0.8)
    local reward_items = uq.RewardType.parseRewards(data.Reward)
    if #reward_items > 0 then
        local reward_parent = uq.rewardToGrid(reward_items, 20)
        reward_parent:setScale(0.75)
        self._panelReward:addChild(reward_parent)
    end
end

return ArenaHelpItem