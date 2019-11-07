local ArrangedItem = class("ArrangedItem", require('app.base.ChildViewBase'))

ArrangedItem.RESOURCE_FILENAME = "battle/ArrangeItem.csb"
ArrangedItem.RESOURCE_BINDING = {
    ["Sprite_3"]    ={["varname"]="_spriteBg2"},
    ["Sprite_2"]    ={["varname"]="_spiritBgNotOpen"},
    ["Panel_name"]  ={["varname"]="_spriteBg3"},
    ["Node_4"]      ={["varname"]="_nodeLock"},
    ["lock_label"]  ={["varname"]="_txtLocked"},
    ["panel_touch"] ={["varname"]="_btnBg",["events"]={{["event"]="touch",["method"]="onBg"}}},
    ["Text_2"]      ={["varname"]="_txtName"},
    ["Text_6"]      ={["varname"]="_txtSoldierName"},
    ["Sprite_1"]    ={["varname"]="_spriteNormal"},
    ["soldiers"]    ={["varname"]="_nodeSoldier"},
    ["Node_23"]     ={["varname"]="_nodeHead"},
    ["Text_1"]      ={["varname"]="_txtPrecent"},
    ["hp"]          ={["varname"]="_loadingBar"},
}

ArrangedItem.STATE = {
    NONE = 1,
    OPEN_SOLDIER = 2,
    NOT_OPEN = 3,
    OPEN_NOT_EQUIP = 4,
    OPEN_LOCK = 5,
}

function ArrangedItem:onCreate()
    ArrangedItem.super.onCreate(self)
    self:parseView()
    self._soldiers = {}
    self._openFromOther = false
    self._nodeSoldier:setVisible(false)
    self._soldierNum = {1, 2, 3, 4, 5, 6, 7, 8, 9}
    self._fillPos = {7, 5, 9, 2, 1, 4, 6, 3, 8}
    self._enterWar = false

    self:init()

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(handler(self, self._onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self._onTouchMove), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, self._onTouchEnd), cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(handler(self, self._onTouchEnd), cc.Handler.EVENT_TOUCH_CANCELLED)
    local eventDispatcher = self._btnBg:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self._btnBg)
    self._btnBg:setSwallowTouches(false)

    self._eventArmy = services.EVENT_NAMES.ON_ARMY_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_ARMY_REFRESH, handler(self, self.refreshSoldier), self._eventArmy)

    self._eventWarBefore = services.EVENT_NAMES.ON_BEFORE_WAR .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_BEFORE_WAR, handler(self, self.refreshWarBefore), self._eventWarBefore)

    self._eventWarEnter = services.EVENT_NAMES.ON_ENTER_WAR .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_ENTER_WAR, handler(self, self.refreshWarEnter), self._eventWarEnter)
end

function ArrangedItem:onExit()
    services:removeEventListenersByTag(self._eventArmy)
    services:removeEventListenersByTag(self._eventWarBefore)
    services:removeEventListenersByTag(self._eventWarEnter)
    ArrangedItem.super.onExit(self)
end

function ArrangedItem:setOpenFromOther(flag)
    self._openFromOther = flag
end

function ArrangedItem:setCanClick(state)
    self._noClick = not state
end

function ArrangedItem:switch(role_data, embattle_type)
    if uq.config.constant.TYPE_EMBATTLE.INSTANCE_EMBATTLE == embattle_type then
        self:sendUpAndDownGeneralProtocol(role_data.id)
    end
    self._roleDatas = role_data
    self:refreshPage()
end

function ArrangedItem:_onTouchBegin(touches, event)
    self._touchPos = touches:getLocation()
    local location_con = self:convertToNodeSpace(self._touchPos)
    local node_pos = cc.p(location_con.x, location_con.y)

    local rect = cc.rect(-80, -60, 200, 100)
    self._touchBeginState = true
    local view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.ARRANGED_BEFORE_WAR)
    if cc.rectContainsPoint(rect, node_pos) and not self._noClick then
        if not self:formationOpened() or not self._roleDatas then
            return false
        end
        if view then
            view:_onTouchBegin(touches, event)
            view:setMoveNodeData(self._roleDatas, uq.cache.formation.ROLE.ROLE_GENERAL, self._index)
        end
        return true
    else
        if view then
            view:closeEmbattleGeneralTip()
        end
        return false
    end
end

function ArrangedItem:_onTouchMove(touches, event)
    if self._touchBeginState then
        local pos = touches:getLocation()
        if math.sqrt(math.pow(pos.x - self._touchPos.x, 2) + math.pow(pos.y - self._touchPos.y, 2)) > 10 then
            self._touchBeginState = false
        end
        return
    end
    local view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.ARRANGED_BEFORE_WAR)
    if view then
        view:_onTouchMove(touches, event)
        view:setLeftListVisible(false)
    end
end

function ArrangedItem:_onTouchEnd(touches, event)
    self._touchBeginState = false
    local view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.ARRANGED_BEFORE_WAR)
    if view then
        view:_onTouchEnd(touches, event)
    end
end

function ArrangedItem:init()
    self._index = 0 --序号
    self._onIconTouchCallback = nil
    self:initData()
end

function ArrangedItem:initData()
    self._formationIndex = 0 --阵型id
    self._orderIndex = 0 --出手顺序
    self._roleDatas = nil
    self._formationData = nil
    self._formationStaticData = nil
    self._formationStaticLevel = 0
end

function ArrangedItem:setData(formation_index, general_id, injure_state)
    self._injureState = injure_state
    self:initData()
    self._formationIndex = formation_index
    self._formationStaticData = StaticData['formation'][formation_index]
    local content = self._formationStaticData.AtkOrder[1].AtkOrder
    local order = string.split(content, ',')
    for k, v in ipairs(order) do
        if self._index == tonumber(v) then
            self._orderIndex = k
            self._formationStaticLevel = self._formationStaticData.Location[self._orderIndex].level
            break
        end
    end
    self._formationData = uq.cache.formation:getFormationData(self._formationIndex)
    if general_id then
        self._roleDatas = uq.cache.generals:getGeneralDataByID(general_id)
    end
    self:refreshPage()
end

function ArrangedItem:refreshPage()
    if self:formationOpened() then
        if self._roleDatas then
            self:refreshState(self.STATE.OPEN_SOLDIER)
        elseif self._orderIndex > 0 then
            self:refreshState(self.STATE.OPEN_NOT_EQUIP)
        else
            self:refreshState(self.STATE.NOT_OPEN)
        end
    elseif self:formationCanOpen() then
        self:refreshState(self.STATE.OPEN_LOCK)
        self._nodeLock:getChildByName("lock_label"):setString(string.format(StaticData["local_text"]["label.formation.openLvLimit"], self._formationStaticLevel))
    else
        self:refreshState(self.STATE.NOT_OPEN)
    end
    if self._index <= 0 then
        self:refreshState(self.STATE.OPEN_SOLDIER)
    end
    self:loadSoldier()
end

function ArrangedItem:refreshState(state)
    self._spriteBg2:setVisible(state == self.STATE.OPEN_NOT_EQUIP)
    self._spriteNormal:setVisible(state == self.STATE.OPEN_SOLDIER)
    self._spriteBg3:setVisible(state == self.STATE.OPEN_SOLDIER)
    self._btnBg:setVisible(state == self.STATE.OPEN_SOLDIER)
    self._nodeLock:setVisible(state == self.STATE.OPEN_LOCK)
end

function ArrangedItem:formationCanOpen()
    return self._formationData and self._formationStaticLevel > self._formationData.lvl
end

function ArrangedItem:formationOpened()
    return self._formationData and self._formationStaticLevel <= self._formationData.lvl and self._orderIndex > 0
end

function ArrangedItem:setIndex(index)
    self._index = index
end

function ArrangedItem:getIndex()
    return self._index
end

function ArrangedItem:refreshWarBefore()
    self._enterWar = false
    self:refreshSoldier()
end


function ArrangedItem:refreshWarEnter()
    self._enterWar = true
end

function ArrangedItem:refreshSoldier()
    if self._roleDatas ~= nil and self._enterWar == false then
        local cur_soldier_num = self._injureState and self._roleDatas.current_soldiers or self._roleDatas.max_soldiers
        self._loadingBar:setPercent(cur_soldier_num / self._roleDatas.max_soldiers * 100)
        self._txtPrecent:setString(cur_soldier_num .. '/' .. self._roleDatas.max_soldiers)
    end
end

function ArrangedItem:loadSoldier()
    self._nodeSoldier:setVisible(self._roleDatas ~= nil)
    if self._roleDatas then
        self._txtName:setString(self._roleDatas.name)
        self:refreshSoldier()
        local general_config = StaticData['general'][self._roleDatas.rtemp_id]
        local image = ccui.ImageView:create('img/common/general_head/' .. general_config.icon)
        image:setScale(0.27)
        self._nodeHead:removeAllChildren()
        uq.cache.formation:clipHead(image, self._nodeHead, cc.p(0, -12))
        local soldier_config = StaticData['soldier'][self._roleDatas.battle_soldier_id]
        if soldier_config then
            local type_solider1 = StaticData['types'].Soldier[1].Type[soldier_config.type]
            self._txtSoldierName:setString(type_solider1.shortName)
            self:initSoldier(self._roleDatas.battle_soldier_id)
            self._txtSoldierName:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()
                self:addSoldier(self._roleDatas.battle_soldier_id)
            end)))
        end
    end
end

function ArrangedItem:initSoldier(id)
    local soldier_data = StaticData['soldier'][id]
    self._soldierNum = {1, 2, 3, 4, 5, 6, 7, 8, 9}
    if soldier_data.fillType == 2 then
        self._soldierNum = {4, 7, 6}
    elseif soldier_data.fillType == 3 then
        self._soldierNum = {6, 7, 8, 9}
    end
    self:formation()

    if next(self._soldiers) ~= nil then
        return
    end
    local soldier_data = StaticData['soldier'][self._roleDatas.battle_soldier_id]
    for i = 1, #self._soldierNum do
        local node = self._nodeSoldier:getChildByName(self._soldierNum[i]):getChildByName("img")
        node:loadTexture("img/soldier/" .. soldier_data.action .. "_" .. 1 .. ".png")
    end
end

function ArrangedItem:addSoldier(id)
    local xml_data = StaticData['formation_loc'].scale
    local cell_line = math.floor((self._index - 1) / 3) + 1
    if next(self._soldiers) ~= nil then
        for i = 1, 9 do
            local node_soldier = self._nodeSoldier:getChildByName(i)
            node_soldier:removeAllChildren()
        end
    end
    self._soldiers = {}
    for i = 1, #self._soldierNum do
        local node_pos = self._nodeSoldier:getChildByName(self._soldierNum[i])
        local horizon_num = math.floor((node_pos.pos_index - 1) / 3) + 1
        local line = horizon_num + (cell_line - 1) * 3
        line = 9 - line + 1
        local soldier = uq.createPanelOnly('battle.BattleSoldier')
        soldier:setData({soldier_id = self._roleDatas.battle_soldier_id}, 1, false, self._soldierNum[i], node_pos.pos_index)
        node_pos:removeAllChildren()
        node_pos:addChild(soldier)
        local scale = xml_data[line] and xml_data[line].scale or 1
        soldier:setScale(scale)
        soldier:setName('soldier')
        soldier:playIdle()
        table.insert(self._soldiers, soldier)
    end
end

function ArrangedItem:formation()
    local xml_data = StaticData['formation_loc'].scale
    local cell_line = math.floor((self._index - 1) / 3) + 1
    local soldier_data = StaticData['soldier'][self._roleDatas.battle_soldier_id]
    local offx = {0, 30, 60}
    self._spacex = 30

    for i = 1, 9 do
        local index = math.floor((i - 1) / 3) + 1
        local line = index + (cell_line - 1) * 3
        line = 9 - line + 1
        local off = offx[index]
        local x = (i - 1) % 3 * self._spacex + off
        local y = 0 - math.floor((i - 1) / 3) * 15 + (i - 1) % 3 * 15
        local node_pos = self._nodeSoldier:getChildByName(self._fillPos[i])
        node_pos:setPosition(cc.p(x, y))
        node_pos.pos_index = i
    end
end

function ArrangedItem:playAttack()
    for k, item in ipairs(self._soldiers) do
        item:playAttack(function()
            item:playIdle()
        end)
    end
end

function ArrangedItem:setSoilderData(data)
    if self:formationOpened() or self._index <= 0 then
        self._roleDatas = data
    end
    self:refreshPage()
end

function ArrangedItem:onBg(event)
    if not self._roleDatas or not self._onIconTouchCallback then
        return
    end
    local node_base = self:getChildByName("Node")
    local pos = self:convertToWorldSpace(cc.p(node_base:getPosition()))
    self._onIconTouchCallback({self._roleDatas}, self._index, event, cc.p(pos.x + 150, pos.y + 200))
end

--武将下阵
function ArrangedItem:downRole(embattle_type)
    if embattle_type == uq.config.constant.TYPE_EMBATTLE.INSTANCE_EMBATTLE then
        self:sendUpAndDownGeneralProtocol(0)
    end
    self._roleDatas = nil
    self:refreshPage()
end

function ArrangedItem:sendUpAndDownGeneralProtocol(general_id)
    local data = {
        formation_id = self._formationIndex,
        genaral_battle_id = general_id,
        formation_pos = self._index
    }
    if not self._openFromOther then
        network:sendPacket(Protocol.C_2_S_FORMATION_GENARAL_BATTLE, data)
    end
end

function ArrangedItem:getRoleData()
    return self._roleDatas
end

function ArrangedItem:getRoleID()
    return self._roleDatas and self._roleDatas.id or 0
end

function ArrangedItem:setIconTouchCallback(callback)
    self._onIconTouchCallback = callback
end

return ArrangedItem