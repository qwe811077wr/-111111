local ToastItemInfo = class("ToastItemInfo", require("app.base.ModuleBase"))

function ToastItemInfo:ctor(name, args)
    ToastItemInfo.super.ctor(self, name, args)
    self._args = args or {}
    self._allToast = {}
end

function ToastItemInfo:init()
    self:setView(cc.Node:create())
    self:_add(self._args)
    self:setLocalZOrder(uq.ModuleManager.SPECIAL_ZORDER.TIP_ZORDER)
    self:setBaseBgVisible(false)
end

function ToastItemInfo:update(params)
    self:_add(params)
end

function ToastItemInfo:_add(params)
    local pop_node = cc.CSLoader:createNode('common/ToastItemInfo.csb')
    local zorder = #self._allToast
    self:getResourceNode():addChild(pop_node, zorder)
    if zorder >= 5 then
        table.remove(self._allToast, 1)
    end
    table.insert(self._allToast, pop_node)

    local xml_data = StaticData.getCostInfo(self._args.item_info.type, self._args.item_info.paraml)
    pop_node:getChildByName('Sprite_3'):setTexture('img/common/item/' .. xml_data.icon)

    local bg_img = StaticData['types']['ItemQuality'][1]['Type'][tonumber(xml_data.qualityType)].qualityIcon
    pop_node:getChildByName('s07_00000_1'):setTexture("img/common/ui/" .. bg_img)
    pop_node:getChildByName('Text_1'):setString(string.format('%s x%d', xml_data.name, self._args.item_info.num))

    pop_node:setPosition(cc.p(params.x or display.cx, params.y or display.cy))

    local action1 = cc.Sequence:create(cc.DelayTime:create(0.5), cc.MoveBy:create(0.5, cc.p(0, 80)))
    local action2 = cc.Sequence:create(cc.DelayTime:create(0.5), cc.FadeOut:create(0.5), cc.CallFunc:create(function(sender)
        pop_node:removeSelf()
        table.remove(self._allToast, 1)
        if #self._allToast <= 0 then
            uq.ModuleManager:getInstance():dispose(self:name())
        end
    end))
    pop_node:runAction(cc.Spawn:create(action1, action2))
end

function ToastItemInfo:dispose()
    self._allToast = nil
    self._args = nil
    ToastItemInfo.super.dispose(self)
end

return ToastItemInfo