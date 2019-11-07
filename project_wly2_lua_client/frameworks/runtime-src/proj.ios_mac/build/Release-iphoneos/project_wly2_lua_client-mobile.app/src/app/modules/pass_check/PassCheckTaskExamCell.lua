local PassCheckTaskExamCell = class("PassCheckTaskExamCell", require('app.base.ChildViewBase'))
local EquipItem = require("app.modules.common.EquipItem")

PassCheckTaskExamCell.RESOURCE_FILENAME = "pass_check/PassCheckTaskExamCell.csb"
PassCheckTaskExamCell.RESOURCE_BINDING = {
    ["Node_1"]     = {["varname"] = "_nodeBase"},
    ["bg_img"]     = {["varname"] = "_imgBg"},
    ["name_txt"]   = {["varname"] = "_txtName"},
    ["finish_img"] = {["varname"] = "_imgStateBg"},
    ["Image_4"]    = {["varname"] = "_imgState"},
    ["items_node"] = {["varname"] = "_nodeItems"},
    ["Image_1"]    = {["varname"] = "_imgSelect"},
    ["Text_2_0_0"] = {["varname"] = "_txtScore"},
}

function PassCheckTaskExamCell:ctor(name, params)
    PassCheckTaskExamCell.super.ctor(self, name, params)
    self:parseView()
    self:setSelectVis(false)
end

function PassCheckTaskExamCell:setData(data, idx, func)
    self._data = data
    local data = data or {}
    if not data or next(data) == nil then
        return
    end
    self._txtName:setString(data.title)
    self._imgBg:addClickEventListenerWithSound(function()
        if func then
            func(idx)
        end
    end)
    local item_data = uq.RewardType.new(data.reward)
    self._equiItem = require("app.modules.common.EquipItem"):create({info = item_data:toEquipWidget()})
    self._nodeItems:addChild(self._equiItem)
    self._equiItem:enableEvent()
    self._equiItem:setSwallow(false)
    self._equiItem:setScale(0.8)

    self._imgBg:loadTexture('img/pass_check/' .. data.bgImg)
    self._txtScore:setString('+' .. data.progress)

    self:refreshState()
end

function PassCheckTaskExamCell:refreshState()
    local state = uq.cache.pass_check._passTask[self:getTaskID()].state
    self._imgStateBg:setVisible(false)
    self._imgState:ignoreContentAdaptWithSize(true)
    if state == uq.config.constant.TYPE_PASS_CARD_TASK_STATE.ST_ACCEPT then
        self._imgStateBg:setVisible(true)
        self._imgState:loadTexture('img/common/ui/' .. 's04_00046.png')
    elseif state == uq.config.constant.TYPE_PASS_CARD_TASK_STATE.ST_FINISHED then
        self._imgStateBg:setVisible(true)
        self._imgState:loadTexture('img/pass_check/' .. 's04_00047.png')
    elseif state == uq.config.constant.TYPE_PASS_CARD_TASK_STATE.ST_DRAWD then
        self._imgStateBg:setVisible(true)
        self._imgState:loadTexture('img/common/ui/' .. 's04_00042.png')
    elseif state == uq.config.constant.TYPE_PASS_CARD_TASK_STATE.ST_ABANDON then
        self._imgStateBg:setVisible(true)
        self._imgState:loadTexture('img/pass_check/' .. 's04_00045.png')
    end
end

function PassCheckTaskExamCell:setSelectVis(flag)
    self._imgSelect:setVisible(flag)
end

function PassCheckTaskExamCell:getTaskID()
    return self._data.ident
end

function PassCheckTaskExamCell:showAction()
    uq.intoAction(self._nodeBase)
end

return PassCheckTaskExamCell