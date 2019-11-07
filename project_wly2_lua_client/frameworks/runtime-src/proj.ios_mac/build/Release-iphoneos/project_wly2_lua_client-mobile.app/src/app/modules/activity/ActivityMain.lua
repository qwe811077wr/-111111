local ActivityMain = class("ActivityMain", require('app.modules.common.BaseViewWithHead'))

ActivityMain.RESOURCE_FILENAME = "activity/Activity.csb"
ActivityMain.RESOURCE_BINDING = {
    ["ScrollView_2"]              = {["varname"] = "_scrollView"},
}
function ActivityMain:ctor(name, params)
    ActivityMain.super.ctor(self, name, params)
end

function ActivityMain:init()
    self:addShowCoinGroup({uq.config.constant.COST_RES_TYPE.MONEY, uq.config.constant.COST_RES_TYPE.GOLDEN})
    self:centerView()
    self:parseView()
    self:adaptBgSize()

    self._boxWith = 415
    self._redType = {
        [1] = uq.cache.hint_status.RED_TYPE.ACHIEVEMENT_SEVEN,
        [2] = uq.cache.hint_status.RED_TYPE.ACHIEVEMENT_LEVEL,
        [4] = uq.cache.hint_status.RED_TYPE.ACHIEVEMENT_SIGN
    }
    self._allRedImg = {}
    self._listData1 = self:dealData(2)
    self._listData2 = self:dealData(1)
    self._selectIndex = 0
    self._isClick = true
    self:_onAchievementInsideRed()
    self:setTitle(uq.config.constant.MODULE_ID.ACTIVITY_MAIN)
    self:refreshScroll()
    self:refreshAllBoxsRed()
    self._eventRedInsideTag = services.EVENT_NAMES.ON_ACHIEVEMENT_INSIDE_RED .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_ACHIEVEMENT_INSIDE_RED, handler(self, self._onAchievementInsideRed), self._eventRedInsideTag)
    self._eventRedPass = services.EVENT_NAMES.ON_PASS_CHECK_RED_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_PASS_CHECK_RED_REFRESH, handler(self, self.refreshAllBoxsRed), self._eventRedPass)

    self._eventRefresh = '_eventRefresh' .. tostring(self)
    uq.TimerProxy:addTimer(self._eventRefresh, handler(self, self.refreshBoxsStatus), 10, -1)
end

function ActivityMain:refreshScroll()
    self._allRedImg = {}
    self._scrollView:removeAllChildren()
    local boxs_num = #self._listData2 + math.ceil(#self._listData1 / 2)
    for i = 1, boxs_num do
        local pos_x, pos_y = self:getPositionByIndex(i)
        if i <= #self._listData2 then
            self:addOne(self._listData2[i], cc.p(pos_x, pos_y))
        else
            for j = 1, 2 do
                local btw = self._boxWith / 4
                local off_x = j == 1 and -btw or btw
                local last_idx = (i - #self._listData2 - 1) * 2
                self:addOne(self._listData1[last_idx + j], cc.p(pos_x + off_x, pos_y))
            end
        end
    end
    self._scrollView:setScrollBarEnabled(false)
    self._scrollView:setInnerContainerSize(cc.size(self._boxWith * math.ceil(boxs_num / 2), 590))
end

function ActivityMain:addOne(data, pos)
    if not data then
        return
    end
    local item_temp = cc.CSLoader:createNode('activity/ActivityBoxs.csb')
    self._scrollView:addChild(item_temp)
    local node = item_temp:getChildByName("Node_1")
    local min_node = node:getChildByName("min_node")
    local max_node = node:getChildByName("max_node")
    local name_spr = node:getChildByName("name_spr")
    local dec_txt = node:getChildByName("dec_txt")
    item_temp:setPosition(pos)
    dec_txt:setString(data.desc)
    name_spr:setTexture("img/activity/" .. data.nameImg)
    min_node:setVisible(data.imgType ~= 1)
    max_node:setVisible(data.imgType == 1)
    local show_node = min_node
    if data.imgType == 1 then
        show_node = max_node
    end
    show_node:getChildByName("icon_spr"):setTexture("img/activity/" .. data.moduleImg)
    show_node:getChildByName("bg_img"):setSwallowTouches(false)
    show_node:getChildByName("bg_img"):addClickEventListenerWithSound(function()
        if data.module then
            uq.jumpToModule(data.module)
        end
    end)
    local red_img = show_node:getChildByName("red_img")
    table.insert(self._allRedImg, {img = red_img , txt = dec_txt, data = data})
    uq.intoAction(node, nil, nil, nil, 0.5)
end
function ActivityMain:refreshAllBoxsRed()
    for i, v in ipairs(self._allRedImg) do
        local data = v.data or {}
        if data and next(data) ~= nil then
            if data.ident == 3 then
                v.img:setVisible(uq.cache.pass_check:isRedModule(1))
            elseif self._redType[data.ident] then
                v.img:setVisible(uq.cache.hint_status.status[self._redType[data.ident]])
            end
            if data.type ~= uq.config.constant.TYPE_ACTIVITY_TIME_LIMIT.RESIDENT then
                v.txt:setString(self:getTxtDec(data))
            end
        end
    end
end

function ActivityMain:getPositionByIndex(idx)
    local pos_y = 445
    if idx % 2 == 0 then
        pos_y = 150
    end
    return (math.ceil(idx / 2) - 0.5) * self._boxWith, pos_y
end

function ActivityMain:_onAchievementInsideRed(msg)
    self:refreshBoxsStatus()
end

function ActivityMain:dealData(img_type)
    local tab = {}
    local data = StaticData['welfare'] or {}
    for _, v in ipairs(data) do
        if v.imgType == img_type then
            if self:isOpenModules(v) then
                table.insert(tab, v)
            end
        end
    end
    table.sort(tab, function (a, b)
        return a.show < b.show
    end)
    return tab
end

function ActivityMain:isOpenModules(data)
    if data.type == uq.config.constant.TYPE_ACTIVITY_TIME_LIMIT.RESIDENT then
        return true
    elseif data.type == uq.config.constant.TYPE_ACTIVITY_TIME_LIMIT.CREATE_ROLE then
        local time = uq.cache.achievement:getBageinCreateTime(uq.cache.role.create_time) + data.param * 24 * 3600
        if data.ident == 1 then
            return uq.curServerSecond() < time or uq.cache.hint_status.status[uq.cache.hint_status.RED_TYPE.ACHIEVEMENT_SEVEN]
        end
        return uq.curServerSecond() < time
    elseif data.type == uq.config.constant.TYPE_ACTIVITY_TIME_LIMIT.WAR_ORDER then
        return uq.cache.pass_check:isCanOpenPassCheck()
    else
        return false
    end
end

function ActivityMain:getTxtDec(data)
    if data.type == uq.config.constant.TYPE_ACTIVITY_TIME_LIMIT.CREATE_ROLE then
        local time = uq.cache.achievement:getSevenSurplusTime()
        if time >= 0 then
            return self:getTimeDayHourMinutes(time)
        end
        return StaticData["local_text"]["activity.end"]
    elseif data.type == uq.config.constant.TYPE_ACTIVITY_TIME_LIMIT.WAR_ORDER then
        return self:getTimeDayHourMinutes(math.max(uq.cache.pass_check._seasonEndTime - uq.curServerSecond(), 0))
    else
        return ""
    end
end

function ActivityMain:getTimeDayHourMinutes(time)
    local time = time or 0
    local day = math.floor(time / 86400)
    local hour = math.floor((time - day * 86400) / 3600)
    local minutes = math.floor((time - day * 86400 - hour * 3600) / 60) + 1
    return StaticData["local_text"]["activity.end.surplus.time"] .. string.format(StaticData["local_text"]["activity.sign.surplus.time"], day, hour, minutes)
end

function ActivityMain:refreshBoxsStatus()
    local is_refresh = false
    for i = 1, 2 do
        local tab = self["_listData" .. i] or {}
        if #tab > 0 then
            for j = #tab, 1, -1 do
                if not self:isOpenModules(tab[j]) then
                    is_refresh = true
                    table.remove(tab, j)
                end
            end
        end
    end
    if is_refresh then
        self:refreshScroll()
    end
    self:refreshAllBoxsRed()
end

function ActivityMain:dispose()
    services:removeEventListenersByTag(self._eventRedInsideTag)
    services:removeEventListenersByTag(self._eventRedPass)
    uq.TimerProxy:removeTimer(self._eventRefresh)
    ActivityMain.super.dispose(self)
end

return ActivityMain