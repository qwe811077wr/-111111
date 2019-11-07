local GovernmentAppointListCell = class("GovernmentAppointListCell", require('app.base.ChildViewBase'))

GovernmentAppointListCell.RESOURCE_FILENAME = "government/GovernmentAppointListCell.csb"
GovernmentAppointListCell.RESOURCE_BINDING = {
    ["Text_1"]       = {["varname"] = "_txtName"},
    ["Text_1_0"]     = {["varname"] = "_txtLevel"},
    ["Text_1_0_0"]   = {["varname"] = "_txtContribute"},
    ["Text_1_0_0_0"] = {["varname"] = "_txtOnlineState"},
    ["Image_7"]      = {["varname"] = "_headImg"},
    ["Image_8"]      = {["varname"] = "_imgBg"},
}

function GovernmentAppointListCell:onCreate()
    GovernmentAppointListCell.super.onCreate(self)
    self:parseView()
end

function GovernmentAppointListCell:onExit()
    GovernmentAppointListCell.super:onExit()
end

function GovernmentAppointListCell:setData(member_data, idx)
    self._curMemberData = member_data
    if self._curMemberData then
        self._txtName:setString(self._curMemberData.name)
        self._txtLevel:setString(string.format("%s  %d", StaticData['local_text']['label.common.level'], self._curMemberData.level))
        self._txtContribute:setString('0')
        local res_head = uq.getHeadRes(self._curMemberData.img_id, self._curMemberData.img_type)
        self._headImg:loadTexture(res_head)
        if self._curMemberData.is_online == 1 then
            self._txtOnlineState:setString(StaticData['local_text']['label.common.online'])
            self._txtOnlineState:setTextColor(cc.c3b(6, 227, 74))
        else
            local time = self._curMemberData.logout_time
            self._txtOnlineState:setString(uq.getTime2(time) .. StaticData['local_text']['label.common.before'])
            self._txtOnlineState:setTextColor(cc.c3b(121, 129, 129))
        end
    end
    if idx then
        self._imgBg:setVisible(idx % 2 == 0)
    end
end

return GovernmentAppointListCell