local EmbattleItem = class("EmbattleItem", require('app.base.ChildViewBase'))

EmbattleItem.RESOURCE_FILENAME = "embattle/EmbattleItem.csb"
EmbattleItem.RESOURCE_BINDING = {
    ["Sprite_4"]    ={["varname"]="_spriteBg1"},
    ["Sprite_3"]    ={["varname"]="_spriteBg2"},
    ["Panel_name"]  ={["varname"]="_spriteBg3"},
    ["Node_15"]     ={["varname"]="_nodeSoldier"},
    ["Node_4"]      ={["varname"]="_nodeCanUp"},
    ["Node_2"]      ={["varname"]="_nodeClosed"},
    ["Node_3"]      ={["varname"]="_nodeDown"},
    ["switch"]      ={["varname"]="_btnSwitch",["events"]={{["event"]="touch",["method"]="onSwitch"}}},
    ["Text_1"]      ={["varname"]="_txtLevel"},
    ["Node_17"]     ={["varname"]="_nodeBosomInfo"},
    ["Image_2"]     ={["varname"]="_bosomHead"},
    ["Image_3"]     ={["varname"]="_bosomHeadBg"},
    ["Button_2"]    ={["varname"]="_btnBg",["events"]={{["event"]="touch",["method"]="onBg"}}},
    ["Button_1"]    ={["varname"]="_btnDown",["events"]={{["event"]="touch",["method"]="onDown"}}},
    ["Text_2"]      ={["varname"]="_txtName"},
}

EmbattleItem.STATE = {
    NONE = 1,
    OPEN_SOLDIER = 2,
    NOT_OPEN = 3,
    OPEN_NOT_EQUIP = 4,
}

EmbattleItem.SOLDIER_SCALE = {
    0.46,
    0.48,
    0.50,
    0.52,
    0.55,
    0.58,
    0.60,
    0.64,
    0.68,
}

EmbattleItem.SOLDIER_POS = {
    {posx = -40, posy = 50, column_space = 50, row_space = 35, row_offset = 5},
}

EmbattleItem._normalImg = {
    "img/embattle/g03_0000866.png",
    "img/embattle/g03_0000868.png",
    "img/embattle/g03_0000870.png",
    "img/embattle/g03_0000872.png",
    "img/embattle/g03_0000874.png",
    "img/embattle/g03_0000876.png",
    "img/embattle/g03_0000878.png",
    "img/embattle/g03_0000880.png",
    "img/embattle/g03_0000882.png",
}

EmbattleItem._selectImg = {
    "img/embattle/g03_0000867.png",
    "img/embattle/g03_0000869.png",
    "img/embattle/g03_0000871.png",
    "img/embattle/g03_0000873.png",
    "img/embattle/g03_0000875.png",
    "img/embattle/g03_0000877.png",
    "img/embattle/g03_0000879.png",
    "img/embattle/g03_0000881.png",
    "img/embattle/g03_0000883.png",
}

function EmbattleItem:onCreate()
    EmbattleItem.super.onCreate(self)
    self:parseView()
    self._soldiers = {}
    self._openFromOther = false
    self._nodeSoldier:setVisible(false)
    self._nodeBosomInfo:setVisible(false)

    self:init()

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(handler(self, self._onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self._onTouchMove), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, self._onTouchEnd), cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(handler(self, self._onTouchEnd), cc.Handler.EVENT_TOUCH_CANCELLED)
    local eventDispatcher = self._btnBg:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self._btnBg)
    self._btnBg:setSwallowTouches(false)
end

function EmbattleItem:setOpenFromOther(flag)
    self._openFromOther = flag
end

function EmbattleItem:getCurInfoTypeByBosomHead()
    local role_type = 0
    if self._showBosom then
        role_type = uq.cache.formation.ROLE.ROLE_BOSOM
    else
        role_type = uq.cache.formation.ROLE.ROLE_GENERAL
    end
    return role_type
end

function EmbattleItem:_onTouchBegin(touches, event)
    if not self:formationOpened() then return false end
    if self._showBosom and not self._roleDatas[uq.cache.formation.ROLE.ROLE_BOSOM] then return false end


    local role_type = self:getCurInfoTypeByBosomHead()
    --判断点击位置在内部
    local location = touches:getLocation()
    local locationCon = self:convertToNodeSpace(location)
    local nodePos = cc.p(locationCon.x, locationCon.y)

    local rect = cc.rect(-60, -50, 120, 100)
    local view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.EMBATTLE_MODULE)
    if cc.rectContainsPoint(rect, nodePos) then
        if view then
            view:_onTouchBegin(touches, event)
            view:setMoveNodeData(self._roleDatas[role_type], role_type, self._index)
        end
        return true
    else
        if view then
            view:closeEmbattleGeneralTip()
        end
        return false
    end
end

function EmbattleItem:_onTouchMove(touches, event)
    local view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.EMBATTLE_MODULE)
    if view then
        view:_onTouchMove(touches, event)
    end
end

function EmbattleItem:_onTouchEnd(touches, event)
    local view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.EMBATTLE_MODULE)
    if view then
        view:_onTouchEnd(touches, event)
    end
end

function EmbattleItem:init()
    self._index = 0 --序号
    self.onIconTouchCallback = nil
    self:initData()
end

function EmbattleItem:initData()
    self._formationIndex = 0 --阵型id
    self._orderIndex = 0 --出手顺序
    self._roleDatas = {}
    self._formationData = nil
    self._formationStaticData = nil
    self._formationStaticLevel = 0
    self._btnSwitch:setVisible(false)
    self._curSelectInfo = nil --当前选中武将的信息
    self._showBosom = uq.cache.formation:getBosomShowState() --当前是否显示武将
end

function EmbattleItem:setData(formationIndex)
    self:initData()
    self._formationIndex = formationIndex
    self._formationStaticData = StaticData['formation'][formationIndex]
    self._formationData = uq.cache.formation:getFormationData(self._formationIndex)

    local content = self._formationStaticData.AtkOrder[1].AtkOrder
    local order = string.split(content, ',')
    for k,v in ipairs(order) do
        if self._index == tonumber(v) then
            self._orderIndex = k
            self._formationStaticLevel = self._formationStaticData.Location[self._orderIndex].level
            break
        end
    end
    if self._formationData then
        for _,item in ipairs(self._formationData.general_loc) do
            if item.index == self._index then
                self._roleDatas[uq.cache.formation.ROLE.ROLE_GENERAL] = uq.cache.generals:getGeneralDataByID(item.general_id)
                if item.bosom_id then
                    local bosoms = uq.cache.role.bosom:getAllBosomsInfo()
                    if bosoms then self._roleDatas[uq.cache.formation.ROLE.ROLE_BOSOM] = bosoms[item.bosom_id] end
                end
                break
            end
        end
    end
    self:refreshPage()
end

function EmbattleItem:refreshPage()
    if self._formationData then
        if self:formationOpened() then
            if self._roleDatas[uq.cache.formation.ROLE.ROLE_GENERAL] then
                self:refreshState(self.STATE.OPEN_SOLDIER)
            elseif self._orderIndex > 0 then
                self:refreshState(self.STATE.OPEN_NOT_EQUIP)
            else
                self:refreshState(self.STATE.NOT_OPEN)
            end
        else
            self:refreshState(self.STATE.NOT_OPEN)
        end
    else
        --未开启
        self:refreshState(self.STATE.NOT_OPEN)
    end
    if self._index <= 0 then
        self:refreshState(self.STATE.OPEN_SOLDIER)
    end
    self._nodeDown:setVisible(false)
    self._btnSwitch:setVisible(false)
    self:loadSoldier()
    self:loadBosomHead()
end

function EmbattleItem:refreshState(state)
    self._spriteBg1:setVisible(self._orderIndex > 0 and state ~= self.STATE.OPEN_NOT_EQUIP)
    self._spriteBg2:setVisible(state == self.STATE.OPEN_NOT_EQUIP)
    self._spriteBg3:setVisible(state == self.STATE.OPEN_SOLDIER)
    self._nodeCanUp:setVisible(state == self.STATE.OPEN_NOT_EQUIP)
    uq.log('EmbattleItem:refreshState', state, self.STATE.NOT_OPEN, self._orderIndex)
    self._nodeClosed:setVisible(state == self.STATE.NOT_OPEN and self._orderIndex > 0)
    self._txtLevel:setString(string.format("阵型%d级开启", self._formationStaticLevel))
end

function EmbattleItem:formationOpened()
    return self._formationData and self._formationStaticLevel <= self._formationData.lvl and self._orderIndex > 0
end

function EmbattleItem:setIndex(index)
    self._index = index
    if self._index <= 0 then
        return
    end
    self._spriteBg1:setTexture(self._normalImg[self._index])
    self._spriteBg2:setTexture(self._selectImg[self._index])
end

function EmbattleItem:loadSoldier()
    self._nodeSoldier:setVisible(self._roleDatas[uq.cache.formation.ROLE.ROLE_GENERAL] ~= nil)
    if self._roleDatas[uq.cache.formation.ROLE.ROLE_GENERAL] then
        local generalData = self._roleDatas[uq.cache.formation.ROLE.ROLE_GENERAL]
        local str = generalData.name
        self._txtName:setString(str)

        local soldier_config = StaticData['soldier'][self._roleDatas[uq.cache.formation.ROLE.ROLE_GENERAL].battle_soldier_id]
        if soldier_config then
            self:addSoldier(self._roleDatas[uq.cache.formation.ROLE.ROLE_GENERAL].battle_soldier_id)
        end
    end
end

function EmbattleItem:addSoldier(id)
    self._soldiers = {}
    self._nodeSoldier:removeAllChildren()
    local index = math.floor((self._index - 1) / 3) * 3 + 1
    if index <= 0 then
        index = 7
    end
    for i = 0, 8 do
        local troop_data = StaticData['soldier'][id]
        local node_solider = uq.createPanelOnly('instance.InstanceSoldier')
        local x = -45 + (i % 3) * 50 - 5 * (i / 3)
        local y = 55 - math.floor(i / 3) * 35
        local scale_index = index + math.floor(i / 3)
        node_solider:setPosition(cc.p(x, y))
        self._nodeSoldier:addChild(node_solider)
        node_solider:setData(nil, nil, troop_data.action, false, 'idle')
        node_solider:setDefaultSpeed(1)
        node_solider:playIdle()
        node_solider:setSoldierScale(self.SOLDIER_SCALE[scale_index])
        table.insert(self._soldiers, node_solider)
    end
end

function EmbattleItem:playAttack()
    for k, item in ipairs(self._soldiers) do
        item:playAttack(function()
            item:playIdle()
        end)
    end
end

--加载知己头像
function EmbattleItem:loadBosomHead()
    self._nodeBosomInfo:setVisible(self._roleDatas[uq.cache.formation.ROLE.ROLE_BOSOM] ~= nil and self._showBosom)
    if self._roleDatas[uq.cache.formation.ROLE.ROLE_BOSOM] then
        local bosom_id = self._roleDatas[uq.cache.formation.ROLE.ROLE_BOSOM].id
        local bosomTab = StaticData['bosom']['women'][bosom_id]
        if bosomTab then
            local icon = bosomTab.icon
            if icon then self._bosomHead:loadTexture('img/common/general_head/' .. icon) end
            local bosomType = bosomTab.qualityType
            local typeTab = StaticData['types']['TalkQualityType'][1]['Type'][bosomType]
            if typeTab then
                local bosomBg = typeTab.qualityIcon2
                if bosomBg then self._bosomHeadBg:loadTexture('img/bosom/' .. bosomBg) end
            end
        end
    end
end

function EmbattleItem:setBosomHeadState(flag)
    self._showBosom = flag
    self._nodeBosomInfo:setVisible(flag)
    if not self._roleDatas[uq.cache.formation.ROLE.ROLE_BOSOM] then
        self._nodeBosomInfo:setVisible(false)
    end
end

function EmbattleItem:setCurSelectData(role_type)
    self._curSelectInfo = self._roleDatas[role_type]
end

function EmbattleItem:setSoilderData(data, role_type)
    if self:formationOpened() or self._index <= 0 then
        if uq.cache.formation.ROLE.ROLE_GENERAL == role_type then
            self._roleDatas[uq.cache.formation.ROLE.ROLE_GENERAL] = data
        else
            self._roleDatas[uq.cache.formation.ROLE.ROLE_BOSOM] = data
        end
    end
    self:refreshPage()
end

function EmbattleItem:onSwitch(event)
    --[[if event.name == "ended" then
        local role_type = uq.cache.formation:getCurRoleType()
        self:switch(self._curSelectInfo)
    end]]
end

function EmbattleItem:switch(role_data, role_type)
    if uq.cache.formation.ROLE.ROLE_GENERAL == role_type then
        self:sendUpAndDownGeneralProtocol(role_data.id)
    end
    self._roleDatas[role_type] = role_data
    self:refreshPage()
    self._btnSwitch:setVisible(false)
end

function EmbattleItem:onBg(event)
    if self._roleDatas[uq.cache.formation.ROLE.ROLE_GENERAL] then
        if event.name == "ended" then
            if not self._curSelectInfo then
                self._nodeDown:setVisible(false)
            else
                self._btnSwitch:setVisible(false)
            end
        end
        if self.onIconTouchCallback then
            self.onIconTouchCallback(self._roleDatas, self._index, event)
        end
    end
end

--武将下阵
function EmbattleItem:downRole(replaceID)
    local role_type = self._showBosom and uq.cache.formation.ROLE.ROLE_BOSOM or uq.cache.formation.ROLE.ROLE_GENERAL
    if not self._showBosom then
        if self._roleDatas[uq.cache.formation.ROLE.ROLE_BOSOM] then
            self._roleDatas[uq.cache.formation.ROLE.ROLE_BOSOM] = nil
        end
        self:sendUpAndDownGeneralProtocol(0)
    end
    uq.cache.formation:roleDown(self._roleDatas[role_type], role_type)
    self._roleDatas[role_type] = nil

    self:refreshPage()
    self._nodeDown:setVisible(false)
end

function EmbattleItem:sendUpAndDownGeneralProtocol(general_id)
    local data = {
        formation_id = self._formationIndex,
        genaral_battle_id = general_id,
        formation_pos = self._index
    }
    if not self._openFromOther then
        network:sendPacket(Protocol.C_2_S_FORMATION_GENARAL_BATTLE, data)
    end
end

function EmbattleItem:onDown(event)
    if event.name == "ended" then
        self:downRole(-1)
    end
end

function EmbattleItem:getRoleData(role_type)
    if self._roleDatas[role_type] then
        return self._roleDatas[role_type]
    else
        return nil
    end
end

function EmbattleItem:getRoleID(role_type)
    if self._roleDatas[role_type] then
        return self._roleDatas[role_type].id
    else
        return 0
    end
end

function EmbattleItem:setIconTouchCallback(callback)
    self.onIconTouchCallback = callback
end

return EmbattleItem