local DrillDiffcultyBox = class("DrillDiffcultyBox", require('app.base.ChildViewBase'))
local EquipItem = require("app.modules.common.EquipItem")

DrillDiffcultyBox.RESOURCE_FILENAME = "drill/DifficultyBoxs.csb"
DrillDiffcultyBox.RESOURCE_BINDING  = {
    ["Node_2"]                                 = {["varname"] = "_nodeBase"},
    ["Panel_2"]                                = {["varname"] = "_panelGeneral"},
    ["Image_3"]                                = {["varname"] = "_imgBg"},
    ["Node_1"]                                 = {["varname"] = "_nodeReward"},
    ["Panel_3"]                                = {["varname"] = "_panelLocked"},
    ["img_lock"]                               = {["varname"] = "_imgLocked"},
    ["Text_1"]                                 = {["varname"] = "_txtLocked"},
    ["exp_limit"]                              = {["varname"] = "_txtLevelLimt"},
    ["boss"]                                   = {["varname"] = "_txtBossName"},
    ["title_txt"]                              = {["varname"] = "_txtTitle"},
    ["icon_spr"]                               = {["varname"] = "_imgHead"},
    ["Button_1_0"]                             = {["varname"] = "_btnContinue", ["events"] = {{["event"] = "touch",["method"] = "onBtnContinue"}}},
    ["Button_1"]                               = {["varname"] = "_btnOk", ["events"] = {{["event"] = "touch",["method"] = "onBtnOk"}}},
}

function DrillDiffcultyBox:ctor(name, params)
    DrillDiffcultyBox.super.ctor(self, name, params)
    self:parseView()
    self:initPage()
end

function DrillDiffcultyBox:setInfo(info, index)
    self._info = info
    self._curIndex = index
    if not self._info then
        return
    end
    self:refreshPage()
    self:refreshBtnState()
end

function DrillDiffcultyBox:initPage()
    self._tabItem = {}
    self._scale = 0.7
    for i = 1, 3 do
        local item = EquipItem:create()
        item:setScale(self._scale)
        item:setTouchEnabled(true)
        item:addClickEventListenerWithSound(function(sender)
            local info = sender:getEquipInfo()
            uq.showItemTips(info)
        end)
        table.insert(self._tabItem, item)
        self._nodeReward:addChild(item)
    end
end

function DrillDiffcultyBox:refreshBtnState(id, cur_mode)
    if not self._btnContinue:isVisible() and not self._btnOk:isVisible() then
        return
    end
    id = id or uq.cache.drill:getDrillIdOperation()
    self._btnOk:setEnabled(id == 0)
    if id == 0 then
        self._btnOk:setVisible(true)
        self._btnOk:setEnabled(true)
        self._btnContinue:setVisible(false)
        return
    end
    cur_mode = cur_mode or uq.cache.drill:getDrillInfoById(id).cur_mode
    local state = cur_mode == self._info.ident
    self._btnOk:setVisible(not state)
    self._btnContinue:setVisible(state)
end

function DrillDiffcultyBox:refreshOpenState()
    local lock_state = self._info.levelLimit > uq.cache.role:level()
    local info = uq.cache.drill:getDrillInfoById(self._curIndex)
    local max_mode = info.mode + 1
    local open_state = max_mode >= self._info.ident
    self._imgLocked:setVisible(lock_state)
    self._panelLocked:setVisible(lock_state or not open_state)
    self._txtLocked:setVisible(not open_state and not lock_state)
    self._txtLevelLimt:setVisible(lock_state)
    self._txtLevelLimt:setString(string.format(StaticData['local_text']['drill.need.lv'], self._info.levelLimit))
    self._btnContinue:setVisible(not lock_state and open_state)
    self._btnOk:setVisible(not lock_state and open_state)
end

function DrillDiffcultyBox:refreshPage()
    self._txtTitle:setString(self._info.title)
    self:refreshOpenState()

    local troop_array = string.split(self._info.troopId, ',')
    local index = #troop_array
    local troop_info = StaticData['drill_ground'].Troop[tonumber(troop_array[index])]
    if not troop_info then
        return
    end
    self._txtBossName:setString(troop_info.name)
    local generals = StaticData['general'][troop_info.generalId] or {}
    if generals and generals.miniIcon then
        self._imgHead:setTexture("img/common/general_head/" .. generals.miniIcon)
    end


    local rewards = uq.RewardType.parseRewards(self._info.previewRwd)
    local size = self._tabItem[1]:getContentSize()
    local delta = -(size.width * self._scale * (#rewards - 1)) / 2
    for i = 1, 3 do
        self._tabItem[i]:setVisible(rewards[i] ~= nil)
        if not rewards[i] then
            break
        end
        self._tabItem[i]:setInfo(rewards[i]:toEquipWidget())
        self._tabItem[i]:setPositionX(delta)
        delta = delta + size.width * self._scale
    end
end

function DrillDiffcultyBox:onBtnContinue(event)
    if event.name ~= "ended" then
        return
    end
    local data = {
        xml_data = uq.cache.drill:getDrillXmlById(self._curIndex),
        cur_mode = self._info.ident
    }
    uq.ModuleManager:getInstance():show(uq.ModuleManager.DRILL_CARD, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, data = data})
end

function DrillDiffcultyBox:onBtnOk(event)
    if event.name ~= "ended" then
        return
    end
    if uq.cache.drill:getFinishTimes() >= StaticData['drill_ground'].Info[1].times then
        uq.fadeInfo(StaticData['local_text']['daily.instance.des12'])
        return
    end
    network:sendPacket(Protocol.C_2_S_DRILL_GROUND_ENTER, {id = self._curIndex, mode = self._info.ident})
end

function DrillDiffcultyBox:getItemContentSize()
    return self._imgBg:getContentSize()
end

function DrillDiffcultyBox:showAction()
    uq.intoAction(self._nodeBase)
end

return DrillDiffcultyBox