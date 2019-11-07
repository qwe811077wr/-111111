local InstanceWarPowerWin = class("InstanceWarPowerWin", require('app.base.PopupBase'))

InstanceWarPowerWin.RESOURCE_FILENAME = "instance_war/InstanceWarPowerWin.csb"
InstanceWarPowerWin.RESOURCE_BINDING = {
    ["Image_3"]        = {["varname"] = "_imgScore"},
    ["Text_2_0"]       = {["varname"] = "_txtRound"},
    ["Text_2_0_1"]     = {["varname"] = "_txtCity"},
    ["Text_2_0_0"]     = {["varname"] = "_txtPowerFight"},
    ["Text_2_0_2"]     = {["varname"] = "_txtGeneral"},
    ["drop_item_list"] = {["varname"] = "_dropList"},
    ["Button_1"]       = {["varname"] = "_btnConfirm",["events"] = {{["event"] = "touch",["method"] = "onConfirm"}}},
}

function InstanceWarPowerWin:onCreate()
    InstanceWarPowerWin.super.onCreate(self)
    self:centerView()
    self:parseView()
    self:setLayerColor()
end

function InstanceWarPowerWin:setData(data, call_back)
    self._callback = call_back
    self._txtRound:setString(data.round)
    self._txtCity:setString(data.city_num)
    self._txtPowerFight:setString(data.wipeout)
    self._txtGeneral:setString(data.general_num)

    self._dropList:setScrollBarEnabled(false)
    for k, item in ipairs(data.rwds) do
        local reward_str = string.format('%d;%d;%d', item.type, item.num, item.paraml)
        local panel = uq.createPanelOnly('instance.DropItem')
        panel:setData(reward_str)
        panel:setSwallow(false)
        panel:setGameMode(uq.config.constant.GAME_MODE.INSTANCE_WAR)
        local size = panel:getContentSize()
        panel:setPosition(cc.p(size.width / 2 + 10, size.height / 2 - 8))

        local widget = ccui.Widget:create()
        widget:setContentSize(cc.size(size.width + 20, size.height))
        widget:addChild(panel)
        widget:setTouchEnabled(true)
        self._dropList:pushBackCustomItem(widget)
    end

    local strs = {'s04_00016.png', 's04_00015.png', 's04_00014.png', 's04_00013.png', 's04_00012.png', 's04_00011.png'}
    if strs[data.score] then
        self._imgScore:setVisible(true)
        self._imgScore:loadTexture('img/generals/' .. strs[data.score])
    else
        self._imgScore:setVisible(false)
    end
end

function InstanceWarPowerWin:onExit()
    InstanceWarPowerWin.super.onExit(self)
end

function InstanceWarPowerWin:onConfirm(event)
    if event.name ~= "ended" then
        return
    end
    if self._callback then
        self._callback()
    end
    self:disposeSelf()
end

return InstanceWarPowerWin