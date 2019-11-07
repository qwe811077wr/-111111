local ArmyItem = class("ArmyItem", require("app.base.ChildViewBase"))

ArmyItem.RESOURCE_FILENAME = "generals/ArmsItem.csb"
ArmyItem.RESOURCE_BINDING = {
    ["Panel_1"]           = {["varname"] = "_panelBase"},
    ["img_select1"]       = {["varname"] = "_imgChoosed"},
    ["img_select2"]       = {["varname"] = "_imgSelected"},
    ["img_icon1"]         = {["varname"] = "_imgIcon"},
    ["label_name1"]       = {["varname"] = "_txtName"},
    ["btn_select1"]       = {["varname"] = "_btnChoose", ["events"] = {{["event"] = "touch", ["method"] = "_onTouchChoose"}}},
    ["Panel_3"]           = {["varname"] = "_panelGrey"},
    ["Image_3"]           = {["varname"] = "_imgLocked"},
    ["Node_1"]            = {["varname"] = "_nodeEffect"},
    ["Text_2"]            = {["varname"] = "_txtState"},
    ["Image_22"]          = {["varname"] = "_imgSoldierType"},
}

function ArmyItem:ctor(name, params)
    ArmyItem.super.ctor(self, name, params)
end

function ArmyItem:onCreate()
    ArmyItem.super.onCreate(self)
    self:parseView()
    self._action = nil
end

function ArmyItem:setData(data, play_anim)
    if not data then
        return
    end
    self._info = data
    if play_anim then
        self:refreshAnimItem()
    else
        self:refreshItem()
    end
end

function ArmyItem:_onTouchChoose(event)
    if event.name ~= "ended" then
        return
    end
    network:sendPacket(Protocol.C_2_S_GENARAL_SET_BATTLE_SOLDIER, {general_id = self._info.general_id, soldier_id = self._info.id})
end

function ArmyItem:setImgSoldierTypeVisible(visible)
    self._imgSoldierType:setVisible(visible)
    if not visible then
        return
    end
    local soldier_xml = StaticData['soldier'][self._info.id]
    if not soldier_xml then
        return
    end
    local type_info = StaticData['types'].Soldier[1].Type[soldier_xml.type]
    if not type_info then
        return
    end
    self._imgSoldierType:loadTexture("img/generals/" .. type_info.miniIcon2)
end

function ArmyItem:refreshAnimItem()
    local soldier_xml = StaticData['soldier'][self._info.id]
    if soldier_xml == nil then
        return
    end
    self._nodeEffect:removeAllChildren()
    self._imgIcon:setVisible(false)
    self._txtName:setString(soldier_xml.name)
    self._action = soldier_xml.idleAction
    local group1 = uq.AnimationManager:getInstance():getAction('idle', self._action)
    self._animation1 = require('app/modules/battle/ObjectAnimation'):create(self._nodeEffect, group1)
    self._animation1:play(uq.config.constant.ACTION_TYPE.ANIMATION_NAME_IDLE, true)
    self._animation1:setScale(0.7)
end

function ArmyItem:refreshItem()
    local soldier_xml = StaticData['soldier'][self._info.id]
    if soldier_xml == nil then
        return
    end
    local general_info = uq.cache.generals:getGeneralDataByID(self._info.general_id)
    self._txtName:setString(soldier_xml.name)
    self._imgIcon:loadTexture("img/common/soldier/" .. soldier_xml.file)
    self._panelGrey:setVisible(self._info.id ~= general_info.soldierId1 and self._info.id ~= general_info.soldierId2)
    self._btnChoose:setVisible(self._info.id ~= general_info.battle_soldier_id and (self._info.id == general_info.soldierId1 or self._info.id == general_info.soldierId2))
    self._imgChoosed:setVisible(self._info.id == general_info.battle_soldier_id)
    local state = self._info.level > self._info.cur_level
    if state then
        self._txtState:setString(string.format(StaticData['local_text']['soldier.level.can.get'], self._info.level + 1))
    else
        self._txtState:setString(StaticData['local_text']['general.soldier.rebuild.get'])
    end
end

function ArmyItem:setSelectedImgVisible(visible)
    self._imgSelected:setVisible(visible)
end

function ArmyItem:getSelectedImgVisible()
    return self._imgSelected:isVisible()
end

function ArmyItem:onExit()
    if self._action then
        uq.AnimationManager:getInstance():dispose('idle', self._action)
    end
    ArmyItem.super.onExit(self)
end

function ArmyItem:setSwallowTouch(visible)
    self._panelBase:setTouchEnabled(true)
    self._panelBase:setSwallowTouches(visible)
    self._panelGrey:setSwallowTouches(visible)
end

function ArmyItem:getSoldierId()
    return self._info.id
end

return ArmyItem