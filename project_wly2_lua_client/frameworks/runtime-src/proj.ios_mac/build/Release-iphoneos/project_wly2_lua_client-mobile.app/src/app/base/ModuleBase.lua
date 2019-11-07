local ModuleBase = class("ModuleBase", require('app.base.ChildViewBase'))

ModuleBase.ACTION_TAG = 10003

function ModuleBase:ctor(name, params)
    assert(name and params, "ModuleBase ctor(): name or params be not nil!")
    ModuleBase.super.ctor(self, name)
    self._name = name
    self._params = params
    self._inAction = false
end

function ModuleBase:onCreate()
    ModuleBase.super.onCreate(self)

    self._baseBg = ccui.ImageView:create("img/common/ui/g01_000055.png")
    self:addChild(self._baseBg, uq.ModuleManager.SPECIAL_ZORDER.MODULE_BASE_BG)
    self._baseBg:setScale9Enabled(true)
    self._baseBg:setContentSize(cc.size(display.width + 10, display.height + 10))
    self._baseBg:setTouchEnabled(true)
    self._baseBg:setLocalZOrder(uq.ModuleManager.SPECIAL_ZORDER.MODULE_BASE_BG)
end

function ModuleBase:setBaseBgVisible(flag)
    self._baseBg:setVisible(flag)
end

function ModuleBase:setBaseBgClip()
    self._clipNode = cc.ClippingNode:create()
    local stencil_node = cc.DrawNode:create()
    stencil_node:drawSolidRect(cc.p(display.width / 2, CC_DESIGN_RESOLUTION.height / 2), cc.p(-display.width / 2, -CC_DESIGN_RESOLUTION.height / 2), display.COLOR_WHITE)
    self._clipNode:setStencil(stencil_node)

    self._baseBg:removeFromParent()
    self._clipNode:addChild(self._baseBg)
    self._clipNode:setInverted(true)
    self:addChild(self._clipNode, uq.ModuleManager.SPECIAL_ZORDER.MODULE_BASE_BG)
end

function ModuleBase:init()
end

function ModuleBase:update(params)
end

function ModuleBase:name()
    return self._name
end

function ModuleBase:setView(view)
    if self._view then
        self._view:removeSelf()
    end
    self._view = view
    self._view:setAnchorPoint(cc.p(0.5, 0.5))
    self._view:setPosition(cc.p(0, 0))
    self:addChild(view)
    self:centerView()
end

function ModuleBase:playEffect(action)
    if self._inAction then
        return
    end
    if not self._view then
        return
    end
    self._inAction = true
    local a = cc.Sequence:create(action, cc.CallFunc:create(handler(self, self._callFunc)), nil)
    self._view:runAction(a)
end

function ModuleBase:_callFunc()
    self._inAction = false
end

function ModuleBase:centerView()
    self:setPosition(cc.p(display.width / 2, display.height / 2))
end

function ModuleBase:enableViewEvents()
end

function ModuleBase:zOrder()
    if self._params and self._params.zOrder then
        return self._params.zOrder
    end
    return 0
end

function ModuleBase:disposeSelf()
    local panel = uq.ModuleManager:getInstance():getModule(self:name())
    if panel then
        uq.ModuleManager:getInstance():dispose(self:name())
    else
        self:removeFromParent()
    end
end

function ModuleBase:dispose()
    self:removeFromParent()
end

function ModuleBase:onCleanup()
    display.removeUnusedSpriteFrames()
end

function ModuleBase:adaptBgSize(node_bg)
    node_bg = node_bg or self:getBindChildren('img_bg_adapt')

    if not node_bg then
        return
    end
    node_bg:setAnchorPoint(cc.p(0.5, 0.5))

    local scale_x, scale_y = display.width / CC_DESIGN_RESOLUTION.width, display.height / CC_DESIGN_RESOLUTION.height
    if CC_DESIGN_RESOLUTION.autoscale == "FIXED_WIDTH" then
        -- node_bg:setScale(scale_y)
    else
        node_bg:setScale(scale_x)
    end
    local node_pos = node_bg:getParent():convertToNodeSpace(cc.p(display.width / 2, display.height / 2))
    node_bg:setPosition(node_pos)
end

function ModuleBase:adaptNode()
    local design_height_start = (display.height - CC_DESIGN_RESOLUTION.height) / 2
    local design_height_end = display.height / 2 + CC_DESIGN_RESOLUTION.height / 2
    local design_height_middle = display.height / 2

    local map_pos = {
        ['_nodeLeftMiddle'] = cc.p(0 + uq.getAdaptOffX(), design_height_middle),
        ['_nodeRightMiddle'] = cc.p(display.width - uq.getAdaptOffX(), design_height_middle),
        ['_nodeLeftTop'] = cc.p(0, design_height_end),
        ['_nodeRightTop'] = cc.p(display.width, design_height_end),
        ['_nodeLeftBottom'] = cc.p(0, design_height_start),
        ['_nodeRightBottom'] = cc.p(display.width, design_height_start),
        ['_nodeTopMiddle'] = cc.p(display.width / 2, design_height_end),
        ['_nodeBottomMiddle'] = cc.p(display.width / 2, design_height_start),
    }

    for node_name, pos in pairs(map_pos) do
        local node_item = self[node_name]
        if node_item then
            local node_pos = node_item:getParent():convertToNodeSpace(pos)
            node_item:setPosition(node_pos)
        end
    end
end

return ModuleBase