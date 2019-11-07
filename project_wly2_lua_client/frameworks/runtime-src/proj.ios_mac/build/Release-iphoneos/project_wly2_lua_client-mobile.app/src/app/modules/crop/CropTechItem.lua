local CropTechItem = class("CropTechItem", require('app.base.ChildViewBase'))

CropTechItem.RESOURCE_FILENAME = "crop/CropTechItem.csb"
CropTechItem.RESOURCE_BINDING = {
    ["Panel_1"]                 = {["varname"] = "_panel"},
    ["bg"]                      = {["varname"] = "_spriteBg"},
    ["lock"]                    = {["varname"] = "_spriteLock"},
    ["icon"]                    = {["varname"] = "_spriteIcon"},
    ["name"]                    = {["varname"] = "_txtName"},
    ["level"]                   = {["varname"] = "_txtLevel"},
    ["Text_2"]                  = {["varname"] = "_txtLevelProgress"},
    ["LoadingBar_1"]            = {["varname"] = "_loadLevelProgress"},
    ["Image_selected"]          = {["varname"] = "_imgSelected"},
}

function CropTechItem:onCreate()
    CropTechItem.super.onCreate(self)
end

function CropTechItem:setData(index, parent)
    self._xmlData = StaticData['legion_tech'][index]
    self._index = index
    self._parent = parent
    self:refreshPage()
end

function CropTechItem:refreshPage()
    self._spriteLock:setVisible(false)
    self._opened = true
    if not self._xmlData then
        self._spriteLock:setVisible(true)
        self._txtName:setString('')
        self._opened = false
        return
    end

    self._spriteIcon:setTexture('img/crop/' .. self._xmlData.icon)

    local crop_info = uq.cache.crop:getCropDataById(uq.cache.role.cropsId)
    local tech_data = self._parent:getTechData()
    local tech_level = tech_data and tech_data.techs[self._index].lvl or 0
    local level_data = self._xmlData.Effect[tech_level]

    if self._xmlData.initLevel > crop_info.level then
        self._spriteLock:setVisible(true)
        self._txtName:setString(string.format(StaticData['local_text']['crop.tech.open.level'], self._xmlData.initLevel))
        self._opened = false
    else
        self._txtLevel:setString(tostring(tech_level))
        self._txtName:setString(self._xmlData.name)
        local level_max = self._index == 1 and #self._xmlData.Effect or level_data.LegionLevel
        self._txtLevelProgress:setString(string.format('%d/%d', tech_level, level_max))
        self._loadLevelProgress:setPercent(tech_level / level_max * 100)
    end
end

function CropTechItem:getOpend()
    return self._opened
end

function CropTechItem:setSelected(flag)
    self._imgSelected:setVisible(flag)
end

function CropTechItem:getContentSize()
    return self._panel:getContentSize()
end

return CropTechItem