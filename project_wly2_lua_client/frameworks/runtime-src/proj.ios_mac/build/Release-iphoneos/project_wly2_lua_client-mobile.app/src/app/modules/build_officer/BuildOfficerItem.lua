local BuildOfficerItem = class("BuildOfficerItem", require('app.base.ChildViewBase'))

BuildOfficerItem.RESOURCE_FILENAME = "build_officer/BuildOfficerItem.csb"
BuildOfficerItem.RESOURCE_BINDING = {
    ["Node_1"]       = {["varname"] = "_nodeHead"},
    ["Image_5"]      = {["varname"] = "_imgBuild"},
    ["Text_2"]       = {["varname"] = "_txtDesc"},
    ["Text_2_1"]     = {["varname"] = "_txtPropertyDesc1"},
    ["Text_2_2"]     = {["varname"] = "_txtPropertyDesc2"},
    ["Text_2_0"]     = {["varname"] = "_txtPropertyNum1"},
    ["Text_2_3"]     = {["varname"] = "_txtPropertyNum2"},
    ["Image_3"]      = {["varname"] = "_imgItem",["events"] = {{["event"] = "touch",["method"] = "onItemClick"}}},
    ["Button_1"]     = {["varname"] = "_btnOneKey",["events"] = {{["event"] = "touch",["method"] = "onBtnClick"}}},
    ["Text_1"]       = {["varname"] = "_txtBuildName"},
    ["Sprite_3"]     = {["varname"] = "_spriteIcon"},
    ["Text_2_1_0"]   = {["varname"] = "_txtResNum"},
    ["Text_2_1_0_0"] = {["varname"] = "_txtResTip"},
    ["Image_9"]      = {["varname"] = "_imgNumBg"},
}

function BuildOfficerItem:onCreate()
    BuildOfficerItem.super.onCreate(self)
    self._txtPropertyNum1:setVisible(false)
    self._txtPropertyNum2:setVisible(false)
    self._imgBuild:ignoreContentAdaptWithSize(true)
    self._canClick = true
end

function BuildOfficerItem:onExit()
    self:removeEvent()
    BuildOfficerItem.super.onExit(self)
end

function BuildOfficerItem:removeEvent()
    services:removeEventListenersByTag(self._refreshEventTag)
    services:removeEventListenersByTag(self._resUpdataTag)
end

function BuildOfficerItem:addEvent()
    self:removeEvent()
    self._refreshEventTag = services.EVENT_NAMES.ON_BUILD_OFFICER_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_BUILD_OFFICER_REFRESH, handler(self, self.onEventRefresh), self._refreshEventTag)

    self._resUpdataTag = services.EVENT_NAMES.ON_UPDATE_BUILDER_RESOURCE .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_UPDATE_BUILDER_RESOURCE, handler(self, self.onUpdateRes), self._resUpdataTag)
end

function BuildOfficerItem:setData(data)
    self:addEvent()
    self._data = data
    self._officerNum, self._totalNum = uq.cache.role:getBuildOfficerUnlockNum(self._data.castleMapType)

    self:refreshPage()
end

function BuildOfficerItem:onEventRefresh(evt)
    if evt.build_type and evt.build_type ~= self._data.castleMapType then
        return
    end
    self:setData(self._data)
end

function BuildOfficerItem:refreshPage()
    for i = 1, self._totalNum do
        local panel = self._nodeHead:getChildByName('item' .. i)
        if not panel then
            panel = uq.createPanelOnly('build_officer.BuildOfficerHead')
            panel:setName('item' .. i)
            panel:setPosition(cc.p(50 + (i - 1) * 110, 0))
            self._nodeHead:addChild(panel)
        else
            panel:setVisible(true)
        end
        panel:setItemData(self._data, i, self._officerNum)
    end

    for i = self._totalNum + 1, 5 do
        local panel = self._nodeHead:getChildByName('item' .. i)
        if panel then
            panel:setVisible(false)
        end
    end

    local build_id = uq.cache.role:getBuildIdByType(self._data.castleMapType)
    local build_xml = StaticData['buildings']['CastleMap'][build_id]
    self._imgBuild:loadTexture(build_xml.icon)
    self._imgBuild:setScale(self._data.scale)
    self._txtDesc:setString(self._data.title)
    self._txtBuildName:setString(uq.cache.role:getFilterBuildName(build_xml.name))

    local nums = uq.cache.role:getBuildOfficerPropertyData(self._data.castleMapType, self._data.officerAttrType)
    local office_data = uq.cache.role:getBuildOfficerEffect(nums)
    local effects = string.split(self._data.addEffect, ',')

    self._txtPropertyDesc1:setVisible(false)
    self._txtPropertyDesc2:setVisible(false)
    for i = 1, 2 do
        if effects[i] then
            local xml_data = StaticData['officer'].AddType[tonumber(effects[i])]
            local num = office_data[tonumber(effects[i])]
            if xml_data.percent == 1 then
                num = num * 100
            end
            self['_txtPropertyDesc' .. i]:setVisible(true)
            self['_txtPropertyDesc' .. i]:setHTMLText(string.format(xml_data.desc, tostring(num)))
        end
    end
    self:refreshProduce()
end

function BuildOfficerItem:refreshProduce()
    self._imgItem:setVisible(false)

    if self._data.castleMapType ~= uq.config.constant.BUILD_TYPE.STRATEGY then
        return
    end

    local office_xml = StaticData['officer_build_map'][self._data.castleMapType]
    if office_xml and office_xml.reward ~= "" then
        local reward = uq.RewardType.new(office_xml.reward)
        self._imgItem:setVisible(true)
        local xml_data = StaticData.getCostInfo(reward:type(), reward:id())
        self:setProduceNum(xml_data)
    end
end

function BuildOfficerItem:setProduceNum(xml_data)
    self._spriteIcon:setTexture('img/common/ui/' .. xml_data.miniIcon)
    local num = uq.cache.role:getBuildResource(self._data.castleMapType)
    self._imgItem:stopAllActions()
    if num == 0 then
        self._imgNumBg:setVisible(false)
        self._txtResTip:setVisible(false)
        uq.ShaderEffect:setGrayAndChild(self._imgItem)
        self._txtResNum:setString('')
    else
        self._imgNumBg:setVisible(true)
        self._txtResTip:setVisible(true)
        uq.ShaderEffect:setRemoveGrayAndChild(self._imgItem)
        self._txtResNum:setString(num)
        local action1 = cc.MoveTo:create(1, cc.p(96, 88))
        local action2 = cc.MoveTo:create(1, cc.p(96, 80))
        self._imgItem:runAction(cc.RepeatForever:create(cc.Sequence:create(action1, action2)))
    end
end

function BuildOfficerItem:onBtnClick(event)
    if event.name ~= 'ended' then
        return
    end
    if not self._canClick then
        uq.fadeInfo(StaticData['local_text']['label.not.click'])
        return
    end
    self._canClick = false
    network:sendPacket(Protocol.C_2_S_BUILD_ONEKEY_ADD_OFFICER, {build_type = self._data.castleMapType})

    self:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function()
        self._canClick = true
    end)))
end

function BuildOfficerItem:onItemClick(event)
    if event.name ~= "ended" then
        return
    end

    local num = uq.cache.role:getBuildResource(self._data.castleMapType)
    if num == 0 then
        local office_xml = StaticData['officer_build_map'][self._data.castleMapType]
        local reward = uq.RewardType.new(office_xml.reward)
        local xml_data = StaticData.getCostInfo(reward:type(), reward:id())

        uq.fadeInfo(StaticData['local_text']['label.buildofficer.none'] .. xml_data.name)
        return
    end
    local build_id = uq.cache.role:getBuildIdByType(self._data.castleMapType)
    network:sendPacket(Protocol.C_2_S_BUILD_GET_RESOURCE, {build_id = build_id})
end

function BuildOfficerItem:onUpdateRes()
    self:refreshProduce()
end

return BuildOfficerItem