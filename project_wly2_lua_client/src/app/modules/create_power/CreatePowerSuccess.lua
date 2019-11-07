local CreatePowerSuccess = class("CreatePowerSuccess", require("app.base.PopupBase"))

CreatePowerSuccess.RESOURCE_FILENAME = "create_power/CreatePowerSuccess.csb"

CreatePowerSuccess.RESOURCE_BINDING  = {
    ["label_crop"]                    ={["varname"] = "_cropNameLabel"},
    ["label_city"]                    ={["varname"] = "_cityNameLabel"},
    ["Panel_1"]                       ={["varname"] = "_panelPress"},
}
function CreatePowerSuccess:ctor(name, args)
    CreatePowerSuccess.super.ctor(self,name,args)
    self._curInfo = args.info or nil
end

function CreatePowerSuccess:init()
    self:parseView()
    self:centerView()
    self:setLayerColor(0.85)
    self:initUi()
end

function CreatePowerSuccess:initUi()
    self._panelPress:setTouchEnabled(true)
    self._panelPress:addClickEventListener(function(sender)
        uq.jumpToModule(4)
    end)
    local crop_data = uq.cache.crop:getCropDataById(uq.cache.role.cropsId)
    self._cropNameLabel:setString(crop_data.name)
    self._cityNameLabel:setString(self._curInfo.name)
end

function CreatePowerSuccess:dispose()
    CreatePowerSuccess.super.dispose(self)
end

return CreatePowerSuccess