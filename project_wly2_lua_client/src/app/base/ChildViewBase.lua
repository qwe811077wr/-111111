local ChildViewBase = class("ChildViewBase", function()
    return cc.Node:create()
end)

function ChildViewBase:ctor()
    self:enableNodeEvents()

    self._view = nil
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

function ChildViewBase:setOpacity(opacity)
    if self._view then
        self._view:setOpacity(opacity)
    end
end

function ChildViewBase:parseView(v)
    local view = v or self
    if not view then
        return
    end
    self:_parseView(view)
end

function ChildViewBase:_parseView(v)
    local children = v:getChildren()
    for k,child in ipairs(children) do
        local text = nil
        local method = nil
        if child.getString then
            text = child:getString()
            method = child.setString
        end
        if child.getTitleText then
            text = child:getTitleText()
            method = child.setTitleText
        end
        if text ~= nil and string.len(text) > 0 then
            if string.find(text, "#[%w%.%[%]\"_%*'\"]+#") then
                local key = string.split(text, "#")[2]
                method(child, StaticData['local_text'][key] or '')
            else
                self:_parseView(child)
            end
        else
            self:_parseView(child)
        end
    end
end

function ChildViewBase:onCreate()
end

function ChildViewBase:getResourceNode()
    return self._view
end

function ChildViewBase:getContentSize()
    return self._view:getContentSize()
end

function ChildViewBase:setContentSize(size)
    return self._view:setContentSize(size)
end

function ChildViewBase:createResoueceNode(fname)
    if self._view then
        self._view:removeSelf()
        self._view = nil
    end
    self._view = cc.CSLoader:createNode(fname)
    assert(self._view, string.format("ChildViewBase:createResoueceNode() - load resouce node from file \"%s\" failed", resourceFilename))
    self._view:setAnchorPoint(cc.p(0.5,0.5))
    self._view:setPosition(cc.p(0,0))
    self:addChild(self._view)
end

function ChildViewBase:createResoueceBinding(binding)
    assert(self._view, "ChildViewBase:createResoueceBinding() - not load resource node")
    for nodeName, nodeBinding in pairs(binding) do
        local node = self:getBindChildren(nodeName)
        if nodeBinding.varname then
            self[nodeBinding.varname] = node
        end
        for _, event in ipairs(nodeBinding.events or {}) do
            if event.event == "touch" then
                local wrapper = function (handler, sound_id)
                    return function(event)
                        if event.name == "ended" then
                            uq.playSoundByID(sound_id or uq.config.constant.COMMON_SOUND.BUTTON)
                        end
                        handler(event)
                    end
                end
                node:onTouch(wrapper(handler(self, self[event.method]), event.sound_id))
            end
        end
    end
end

function ChildViewBase:getBindChildren(path_name)
    local childs = string.split(path_name, '/')
    local parent_node = self._view
    local child_num = #childs
    local node_found = nil
    for i=1, child_num do
        if i == child_num then
            --最后一级节点
            node_found = self:seekChildren(parent_node, childs[i])
        else
            parent_node = self:seekChildren(parent_node, childs[i])
        end
    end
    if not node_found then
        uq.log('log ChildViewBase getChildren find error', path_name)
    end
    return node_found
end

function ChildViewBase:seekChildren(root, childName)
    if not root then return end

    if root:getName() == childName then
        return root
    end

    if root:getChildByName(childName) then
        return root:getChildByName(childName)
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

function ChildViewBase:refreshLayerFromTop()
end

function ChildViewBase:onExit()
    if self._in_action then
        self._view:stopAllActions()
    end
    self._view = nil
end

function ChildViewBase:onEnter()
end

return ChildViewBase
