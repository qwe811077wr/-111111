local SingleBattleModule = class("SingleBattleModule", require('app.base.ModuleBase'))

SingleBattleModule.RESOURCE_FILENAME = "battle/SingleBattleView.csb"
SingleBattleModule.RESOURCE_BINDING = {
    ["atk_name_txt"]  = {["varname"] = "_txtAtk"},
    ["level_left"]    = {["varname"] = "_txtLevelLeft"},
    ["level_right"]   = {["varname"] = "_txtLevelRight"},
    ["def_name_txt"]  = {["varname"] = "_txtDef"},
    ["button_over"]   = {["varname"] = "_btnOver",["events"] = {{["event"] = "touch",["method"] = "onOver"}}},
    ["button_speed"]  = {["varname"] = "_btnDouble",["events"] = {{["event"] = "touch",["method"] = "onDouble"}}},
    ["Sprite_4"]      = {["varname"] = "_spriteSpeed"},
    ["img_bg_adapt"]  = {["varname"] = "_imgBg"},
    ["round_txt"]     = {["varname"] = "_txtRound"},
    ["button_info"]   = {["varname"] = "_btnSoldierInfo",["events"] = {{["event"] = "touch",["method"] = "onSoldierInfo"}}},
    ["Button_effect"] = {["varname"] = "_btnEffect",["events"] = {{["event"] = "touch",["method"] = "onEffect"}}},
    ["button_buff"]   = {["varname"] = "_btnBuff",["events"] = {{["event"] = "touch",["method"] = "onBuff"}}},
    ["node_info"]     = {["varname"] = "_nodeInfo"},
    ["Sprite_3"]      = {["varname"] = "_spriteHeadLeft"},
    ["Sprite_2"]      = {["varname"] = "_spriteHeadRight"},
    ["Node_1"]        = {["varname"] = "_nodeHeadLeft"},
    ["Node_2"]        = {["varname"] = "_nodeHeadRight"},
    ["panel_mask"]    = {["varname"] = "_panelMask"},
    ["Image_7"]       = {["varname"] = "_imgOver"},
    ["node_ui"]       = {["varname"] = "_nodeUI"},
    ["Node_left"]     = {["varname"] = "_nodeLeft"},
    ["Node_right"]    = {["varname"] = "_nodeRight"},
}

SingleBattleModule.ITEM_ZORDER = {
    NORMAL           = 0,
    SOLDIER          = 1,
    EFFECT_BUFF      = 3,
    EFFECT_SKILL     = 100,
    EFFECT_MASK      = 101,
    SOLDIER_TOP      = 102,
    EFFECT_BUFF_TOP  = 103,
    EFFECT_SKILL_TOP = 104,
    UI               = 105,
    SOLDIER_INFO     = 106,
}

function SingleBattleModule:ctor(name, params)
    params.sound_id = 0
    SingleBattleModule.super.ctor(self, name, params)
    self._report = params.report
    self._finishCB = params.cb
    self._bgPath = params.report.bg_path
    self._isReplay = params.report.is_replay
    self._cells = {{}, {}}

    self._curRoundIdx = 1
    self._curObjectIdx = 1
    self._curActionIdx = 1
    self._playActionDelayTime = 0.5
    self._overBattleTag = 'over_battle_tag' .. tostring(self)
    self._overGame = false
    self._openOver = 1
    self._openSpeedUp = 1
    self._openEffect = true
    uq.playSoundByID(1109)
    -- uq.log('SingleBattleModule:ctor', self._report)
end

function SingleBattleModule:init()
    self:parseView()
    self:centerView()
    self:adaptBgSize()
    self:setBaseBgVisible(true)

    self._nodeUI:setLocalZOrder(self.ITEM_ZORDER.UI)
    self._imgBg:loadTexture(self._bgPath)
    self._panelMask:setLocalZOrder(self.ITEM_ZORDER.EFFECT_MASK)

    local report = self._report
    for i = 0, 1 do
        local name_txt   = nil
        local obj        = nil
        local txt_level  = nil
        local head_icon  = nil
        local soldier_type = ''
        if i == 0 then
            name_txt   = self._txtAtk
            obj        = report.atker
            txt_level  = self._txtLevelLeft
            head_icon  = self._spriteHeadLeft
            soldier_type = 'a'
        else
            name_txt   = self._txtDef
            obj        = report.defenser
            txt_level  = self._txtLevelRight
            head_icon  = self._spriteHeadRight
            soldier_type = 'd'
        end
        name_txt:setString(obj.name)
        txt_level:setString(string.format('lv%d', obj.level))

        local res_head = uq.getHeadRes(obj.img_id, obj.img_type)
        if res_head == "" then
            res_head = 'img/common/player_head/WJTX0001.png'
        end
        head_icon:setTexture(res_head)

        for _, v in pairs(obj.generals) do
            local node = self:getResourceNode():getChildByName(v.pos .. soldier_type)
            local cell = uq.createPanelOnly('battle.BattleSoldierGroup')
            cell:setData(v, i + 1, i == 1, self)
            cell:setPosition(cc.p(-60, -66))
            node:addChild(cell)
            self._cells[i + 1][v.pos] = cell
        end
    end
    for _, v in pairs(self._cells) do
        for _, v1 in pairs(v) do
            v1:playIdle()
        end
    end

    self:showFormation(false)
    self:refreshPage()
    self:refreshSoldierInfo()
    self:refreshEffect()
    self:refreshSpeed()
    self:format()
    self:hideUI(true)

    local start_animation = uq.createPanelOnly('battle.BattleStartAnimation')
    start_animation:setData(self._report)
    start_animation:setEndCallback(handler(self, self.startAnimationEndCallback))
    self:addChild(start_animation)

    uq.ModuleManager:getInstance():dispose(uq.ModuleManager.NPC_WIN_MODULE)
    uq.ModuleManager:getInstance():dispose(uq.ModuleManager.NPC_LOST_MODULE)
    uq.ModuleManager:getInstance():dispose(uq.ModuleManager.NPC_DRILL_WIN_MODULE)
    uq.ModuleManager:getInstance():dispose(uq.ModuleManager.NPC_DRILL_LOST_MODULE)
    uq.ModuleManager:getInstance():dispose(uq.ModuleManager.SINGLE_BATTLE_MODULE)

    self:clipHead(self._spriteHeadLeft, self._nodeHeadLeft)
    self:clipHead(self._spriteHeadRight, self._nodeHeadRight)

    self._nodeLeft:setPosition(cc.p(-display.width / 2, -CC_DESIGN_RESOLUTION.height / 2))
    self._nodeRight:setPosition(cc.p(display.width / 2, -CC_DESIGN_RESOLUTION.height / 2))

    self:addBgEffect()
end

function SingleBattleModule:addBgEffect()
    local strs = string.split(self._bgPath, '/')
    local bg_name = strs[#strs]
    local effects = uq.cache.instance:getBgConfig(bg_name)
    for k, item in ipairs(effects) do
        uq:addEffectByNode(self._imgBg, item.txid, -1, true, cc.p(item.X, item.Y))
    end
end

function SingleBattleModule:showFormation(flag)
    for i = 1, 9 do
        local child_node = self:getResourceNode():getChildByName(tostring(i) .. 'a')
        child_node:setVisible(flag)
    end

    for i = 1, 9 do
        local child_node = self:getResourceNode():getChildByName(tostring(i) .. 'd')
        child_node:setVisible(flag)
    end
end

function SingleBattleModule:clipHead(sprite_head, node_bg)
    local node_clip = cc.ClippingNode:create()
    local stencil_node = cc.DrawNode:create()
    stencil_node:drawSolidCircle(cc.p(0, 0), 50, math.pi, 50, 1, 1, cc.c4b(1, 0, 0, 1))
    node_clip:setStencil(stencil_node)

    sprite_head:removeFromParent()
    sprite_head:setPosition(cc.p(0, 0))

    node_clip:addChild(sprite_head)
    node_clip:setInverted(false)
    node_bg:addChild(node_clip)
end

function SingleBattleModule:onCreate()
    SingleBattleModule.super.onCreate(self)
    self._panelMask:setContentSize(display.size)
    self._panelMask:setVisible(false)
end

function SingleBattleModule:convertPos(node, x, y)
    x = x
    y = CC_DESIGN_RESOLUTION.height - y
    local pos = node:convertToNodeSpace(cc.p(x, y))
    return pos
end

function SingleBattleModule:format()
    local xml_data = StaticData['formation_loc'].Formationloc

    for i = 1, 9 do
        local center = cc.p(xml_data[i].x1 + 70 - display.width / 2, display.height / 2 - xml_data[i].y1 + 110)
        local child_node = self:getResourceNode():getChildByName(tostring(i) .. 'a')
        child_node:setPosition(center)
        child_node:setLocalZOrder(self.ITEM_ZORDER.SOLDIER)
        child_node.init_pos = center
    end

    for i = 1, 9 do
        local index = i + 9
        local center = cc.p(xml_data[index].x1 + 70 - display.width / 2, display.height / 2 - xml_data[index].y1 + 110)
        local child_node = self:getResourceNode():getChildByName(tostring(i) .. 'd')
        child_node:setPosition(center)
        child_node:setLocalZOrder(self.ITEM_ZORDER.SOLDIER)
        child_node.init_pos = center
    end
end

function SingleBattleModule:getCenterFrontPos(side)
    if side == 1 then
        local init_pos = self:getResourceNode():getChildByName('6a').init_pos
        return cc.p(init_pos.x + 115, init_pos.y + 58)
    else
        local init_pos = self:getResourceNode():getChildByName('6d').init_pos
        return cc.p(init_pos.x - 115, init_pos.y - 58)
    end
end

function SingleBattleModule:refreshPage()
    if self._isReplay then
        self._btnOver:setVisible(true)
    elseif uq.cache.role:level() < self._openOver then
        self._btnOver:setVisible(false)
    else
        --五秒后可以操作
        self._btnOver:setVisible(true)

        self._endTime = os.time() + 0
        uq.ShaderEffect:addGrayButton(self._btnOver)
        uq.ShaderEffect:setGrayAndChild(self._imgOver)
        self:refreshOverDesc()

        uq.TimerProxy:removeTimer(self._overBattleTag)
        uq.TimerProxy:addTimer(self._overBattleTag, handler(self, self.refreshOverDesc), 1, -1)
    end

    if uq.cache.role:level() < self._openSpeedUp then
        uq.ShaderEffect:addGrayButton(self._btnDouble)
        uq.ShaderEffect:setGrayAndChild(self._spriteSpeed)
    end
end

function SingleBattleModule:refreshOverDesc()
    if self._endTime <= os.time() then
        uq.ShaderEffect:removeGrayButton(self._btnOver)
        uq.ShaderEffect:setRemoveGrayAndChild(self._imgOver)
        uq.TimerProxy:removeTimer(self._overBattleTag)
    end
end

function SingleBattleModule:onExit()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_BEFORE_WAR})
    uq.TimerProxy:removeTimer(self._overBattleTag)
    SingleBattleModule.super:onExit()
end

function SingleBattleModule:startAnimationEndCallback()
    self:showFormation(true)
    self:hideUI(false)

    uq.delayAction(self, 0.5, function()
        self:playOneRound()
    end)
end

function SingleBattleModule:hideUI(flag)
    self._nodeLeft:setVisible(not flag)
    self._nodeRight:setVisible(not flag)
    self._nodeInfo:setVisible(not flag)
    uq.ModuleManager:getInstance():dispose(uq.ModuleManager.SINGLE_BATTLE_BUFFS_MODULE)
end

--执行一轮回合
function SingleBattleModule:playOneRound()
    if self._curRoundIdx > #self._report.rounds then
        if self._finishCB and not self._overGame then
            self:hideUI(true)
            self._finishCB(self._report)
        end
    else
        self:setRoundTitle(self._report.rounds[self._curRoundIdx].round)
        self:playOneSide()
    end
end

--执行一边
function SingleBattleModule:playOneSide()
    local round = self._report.rounds[self._curRoundIdx]
    if self._curObjectIdx > #round.objects then
        self._curActionIdx = 1
        self._curObjectIdx = 1
        self._attackActionData = nil
        self._curRoundIdx = self._curRoundIdx + 1
        self:playOneRound()
    else
        self:playActionDelay()
    end
end

function SingleBattleModule:playActionDelay()
    local round = self._report.rounds[self._curRoundIdx]
    local actions = round.objects[self._curObjectIdx]
    if self._curActionIdx > #actions then
        self._curActionIdx = 1
        --下一回合
        self._curObjectIdx = self._curObjectIdx + 1
        self._attackActionData = nil
        uq.delayAction(self, self._playActionDelayTime / uq.cache.instance._speed, handler(self, self.playOneSide))
    else
        self:playAction()
    end
end

function SingleBattleModule:playReadyAction()
    local round = self._report.rounds[self._curRoundIdx]
    local actions = round.objects[self._curObjectIdx]
    for index = self._curActionIdx + 1, 100 do
        local action_data = actions[index]
        if not action_data then
            break
        end
        local side = self._cells[action_data.side]
        if action_data.action == uq.BattleReport.ACTION_TYPE_HURT then
            for _, v in pairs(action_data.targets) do
                local obj = side[v.pos]
                obj:playReadyHitEffect(self._attackActionData)
            end
            break
        end
    end
end

function SingleBattleModule:getHurtSoldier()
    local round = self._report.rounds[self._curRoundIdx]
    local actions = round.objects[self._curObjectIdx]
    for index = self._curActionIdx + 1, 100 do
        local action_data = actions[index]
        if not action_data then
            break
        end
        local side = self._cells[action_data.side]
        if action_data.action == uq.BattleReport.ACTION_TYPE_HURT then
            return action_data.targets, side
        end
    end
end

function SingleBattleModule:playAction()
    local round = self._report.rounds[self._curRoundIdx]
    local actions = round.objects[self._curObjectIdx]
    local action_data = actions[self._curActionIdx]
    local side = self._cells[action_data.side]
    if action_data.action == uq.BattleReport.ACTION_TYPE_ATK then --1
        self._finishAttack = false
        self._attackActionData = action_data
        local cb = handler(self, self._attackCB)
        local called = false
        self._attackSoldierNum = #action_data.targets --有效数量
        for _, v in pairs(action_data.targets) do
            local obj = side[v.pos]
            obj:playWalkAction(v.skill_id, function()
                local skill_data = StaticData['skill'][v.skill_id]
                --技能弹出技能信息
                if skill_data.type > 0 then
                    obj:playAttack(v, cb)
                else
                    --普通攻击动作 攻击动作完成后才可进行下一动作
                    obj:playAttack(v)
                    local action_time = obj:getAnimationTime(uq.config.constant.ACTION_TYPE.ANIMATION_NAME_ATTACK)
                    uq.delayAction(self, action_time / 2, function()
                        cb(obj)
                    end)
                end
            end)
            called = true
        end
        if called then
            return
        end
    elseif action_data.action == uq.BattleReport.ACTION_TYPE_HURT then --2
        local cb = handler(self, self.hitCB)
        local called = false
        self._hitSoldierNum = #action_data.targets --有效数量
        self._actionData = action_data
        for _, v in pairs(action_data.targets) do
            local obj = side[v.pos]
            obj:playHurt(self._attackActionData, v, cb)
            called = true
        end
        if called then
            return
        end
    elseif action_data.action == uq.BattleReport.ACTION_TYPE_BUFF then --3
        for _, v in pairs(action_data.targets) do
            for _, k in pairs(v.poses) do
                local obj = side[k]
                obj:addBuff(self._attackActionData, v)
            end
        end
    elseif action_data.action == uq.BattleReport.ACTION_TYPE_MORALE then --4
        local cb = handler(self, self.moralCB)
        local called = false
        self._moralSoldierNum = #action_data.targets --有效数量
        for _, v in pairs(action_data.targets) do
            local obj = side[v.pos]
            obj:addMoral(v.morale, self:popMoral(v, self._attackActionData), self._attackActionData, cb)
            called = true
        end
        if called then
            return
        end
    elseif action_data.action == uq.BattleReport.ACTION_TYPE_RELIVE then --5
    end
    self:playNextAction()
end

function SingleBattleModule:moralCB()
    self._moralSoldierNum = self._moralSoldierNum - 1
    if self._moralSoldierNum > 0 then
        return
    end

    if self._finishAttack then
        self:playNextAction()
    end
end

--判断是否是释放技能扣除士气
function SingleBattleModule:popMoral(cur_data, attack_data)
    if not attack_data then
        --没有攻击动作
        return true
    end

    local skill_id = attack_data.targets[1].skill_id
    local skill_data = StaticData['skill'][skill_id]

    if skill_data.type == 0 and skill_id ~= 11 and skill_id ~= 1101 and skill_id ~= 16 then
        return false
    end

    if attack_data.targets[1].pos == cur_data.pos then
        if skill_data.type == 0 then
            --普攻
            return false
        end
        if cur_data.morale <= 0 then
            --技能减士气
            return false
        else
            --技能加士气
            return true
        end
    else
        return true
    end
end

function SingleBattleModule:_attackCB(obj)
    self._attackSoldierNum = self._attackSoldierNum - 1
    if self._attackSoldierNum > 0 then
        return
    end
    self._finishAttack = true
    self:playNextAction() --hurt action
end

function SingleBattleModule:hitCB()
    self._hitSoldierNum = self._hitSoldierNum - 1
    if self._hitSoldierNum > 0 then
        return
    end

    --攻击者归位
    if self._attackActionData then
        local side = self._cells[self._attackActionData.side]
        self._walkSoldierNum = #self._attackActionData.targets
        for _, v in pairs(self._attackActionData.targets) do
            local obj = side[v.pos]
            obj:playBackWalkAction(v.skill_id, function()
                obj:playIdle()
                self:hitCBEnd()
            end)
        end
    else
        self._walkSoldierNum = 0
        self:hitCBEnd()
    end
end

function SingleBattleModule:hitCBEnd()
    self._walkSoldierNum = self._walkSoldierNum - 1
    if self._walkSoldierNum > 0 then
        return
    end

    if self._finishAttack then
        self:playNextAction()
    end
end

function SingleBattleModule:playNextAction()
    self._curActionIdx = self._curActionIdx + 1
    self:playActionDelay()
end

function SingleBattleModule:setRoundTitle(round)
    self._txtRound:setString(round)
end

function SingleBattleModule:dispose()
    for _, v in pairs(self._cells) do
        for _, v1 in pairs(v) do
            v1:dispose()
        end
    end
    SingleBattleModule.super.dispose(self)
end

function SingleBattleModule:overGame()
    self._overGame = true
    --跳过动作
    for _, v in pairs(self._cells) do
        for _, v1 in pairs(v) do
            v1:setJumpAction(true)
        end
    end

    if self._finishCB then
        self:hideUI(true)
        self._finishCB(self._report)
    end
end

function SingleBattleModule:setSpeed(speed)
    --跳过动作
    for _, v in pairs(self._cells) do
        for _, v1 in pairs(v) do
            v1:setSpeed(speed)
        end
    end
end

function SingleBattleModule:onOver(event)
    if event.name ~= "ended" then
        return
    end

    if self._isReplay then
        self:overGame()
    elseif uq.cache.role:level() < self._openOver then
        uq.fadeInfo(string.format(StaticData['local_text']['label.battle.maincity'], self._openOver))
    elseif self._endTime > os.time() then
        uq.ShaderEffect:addGrayButton(self._btnOver)
        uq.ShaderEffect:setGrayAndChild(self._imgOver)
    else
        self:overGame()
    end
end

function SingleBattleModule:refreshSpeed()
    if uq.cache.instance._speed == 1 then
        self._spriteSpeed:setTexture('img/battle/s02_00016_2.png')
        self:setSpeed(uq.cache.instance._speed)
    else
        self._spriteSpeed:setTexture('img/battle/s02_00016_3.png')
        self:setSpeed(uq.cache.instance._speed)
    end
end

function SingleBattleModule:onDouble(event)
    if event.name == "ended" then
        if uq.cache.role:level() >= self._openSpeedUp then
            if uq.cache.instance._speed == 2 then
                uq.cache.instance._speed = 1
            else
                uq.cache.instance._speed = 2
            end
            self:refreshSpeed()
        else
            uq.fadeInfo(string.format(StaticData['local_text']['label.battle.speedup'], self._openSpeedUp))
        end
    end
end

function SingleBattleModule:getConvertPos(soldier_group)
    local group_parent = soldier_group:getParent()
    local pos_x, pos_y = group_parent:getPosition()
    local world_pos = group_parent:getParent():convertToWorldSpace(cc.p(pos_x, pos_y))
    local node_pos = self:convertToNodeSpace(world_pos)
    local size = group_parent:getContentSize()

    return cc.p(node_pos.x + size.width / 2,  node_pos.y + size.height / 2)
end

function SingleBattleModule:refreshSoldierInfo()
    if uq.cache.instance._openSoldierInfo then
        for _, side in pairs(self._cells) do
            for k, item in pairs(side) do
                item:setLittleVisible(true)
            end
        end

        self._btnSoldierInfo:loadTextureNormal('img/battle/s02_00017.png')
        self._btnSoldierInfo:loadTexturePressed('img/battle/s02_00017.png')
    else
        for _, side in pairs(self._cells) do
            for k, item in pairs(side) do
                item:setLittleVisible(false)
            end
        end

        self._btnSoldierInfo:loadTextureNormal('img/battle/s02_00017_1.png')
        self._btnSoldierInfo:loadTexturePressed('img/battle/s02_00017_1.png')
    end
end

function SingleBattleModule:onSoldierInfo(event)
    if event.name ~= "ended" then
        return
    end
    uq.cache.instance._openSoldierInfo = not uq.cache.instance._openSoldierInfo
    self:refreshSoldierInfo()
end

function SingleBattleModule:refreshEffect()
    if self._openEffect then
        self._btnEffect:loadTextureNormal('img/battle/s02_00018.png')
        self._btnEffect:loadTexturePressed('img/battle/s02_00018.png')
    else
        self._btnEffect:loadTextureNormal('img/battle/s02_00018_2.png')
        self._btnEffect:loadTexturePressed('img/battle/s02_00018_2.png')
    end
end

function SingleBattleModule:onEffect(event)
    if event.name ~= "ended" then
        return
    end

    if self._openEffect then
        self._openEffect = false
    else
        self._openEffect = true
    end
    self:refreshEffect()
end

function SingleBattleModule:onBuff(event)
    if event.name ~= "ended" then
        return
    end

    local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.SINGLE_BATTLE_BUFFS_MODULE)
    panel:setLocalZOrder(uq.ModuleManager.SPECIAL_ZORDER.CONFIRM_BOX_ZORDER + 1)
end

function SingleBattleModule:getSpeed()
    return uq.cache.instance._speed
end

function SingleBattleModule:getEffectOpened()
    --return self._openEffect
    return false
end

function SingleBattleModule:setMaskVisible(flag)
    self._panelMask:setVisible(flag)
end

function SingleBattleModule:getObject(side, pos)
    return self._cells[side][pos]
end

return SingleBattleModule