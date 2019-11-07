local PassUpLevel = class("PassUpLevel", require('app.base.PopupBase'))
local EquipItem = require("app.modules.common.EquipItem")

PassUpLevel.RESOURCE_FILENAME = "pass_check/PassUpLevel.csb"
PassUpLevel.RESOURCE_BINDING = {
    ["Panel_2"]                         = {["varname"] = "_pnlAction"},
    ["Node_6"]                          = {["varname"] = "_nodePassUp"},
    ["Image_up_bg"]                     = {["varname"] = "_imgPassUpBg"},
    ["Image_up_pan_bg"]                 = {["varname"] = "_imgPassUpPanBg"},
    ["Image_up_pan"]                    = {["varname"] = "_imgPassUpPan"},
    ["Node_9"]                          = {["varname"] = "_pnlPassUpLevelAction"},
    ["Font_level"]                      = {["varname"] = "_fntPassUpLevel"},
    ["Image_up"]                        = {["varname"] = "_imgPassUpUp"},
    ["Image_up_title"]                  = {["varname"] = "_imgPassUpTitle"},
    ["Node_8"]                          = {["varname"] = "_pnlPassUpTitleActionLeft"},
    ["Node_7"]                          = {["varname"] = "_pnlPassUpTitleActionRight"},
    ["Text_51"]                         = {["varname"] = "_txtPassUp"},
    ["Button_later"]                    = {["varname"] = "_btnPassUpLater", ["events"]={{["event"]="touch", ["method"]="onBtnConfirm"}}},
    ["Button_accept"]                   = {["varname"] = "_btnPassUpAccept", ["events"]={{["event"]="touch", ["method"]="onBtnAccept"}}},
    ["Panel_1"]                         = {["varname"] = "_panelReward"},
    ["Node_0"]                          = {["varname"] = "_nodeUnlockPass"},
    ["Image_bg_left"]                   = {["varname"] = "_imgUnlockPassBgLeft"},
    ["Image_bg_right"]                  = {["varname"] = "_imgUnlockPassBgRight"},
    ["Image_bg_total"]                  = {["varname"] = "_imgUnlockPassBgTotal"},
    ["Image_font_title"]                = {["varname"] = "_fntUnlockPassTitle"},
    ["Node_4"]                          = {["varname"] = "_pnlUnlockPassTitleAction"},
    ["Node_5"]                          = {["varname"] = "_pnlUnlockPassSeasonAction"},
    ["Image_bg_pan"]                    = {["varname"] = "_imgUnlockPassBgPan"},
    ["Image_bg_season"]                 = {["varname"] = "_imgUnlockPassBgSeason"},
    ["Text_season"]                     = {["varname"] = "_txtUnlockPassSeason"},
    ["Button_confirm"]                  = {["varname"] = "_btnUnlockPassConfirm", ["events"]={{["event"]="touch", ["method"]="onBtnConfirm"}}},
    ["Button_share"]                    = {["varname"] = "_btnUnlockPassShare"}, ["events"]={{["event"]="touch", ["method"]="onBtnShare"}},
}

function PassUpLevel:ctor(name, param)
    PassUpLevel.super.ctor(self, name, param)

    self._type = param.data.show_type
    self._seasonId = param.data.season_id
    self._newLevel = param.data.level or 1

    self._cacheData = uq.cache.pass_check._passCardInfo
    self._passData = StaticData['pass']['Info'][self._cacheData.season_id]
    self._passLevel = self._passData['PassGift']

    self._rewardList = {}
    self._allRewards = {}
end

function PassUpLevel:onCreate()
    PassUpLevel.super.onCreate(self)
    self._eventOneKey = "_onOneKeyDrawReward" .. tostring(self)
    network:addEventListener(Protocol.S_2_C_PASSCARD_LEVEL_ONEKEY_DRAW_REWARD, handler(self, self._onOneKeyReward), self._eventOneKey)
end

function PassUpLevel:_onOneKeyReward(evt)
    local rewardCache = {}
    local data = evt.data
    for i, v in ipairs(data.rwds) do
        table.insert(rewardCache, v)
    end
    if data.is_over == 1 then
        uq.ModuleManager:getInstance():show(uq.ModuleManager.SHOW_REWARD_MODULE, {rewards = rewardCache})
        uq.cache.pass_check:setOneKeyFinish()
        uq.cache.pass_check:updateRed()
        services:dispatchEvent({name = services.EVENT_NAMES.ON_PASS_CHECK_RED_REFRESH})
        self:disposeSelf()
    end
end

function PassUpLevel:init()
    self:parseView()
    self:centerView()
    self:setLayerColor(0.7)
    self:adaptBgSize(self._pnlAction)
    self:adaptBgSize(self._nodePassUp)
    self:adaptBgSize(self._nodeUnlockPass)
    self:initRewardList()
    self:initRewardTableView()
    self:refreshLayer()
end

function PassUpLevel:initRewardList()
    local info = {}
    local function organizeRewardList(xmlData, lockInfo, reward)
        if xmlData.ident > self._cacheData.level then
            return
        end
        for k, v in pairs(lockInfo) do
            if xmlData.ident == v then
                return
            end
        end
        info = uq.RewardType:mergeRewardToMap(info, uq.RewardType.parseRewards(reward))
    end

    for k, v in pairs(self._passLevel) do
        organizeRewardList(v, self._cacheData.free_gift, v.freeGift)
        --只有解锁了战令后才计算尊享奖励
        if self._cacheData.state ~= 0 then
            organizeRewardList(v, self._cacheData.pass_gift, v.passGift)
        end
    end

    if next(info) ~= nil then
        self._rewardList = uq.RewardType:convertMapToTable(info)
    end
end



function PassUpLevel:initRewardTableView()
    local size = self._panelReward:getContentSize()
    self._listView = cc.TableView:create(cc.size(size.width, size.height))
    self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self._listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listView:setPosition(cc.p(0, 0))
    self._listView:setDelegate()
    self._listView:registerScriptHandler(handler(self, self.cellSizeForTableContent), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listView:registerScriptHandler(handler(self, self.tableCellAtIndexContent), cc.TABLECELL_SIZE_AT_INDEX)
    self._listView:registerScriptHandler(handler(self, self.numberOfCellsInTableViewContent), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._listView:reloadData()
    self._panelReward:addChild(self._listView)
end

function PassUpLevel:cellSizeForTableContent(view, idx)
    return 125, 250
end

function PassUpLevel:numberOfCellsInTableViewContent(view)
    return math.floor((#self._rewardList + 1) / 2)
end

function PassUpLevel:tableCellAtIndexContent(view, idx)
    local index = idx * 2 + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        for i = 1, 0, -1 do
            local info = self._rewardList[index]
            local width = 0
            local height = 0
            local euqip_item = nil
            if info ~= nil then
                euqip_item = EquipItem:create({info = info})
                height = euqip_item:getContentSize().height
                euqip_item:setScale(0.7)
                euqip_item:setPosition(cc.p(62.5, (height * 0.5 + 20) * 1.2 + (height + 15) * i * 0.7))
                cell:addChild(euqip_item, 1)
                euqip_item:setName("item" .. i)
                table.insert(self._allRewards, euqip_item)
            else
                euqip_item = EquipItem:create()
                height = euqip_item:getContentSize().height
                euqip_item:setScale(0.7)
                euqip_item:setPosition(cc.p(62.5, (height * 0.5 + 20) * 1.2 + (height + 15) * i * 0.7))
                cell:addChild(euqip_item, 1)
                euqip_item:setName("item" .. i)
                euqip_item:setVisible(false)
                table.insert(self._allRewards, euqip_item)
            end
            index = index + 1
        end
    else
        for i = 1, 0, -1 do
            local info = self._rewardList[index]
            local euqip_item = cell:getChildByName("item" .. i)
            if info ~= nil then
                euqip_item:setInfo(info)
                euqip_item:setVisible(true)
            elseif euqip_item then
                euqip_item:setVisible(false)
            end
            index = index + 1
        end
    end
    return cell
end

function PassUpLevel:refreshLayer()
    self._nodeUnlockPass:setVisible(self._type == 1)
    self._nodePassUp:setVisible(self._type ~= 1)
    if self._type == 1 then
        --恭喜解锁
        self:refreshUnlockLayer()
    else
        --升级成功
        self:refreshUpLevelLayer()
    end
end

function PassUpLevel:refreshUnlockLayer()
    local time = 1 / 24
    local left_bg_size = self._imgUnlockPassBgLeft:getContentSize()
    local move_left = cc.MoveTo:create(time * 3, cc.p(-left_bg_size.width, -8))
    self._imgUnlockPassBgLeft:runAction(move_left)

    local right_bg_size = self._imgUnlockPassBgRight:getContentSize()
    local move_right = cc.MoveTo:create(time * 3, cc.p(left_bg_size.width, -8))
    self._imgUnlockPassBgRight:runAction(move_right)

    local delay_two = cc.DelayTime:create(time * 2)
    local show_func = cc.CallFunc:create(function()
            self._imgUnlockPassBgTotal:setVisible(true)
            self._fntUnlockPassTitle:setVisible(true)
            self._imgUnlockPassBgPan:setVisible(true)
    end)
    self._nodeUnlockPass:runAction(cc.Sequence:create(delay_two, show_func))

    local scale_bg_total = cc.ScaleTo:create(time * 2, 1.3)
    self._imgUnlockPassBgTotal:runAction(cc.Sequence:create(delay_two, scale_bg_total))

    local scale_title_first = cc.ScaleTo:create(time, 1.2)
    local scale_title_second = cc.ScaleTo:create(time * 2, 1)
    self._fntUnlockPassTitle:runAction(cc.Sequence:create(delay_two, scale_title_first, scale_title_second))

    local call_title_func = cc.CallFunc:create(function()
            uq:addEffectByNode(self._pnlUnlockPassTitleAction, 900138, 1, true, cc.p(0, 0))
        end)
    self._pnlUnlockPassTitleAction:runAction(cc.Sequence:create(delay_two, call_title_func))

    local call_season_func = cc.CallFunc:create(function()
            uq:addEffectByNode(self._pnlUnlockPassSeasonAction, 900122, 1, true, cc.p(0, 0))
        end)
    self._pnlUnlockPassSeasonAction:runAction(cc.Sequence:create(delay_two, call_season_func))

    local delay_one = cc.DelayTime:create(time)
    local show_func_two = cc.CallFunc:create(function()
            self._imgUnlockPassBgSeason:setVisible(true)
            self._btnUnlockPassConfirm:setVisible(true)
            self._btnUnlockPassShare:setVisible(true)
        end)
    self._nodeUnlockPass:runAction(cc.Sequence:create(delay_two, delay_one, show_func_two))

    local show_func_three = cc.CallFunc:create(function()
            self._txtUnlockPassSeason:setVisible(true)
            self._txtUnlockPassSeason:setString(string.format(StaticData['local_text']['pass.level.season2'], self._seasonId))
        end)
    self._nodeUnlockPass:runAction(cc.Sequence:create(delay_two, delay_two, show_func_three))
end

function PassUpLevel:refreshUpLevelLayer()
    local time = 1 / 24
    local delay_one = cc.DelayTime:create(time)
    local delay_two = cc.DelayTime:create(time * 2)
    local delay_four = cc.DelayTime:create(time * 4)
    local delay_eight = cc.DelayTime:create(time * 8)
    local move_bg = cc.MoveTo:create(time * 3, cc.p(0, 0))
    self._imgPassUpBg:runAction(move_bg)
    local show_pan_bg = cc.CallFunc:create(function()
            self._imgPassUpPanBg:setVisible(true)
    end)
    local scale_pan_bg = cc.ScaleTo:create(time, 1)
    self._imgPassUpPanBg:runAction(cc.Sequence:create(delay_two, show_pan_bg, scale_pan_bg))
    local show_pan = cc.CallFunc:create(function()
            self._imgPassUpPan:setVisible(true)
    end)
    local show_pan_normal = cc.CallFunc:create(function()
            self._imgPassUpPan:setScale(1)
            self._imgPassUpPan:setOpacity(255)
    end)
    self._imgPassUpPan:runAction(cc.Sequence:create(delay_four, show_pan, delay_one, show_pan_normal))
    local call_level_action = cc.CallFunc:create(function()
        uq:addEffectByNode(self._pnlPassUpLevelAction, 900122, 1, true, cc.p(0, 0))
    end)
    self._pnlPassUpLevelAction:runAction(cc.Sequence:create(delay_four, delay_one, call_level_action))
    local show_level_func = cc.CallFunc:create(function()
        self._imgPassUpUp:setVisible(true)
        self._fntPassUpLevel:setVisible(true)
        self._fntPassUpLevel:setString(tostring(self._newLevel))
    end)
    self._fntPassUpLevel:runAction(cc.Sequence:create(delay_four, delay_one, show_level_func))

    local show_title_func = cc.CallFunc:create(function()
        self._imgPassUpTitle:setVisible(true)
        uq:addEffectByNode(self._pnlPassUpTitleActionLeft, 900011, 1, true, cc.p(0, 0))
    end)
    self._nodePassUp:runAction(cc.Sequence:create(delay_four, delay_two, show_title_func))

    local call_title_action = cc.CallFunc:create(function()
        self._txtPassUp:setVisible(true)
        uq:addEffectByNode(self._pnlPassUpTitleActionRight, 900024, 1, true, cc.p(0, 0))
    end)
    self._nodePassUp:runAction(cc.Sequence:create(delay_eight, call_title_action))

    local show_rewards_action_func = cc.CallFunc:create(function()
        self._panelReward:setVisible(true)
        for k, v in pairs(self._allRewards) do
            v:getBaseLayer():setVisible(false)
            uq:addEffectByNode(v, 900066, 1, true, cc.p(62, 85))
        end
    end)
    local show_rewards_func = cc.CallFunc:create(function ()
        for k, v in pairs(self._allRewards) do
            v:getBaseLayer():setVisible(true)
        end
    end)
    self._panelReward:runAction(cc.Sequence:create(delay_eight, delay_two, show_rewards_action_func, delay_eight, show_rewards_func))

    local show_btn_func = cc.CallFunc:create(function()
        self._btnPassUpLater:setVisible(true)
        self._btnPassUpAccept:setVisible(true)
    end)
    self._nodePassUp:runAction(cc.Sequence:create(delay_eight, delay_four, show_btn_func))

    local move_up = cc.MoveBy:create(time * 2, cc.p(0, 100))
    self._btnPassUpLater:runAction(cc.Sequence:create(delay_eight, delay_four, move_up))
    self._btnPassUpAccept:runAction(cc.Sequence:create(delay_eight, delay_four, move_up:clone()))
end

function PassUpLevel:onBtnConfirm(event)
    if event.name ~= "ended" then
        return
    end

    self:disposeSelf()
end

function PassUpLevel:onBtnShare(event)
    if event.name ~= "ended" then
        return
    end
end

function PassUpLevel:onBtnAccept(event)
    if event.name ~= "ended" then
        return
    end
    if not uq.cache.pass_check:isCanOneKeyFinish() then
        uq.fadeInfo(StaticData["local_text"]["pass.not.reward"])
        return
    end
    network:sendPacket(Protocol.C_2_S_PASSCARD_LEVEL_ONEKEY_DRAW_REWARD, {})
end

function PassUpLevel:onExit()
    network:removeEventListenerByTag(self._eventOneKey)
    PassUpLevel.super.onExit(self)
end

return PassUpLevel