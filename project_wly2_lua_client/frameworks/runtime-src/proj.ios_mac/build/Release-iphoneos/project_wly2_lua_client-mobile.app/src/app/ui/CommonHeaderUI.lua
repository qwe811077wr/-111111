local CommonHeaderUI = class('CommonHeaderUI', require('app.base.ChildViewBase'))

CommonHeaderUI.RESOURCE_FILENAME = "common/CommonHeaderView.csb"
CommonHeaderUI.RESOURCE_BINDING = {
    ["back_btn"]       = {["varname"] = "_btnClose"},
    ["node_top_left"]  = {["varname"] = "_nodeTopLeft"},
    ["node_top_right"] = {["varname"] = "_nodeTopRight"},
    ["Button_2"]       = {["varname"] = "_btnRule"},
    ["name"]           = {["varname"] = "_nameLabel"},
    ["image_bg"]       = {["varname"] = "_imgBg"},
}
CommonHeaderUI.CLEAR_RULE_ID = -1

function CommonHeaderUI:onCreate()
    CommonHeaderUI.super.onCreate(self)

    self._resItems = {}
    self:setPosition(cc.p(-display.width / 2, CC_DESIGN_RESOLUTION.height / 2))
    self:setCloseClick(function ()
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
        uq.ModuleManager:getInstance():dispose()
        services:dispatchEvent({name = services.EVENT_NAMES.ON_SHOW_FUNCTION_OPEN})
    end)
    uq:addEffectByNode(self._btnClose, 900003, -1, true, cc.p(30, 30))

    self._nodeTopLeft:setPosition(cc.p(0, 0))
    self._nodeTopRight:setPosition(cc.p(display.width, 0))
    self._ruleId = CommonHeaderUI.CLEAR_RULE_ID
    self._nameLabel:setString("")
    self._btnRule:addClickEventListener(handler(self, self.openModuleRule))
    self._btnRule:setVisible(false)
    self._imgBg:setContentSize(cc.size(display.width, 66))
    self:runActionTop()
end

function CommonHeaderUI:setCloseClick(func)
    self._btnClose:addClickEventListener(function()
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
        if func then
            func()
        end
    end)
end

function CommonHeaderUI:setBgVisible(visible)
    self._imgBg:setVisible(visible)
end

function CommonHeaderUI:setRuleId(rule_id)
    if rule_id and rule_id > CommonHeaderUI.CLEAR_RULE_ID then
        self._ruleId = rule_id
        self._btnRule:setVisible(table.keyof(uq.config.constant.MODULE_RULE_ID, rule_id) ~= false)
    else
        self._ruleId = CommonHeaderUI.CLEAR_RULE_ID
        self._btnRule:setVisible(false)
    end
end

function CommonHeaderUI:openModuleRule()
    if self._ruleId <= CommonHeaderUI.CLEAR_RULE_ID then
        return
    end
    local info = StaticData['rule'][self._ruleId]
    if not info then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ANCIENT_CITY_RULE, {info = info})
end

function CommonHeaderUI:getBackBtn()
    return self._btnClose
end

function CommonHeaderUI:onClose(event)
    if event.name == "ended" then
        uq.ModuleManager:getInstance():dispose()
    end
end

function CommonHeaderUI:getNode()
    return self
end

function CommonHeaderUI:runActionTop()
    self:stopAllActions()
    self:setPositionY(CC_DESIGN_RESOLUTION.height / 2 + 50)
    self:runAction(cc.MoveTo:create(0.2, cc.p(-display.width / 2, CC_DESIGN_RESOLUTION.height / 2)))
end

function CommonHeaderUI:endActionTop()
    self:stopAllActions()
    self:setPosition(cc.p(-display.width / 2, CC_DESIGN_RESOLUTION.height / 2))
end

function CommonHeaderUI:addResItem(item)
    local pos_x = 0
    table.insert(self._resItems, item)
    for _, v in pairs(self._resItems) do
        pos_x = pos_x - v:getInner()
    end

    for _, v in pairs(self._resItems) do
        v:getNode():setPosition(cc.p(pos_x, - 40))
        pos_x = pos_x + v:getInner()
    end
    self._nodeTopRight:addChild(item:getNode())
 end

function CommonHeaderUI:removeAllItems()
    self._nodeTopRight:removeAllChildren()
    self._resItems = {}
end

function CommonHeaderUI:showReturn(b)
    self._btnClose:setVisible(b)
end

function CommonHeaderUI:setTitle(id)
    local info = StaticData['module'][id]
    if info then
        self._nameLabel:setString(info.name)
    end
end

function CommonHeaderUI:setVisible(v)
    self:setVisible(v)
end

function CommonHeaderUI:onExit()
    for _, v in pairs(self._resItems) do
        v:dispose()
    end

    CommonHeaderUI.super:onExit()
end

function CommonHeaderUI:dispose()
end

return CommonHeaderUI