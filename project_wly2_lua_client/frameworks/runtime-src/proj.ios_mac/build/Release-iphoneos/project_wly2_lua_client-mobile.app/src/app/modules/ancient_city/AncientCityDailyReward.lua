local AncientCityDailyReward = class("AncientCityDailyReward", require("app.base.PopupBase"))
local AncientCityDailyRewardItem = require("app.modules.ancient_city.AncientCityDailyRewardItem")

AncientCityDailyReward.RESOURCE_FILENAME = "ancient_city/AncientCityDailyReward.csb"

AncientCityDailyReward.RESOURCE_BINDING  = {
    ["Button_1"]                ={["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "_onBtnClose"}}},
    ["btn_getreward"]           ={["varname"] = "_btnGetReward",["events"] = {{["event"] = "touch",["method"] = "_onBtnGetReward"}}},
    ["bmt_num"]                 ={["varname"] = "_numBmt"},
    ["label_rewardnum"]         ={["varname"] = "_rewardNumLabel"},
    ["Panel_tabview"]           ={["varname"] = "_panelTableView"},
    ["Image_35"]                ={["varname"] = "_bgImg"},
}

function AncientCityDailyReward:ctor(name, args)
    AncientCityDailyReward.super.ctor(self, name, args)
    self._curTabInfo = {}
end

function AncientCityDailyReward:init()
    self:parseView()
    self:centerView()
    self:initTableView()
    self:initUi()
    self:initProtocolData()
    self:setLayerColor()
end

function AncientCityDailyReward:_onBtnGetReward(event)
    if event.name ~= "ended" then
        return
    end
    local isfind = false
    local city_info = uq.cache.ancient_city:getPassCityInfo()
    for k, v in pairs(StaticData['daily_goal']) do
        if v.nums <= city_info.daily_num then
            isfind = true
            for k2,v2 in pairs(city_info.goal_ids) do
                if v2 == v.ident then
                    isfind = false
                    break
                end
            end
            if isfind then
                break
            end
        end
    end
    if isfind then
        network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_DRAW_GOAL, {id = 0})
    else
        uq.fadeInfo(StaticData["local_text"]["ancient.city.daily.reward.des5"])
    end
end

function AncientCityDailyReward:_onBtnClose(event)
    if event.name ~= "ended" then
        return
    end
    self:disposeSelf()
end

function AncientCityDailyReward:initUi()
    self:addExceptNode(self._bgImg)
    local total_num = 0
    for k,v in pairs(StaticData['daily_goal']) do
        table.insert(self._curTabInfo, v)
        total_num = total_num + 1
    end
    local info = uq.cache.ancient_city:getPassCityInfo()
    local cur_num = #info.goal_ids
    for k,v in pairs(self._curTabInfo) do
        v.is_can_get = 1 --不可领取
        if v.nums <= info.daily_num then --可领取
            v.is_can_get = 2
            for k2,v2 in pairs(info.goal_ids) do
                if v2 == v.ident then
                    v.is_can_get = 0 --已领取
                    break
                end
            end
        end
    end
    table.sort(self._curTabInfo, function(a, b)
        if a.is_can_get == b.is_can_get then
            return a.ident < b.ident
        end
        return a.is_can_get > b.is_can_get
    end)
    local ShaderEffect = uq.ShaderEffect
    if self._curTabInfo[1].is_can_get == 2 then
        self._btnGetReward:setEnabled(true)
        ShaderEffect:removeGrayButton(self._btnGetReward)
    else
        self._btnGetReward:setEnabled(false)
        ShaderEffect:addGrayButton(self._btnGetReward)
    end
    self._tableView:reloadData()
    self._numBmt:setString(info.daily_num)
    self._rewardNumLabel:setHTMLText(string.format(StaticData['local_text']['ancient.bay.reward.num'], cur_num, total_num))
end

function AncientCityDailyReward:updateData()
    local total_num = 0
    local info = uq.cache.ancient_city:getPassCityInfo()
    local cur_num = #info.goal_ids
    for k,v in pairs(self._curTabInfo) do
        total_num = total_num + 1
        v.is_can_get = 1 --不可领取
        if v.nums <= info.daily_num then --可领取
            v.is_can_get = 2
            for k2,v2 in pairs(info.goal_ids) do
                if v2 == v.ident then
                    v.is_can_get = 0 --已领取
                    break
                end
            end
        end
    end
    table.sort(self._curTabInfo, function(a, b)
        if a.is_can_get == b.is_can_get then
            return a.ident < b.ident
        end
        return a.is_can_get > b.is_can_get
    end)
    local ShaderEffect = uq.ShaderEffect
    if self._curTabInfo[1].is_can_get == 2 then
        self._btnGetReward:setEnabled(true)
        ShaderEffect:removeGrayButton(self._btnGetReward)
    else
        self._btnGetReward:setEnabled(false)
        ShaderEffect:addGrayButton(self._btnGetReward)
    end
    self._tableView:reloadData()
    self._numBmt:setString(info.daily_num)
    self._rewardNumLabel:setHTMLText(string.format(StaticData['local_text']['ancient.bay.reward.num'], cur_num, total_num))
end

function AncientCityDailyReward:initProtocolData()
    network:addEventListener(Protocol.S_2_C_ANCIENT_CITY_DRAW_GOAL, handler(self, self._onAncientCityDrawGoal), '_onAncientCityDrawGoalByReward')
end

function AncientCityDailyReward:_onAncientCityDrawGoal(msg)
    if msg.data.ret ~= 0 then
        return
    end
    uq.fadeInfo(StaticData["local_text"]["ancient.city.daily.reward.des4"])
    local id = msg.data.id
    local city_info = uq.cache.ancient_city:getPassCityInfo()
    if id > 0 then
        local isfind = false
        for k, v in pairs(city_info.goal_ids) do
            if v == id then
                isfind = true
                break
            end
        end
        if not isfind then
            table.insert(city_info.goal_ids, id)
            uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, {rewards = StaticData['daily_goal'][id].reward})
        end
    else
        local rewards = ""
        for k, v in pairs(StaticData['daily_goal']) do
            local isfind = false
            if v.nums <= city_info.daily_num then
                for k2, v2 in pairs(city_info.goal_ids) do
                    if v2 == v.ident then
                        isfind = true
                        break
                    end
                end
                if not isfind then
                    table.insert(city_info.goal_ids, v.ident)
                    if rewards == "" then
                        rewards = v.reward
                    else
                        rewards = rewards .. "|" .. v.reward
                    end
                end
            end
        end
        rewards = self:dealStrReward(rewards)
        uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, {rewards = rewards})
    end
    uq.cache.ancient_city:updateRed()
    self:updateData()
end

function AncientCityDailyReward:dealStrReward(str)
    if str == "" then
        return ""
    end
    local tab_reward = {}
    local item_list = uq.RewardType.parseRewards(str)
    for i, v in ipairs(item_list) do
        table.insert(tab_reward, v:toEquipWidget())
    end
    if #tab_reward <= 1 then
        return tab_reward
    end
    table.sort(tab_reward, function (a, b)
        if a.type ~= b.type then
            return a.type > b.type
        end
        return a.id > b.id
    end)
    for i = #tab_reward - 1, 1, -1 do
        if tab_reward[i].type == tab_reward[i + 1].type and tab_reward[i].id == tab_reward[i + 1].id then
            tab_reward[i].num = tab_reward[i].num + tab_reward[i + 1].num
            table.remove(tab_reward, i + 1)
        end
    end
    return tab_reward
end

function AncientCityDailyReward:initTableView()
    local size = self._panelTableView:getContentSize()
    self._tableView = cc.TableView:create(cc.size(size.width,size.height))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setAnchorPoint(cc.p(0,0))
    self._tableView:setDelegate()
    self._panelTableView:addChild(self._tableView)

    self._tableView:registerScriptHandler(handler(self,self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
end

function AncientCityDailyReward:cellSizeForTable(view, idx)
    return 1040, 166
end

function AncientCityDailyReward:numberOfCellsInTableView(view)
    return #self._curTabInfo
end

function AncientCityDailyReward:tableCellTouched(view, cell,touch)

end

function AncientCityDailyReward:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx + 1
    if not cell then
        cell = cc.TableViewCell:new()
        local info = self._curTabInfo[index]
        local euqip_item = nil
        if info ~= nil then
            euqip_item = AncientCityDailyRewardItem:create({info = info})
            local width = euqip_item:getContentSize().width
            euqip_item:setPosition(cc.p(width * 0.5, 77))
            cell:addChild(euqip_item,1)
            euqip_item:setName("item")
        end
    else
        local info = self._curTabInfo[index]
        local euqip_item = cell:getChildByName("item")
        if info ~= nil then
            euqip_item:setInfo(info)
        end
    end
    return cell
end

function AncientCityDailyReward:dispose()
    network:removeEventListenerByTag("_onAncientCityDrawGoalByReward")
    AncientCityDailyReward.super.dispose(self)
end

return AncientCityDailyReward