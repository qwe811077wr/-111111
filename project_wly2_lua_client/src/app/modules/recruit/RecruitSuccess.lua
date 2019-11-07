local RecruitSuccess = class("RecruitSuccess", require('app.base.PopupBase'))

RecruitSuccess.RESOURCE_FILENAME = "recruit/RecruitSuccess.csb"
RecruitSuccess.RESOURCE_BINDING = {
    ["dec_txt"]                        = {["varname"] = "_txtDec"},
    ["Panel_1"]                        = {["varname"] = "_pnlClose"},
}

function RecruitSuccess:ctor(name, params)
    RecruitSuccess.super.ctor(self, name, params)
    self:centerView()
    self:parseView()

    self._data = params.data or {}
    self._info = self._data.info or {}
    self:initLayer()
end

function RecruitSuccess:initLayer()
    local name = self:getName()
    local str = self._info.succeed == 1 and StaticData['local_text']['recruit.gift.success'] or StaticData['local_text']['recruit.gift.fail']
    self._txtDec:setHTMLText(string.format(str, name))
    self._pnlClose:addClickEventListenerWithSound(function()
        if self._info.succeed == 1 and id ~= 0 then
            local info = {info = self._info.info[1].id, is_new = true}
            uq.cache.generals:clearNewGenerals()
            uq.showNewGenerals(info, false)
            uq.refreshNextNewGeneralsShow()
        end
        self:disposeSelf()
    end)
end

function RecruitSuccess:getName()
    if self._info and self._info.info and self._info.info[1] and self._info.info[1].name then
        return self._info.info[1].name
    end
    return ""
end


return RecruitSuccess