local TavernView = class("TavernView", require('app.modules.common.BaseViewWithHead'))

TavernView.RESOURCE_FILENAME = "tavern/TavernView.csb"
TavernView.RESOURCE_BINDING = {
    ["Node_2"]                     = {["varname"] = "_itemNode"},
    ["preview_btn"]                = {["varname"] = "_btnPreview"},
    ["ten_btn"]                    = {["varname"] = "_btnTen"},
    ["one_btn"]                    = {["varname"] = "_btnOne"},
    ["ten_txt"]                    = {["varname"] = "_txtTen"},
    ["one_txt"]                    = {["varname"] = "_txtOne"},
    ["Image_6"]                    = {["varname"] = "_imgCost1"},
    ["Image_6_0"]                  = {["varname"] = "_imgCost2"},
    ["jar_img"]                    = {["varname"] = "_imgJar"},
    ["Button_4"]                   = {["varname"] = "_btnLeft"},
    ["Button_4_0"]                 = {["varname"] = "_btnRight"},
    ["Text_7"]                     = {["varname"] = "_txtName"},
    ["Image_2"]                   = {["varname"] = "_imgIcon"},
    ["Node_2/jar_1_pnl"]           = {["varname"] = "_pnl1"},
    ["Node_2/jar_2_pnl"]           = {["varname"] = "_pnl3"},
    ["Node_2/jar_3_pnl"]           = {["varname"] = "_pnl5"},
    ["Node_2/jar_4_pnl"]           = {["varname"] = "_pnl2"},
    ["Node_2/jar_5_pnl"]           = {["varname"] = "_pnl4"},
    ["Node_2/jar_6_pnl"]           = {["varname"] = "_pnl6"},
    ["Node_1"]                     = {["varname"] = "_node"},
    ["Node_1/Text_3"]              = {["varname"] = "_txtStrFree"},
    ["Node_1/Text_4"]              = {["varname"] = "_txtTimesFree"},
    ["Node_1/Image_5"]             = {["varname"] = "_imgJarBg"},
    ["Node_1/left_1_img"]          = {["varname"] = "_imgLeft1"},
    ["Node_1/left_2_img"]          = {["varname"] = "_imgLeft2"},
    ["Node_1/right_1_img"]         = {["varname"] = "_imgRight1"},
    ["Node_1/right_2_img"]         = {["varname"] = "_imgRight2"},
}

function TavernView:init()
    self._selectIndex = 1
    self._allItem = {}
    self._allList = self:getListData()
    self._differValue = {
        [1] = 1,
        [2] = -1,
        [3] = 2,
        [4] = -2,
        [5] = 3,
        [6] = -3,
    }
    self:initLayer()
    self:centerView()
    self:parseView()
    self:addShowCoinGroup({uq.config.constant.COST_RES_TYPE.MONEY, uq.config.constant.COST_RES_TYPE.GOLDEN})
    self:setTitle(uq.config.constant.MODULE_ID.TAVERN_VIEW)
    self._eventDo = services.EVENT_NAMES.ON_TAVERN_DO .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_TAVERN_DO, handler(self, self.refreshLayer), self._eventDo)
end

function TavernView:onCreate()
    TavernView.super.onCreate(self)
end

function TavernView:initLayer()
    local num = math.min(math.max(#self._allList - 1, 0), 6)
    for i = 1, num do
        local item = uq.createPanelOnly("tavern.TavernItem")
        local func = function (index)
            self:dealSelect(self._differValue[index])
        end
        item:initlayer(func)
        self["_pnl" .. i]:addChild(item)
        self._allItem[i] = item
    end
    self:refreshItem(true)
    self:refreshLayer()
    self._btnLeft:addClickEventListenerWithSound(function()
        self:dealSelect(-1)
        end)
    self._btnRight:addClickEventListenerWithSound(function()
        self:dealSelect(1)
        end)
    self._btnOne:addClickEventListener(function()
        self:costDrink(false)
        end)
    self._btnTen:addClickEventListener(function()
        self:costDrink(true)
        end)
    self._btnPreview:addClickEventListenerWithSound(function()
        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.TAVERN_REWARD_PREVIEW, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
        if panel then
            panel:setData(self._selectIndex)
        end
        end)
    local move1 = cc.MoveBy:create(3, cc.p(0, 10))
    local move2 = cc.MoveBy:create(6, cc.p(0, -20))
    self._imgJar:runAction(cc.RepeatForever:create(cc.Sequence:create(move1, move2, move1, nil)))
    uq:addEffectByNode(self._imgJar, 900034, -1, true)
    uq:addEffectByNode(self._imgJar, 900033, -1, true, cc.p(180, -90))
    uq:addEffectByNode(self._imgJar, 900038, -1, true, cc.p(180, -30))
    uq:addEffectByNode(self._imgJarBg, 900035, -1, true, cc.p(185, 340))
    uq:addEffectByNode(self._imgLeft1, 900036, -1, true, cc.p(55, -37))
    uq:addEffectByNode(self._imgLeft2, 900036, -1, true, cc.p(50, -37))
    uq:addEffectByNode(self._imgRight1, 900036, -1, true, cc.p(52, -37))
    uq:addEffectByNode(self._imgRight2, 900036, -1, true, cc.p(52, -37))
    uq:addEffectByNode(self._node, 900033, -1, true, cc.p(430, 750))
    uq:addEffectByNode(self._node, 900033, -1, true, cc.p(850, 750))
    uq:addEffectByNode(self._node, 900033, -1, true, cc.p(50, 550))
    uq:addEffectByNode(self._node, 900033, -1, true, cc.p(100, 720))
    uq:addEffectByNode(self._node, 900033, -1, true, cc.p(230, 680))
    --uq:addEffectByNode(self._node, 900037, -1, true, cc.p(430, 50))
    --uq:addEffectByNode(self._node, 900037, -1, true, cc.p(1100, 50))
    uq:addEffectByNode(self._btnPreview, 900052, -1, true, cc.p(50, 100))
end


function TavernView:refreshLayer()
    local data = self._allList[self._selectIndex]
    if not data then
        return
    end
    local str = ""
    local tab_char = string.toChars(data.city)
    for i, v in ipairs(tab_char) do
        if str == "" then
            str = str .. v
        else
            str = str .. "\n" .. v
        end
    end
    self._txtName:setString(str)
    self._imgIcon:loadTexture("img/common/general_body/" .. data.icon)
    self._txtTen:setString("")
    self._txtOne:setString("")
    local cost_type, cost_num = uq.cache.tavern:getCostTypeAndNumById(data.ident, true)
    if cost_num ~= nil then
        self._txtTen:setString(tonumber(cost_num))
        local info = StaticData['types'].Cost[1].Type[cost_type]
        if info and info.miniIcon then
            self._imgCost1:loadTexture("img/common/ui/" .. info.miniIcon)
        end
    end
    cost_type, cost_num = uq.cache.tavern:getCostTypeAndNumById(data.ident)
    if cost_num ~= nil then
        self._txtOne:setString(tonumber(cost_num))
        local info = StaticData['types'].Cost[1].Type[cost_type]
        if info and info.miniIcon then
            self._imgCost2:loadTexture("img/common/ui/" .. info.miniIcon)
        end
    end
    local free_times = uq.cache.tavern:getFreeTimes(data.ident)
    self._txtTimesFree:setString(free_times .. "/" .. data.free)
    self._txtTimesFree:setVisible(data.free ~= 0)
    self._txtStrFree:setVisible(data.free ~= 0)
end

function TavernView:refreshItem(is_bool)
    for i, v in ipairs(self._allItem) do
        v:refreshData(self:getItemData(i), i, is_bool)
    end
end

function TavernView:costDrink(is_ten)
    local data = self._allList[self._selectIndex]
    if not data then
        return
    end
    uq.cache.tavern:sendTavernMsg(data.ident, is_ten)
end

function TavernView:getItemData(idx)
    local differ_value = self._differValue[idx]
    local num = self:getSuitIndex(differ_value)
    return self._allList[num] or {}
end

function TavernView:getListData()
    return StaticData['appoint_item'] or {}
end

function TavernView:dealSelect(value)
    local index = self:getSuitIndex(value)
    if self._allList[index].showLevel > uq.cache.role:level() then
        uq.fadeInfo(string.format(StaticData["local_text"]["tavern.lv.limit"], self._allList[index].showLevel, self._allList[index].city))
        return
    end
    self._selectIndex = index
    self:refreshItem()
    self:refreshLayer()
end

function TavernView:getSuitIndex(value)
    local index = self._selectIndex + value
    if index < 1 then
        index = index + #self._allList
    elseif index > #self._allList then
        index = index - #self._allList
    end
    return index
end

function TavernView:dispose()
    services:removeEventListenersByTag(self._eventDo)
    TavernView.super.dispose(self)
end

return TavernView