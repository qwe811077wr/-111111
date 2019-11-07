local FullScreenSkillEffect = class("FullScreenSkillEffect", require('app.base.ModuleBase'))

FullScreenSkillEffect.RESOURCE_FILENAME = "battle/SkillEffect.csb"
FullScreenSkillEffect.RESOURCE_BINDING = {
    ["Panel_1"]     = {["varname"] = "_panelBg"},
}

function FullScreenSkillEffect:onCreate()
    FullScreenSkillEffect.super.onCreate(self)

    self._excuted = false
    self:setBaseBgVisible(false)
    self:centerView()

    self._flash = false
    self._timerFlag = 'skill_effect' .. tostring(self)
    uq.TimerProxy:addTimer(self._timerFlag, handler(self, self.frameCallback), 0, -1)

    self:setContentSize(display.size)
    self._panelBg:setPosition(display.center)
    self._panelBg:setContentSize(display.size)
    self._panelBg:setOpacity(0)
end

function FullScreenSkillEffect:onExit()
    if not self._excuted and self._finishCallback then
        self._finishCallback()
    end
    uq.TimerProxy:removeTimer(self._timerFlag)
    FullScreenSkillEffect.super:onExit()
end

function FullScreenSkillEffect:playSkill(skill_data, flip)
    self._skillData = skill_data

    if tonumber(skill_data.bgTx) > 0 then
        self._skillEffectBg = uq.createPanelOnly('common.EffectNode')
        self._skillEffectBg:playEffectNormal(tonumber(skill_data.bgTx), true)
        self:addChild(self._skillEffectBg)
        local effect_data = StaticData['effect'][tonumber(skill_data.bgTx)]
        self._skillEffectBg:setScale(effect_data.scale)
        uq.ShaderEffect:addSharpenEffect(self._skillEffectBg:getSprite())
    end

    self._skillEffect = uq.createPanelOnly('common.EffectNode')
    self._effectID = 0
    if skill_data.launchTx then
        self._effectID = tonumber(skill_data.launchTx)
    else
        self._effectID = tonumber(skill_data.effectTx)
    end
    self._effectData = StaticData['effect'][self._effectID]
    self._skillEffect:playEffectNormal(self._effectID, false, handler(self, self.finishCallback))
    self:addChild(self._skillEffect)
    self._skillEffect:setScale(self._effectData.scale)
    self._animateAction = self._skillEffect:getAnimateAction()

    local side = flip == 1 and 1 or 2
    self._skillEffect:setPosition(cc.p(-tonumber(self._effectData['X' .. side]), tonumber(self._effectData['Y' .. side])))

    uq.shakeScreenByEffectFrame(self, self._skillData, cc.p(display.width / 2, display.height / 2), self._skillEffect)
end

function FullScreenSkillEffect:setFinishCallback(callback)
    self._finishCallback = callback
end

function FullScreenSkillEffect:finishCallback()
    local callback = self._finishCallback
    self._excuted = true
    self:disposeSelf()
    if callback then
        callback()
    end
end

function FullScreenSkillEffect:frameCallback()
    local flash = tonumber(self._effectData.flash)
    if flash == 0 then return end

    local fram_num = self._animateAction:getCurrentFrameIndex()
    if fram_num == flash and not self._flash then
        self._flash = true
        if self._skillEffectBg then
            uq.ShaderEffect:setFlashAndChild(self._skillEffectBg:getSprite(), false, 10)
            self._skillEffectBg:setOpacity(0.65 * 255)
        end
        uq.ShaderEffect:setFlashAndChild(self._skillEffect:getSprite(), false, 1)
        self._skillEffect:setOpacity(0.65 * 255)
    elseif fram_num == flash + 1 and self._flash then
        self._flash = false
        uq.ShaderEffect:setRemoveFlashAndChild(self)
        self._skillEffect:setOpacity(255)
        if self._skillEffectBg then
            self._skillEffectBg:setOpacity(255)
        end
    end
end

return FullScreenSkillEffect