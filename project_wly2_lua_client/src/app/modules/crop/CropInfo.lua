local CropInfo = class("CropInfo", require('app.base.PopupBase'))

CropInfo.RESOURCE_FILENAME = "crop/CropInfo.csb"
CropInfo.RESOURCE_BINDING = {
    ["Text_1"]         = {["varname"] = "_txtName"},
    ["Text_1_0"]       = {["varname"] = "_txtLevel"},
    ["Text_1_0_1"]     = {["varname"] = "_txtCropName"},
    ["ListView_1"]     = {["varname"] = "_generalList"},
    ["bg_spr"]         = {["varname"] = "_sprBg"},
    ["icon_spr"]       = {["varname"] = "_sprIcon"},
    ["close_btn"]      = {["varname"] = "_btnClose"},
    ["Image_7"]        = {["varname"] = "_imgIcon"},
    ["flag_spr"]       = {["varname"] = "_sprFlag"},
    ["Text_11"]        = {["varname"] = "_txtFlag"},
}

function CropInfo:onCreate()
    CropInfo.super.onCreate(self)

    self:centerView()
    self:setLayerColor(0.4)
    self:parseView()
    self._btnClose:addClickEventListenerWithSound(function()
        self:disposeSelf()
        end)
end

function CropInfo:onExit()
    CropInfo.super:onExit()
end

function CropInfo:setData(data)
    local data = data or {}
    if not data or next(data) == nil then
        return
    end
    self._curMemberInfo = data
    self._txtName:setString(data.name)
    self._txtLevel:setString(tostring(data.level))

    self._generalList:removeAllItems()
    for i = 1, 10 do
        local item = uq.createPanelOnly("instance.NpcGuideListItem")
        local size = item:getContentSize()
        item:setPosition(cc.p(size.width / 2, size.height / 2 - 30))
        local widget = ccui.Widget:create()
        widget:setContentSize(item:getContentSize())
        widget:addChild(item)
        widget:setTouchEnabled(true)
        item:setShowName(true)
        self._generalList:pushBackCustomItem(widget)
    end
    self._generalList:setScrollBarEnabled(false)
    self._generalList:requestDoLayout()

    local crop_info = uq.cache.crop:getCropDataById(uq.cache.role.cropsId)
    if crop_info and crop_info.name then
        self._txtCropName:setString(crop_info.name)
    end
    local icon_bg, icon_icon = uq.cache.crop:getCropIcon()
    if icon_bg and icon_bg ~= "" then
        self._sprBg:setTexture(icon_bg)
        self._sprIcon:setTexture(icon_icon)
    end
    local path = uq.getHeadRes(data.img_id, data.img_type)
    if path ~= "" then
        self._imgIcon:loadTexture(path)
    end
    self._sprFlag:setTexture(uq.cache.role:getCountryBg(data.country_id))
    self._txtFlag:setString(uq.cache.role:getCountryShortName(data.country_id))
end

return CropInfo