local BuildOfficerSelectItem = class("BuildOfficerSelectItem", require('app.base.ChildViewBase'))

BuildOfficerSelectItem.RESOURCE_FILENAME = "build_officer/BuildOfficerSelectItem.csb"
BuildOfficerSelectItem.RESOURCE_BINDING = {
    ["Node_1"]   = {["varname"] = "_nodeHead"},
    ["Image_2"]  = {["varname"] = "_imgProcesing"},
    ["Text_2"]   = {["varname"] = "_txtBtnDesc"},
    ["Button_1"] = {["varname"] = "_btnClick",["events"] = {{["event"] = "touch",["method"] = "onBtnClick"}}},
    ["Panel_22"] = {["varname"] = "_panelClick",["events"] = {{["event"] = "touch",["method"] = "onBtnClick"}}}
}

function BuildOfficerSelectItem:onCreate()
    BuildOfficerSelectItem.super.onCreate(self)

    for i = 1, 7 do
        self['type_' .. i] = self:getResourceNode():getChildByName('type_' .. i)
        self['add_' .. i] = self:getResourceNode():getChildByName('add_' .. i)
    end
end

function BuildOfficerSelectItem:setData(data, select_general_temp_id, build_data, pos_index, select_call)
    self._data = data
    self._selectGeneralTempId = select_general_temp_id
    self._buildData = build_data
    self._posIndex = pos_index
    self._selectCallback = select_call
    if not self._head then
        self._head = uq.createPanelOnly('build_officer.BuildOfficerHead')
        self._nodeHead:addChild(self._head)
    end
    self._head:setSelectData(self._data.temp_id, self._data.id)

    self:refreshPage()
end

function BuildOfficerSelectItem:onExit()
    if self._timerField then
        self._timerField:dispose()
        self._timerField = nil
    end
    BuildOfficerSelectItem.super.onExit(self)
end

function BuildOfficerSelectItem:refreshValue()
    local values = nil
    if uq.cache.role.switch_property then
        values = uq.cache.generals:getGeneralBuildOfficerPropertyAdd(self._data.id)
    else
        values = uq.cache.generals:getGeneralBuildOfficerLevelAdd(self._data.id)
    end
    for i = 1, 7 do
        if uq.cache.role.switch_property then
            self['type_' .. i]:setString(values[i][1])
            self['add_' .. i]:setString(string.format('(+%s)', tostring(values[i][2])))
        else
            self['type_' .. i]:setString(string.format('LV.%d', values[i][1]))

            local xml_data = StaticData['officer_level'].OfficerLevel[values[i][1]]
            local per = values[i][2] / xml_data.proficiency
            self['add_' .. i]:setString(string.format('(%.1f%%)', tostring(per * 100)))
        end

        if i == self._buildData.officerAttrType then
            self['type_' .. i]:setTextColor(uq.parseColor('#56ff49'))
            self['add_' .. i]:setTextColor(uq.parseColor('#56ff49'))
        else
            self['type_' .. i]:setTextColor(uq.parseColor('#FFFFFF'))
            self['add_' .. i]:setTextColor(uq.parseColor('#75B5BF'))
        end
    end
end

function BuildOfficerSelectItem:refreshPage()
    local is_procesing = uq.cache.generals:isGeneralProcesing(self._data.id)
    self._btnClick:setEnabled(true)
    self._panelClick:setVisible(false)
    if is_procesing then
        if self._data.temp_id == self._selectGeneralTempId then
            --卸任
            self._btnClick:setVisible(true)
            self._imgProcesing:setVisible(false)
            self._txtBtnDesc:setString(StaticData['local_text']['label.buildofficer.quit'])
        else
            --进行中
            self._btnClick:setVisible(false)
            self._imgProcesing:setVisible(true)
        end
    else
        self._tireCdTime = uq.cache.generals:getTireCdTime(self._data.id, StaticData['officer_level'].Info[1].reWorkTired)
        if self._tireCdTime > 0 then
            --疲劳中
            self._btnClick:setVisible(true)
            self._imgProcesing:setVisible(false)
            self:refreshCdTime()
            uq.ShaderEffect:addGrayButton(self._btnClick)
            self._panelClick:setVisible(true)
        else
            --上任
            self._btnClick:setVisible(true)
            self._imgProcesing:setVisible(false)
            self._txtBtnDesc:setString(StaticData['local_text']['label.buildofficer.start'])
        end
    end
    self:refreshValue()
end

function BuildOfficerSelectItem:refreshCdTime()
    local left_time = self._tireCdTime
    if left_time <= 0 then
        if self._timerField then
            self._timerField:dispose()
            self._timerField = nil
        end
        return
    end

    local function timer_end()
        self:refreshPage()
    end

    if self._timerField then
        self._timerField:setTime(left_time)
    else
        self._timerField = uq.ui.TimerField:create(self._txtBtnDesc, left_time, timer_end)
    end
end

function BuildOfficerSelectItem:onBtnClick(event)
    if event.name ~= 'ended' then
        return
    end

    if self._txtBtnDesc:getString() == StaticData['local_text']['label.buildofficer.quit'] then
        local data = {
            build_type = self._buildData.castleMapType,
            officer_pos = self._posIndex - 1
        }
        network:sendPacket(Protocol.C_2_S_BUILD_DEL_OFFICER, data)

        if self._selectCallback then
            self._selectCallback()
        end
    elseif self._txtBtnDesc:getString() == StaticData['local_text']['label.buildofficer.start'] then
        local data = {
            build_type = self._buildData.castleMapType,
            general_id = self._data.id,
            officer_pos = self._posIndex - 1
        }
        network:sendPacket(Protocol.C_2_S_BUILD_ADD_OFFICER, data)

        if self._selectCallback then
            self._selectCallback()
        end
    else
        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.BUILD_OFFICER_GIFT, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
        panel:setData(self._data.id)
    end
end

return BuildOfficerSelectItem