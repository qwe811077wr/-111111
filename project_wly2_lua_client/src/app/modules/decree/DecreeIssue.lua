local DecreeIssue = class("DecreeIssue", require('app.base.PopupBase'))
local EquipItem = require("app.modules.common.EquipItem")

DecreeIssue.RESOURCE_FILENAME = "decree/DecreeIssue.csb"
DecreeIssue.RESOURCE_BINDING = {
    ["cost_num_txt"]                           = {["varname"] = "_txtNumCost"},
    ["now_num_txt"]                            = {["varname"] = "_txtNumNow"},
    ["close_btn"]                              = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onClose"}}},
    ["Button_2"]                               = {["varname"] = "_btnOk",["events"] = {{["event"] = "touch",["method"] = "onOk"}}},
    ["items_node"]                             = {["varname"] = "_nodeItems"},
    ["Panel_2"]                                = {["varname"] = "_pnl"},
    ["limit_txt"]                              = {["varname"] = "_txtLimit"},
}

function DecreeIssue:ctor(name, params)
    DecreeIssue.super.ctor(self, name, params)
    self:centerView()
    self:parseView()
    self._data = params.data or {}
    self._cost = self._data.cost or 1
    self._maxNum = math.floor(uq.cache.decree:getNumDecree() / self._cost)
    self._num = math.min(self._maxNum, 1)
    self._isReward = false
    self:setLayerColor(0.4)
    self:initLayer()
end

function DecreeIssue:initLayer()
    local size = self._pnl:getContentSize()
    self._editBox = ccui.EditBox:create(cc.size(size.width - 5, size.height), '')
    self._editBox:setAnchorPoint(cc.p(0.5, 0.5))
    self._editBox:setFontName("font/hwkt.ttf")
    self._editBox:setFontSize(22)
    self._editBox:setMaxLength(2)
    self._editBox:setFontColor(cc.c3b(255, 255, 255))
    self._editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._editBox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self._editBox:registerScriptEditBoxHandler(function(event, sender) self:editboxHandle(event, sender) end)
    self._editBox:setPlaceholderFontName("Arial")
    self._editBox:setPlaceholderFontSize(22)
    self._editBox:setPosition(cc.p(size.width / 2 + 5, size.height / 2))
    self._pnl:addChild(self._editBox)
    self._editBox:setText(tostring(self._num))
    self._txtNumNow:setString(tostring(self._maxNum))
    self:refreshLayer()
end

function DecreeIssue:editboxHandle(event, sender)
    if event == "changed" or event == "ended" then
        self:dealText(event)
    end
end

function DecreeIssue:refreshLayer()
    self._txtNumCost:setString(tostring(self._num * self._cost))
    self._nodeItems:removeAllChildren()
    local reward = uq.cache.decree:getDecreeReWard(self._data.ident)
    local is_lock = self._num ~= 0 and next(reward) ~= nil
    self._txtLimit:setVisible(not is_lock)
    self._isReward = is_lock
    if not is_lock then
        return
    end
    for i, v in ipairs(reward) do
        local euqip_item = EquipItem:create({info = {["type"] = v.type, ["id"] = v.id, ["num"] = v.num * self._num}})
        euqip_item:setTouchEnabled(true)
        euqip_item:setScale(0.6)
        euqip_item:addClickEventListener(function(sender)
            local info = sender:getEquipInfo()
            uq.showItemTips(info)
        end)
        euqip_item:setPosition(cc.p((i - 1) * 80, 0))
        self._nodeItems:addChild(euqip_item)
    end
end

function DecreeIssue:dealText(event)
    local str = self._editBox:getText()
    if event == "changed" and str == "" then
        return
    end
    local num = self:dealNum(str)
    self._editBox:setText(tostring(num))
    self._num = num
    if event == "ended" then
        self:refreshLayer()
    end
end

function DecreeIssue:dealNum(str)
    if not str or str == "" then
        return math.min(self._maxNum, 1)
    end
    return math.min(math.max(tonumber(str), math.min(self._maxNum, 1)), self._maxNum)
end

function DecreeIssue:onClose(event)
   if event.name ~= "ended" then
        return
    end
    self:disposeSelf()
end

function DecreeIssue:onOk(event)
   if event.name ~= "ended" then
        return
    end
    if self._num == 0 then
        uq.fadeInfo(StaticData["local_text"]["decree.not.enought"])
        return
    end
    if not self._isReward then
        uq.fadeInfo(StaticData["local_text"]["decree.not.open"])
        return
    end
    network:sendPacket(Protocol.C_2_S_DECREE, {id = self._data.ident, count = self._num})
    self:disposeSelf()
end

return DecreeIssue