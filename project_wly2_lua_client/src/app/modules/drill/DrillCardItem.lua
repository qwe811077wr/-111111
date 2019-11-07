local DrillCardItem = class("DrillCardItem", require('app.base.ChildViewBase'))

DrillCardItem.RESOURCE_FILENAME = "drill/DrillCardItems.csb"
DrillCardItem.RESOURCE_BINDING  = {
    ["bg_1_img"]                               = {["varname"] = "_imgBlight"},
    ["bg_2_img"]                               = {["varname"] = "_imgDark"},
    ["Sprite_1"]                               = {["varname"] = "_imgNormalBg"},
    ["lv_txt"]                                 = {["varname"] = "_txtIndex"},
    ["name_txt"]                               = {["varname"] = "_txtBoss"},
    ["box_2_img"]                              = {["varname"] = "_imgBoxOpen"},
    ["box_1_img"]                              = {["varname"] = "_imgBox", ["events"] = {{["event"] = "touch",["method"] = "onOpenBox"}}},
    ["icon_spr"]                               = {["varname"] = "_imgIcon"},
    ["select_img"]                             = {["varname"] = "_imgSelected", ["events"] = {{["event"] = "touch",["method"] = "onBattle"}}},
    ["Panel_4"]                                = {["varname"] = "_panelOver"},
    ["Image_1"]                                = {["varname"] = "_imgBoss"},
    ["Image_20"]                               = {["varname"] = "_imgCurIndex"},
    ["Sprite_1_0"]                             = {["varname"] = "_imgBossBg"},
    ["Node_2"]                                 = {["varname"] = "_nodeEffect"},
}

function DrillCardItem:ctor(name, params)
    DrillCardItem.super.ctor(self, name, params)
    self._imgSelected:setTouchEnabled(true)
    self._imgBox:setTouchEnabled(true)
end

function DrillCardItem:setInfo(info)
    self._info = info
    if not self._info then
        return
    end
    self:initPage()
end

function DrillCardItem:initPage()
    self._troopInfo = StaticData['drill_ground'].Troop[tonumber(self._info.troop_id)]
    self._txtBoss:setString(self._troopInfo.name)
    self._txtIndex:setString(self._info.index)
    self._imgBoss:setVisible(self._info.is_last)
    self._imgBossBg:setVisible(self._info.is_last)
    self._imgNormalBg:setVisible(not self._info.is_last)
    self._imgBoxOpen:setVisible(false)
    local generals = StaticData['general'][self._troopInfo.generalId] or {}
    if generals and generals.miniIcon then
        self._imgIcon:setTexture("img/common/general_head/" .. generals.miniIcon)
    end
end

function DrillCardItem:refreshPage(index, reward_index)
    self._rewardIndex = reward_index
    self._nowIndex = index
    self:setImgSelectedState(index == self._info.index)
    if self._info.index < index then
        self._panelOver:setVisible(true)
    end
    self._imgBoxOpen:setVisible(self._info.index < index and self._info.index < reward_index)
    local opacity = self._info.index >= index and 255 or 0
    self._imgBox:setOpacity(opacity)
    self._nodeEffect:removeAllChildren()
    if self._rewardIndex < self._nowIndex and self._rewardIndex == self._info.index then
        local size = self._imgBox:getContentSize()
        uq:addEffectByNode(self._nodeEffect, 900129, -1, true)
    end
end

function DrillCardItem:onBattle(event)
    if event.name ~= "ended" then
        return
    end
    local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.DRILL_CARD)
    if panel then
        panel:showEmbattle()
    end
end

function DrillCardItem:onOpenBox(event)
    if event.name == "began" then
        local scale = self._imgBox:getScale()
        self._imgBox:setScale(scale * 1.1)
    elseif event.name ~= "moved" then
        local scale = self._imgBox:getScale()
        self._imgBox:setScale(scale / 1.1)
    end
    if event.name ~= "ended" then
        return
    end

    if self._info.index < self._rewardIndex then
        return
    end

    if self._info.index >= self._nowIndex then
        uq.fadeInfo(StaticData["local_text"]["drill.less.card"])
        return
    end

    local data = {
        id = self._troopInfo.ident,
        is_last = self._info.is_last,
        reward = self._troopInfo.drop,
    }
    uq.ModuleManager:getInstance():show(uq.ModuleManager.DRILL_OPEN_BOXS, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, data = data})
end

function DrillCardItem:setImgSelectedState(visible)
    self._imgSelected:setVisible(visible)
    self._imgBlight:setVisible(visible)
    self._imgDark:setVisible(not visible)
    self._imgCurIndex:setVisible(visible)
    self._imgCurIndex:stopAllActions()
    if not visible then
        return
    end
    local action = cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(0, 10)), cc.MoveBy:create(0.5, cc.p(0, -10))))
    self._imgCurIndex:runAction(action)
end

return DrillCardItem