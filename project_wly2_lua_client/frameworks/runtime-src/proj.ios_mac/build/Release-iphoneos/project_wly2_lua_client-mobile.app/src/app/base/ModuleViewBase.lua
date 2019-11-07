
--[[
    author:zhongqilong
]]

local ModuleViewBase = class("ModuleViewBase", require('app.base.PopupBase'))

function ModuleViewBase:ctor(name, params)
    ModuleViewBase.super.ctor(self, name, params)

    -- check CSB resource file
    local res = rawget(self.class, "RESOURCE_FILENAME")
    if res then
        self:createResoueceNode(res)
    end

    local binding = rawget(self.class, "RESOURCE_BINDING")
    if res and binding then
        self:createResoueceBinding(binding)
    end

    if self.onCreate then self:onCreate() end
end

function ModuleViewBase:onCreate()
    self._view:setAnchorPoint(0.5, 0.5)
end

function ModuleViewBase:createResoueceNode(resourceFilename)
    if self._view then
        self._view:removeSelf()
        self._view = nil
    end
    self._view = cc.CSLoader:createNode(resourceFilename)
    self._view.class = self
    assert(self._view, string.format("ModuleViewBase:createResoueceNode() - load resouce node from file \"%s\" failed", resourceFilename))
end

function ModuleViewBase:createResoueceBinding(binding)
    assert(self._view, "ModuleViewBase:createResoueceBinding() - not load resource node")
    for nodeName, nodeBinding in pairs(binding) do
        local node = self:seekChildren(self._view, nodeName)
        if node then
            if nodeBinding.varname then
                self[nodeBinding.varname] = node
            end
            for _, event in ipairs(nodeBinding.events or {}) do
                if event.event == "touch" then
                    node:onTouch(handler(self, self[event.method]))
                end
            end
        else
            uq.log('seek child error', nodeName)
        end
    end
end

function ModuleViewBase:seekChildren(root, childName)
    if not root then return end

    if root:getName() == childName then
        return root
    end

    local arrayNode = root:getChildren()
    for _,child in ipairs(arrayNode) do
        local node = self:seekChildren(child, childName)
        if node then
            return node
        end
    end

    return
end

function ModuleViewBase:setCenter()
    self:centerView(self._view)
end

return ModuleViewBase
