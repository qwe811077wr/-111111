local PrivilegeInfo = class("PrivilegeInfo", require("app.base.PopupBase"))

PrivilegeInfo.RESOURCE_FILENAME = "government/PrivilegeInfo.csb"

PrivilegeInfo.RESOURCE_BINDING  = {
    ["Panel_2/label_des"]                       ={["varname"] = "_desLabel"},
    ["Panel_2/Node_2"]                          ={["varname"] = "_lockNode"},
    ["Panel_2/Node_1"]                          ={["varname"] = "_infoNode"},
    ["Panel_2/Node_1/Image_country"]            ={["varname"] = "_imgCountry"},
    ["Panel_2/Node_1/label_government"]         ={["varname"] = "_governmentLabel"},
    ["Panel_2/Node_1/label_name"]               ={["varname"] = "_nameLabel"},
    ["Panel_2/Node_1/label_corps"]              ={["varname"] = "_cropsLabel"},
    ["Panel_2/Node_1/Panel_2/Image_7"]          ={["varname"] = "_imgIcon"},
    ["Panel_2/Node_10"]                         ={["varname"] = "_attNode"},
}
function PrivilegeInfo:ctor(name, args)
    PrivilegeInfo.super.ctor(self,name,args)
    self._info = args.info
    self._attInfoArray = {}
end

function PrivilegeInfo:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self:initUi()
end

function PrivilegeInfo:initUi()
    for i = 1, 4 do
        local item = self._attNode:getChildByName("Node_des_" .. i)
        table.insert(self._attInfoArray, item)
    end
    self:updateInfo()
end

function PrivilegeInfo:updateInfo()
    self._infoNode:setVisible(self._info.data ~= nil)
    self._lockNode:setVisible(self._info.data == nil)
    self._governmentLabel:setString(self._info.name)
    self._desLabel:setString(self._info.desc)
    local width = 1
    for k, v in ipairs(self._attInfoArray) do
        v:setVisible(self._info["right" .. k] ~= nil)
        if self._info["right" .. k] ~= nil then
            v:getChildByName("label_des"):setString(self._info["right" .. k])
            if v:getChildByName("label_des"):getContentSize().width > width then
                width = v:getChildByName("label_des"):getContentSize().width
            end
            v:getChildByName("label_add"):setString(self._info["num" .. k])
        end
    end
    for k, v in ipairs(self._attInfoArray) do
        if self._info["right" .. k] ~= nil then
            v:getChildByName("label_add"):setPositionX(width + 75)
        end
    end
    if self._info.data == nil then
        return
    end
    self._nameLabel:setString(self._info.data.player_name)
    self._cropsLabel:setString(self._info.data.crop_name)
    local res_head = uq.getHeadRes(self._info.data.img_id, self._info.data.img_type)
    self._imgIcon:loadTexture(res_head)
end

function PrivilegeInfo:dispose()
    PrivilegeInfo.super.dispose(self)
end

return PrivilegeInfo