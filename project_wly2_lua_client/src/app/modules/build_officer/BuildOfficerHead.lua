local BuildOfficerHead = class("BuildOfficerHead", require('app.base.ChildViewBase'))

BuildOfficerHead.RESOURCE_FILENAME = "build_officer/BuildOfficerHead.csb"
BuildOfficerHead.RESOURCE_BINDING = {
    ["Node_3"]      = {["varname"] = "_nodeLock"},
    ["Panel_1_0"]   = {["varname"] = "_panelTouch",["events"] = {{["event"] = "touch",["method"] = "onPanelTouch",["sound_id"] = 0}}},
    ["Node_2"]      = {["varname"] = "_nodeAdd"},
    ["Node_1"]      = {["varname"] = "_nodeInfo"},
    ["Node_1_0"]    = {["varname"] = "_nodeInfoSelect"},
    ["Text_2"]      = {["varname"] = "_txtLock"},
}

function BuildOfficerHead:onCreate()
    BuildOfficerHead.super.onCreate(self)
    self._panelTouch:setSwallowTouches(false)
end

function BuildOfficerHead:onExit()
    if self._timerField then
        self._timerField:dispose()
        self._timerField = nil
    end
    BuildOfficerHead.super.onExit(self)
end

function BuildOfficerHead:setItemData(office_data, index, total_num)
    self._nodeInfo:setVisible(true)
    self._nodeInfoSelect:setVisible(false)
    self._imgFace = self._nodeInfo:getChildByName('Image_1')
    self._panelInfoBg = self._nodeInfo:getChildByName('Panel_2')
    self._txtInfo = self._panelInfoBg:getChildByName('Text_1')
    self._spriteBg = self._nodeInfo:getChildByName('s07_00000_1')
    self._panelIcon = self._nodeInfo:getChildByName('Panel_1')
    self._spriteIcon = self._panelIcon:getChildByName('Sprite_2')

    self._selectGeneralTempId = 0
    self._data = office_data
    self._index = index
    self._nodeLock:setVisible(false)
    self._nodeInfo:setVisible(false)
    self._nodeAdd:setVisible(false)
    self._txtInfo:setVisible(false)
    self._panelInfoBg:setVisible(false)

    local build_id = uq.cache.role:getBuildIdByType(office_data.castleMapType)
    local build_xml = StaticData['buildings']['CastleMap'][build_id]
    if index > total_num then
        local level = 0
        local nums = string.split(office_data.officerNums, ';')
        for i = #nums, 1, -1 do
            local strs = string.split(nums[i], ',')
            if index >= tonumber(strs[2]) then
                level = tonumber(strs[1])
                break
            end
        end
        self._txtLock:setString(string.format('%s %d' .. StaticData['local_text']['label.level2'], uq.cache.role:getFilterBuildName(build_xml.name), level))
        self._nodeLock:setVisible(true)
        return
    end

    local officer_list = uq.cache.role:getBuildOfficerData(office_data.castleMapType)
    if officer_list[index] and officer_list[index].general_id > 0 then
        self._selectGeneralTempId = uq.cache.generals:getGeneralTempId(officer_list[index].general_id)
        self._generalId = officer_list[index].general_id
        self._nodeInfo:setVisible(true)
        self:setGeneralInfo(officer_list[index].general_id)
        if officer_list[index].lock_state > 0 then --锁定状态下计时
            self:refreshCdTime()
        end
    else
        self._nodeAdd:setVisible(true)
    end
end

function BuildOfficerHead:refreshCdTime()
    self._txtInfo:setVisible(false)
    self._panelInfoBg:setVisible(false)

    local left_time = uq.cache.role:getBuildOfficerLevelUpMaxCD(self._data.castleMapType, self._generalId)
    if left_time <= 0 then
        if self._timerField then
            self._timerField:dispose()
            self._timerField = nil
        end
        return
    end

    self._txtInfo:setVisible(true)
    self._panelInfoBg:setVisible(true)

    local function timer_end()
        self:refreshCdTime()
    end

    if self._timerField then
        self._timerField:setTime(left_time)
    else
        self._timerField = uq.ui.TimerField:create(self._txtInfo, left_time, timer_end)
    end
end

function BuildOfficerHead:setSelectData(temp_id, general_id)
    self._nodeInfo:setVisible(false)
    self._nodeInfoSelect:setVisible(true)
    self._txtName = self._nodeInfoSelect:getChildByName('Text_4')
    self._imgFace = self._nodeInfoSelect:getChildByName('Image_1')
    self._panelInfoBg = self._nodeInfoSelect:getChildByName('Panel_2')
    self._txtInfo = self._panelInfoBg:getChildByName('Text_1')
    self._spriteBg = self._nodeInfoSelect:getChildByName('s07_00000_1')
    self._panelIcon = self._nodeInfoSelect:getChildByName('Panel_1')
    self._spriteIcon = self._panelIcon:getChildByName('Sprite_2')

    self._selectGeneralTempId = temp_id
    self._panelTouch:setVisible(false)
    self._nodeLock:setVisible(false)
    self._nodeAdd:setVisible(false)
    self:setGeneralInfo(general_id)

    local tire = uq.cache.generals:getGeneralTire(general_id)
    self._txtInfo:setFontSize(12)
    if tire >= StaticData['officer_level'].Info[1].unWorkTired then
        self._txtInfo:setHTMLText(string.format(StaticData['local_text']['label.buildofficer.tire'] .. " <font color='#ff390b'> %d</font>/%d", tire, StaticData['officer_level'].Info[1].maxTired))
    else
        self._txtInfo:setHTMLText(string.format(StaticData['local_text']['label.buildofficer.tire'] .. " <font color='#ffc90e'> %d</font>/%d", tire, StaticData['officer_level'].Info[1].maxTired))
    end
end

function BuildOfficerHead:setGeneralInfo(general_id)
    local temp_id = uq.cache.generals:getGeneralTempId(general_id)
    local xml_data = StaticData['general'][temp_id]
    self._spriteIcon:setTexture('img/common/general_head/' .. xml_data.icon)

    local tire_data = uq.cache.generals:getGeneralTireModeData(general_id)
    self._imgFace:loadTexture('img/build_officer/' .. tire_data.icon)

    local general_data = uq.cache.generals:getGeneralDataByID(general_id)
    local grade_info = StaticData['types'].GeneralGrade[1].Type[general_data.grade]
    local quality_info = StaticData['types'].ItemQuality[1].Type[grade_info.qualityType]
    self._spriteBg:setTexture('img/common/ui/' .. quality_info.qualityIcon)
    if self._txtName then
        self._txtName:setString(general_data.name)
        self._txtName:setTextColor(uq.parseColor(quality_info.color))
    end
end

function BuildOfficerHead:onPanelTouch(event)
    if event.name ~= 'ended' then
        return
    end

    if self._nodeLock:isVisible() then
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
        uq.fadeInfo(StaticData['local_text']['label.buildofficer.not.open'])
        return
    end

    if self._nodeInfo:isVisible() and self._txtInfo:isVisible() then
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
        uq.fadeInfo(StaticData['local_text']['label.buildofficer.procesing'])
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.BUILD_OFFICER_SELECT, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
    panel:setData(self._data, self._selectGeneralTempId, self._index)
end

return BuildOfficerHead