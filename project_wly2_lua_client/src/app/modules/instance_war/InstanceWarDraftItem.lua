local InstanceWarDraftItem = class("InstanceWarDraftItem", require('app.base.ChildViewBase'))

InstanceWarDraftItem.RESOURCE_FILENAME = "instance_war/InstanceWarDraftItem.csb"
InstanceWarDraftItem.RESOURCE_BINDING = {
    ["s06_000001_001_2"] = {["varname"] = "_spriteIcon"},
    ["Text_1"]           = {["varname"] = "_txtName"},
    ["Text_1_0"]         = {["varname"] = "_txtLevel"},
    ["Image_7"]          = {["varname"] = "_imgType1"},
    ["Image_8"]          = {["varname"] = "_imgType2"},
    ["Text_1_2"]         = {["varname"] = "_txtSolder"},
    ["Slider_1"]         = {["varname"] = "_slider"},
}

function InstanceWarDraftItem:onCreate()
    InstanceWarDraftItem.super.onCreate(self)
    self._slider:onEvent(handler(self, self.onSliderChange))
end

function InstanceWarDraftItem:setData(general_data, parent, soldier_current)
    self._parent = parent
    self._generalData = general_data
    local general_xml = uq.cache.generals:getGeneralDataXML(general_data.temp_id)
    self._spriteIcon:setTexture("img/common/general_head/" .. general_xml.miniIcon)
    self._txtName:setString(general_data.name)
    self._txtLevel:setString(general_data.lvl)
    self._currentSoldier = soldier_current

    local soldier_xml1 = StaticData['soldier'][general_data.soldierId1]
    if soldier_xml1 ~= nil then
        local type_solider1 = StaticData['types'].Soldier[1].Type[soldier_xml1.type]
        self._imgType1:loadTexture("img/generals/" .. type_solider1.miniIcon2)
        self._imgType1:setVisible(true)
    else
        self._imgType1:setVisible(false)
    end

    local soldier_xml2 = StaticData['soldier'][general_data.soldierId2]
    if soldier_xml2 ~= nil then
        local type_solider2 = StaticData['types'].Soldier[1].Type[soldier_xml2.type]
        self._imgType2:loadTexture("img/generals/" .. type_solider2.miniIcon2)
        self._imgType2:setVisible(true)
    else
        self._imgType2:setVisible(false)
    end

    self._slider:setPercent(self._currentSoldier[general_data.id] / general_data.limitSoldierNum * 100)
    self._txtSolder:setString(self._currentSoldier[general_data.id] .. '/' .. general_data.limitSoldierNum)
    self:refreshSoldier()
end

function InstanceWarDraftItem:getGeneralId()
    return self._generalData.id
end

function InstanceWarDraftItem:onSliderChange(event)
    if event.name == "ON_PERCENTAGE_CHANGED" then
        local slide_ball = self._slider:getSlidBallRenderer()
        local bar_length = self._slider:getContentSize().width
        local posx = slide_ball:getPositionX()
        local rate = posx / bar_length
        local soldier = math.floor(self._generalData.limitSoldierNum * rate)

        local left_soldier = self._parent:getLeftSoldier()
        if soldier > left_soldier + self._currentSoldier[self._generalData.id] then
            soldier = left_soldier + self._currentSoldier[self._generalData.id]
            slide_ball:setPositionX(soldier / self._generalData.limitSoldierNum * bar_length)
        end

        self._currentSoldier[self._generalData.id] = soldier
        self._parent:setCurrentSoldier(self._generalData.id, soldier)
        self._parent:refreshSolder()
        self:refreshSoldier()
    end
end

function InstanceWarDraftItem:refreshSoldier()
    self._txtSolder:setString(self._currentSoldier[self._generalData.id] .. '/' .. self._generalData.limitSoldierNum)
end

return InstanceWarDraftItem