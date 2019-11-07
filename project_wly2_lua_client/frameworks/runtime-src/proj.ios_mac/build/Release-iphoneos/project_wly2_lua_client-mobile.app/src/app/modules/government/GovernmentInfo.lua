local GovernmentInfo = class("GovernmentInfo", require("app.base.PopupBase"))

GovernmentInfo.RESOURCE_FILENAME = "government/GovernmentInfo.csb"

GovernmentInfo.RESOURCE_BINDING  = {
    ["Panel_2/label_des"]                       ={["varname"] = "_desLabel"},
    ["Panel_2/Node_2"]                          ={["varname"] = "_lockNode"},
    ["Panel_2/Node_1"]                          ={["varname"] = "_infoNode"},
    ["Panel_2/label_government"]                ={["varname"] = "_governmentLabel"},
    ["Panel_2/Node_1/label_name"]               ={["varname"] = "_nameLabel"},
    ["Panel_2/Node_1/Panel_2/Image_7"]          ={["varname"] = "_imgIcon"},
    ["Panel_2/Node_10"]                         ={["varname"] = "_attNode"},
    ["Panel_2/btn_command"]                     ={["varname"] = "_btnCommand",["events"] = {{["event"] = "touch",["method"] = "_onBtnCommand"}}},
}

GovernmentInfo._DESTXT = {
    StaticData['local_text']["crop.government.des6"],
    StaticData['local_text']["crop.government.des7"],
    StaticData['local_text']["crop.government.des8"],
    StaticData['local_text']["crop.government.des9"],
}

function GovernmentInfo:ctor(name, args)
    GovernmentInfo.super.ctor(self,name,args)
    self._info = args.info or nil
    self._pos = args.pos or 0
    self._cityId = args.city_id or 0
    self._attInfoArray = {}
end

function GovernmentInfo:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self:initUi()
    services:addEventListener(services.EVENT_NAMES.ON_CROP_APPOINT_NOTIFY, handler(self, self._onCropAppointNotify), "onCropAppointNotifyByInfo")
end

function GovernmentInfo:_onCropAppointNotify()
    for k, v in ipairs(uq.cache.crop._allMemberInfo) do
        if self._cityId == v.pos_cityid and self._pos == v.pos then
            self._info = v
            break
        end
    end
    self:updateInfo()
end

function GovernmentInfo:initUi()
    for i = 1, 4 do
        local item = self._attNode:getChildByName("Node_des_" .. i)
        table.insert(self._attInfoArray, item)
    end
    self._btnCommand:setPressedActionEnabled(true)
    self:updateInfo()
end

function GovernmentInfo:updateInfo()
    self._infoNode:setVisible(self._info ~= nil)
    self._lockNode:setVisible(self._info == nil)
    self._btnCommand:setVisible(self._info == nil)
    local info = StaticData['war_season'].WarGrade[1].grade[self._pos]
    local index = 1
    if info then
        if info.prestige then
            self._attInfoArray[index]:setVisible(true)
            self._attInfoArray[index]:getChildByName("label_des"):setHTMLText(string.format(StaticData["local_text"]["crop.government.des10"], info.prestige))
            index = index + 1
        end
    end
    for k = index, 4 do
        self._attInfoArray[k]:setVisible(false)
    end
    if self._pos < uq.config.constant.GOVERNMENT_POS.TATRAP then
        self._governmentLabel:setString(self._DESTXT[self._pos + 1])
    else
        self._governmentLabel:setString(string.format(self._DESTXT[self._pos + 1], StaticData['world_city'][self._cityId].name))
    end
    if self._info then
        local self_info = uq.cache.crop:getMemberInfoById(uq.cache.role.id)
        local res_head = uq.getHeadRes(self._info.img_id, self._info.img_type)
        self._imgIcon:loadTexture(res_head)
        self._nameLabel:setString(self._info.name)
        self._btnCommand:setVisible(self._info.pos > self_info.pos)
    end
end

function GovernmentInfo:_onBtnCommand(event)
    if event.name ~= "ended" then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.GOVERNMENT_APPOINT_LIST, {pos = self._pos, city_id = self._cityId})
end

function GovernmentInfo:dispose()
    services:removeEventListenersByTag("onCropAppointNotifyByInfo")
    GovernmentInfo.super.dispose(self)
end

return GovernmentInfo