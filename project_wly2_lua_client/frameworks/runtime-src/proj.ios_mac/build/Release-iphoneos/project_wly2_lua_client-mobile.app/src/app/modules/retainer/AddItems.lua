local AddItems = class("AddItems", require('app.base.ChildViewBase'))

AddItems.RESOURCE_FILENAME = "retainer/AddItems.csb"
AddItems.RESOURCE_BINDING = {
    ["add_pnl"]                   = {["varname"]="_pnlAdd"},
    ["add_pnl/Button_1"]          = {["varname"]="_btnAdd"},
    ["add_pnl/Text_1"]            = {["varname"]="_txtAdd"},
    ["apply_pnl"]                 = {["varname"]="_pnlApply"},
    ["apply_pnl/Button_2"]        = {["varname"]="_btnOk"},
    ["apply_pnl/Button_3"]        = {["varname"]="_btnCancel"},
    ["Panel_1/Text_3"]            = {["varname"]="_txtName"},
    ["Panel_1/Text_3_0"]          = {["varname"]="_txtGs"},
    ["Panel_1/Text_3_1"]          = {["varname"]="_txtLv"},
    ["Panel_1/Text_3_2"]          = {["varname"]="_txtJt"},
    ["Panel_1/Text_3_3"]          = {["varname"]="_txtServer"},
}

function AddItems:onCreate()
    AddItems.super.onCreate(self)
end

function AddItems:setData(data , is_add, is_suzerain)
    local data = data or {}
    self._pnlAdd:setVisible(is_add)
    self._pnlApply:setVisible(not is_add)
    if next(data) ~= nil then
        self._txtName:setString(data.name)
        self._txtGs:setString(tostring(data.force_value))
        self._txtLv:setString(tostring(data.level))
        self._txtJt:setString(tostring(data.crop_id))
    end
    if is_suzerain then
        self._txtAdd:setString(StaticData['local_text']['retainer.jojn.king'])
    else
        self._txtAdd:setString(StaticData['local_text']['retainer.jojn.courtier'])
    end
    self.data = data
    self.isSuzerain = is_suzerain
    self._btnAdd:addClickEventListenerWithSound(handler(self, self._onDealAdd))
    self._btnOk:addClickEventListenerWithSound(function ()
        self:dealOkOrCancel(0)
    end)
    self._btnCancel:addClickEventListenerWithSound(function ()
        self:dealOkOrCancel(1)
    end)
    self:parseView()
end

function AddItems:_onDealAdd()
    if next(self.data) == nil then
        return
    end
    if uq.cache.retainer:isAlrealyExist(self.data.id) then
        uq.fadeInfo(StaticData["local_text"]["retainer.not.own.operator"])
        return
    end
    local apply_type = 0
    if self.isSuzerain then
        if uq.cache.retainer:isLimitBecomeCourtier() then
            uq.fadeInfo(StaticData["local_text"]["retainer.limit.add.courtier"])
            return
        end
        if uq.cache.retainer:isMaxSuzerainNum() then
            uq.fadeInfo(StaticData["local_text"]["retainer.max.num.suzerain"])
            return
        end
    else
        if uq.cache.retainer:isLimitBecomeSuzerain() then
            uq.fadeInfo(StaticData["local_text"]["retainer.limit.add.suzerain"])
            return
        end
        if uq.cache.retainer:isMaxCourtierNum() then
            uq.fadeInfo(StaticData["local_text"]["retainer.max.num.courtier"])
            return
        end
        apply_type = 1
    end
    local data = {
        apply_type = apply_type,
        role_id = self.data.id,
    }
    network:sendPacket(Protocol.C_2_S_ZONG_APPLY, data)
end

function AddItems:dealOkOrCancel(op_type)
    if next(self.data) == nil then
        return
    end
    if uq.cache.retainer:isAlrealyExist(self.data.id) and op_type == 0 then
        uq.fadeInfo(StaticData["local_text"]["retainer.not.own.operator"])
        return
    end
    local apply_type = 0 --宗主
    if self.isSuzerain then
        if uq.cache.retainer:isMaxSuzerainNum() then
            uq.fadeInfo(StaticData["local_text"]["retainer.max.num.suzerain"])
            return
        end
    else
        if uq.cache.retainer:isMaxCourtierNum() then
            uq.fadeInfo(StaticData["local_text"]["retainer.max.num.courtier"])
            return
        end
        apply_type = 1 --属臣
    end
    local data = {
        op_type = op_type,
        apply_type = apply_type,
        role_id = self.data.id,
    }
    network:sendPacket(Protocol.C_2_S_ZONG_HANDLE_APPLY, data)
end

return AddItems