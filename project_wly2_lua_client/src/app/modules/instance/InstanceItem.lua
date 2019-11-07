local InstanceItem = class("InstanceItem", require('app.base.ChildViewBase'))

InstanceItem.RESOURCE_FILENAME = "instance/NPCNode.csb"
InstanceItem.RESOURCE_BINDING = {
    ["node_star"]    = {["varname"] = "_nodeStar"},
    ["node_solider"] = {["varname"] = "_nodeSoldier"},
    ["panel_touch"]  = {["varname"] = "_panelTouch",["events"] = {{["event"] = "touch",["method"] = "onHead",["sound_id"] = 0}}},
    ["image_head"]   = {["varname"] = "_imageHead",["events"] = {{["event"] = "touch",["method"] = "onHead",["sound_id"] = 0}}},
    ["image_bg"]     = {["varname"] = "_imgBg",["events"] = {{["event"] = "touch",["method"] = "onHead",["sound_id"] = 0}}},
    ["text_name"]    = {["varname"] = "_txtName"},
    ["image_strong"] = {["varname"] = "_imgStrong"},
    ["node_solider"] = {["varname"] = "_nodeSoldier"},
    ["node_title"]   = {["varname"] = "_nodeTitle"},
}

function InstanceItem:onCreate()
    InstanceItem.super.onCreate(self)
    self._initPage = false
    self._soldiers = {}
    self._delayAction = nil
end

function InstanceItem:setData(data, instance_id)
    self._data = data
    self._instanceId = instance_id
end

function InstanceItem:initPage()
    if self._initPage then
        return
    end
    self._initPage = true
    self._imageHead:setVisible(false)
    self._imgStrong:setVisible(false)
    if self._data.showType == 1 then
        self:addFormation(self._data.troopShow)
    elseif self._data.showType == 2 then
        self._imageHead:setVisible(true)
        local soldier_id = tonumber(self._data.model) or 94
        self:addSoldier(soldier_id, cc.p(0, 0))
    elseif self._data.showType == 3 then
        self._imageHead:setVisible(true)
        self._imgBuild = ccui.ImageView:create('img/building/instance/' .. self._data.model)
        self._nodeSoldier:addChild(self._imgBuild)
    elseif self._data.showType == 4 then
        self._imageHead:setVisible(true)
        self._imgStrong:setVisible(true)
        self:addFormation(self._data.troopShow)
        local soldier_id = tonumber(self._data.model) or 94
        self:addSoldier(soldier_id, cc.p(-100, -28))
    elseif self._data.showType == 5 then
        self._imageHead:setVisible(false)
        self._imgStrong:setVisible(false)
        self:addFormation2(self._data.troopShow)
        local soldier_id = tonumber(self._data.model) or 36
        self:addSoldier(soldier_id, cc.p(-70, 10))
    elseif self._data.showType == 6 then
        self._imageHead:setVisible(true)
        self._imgStrong:setVisible(true)
        self:addFormation2(self._data.troopShow)
        local soldier_id = tonumber(self._data.model) or 36
        self:addSoldier(soldier_id, cc.p(-70, 10))
    end
    self._imageHead:loadTexture('img/instance/' .. self._data.icon)
    self._txtName:setString(self._data.Name)

    local posx = {0, 0, 20, 0, -20, 0}
    local posy = {90, 60, 50, 90, -40, 100}
    self._nodeTitle:setPositionX(posx[self._data.showType])
    self._nodeTitle:setPositionY(posy[self._data.showType])

    local pos = {cc.p(0, 140), cc.p(0, 110), cc.p(20, 100), cc.p(0, 140), cc.p(-20, 110), cc.p(0, 150)}
    self._nodeStar:setPosition(pos[self._data.showType])
end

function InstanceItem:addFormation(soldier_id)
    for i = 1, 9 do
        local x = -50 + (i - 1) % 3 * 40 - math.floor((i - 1) / 3) * 2
        local y = 50 - math.floor((i - 1) / 3) * 20
        self:addSoldier(soldier_id, cc.p(x, y))
    end
end

function InstanceItem:addFormation2(soldier_id)
    for i = 1, 6 do
        local x = -50 + (i - 1) % 2 * 40 - math.floor((i - 1) / 2) * -20
        local y = 50 + (i - 1) % 2 * 10 - math.floor((i - 1) / 2) * 20
        self:addSoldier(soldier_id, cc.p(x, y))
    end
end

function InstanceItem:addSoldier(soldier_id, pos)
    local troop_data = StaticData['soldier'][soldier_id]
    local node_solider = uq.createPanelOnly('instance.InstanceSoldier')
    self._nodeSoldier:addChild(node_solider, -1)
    node_solider:setPosition(pos)
    node_solider:setData(self._instanceId, self._data, troop_data.action, true)
    node_solider:setSoldierScale(0.7)

    table.insert(self._soldiers, node_solider)
end

function InstanceItem:playDelayAction()
    self._actionSoliderNum = 0
    local function actionEnd()
        self._actionSoliderNum = self._actionSoliderNum + 1
        if self._actionSoliderNum == #self._soldiers then
            self:playDelayAction()
            self._actionSoliderNum = 0
        end
    end

    for k, item in ipairs(self._soldiers) do
        item:playIdle()
    end

    local time = math.random(2, 5)
    local delay = cc.DelayTime:create(time)
    local call_func = cc.CallFunc:create(function()
        for k, item in ipairs(self._soldiers) do
            item:playAttack(actionEnd)
        end
    end)
    self._delayAction = self:runAction(cc.Sequence:create(delay, call_func))
end

function InstanceItem:stopDelayAction()
    if self._delayAction then
        self:stopAction(self._delayAction)
        self._delayAction = nil
    end
end

function InstanceItem:refresh()
    local npc_info = uq.cache.instance:getNPC(self._instanceId, self._data.ident)
    local star = 0
    if npc_info.star and npc_info.star > 0 then
        star = npc_info.star
    end

    self:initPage()
    self:stopDelayAction()
    if star > 0 then
        for k, item in ipairs(self._soldiers) do
            item:playStand()
        end
    else
        self:playDelayAction()
    end

    for i = 1, 3 do
        self._nodeStar:getChildByName('star_' .. i):setVisible(i <= star)
    end
    self._nodeStar:setVisible(star > 0)

    if not self._effect then
        self._effect = uq.createPanelOnly('instance.AnimationKnife')
        self:getParent():addChild(self._effect)
        local effect_posx = {0, 0, 10, 0, -20, -20}
        local effect_posy = {145, 120, 110, 146, 120, 160}
        local x, y = self:getPosition()
        self._effect:setLocalZOrder(display.height)
        self._effect:setPosition(cc.p(x + effect_posx[self._data.showType], y + effect_posy[self._data.showType]))
    end
    self:setEffect()
end

function InstanceItem:setEffect()
    self._effect:setVisible(false)

    local npc_info = uq.cache.instance:getNPC(self._instanceId, self._data.ident)

    if npc_info.star and npc_info.star > 0 then
        return
    end

    local pre_id = self._data.premiseObjectId
    if pre_id > 0 then
        local pre_data = uq.cache.instance:getNPC(self._instanceId, pre_id)
        if not pre_data.star or pre_data.star <= 0 then
            return
        end
    else
        if npc_info.star and npc_info.star > 0 then
            return
        end
    end

    self._effect:setVisible(true)
end

function InstanceItem:onHead(event)
    if event.name == "ended" then
        local npc_info = uq.cache.instance:getNPC(self._instanceId, self._data.ident)

        local pre_id = self._data.premiseObjectId
        if pre_id > 0 then
            local pre_data = uq.cache.instance:getNPC(self._instanceId, pre_id)
            if not pre_data.star or pre_data.star <= 0 then
                uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
                uq.fadeInfo(StaticData['local_text']['instance.pass.pre.first'])
                return
            end
        end
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
        uq.ModuleManager:getInstance():show(uq.ModuleManager.NPC_INFO_MODULE, {instance_id = self._instanceId, npc_id = self._data.ident, troop_id = self._data.troops})
    end
end

function InstanceItem:isCurFightNpc()
    return self._effect:isVisible()
end

return InstanceItem