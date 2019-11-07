local RankInfo = class("RankInfo", require('app.base.PopupBase'))

RankInfo.RESOURCE_FILENAME = "crop/CropInfo.csb"
RankInfo.RESOURCE_BINDING = {
    ["Button_1"]     = {["varname"] = "_btnShield",["events"] = {{["event"] = "touch",["method"] = "onShield"}}},
    ["Button_1_0"]   = {["varname"] = "_btnChat",["events"] = {{["event"] = "touch",["method"] = "onChat"}}},
    ["close_btn"]    = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onCloseBtn"}}},
    ["Text_1"]       = {["varname"] = "_txtName"},
    ["Text_1_0"]     = {["varname"] = "_txtLevel"},
    ["Text_1_0_1"]   = {["varname"] = "_txtCropName"},
    ["Text_1_1"]     = {["varname"] = "_txtShield"},
    ["icon_spr"]     = {["varname"] = "_spriteCropHead"},
    ["bg_spr"]       = {["varname"] = "_spriteCropHeadBg"},
    ["Image_7"]      = {["varname"] = "_imgHead"},
    ["flag_spr"]     = {["varname"] = "_spriteCountry"},
    ["Text_11"]      = {["varname"] = "_txtCountryName"},
    ["Node_4"]       = {["varname"] = "_nodeItem"},
    ["ListView_1"]   = {["varname"] = "_scrollPanel"},
    ["Text_title"]   = {["varname"] = "_titleLabel"},
    ["Text_crop"]    = {["varname"] = "_cropDesLabel"},
    ["Text_1_0_0"]   = {["varname"] = "_txtLevelHead"},
}

function RankInfo:init()
    self:centerView()
    self:setLayerColor()
    self:parseView()
    self._scrollPanel:setVisible(false)
    self._txtCountryName:setVisible(false)
end

function RankInfo:setData(data)
    self._data = data
    self._txtName:setString(data.role_name)
    local txt_head = self._data.role_id ~= uq.cache.role.id and StaticData['local_text']['crop.main.title4'] or StaticData['local_text']['crop.master.level']
    self._txtLevelHead:setString(txt_head)
    self._txtLevel:setString(data.role_lvl)
    local pos_x = self._txtLevelHead:getPositionX()
    local size = self._txtLevelHead:getContentSize()
    self._txtLevel:setPositionX(pos_x + size.width + 15)

    if data.crop_name ~= '' then
        self._txtCropName:setString(data.crop_name)
    else
        self._txtCropName:setString(StaticData['local_text']['label.none'])
    end
    self._btnShield:setVisible(data.is_general == nil)
    self._btnChat:setVisible(data.is_general == nil)
    if data.is_general then
        self._titleLabel:setString(StaticData['local_text']['fly.nail.general.title'])
        self._txtCropName:setString(data.power)
        self._cropDesLabel:setString(StaticData['local_text']['label.power'])
        local general_data = uq.cache.generals:getGeneralDataXML(data.general_id)
        self._imgHead:loadTexture("img/common/general_head/" .. general_data.miniIcon)
    else
        local icon_bg, head_icon = uq.cache.crop:getCropIcon(data.crop_icon)
        self._spriteCropHead:setTexture(head_icon)
        self._spriteCropHeadBg:setTexture(icon_bg)

        local res_head = uq.getHeadRes(data.img_id, data.img_type)
        self._imgHead:loadTexture(res_head)
    end
    self._spriteCountry:setTexture(uq.cache.role:getCountryImg(data.country_id))
    self._txtCountryName:setString(uq.cache.role:getCountryShortName(data.country_id))

    self._nodeItem:removeAllChildren()
    local node_parent = cc.Node:create()
    local total_width = 0
    local space = 23
    for i = 1, #data.generals do
        local panel = uq.createPanelOnly('instance.NpcGuideListItem')
        local size = panel:getContentSize()
        local x = (i - 1) * (size.width + space) + size.width / 2
        local y = 0
        panel:setPosition(cc.p(x, y))
        node_parent:addChild(panel)
        panel:setGeneralData(data.generals[i])
        panel:setScale(1.2)
        total_width = total_width + size.width + space
    end
    total_width = total_width - space
    node_parent:setPositionX(-total_width / 2)
    self._nodeItem:addChild(node_parent)

    self._btnShield:setVisible(self._data.role_id ~= uq.cache.role.id)
    self._btnChat:setVisible(self._data.role_id ~= uq.cache.role.id)

    self._chatInfo = {
        sender_id = self._data.role_id,
        role_name = self._data.role_name,
        img_id = self._data.img_id,
        img_type = self._data.img_type,
        country_id = self._data.country_id,
        crop_name = self._data.crop_name,
    }
end

function RankInfo:setInfo(info)
    if self._info and self._info.id == info.id then
        return
    end
    self._info = info
    self._txtName:setString(info.name)
    self._txtLevel:setString(info.level)
    local crop_name = (info.crop_name == "" or not info.crop_name) and StaticData['local_text']['label.none'] or info.crop_name
    self._txtCropName:setString(crop_name)
    self._spriteCountry:setTexture(uq.cache.role:getCountryImg(info.country))
    network:addEventListener(Protocol.S_2_C_ATHLETICS_VIEW_FORMATION, handler(self, self._onViewFormation), '_onViewFormation' .. tostring(self))
    network:sendPacket(Protocol.C_2_S_ATHLETICS_VIEW_FORMATION, {pos = info.rank})

    local res_head = uq.getHeadRes(info.img_id, info.img_type)
    self._imgHead:loadTexture(res_head)
    self._btnShield:setVisible(self._info.id ~= uq.cache.role.id)
    self._btnChat:setVisible(self._info.id ~= uq.cache.role.id)
    local icon_bg, head_icon = uq.cache.crop:getCropIcon(self._info.crop_icon)
    self._spriteCropHead:setTexture(head_icon)
    self._spriteCropHeadBg:setTexture(icon_bg)

    self._chatInfo = {
        sender_id = self._info.id,
        role_name = self._info.name,
        img_id = self._info.img_id,
        img_type = self._info.img_type,
        country_id = self._info.country,
        crop_name = self._info.crop_name,
    }
end

function RankInfo:_onViewFormation(msg)
    local data = msg.data
    self._nodeItem:removeAllChildren()
    local node_parent = cc.Node:create()
    local total_width = 0
    local space = 23
    for i = 1, #data.generals do
        local panel = uq.createPanelOnly('instance.NpcGuideListItem')
        local size = panel:getContentSize()
        local x = (i - 1) * (size.width + space) + size.width / 2
        local y = 0
        panel:setPosition(cc.p(x, y))
        node_parent:addChild(panel)
        panel:setGeneralData(data.generals[i])
        panel:setScale(1.2)
        total_width = total_width + size.width + space
    end
    total_width = total_width - space
    node_parent:setPositionX(-total_width / 2)
    self._nodeItem:addChild(node_parent)
end

function RankInfo:onShield(event)
    if event.name ~= "ended" then
        return
    end

    if self._txtShield:getString() == StaticData['local_text']['rank.sheild'] then
        uq.cache.chat:addShield(self._chatInfo.role_name)
    else
        uq.cache.chat:deleteShield(self._chatInfo.role_name)
    end

    if uq.cache.chat:getShield(self._chatInfo.role_name) then
        self._txtShield:setString(StaticData['local_text']['rank.remove.sheild'])
        uq.fadeInfo(StaticData['local_text']['rank.sheild.success'])
    else
        self._txtShield:setString(StaticData['local_text']['rank.sheild'])
        uq.fadeInfo(StaticData['local_text']['rank.remove.sheild'])
    end
end

function RankInfo:onChat(event)
    if event.name ~= "ended" then
        return
    end
    uq.cache.chat:createConversation(self._chatInfo, true, false)
    self:disposeSelf()
end

function RankInfo:dispose()
    network:removeEventListenerByTag('_onViewFormation' .. tostring(self))
    RankInfo.super.dispose(self)
end

function RankInfo:onCloseBtn(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

return RankInfo