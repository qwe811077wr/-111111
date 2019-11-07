local CropMyCell = class("CropMyCell", require('app.base.ChildViewBase'))

CropMyCell.RESOURCE_FILENAME = "crop/CropMyCell.csb"
CropMyCell.RESOURCE_BINDING = {
    ["Button_1"]            = {["varname"] = "_btnSet",["events"] = {{["event"] = "touch",["method"] = "onSet",["sound_id"] = 0}}},
    ["post_spr"]            = {["varname"] = "_sprPost"},
    ["Text_1"]              = {["varname"] = "_txtName"},
    ["Text_1_0"]            = {["varname"] = "_txtLevel"},
    ["Text_1_0_0"]          = {["varname"] = "_txtContribute"},
    ["Text_1_0_0_2"]        = {["varname"] = "_txtGs"},
    ["Text_1_0_0_1"]        = {["varname"] = "_txtOnlineState"},
    ["icon_img"]            = {["varname"] = "_imgIcon"},
}

function CropMyCell:onCreate()
    CropMyCell.super.onCreate(self)
    self._allLabel = {"_txtName", "_txtLevel", "_txtContribute", "_txtGs"}
end

function CropMyCell:setData(member_data, index, func)
    self._index = index
    self._curMemberData = member_data
    self._func = func

    if not self._curMemberData or next(self._curMemberData) == nil then
        return
    end
    self._txtName:setString(self._curMemberData.name)
    self._txtLevel:setString(string.format("%s  %d", StaticData['local_text']['label.common.level'], self._curMemberData.level))
    self._txtContribute:setString(self._curMemberData.contribution)
    self._txtGs:setString(tostring(self._curMemberData.power))
    local color = uq.parseColor("#FFFFFF")
    if self._curMemberData.is_online == 1 or self._curMemberData.id == uq.cache.role.id then
        self._txtOnlineState:setString(StaticData['local_text']['label.common.online'])
        self._txtOnlineState:setTextColor(uq.parseColor("#56FF49"))
        if self._curMemberData.is_online == 1 then
            color = uq.parseColor("#56FF49")
        end
    else
        local time = uq.cache.server_data:getServerTime() - self._curMemberData.logout_time
        if time > 0 then
            self._txtOnlineState:setString(self:getShowTime(time))
            color = uq.parseColor("#506372")
            self._txtOnlineState:setTextColor(color)
        end
    end
    for i, v in ipairs(self._allLabel) do
        self[v]:setTextColor(color)
    end
    --军团职位
    local icon_name = StaticData['types']['Position'][1].Type[self._curMemberData.pos].icon or ""
    if icon_name and icon_name ~= "" then
        self._sprPost:setTexture("img/crop/" .. icon_name)
    end
    local path = uq.getHeadRes(self._curMemberData.img_id, self._curMemberData.img_type)
    if path ~= "" then
        self._imgIcon:loadTexture(path)
    end
end

function CropMyCell:onSet(event)
    if event.name == "ended" then
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
        if self._func and self._index then
            self._func(self._index)
        end
    end
end

function CropMyCell:getShowTime(time)
    if time > 30 * 24 * 3600 then
        return StaticData['local_text']['crop.before.one.month']
    end
    return uq.getTime2(time) .. StaticData['local_text']['label.common.before']
end

function CropMyCell:onExit()
    CropMyCell.super:onExit()
end

return CropMyCell