local DailyInstanceItem = class("DailyInstanceItem", require('app.base.ChildViewBase'))

DailyInstanceItem.RESOURCE_FILENAME = "daily_instance/DailyInstanceItem.csb"
DailyInstanceItem.RESOURCE_BINDING = {
    ["Image_1"]                 = {["varname"] = "_imgBg"},
    ["Image_type"]              = {["varname"] = "_imgType"},
    ["Button_3"]                = {["varname"] = "_btnSweep",["events"] = {{["event"] = "touch",["method"] = "_onBtnBattle"}}},
    ["Text_1"]                  = {["varname"] = "_nameLabel"},
    ["Panel_mash"]              = {["varname"] = "_panelMash"},
}

function DailyInstanceItem:ctor(name, params)
    DailyInstanceItem.super.ctor(self, name, params)
end

function DailyInstanceItem:onCreate()
    DailyInstanceItem.super.onCreate(self)
    self:parseView()
end

function DailyInstanceItem:setInfo(info)
    self._info = info
    self._nameLabel:setString(self._info.name)
    self._nameLabel:setTextColor(uq.parseColor(self._info.color))
    self._imgType:loadTexture("img/daily_instance/" .. self._info.icon)
    self._panelMash:setVisible(self._info.max_difficulty < self._info.ident)
    self._btnSweep:setVisible(self._info.max_difficulty >= self._info.ident)
    self._btnSweep:setEnabled(self._info.max_difficulty > self._info.ident)
    local ShaderEffect = uq.ShaderEffect
    if self._info.max_difficulty > self._info.ident then
        ShaderEffect:removeGrayButton(self._btnSweep)
    else
        ShaderEffect:addGrayButton(self._btnSweep)
    end
end

function DailyInstanceItem:checkTouched(point)
    local btn_size = self._btnSweep:getContentSize()
    local pos = self._btnSweep:convertToNodeSpace(point)
    local btn_rect = cc.rect(0, 0, btn_size.width, btn_size.height)
    if cc.rectContainsPoint(btn_rect, pos) then
        uq.fadeInfo(StaticData["local_text"]["daily.instance.des13"])
        return false
    end
    local size = self._imgBg:getContentSize()
    local rect = cc.rect(0, 0, size.width, size.height)

    return cc.rectContainsPoint(rect, pos)
end

function DailyInstanceItem:getInfo()
    return self._info
end

function DailyInstanceItem:_onBtnBattle(event)
    if event.name ~= "ended" then
        return
    end
    network:sendPacket(Protocol.C_2_S_DAILY_INSTANCE_SWEEP, {group_id = self._info.indtance_id, instance_id = self._info.ident})
end


return DailyInstanceItem