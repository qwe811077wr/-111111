local MainCityCurrency = class("MainCityCurrency", require('app.base.ChildViewBase'))

MainCityCurrency.RESOURCE_FILENAME = "main_city/MainCityCurrency.csb"
MainCityCurrency.RESOURCE_BINDING = {
    ["icon"]    = {["varname"]="_spriteIcon"},
    ["num"]     = {["varname"]="_txtNum"},
    ["num_txt"] = {["varname"]="_txtNumAdd"},
    ["add_img"] = {["varname"]="_imgAdd"},
    ["num_add"] = {["varname"]="_addLabel"},
    ["Image_1"] = {["varname"]="_imgLine"},
    ["Panel_1"] = {["varname"]="_panelTouch",["events"] = {{["event"] = "touch",["method"] = "onPanelTouch",["sound_id"] = 0}}},
}

function MainCityCurrency:onCreate()
    MainCityCurrency.super.onCreate(self)
    self._addLabel:setVisible(false)
end

function MainCityCurrency:setData(xml_data)
    self._eventName = services.EVENT_NAMES.ON_CONSUME_RES_CHANGE .. xml_data.type
    self._eventTag = self._eventName .. tostring(self)
    self._xmlData = xml_data

    services:removeEventListenersByTag(self._eventTag)
    services:addEventListener(self._eventName, handler(self, self.updateValueEvent), self._eventTag)

    self._eventActionName = services.EVENT_NAMES.ON_RESOURCE_ACTION .. xml_data.type
    self._eventActionTag = self._eventActionName .. tostring(self)

    self._isYieldRes = self:isYieldRes(xml_data.type)
    if not self._isYieldRes then
        self._txtNum:setVisible(false)
        self._txtNum = self._txtNumAdd
    end
    self._txtNum:setScale(1.0)
    self._addLabel:setVisible(false)
    services:removeEventListenersByTag(self._eventActionTag)
    services:addEventListener(self._eventActionName, handler(self, self.updateActionEvent), self._eventActionTag)
    self._imgArray = {}
    self._spriteIcon:setTexture('img/common/ui/' .. xml_data.icon)
    self._imgAdd:setVisible(xml_data.type == uq.config.constant.COST_RES_TYPE.GOLDEN)
    self._actionNum = 0
    self:updateValue()
end

function MainCityCurrency:setShowLine(is_bool)
    self._imgLine:setVisible(is_bool)
end

function MainCityCurrency:isYieldRes(res_type)
    return res_type == uq.config.constant.COST_RES_TYPE.MONEY or res_type == uq.config.constant.COST_RES_TYPE.IRON_MINE or
        res_type == uq.config.constant.COST_RES_TYPE.FOOD or res_type == uq.config.constant.COST_RES_TYPE.REDIF
end

function MainCityCurrency:updateActionEvent(msg)
    self._txtNum:stopAllActions()
    if msg.data.is_begain then
        self._txtNum:runAction(cc.ScaleTo:create(0.2, 1.2))
        self._addLabel:setVisible(false)
    else
        self._addLabel:setString("+" .. msg.data.total_res)
        self._addLabel:setVisible(true)
        self._addLabel:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function()
            self._addLabel:setVisible(false)
            self._txtNum:runAction(cc.ScaleTo:create(0.2, 1.0))
        end)))
    end
end

function MainCityCurrency:updateValue(num)
    local num = num or uq.cache.role:getResNum(self._xmlData.type)
    local str = uq.formatResource(num)
    if self._isYieldRes then
        local max_num, add_num = uq.cache.decree:getResMaxAddProduce(tonumber(self._xmlData.castleType))
        self._txtNumAdd:setString(self._xmlData.name .. "+" .. uq.formatResource(add_num))
    else
        str = "   " .. str
    end
    self._txtNum:setString(str)
end

function MainCityCurrency:updateValueEvent(evt)
    self:updateValue(evt.data.new_value)
end

function MainCityCurrency:getIconWorldPos()
    return self._spriteIcon:getParent():convertToWorldSpace(cc.p(self._spriteIcon:getPosition()))
end

function MainCityCurrency:getDataType()
    return self._xmlData.type
end

function MainCityCurrency:onExit()
    services:removeEventListenersByTag(self._eventActionTag)
    services:removeEventListenersByTag(self._eventTag)
    MainCityCurrency.super.onExit(self)
end

function MainCityCurrency:onPanelTouch(event)
    if event.name == "ended" then
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
        if self._xmlData.type == uq.config.constant.COST_RES_TYPE.MILITORY_ORDER then
            uq.jumpToModule(uq.config.constant.MODULE_ID.BUY_MILITORY_ORDER)
        else
            uq.jumpToModule(uq.config.constant.MODULE_ID.GET_RESOURCE, {type = self._xmlData.type})
        end
    end
end

function MainCityCurrency:showGoldLayer()
    self._spriteIcon:setScale(1)
    self._txtNum:setScale(1.125)
end

return MainCityCurrency