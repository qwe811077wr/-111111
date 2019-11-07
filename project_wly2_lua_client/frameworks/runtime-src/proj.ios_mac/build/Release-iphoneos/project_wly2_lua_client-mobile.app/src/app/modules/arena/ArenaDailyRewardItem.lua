local ArenaDailyRewardItem = class("ArenaDailyRewardItem", require('app.base.ChildViewBase'))
local HeadItem = require('app.modules.role.HeadItem')
local EquipItem = require("app.modules.common.EquipItem")

ArenaDailyRewardItem.RESOURCE_FILENAME = "arena/ArenaRewardItem.csb"
ArenaDailyRewardItem.RESOURCE_BINDING = {
    ["Text_1_0"]                        = {["varname"] = "_txtTime"},
    ["Text_1_2"]                        = {["varname"] = "_txtRank"},
    ["Text_1_3"]                        = {["varname"] = "_deadLineTime"},
    ["Node_1"]                          = {["varname"] = "_nodeReward"},
    ["Button_1"]                        = {["varname"] = "_btnReward", ["events"] = {{["event"] = "touch",["method"] = "onReward"}}},
    ["Image_3"]                         = {["varname"] = "_imgAchieve"},
    ["Text_5"]                          = {["varname"] = "_txtOutTime"},
}

function ArenaDailyRewardItem:onCreate()
    ArenaDailyRewardItem.super.onCreate(self)
    self:parseView()
    self._scroeItem = EquipItem:create()
    self._scroeItem:setScale(0.8)
    self._nodeReward:addChild(self._scroeItem)
    self._scoreInfo = {type = 22}
    self._arrReward = {}
    table.insert(self._arrReward, self._scroeItem)
end

function ArenaDailyRewardItem:setData(data)
    self._rewardInfo = data
    local create_time = os.date("*t", data.clear_time)
    self._txtTime:setString(string.format(StaticData['local_text']['reward.month.day'], create_time.month, create_time.day))
    self._txtRank:setString(data.rank)


    local time = data.clear_time - os.time() + 7 * 24 * 3600
    self._txtOutTime:setVisible(time < 0)
    self._btnReward:setVisible(time > 0 and data.state == 0)
    self._imgAchieve:setVisible(time > 0 and data.state ~= 0)
    if time > 0 then
        local day = math.floor(time / (3600 * 24))
        if day < 1 then
            self._deadLineTime:setString(string.format(StaticData['local_text']['leave.hour.time'], math.ceil(time / 3600)))
        else
            self._deadLineTime:setString(string.format(StaticData['local_text']['leave.day.time'], day))
        end
    end

    self._scoreInfo.num = data.score
    self._scroeItem:setInfo(self._scoreInfo)

    local reward_items = uq.cache.arena:getArenaReward(data.rank)
    if reward_items and #reward_items > 0 then
        local size = self._scroeItem:getContentSize()
        for i = 2, #reward_items + 1 do
            local item = self._arrReward[i]
            if not item then
                item = EquipItem:create({info = reward_items[i - 1]:toEquipWidget()})
                item:setScale(0.8)
                item:setPositionX(size.width * 0.85 * (i - 1))
                table.insert(self._arrReward, item)
                self._nodeReward:addChild(item)
            else
                item:setInfo(reward_items[i - 1]:toEquipWidget())
            end
        end
    end

    for i = #reward_items + 2, #self._arrReward do
        self._arrReward[i]:setVisible(false)
    end
end

function ArenaDailyRewardItem:onReward(evt)
    if evt.name ~= "ended" then
        return
    end
    network:sendPacket(Protocol.C_2_S_ATHLETICS_DRAW_REWARD, {clear_time = self._rewardInfo.clear_time})
end

return ArenaDailyRewardItem