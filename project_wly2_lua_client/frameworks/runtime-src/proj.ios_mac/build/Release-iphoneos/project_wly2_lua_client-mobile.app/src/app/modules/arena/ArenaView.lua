local ArenaView = class("ArenaView", require('app.modules.common.BaseViewWithHead'))

ArenaView.RESOURCE_FILENAME = "arena/ArenaView.csb"
ArenaView.RESOURCE_BINDING = {
    ["Panel_1"]       = {["varname"] = "_panelHead"},
    ["Text_20"]       = {["varname"] = "_curRank"},
    ["Text_21"]       = {["varname"] = "_curPower"},
    ["Panel_2"]       = {["varname"] = "_panelTabView"},
    ["Button_reward"] = {["varname"] = "_btnReward",["events"] = {{["event"] = "touch",["method"] = "onReward"}}},
    ["Button_rank"]   = {["varname"] = "_btnRank",["events"] = {{["event"] = "touch",["method"] = "onRank"}}},
    ["Button_shop"]   = {["varname"] = "_btnShop",["events"] = {{["event"] = "touch",["method"] = "onShop"}}},
    ["Button_fight"]  = {["varname"] = "_btnFight",["events"] = {{["event"] = "touch",["method"] = "onFight"}}},
    ["Button_report"] = {["varname"] = "_btnReport",["events"] = {{["event"] = "touch",["method"] = "onReport"}}},
    ["Button_1_1"]    = {["varname"] = "_btnChangeEnemy",["events"] = {{["event"] = "touch",["method"] = "onChangeEnemy"}}},
    ["btn_left"]      = {["varname"] = "_btnLeft",["events"] = {{["event"] = "touch",["method"] = "onBtnLeft"}}},
    ["btn_right"]     = {["varname"] = "_btnRight",["events"] = {{["event"] = "touch",["method"] = "onBtnRight"}}},
    ["Text_1_0_0_0"]  = {["varname"] = "_txtChallengeBuyTime"},
    ["Button_1_1_1"]  = {["varname"] = "_btnBuyTime",["events"] = {{["event"] = "touch",["method"] = "onBuyChallengeTime"}}},
    ["role_icon_img"] = {["varname"] = "_imgHead"},
}

function ArenaView:init()
    local coin_group = {
        uq.config.constant.COST_RES_TYPE.MONEY,
        uq.config.constant.COST_RES_TYPE.GOLDEN,
        uq.config.constant.COST_RES_TYPE.ARENA_SCORE
    }
    self:addShowCoinGroup(coin_group)
    self:centerView()
    self:parseView()
    self:setTitle(uq.config.constant.MODULE_ID.ARENA)
    self:setRuleId(uq.config.constant.MODULE_RULE_ID.ARENA)
    self:adaptBgSize()
    self:initTableView()
    self._lastMusic = uq.getLastMusic()
    uq.playSoundByID(108)
    self._posX = {0, -740, -1663,-2350}
    self._dirIndex = 4

    local head_id = uq.cache.role:getImgId()
    local resh_type = uq.cache.role:getImgType()
    local res_head = uq.getHeadRes(head_id, resh_type)
    self._imgHead:loadTexture(res_head)
end

function ArenaView:initTableView()
    local size = self._panelTabView:getContentSize()
    self._tableView = cc.TableView:create(cc.size(size.width,size.height))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setAnchorPoint(cc.p(0,0))
    self._tableView:setDelegate()
    self._panelTabView:addChild(self._tableView)

    self._tableView:registerScriptHandler(handler(self,self.scrollScriptScroll), cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._tableView:registerScriptHandler(handler(self,self.tableUnHighLight), cc.TABLECELL_UNHIGH_LIGHT)
    self._tableView:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
end

function ArenaView:scrollScriptScroll()
    self._scrolling = true
end

function ArenaView:tableUnHighLight()
    self._scrolling = false
end

function ArenaView:onBtnLeft(event)
    if event.name ~= "ended" then
        return
    end
    local offset = self._tableView:getContentOffset()
    if offset.x == self._posX[1] then
        return
    end
    for k, v in ipairs(self._posX) do
        if v <= offset.x then
            self._dirIndex = k - 1
            break
        end
    end
    self._tableView:setContentOffset(cc.p(self._posX[self._dirIndex], 0))
    self._scrolling = false
end

function ArenaView:onBtnRight(event)
    if event.name ~= "ended" then
        return
    end
    local offset = self._tableView:getContentOffset()
    if offset.x == self._posX[4] then
        return
    end
    for k, v in ipairs(self._posX) do
        if v == offset.x then
            self._dirIndex = k + 1
            break
        end
        if v <= offset.x then
            self._dirIndex = k
            break
        end
    end
    self._tableView:setContentOffset(cc.p(self._posX[self._dirIndex], 0))
    self._scrolling = false
end

function ArenaView:cellSizeForTable(view, idx)
    if idx == 14 then
        return 215, 428
    end
    return 230, 428
end

function ArenaView:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local item = nil
    if not cell then
        cell = cc.TableViewCell:new()
        item = uq.createPanelOnly('arena.ArenaViewItem')
        item:setName("item")
        item:getChildByName("Node"):getChildByName("Image_2"):addClickEventListenerWithSound(handler(item, function(item)
            if self._scrolling then
                return
            end
            local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.RANK_INFO, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
            local info = item:getData()
            if info.id == uq.cache.role.id then
                local data = {
                    role_name = uq.cache.role.name,
                    role_id   = uq.cache.role.id,
                    role_lvl = uq.cache.role.master_lvl,
                    crop_name = uq.cache.role.crop_name,
                    crop_icon = uq.cache.role.cropsId,
                    img_id = uq.cache.role.img_id,
                    img_type = uq.cache.role.img_type,
                    country_id = uq.cache.role.country_id,
                    generals = uq.cache.arena:getAreanOwnerBattleFormation(),
                }
                panel:setData(data)
            else
                panel:setInfo(info)
            end
        end))
        item:setData(self._allItemData[index], index)
        cell:addChild(item)
    else
        item = cell:getChildByName("item")
        item:setData(self._allItemData[index], index)
    end
    return cell
end

function ArenaView:numberOfCellsInTableView()
    return #self._allItemData
end

function ArenaView:onCreate()
    ArenaView.super.onCreate(self)
    self._buyTime = 0
    self._challengeTime = 0
    self._rank = 0

    network:addEventListener(Protocol.S_2_C_ATHLETICS_BUY_TIMES, handler(self, self._onBuyTime), '_onBuyTime')
    network:addEventListener(Protocol.S_2_C_ATHLETICS_SWEEP, handler(self, self._onBattleSweep), '_onBattleSweep' .. tostring(self))
    network:addEventListener(Protocol.S_2_C_ATHLETICS_CHANGE_PLAYER, handler(self, self._onChangePlayer), '_onChangePlayer')
    network:addEventListener(Protocol.S_2_C_ATHLETICS_CHALLENGE_PLAYER, handler(self, self._onChallengePlayer), '_onChallengePlayer')
    self._serviceEnterTag = services.EVENT_NAMES.ON_ARENA_ENTER .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_ARENA_ENTER, handler(self, self._onEnterAthletics), self._serviceEnterTag)
    network:sendPacket(Protocol.C_2_S_ENTER_ATHLETICS)
end

function ArenaView:onExit()
    services:removeEventListenersByTag(self._serviceEnterTag)
    network:removeEventListenerByTag('_onBuyTime')
    network:removeEventListenerByTag('_onBattleSweep' .. tostring(self))
    network:removeEventListenerByTag('_onChangePlayer')
    network:removeEventListenerByTag('_onChallengePlayer')
    ArenaView.super:onExit()
end

function ArenaView:dispose()
    uq.playBackGroundMusic(self._lastMusic)
    ArenaView.super.dispose(self)
end

function ArenaView:_onEnterAthletics(evt)
    self._arenaData = evt.data
    self._buyTime = evt.data.buy_times
    self._challengeTime = evt.data.challenge_times
    self._rank = evt.data.rank
    uq.cache.role.rank = self._rank
    self._bestRank = evt.data.best_rank
    self._curRewardIntegral = evt.data.cur_reward_integral
    self._oldRewardIntegral = evt.data.reward_integral

    self:refreshChallengeTime()
    self:refreshChallenge(evt.data.challengers)
    self:refreshPage()
end

function ArenaView:refreshPage()
    local rank = self._rank <= 0 and StaticData['local_text']['arena.out'] or self._rank
    self._curRank:setString(rank)
    self._curPower:setString(uq.cache.role.power)
end

function ArenaView:_onChangePlayer(msg)
    self._rank = msg.data.rank
    uq.cache.role.rank = self._rank
    self._curRank:setString(self._rank)
    self:refreshChallenge(msg.data.challengers)
end

function ArenaView:refreshChallenge(challengers)
    self._allItemData = challengers
    local data = {
        power    = uq.cache.role.power,
        rank     = self._rank,
        img_type = uq.cache.role.img_type,
        img_id   = uq.cache.role.img_id,
        country  = uq.cache.role.country_id,
        level    = uq.cache.role:level(),
        name     = uq.cache.role.name,
        id       = uq.cache.role.id,
        add_self  = 1
    }
    table.insert(self._allItemData, data)
    if self._rank > 0 then
        table.sort(self._allItemData, function (a,b)
            return a.rank < b.rank
        end)
    end
    self._tableView:reloadData()
    self._tableView:setContentOffset(cc.p(self._posX[self._dirIndex], 0))
    self._scrolling = false
end

function ArenaView:showHelp()
    local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.ARENA_HELP)
    panel:setData(self._bestRank)
end

function ArenaView:onReward(event)
    if event.name ~= "ended" then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ARENA_DAILY_REWARD, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
end

function ArenaView:onShop(event)
    if event.name ~= "ended" then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.GENRAL_SHOP_MODULE, {_sub_index = uq.config.constant.GENERAL_SHOP.ATHLETICS_SHOP})
end

function ArenaView:onRank(event)
    if event.name ~= "ended" then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ARENA_RANK, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
end

function ArenaView:onFight(event)
    if event.name ~= "ended" then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ARENA_TOP_FIGHT, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
end

function ArenaView:onReport(event)
    if event.name ~= "ended" then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ARENA_REPORT, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
end

function ArenaView:onChangeEnemy(event)
    if event.name ~= "ended" then
        return
    end
    network:sendPacket(Protocol.C_2_S_ATHLETICS_CHANGE_PLAYER)
end

function ArenaView:onBuyChallengeTime(event)
    if event.name == "ended" then
        local cost_info = uq.cache.arena:getBuyChallengeTimeCost(self._buyTime)
        local str = string.format(StaticData['local_text']['arena.cannot.challenge'], '<img img/common/ui/03_0003.png>', tonumber(cost_info[2]), self._buyTime)
        local function confirm()
            if uq.cache.role:checkRes(tonumber(cost_info[1]), tonumber(cost_info[2]), tonumber(cost_info[3])) then
                network:sendPacket(Protocol.C_2_S_ATHLETICS_BUY_TIMES)
            else
                local info = StaticData.getCostInfo(tonumber(cost_info[1]), tonumber(cost_info[3]))
                uq.fadeInfo(string.format(StaticData['local_text']['label.res.tips.less'], info.name))
            end
        end
        local data = {
            content = str,
            confirm_callback = confirm
        }
        uq.addConfirmBox(data)
    end
end

function ArenaView:_onBuyTime(msg)
    self._buyTime = msg.data.buy_times
    self._challengeTime = msg.data.challenge_times
    self:refreshChallengeTime()
end

function ArenaView:refreshChallengeTime()
    local times = (self._buyTime + 1) * 5
    self._btnBuyTime:setVisible(times - self._challengeTime <= 0)
    self._txtChallengeBuyTime:setString(string.format('%d/%d', times - self._challengeTime, times))
end

function ArenaView:_onChallengePlayer(msg)
    if msg.data.ret ~= 0 then
        return
    end
    self._battleInfo = msg.data
    self._challengeTime = msg.data.challenge_times
    self._preRank = self._rank
    self._rank = msg.data.new_rank
    uq.cache.role.rank = self._rank
    uq.cache.arena:setRank(self._rank)
    self:refreshChallengeTime()
    if self._battleInfo.battle_ret > 0 then
        network:sendPacket(Protocol.C_2_S_ENTER_ATHLETICS)
    end
    uq.BattleReport:getInstance():showBattleReport(msg.data.report_id, handler(self, self.showBattleResult), msg.data.rewards)
end

function ArenaView:_onBattleSweep(msg)
    self._battleInfo = msg.data
    self._challengeTime = self._challengeTime + 1
    self:refreshChallengeTime()
    self:showBattleResult(nil, true)
end

function ArenaView:showBattleResult(report, isAthleticSweep)
    self._battleInfo.new_rank = self._battleInfo.new_rank or self._rank
    local rank_diff = 0
    if isAthleticSweep then
        rank_diff = 0
    elseif self._preRank and self._preRank ~= 0 then
        rank_diff = self._preRank - self._battleInfo.new_rank
    else
        rank_diff = 5000 - self._battleInfo.new_rank
    end
    self._battleInfo.rank_diff = rank_diff
    self._battleInfo.isAthleticSweep = isAthleticSweep
    local data = {base_data = self._battleInfo, callback = handler(self, self.showBattleResult), report = report}
    if isAthleticSweep or report.result > 0 then
        uq.ModuleManager:getInstance():show(uq.ModuleManager.ARENA_WIN_MODULE, data)
    else
        uq.ModuleManager:getInstance():show(uq.ModuleManager.ARENA_LOST_MODULE, data)
    end
end

return ArenaView