local NpcGuideListItem = class("NpcGuideListItem", require('app.base.ChildViewBase'))

NpcGuideListItem.RESOURCE_FILENAME = "instance/GuideHeadItem.csb"
NpcGuideListItem.RESOURCE_BINDING = {
    ["Text_1"]   = {["varname"] = "_txtLv"},
    ["spr_icon"] = {["varname"] = "_sprIcon"},
    ["spr_1"]    = {["varname"] = "_spr1"},
    ["spr_2"]    = {["varname"] = "_spr2"},
    ["spr_3"]    = {["varname"] = "_spr3"},
    ["spr_4"]    = {["varname"] = "_spr4"},
    ["spr_5"]    = {["varname"] = "_spr5"},
    ["name_txt"] = {["varname"] = "_txtName"},
    ["Image_1"]  = {["varname"] = "_imgBg"},
}

function NpcGuideListItem:onCreate()
    NpcGuideListItem.super.onCreate(self)
end

function NpcGuideListItem:setData(data)
    if not data or next(data) == nil then
        return
    end
    local id = tonumber(data[1]) or 0
    local general_data = uq.cache.generals:getGeneralDataXML(id)
    if not general_data or next(general_data) == nil then
        return
    end
    local quality = general_data.isJiuguan == 0 and general_data.qualityType or 1
    for i = 1, 5 do
        self["_spr" .. i]:setVisible(i <= quality)
    end
    self._txtLv:setString(data[2])

    if not data[3] then
        return
    end
    local general_xml = uq.cache.generals:getGeneralDataXML(tonumber(data[3]))
    self._sprIcon:setTexture("img/common/general_head/" .. general_xml.miniIcon)
end

function NpcGuideListItem:setShowName(is_show)
    self._txtName:setVisible(is_show)
end

function NpcGuideListItem:setGeneralData(data)
    self._txtName:setString(data.name)

    local grade_info = StaticData['types'].GeneralGrade[1].Type[data.grade]
    local quality_info = StaticData['types'].ItemQuality[1].Type[grade_info.qualityType]
    self._imgBg:loadTexture('img/common/ui/' .. quality_info.qualityIcon)
    self._txtName:setTextColor(uq.parseColor(quality_info.color))
    self._txtName:setVisible(true)

    local general_data = uq.cache.generals:getGeneralDataXML(data.general_id)
    local general_xml = uq.cache.generals:getGeneralDataXML(data.rtemp_id)

    self._txtLv:setString(data.level)
    self._sprIcon:setTexture("img/common/general_head/" .. general_xml.miniIcon)

    local quality = general_data.isJiuguan == 0 and general_data.qualityType or 1
    for i = 1, 5 do
        self["_spr" .. i]:setVisible(i <= quality)
    end
end

return NpcGuideListItem