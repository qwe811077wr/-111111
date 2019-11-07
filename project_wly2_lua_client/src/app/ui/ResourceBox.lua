local ResourceBox = class('ResourceBox', require('app.base.ChildViewBase'))

ResourceBox.RESOURCE_FILENAME = "common/ResourceBox.csb"
ResourceBox.RESOURCE_BINDING = {
    ["icon"]      = {["varname"] = "_spriteIcon"},
    ["value_txt"] = {["varname"] = "_txtValue"},
    ["add_btn"]   = {["varname"] = "_btnAdd"},
    ["container"] = {["varname"] = "_layoutContainer"},
}

function ResourceBox:setRes(icon, event_name, init_value, format_func, add_cb, id, mode)
    self._gameMode = mode
    self._spriteIcon:loadTexture(icon, ccui.TextureResType.localType)
    self._materialId = id or 0
    if format_func then
        self._formatFunc = format_func
        self._txtValue:setString(format_func(init_value or 0))
    else
        self._txtValue:setString(init_value or '0')
    end
    if add_cb then
        self._btnAdd:setVisible(true)
        self._btnAdd:addClickEventListener(function(sender)
            uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
            add_cb(sender)
        end)

        local size = self:getContentSize()
        size.width = size.width + 10
        self:setContentSize(size)
    end
    if event_name then
        self._eventTag = event_name .. tostring(self)
        services:addEventListener(event_name, handler(self, self._updateValue), self._eventTag)
    end
end

function ResourceBox:getInner()
    return self._layoutContainer:getContentSize().width + 20
end

function ResourceBox:onExit()
    ResourceBox.super:onExit()
    if self._eventTag then
        services:removeEventListenersByTag(self._eventTag)
        self._eventTag = nil
    end
end

function ResourceBox:getNode()
    return self
end

function ResourceBox:_updateValue(evt)
    local val = evt.data.new_value
    if self._formatFunc then
        val = self._formatFunc(val)
    end
    if evt.data.id ~= nil then
        if evt.data.id == self._materialId and self._txtValue then
            self._txtValue:setString(tostring(val))
        end
    else
        if self._txtValue then
            self._txtValue:setString(tostring(val))
        end
    end
end

function ResourceBox:dispose()
end

function ResourceBox.createRes(type, add_cb, id, mode)
    local cb = nil
    local default_cb = {}
    local val = 0
    if mode == uq.config.constant.GAME_MODE.INSTANCE_WAR then
        val = uq.cache.instance_war:getRes(type, id)
    else
        default_cb = {
            [uq.config.constant.COST_RES_TYPE.MONEY] = function()
                uq.runCmd('show_add_money')
            end,
            [uq.config.constant.COST_RES_TYPE.GOLDEN] = function()
                uq.runCmd('show_add_golden')
            end,
            [uq.config.constant.COST_RES_TYPE.MATERIAL] =
            {
                [uq.config.constant.MATERIAL_TYPE.EQUIP_VOURCHER] = function()
                    uq.runCmd('enter_buy_vourchers')
                end,
                [uq.config.constant.MATERIAL_TYPE.GENENRAL_VOURCHER] = function()
                    uq.runCmd('enter_buy_vourchers_general')
                end
            }
        }
        val = uq.cache.role:getResNum(type, id)
    end

    if add_cb then
        cb = id == nil and default_cb[type] or (default_cb[type] and default_cb[type][id] or nil)
    end
    local info = StaticData.getCostInfo(type, id)
    local miniIcon = info and info.miniIcon or "03_0002.png"
    local panel = ResourceBox:create()

    if mode == uq.config.constant.GAME_MODE.INSTANCE_WAR then
        if type == uq.config.constant.COST_RES_TYPE.GOLDEN then
            panel:setRes('img/common/ui/' .. miniIcon, services.EVENT_NAMES.ON_INSTANCE_WAR_RES_CHANGE .. type, val, nil, cb, id, mode)
        else
            panel:setRes('img/common/ui/' .. miniIcon, services.EVENT_NAMES.ON_INSTANCE_WAR_RES_CHANGE .. type, val, uq.formatResource, cb, id, mode)
        end
    else
        if type == uq.config.constant.COST_RES_TYPE.GOLDEN then
            panel:setRes('img/common/ui/' .. miniIcon, services.EVENT_NAMES.ON_CONSUME_RES_CHANGE .. type, val, nil, cb, id, mode)
        else
            panel:setRes('img/common/ui/' .. miniIcon, services.EVENT_NAMES.ON_CONSUME_RES_CHANGE .. type, val, uq.formatResource, cb, id, mode)
        end
    end

    return panel
end

return ResourceBox