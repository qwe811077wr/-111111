local NpcSweepItem = class("NpcSweepItem", require('app.base.ChildViewBase'))

NpcSweepItem.RESOURCE_FILENAME = "instance/NpcSweepItem.csb"
NpcSweepItem.RESOURCE_BINDING = {
    ["Node_1"] = {["varname"] = "_nodeList"},
    ["Text_1"] = {["varname"] = "_txtNum"},
}

function NpcSweepItem:onCreate()
    NpcSweepItem.super.onCreate(self)
end

function NpcSweepItem:setData(reward_data, index)
    self._txtNum:setString(string.format(StaticData['local_text']['label.rank.num'], index))

    local rwds = ''
    for i = 1, #reward_data.rwds do
        local item = reward_data.rwds[i]
        local rwd_str = string.format('%d;%d;%d', item.type, item.num, item.paraml)
        rwds = rwds .. rwd_str
        if i ~= #reward_data.rwds then
            rwds = rwds .. '|'
        end
    end
    local reward_items = uq.RewardType.parseRewards(rwds)
    local reward_node, total_width = uq.rewardToGrid(reward_items, 20, 'instance.DropItem', true)
    self._nodeList:addChild(reward_node)
    self._nodeList:setScale(0.9)
end

return NpcSweepItem