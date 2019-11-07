local WorldTrendsRewardItem = class("WorldTrendsRewardItem", require('app.base.ChildViewBase'))
WorldTrendsRewardItem.RESOURCE_FILENAME = "world/WorldTrendsRewardItem.csb"
WorldTrendsRewardItem.RESOURCE_BINDING = {
    ["Node_1/city_name"]        = {["varname"] = "_nameLabel"},
    ["Node_1/city_des"]         = {["varname"] = "_desLabel"},
    ["Node_1/city_rank"]        = {["varname"] = "_rankLabel"},
    ["Node_1/Node_2"]           = {["varname"] = "_desNode1"},
    ["Node_1/Node_3"]           = {["varname"] = "_desNode2"},
    ["Node_1/Node_4"]           = {["varname"] = "_desNode3"},
    ["Node_1/Node_5"]           = {["varname"] = "_desNode4"},
}

function WorldTrendsRewardItem:onCreate()
    WorldTrendsRewardItem.super.onCreate(self)
    self._nodeArray = {self._desNode1, self._desNode2, self._desNode3, self._desNode4}
    self._desArray = {}
    self._numArray = {}
    for k, v in ipairs(self._nodeArray) do
        local des = v:getChildByName("city_des1")
        table.insert(self._desArray, des)
        des = v:getChildByName("city_des2")
        table.insert(self._desArray, des)
        local num = v:getChildByName("city_num1")
        table.insert(self._numArray, num)
        num = v:getChildByName("city_num2")
        table.insert(self._numArray, num)
    end
end

function WorldTrendsRewardItem:onExit()
    WorldTrendsRewardItem.super.onExit(self)
end

function WorldTrendsRewardItem:updateDialog()
    self._nameLabel:setString(string.format(StaticData["local_text"]["world.trends.reward.des2"], self._info.occupy))
    self._desLabel:setString(StaticData["local_text"]["world.trends.reward.des" ..  self._info.king])
    if self._info.king == 0 then
        self._desLabel:setTextColor(uq.parseColor("#FF0C00"))
    else
        self._desLabel:setTextColor(uq.parseColor("#36FF00"))
    end
    self._rankLabel:setString(self._info.ident)
    local index = 1
    for k, v in ipairs(self._info.Item) do
        local node = self._nodeArray[k]
        if not node then
            return
        end
        local reward_array = uq.RewardType.parseRewards(v.Reward)
        for k2, v2 in ipairs(reward_array) do
            local info = StaticData.getCostInfo(v2:type(), v2:id())
            if info then
                local des = self._desArray[index + k2 - 1]
                des:setString(info.name)
                local num = self._numArray[index + k2 - 1]
                num:setString(v2:num())
            end
        end
        index = index + 2
    end
end

function WorldTrendsRewardItem:setData(info)
    self._info = info
    self:updateDialog()
end

return WorldTrendsRewardItem