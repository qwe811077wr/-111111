
--[[
    author:zhongqilong
    用于全屏界面基类
]]
local BaseViewWithHead = class("BaseViewWithHead", require('app.base.ModuleBase'))

function BaseViewWithHead:ctor(name, params)
    BaseViewWithHead.super.ctor(self, name, params)
    self:initUI()
end

function BaseViewWithHead:setTitle(id)
    self._topUI:setTitle(id)
end

function BaseViewWithHead:setRuleId(rule_id)
    self._topUI:setRuleId(rule_id)
end

function BaseViewWithHead:onCreate()
    BaseViewWithHead.super.onCreate(self)
end

function BaseViewWithHead:setBgVisible(visible)
    self._topUI:setBgVisible(visible)
end

function BaseViewWithHead:initUI()
    self._hideMainUI = false

    local top_ui = uq.ui.CommonHeaderUI:create()
    self._topUI = top_ui
    self:addChild(top_ui)
end

function BaseViewWithHead:endActionTop()
    self._topUI:endActionTop()
end

--隐藏主城的UI
function BaseViewWithHead:hideMainUI()
    self._hideMainUI = true
    services:dispatchEvent({name = services.EVENT_NAMES.ON_HIDE_MAIN_UI})
end

function BaseViewWithHead:showMainUI()
    if self._hideMainUI then
        services:dispatchEvent({name = services.EVENT_NAMES.ON_SHOW_MAIN_UI})
    end
end

function BaseViewWithHead:onCleanup()
    BaseViewWithHead.super:onCleanup()
    self:showMainUI()
end

function BaseViewWithHead:addShowCoinGroup(show_type)
    for k, v in ipairs(show_type) do
        if type(v) == "table" then
            self._topUI:addResItem(uq.ui.ResourceBox.createRes(v.type, true, v.id))
        else
            self._topUI:addResItem(uq.ui.ResourceBox.createRes(v, true))
        end
    end
end

function BaseViewWithHead:setCloseBack(callback)
    self._topUI:getBackBtn():addClickEventListenerWithSound(function()
        callback({name = "ended"})
    end)
end

return BaseViewWithHead