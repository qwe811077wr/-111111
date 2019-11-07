local EquipChangeUi = class("EquipChangeUi", require('app.base.ChildViewBase'))
local EquipItem = require("app.modules.common.EquipItem")

EquipChangeUi.RESOURCE_FILENAME = "main_city/EquipChangeUI.csb"
EquipChangeUi.RESOURCE_BINDING = {
    ["Button_1"]            = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onClose"}}},
    ["Button_ok"]           = {["varname"] = "_btnOk",["events"] = {{["event"] = "touch",["method"] = "onBtnOk"}}},
    ["name_label"]          = {["varname"] = "_nameLabel"},
    ["equip_item"]          = {["varname"] = "_itemPanel"},
}

function EquipChangeUi:onCreate()
    EquipChangeUi.super.onCreate(self)
    self:parseView()
    self:initProtocal()
end

function EquipChangeUi:initProtocal()
    self._btnOk:setPressedActionEnabled(true)
    self._btnClose:setPressedActionEnabled(true)
    services:addEventListener(services.EVENT_NAMES.ON_SET_CHANGEUI_INFO, handler(self, self._onUpdateEquip), '_onUpdateEquipByChanges')
end

function EquipChangeUi:_onUpdateEquip(msg)
    self._equipInfo = msg.data.info
    self._generalsId = msg.data.id
    self._findNotEquip = msg.data.state
    if not self._equipInfo or next(self._equipInfo) == nil or not self._generalsId then
        return
    end
    self:setVisible(true)
    self:refreshPage()
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
end

function EquipChangeUi:onClose(event)
    if event.name == "ended" then
        self:setVisible(false)
    end
end

function EquipChangeUi:onBtnOk(event)
    if event.name ~= "ended" then
        return
    end
    if self._findNotEquip then
        network:sendPacket(Protocol.C_2_S_EQUIP_ITEM, {general_id = self._generalsId, item_id = self._equipInfo.db_id})
    else
        uq.runCmd('open_general_attribute', {{generals_id = self._generalsId, tabIndex = 2, index = 0}})
    end
    self:setVisible(false)
end

function EquipChangeUi:onExit()
    services:removeEventListenersByTag("_onUpdateEquipByChanges")
    EquipChangeUi.super:onExit()
end

return EquipChangeUi