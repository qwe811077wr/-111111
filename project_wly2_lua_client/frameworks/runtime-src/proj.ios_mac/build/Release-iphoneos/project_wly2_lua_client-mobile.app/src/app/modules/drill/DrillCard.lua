local DrillCard = class("DrillCard", require('app.modules.common.BaseViewWithHead'))
local EquipItem = require("app.modules.common.EquipItem")

DrillCard.RESOURCE_FILENAME = "drill/DrillCard.csb"
DrillCard.RESOURCE_BINDING = {
    ["card_node"]                             = {["varname"] = "_nodeCard"},
    ["Image_1"]                               = {["varname"] = "_imgEnd"},
    ["Node_effect"]                           = {["varname"] = "_nodeEffect"},
    ["map_bg"]                                = {["varname"] = "_imgBg"},
    ["items_node"]                            = {["varname"] = "_nodeItems"},
    ["ok_btn"]                                = {["varname"] = "_btnOk", ["events"] = {{["event"] = "touch",["method"] = "onBtnOk"}}},
    ["title_txt"]                             = {["varname"] = "_txtName"},
    ["diffcult_txt"]                          = {["varname"] = "_txtDiffcult"},
    ["back_btn"]                              = {["varname"] = "_btnBack", ["events"] = {{["event"] = "touch",["method"] = "onBtnBack"}}},
    ["card_txt"]                              = {["varname"] = "_txtCard"},
    ["finish_img"]                            = {["varname"] = "_imgFinish"},
    ["Node_5"]                                = {["varname"] = "_nodeBtn"},
    ["Panel_1"]                               = {["varname"] = "_panelFinish", ["events"] = {{["event"] = "touch",["method"] = "onFinish"}}},
}

function DrillCard:ctor(name, params)
    DrillCard.super.ctor(self, name, params)
    self._params = params or {}
    self._data = self._params.data or {}
    self._xmlData = self._data.xml_data or {}
    self._curMode = self._data.cur_mode or 1

    self._info = {}
    self._cardDiffcultInfo = {}
    self._drillData = uq.cache.drill:getDrillInfoById(self._xmlData.ident) or {}
    if self._xmlData and self._xmlData.Mode and self._xmlData.Mode[self._curMode] then
        self._cardDiffcultInfo = self._xmlData.Mode[self._curMode]
    end
    self._onEventEnd = "_onEventEnd" ..tostring(self)
    self._onEventBattle = "_onEventBattle" ..tostring(self)
    self._onEventCardChange = "_onEventCardChange" ..tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_DRILL_SKILL_END, handler(self, self.showFinishLayer), self._onEventEnd)
    services:addEventListener(services.EVENT_NAMES.ON_DRILL_CARD_CHANGE, handler(self, self._onRefreshCardLayer), self._onEventCardChange)
    network:addEventListener(Protocol.S_2_C_DRILL_GROUND_BATTER, handler(self, self._onGroundBattle), self._onEventBattle)

    self:setCloseBack(function()
        local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.DRILL_MAIN)
        if not panel then
            uq.runCmd('open_drill')
        end
        self:disposeSelf()
    end)
end

function DrillCard:_onGroundBattle(msg)
    local battle_info = msg.data
    self._battleInfo = msg.data
    uq.BattleReport:getInstance():showBattleReport(battle_info.report_id, handler(self, self.onPlayReportEnd))
    self:_onRefreshCardLayer()
end

function DrillCard:showFinishLayer()
    self._imgEnd:setScale(0.5)
    self._panelFinish:setVisible(true)
    uq:addEffectByNode(self._nodeEffect, 900011, 1, true)
    self._imgEnd:runAction(cc.Sequence:create(cc.ScaleTo:create(1 / 12, 1.2), cc.ScaleTo:create(2 / 12, 1)))
end

function DrillCard:onFinish(event)
    if event.name ~= "ended" then
        return
    end
    self:disposeSelf()
end

function DrillCard:_onRefreshCardLayer(msg)
    self:refreshCardLayer()
    self:refreshDownLayer()
end

function DrillCard:onPlayReportEnd(report)
    if not report then
        return
    end
    if not report.is_replay then
        services:dispatchEvent({name = services.EVENT_NAMES.ON_CLOSE_ARRANGED_BEFORE})
    end

    report.drill_tile = self._xmlData.skillTitle
    if report.result > 0 then
        uq.ModuleManager:getInstance():show(uq.ModuleManager.NPC_DRILL_WIN_MODULE, {rewards = self._info.killReward, report = report, data = self._battleInfo})
    else
        uq.ModuleManager:getInstance():show(uq.ModuleManager.NPC_DRILL_LOST_MODULE, {report = report, data = self._battleInfo})
    end
end

function DrillCard:init()
    self:centerView()
    self:parseView()
    self._allCardBoxs = {}
    self:initLayer()
    self:adaptBgSize()
end

function DrillCard:initLayer()
    if not self._cardDiffcultInfo or next(self._cardDiffcultInfo) == nil then
        return
    end
    self._txtName:setString(self._cardDiffcultInfo.title)
    self._txtDiffcult:setHTMLText(self._cardDiffcultInfo.name)
    self._imgBg:setTexture("img/drill/" .. self._cardDiffcultInfo.mapImage)


    local arr_pos = string.split(self._cardDiffcultInfo.iconDotCoord, ';')
    self._arrTroopId = string.split(self._cardDiffcultInfo.troopId, ',')
    for k, v in ipairs(self._arrTroopId) do
        local item = uq.createPanelOnly("drill.DrillCardItem")
        local pos = string.split(arr_pos[k], ',')
        item:setPosition(cc.p(tonumber(pos[1]), tonumber(pos[2])))
        item:setInfo({troop_id = self._arrTroopId[k], index = k, is_last = k == #self._arrTroopId})
        self._nodeCard:addChild(item)
        table.insert(self._allCardBoxs, item)
    end
    self:refreshCardLayer()
    self:refreshDownLayer()
end

function DrillCard:onBtnOk(event)
    if event.name ~= "ended" then
        return
    end
    self:showEmbattle()
end

function DrillCard:onBtnBack(event)
    if event.name ~= "ended" then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.CONFIRM_BOX_MODULE)
    local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.CONFIRM_BOX_MODULE)
    local content = StaticData['local_text']['drill.fight.desc10']
    local confirm_callback = function()
        network:sendPacket(Protocol.C_2_S_DRILL_GROUND_END, {})
    end
    panel:addConfirmBox({content = content, confirm_callback = confirm_callback}, uq.config.constant.CONFIRM_TYPE.NULL)
    panel:setScale(0.87)
    panel:setLayerColor(0)
end

function DrillCard:refreshCardLayer()
    if not self._cardDiffcultInfo or next(self._cardDiffcultInfo) == nil then
        return
    end
    self._nowCard, self._rewardIndex = self:findNowCardIndex()
    for k, v in ipairs(self._allCardBoxs) do
        v:refreshPage(self._nowCard, self._rewardIndex)
    end

    local state = self._nowCard > #self._allCardBoxs
    self._btnOk:setVisible(not state)
    self._imgFinish:setVisible(state)
end

function DrillCard:findNowCardIndex()
    if next(self._drillData) == nil or next(self._drillData.rewards) == nil then
        return 1, 1
    end
    local num = #self._drillData.rewards
    local reward_index = self._drillData.rewards[num].num < 1 and num or num + 1
    return num + 1, reward_index
end

function DrillCard:refreshDownLayer()
    local index = math.min(self._nowCard, #self._allCardBoxs)
    self._txtCard:setString(StaticData["local_text"]["drill.day" .. index])
    self._info = StaticData['drill_ground'].Troop[tonumber(self._arrTroopId[index])]
    if not self._info.killReward or self._info.killReward == "" then
        return
    end
    local tab_award = uq.RewardType.parseRewards(self._info.killReward)
    for i, v in ipairs(tab_award) do
        local item = EquipItem:create()
        item:setTouchEnabled(true)
        item:setPosition(cc.p((i - 1) * 110, 0))
        item:setScale(0.8)
        item:setInfo(v:toEquipWidget())
        item:addClickEventListenerWithSound(function(sender)
            local info = sender:getEquipInfo()
            uq.showItemTips(info)
        end)
        self._nodeItems:addChild(item)
    end
end

function DrillCard:isFinishCardById(id)
    for k, v in pairs(self._drillData.rewards) do
        if v.id == id then
            return true
        end
    end
    return false
end

function DrillCard:isCanOpenBoxs(id)
    for k, v in pairs(self._drillData.rewards) do
        if v.id == id then
            return v.num < 1, true
        end
    end
    return false, false
end

function DrillCard:showEmbattle()
    local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.DRILL_MAIN)
    if panel then
        panel:disposeSelf()
    end
    if self._showEmbattleCD and os.time() - self._showEmbattleCD < 3 then
        return
    end
    self._showEmbattleCD = os.time()
    if self._rewardIndex < self._nowCard then
        uq.fadeInfo(StaticData['local_text']['has.reward.to.receive'])
        return
    end
    if not self._info.Army or next(self._info.Army) == nil then
        return
    end
    local soldier_array = {}
    if self._info.limitSoldier and self._info.limitSoldier ~= "" then
        local tab_split = string.split(self._info.limitSoldier, ",")
        for i, v in ipairs(tab_split) do
            table.insert(soldier_array, tonumber(v))
        end
    end
    local cache_data = uq.cache.drill:getFormationData()
    local data = clone(cache_data)
    local army_data = {
        ids = {data.formation_id},
        array = {'formations'},
        formations = data.formations,
    }
    local data = {
        enemy_data = self._info.Army,
        army_data = {army_data},
        embattle_type = uq.config.constant.TYPE_EMBATTLE.DRILL_GROUND_EMBATTLE,
        confirm_callback = handler(self, self._doAtkNPC),
        soldier_array = soldier_array,
    }
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ARRANGED_BEFORE_WAR, data)
end

function DrillCard:_doAtkNPC()
    network:sendPacket(Protocol.C_2_S_DRILL_GROUND_BATTER, {})
end

function DrillCard:dispose()
    services:removeEventListenersByTag(self._onEventEnd)
    services:removeEventListenersByTag(self._onEventCardChange)
    network:removeEventListenerByTag(self._onEventBattle)
    DrillCard.super.dispose(self)
end

return DrillCard