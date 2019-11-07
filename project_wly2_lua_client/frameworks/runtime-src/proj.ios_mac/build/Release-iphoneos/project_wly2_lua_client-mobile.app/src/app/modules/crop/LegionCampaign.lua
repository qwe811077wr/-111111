local LegionCampaign = class("LegionCampaign", require('app.base.ModuleBase'))

LegionCampaign.RESOURCE_FILENAME = "crop/LegionCampaign.csb"
LegionCampaign.RESOURCE_BINDING = {
    ["Panel_2"]      = {["varname"] = "_panel"},
    ["img_bg_adapt"] = {["varname"] = "_imgBg"},
    ["Button_left"]  = {["varname"] = "_btnLeft", ["events"] = {{["event"] = "touch",["method"] = "onLeft"}}},
    ["Button_right"] = {["varname"] = "_btnRight", ["events"] = {{["event"] = "touch",["method"] = "onRight"}}},
}
function LegionCampaign:ctor(name, params)
    LegionCampaign.super.ctor(self, name, params)
    self._func = params.func
    self._imgBg:setTouchEnabled(true)
    self._imgBg:setSwallowTouches(true)
end

function LegionCampaign:init()
    self:centerView()

    local top_ui = uq.ui.CommonHeaderUI:create()
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.GESTE))
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.MONEY))
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.GOLDEN))
    top_ui:setTitle(uq.config.constant.MODULE_ID.LEGIN_CAMPAIGN)
    top_ui:setPosition(0, display.height)
    self._topUI = top_ui
    self._view:addChild(top_ui:getNode())

    self:parseView()
    self:initPageView()
    self:onPageChange()
    self:adaptBgSize()

    self._allCampaign = uq.cache.crop._allLegionCampaign.instance_ids
end

function LegionCampaign:onCreate()
    LegionCampaign.super.onCreate(self)

    self._eventTag = services.EVENT_NAMES.ON_LEGION_CAMPAIGN_BACK .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_LEGION_CAMPAIGN_BACK, handler(self, self.onBack), self._eventTag)
end

function LegionCampaign:dispose()
    if self._func then
        self._func()
    end
    services:removeEventListenersByTag(self._eventTag)
    LegionCampaign.super.dispose(self)
end

function LegionCampaign:initPageView()
    self._pageView = ccui.PageView:create()

    local viewSize = self._panel:getContentSize()
    self._pageView:setContentSize(viewSize)
    self._panel:addChild(self._pageView)

    self._pageNum = 0
    if self._allCampaign then
        self._pageNum = #self._allCampaign
    end

    for i = 0, self._pageNum do
        local data = StaticData["legion_campaign"][i + 1]
        if not data then
            return
        end

        local layout = ccui.Layout:create()
        layout:setContentSize(viewSize)
        layout:setPosition(viewSize.width * i, 325)
        self._pageView:insertPage(layout, i)

        local item = uq.createPanelOnly("crop.LegionCampaignCell")
        item:setData(data)
        item:setPosition(viewSize.width / 2, viewSize.height / 2)
        layout:addChild(item)
    end

    self._pageView:addEventListener(handler(self, self.onPageChange))
end

function LegionCampaign:onLeft(event)
    if event.name == "ended" then
        local curPageIndex = self._pageView:getCurrentPageIndex()
        curPageIndex = curPageIndex - 1
        self._btnLeft:setVisible(true)
        self._btnRight:setVisible(true)
        if curPageIndex <= 0 then
            curPageIndex = 0
            self._btnLeft:setVisible(false)
        end

        if self._pageNum == 0 then
            self._btnLeft:setVisible(false)
            self._btnRight:setVisible(false)
        end

        self._pageView:scrollToPage(curPageIndex)
        self:changeBg(curPageIndex)
    end
end

function LegionCampaign:onRight(event)
    if event.name == "ended" then
        local curPageIndex = self._pageView:getCurrentPageIndex()
        curPageIndex = curPageIndex + 1
        self._btnLeft:setVisible(true)
        self._btnRight:setVisible(true)
        if curPageIndex >= self._pageNum - 1 then
            curPageIndex = self._pageNum - 1
            self._btnRight:setVisible(false)
        end

        if self._pageNum == 0 then
            self._btnLeft:setVisible(false)
            self._btnRight:setVisible(false)
        end

        self._pageView:scrollToPage(curPageIndex)
        self:changeBg(curPageIndex)
    end
end

function LegionCampaign:onPageChange()
    local curPageIndex = self._pageView:getCurrentPageIndex()
    if curPageIndex == 0 then
        self._btnLeft:setVisible(false)
    elseif curPageIndex == self._pageNum - 1 then
        self._btnRight:setVisible(false)
    else
        self._btnLeft:setVisible(true)
        self._btnRight:setVisible(true)
    end

    if self._pageNum == 0 then
            self._btnLeft:setVisible(false)
            self._btnRight:setVisible(false)
        end

    self:changeBg(curPageIndex)
end

function LegionCampaign:changeBg(id)
    if id <= 0 then
        id = 0
    end
    self._imgBg:loadTexture("img/crop/" .. StaticData["legion_campaign"][id + 1].map)
end

function LegionCampaign:onBack(event)
    self:disposeSelf()
end

return LegionCampaign