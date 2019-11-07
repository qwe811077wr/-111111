local EquipChangeUi = class("EquipChangeUi", require('app.base.ChildViewBase'))
local EquipItem = require("app.modules.common.EquipItem")

EquipChangeUi.RESOURCE_FILENAME = "main_city/EquipChangeUI.csb"
EquipChangeUi.RESOURCE_BINDING = {
    ["Button_1"]            = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onClose",["sound_id"] = 0}}},
    ["Button_ok"]           = {["varname"] = "_btnOk",["events"] = {{["event"] = "touch",["method"] = "onBtnOk",["sound_id"] = 0}}},
    ["name_label"]          = {["varname"] = "_nameLabel"},
    ["equip_item"]          = {["varname"] = "_itemPanel"},
}

function EquipChangeUi:onCreate()
    EquipChangeUi.super.onCreate(self)
    self:parseView()
    self:initProtocal()
    self._arrInfo = {}
end

function EquipChangeUi:initProtocal()
    self._btnOk:setPressedActionEnabled(true)
    self._btnClose:setPressedActionEnabled(true)
    services:addEventListener(services.EVENT_NAMES.ON_SET_CHANGEUI_INFO, handler(self, self.setInfo), '_onUpdateEquipByChanges' .. tostring(self))
    services:addEventListener(services.EVENT_NAMES.ON_UPDATE_GENERALEFF, handler(self,self._onChangeEquipment), '_onEquipMentDress' .. tostring(self))
    services:addEventListener(services.EVENT_NAMES.ON_EQUIPMENT_BREAK_THROUGH, handler(self, self._onChangeEquipment), '_onRisingSuccess' .. tostring(self))
    network:addEventListener(Protocol.S_2_C_EQUIPMENT_MULTIPLE_SELL, handler(self, self._onMultipleDecompose), '_onMultipleDecompose' .. tostring(self))
end

function EquipChangeUi:_onMultipleDecompose(msg)
    self:_onChangeEquipment({data = msg.data.dbid})
end

function EquipChangeUi:setInfo(msg)
    local info = msg.data
    for k, v in ipairs(info) do
        table.insert(self._arrInfo, 1, v)
    end

    while #self._arrInfo > 10 do
        table.remove(self._arrInfo, 11)
    end
    self:findInfo()
end

function EquipChangeUi:_onChangeEquipment(msg)
    if not self:isVisible() then
        return
    end
    local ids = msg.data
    for k, v in ipairs(ids) do
        for index, info in ipairs(self._arrInfo) do
            if v == info.db_id then
                table.remove(self._arrInfo, index)
                break
            end
        end
    end
    self:findInfo()
end

function EquipChangeUi:findInfo()
    if next(self._arrInfo) == nil then
        self:setVisible(false)
        return
    end
    local find_info = false
    local formation_info = uq.cache.formation:getDefaultFormation()
    self._generalsId = nil
    self._findNotEquip = false
    while not find_info and next(self._arrInfo) ~= nil do
        local info = self._arrInfo[1]
        local effect_value = 10000
        for k, v in ipairs(formation_info.general_loc) do
            if v.general_id and v.general_id ~= 0 then
                local equip_info = uq.cache.equipment:getInfoByTypeAndGeneralId(info.xml.type, v.general_id)
                if not equip_info then
                    find_info = true
                    self._generalsId = v.general_id
                    self._findNotEquip = true
                    break
                else
                    if info.xml.effectValue > equip_info.xml.effectValue and equip_info.xml.effectValue < effect_value then
                        find_info = true
                        effect_value = equip_info.xml.effectValue
                        self._generalsId = v.general_id
                    end
                end
            end
        end
        if not find_info then
            table.remove(self._arrInfo, 1)
        end
    end

    self._equipInfo = self._arrInfo[1]
    self:setVisible(self._equipInfo ~= nil)
    if self._equipInfo then
        self:refreshPage()
    end
end


function EquipChangeUi:refreshPage()
    self._itemPanel:removeAllChildren()
    self._equipInfo.id = self._equipInfo.temp_id
    self._equipInfo.type = uq.config.constant.COST_RES_TYPE.EQUIP
    self._itemPanel:removeAllChildren()
    local euqip_item = EquipItem:create({info = self._equipInfo})
    euqip_item:setPosition(cc.p(self._itemPanel:getContentSize().width * 0.5,self._itemPanel:getContentSize().height * 0.5))
    euqip_item:setTouchEnabled(true)
    euqip_item:addClickEventListenerWithSound(function(sender)
        local info = sender:getEquipInfo()
        uq.ModuleManager:getInstance():show(uq.ModuleManager.ITEM_TIPS_MODULE,{info = info})
    end)
    self._itemPanel:addChild(euqip_item)
    local xml_info = StaticData['items'][self._equipInfo.temp_id]
    self._nameLabel:setString(xml_info.name)

    local xml_info = StaticData.getCostInfo(uq.config.constant.COST_RES_TYPE.EQUIP, self._equipInfo.temp_id)
    local item_quality_info = StaticData['types'].ItemQuality[1].Type[tonumber(xml_info.qualityType)]
    if item_quality_info then
        self._nameLabel:setTextColor(uq.parseColor(item_quality_info.color))
    end
end

function EquipChangeUi:onClose(event)
    if event.name == "ended" then
        self._arrInfo = {}
        self._equipInfo = nil
        self:setVisible(false)
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BACK)
    end
end

function EquipChangeUi:onBtnOk(event)
    if event.name ~= "ended" then
        return
    end
    uq.playSoundByID(22)
    if self._findNotEquip then
        network:sendPacket(Protocol.C_2_S_EQUIP_ITEM, {general_id = self._generalsId, item_id = self._equipInfo.db_id})
        table.remove(self._arrInfo, 1)
    else
        uq.runCmd('open_general_attribute', {{generals_id = self._generalsId, tabIndex = 2, index = 0}})
        table.remove(self._arrInfo, 1)
        self:findInfo()
    end
end

function EquipChangeUi:onExit()
    services:removeEventListenersByTag("_onUpdateEquipByChanges" .. tostring(self))
    services:removeEventListenersByTag('_onEquipMentDress' .. tostring(self))
    services:removeEventListenersByTag('_onRisingSuccess' .. tostring(self))
    network:removeEventListenerByTag('_onMultipleDecompose' .. tostring(self))
    EquipChangeUi.super:onExit()
end

return EquipChangeUi