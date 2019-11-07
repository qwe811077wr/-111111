local EquipResourceItem = class("EquipResourceItem", require("app.base.ChildViewBase"))
local EquipItem = require("app.modules.common.EquipItem")

EquipResourceItem.RESOURCE_FILENAME = "generals/EquipFromItem.csb"
EquipResourceItem.RESOURCE_BINDING = {
    ["Panel_1"]                   = {["varname"] = "_panelItem"},
    ["Text_1"]                    = {["varname"] = "_txtName"},
    ["Text_boss"]                 = {["varname"] = "_txtNum"},
    ["Text_1_0"]                  = {["varname"] = "_txtHead"},
    ["Button_1"]                  = {["varname"] = "_btnRunCmd", ["events"] = {{["event"] = "touch",["method"] = "_onJump"}}},
}

function EquipResourceItem:ctor()
    EquipResourceItem.super.ctor(self)
end

function EquipResourceItem:onCreate()
    self:parseView()
end

function EquipResourceItem:setInfo(info)
    self._info = info
    self:refreshPage()
end

function EquipResourceItem:refreshPage()
    if not self._info then
        return
    end
    self._data = StaticData['items'][self._info.id]
    self._txtName:setString(self._data.name)
    local quality_info = StaticData['types'].ItemQuality[1].Type[tonumber(self._data.qualityType)]
    if not quality_info then
        return
    end
    self._txtName:setTextColor(uq.parseColor("#" .. quality_info.color))
    local type_xml  = StaticData['types'].Effect[1].Type[self._data.effectType]
    if type_xml then
        self._txtHead:setString(StaticData['local_text']['label.state.init'] .. type_xml.name)
    end
    self._txtNum:setString('+' .. self._data.effectValue)

    local item = EquipItem:create({info = self._info})
    local size = item:getContentSize()
    local scale = 0.9
    item:setScale(scale)
    item:setPosition(cc.p(size.width * scale / 2, size.height * scale / 2))
    self._panelItem:addChild(item)
end

function EquipResourceItem:_onJump(event)
    if event.name ~= "ended" then
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.INSIGHT_RES_FROM_MODULE, self._info)
end

function EquipResourceItem:dispose()
    EquipResourceItem.super.dispose(self)
end

return EquipResourceItem