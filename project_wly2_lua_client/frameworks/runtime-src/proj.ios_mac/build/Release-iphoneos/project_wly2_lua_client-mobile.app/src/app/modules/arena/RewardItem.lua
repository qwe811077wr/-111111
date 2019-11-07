local RewardItem = class("RewardItem", require('app.base.ChildViewBase'))

RewardItem.RESOURCE_FILENAME = "arena/RewardItem.csb"
RewardItem.RESOURCE_BINDING = {
    ["Text_1"]         = {["varname"] = "_txtNum"},
    ["Item_0004_26_0"] = {["varname"] = "_spriteIcon"},
    ["Panel_1"]        = {["varname"] = "_panelBg",["events"] = {{["event"] = "touch",["method"] = "onTouch"}}}
}

function RewardItem:onCreate()
    RewardItem.super.onCreate(self)
end

function RewardItem:setData(rwd_str)
    local parts = string.split(rwd_str, ";")

    local type = tonumber(parts[1])
    local num = tonumber(parts[2])
    local id = tonumber(parts[3])

    self._data = StaticData.getCostInfo(type, id)
    local icon = self._data.icon

    self._spriteIcon:setTexture('img/common/item/' .. icon)
    self._txtNum:setString(num)

    self._info = {
        type = type,
        id = id,
        num = num
    }
end

function RewardItem:onTouch(event)
    if event.name ~= "ended" then
        return
    end
    uq.showItemTips(self._info)
end

function RewardItem:setTouch(flag)
    self._panelBg:setVisible(flag)
end

return RewardItem