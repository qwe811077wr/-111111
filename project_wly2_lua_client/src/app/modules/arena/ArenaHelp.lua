local ArenaHelp = class("ArenaHelp", require('app.base.PopupBase'))

ArenaHelp.RESOURCE_FILENAME = "arena/ArenaHelp.csb"
ArenaHelp.RESOURCE_BINDING = {
    ["Text_25"]          = {["varname"] = "_txtHighestRank"},
    ["Text_30"]          = {["varname"] = "_txtFightRules"},
    ["Text_30_0"]        = {["varname"] = "_txtRewardDes"},
    ["Panel_3"]          = {["varname"] = "_panelRank"},
    ["Panel_1"]          = {["varname"] = "_panelReward"},
    ["Text_27"]          = {["varname"] = "_txtRewardRange"},
    ["ScrollView_2"]     = {["varname"] = "_scrollView"},
    ["Node_22"]          = {["varname"] = "_node"},
    ["Node_1"]           = {["varname"] = "_nodeRewardDesc"},
    ["Node_2"]           = {["varname"] = "_nodeRewardInfoDesc"},
    ["Image_1"]          = {["varname"] = "_imgRankNotListed"},
    ["Image_3"]          = {["varname"] = "_imgRewardNotListed"},
}

function ArenaHelp:init()
    self:centerView()
    self:parseView()

    self:initData()

    self._xmlData = StaticData['arena_reward']

    self:initScrollView()
    self:initRewardList()
end

function ArenaHelp:onCreate()
    ArenaHelp.super.onCreate(self)
end

function ArenaHelp:initData()
    local xml_data = StaticData['rule'][203]['Text']
    self._txtFightRules:setString(xml_data[1]['description'])

    self._txtFightRules:setTextAreaSize(cc.size(600, 0))
    self._txtRewardDes:setTextAreaSize(cc.size(600, 0))
    local size = self._txtFightRules:getContentSize()

    self._nodeRewardDesc:setPositionY(-size.height + 40)
    self._txtRewardDes:setString(xml_data[2]['description'])

    local reward_size = self._txtRewardDes:getContentSize()
    self._nodeRewardInfoDesc:setPositionY(-reward_size.height - size.height + 80)
end

function ArenaHelp:setData(data)
    self._txtHighestRank:setString(data)
    if data <= 0 then
        self._txtHighestRank:setVisible(false)
        self._imgRankNotListed:setVisible(true)
    end

    local info = self:matchRewardRange(data)
    if not info then
        local end_rank = self._xmlData[#self._xmlData]['rewardRankLimit']
        self._txtRewardRange:setString(end_rank)
        self._imgRewardNotListed:setVisible(true)
        return
    end
    self._txtRewardRange:setString(info.name)

    local reward_items = uq.RewardType.parseRewards(info.Reward)
    if #reward_items > 0 then
        local reward_parent = uq.rewardToGrid(reward_items, 20)
        reward_parent:setScale(0.8)
        self._panelReward:addChild(reward_parent)
    end
end

function ArenaHelp:matchRewardRange(data)
    for k, v in pairs(self._xmlData) do
        local info = {}
        for s in string.gmatch(v.name, '%d+') do
            table.insert(info, s)
        end

        if not info[2] then
            if tonumber(info[1]) == data then
                return v
            end
        else
            if data >= tonumber(info[1]) and data <= tonumber(info[2]) then
                return v
            end
        end
    end
    return
end

function ArenaHelp:initScrollView()
    local num = #self._xmlData
    local size = self._scrollView:getContentSize()
    local item_height = 75 * (num - 1)
    local node = self._node:removeFromParent()
    local add_height = self._nodeRewardInfoDesc:getPositionY()
    local add_all_height = math.abs(add_height) + item_height
    node:setPosition(cc.p(-373.27, -100.25 + add_all_height))
    self._scrollView:setInnerContainerSize(cc.size(size.width, size.height + add_all_height))
    self._scrollView:setScrollBarEnabled(false)
    self._scrollView:addChild(node)
end

function ArenaHelp:initRewardList()
    local num = #self._xmlData
    for i = 1, num do
        local item = uq.createPanelOnly("arena.ArenaHelpItem")
        item:setPosition(cc.p(0 , 35 - 75 * (i - 1)))
        item:setData(self._xmlData[i])
        self._panelRank:addChild(item)
    end
end

return ArenaHelp