local CreatePowerInfo = class("CreatePowerInfo", require("app.base.PopupBase"))

CreatePowerInfo.RESOURCE_FILENAME = "create_power/CreatePowerInfo.csb"

CreatePowerInfo.RESOURCE_BINDING  = {
    ["ScrollView_1"]    ={["varname"] = "_scrollView"},
    ["img_flag"]        ={["varname"] = "_imgFlag"},
    ["label_name"]      ={["varname"] = "_nameLabel"},
    ["label_flag"]      ={["varname"] = "_flagLabel"},
    ["label_status"]    ={["varname"] = "_statusLabel"},
    ["Panel_2"]         ={["varname"] = "_editBoxPanel"},
    ["Text_6"]          ={["varname"] = "_btnTextLabel"},
    ["Button_create"]   = {["varname"] = "_BtnNext",["events"] = {{["event"] = "touch",["method"] = "onBtnCreate"}}},
}
function CreatePowerInfo:ctor(name, args)
    CreatePowerInfo.super.ctor(self,name,args)
    self._curInfo = args.info or nil
    self._canUsedFlag = args.flag_array or {}
    self._curFlagInfo = self._canUsedFlag[1] or nil
end

function CreatePowerInfo:init()
    self:parseView()
    self:centerView()
    self:initUi()
    services:addEventListener(services.EVENT_NAMES.ON_CREATE_POWER_FAIL, handler(self, self._onCraetePowerFail), "_onCraetePowerFailByInfo")
end

function CreatePowerInfo:initUi()
    local size = self._editBoxPanel:getContentSize()
    self._editBoxName = ccui.EditBox:create(cc.size(size.width, size.height), '')
    self._editBoxName:setAnchorPoint(cc.p(0.5, 0.5))
    self._editBoxName:setFontName("font/fzzzhjt.ttf")
    self._editBoxName:setFontSize(20)
    self._editBoxName:setFontColor(uq.parseColor("#ffffff"))
    self._editBoxName:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._editBoxName:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self._editBoxName:setPosition(cc.p(size.width / 2, size.height / 2))
    self._editBoxName:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    self._editBoxName:setMaxLength(1)
    self._editBoxName:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end)
    self._editBoxPanel:addChild(self._editBoxName)
    self._editBoxName:setPlaceholderFontName("font/fzzzhjt.ttf")
    self._editBoxName:setPlaceholderFontColor(uq.parseColor("#ffffff"))
    self._editBoxName:setPlaceholderFontSize(20)
    self._editBoxName:setPlaceHolder(StaticData["local_text"]["world.war.power.des4"])
    self._nameLabel:setString(self._curInfo.name)
    local crop_data = uq.cache.crop:getCropDataById(uq.cache.role.cropsId)
    self._cropName = string.subUtf(crop_data.name, 1, 1)
    self._flagLabel:setString(self._cropName)
    if crop_data.level < 3 then
        self._statusLabel:setTextColor(uq.parseColor("#f22926"))
        self._btnTextLabel:setString(StaticData["local_text"]["world.war.power.des8"])
    else
        self._statusLabel:setTextColor(uq.parseColor("#5bbf5b"))
        self._btnTextLabel:setString(StaticData["local_text"]["world.war.power.des7"])
    end
    self:updateScrollView()
end

function CreatePowerInfo:_onCraetePowerFail(msg)
    if msg.data.ret == 1 then
        uq.fadeInfo(uq.fadeInfo(StaticData["local_text"]["world.war.power.des2"]))
        self:disposeSelf()
    elseif msg.data.ret == 2 then
        self._panelFlag:setVisible(false)
        for k, v in ipairs(self._canUsedFlag) do
            if v.ident == self._curFlagInfo then
                table.remove(self._canUsedFlag, k)
                break
            end
        end
        if #self._canUsedFlag == 0 then
            self:disposeSelf()
            uq.fadeInfo(uq.fadeInfo(StaticData["local_text"]["world.war.power.des1"]))
            return
        end
        uq.fadeInfo(uq.fadeInfo(StaticData["local_text"]["world.war.power.des3"]))
        self._curFlagInfo = self._canUsedFlag[1]
        self:updateScrollView()
    else
        local crop_data = uq.cache.crop:getCropDataById(uq.cache.role.cropsId)
        crop_data.city_id = msg.data.init_city_id
        crop_data.color_id = msg.data.color_id
        crop_data.power_id = msg.data.power_id
        crop_data.power_name = msg.data.power_name
        uq.ModuleManager:getInstance():show(uq.ModuleManager.CREATE_POWER_SUCCESS, {info = self._curInfo})
        self:disposeSelf()
    end
end

function CreatePowerInfo:updateScrollView()
    self._scrollView:removeAllChildren()
    local item_size = self._scrollView:getContentSize()
    local index = #self._canUsedFlag
    local inner_width = index * 80
    self._scrollView:setInnerContainerSize(cc.size(inner_width, item_size.height))
    if inner_width < item_size.width then
        self._scrollView:setPositionX(self._scrollView:getPositionX() + (item_size.width - inner_width) * 0.5)
        self._scrollView:setTouchEnabled(false)
    end
    self._scrollView:setScrollBarEnabled(false)
    local item_posx = 0
    for k, v in ipairs(self._canUsedFlag) do
        local img = ccui.ImageView:create("img/create_power/" .. v.color)
        img:setAnchorPoint(cc.p(0, 0))
        img:setScale(1.4)
        img:setPosition(cc.p(item_posx, 0))
        img:setTouchEnabled(true)
        img['info'] = v
        self._scrollView:addChild(img)
        img:addClickEventListener(function(sender)
            self._curFlagInfo = sender['info']
            self:updateFlag()
        end)
        item_posx = item_posx + 80
    end
end

function CreatePowerInfo:updateFlag()
    if self._curFlagInfo == nil then
        return
    end
    self._imgFlag:loadTexture("img/create_power/" .. self._curFlagInfo.color)
end

function CreatePowerInfo:editboxHandle(strEventName, sender)
    if strEventName == "ended" then
        if self._editBoxName:getText() == '' then
            self._flagLabel:setString(self._cropName)
        else
            self._cropName = self._editBoxName:getText()
            self._flagLabel:setString(self._cropName)
        end
    end
end

function CreatePowerInfo:onBtnCreate(event)
    if event.name ~= 'ended' then
        return
    end
    local crop_data = uq.cache.crop:getCropDataById(uq.cache.role.cropsId)
    if crop_data.level < 3 then
        self:disposeSelf()
        local power_view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.CREATE_POWER_MODULE)
        if power_view then
            power_view:disposeSelf()
        end
        uq.ModuleManager:getInstance():show(uq.ModuleManager.CROP_TECH, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
        return
    end
    --创建势力界面
    if uq.cache.crop:getMyCropLeaderId() ~= uq.cache.role.id then
        uq.fadeInfo(StaticData["local_text"]["world.war.power.des6"])
        return
    end
    local str_title = self._cropName
    network:sendPacket(Protocol.C_2_S_NATION_BATTLE_CREATE_POWER, {init_city_id = self._curInfo.ident, color_id = self._curFlagInfo.ident, len = string.len(str_title), power_name = str_title})
end

function CreatePowerInfo:dispose()
    services:removeEventListenersByTag("_onCraetePowerFailByInfo")
    CreatePowerInfo.super.dispose(self)
end

return CreatePowerInfo