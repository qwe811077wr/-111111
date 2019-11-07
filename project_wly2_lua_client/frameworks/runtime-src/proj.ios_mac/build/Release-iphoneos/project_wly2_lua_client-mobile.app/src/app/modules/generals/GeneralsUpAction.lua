local GeneralsUpAction = class("GeneralsUpAction", require("app.base.TableViewBase"))

GeneralsUpAction.RESOURCE_FILENAME = "generals/GeneralUpAction.csb"
GeneralsUpAction.RESOURCE_BINDING  = {
    ["action_node"]                       ={["varname"] = "_nodeBase"},
    ["show_node"]                         ={["varname"] = "_nodeShow"},
    ["Panel_1"]                           ={["varname"] = "_pnlUp"},
}
function GeneralsUpAction:ctor(name, args)
    GeneralsUpAction.super.ctor(self)
    self:init()
end

function GeneralsUpAction:init()
    self:parseView()
    self._num = 1
    self._pnlUp:setVisible(false)
    self._eventUp = services.EVENT_NAMES.ON_GENERALS_QUALITY_UP_ACTION .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_GENERALS_QUALITY_UP_ACTION, handler(self, self.showActionUp), self._eventUp)
end

function GeneralsUpAction:showActionUp(msg)
    local data = msg.data or {}
    if not data or next(data) == nil then
        return
    end
    self._num = #data
    local pnl = self._pnlUp:clone()
    self._nodeShow:addChild(pnl)
    self:addTextLabel(pnl)
    self:initActionUpNode(pnl)
    self:setStringUpNode(pnl, data)
    self:runActionUpNode(pnl)
end

function GeneralsUpAction:addTextLabel(node)
    node.txt1 = node:getChildByName("Text_1")
    for i = 1, self._num - 1 do
        local txt_label = node.txt1:clone()
        txt_label:setPositionY(node.txt1:getPositionY() - 40 * i)
        node:addChild(txt_label)
        node["txt" .. i + 1] = txt_label
    end
    if self._num > 6 then
        node:setPositionY((self._num - 6) * 40)
    end
end

function GeneralsUpAction:initActionUpNode(node)
    node:setVisible(true)
    for i = 1, self._num do
        node["txt" .. i]:setScaleX(0)
    end
end

function GeneralsUpAction:setStringUpNode(node, data)
    for i = 1, self._num do
        local str = data[i] or ""
        node["txt" .. i]:setString(str)
    end
end

function GeneralsUpAction:runActionUpNode(node)
    uq:addEffectByNode(node:getChildByName("action_pnl"), 900077, 1, true, cc.p(0, 50))
    for i = 1, self._num do
        node["txt" .. i]:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.7 + i * 0.15),
            cc.ScaleTo:create(0.2, 1.4),
            cc.DelayTime:create(0.05),
            cc.ScaleTo:create(0.05, 1)
            ))
    end
    uq.delayAction(node, 1.2 + self._num * 0.15, function ()
        node:removeFromParent()
    end)
end

function GeneralsUpAction:onExit()
    services:removeEventListenersByTag(self._eventUp)
    GeneralsUpAction.super:onExit()
end

return GeneralsUpAction