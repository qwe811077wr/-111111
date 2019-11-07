local EmbattleRoleCard = class("EmbattleRoleCard", require('app.base.ChildViewBase'))

EmbattleRoleCard.RESOURCE_FILENAME = "embattle/EmbattleHeadItem.csb"
EmbattleRoleCard.RESOURCE_BINDING = {
    ["Panel_3"]                         ={["varname"]="_panelItem"},
    ["Image_17"]                        ={["varname"]="_imgCouldUp"},
    ["Image_16"]                        ={["varname"]="_imgNotFit"},
    ["Button_1"]                        ={["varname"]="_btnCheck"},
    ["Image_1"]                         ={["varname"]="_imgSelected"},
    ["Panel_3_0"]                       ={["varname"]="_panelClick",["events"]={{["event"]="touch",["method"]="onBgTouch"}}},
    ["Button_1"]                        ={["varname"]="_btnChange",["events"] = {{["event"] = "touch",["method"] = "onBtnRebuild"}}},
}

EmbattleRoleCard._MOVE_STATE = {
    MOVE_STATE_NONE = 0,
    MOVE_STATE_TABLE = 1,
    MOVE_STATE_SELF = 2,
}

function EmbattleRoleCard:onCreate()
    EmbattleRoleCard.super.onCreate(self)
    self._roleData = nil
    self._roleType = uq.cache.formation.ROLE.ROLE_GENERAL
    self._index = -1
    self._callback = nil
    self._fromID = 0
    self._soldierArray = {}
    self._panelClick:setTouchEnabled(true)
    self._panelClick:setSwallowTouches(false)

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(handler(self, self._onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self._onTouchMove), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, self._onTouchEnd), cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(handler(self, self._onTouchEnd), cc.Handler.EVENT_TOUCH_CANCELLED)
    local eventDispatcher = self._panelItem:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self._panelItem)
end

function EmbattleRoleCard:_onTouchBegin(touches, event)
    self._touchPos = touches:getLocation()
    local locationCon = self:convertToNodeSpace(self._touchPos)
    local nodePos = cc.p(locationCon.x, locationCon.y)
    local rect = cc.rect(-60, -81, 121, 163)
    if cc.rectContainsPoint(rect, nodePos) and self._index > 0 then
        local view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.EMBATTLE_MODULE)
        if view then
            view:_onTouchBegin(touches, event)
            view:setMoveNodeData(self._roleData, self._roleType)
        end
        local view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.ARRANGED_BEFORE_WAR)
        if view then
            view:_onTouchBegin(touches, event)
            view:setMoveNodeData(self._roleData, self._roleType)
        end
        self:setScale(0.85)
        self._imgSelected:setVisible(true)
        self._scaleState = true
        self._moveState = self._MOVE_STATE.MOVE_STATE_NONE
        return true
    else
        return false
    end
end

function EmbattleRoleCard:checkSoldierArray(type_array)
    self._imgCouldUp:setVisible(self._roleData.up_state)
    self._imgNotFit:setVisible(not self._roleData.up_state)
    return self._roleData.up_state
end

function EmbattleRoleCard:_onTouchMove(touches, event)
    local pos = touches:getLocation()
    if self._moveState == self._MOVE_STATE.MOVE_STATE_TABLE then
        if self._scaleState then
            local locationCon = self:convertToNodeSpace(pos)
            local nodePos = cc.p(locationCon.x, locationCon.y)
            local rect = cc.rect(-60, -81, 121, 163)
            if not cc.rectContainsPoint(rect, nodePos) and self._index > 0  then
                self:setScale(1)
                self._imgSelected:setVisible(false)
                self._scaleState = false
            end
        end
        return
    elseif self._moveState == self._MOVE_STATE.MOVE_STATE_NONE then
        local delta_x = math.abs(pos.x - self._touchPos.x)
        local delta_y = math.abs(pos.y - self._touchPos.y)
        if delta_y > 50 then
            self._moveState = self._MOVE_STATE.MOVE_STATE_TABLE
            services:dispatchEvent({name = services.EVENT_NAMES.ON_SET_EMBATTLE_TOUCH_STATE})
            return
        end
        if delta_x < 50 then
            return
        end
    end
    self._moveState = self._MOVE_STATE.MOVE_STATE_SELF
    services:dispatchEvent({name = services.EVENT_NAMES.ON_SET_EMBATTLE_TOUCH_STATE})
    local view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.EMBATTLE_MODULE)
    if view then
        view:_onTouchMove(touches, event)
    end
    local view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.ARRANGED_BEFORE_WAR)
    if view then
        view:_onTouchMove(touches, event)
    end
end

function EmbattleRoleCard:_onTouchEnd(touches, event)
    self:setScale(1)
    self._imgSelected:setVisible(false)
    services:dispatchEvent({name = services.EVENT_NAMES.ON_SET_EMBATTLE_TOUCH_STATE})
    if self._moveState ~= self._MOVE_STATE.MOVE_STATE_SELF then
        return
    end
    local view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.EMBATTLE_MODULE)
    if view then
        view:_onTouchEnd(touches, event)
    end
    local view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.ARRANGED_BEFORE_WAR)
    if view then
        view:_onTouchEnd(touches, event)
    end
end

function EmbattleRoleCard:onBtnRebuild(event)
    if event.name ~= "ended" then
        return
    end
    local soldier_id = self._roleData.soldierId1 == self._roleData.battle_soldier_id and self._roleData.soldierId2 or self._roleData.soldierId1
    network:sendPacket(Protocol.C_2_S_GENARAL_SET_BATTLE_SOLDIER, {general_id = self._roleData.id, soldier_id = soldier_id})
end

function EmbattleRoleCard:setCallback(callback)
    self._callback = callback
end

function EmbattleRoleCard:setIndex(index)
    self._index = index
end

function EmbattleRoleCard:getIndex()
    return self._index
end

function EmbattleRoleCard:onExit()
    EmbattleRoleCard.super:onExit()
end

function EmbattleRoleCard:setData(index, role_type, data, is_drill) --index 武将编号
    self._roleType = role_type
    self._index = index
    local role_data = data and data or uq.cache.formation:getRoleDataNotInFormation(index, role_type)
    self:setRoleData(role_data, is_drill)
end

function EmbattleRoleCard:setRoleType(role_type)
    self._roleType = role_type
end

function EmbattleRoleCard:getRoleType()
    return self._roleType
end

function EmbattleRoleCard:setRoleData(role_data, is_drill)
    self._roleData = role_data
    local item = self._panelItem:getChildByName("item")
    if not item then
        item = uq.createPanelOnly("general_collect.GeneralCollectCardItem")
        self._panelItem:addChild(item)
        local size = item:getChildByName("Layer"):getContentSize()
        item:setName("item")
        item:setPosition(cc.p(size.width / 2 * 0.56 - 5, size.height / 2 * 0.56 - 5))
        item:setScale(0.56)
        item:setArmyVisible(true)
    end
    item:setData(role_data)
    self._imgCouldUp:setVisible(is_drill and role_data.up_state)
    self._imgNotFit:setVisible(is_drill and not role_data.up_state)
end

function EmbattleRoleCard:getBgSize()
    return self._panelClick:getContentSize()
end

function EmbattleRoleCard:setSelected(flag)
end

function EmbattleRoleCard:onBgTouch(event, touch)
    if event.name == "ended" then
        if self._callback then
            self._callback(self._index)
        end
    end
end

function EmbattleRoleCard:getGeneralID()
    return self._roleData and self._roleData.id or 0
end

function EmbattleRoleCard:getRoleData()
    return self._roleData
end

function EmbattleRoleCard:setFromID(fromID)
    self._fromID = fromID
end

function EmbattleRoleCard:getFromID()
    return self._fromID
end

return EmbattleRoleCard