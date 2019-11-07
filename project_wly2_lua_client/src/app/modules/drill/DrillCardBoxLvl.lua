local DrillCardBoxLvl = class("DrillCardBoxLvl", require('app.base.ChildViewBase'))

DrillCardBoxLvl.RESOURCE_FILENAME = "drill/DrillCardBoxSkill.csb"
DrillCardBoxLvl.RESOURCE_BINDING  = {
    ["Node_1"]                                 = {["varname"] = "_nodeBase"},
    ["tips_txt_1"]                             = {["varname"] = "_txtLvl"},
    ["icon_spr"]                               = {["varname"] = "_imgSoldier"},
    ["Node_7"]                                 = {["varname"] = "_nodeSoldier"},
    ["Text_7"]                                 = {["varname"] = "_txtTitle"},
    ["bg_1_img"]                               = {["varname"] = "_imgSelect"},
    ["Image_6"]                                = {["varname"] = "_imgRed"},
    ["bg_2_img"]                               = {["varname"] = "_imgNormal", ["events"] = {{["event"] = "touch", ["method"] = "_onSelected",["sound_id"] = 0}}},
}

function DrillCardBoxLvl:ctor(name, params)
    DrillCardBoxLvl.super.ctor(self, name, params)
    self:parseView()
    self._nodeSoldier:setVisible(false)
    self._imgNormal:setTouchEnabled(true)
end

function DrillCardBoxLvl:setInfo(info)
    self._info = info
    if not self._info then
        return
    end
    self:refreshPage()
    self:updateLvl()
    self:refreshRed()
end

function DrillCardBoxLvl:refreshPage()
    self._nodeSoldier:removeAllChildren()
    local group = uq.AnimationManager:getInstance():getAction('idle', self._info.effect)
    local animation = require('app/modules/battle/ObjectAnimation'):create(self._nodeSoldier, group)
    animation:play(uq.config.constant.ACTION_TYPE.ANIMATION_NAME_IDLE, true)
    self._imgSoldier:setTexture("img/common/soldier/" .. self._info.icon)
    self._txtTitle:setString(self._info.skillTitle)
end

function DrillCardBoxLvl:refreshRed()
    self._imgRed:setVisible(uq.cache.drill:checkDrillSoldierCouldLvl(self._info.ident))
end

function DrillCardBoxLvl:updateLvl()
    local info = uq.cache.drill:getDrillInfoById(self._info.ident)
    self._txtLvl:setString(info.level)
end

function DrillCardBoxLvl:setCallBack(callback)
    self._callback = callback
end

function DrillCardBoxLvl:_onSelected(event)
    if event.name ~= "ended" or self._imgSelect:isVisible() then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.CHANGE)
    if self._callback then
        self._callback(self._info.ident)
    end
    self:setImgSelectedState(true)
end

function DrillCardBoxLvl:setImgSelectedState(visible)
    self._imgSelect:setVisible(visible)
    self._imgSoldier:setVisible(not visible)
    self._nodeSoldier:setVisible(visible)
end

function DrillCardBoxLvl:getItemContentSize()
    return self._imgSelect:getContentSize()
end

function DrillCardBoxLvl:showAction()
    uq.intoAction(self._view)
end

function DrillCardBoxLvl:onExit()
    DrillCardBoxLvl.super.onExit(self)
end

return DrillCardBoxLvl