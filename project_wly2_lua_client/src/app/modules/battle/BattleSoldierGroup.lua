local BattleSoldierGroup = class('BattleSoldierGroup', require('app.base.ChildViewBase'))

BattleSoldierGroup.RESOURCE_FILENAME = "battle/BattleCell.csb"
BattleSoldierGroup.RESOURCE_BINDING = {
    ["soldiers"]         = {["varname"] = "_nodeSolders"},
    ["node_poptext"]     = {["varname"] = "_nodeFlyHp"},
    ["node_skilleffect"] = {["varname"] = "_nodeSkill"},
    ["node_buff"]        = {["varname"] = "_nodeBuff"},
    ["node_head_little"] = {["varname"] = "_nodeLittle"},
    ["panel_touch"]      = {["varname"] = "_panelTouch",["events"] = {{["event"] = "touch",["method"] = "onPanelTouch"}}},
    ["Image_6"]          = {["varname"] = "_imgBg"},
    ["image_type"]       = {["varname"] = "_imgGeneral"},
}

function BattleSoldierGroup:onCreate()
    BattleSoldierGroup.super.onCreate(self)
    self._jumpAction = false
    self._txtQuene = {}
end

function BattleSoldierGroup:setData(obj, side, flip_x, parent)
    self._side = side
    self._curHP = obj.cur_soldier_num
    self._maxHP = obj.max_soldier_num
    self._curMoral = 0
    self._maxMoral = 100
    self.MAX_MORAL = 100
    self._parent = parent
    self._data = obj
    self._soldierNum = {1,2,3,4,5,6,7,8,9}
    self._fillPos = {7,5,9,2,1,4,6,3,8} --填充顺序
    self._buffs = {}
    self._hurtDelay = 1

    local soldier_data = StaticData['soldier'][obj.soldier_id]
    if soldier_data.fillType == 2 and self._side == 1 then
        self._soldierNum = {2, 4, 6, 7, 8, 9}
    elseif soldier_data.fillType == 2 and self._side == 2 then
        self._soldierNum = {2, 4, 6, 7, 8, 9}
    elseif soldier_data.fillType == 3 then
        self._soldierNum = {6,7,8,9}
    end
    self:formation()

    local xml_data = StaticData['formation_loc'].scale
    local cell_line = math.floor((self._data.pos - 1) / 3) + 1
    self._soldiers = {}
    for i = 1, #self._soldierNum do
        local node_pos = self._nodeSolders:getChildByName(self._soldierNum[i])
        local horizon_num = math.floor((node_pos.pos_index - 1) / 3) + 1
        local line = horizon_num + (cell_line - 1) * 3
        line = 9 - line + 1
        local soldier = uq.createPanelOnly('battle.BattleSoldier')
        soldier:setData(obj, side, false, self._soldierNum[i], node_pos.pos_index)
        node_pos:addChild(soldier)
        soldier:setScale(xml_data[line].scale)
        soldier:setName('soldier')
        table.insert(self._soldiers, soldier)
    end

    local general_config = StaticData['general'][obj.id]
    self._nodeLittle:getChildByName('image_type'):loadTexture('img/common/general_head/' .. general_config.icon)
    uq.cache.formation:clipHead(self._nodeLittle:getChildByName('image_type'), self._nodeLittle:getChildByName('Node_23'))
    self._nodeLittle:getChildByName('txt_type'):setString(StaticData['types'].Soldier[1].Type[soldier_data.type].shortName)

    local skill_data = StaticData['skill'][obj.skill_id]
    self._maxMoral = skill_data.launchMorale
    self._nodeLittle:getChildByName('Panel_3_0'):setContentSize(cc.size(60 * self._maxMoral / self.MAX_MORAL, 20))

    self._actionFinishCallback = nil
    self:setDefaultSpeed(1)
    self:updateMoral()
    self:updateHP()

    local node_soldier = self._nodeSolders:getChildByName('1')
    local x, y = node_soldier:getPosition()
    local size = self._imgBg:getContentSize()
    self._imgBg:setPosition(cc.p(x + 8, y - size.height / 2 + 17))
    self:showBg(false)
    self:setGlobalZOrder(1000)
    self:deadAction()
end

function BattleSoldierGroup:formation()
    local xml_data = StaticData['formation_loc'].scale
    local cell_line = math.floor((self._data.pos - 1) / 3) + 1
    local soldier_data = StaticData['soldier'][self._data.soldier_id]
    local offx = {0, 30, 60}
    self._spacex = 30

    if soldier_data.fillType == 2 then
        self._spacex = 30
    elseif soldier_data.fillType == 3 then
        self._spacex = 30
    end

    for i = 1, 9 do
        local index = math.floor((i - 1) / 3) + 1
        local line = index + (cell_line - 1) * 3
        line = 9 - line + 1

        --local off = offx[index] * xml_data[line].scale
        local off = offx[index]
        local x = (i - 1) % 3 * self._spacex + off
        local y = 0 - math.floor((i - 1) / 3) * 15 + (i - 1) % 3 * 15
        local node_pos = self._nodeSolders:getChildByName(self._fillPos[i])
        node_pos:setPosition(cc.p(x, y))
        node_pos.pos_index = i
    end
end

function BattleSoldierGroup:getSoldierPercent()
    return self._curHP / self._maxHP
end

function BattleSoldierGroup:getMoral()
    return self._curMoral
end

function BattleSoldierGroup:playIdle()
    for k, item in ipairs(self._soldiers) do
        if not item:isDead() then
            item:playIdle()
        end
    end
end

function BattleSoldierGroup:playWalk(start_pos, end_pos, callback, walk_attack)
    self:removeMoralEffect()
    for k, item in ipairs(self._soldiers) do
        if not item:isDead() then
            if walk_attack then
                item:playWalkLeft()
            else
                item:playWalkRight()
            end
        end
    end
    local speed = 800 * uq.cache.instance._speed
    local time = cc.pGetDistance(start_pos, end_pos) / speed
    time = math.min(0.2 / uq.cache.instance._speed, time)
    self:getParent():runAction(cc.Sequence:create(cc.MoveTo:create(time, end_pos), cc.CallFunc:create(function()
        if callback then
            callback()
        end
    end)))
end

function BattleSoldierGroup:getFrontPos()
    local init_pos = self:getParent().init_pos
    if self:side() == 1 then
        return cc.p(init_pos.x + 115, init_pos.y + 58)
    else
        return cc.p(init_pos.x - 115, init_pos.y - 58)
    end
end

function BattleSoldierGroup:getAliveSolderNum()
    local num = 0
    for k, item in ipairs(self._soldiers) do
        if not item:isDead() then
            num = num + 1
        end
    end
    return num
end

function BattleSoldierGroup:popSkillInfo(callback)
    local type_panel = nil
    local skill_data = StaticData['skill'][self._curAttackActionData.skill_id]
    if self._parent:getEffectOpened() then
        if self:side() == 1 then
            local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.SKILL_POP_FULL, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
            panel:setData(self._data, callback)
        else
            self:removeMoralEffect()
            local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.SKILL_POP, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
            panel:setData(self:side(), callback, self._data, skill_data)
            panel:setLocalZOrder(uq.ModuleManager.SPECIAL_ZORDER.CONFIRM_BOX_ZORDER)
        end
    else
        self:removeMoralEffect()
        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.SKILL_POP, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
        panel:setData(self:side(), callback, self._data, skill_data)
        panel:setLocalZOrder(uq.ModuleManager.SPECIAL_ZORDER.CONFIRM_BOX_ZORDER)
    end
end

function BattleSoldierGroup:playWalkAction(skill_id, end_call)
    if self._jumpAction then
        return
    end
    self:showBg(true)

    local skill_data = StaticData['skill'][skill_id]
    local soldier_data = StaticData['soldier'][self._data.soldier_id]
    local hurt_soldier, soldiers = self._parent:getHurtSoldier()
    -- move 可移动
    if hurt_soldier and #hurt_soldier > 0 and skill_data.move > 0 then
        if skill_data.move == 1 then
            self:playWalk(self:getParent().init_pos, soldiers[hurt_soldier[1].pos]:getFrontPos(), function()
                if end_call then
                    end_call()
                end
            end, true)
        else
            self:playWalk(self:getParent().init_pos, self._parent:getCenterFrontPos(math.abs(self:side() - 3)), function()
                if end_call then
                    end_call()
                end
            end, true)
        end
    else
        if end_call then
            end_call()
        end
    end
end

function BattleSoldierGroup:playBackWalkAction(skill_id, end_call)
    if self._jumpAction then
        return
    end
    local skill_data = StaticData['skill'][skill_id]
    local soldier_data = StaticData['soldier'][self._data.soldier_id]
    if skill_data.move > 0 then
        local x, y = self:getParent():getPosition()
        self:playWalk(cc.p(x, y), self:getParent().init_pos, function()
            if end_call then
                end_call()
            end
        end, false)
    else
        if end_call then
            end_call()
        end
    end
end

function BattleSoldierGroup:playAttack(cur_action_data, finish_cb)
    if self._jumpAction then
        return
    end
    self._actionFinishCallback = finish_cb

    if self:isDead() then
        self:playCB()
        return
    end

    self._curAttackActionData = cur_action_data
    self:attackDelay()
end

function BattleSoldierGroup:attackDelay()
    local skill_data = StaticData['skill'][self._curAttackActionData.skill_id]
    --非普通攻击
    if skill_data.type > 0 then
        --喊招
        self:showToTop(true)
        self:popSkillInfo(function()
            self:showToTop(false)
            self:changeBig(false)
            self:playSkillAction()
            self:playAttackEffect()
        end)
        self:playReadyAction()
        --播放下一回合蓄力受击特效
        self._parent:playReadyAction()
    else
        self:playAttackAction()
        self:playAttackEffect()
    end
end

function BattleSoldierGroup:playReadyHitEffect(attack_data)
    self:playSkillEffect(attack_data.targets[1], nil, true)
end

function BattleSoldierGroup:playReadyAction()
    -- self._readyActionFinishNum = 0
    -- for k, item in ipairs(self._soldiers) do
    --     if not item:isDead() then
    --         item:playReady(handler(self, self.readyActionFinishCallback))
    --     end
    -- end
    self:playIdle()
    self:readyActionFinishCallback()
end

function BattleSoldierGroup:playSkillAction()
    self._attackActionFinishNum = 0
    for k, item in ipairs(self._soldiers) do
        if not item:isDead() then
            item:playSkill(handler(self, self.attackActionFinishCallback))
        end
    end
end

function BattleSoldierGroup:changeBig(flag)
    if flag then
        -- self:setScale(2)
        -- local x, y = self:getPosition()
        -- self:setPosition(cc.p(x - 7, y + 11))
    else
        -- self:setScale(1)
        -- local x, y = self:getPosition()
        -- self:setPosition(cc.p(x + 7, y - 11))
    end
end

function BattleSoldierGroup:readyActionFinishCallback()
    -- self._readyActionFinishNum = self._readyActionFinishNum + 1
    -- if self._readyActionFinishNum < self:getAliveSolderNum() then
    --     return
    -- end
    --攻击前施法蓄力特效
    local node_effect = self:addEffect(400096, false, self:side() == 2, self._parent.ITEM_ZORDER.EFFECT_SKILL)
    if node_effect then
        local x, y = node_effect:getPosition()
        node_effect:setPosition(cc.p(x + 7, y + 11))
    end
    self:changeBig(true)
    self:showBg(false)
end

function BattleSoldierGroup:playAttackAction()
    self._attackActionFinishNum = 0
    for k, item in ipairs(self._soldiers) do
        if not item:isDead() then
            item:playAttack(handler(self, self.attackActionFinishCallback))
        end
    end
end

function BattleSoldierGroup:playAttackEffect()
    --launch effect
    self:playLaunchEffect()
    --effect 1暴击 2反击 3暴击和反击
    if self._curAttackActionData.effect == 1 then
        uq.BattleRule:popText(self._nodeFlyHp, uq.BattleRule.POP_TEXT.hit)
    elseif self._curAttackActionData.effect == 2 then
        uq.BattleRule:popText(self._nodeFlyHp, uq.BattleRule.POP_TEXT.against)
    elseif self._curAttackActionData.effect == 3 then
        uq.BattleRule:popText(self._nodeFlyHp, uq.BattleRule.POP_TEXT.restrain)
    end
end

function BattleSoldierGroup:launchEffectFinishCallback()
    self:playCB()
end

function BattleSoldierGroup:playLaunchEffect()
    if not self._curAttackActionData then
        return
    end
    --技能动作执行完毕，释放技能
    local skill_data = StaticData['skill'][self._curAttackActionData.skill_id]
    --发动特效
    if skill_data.isfull > 0 then
        --全屏特效
        self:playFullScreenSkillEffect(skill_data, handler(self, self.launchEffectFinishCallback))
    else
        --普通特效
        if tonumber(skill_data.launchTx) > 0 then
            self:addEffect(tonumber(skill_data.launchTx), false, self:side() == 2, self._parent.ITEM_ZORDER.EFFECT_SKILL, nil)
            --特效播放延迟
            if skill_data.launchTime ~= 0 then
                uq.delayAction(self, skill_data.launchTime, handler(self, self.launchEffectFinishCallback))
            end
        end
    end
end

function BattleSoldierGroup:attackActionFinishCallback()
    self._attackActionFinishNum = self._attackActionFinishNum + 1
    if self._attackActionFinishNum < self:getAliveSolderNum() then
        return
    end
    self:playIdle()

    local skill_data = StaticData['skill'][self._curAttackActionData.skill_id]
    if tonumber(skill_data.launchTx) == 0 then
        self:launchEffectFinishCallback() --无特效按照动作执行完毕显示
    elseif skill_data.isfull == 0 and skill_data.launchTime == 0 then
        --不是全屏特效且延迟时间为零
        self:launchEffectFinishCallback()
    end
    self:showBg(false)
end

function BattleSoldierGroup:hurtEndEffect()
    self:setHightLight(false)
end

function BattleSoldierGroup:hurtBeginEffect()
    self:setHightLight(true)
end

function BattleSoldierGroup:hurtActionFinishCallbackEnd(soldier_item)
    self._hurtActionFinishNum = self._hurtActionFinishNum - 1
    local time = self:getAnimationTime(uq.config.constant.ACTION_TYPE.ANIMATION_NAME_DEATH)
    local delay_time = time / self._parent:getSpeed()

    local disappear_time = 0.5 / self._parent:getSpeed()
    soldier_item:disappear(delay_time, disappear_time)
    uq.delayAction(self, delay_time + disappear_time, function()
        self:deadAction()
    end)
    if self._hurtActionFinishNum > 0 then
        return
    end
    self:setHP(self._curHurtActionData.hurt)
    self:playCB()
    self:showBg(false)
    if not self:isDead() then
        self:hurtEndEffect()
    end
end

function BattleSoldierGroup:hurtActionFinishCallback(soldier_item)
    --已经死亡
    if self._deadSoldier[soldier_item] then
        soldier_item:setDead(true)
        soldier_item:setHightLight(false)
        if self._attackActionData and self._attackActionData.targets[1] then
            local skill_data = StaticData['skill'][self._attackActionData.targets[1].skill_id]
            local ani_name = uq.config.constant.ACTION_TYPE.ANIMATION_NAME_DEATH_M .. soldier_item:getDir()
            --非普通技能 多方向倒地
            if skill_data and skill_data.type > 0 and soldier_item:getAnimation(ani_name) then
                soldier_item:playDieDir(handler(self, self.hurtActionFinishCallbackEnd))
            else
                soldier_item:playDie(handler(self, self.hurtActionFinishCallbackEnd))
            end
        else
            soldier_item:playDie(handler(self, self.hurtActionFinishCallbackEnd))
        end
    else
        soldier_item:playIdle()
        self._hurtActionFinishNum = self._hurtActionFinishNum - 1
        if self._hurtActionFinishNum > 0 then
            return
        end
        self:setHP(self._curHurtActionData.hurt)
        self:playCB()
        self:showBg(false)
        self:deadAction()
        if not self:isDead() then
            self:hurtEndEffect()
        end
    end
end

function BattleSoldierGroup:deadAction()
    if not self:isDead() then
        return
    end
    self:setVisible(false)
    self:hurtEndEffect()
    self:removeMoralEffect()

    for k, item in pairs(self._buffs) do
        local buff_name = 'buff' .. k .. tostring(self)
        if self._nodeBuff:getChildByName(buff_name) then
            self._nodeBuff:getChildByName(buff_name):removeSelf()
        end
    end
end

function BattleSoldierGroup:removeMoralEffect()
    local moral_name = 'moral_effect' .. tostring(self)
    if self._parent:getChildByName(moral_name) then
        self._parent:getChildByName(moral_name):removeSelf()
    end
end

function BattleSoldierGroup:playHurt(attack_action_data, cur_action_data, finish_cb)
    if self._jumpAction then
        return
    end
    self:showBg(true)
    self:hurtBeginEffect()
    self._attackActionData = attack_action_data
    self._actionFinishCallback = finish_cb

    --死亡直接结束
    if self:isDead() then
        self:playCB()
        return
    end

    self._curHurtActionData = cur_action_data

    if self:getAliveSolderNum() == 0 then
        self:playCB()
        return
    end
    if attack_action_data and self:existFullEffect(attack_action_data.targets[1]) then
        self:playSkillEffect(attack_action_data.targets[1], handler(self, self.playHurtDelay))
    else
        self:playHurtDelay()
        if attack_action_data then
            self:playSkillEffect(attack_action_data.targets[1])
        end
    end
end

function BattleSoldierGroup:playHurtDelay()
    self._deadSoldier = self:getDeadSoldier(self._curHP - self._curHurtActionData.hurt)
    self._hurtActionFinishNum = 0
    for k, item in ipairs(self._soldiers) do
        if not item:isDead() then
            self._hurtActionFinishNum = self._hurtActionFinishNum + 1
            local colum_num = (item:getParent().pos_index - 1) % 3
            colum_num = self:side() == 1 and 3 - colum_num or colum_num
            uq.delayAction(self, colum_num * 0, function() item:playHurt(handler(self, self.hurtActionFinishCallback)) end)
        end
    end
    self:popHP(-self._curHurtActionData.hurt)
end

--是否存在全屏特效
function BattleSoldierGroup:existFullEffect(attack_action_data)
    local skill_data = StaticData['skill'][attack_action_data.skill_id]
    if not skill_data or #skill_data.Effect == 0 then
        return false
    end
    for k, item in ipairs(skill_data.Effect) do
        if item.isfull > 0 then
            return true
        end
    end
    return false
end

--受击效果
function BattleSoldierGroup:playSkillEffect(attack_action_data, callback, is_ready_effect)
    self._isReadyEffect = is_ready_effect
    if is_ready_effect == nil then
        self._isReadyEffect = false
    end
    local skill_data = StaticData['skill'][attack_action_data.skill_id]
    if not skill_data or #skill_data.Effect == 0 then
        if callback then
            callback()
        end
        return
    end
    skill_data.attack_pos = attack_action_data.pos
    self:playSkillEffectItem(skill_data, 1, callback)
end
--分段播放受击特效
function BattleSoldierGroup:playSkillEffectItem(skill_data, effect_index, callback)
    local effect_item = skill_data.Effect[effect_index]
    if not effect_item then
        if callback then
            callback()
        end
        return
    end
    local function playEnd()
        effect_index = effect_index + 1
        self:playSkillEffectItem(skill_data, effect_index, callback)
    end
    if effect_item.isfull > 0 then
        if not self._isReadyEffect then
            self:playFullScreenSkillEffect(effect_item, playEnd)
        end
    else
        if effect_item.effectTx > 0 then
            if not self._isReadyEffect then
                if effect_item.isshot == 1 then
                    local node_effect = self:addEffectFly(effect_item.effectTx, false, self:side() == 2, self._parent.ITEM_ZORDER.EFFECT_SKILL, nil, nil, skill_data.attack_pos)
                    uq.shakeScreenByEffectFrame(self._parent, effect_item, cc.p(display.width / 2, display.height / 2), node_effect)
                else
                    local node_effect = self:addEffect(effect_item.effectTx, false, self:side() == 2, self._parent.ITEM_ZORDER.EFFECT_SKILL, nil)
                    uq.shakeScreenByEffectFrame(self._parent, effect_item, cc.p(display.width / 2, display.height / 2), node_effect)
                end
            else
                self:addEffect(effect_item.effectTx * 10, false, self:side() == 2, self._parent.ITEM_ZORDER.EFFECT_SKILL, nil)
            end
        end
        uq.delayAction(self, effect_item.effectDelay, playEnd)
    end
end

function BattleSoldierGroup:playFullScreenSkillEffect(effct_data, end_call)
    local flip = self:side() == 2 and -1 or 1
    local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.FULL_SCREEN_SKILL_EFFECT, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
    panel:setFinishCallback(end_call)
    panel:playSkill(effct_data, flip)
    panel:setScaleX(flip)
end

function BattleSoldierGroup:setMoral(v)
    self._curMoral = v
    self:updateMoral()
end

function BattleSoldierGroup:addMoral(v, pop, attack_action_data, finish_cb)
    self._curMoral = self._curMoral + v
    self._curMoral = self._curMoral > self._maxMoral and self._maxMoral or self._curMoral
    self._curMoral = self._curMoral < 0 and 0 or self._curMoral
    self:updateMoral()

    if pop then
        uq.BattleRule:popText(self._nodeFlyHp, uq.BattleRule.POP_TEXT.moral, v)
        if attack_action_data then
            self:playSkillEffect(attack_action_data.targets[1], finish_cb)
        else
            if finish_cb then
                finish_cb()
            end
        end
    else
        if finish_cb then
            finish_cb()
        end
    end
end

function BattleSoldierGroup:addBuff(attack_data, buff_data)
    local buff_xml = StaticData['buff'][buff_data.type]
    if not buff_xml then
        return
    end

    local buff_name = 'buff' .. buff_data.type .. tostring(self)
    local buff_effect = self._nodeBuff:getChildByName(buff_name)

    if buff_effect then
        if buff_data.state > 0 then
            return
        end
        buff_effect:removeSelf()
        self._buffs[buff_data.type] = 0
    else
        if buff_data.state == 0 then
            return
        end
        buff_effect = self:addEffectSelf(buff_xml.buffIcon, true, false, self._parent.ITEM_ZORDER.EFFECT_BUFF, buff_name, nil, self._nodeBuff)
        if not buff_effect then
            return
        end
        self._buffs[buff_data.type] = buff_data.state
    end
end

function BattleSoldierGroup:updateMoral()
    local moral = self._curMoral > self._maxMoral and self._maxMoral or self._curMoral

    if self._soliderInfo then
        self._soliderInfo:updateMoral(self._curMoral, self._maxMoral)
    end
    self._nodeLittle:getChildByName('Panel_3'):setContentSize(cc.size(60 * self._curMoral / self.MAX_MORAL, 20))
    --士气满添加士气特效
    local moral_name = 'moral_effect' .. tostring(self)
    if self._curMoral >= self._maxMoral and not self:isDead() then
        if not self._parent:getChildByName(moral_name) then
            self:addEffect(400094, true, false, self._parent.ITEM_ZORDER.EFFECT_BUFF, moral_name)
        end
    else
        if self._parent:getChildByName(moral_name) then
            self._parent:getChildByName(moral_name):removeSelf()
        end
    end
end

function BattleSoldierGroup:setHP(v)
    self._curHP = self._curHP - v
    if self._curHP < 0 then
        self._curHP = 0
    end
    self:updateHP()
end

function BattleSoldierGroup:popHP(v)
    uq.BattleRule:popText(self._nodeFlyHp, uq.BattleRule.POP_TEXT.blood, v)
end

function BattleSoldierGroup:updateHP()
    local soldiers = self._nodeSolders
    self._nodeLittle:getChildByName('hp'):setPercent(self._curHP * 100 / self._maxHP)

    local hp = self._curHP > self._maxHP and self._maxHP or self._curHP

    if self._soliderInfo then
        self._soliderInfo:updateHP(self._curHP, self._maxHP)
    end
    self._nodeLittle:getChildByName('Text_1'):setString(self._curHP .. '/' .. self._maxHP)
end

function BattleSoldierGroup:getDeadSoldier(hp)
    if hp < 0 then
        hp = 0
    end
    if hp > self._maxHP then
        hp = self._maxHP
    end

    local order = {}
    if self._side == 1 then
        order = {9,8,7,6,4,5,3,2,1}
    else
        order = {7,6,9,8,2,5,3,4,1}
    end
    local max_id = math.ceil(hp * #self._soldierNum / self._maxHP)
    local dead_num = #self._soldierNum - max_id
    local dead_soldier = {}
    local num = 1
    for k, index in ipairs(order) do
        local node_soldier = self._nodeSolders:getChildByName(index):getChildByName('soldier')
        if node_soldier and num <= dead_num then
            if not node_soldier:isDead() then
                dead_soldier[node_soldier] = 1
            end
            num = num + 1
        end
    end
    return dead_soldier
end

function BattleSoldierGroup:isDead()
    return self._curHP <= 0
end

function BattleSoldierGroup:getRoot()
    return self._root
end

function BattleSoldierGroup:playCB()
    for k, item in ipairs(self._soldiers) do
        if not item:isDead() then
            item:playIdle()
        end
    end
    if self._actionFinishCallback then
        local cb = self._actionFinishCallback
        self._actionFinishCallback = nil
        cb(self)
    end
end

function BattleSoldierGroup:pos()
    return self._data.pos
end

function BattleSoldierGroup:side()
    return self._side
end

function BattleSoldierGroup:dispose()
end

function BattleSoldierGroup:setJumpAction(flag)
    self._jumpAction = true
end

function BattleSoldierGroup:setSpeed(speed)
    for k, item in ipairs(self._soldiers) do
        item:setSpeed(speed)
    end
end

function BattleSoldierGroup:setDefaultSpeed(speed)
    for k, item in ipairs(self._soldiers) do
        item:setDefaultSpeed(speed)
    end
end

function BattleSoldierGroup:onExit()
    BattleSoldierGroup.super:onExit()
end

function BattleSoldierGroup:setLittleVisible(flag)
    self._nodeLittle:setVisible(flag)
end

--(-112, 145)
function BattleSoldierGroup:onPanelTouch(event)
    if event.name == "began" then
        self._littleVisible = self._nodeLittle:isVisible()
        self._soliderInfo = uq.createPanelOnly('battle.BattleSoldierInfo')
        self._parent:addChild(self._soliderInfo)
        self._soliderInfo:setData(self._data)
        self._soliderInfo:updateMoral(self._curMoral, self._maxMoral)
        self._soliderInfo:updateHP(self._curHP, self._maxHP)
        self._soliderInfo:setBuff(self._buffs)
        self._soliderInfo:setLocalZOrder(self._parent.ITEM_ZORDER.SOLDIER_INFO)
        self:setLittleVisible(false)

        if self:side() == 1 then
            local node_pos = self._soliderInfo:getParent():convertToNodeSpace(cc.p(162.5, display.height / 2 + 130))
            self._soliderInfo:setPosition(node_pos)
        else
            local node_pos = self._soliderInfo:getParent():convertToNodeSpace(cc.p(display.width - 160, display.height / 2 - 130))
            self._soliderInfo:setPosition(node_pos)
        end

    elseif event.name == "ended" or event.name == "cancelled" then
        self:setLittleVisible(self._littleVisible)
        self._soliderInfo:removeSelf()
        self._soliderInfo = nil
    end
end

function BattleSoldierGroup:getAnimationTime(name)
    return self._soldiers[1]:getAnimationTime(name)
end

function BattleSoldierGroup:getCenterPos()
    local node_soldier = self._nodeSolders:getChildByName('1')
    local x, y = node_soldier:getPosition()
    local world_pos = self._nodeSolders:convertToWorldSpace(cc.p(x, y))
    return self._parent:convertToNodeSpace(world_pos)
end

function BattleSoldierGroup:addEffectFly(effect_id, repeated, flip, zorder, name, callback, attack_pos)
    local effect_data = StaticData['effect'][effect_id]
    if not effect_data then
        return
    end
    local pos = self:getCenterPos()
    local index = flip and -1 or 1
    local end_pos = cc.p(pos.x + tonumber(effect_data.X1) * index, pos.y + tonumber(effect_data.Y1))

    local attack_side = self:side() == 1 and 2 or 1
    local attacker = self._parent:getObject(attack_side, attack_pos)
    if not attacker then
        return
    end
    local attacker_pos = attacker:getCenterPos()
    local start_pos = cc.p(attacker_pos.x + tonumber(effect_data.X1) * -index, attacker_pos.y + tonumber(effect_data.Y1))

    local node_effect = uq.createPanelOnly('common.EffectNode')
    self._parent:addChild(node_effect)
    node_effect:playEffectFly(effect_id, repeated, callback, 1, start_pos, end_pos)
    node_effect:getSprite():setFlippedX(attack_side == 2)
    node_effect:setLocalZOrder(zorder)
    node_effect:setPosition(start_pos)
    local move_action = cc.MoveTo:create(0.2 / uq.cache.instance._speed, end_pos)
    node_effect:runAction(move_action)

    if name then
        node_effect:setName(name)
    end
    node_effect:setScale(effect_data.scale)
    return node_effect
end

function BattleSoldierGroup:addEffect(effect_id, repeated, flip, zorder, name, callback)
    local effect_data = StaticData['effect'][effect_id]
    if not effect_data then
        return
    end

    local node_effect = uq.createPanelOnly('common.EffectNode')
    self._parent:addChild(node_effect)
    local ret = node_effect:playEffectNormal(effect_id, repeated, callback)
    if not ret then
        return nil
    end
    node_effect:getSprite():setFlippedX(flip)
    node_effect:setLocalZOrder(zorder)

    local pos = self:getCenterPos()
    local index = flip and -1 or 1
    node_effect:setPosition(cc.p(pos.x + tonumber(effect_data.X1) * index, pos.y + tonumber(effect_data.Y1)))

    if name then
        node_effect:setName(name)
    end
    node_effect:setScale(effect_data.scale)
    return node_effect
end

function BattleSoldierGroup:addEffectSelf(effect_id, repeated, flip, zorder, name, callback, parent)
    local effect_data = StaticData['effect'][effect_id]
    if not effect_data then
        return
    end

    local node_effect = uq.createPanelOnly('common.EffectNode')
    parent:addChild(node_effect)
    local ret = node_effect:playEffectNormal(effect_id, repeated, callback)
    if not ret then
        return nil
    end
    node_effect:getSprite():setFlippedX(flip)
    node_effect:setLocalZOrder(zorder)

    local pos = self:getCenterPos()
    local index = flip and -1 or 1
    node_effect:setPosition(cc.p(tonumber(effect_data.X1) * index, tonumber(effect_data.Y1)))

    if name then
        node_effect:setName(name)
    end
    node_effect:setScale(effect_data.scale)
    return node_effect
end

function BattleSoldierGroup:showBg(flag)
    self._imgBg:setVisible(flag)
end

function BattleSoldierGroup:setHightLight(flag)
    for k, item in ipairs(self._soldiers) do
        item:setHightLight(flag)
    end
end

function BattleSoldierGroup:showToTop(flag)
    -- self._parent:setMaskVisible(flag)
    if flag then
        self:getParent():setLocalZOrder(self._parent.ITEM_ZORDER.SOLDIER_TOP)
    else
        self:getParent():setLocalZOrder(self._parent.ITEM_ZORDER.SOLDIER)
    end
end

return BattleSoldierGroup