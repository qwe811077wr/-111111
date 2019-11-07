local CropApplyListCell = class("CropApplyListCell", require('app.base.ChildViewBase'))

CropApplyListCell.RESOURCE_FILENAME = "crop/CropApllyListCell.csb"
CropApplyListCell.RESOURCE_BINDING = {
    ["Text_1"]       = {["varname"] = "_txtName"},
    ["Text_1_0"]     = {["varname"] = "_txtLevel"},
    ["Text_1_0_0"]   = {["varname"] = "_txtContribute"},
    ["Text_1_0_0_0"] = {["varname"] = "_txtOnlineState"},
    ["Image_7"]      = {["varname"] = "_imgIcon"},
    ["Button_1"]     = {["varname"] = "_btnRefuse",["events"] = {{["event"] = "touch",["method"] = "onRefuse"}}},
    ["Button_1_0"]   = {["varname"] = "_btnConfirm",["events"] = {{["event"] = "touch",["method"] = "onConfirm"}}},
}

function CropApplyListCell:onCreate()
    CropApplyListCell.super.onCreate(self)
    self:parseView()
end

function CropApplyListCell:onExit()
    CropApplyListCell.super:onExit()
end

function CropApplyListCell:setData(member_data, idx)
    self._curMemberData = member_data
    if not self._curMemberData or next(self._curMemberData) == nil then
        return
    end
    self._txtName:setString(self._curMemberData.name)
    self._txtLevel:setString(string.format("%s  %d", StaticData['local_text']['label.common.level'], self._curMemberData.level))
    self._txtContribute:setString('0')
    local path = uq.getHeadRes(self._curMemberData.img_id, self._curMemberData.img_type)
    if path ~= "" then
        self._imgIcon:loadTexture(path)
    end
    if self._curMemberData.is_online == 1 then
        self._txtOnlineState:setString(StaticData['local_text']['label.common.online'])
        self._txtOnlineState:setTextColor(cc.c3b(6, 227, 74))
    else
        local time = self._curMemberData.logout_time or 0
        self._txtOnlineState:setString(uq.getTime2(time) .. StaticData['local_text']['label.common.before'])
        self._txtOnlineState:setTextColor(cc.c3b(121, 129, 129))
    end
end

function CropApplyListCell:onRefuse(event)
    if event.name == "ended" then
        network:sendPacket(Protocol.C_2_S_CROP_REJECT, {id = self._curMemberData.id})
    end
end

function CropApplyListCell:onConfirm(event)
    if event.name == "ended" then
        network:sendPacket(Protocol.C_2_S_CROP_APPROVE, {id = self._curMemberData.id})
    end
end

return CropApplyListCell