local JadeLevelFilter = class("GeneralsEquipInfo", require("app.base.PopupBase"))

JadeLevelFilter.RESOURCE_FILENAME = "generals/JadeComposeScreen.csb"
JadeLevelFilter.RESOURCE_BINDING = {
    ["Panel_item"]           = {["varname"] = "_panelItem"},
    ["btn_replace"]          = {["varname"] = "_btnOk",["events"] = {{["event"] = "touch",["method"] = "onBtnOk"}}},
}

function JadeLevelFilter:ctor(name, params)
    JadeLevelFilter.super.ctor(self, name, params)
    self._comfirmCallback = params.callback
    self._filerData = params.filter_data or {1, 2, 3, 4, 5}
end

function JadeLevelFilter:init()
    self:parseView()
    self:centerView()
    self:initUi()
end

function JadeLevelFilter:initUi()
    for i = 1, 5 do
        local item = self._panelItem:getChildByName("Panel_" .. i)
        item:setTag(i)
        item:getChildByName("Text_1"):setString(string.format(StaticData['local_text']['general.equip.jade.level.name'], i))
        local check_box = item:getChildByName("CheckBox_1")
        check_box:setSelected(self._filerData[i] ~= nil)
        check_box:addEventListener(function(sender)
            local state = sender:isSelected()
            if state then
                self._filerData[i] = i
            else
                self._filerData[i] = nil
            end
        end)
    end
end

function JadeLevelFilter:onBtnOk(event)
    if event.name ~= "ended" then
        return
    end
    if self._comfirmCallback then
        self._comfirmCallback(self._filerData)
    end
    self:dispose()
end

function JadeLevelFilter:dispose()
    JadeLevelFilter.super.dispose()
end

return JadeLevelFilter