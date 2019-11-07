local ToastModule = class("ToastModule", require("app.base.ModuleBase"))

function ToastModule:ctor(name, args)
    ToastModule.super.ctor(self, name, args)
    self._args = args or {}
    self._allToast = {}
end

function ToastModule:init()
    self:setView(cc.Node:create())
    self:_add(self._args)
    self:setLocalZOrder(uq.ModuleManager.SPECIAL_ZORDER.TIP_ZORDER)
    self:setBaseBgVisible(false)
end

function ToastModule:update(params)
    self:_add(params)
end

function ToastModule:_add(params)
    local bg = params.bg or 'img/main_city/s03_000394.png'
    local image_bg = ccui.ImageView:create(bg)
    image_bg:setScale9Enabled(true)
    local size = image_bg:getContentSize()
    local zorder = #self._allToast
    self:getResourceNode():addChild(image_bg, zorder)
    if zorder >= 5 then
        table.remove(self._allToast, 1)
    end
    table.insert(self._allToast, image_bg)
    local oy = params.y or display.cy
    image_bg:setPosition(cc.p(params.x or display.cx, oy + 111))
    if params.effect then
        local ox = params.off_x or 0
        local oy = params.off_y or 0
        uq:addEffectByNode(image_bg, params.effect, 1, true, cc.p(size.width / 2 + ox, size.height / 2 + oy), nil, nil, nil, nil, -1)
    end
    local rich_text = uq.RichText:create()
    rich_text:setAnchorPoint(cc.p(0.5, 0.5))
    rich_text:setDefaultFont("res/font/hwkt.ttf")
    rich_text:setFontSize(20)
    rich_text:setContentSize(cc.size(0, size.height))
    rich_text:setTextColor(cc.c3b(255, 255, 255))
    image_bg:addChild(rich_text)
    rich_text:setText(params.msg)
    rich_text:formatText()
    size = image_bg:getContentSize()
    rich_text:setPosition(cc.p(size.width / 2, size.height / 2))

    local action1 = cc.Sequence:create(cc.DelayTime:create(0.5), cc.MoveBy:create(0.5, cc.p(0, 80)))
    local action2 = cc.Sequence:create(cc.DelayTime:create(0.5), cc.FadeOut:create(0.5), cc.CallFunc:create(function(sender)
        image_bg:removeSelf()
        table.remove(self._allToast, 1)
        if #self._allToast <= 0 then
            uq.ModuleManager:getInstance():dispose(self:name())
        end
    end))
    image_bg:runAction(cc.Spawn:create(action1, action2))
end

function ToastModule:dispose()
    self._allToast = nil
    self._args = nil
    ToastModule.super.dispose(self)
end

return ToastModule