local DecreeMain = class("DecreeMain", require('app.base.PopupBase'))

DecreeMain.RESOURCE_FILENAME = "decree/DecreeMain.csb"
DecreeMain.RESOURCE_BINDING = {
    ["ScrollView_1"]                           = {["varname"] = "_scrollView"},
    ["cion_txt"]                               = {["varname"] = "_txtCion"},
    ["close_btn"]                              = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onClose",["sound_id"] = 0}}},
    ["Node_2"]                                 = {["varname"] = "_nodeReward"},
    ["dec_txt"]                                = {["varname"] = "_txtDec"},
    ["Panel_1"]                                = {["varname"] = "_pnlAction"},
    ["cost_times_txt"]                         = {["varname"] = "_txtCostTimes"},
    ["Text_4_0"]                               = {["varname"] = "_txtCost"},
    ["time_txt"]                               = {["varname"] = "_txtTime"},
    ["rule_btn"]                               = {["varname"] = "_btnRule",["events"] = {{["event"] = "touch",["method"] = "onRule"}}},
}

function DecreeMain:ctor(name, params)
    DecreeMain.super.ctor(self, name, params)
    self:centerView()
    self:parseView()
    self:setLayerColor(0.4)
    self._time = 0
    self._xml = StaticData['government'].Guanyin or {}
    self._xmlList = StaticData['government'].Government or {}
    self._maxNum = StaticData['government'].Guanyin[1].limit or 24
    self:initLayer()
    self._onLoadDecree = services.EVENT_NAMES.ON_CONSUME_RES_CHANGE .. uq.config.constant.COST_RES_TYPE.RT_DECREE .. tostring(self)
    self._onDecree = "_onDecree" .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_CONSUME_RES_CHANGE .. uq.config.constant.COST_RES_TYPE.RT_DECREE, handler(self, self.refreshCion), self._onLoadDecree)
    network:addEventListener(Protocol.S_2_C_DECREE, handler(self, self._onDecreeShow),self._onDecree)
    self:refreshCion()
    self._refreshResTime = 'update_res_time' .. tostring(self)
    network:addEventListener(Protocol.S_2_C_LOAD_RESOURCE_REFRESH, handler(self, self._refreshTime), self._refreshResTime)
    self._onTimeRefresh = "_onRefreshTime" .. tostring(self)
    uq.TimerProxy:addTimer(self._onTimeRefresh, handler(self, self._onRefreshTime), 1, -1)
    self:_onRefreshTime()
end

function DecreeMain:initLayer()
    self._scrollView:setScrollBarEnabled(false)
    if not self._xmlList or next(self._xmlList) == nil then
        return
    end
    self._scrollView:removeAllChildren()
    for i, v in ipairs(self._xmlList) do
        local items = uq.createPanelOnly("decree.DecreeBoxs")
        self._scrollView:addChild(items)
        items:setPosition(cc.p((i - 0.5) * 195, 260))
        items:setData(v)
    end
    self._scrollView:setInnerContainerSize(cc.size(#self._xmlList * 196, 520))
end

function DecreeMain:refreshCion()
    self._txtCion:setString(uq.cache.decree:getNumDecree() .. "/" .. self._maxNum)
end

function DecreeMain:_refreshTime(msg)
    local data = msg.data
    self._time = data.cd_time + os.time()
    self:_onRefreshTime()
end

function DecreeMain:_onRefreshTime()
    if self._time - os.time() <= 0 then
        network:sendPacket(Protocol.C_2_S_LOAD_RESOURCE_REFRESH, {id = uq.config.constant.COST_RES_TYPE.RT_DECREE})
    else
        self._txtTime:setString(uq.getTime(self._time - os.time(), uq.config.constant.TIME_TYPE.HHMMSS))
    end
end

function DecreeMain:onClose(event)
    if event.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BACK)
    self:disposeSelf()
end

function DecreeMain:dispose()
    network:removeEventListenerByTag(self._onDecree)
    network:removeEventListenerByTag(self._refreshResTime)
    services:removeEventListenersByTag(self._onLoadDecree)
    uq.TimerProxy:removeTimer(self._onTimeRefresh)
    DecreeMain.super.dispose(self)
end

function DecreeMain:dealReward(id, data)
    local all_str ={}
    local reward = uq.cache.decree:getDecreeReWard(id)
    for i = 1, #data do
        for _, v in ipairs(reward) do
            local xml_data = StaticData.getCostInfo(v.type, v.id)
            if xml_data and xml_data.name then
                local rate = data[i] or 1
                table.insert(all_str, {num = v.num , rate = rate, png = "img/common/ui/" .. xml_data.miniIcon})
            end
        end
    end
    for i, v in ipairs(all_str) do
        local str = v.rate == 1 and  string.format(StaticData['local_text']['decree.reward.show1'], '<img ' .. v.png .. '>', v.num) or string.format(StaticData['local_text']['decree.reward.show'], '<img ' .. v.png .. '>', v.num, v.rate)
        uq.fadeInfo(str)
    end
end

function DecreeMain:_onDecreeShow(msg)
    local data = msg.data
    if not data.items or next(data.items) == 0 then
        return
    end
    local tab_rate = {}
    for i, v in ipairs(data.items) do
        if v.builds and v.builds[1] and v.builds[1].rate then
            table.insert(tab_rate, v.builds[1].rate)
        end
    end
    if tab_rate and next(tab_rate) ~= nil then
        self:dealReward(data.id, tab_rate)
    end
end

function DecreeMain:onRule(event)
    if event.name ~= "ended" then
        return
    end
    local info = StaticData['rule'][uq.config.constant.MODULE_RULE_ID.DECREE]
    if not info then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ANCIENT_CITY_RULE, {info = info})
end

return DecreeMain