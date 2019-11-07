local CropDetail = class("CropDetail", require('app.base.PopupBase'))

CropDetail.RESOURCE_FILENAME = "crop/CropDetail.csb"
CropDetail.RESOURCE_BINDING = {
    ["crop_name"]   = {["varname"] = "_txtName"},
    ["txt_country"] = {["varname"] = "_txtCountry"},
    ["Image_8"]     = {["varname"] = "_imgCountryBg"},
    ["Image_5"]     = {["varname"] = "_imgCropIconBg"},
    ["Image_6"]     = {["varname"] = "_imgCropIcon"},
    ["Text_13"]     = {["varname"] = "_txtLeaderName"},
    ["Text_13_0"]   = {["varname"] = "_txtLeaderPower"},
    ["Image_12"]    = {["varname"] = "_imgLeaderHead"},
    ["Text_5_3"]    = {["varname"] = "_txtLevel"},
    ["Text_5_3_1"]  = {["varname"] = "_txtRank"},
    ["Text_5_3_0"]  = {["varname"] = "_txtMember"},
    ["Text_5_3_2"]  = {["varname"] = "_txtPower"},
    ["Node_1"]      = {["varname"] = "_nodeItem"},
}

function CropDetail:onCreate()
    CropDetail.super.onCreate(self)
    self:centerView()
    self:setLayerColor()
    self:parseView()

    self._eventTag = Protocol.S_2_C_LOAD_ALL_MEMBER .. tostring(self)
    network:addEventListener(Protocol.S_2_C_LOAD_ALL_MEMBER, handler(self, self.onCropInfoRet), self._eventTag)

    self._eventTagCropInfo = Protocol.S_2_C_LOAD_CROP_INFO .. tostring(self)
    network:addEventListener(Protocol.S_2_C_LOAD_CROP_INFO, handler(self, self.onLoadCropInfo), self._eventTagCropInfo)
end

function CropDetail:onExit()
    network:removeEventListenerByTag(self._eventTag)
    network:removeEventListenerByTag(self._eventTagCropInfo)
    CropDetail.super:onExit()
end

function CropDetail:setData(crop_data, index)
    network:sendPacket(Protocol.C_2_S_LOAD_ALL_MEMBER, {crop_id = crop_data.id})
    network:sendPacket(Protocol.C_2_S_LOAD_CROP_INFO, {id = crop_data.id})

    self._cropData = crop_data
    self._txtName:setString(crop_data.name)

    self._txtCountry:setString(uq.cache.role:getCountryShortName(crop_data.country_id))
    self._imgCountryBg:loadTexture(uq.cache.role:getCountryBg(crop_data.country_id))

    local icon_bg, head_icon = uq.cache.crop:getCropIcon(crop_data.head_id)
    self._imgCropIcon:loadTexture(head_icon)
    self._imgCropIconBg:loadTexture(icon_bg)
    self._txtLeaderName:setString(crop_data.leader_name)
    self._txtLeaderPower:setString('0')
    self._txtLevel:setString(crop_data.level)
    self._txtRank:setString(index)
    self._txtPower:setString('0')
end

function CropDetail:onCropInfoRet(evt)
    if evt.data.is_notify == 0 then
        self._members = {}
    end
    for k, item in ipairs(evt.data.members) do
        table.insert(self._members, item)
    end
    self:refreshPage()
end

function CropDetail:refreshPage()
    local power = 0
    local leader_list = {}
    for k, item in ipairs(self._members) do
        power = power + item.power
        leader_list[item.pos] = item
    end
    local leader_data = leader_list[uq.config.constant.GOVERNMENT_POS.COMMANDER]
    self._txtPower:setString(power)
    self._txtLeaderPower:setString(leader_data.power)

    local res_head = uq.getHeadRes(leader_data.img_id, leader_data.img_type)
    self._imgLeaderHead:loadTexture(res_head)

    self._nodeItem:removeAllChildren()
    local node_parent = cc.Node:create()
    local total_width = 0
    local space = 60
    local map_lead = {uq.config.constant.GOVERNMENT_POS.SUB_COMMANDER, uq.config.constant.GOVERNMENT_POS.WARLOAD, uq.config.constant.GOVERNMENT_POS.TATRAP}
    for i = 1, 3 do
        local panel = uq.createPanelOnly('crop.CropLeaderHead')
        local size = panel:getContentSize()
        local x = (i - 1) * (size.width + space) + size.width / 2
        local y = 0
        panel:setPosition(cc.p(x, y))
        node_parent:addChild(panel)
        panel:setData(leader_list[map_lead[i]], map_lead[i])
        total_width = total_width + size.width + space
    end
    total_width = total_width - space
    node_parent:setPositionX(-total_width / 2)
    self._nodeItem:addChild(node_parent)
end

function CropDetail:onLoadCropInfo(evt)
    self._txtMember:setString(string.format('%d/%d', evt.data.mem_num, evt.data.max_mem_num))
end

return CropDetail