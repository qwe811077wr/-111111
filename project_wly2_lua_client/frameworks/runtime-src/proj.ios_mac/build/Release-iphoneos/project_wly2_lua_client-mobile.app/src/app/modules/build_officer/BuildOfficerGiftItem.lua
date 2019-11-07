local BuildOfficerGiftItem = class("BuildOfficerGiftItem", require('app.base.ChildViewBase'))

BuildOfficerGiftItem.RESOURCE_FILENAME = "build_officer/BuildOfficerGiftItem.csb"
BuildOfficerGiftItem.RESOURCE_BINDING = {
    ["Text_1"]      = {["varname"] = "_txtDesc"},
    ["Node_2"]      = {["varname"] = "_nodeBuy"},
    ["Node_1"]      = {["varname"] = "_nodeItem"},
    ["Node_2_0"]    = {["varname"] = "_nodeSend"},
    ["panel_touch"] = {["varname"] = "_panelTouch",["events"] = {{["event"] = "touch",["method"] = "onSend"}}},
    ["panel_buy"]   = {["varname"] = "_panelBuy",["events"] = {{["event"] = "touch",["method"] = "onBuy"}}},
}

function BuildOfficerGiftItem:onCreate()
    BuildOfficerGiftItem.super.onCreate(self)

    self._eventTag = services.EVENT_NAMES.ON_CONSUME_RES_CHANGE .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_CONSUME_RES_CHANGE, handler(self, self.refreshPage), self._eventTag)
end

function BuildOfficerGiftItem:refreshPage()
    self:setData(self._data, self._generalId)
end

function BuildOfficerGiftItem:setData(xml_data, general_id)
    self._generalId = general_id
    self._data = xml_data
    self._txtDesc:setHTMLText(string.format("<font color='#ffec69'>-%d</font>%s", xml_data.reduceTime, StaticData['local_text']['label.minute']))

    local num = uq.cache.role:getResNum(uq.config.constant.COST_RES_TYPE.MATERIAL, xml_data.materialId)
    self._nodeBuy:setVisible(num == 0)
    self._nodeSend:setVisible(num > 0)

    local info = {}
    info.type = uq.config.constant.COST_RES_TYPE.MATERIAL
    info.id = xml_data.materialId
    info.num = num

    local equip_item = self._nodeItem:getChildByName('equip_item')
    if not equip_item then
        equip_item = require("app.modules.common.EquipItem"):create({info = info})
        equip_item:setName('equip_item')
        self._nodeItem:addChild(equip_item)
    end

    equip_item:setNameVisible(num > 0)
    equip_item:setNameString(num)
end

function BuildOfficerGiftItem:onExit()
    services:removeEventListenersByTag(self._eventTag)
    BuildOfficerGiftItem.super.onExit(self)
end

--clear
function BuildOfficerGiftItem:onSend(event)
    if event.name ~= "ended" then
        return
    end

    network:sendPacket(Protocol.C_2_S_GENERAL_CLEAR_TIRED, {general_id = self._generalId, ident = self._data.ident, num = 1})
end

function BuildOfficerGiftItem:onBuy(event)
    if event.name ~= "ended" then
        return
    end

    local info = {xml = {}}
    info.type = 9
    info.num = 99
    info.discount = 1
    info.ident = self._data.ident
    info.xml.cost = self._data.cost
    info.xml.buy = string.format('%d;%d;%d', uq.config.constant.COST_RES_TYPE.MATERIAL, 0, self._data.materialId)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.GENERAL_NUM_BUY_ITEM, {info = info})
end

return BuildOfficerGiftItem