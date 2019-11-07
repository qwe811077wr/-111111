local SkillPop = class("SkillPop", require('app.base.ModuleBase'))

SkillPop.RESOURCE_FILENAME = "battle/SkillPop.csb"
SkillPop.RESOURCE_BINDING = {
    ["Panel_1"]   = {["varname"] = "_panelMask"},
    ["Panel_1_0"] = {["varname"] = "_panelClip"},
    ["img_skill"] = {["varname"] = "_imgSkill"},
    ["Text_1"]    = {["varname"] = "_txtSkillName"},
}

function SkillPop:onCreate()
    SkillPop.super.onCreate(self)

    self:setBaseBgVisible(false)
    self:centerView()

    self:setContentSize(display.size)
    self._panelMask:setPosition(display.center)
    self._panelMask:setContentSize(display.size)
    self._panelClip:setPosition(display.center)
    self._panelClip:setContentSize(cc.size(display.width, CC_DESIGN_RESOLUTION.height))
end

function SkillPop:onExit()
    uq.TimerProxy:removeTimer(self._timerFlag)
    SkillPop.super:onExit()
end

function SkillPop:setData(side, callback, data, skill_data)
    local general_config = StaticData['general'][data.id]
    self._callback = callback
    self._txtSkillName:setString(skill_data.name)
    self._txtSkillName:setScale(2.5)
    self._imgSkill:setOpacity(0)
    self._txtSkillName:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.ScaleTo:create(0.3, 1)))
    self._imgSkill:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.FadeIn:create(0.3)))
    local anim_id = general_config.imageId
    local pre_path = "animation/spine/" .. anim_id .. '/' .. anim_id
    local size = self._panelClip:getContentSize()
    local role_node = nil
    if cc.FileUtils:getInstance():isFileExist(pre_path .. '.skel') then
        local anim = sp.SkeletonAnimation:createWithBinaryFile(pre_path .. '.skel', pre_path .. '.atlas', 1)
        self._panelClip:addChild(anim)
        anim:setScale(general_config.imageRatio)
        if side == 1 then
            anim:setPosition(cc.p(general_config.imageX - 300, general_config.imageY - 150))
        else
            anim:setPosition(cc.p(display.width - general_config.imageX + 400, general_config.imageY - 150))
        end
        -- anim:setAnimation(0, 'idle', true)
        role_node = anim
    else
        local img = ccui.ImageView:create(pre_path .. '.png')
        self._panelClip:addChild(img)
        img:setAnchorPoint(cc.p(0.5, 1))
        -- img:setScale(general_config.imageRatio)
        if side == 1 then
            img:setPosition(cc.p(general_config.imageX, general_config.imageY + 500))
        else
            img:setPosition(cc.p(display.width - general_config.imageX + 250, general_config.imageY + 500))
        end
        role_node = img
    end
    if side == 1 then
        self._imgSkill:setPosition(cc.p(352, 258))
    else
        self._imgSkill:setPosition(cc.p(display.width - 352, 258))
    end

    local by_x = side == 1 and 50 or -50
    role_node:runAction(cc.Sequence:create(cc.MoveBy:create(1, cc.p(by_x, 0)), cc.CallFunc:create(function()
        self:endCall()
    end)))
    self._imgSkill:runAction(cc.MoveBy:create(1, cc.p(by_x, 0)))
end

function SkillPop:endCall()
    local callback = self._callback

    self:disposeSelf()

    if callback then
        callback()
    end
end

return SkillPop