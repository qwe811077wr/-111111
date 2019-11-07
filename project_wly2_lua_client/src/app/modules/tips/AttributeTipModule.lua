local AttributeTipModule = class("AttributeTipModule", require("app.base.ModuleBase"))

function AttributeTipModule:ctor(name, args)
    AttributeTipModule.super.ctor(self, name, args)
    self._args = args or {}
    self._allToast = {}
end

function AttributeTipModule:init()
    self:setView(cc.Node:create())
    self:_add(self._args)
    self:setLocalZOrder(uq.ModuleManager.SPECIAL_ZORDER.TIP_ZORDER)
    self:setBaseBgVisible(false)
end

function AttributeTipModule:update(params)
    self:_add(params)
end

function AttributeTipModule:_add(params)
    local color = params.color or '#00FF12'
    local size = params.size or 30
    local font = params.font or "hwkt.ttf"
    local rich_text = uq.RichText:create()
    rich_text:setAnchorPoint(cc.p(0.5, 0.5))
    rich_text:setDefaultFont("res/font/" .. font)
    rich_text:setFontSize(size)
    rich_text:setTextColor(uq.parseColor(color))
    rich_text:setText(params.msg)
    rich_text:formatText()
    rich_text:setPosition(cc.p(params.x - display.width / 2, params.y - display.height / 2))

    local zorder = #self._allToast
    if zorder >= 5 then
        table.remove(self._allToast, 1)
    end
    self:getResourceNode():addChild(rich_text, zorder)
    table.insert(self._allToast, rich_text)

    local action1 = cc.Sequence:create(cc.ScaleTo:create(0.2, 1.2), cc.ScaleTo:create(0.2, 1))
    local action2 = cc.Sequence:create(cc.DelayTime:create(0.4), cc.MoveBy:create(0.3, cc.p(0, 80)), cc.FadeOut:create(0.5), cc.CallFunc:create(function(sender)
        sender:removeSelf()
        table.remove(self._allToast, 1)
        if #self._allToast <= 0 then
            uq.ModuleManager:getInstance():dispose(self:name())
        end
    end))
    rich_text:runAction(cc.Spawn:create(action1, action2))
end

function AttributeTipModule:dispose()
    self._allToast = nil
    self._args = nil
    AttributeTipModule.super.dispose(self)
end

return AttributeTipModule