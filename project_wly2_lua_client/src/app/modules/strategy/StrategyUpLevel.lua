local StrategyUpLevel = class("StrategyUpLevel", require('app.base.PopupBase'))

StrategyUpLevel.RESOURCE_FILENAME = "strategy/StrategyUpLevel.csb"
StrategyUpLevel.RESOURCE_BINDING = {
    ["name_txt"]                = {["varname"] = "_txtName"},
    ["lv_txt"]                  = {["varname"] = "_txtLv"},
    ["att_now_txt"]             = {["varname"] = "_txtAttNow"},
    ["att_next_txt"]            = {["varname"] = "_txtAttNext"},
    ["next_lv_txt"]             = {["varname"] = "_txtNextLv"},
    ["need_pnl"]                = {["varname"] = "_pnlNeed"},
    ["need_node"]               = {["varname"] = "_nodeNeed"},
    ["time_txt"]                = {["varname"] = "_txtTime"},
    ["cost_num_txt"]            = {["varname"] = "_txtNumCost"},
    ["Image_7"]                 = {["varname"] = "_imgIcon"},
    ["Button_2"]                = {["varname"] = "_btnFinish",["events"] = {{["event"] = "touch",["method"] = "onFinish"}}},
    ["Button_2_0"]              = {["varname"] = "_btnUp",["events"] = {{["event"] = "touch",["method"] = "onUpLv",["sound_id"] = 0}}},
}

function StrategyUpLevel:ctor(name, params)
    StrategyUpLevel.super.ctor(self, name, params)
    self:centerView()
    self:setLayerColor()
    self:parseView()

    self._data = params.data or {}
    self._isUp = false
    self._txt = ""
    self._nextLvData = {}
    self:refreshLayer()
    self._eventTagRefresh = services.EVENT_NAMES.ON_STRATRGY_UP_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_STRATRGY_UP_REFRESH, handler(self, self._onRefreshLayer), self._eventTagRefresh)
end

function StrategyUpLevel:_onRefreshLayer()
    if self._data.level >= uq.cache.technology:getTechnologyMaxLv(self._data.xml) then
        self:disposeSelf()
        return
    end
    self:refreshLayer()
end

function StrategyUpLevel:refreshLayer()
    if not self._data or not self._data.xml or next(self._data.xml) == nil then
        return
    end
    self._txtName:setString(self._data.xml.name)
    self._imgIcon:loadTexture("img/strategy/" .. self._data.xml.icon)
    local tab_now = self:getNextLvInfo(self._data.level)
    if tab_now and tab_now.value then
        local str_num = tab_now.value
        local str = self:getDecStr(self._data.xml.studytype, str_num, self._data.xml.percent, self._data.xml.effectType)
        self._txtAttNow:setHTMLText(string.format(StaticData["local_text"]["strategy.dec.skill"], self._data.xml.desc, str))
        local cost_time = uq.cache.technology:getStudySurplusTime(tab_now.time)
        self._txtTime:setString(uq.getTime(cost_time, uq.config.constant.TIME_TYPE.HHMMSS))
        local gold_num = uq.cache.role:getResNum(uq.config.constant.COST_RES_TYPE.GOLDEN, 0)
        local cost = uq.cache.technology:getStudyCostGold(cost_time)
        self._txtNumCost:setString(gold_num .. '/' .. cost)
        self:refreshDemand(tab_now)
    end
    local tab_next = self:getNextLvInfo(self._data.level + 1)
    if tab_next and tab_next.value then
        local str_num = tab_next.value
        local str = self:getDecStr(self._data.xml.studytype, str_num, self._data.xml.percent, self._data.xml.effectType)
        self._txtAttNext:setHTMLText(string.format(StaticData["local_text"]["strategy.dec.skill"], self._data.xml.desc, str))
    end
    self._txtNextLv:setString(tostring(self._data.level + 1))
    self._pnlNeed:setVisible(false)
    self._txtLv:setString(self._data.level .. "/" .. uq.cache.technology:getTechnologyMaxLv(self._data.xml))
end

function StrategyUpLevel:getDecStr(study_type, num, percent, effectType)
    if study_type ~= 3 then
        return uq.cache.generals:getNumByEffectType(effectType, num)
    end
    if percent == 1 then
        return num * 100 .. "%"
    end
    return tostring(num)
end

function StrategyUpLevel:getNextLvInfo(level)
    if self._data.xml and self._data.xml.Effect and self._data.xml.Effect[level] and next(self._data.xml.Effect[level]) ~= nil then
        return self._data.xml.Effect[level]
    end
    return {}
end

function StrategyUpLevel:refreshDemand(data)
    self._nodeNeed:removeAllChildren()
    if not data or next(data) == nil then
        return
    end
    self._isUp = true
    local reward = uq.RewardType.parseRewards(data.cost)
    for i = 1, #reward + 1 do
        local item = cc.CSLoader:createNode('strategy/StrateNeed.csb')
        self._nodeNeed:addChild(item)
        item:setPosition(cc.p(0, -(i - 1) * 55))
        local node_base = item:getChildByName("Node_1")
        if i == 1 then
            node_base:getChildByName("icon_spr"):setTexture("img/strategy/s03_00297.png")
            node_base:getChildByName("icon_spr"):setScale(1)
            node_base:getChildByName("dec_txt"):setString(string.format(StaticData['local_text']["strategy.up.need.lv"], data.strategyLevel))
            local lv = uq.cache.role:getBuildingLevel(uq.config.constant.TYPE_BUILDING.STRATEGY_MANSION)
            local is_enough = lv >= data.strategyLevel
            node_base:getChildByName("need_1_img"):setVisible(is_enough)
            node_base:getChildByName("need_2_img"):setVisible(not is_enough)
            if not is_enough then
                self._isUp = false
                self._txt = StaticData['local_text']["strategy.less.lv"]
            end
        else
            local tab_reward = reward[i - 1]:toEquipWidget()
            local info = StaticData.getCostInfo(tab_reward.type, tab_reward.id)
            if info and next(info) ~= nil then
                node_base:getChildByName("icon_spr"):setTexture("img/common/ui/" .. info.miniIcon)
                node_base:getChildByName("icon_spr"):setScale(0.8)

                local rate = uq.cache.role:getBuildOfficerPropertyAdd(uq.config.constant.BUILD_TYPE.STRATEGY, uq.config.constant.BUILD_OFFICER_EFFECT.TYPE_STUDY_COST)
                local cost_num = uq.cache.technology:getStudySurplusCost(tab_reward.num) * (1 - rate)
                cost_num = math.ceil(cost_num)
                local all_num = uq.cache.role:getResNum(tab_reward.type, tab_reward.id)
                node_base:getChildByName("dec_txt"):setString(uq.formatResource(all_num, true) .. "/" .. uq.formatResource(cost_num, true))
                local is_enough = all_num >= cost_num
                node_base:getChildByName("need_1_img"):setVisible(is_enough)
                node_base:getChildByName("need_2_img"):setVisible(not is_enough)
                if not is_enough then
                    self._isUp = false
                    self._txt = string.format(StaticData['local_text']["strategy.less.res"], info.name)
                end
            end
        end
    end
end

function StrategyUpLevel:onFinish(event)
    if event.name ~= "ended" then
        return
    end
    if not self._isUp then
        uq.fadeInfo(self._txt)
        return
    end
    if uq.cache.technology:isFullFinish() then
        uq.fadeInfo(StaticData['local_text']["strategy.is.full"])
        return
    end
    uq.cache.technology:sendFinishMsg(self._data.id)
end

function StrategyUpLevel:onUpLv(event)
    if event.name ~= "ended" then
        return
    end
    if not self._isUp then
        uq.fadeInfo(self._txt)
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
        return
    end
    if uq.cache.technology:isFullFinish() then
        uq.fadeInfo(StaticData['local_text']["strategy.is.full"])
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
        return
    end
    uq.playSoundByID(27)
    network:sendPacket(Protocol.C_2_S_TECHNOLOGY_INTERSIFY, {id = self._data.id})
    self:disposeSelf()
end

function StrategyUpLevel:dispose()
    services:removeEventListenersByTag(self._eventTagRefresh)
    StrategyUpLevel.super.dispose(self)
end

return StrategyUpLevel