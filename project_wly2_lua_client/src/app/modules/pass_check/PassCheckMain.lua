local PassCheckMain = class("PassCheckMain", require('app.base.ModuleBase'))

PassCheckMain.RESOURCE_FILENAME = "pass_check/PassCheckMain.csb"
PassCheckMain.RESOURCE_BINDING = {
    ["Image_bg"]            = {["varname"] = "_imgBg"},
    ["Node_7"]              = {["varname"] = "_node"},
    ["Panel_1"]             = {["varname"] = "_pnlClick"},
    ["left_node"]           = {["varname"] = "_nodeLeftBottom"},
    ["Button_1"]            = {["varname"] = "_btn1", ["events"] = {{["event"] = "touch",["method"] = "onChanged",["sound_id"] = 0}}},
    ["Button_2"]            = {["varname"] = "_btn2", ["events"] = {{["event"] = "touch",["method"] = "onChanged",["sound_id"] = 0}}},
    ["Button_3"]            = {["varname"] = "_btn3", ["events"] = {{["event"] = "touch",["method"] = "onChanged",["sound_id"] = 0}}},
    ["Button_4"]            = {["varname"] = "_btn4", ["events"] = {{["event"] = "touch",["method"] = "onChanged",["sound_id"] = 0}}},
    ["Button_5"]            = {["varname"] = "_btn5", ["events"] = {{["event"] = "touch",["method"] = "onChanged",["sound_id"] = 0}}},
    ["Button_6"]            = {["varname"] = "_btn6", ["events"] = {{["event"] = "touch",["method"] = "onChanged",["sound_id"] = 0}}},
}

PassCheckMain.SUB_MODULES = {
    "PassCheckLevel",        --考核等级
    "PassCheckDaysWelfare",  --14天福利
    "PassCheckTaskExam",     --考核任务
    "PassCheckDailyDeal",    --每日特惠
    "PassCheckLimitPackage", --限定礼包
    "PassCheckLimitStore", --龙币商店
}

function PassCheckMain:ctor(name, params)
    PassCheckMain.super.ctor(self, name, params)

    self._imgBg:setTouchEnabled(true)
    self._imgBg:setSwallowTouches(true)
end

function PassCheckMain:init()
    local top_ui = uq.ui.CommonHeaderUI:create()
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.GLORY_BADGE))
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.MONEY))
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.GOLDEN))
    top_ui:setTitle(uq.config.constant.MODULE_ID.PASS_CHECK)
    self._topUI = top_ui
    self._view:addChild(top_ui:getNode())

    self._modules = {}
    self._btn = {}
    self._curIndex = 1
    self._isOpenRule = false
    self._info = uq.cache.pass_check._passCardInfo

    self:centerView()
    self:parseView()
    self:adaptNode()
    self:initButton()
    self:refreshPageSign()
    self:showPassCardRed()
    self._pnlClick:setContentSize(display.size)
    self:adaptBgSize(self._imgBg)
    self:adaptBgSize(self._pnlClick)

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self, self._onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self._onTouchEnd), cc.Handler.EVENT_TOUCH_ENDED)
    local event_dispatcher = self._pnlClick:getEventDispatcher()
    event_dispatcher:addEventListenerWithSceneGraphPriority(listener, self._pnlClick)
end

function PassCheckMain:onCreate()
    PassCheckMain.super.onCreate(self)

    self._eventTag = services.EVENT_NAMES.ON_PASS_CHECK_BUY_LEVEL .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_PASS_CHECK_BUY_LEVEL, handler(self, self.onBuyLevel), self._eventTag)

    self._eventTag1 = services.EVENT_NAMES.ON_REFRESH_PASS_CHECK_INFO .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_REFRESH_PASS_CHECK_INFO, handler(self, self.onPassUpdate), self._eventTag1)

    self._eventPass = services.EVENT_NAMES.ON_PASS_CHECK_RED_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_PASS_CHECK_RED_REFRESH, handler(self, self.showPassCardRed), self._eventPass)

    self._eventShowLevel = services.EVENT_NAMES.ON_PASS_CHECK_LEVEL_SHOW .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_PASS_CHECK_LEVEL_SHOW, handler(self, self.showPassCardLevel), self._eventShowLevel)
end

function PassCheckMain:initButton()
    for i = 1, 6 do
        local btn = self["_btn" .. i]
        btn['userData'] = i
        self._btn[i] = btn
    end
    self:refreshBtn()
end

function PassCheckMain:onPassUpdate()
    self:refreshBtn()
end

function PassCheckMain:refreshBtn()
    for i = 1, 6 do
        local btn = self._btn[i]
        local is_hide_btn = (i == 5 or i == 6) and self._info.state == 0
        btn:setVisible(not is_hide_btn)
        local is_show_title = ((i == 5 or i == 6) and not self:isOpenPackage()) or (i > 2 and self._info.state == 0)
        btn:getChildByName("Image_3"):setVisible(is_show_title)
    end
end

function PassCheckMain:showPassCardRed()
    for i = 1, 6 do
        local is_exist = uq.cache.pass_check._reds[i]
        local size = self._btn[i]:getContentSize()
        uq.showRedStatus(self._btn[i], is_exist, size.width / 2 - 10, size.height / 2 - 10)
    end
end

function PassCheckMain:refreshPageSign()
    local color = uq.parseColor("#ffffff")
    local color1 = uq.parseColor("#7fb5bf")
    local pre_path = 'img/pass_check/'
    for k, v in pairs(self._modules) do
        self._btn[k]:setEnabled(true)
        self._btn[k]:getChildByName("Text_1"):setTextColor(color1)
        v:setVisible(false)
    end

    if self._modules[self._curIndex] then
        self._modules[self._curIndex]:setVisible(true)
    else
        local panel = uq.createPanelOnly(string.format("pass_check.%s", self.SUB_MODULES[self._curIndex]))
        panel:setPositionX(-75)
        if panel.setRuleState then
            panel:setRuleState(function ()
                self._isOpenRule = true
            end)
        end
        self._node:addChild(panel)
        self._modules[self._curIndex] = panel
    end
    self._btn[self._curIndex]:setEnabled(false)
    self._btn[self._curIndex]:getChildByName("Text_1"):setTextColor(color)
    self._modules[self._curIndex]:showAction()
end

function PassCheckMain:isOpenPackage()
    local tab = StaticData['pass'].Info[1].SpecialGift
    if tab and tab[1] and tab[1].openLevel then
        return self._info.level >= tonumber(tab[1].openLevel)
    end
    return false
end

function PassCheckMain:onChanged(event)
    if event.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.CHANGE)
    local idx = event.target['userData']
    if (idx == 5 or idx == 6) and not self:isOpenPackage() then
        uq.fadeInfo(StaticData['local_text']['pass.open.lv'])
    elseif (self._info.state == 0 and idx > 2) then
        uq.fadeInfo(StaticData['local_text']['pass.fun.tips'])
    else
        self._curIndex = idx
        self:refreshPageSign()
    end
end

function PassCheckMain:onBuyLevel()
    uq.fadeInfo(StaticData['local_text']['ancient.city.add.num.des3'])
end

function PassCheckMain:showPassCardLevel(msg)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.PASS_UP_LEVEL,
        {zOrder = uq.ModuleManager.SPECIAL_ZORDER.TIP_ZORDER - 20, data = msg.data, close_open_action = true})
end

function PassCheckMain:_onTouchBegin(touch, event)
    return self._isOpenRule
end

function PassCheckMain:_onTouchEnd(touch, event)
    local panel = self._modules[self._curIndex]
    if panel.closeRule then
        panel:closeRule()
    end
    self._isOpenRule = false
    return true
end

function PassCheckMain:dispose()
    services:removeEventListenersByTag(self._eventTag)
    services:removeEventListenersByTag(self._eventTag1)
    services:removeEventListenersByTag(self._eventPass)
    services:removeEventListenersByTag(self._eventShowLevel)
    PassCheckMain.super.dispose(self)
end

return PassCheckMain