local PopupTabView = class("PopupTabView", require('app.base.ModuleBase'))

function PopupTabView:ctor(name, args)
    PopupTabView.super.ctor(self, name, args)
    self._subModule = nil

    local popup = ccui.Layout:create()
    popup:setTouchEnabled(true)
    popup:setSwallowTouches(true)
    popup:ignoreContentAdaptWithSize(false)
    popup:setContentSize(cc.size(display.width, display.height) )
    self:addChild(popup,-1)

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self, self._onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
    local event_dispatcher = popup:getEventDispatcher()
    event_dispatcher:addEventListenerWithSceneGraphPriority(listener, popup)
end

function PopupTabView:_onTouchBegin(evt)
    return true
end

function PopupTabView:addSub(path, pos, parent, _tab_index, _sub_index)
    self._subModule_show_index = _tab_index
    if not parent  then
        parent = self._view:getChildByName("sub_cont")
    end

    if not self._subModule then
        self._subModule = {}
    end

    for k,v in pairs(self._subModule) do
        v:setVisible(false)
    end

    if self._subModule[_tab_index] ~= nil then
        self._subModule[_tab_index]:setVisible(true)
        self._subModule[_tab_index]:update(_sub_index)
    else
        local m = require(path).new(path, {zOrder=0,tab_index = _tab_index,sub_index = _sub_index})
        if not m then
            return
        end
        m:init()
        self._subModule[_tab_index] = m
        local _subView = self._subModule[_tab_index]
        parent:addChild(_subView)
        if not pos then
            local size = parent:getContentSize()
            pos = cc.p(size.width/2, size.height/2)
        end
        _subView:setPosition(pos)
    end
end

function PopupTabView:dispose()
    if self._subModule then
        for k,v in pairs(self._subModule) do
            v:dispose()
        end
    end
    self._subModule = nil
    PopupTabView.super.dispose(self)
end

return PopupTabView
