local CreatePowerModule = class("CreatePowerModule", require("app.base.ModuleBase"))
local CreatePowerItem = require("app.modules.create_power.CreatePowerItem")

CreatePowerModule.RESOURCE_FILENAME = "create_power/CreatePowerModule.csb"

CreatePowerModule.RESOURCE_BINDING  = {
    ["Panel_1"]                                 ={["varname"] = "_panelPress"},
    ["Panel_1/Node_city"]                       ={["varname"] = "_nodeCity"},
    ["Panel_1/Node_2"]                          ={["varname"] = "_nodeTopMiddle"},
    ["Panel_1/Node_5"]                          ={["varname"] = "_nodeLeftTop"},
    ["Panel_1/node_middle_bottom"]              ={["varname"] = "_nodeBottomMiddle"},
    ["Panel_1/node_middle_bottom/city_name"]    ={["varname"] = "_cityNameLabel"},
    ["Panel_1/Node_5/back_btn"]                 ={["varname"] = "_BtnClose",["events"] = {{["event"] = "touch",["method"] = "onCloseBtn"}}},
    ["Panel_1/node_middle_bottom/Button_next"]  ={["varname"] = "_BtnNext",["events"] = {{["event"] = "touch",["method"] = "onNextBtn"}}},
    ["Panel_1/node_middle_bottom/des_label"]    ={["varname"] = "_desLabel"},
    ["Panel_1/des"]                             ={["varname"] = "_stateLabel"},
}

function CreatePowerModule:ctor(name, args)
    CreatePowerModule.super.ctor(self, name, args)
    self._cityInfoArray = {}
    self._canUsedFlag = {}
    self._cityItemArray = {}
    self._curInfo = nil
end

function CreatePowerModule:init()
    self:parseView()
    self:centerView()
    self:initProtocol()
    self._nodeBottomMiddle:setVisible(false)
    self._panelPress:setTouchEnabled(true)
    self._panelPress:addClickEventListener(function(sender)
        self._nodeBottomMiddle:setVisible(false)
    end)
    self:adaptBgSize()
    self:adaptNode()
end

function CreatePowerModule:updateDialog()
    self._nodeCity:removeAllChildren()
    local scale = 0.3
    local used_num = 0
    for k, v in pairs(self._cityInfoArray) do
        if v then
            local item = CreatePowerItem:create({info = v})
            self._nodeCity:addChild(item)
            item:setTouchEnabled(true)
            item:addClickEventListener(function(sender)
                local info = sender:getInfo()
                if info.used or info.type ~= 1 then
                    return
                end
                self._curInfo = sender:getInfo()
                self:showInfo()
            end)
            self._cityItemArray[v.ident] = item
            if v.type == 1 and not v.used then
                used_num = used_num + 1
            end
        end
    end
    self._stateLabel:setVisible(used_num == 0)
end

function CreatePowerModule:showInfo()
    if #self._canUsedFlag == 0 then
        uq.fadeInfo(StaticData["local_text"]["world.war.power.des1"])
        return
    end
    self._nodeBottomMiddle:setVisible(true)
    self._cityNameLabel:setString(self._curInfo.name)
    self._desLabel:setString(self._curInfo.desc)
end

function CreatePowerModule:_onBattleLoadInitCity(msg)
    local used_color = {}
    local used_city = {}
    local crop_data = uq.cache.crop:getCropData()
    for k, v in pairs(crop_data) do
        used_color[v.color_id] = true
    end

    for k, v in pairs(msg.data.init_citys) do
        if v.crop_id > 0 then
            used_city[v.city_id] = true
        end
    end
    for k, v in ipairs(StaticData['world_flag']) do
        if not used_color[v.ident] then
            table.insert(self._canUsedFlag, v)
        end
    end
    for k, v in pairs(StaticData['world_city']) do
        if v.type == 1 or v.type == 5 then
            v.used = used_city[v.ident]
            self._cityInfoArray[v.ident] = v
        end
    end
    self:updateDialog()
end

function CreatePowerModule:initProtocol()
    services:addEventListener(services.EVENT_NAMES.ON_CREATE_POWER_FAIL, handler(self, self._onCraetePowerFail), "_onCraetePowerFailByModule")
    network:addEventListener(Protocol.S_2_C_NATION_BATTLE_LOAD_INIT_CITY, handler(self, self._onBattleLoadInitCity), '_onBattleLoadInitCity')
    network:sendPacket(Protocol.C_2_S_NATION_BATTLE_LOAD_INIT_CITY)
end

function CreatePowerModule:_onCraetePowerFail(msg)
    if msg.data.ret == 1 then
        self._cityInfoArray[self._curInfo.ident].used = true
        self:updateDialog()
    end
end

function CreatePowerModule:onNextBtn(event)
    if event.name ~= 'ended' then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.CREATE_POWER_INFO, {info = self._curInfo, flag_array = self._canUsedFlag})
end

function CreatePowerModule:onCloseBtn(event)
    if event.name ~= 'ended' then
        return
    end
    self:disposeSelf()
end

function CreatePowerModule:dispose()
    services:removeEventListenersByTag("_onCraetePowerFailByModule")
    network:removeEventListenerByTag("_onBattleLoadInitCity")
    CreatePowerModule.super.dispose(self)
end

return CreatePowerModule
