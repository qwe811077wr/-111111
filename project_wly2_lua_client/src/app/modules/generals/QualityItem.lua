local QualityItem = class("QualityItem", require('app.base.ChildViewBase'))

QualityItem.RESOURCE_FILENAME = "generals/QualityItem.csb"
QualityItem.RESOURCE_BINDING = {
    ["Text_1"]      = {["varname"]="_txtDec"},
    ["Text_boss"]   = {["varname"]="_txtBoss"},
    ["Text_1_0"]    = {["varname"]="_txtWar"},
    ["Image_1"]     = {["varname"]="_imgIcon"},
    ["Button_1"]    = {["varname"]="_btnJump", ["events"] = {{["event"] = "touch",["method"] = "onRunCmd"}}},
}

function QualityItem:onCreate()
    QualityItem.super.onCreate(self)
    self:parseView()
end

function QualityItem:setInfo(info)
    self._info = info
    if not info then
        return
    end
    if self._info.is_special then
        self:setData(self._info.id)
    else
        self:setItemData()
    end
end

function QualityItem:setData(crad_id)
    local instance_id = tonumber(string.sub(tostring(crad_id), 1, 3))
    local tab = StaticData.load('instance/Map_' .. instance_id).Map[instance_id].Object[tonumber(crad_id)]
    if tab and tab.Name then
        self._txtBoss:setString(tab.Name)
    end
    local chapter = StaticData['instance'][instance_id]
    if chapter and chapter.name then
        self._txtDec:setString("[" .. chapter.name .. "]")
    end
    self._imgIcon:loadTexture("img/generals/" .. StaticData['module'][21].jumpIcon)
end

function QualityItem:onRunCmd(event)
    if event.name ~= "ended" then
        return
    end
    if self._info.is_special then
        uq.cache.instance:openSweep(tonumber(string.sub(tostring(self._info.id), 1, 3)), tonumber(self._info.id))
    else
        uq.jumpToModule(tonumber(self._info.id))
    end
end

function QualityItem:setItemData()
    local pos_y = self._txtDec:getPositionY()
    self._txtDec:setPositionY(pos_y - 20)
    self._txtBoss:setVisible(false)
    self._txtWar:setVisible(false)

    self._data = StaticData['module'][tonumber(self._info.id)]
    if not self._data then
        return
    end
    self._imgIcon:loadTexture("img/generals/" .. self._data.jumpIcon)
    self._txtDec:setString(self._data.jumpDescription)
    self._btnJump:setVisible(self._data.jumpType ~= 2)
end

return QualityItem