local RecruitItems = class("RecruitItems", require('app.base.ChildViewBase'))

RecruitItems.RESOURCE_FILENAME = "recruit/RecruitBoxs.csb"
RecruitItems.RESOURCE_BINDING = {
    ["Node_1"]                     = {["varname"] = "_nodeBase"},
    ["recruit_node"]               = {["varname"] = "_nodeRecruit"},
    ["time_txt"]                   = {["varname"] = "_txtTime"},
    ["recruit_txt"]                = {["varname"] = "_txtRecruit"},
    ["recruit_btn"]                = {["varname"] = "_btnRecruit"},
    ["finish_txt"]                 = {["varname"] = "_txtFinish"},
    ["dec_1_txt"]                  = {["varname"] = "_txtDec1"},
    ["dec_2_txt"]                  = {["varname"] = "_txtDec2"},
    ["dec_3_txt"]                  = {["varname"] = "_txtDecValue1"},
    ["dec_4_txt"]                  = {["varname"] = "_txtDecValue2"},
    ["dec_5_txt"]                  = {["varname"] = "_txtDecValue3"},
    ["dec_6_txt"]                  = {["varname"] = "_txtDec6"},
    ["dec_7_txt"]                  = {["varname"] = "_txtDec7"},
    ["dec_8_txt"]                  = {["varname"] = "_txtDec8"},
    ["dec_9_txt"]                  = {["varname"] = "_txtDec9"},
}

function RecruitItems:onCreate()
    RecruitItems.super.onCreate(self)
    self:parseView()
    self:initLayer()
    self._data = {}
end

function RecruitItems:setData(data)
    self._data = data or {}
    if not self._data or next(self._data) == nil then
        return
    end
    self._txtDec1:setString(self._data.name)
    self._txtDec9:setString(math.min(self._data.rate / 10, 100) .. "%")
    for i = 1, 3 do
        self["_txtDecValue" .. i]:setString(tostring(self._data.attr[i]))
    end
    local idx = 0
    local idx_value = ""
    for i = 4, 10 do
        if idx == 0 or self._data.attr[idx] < self._data.attr[i] then
            idx = i
        end
    end
    self._txtDec7:setString("0")
    self._txtDec7:setString(StaticData["local_text"]["recruit.specialty.txt" .. idx])
    self._txtDec8:setString(tostring(self._data.attr[idx]))
    local city_value = self._data.attr[11] or 0
    self._txtDec6:setString(tostring(city_value))
    local xml = StaticData['types']["GeneralGrade"][1].Type[self._data.quality_type] or {}
    if xml and xml.name then
        self._txtDec2:setString(xml.name)
    end
    self._nodeRecruit:setVisible(false)
    self._txtRecruit:setVisible(true)
    self:refreshState()
end

function RecruitItems:initLayer()
    self._btnRecruit:addClickEventListenerWithSound(function()
        if uq.cache.recruit:isRecruitGenerals() then
            uq.fadeInfo(StaticData["local_text"]["recruit.ogoing.recruit"])
            return
        end
        if uq.cache.generals:getRecruitGeneralsNum() >= 20 then
            uq.fadeInfo(StaticData["local_text"]["recruit.max.generals"])
            return
        end
        uq.ModuleManager:getInstance():show(uq.ModuleManager.RECRUIT_FIGT, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, data = self._data})
    end)
end

function RecruitItems:refreshBoxs()
    self:setData(self._data)
end

function RecruitItems:refreshState()
    self._btnRecruit:setVisible(self._data.left_time == 0)
    local is_ongoing = self._data.left_time ~= 0 and self._data.left_time ~= -1 and self._data.left_time ~= -2
    self._nodeRecruit:setVisible(is_ongoing)
    self._txtFinish:setVisible(self._data.left_time == -1 or self._data.left_time == -2)
    local str = self._data.left_time == -1 and StaticData["local_text"]["recruit.state.finish"] or StaticData["local_text"]["recruit.state.fail"]
    self._txtFinish:setString(str)
    self:refreshTimes()
end

function RecruitItems:refreshTimes()
    if self._data.left_time and self._data.left_time ~= 0 and self._data.left_time ~= -1 and self._data.left_time ~= -2 then
        local time = math.max(self._data.left_time - uq.cache.server_data:getServerTime(), 0)
        local time_str = uq.getTime(time, uq.config.constant.TIME_TYPE.MMSS)
        self._txtTime:setString("(" .. time_str .. ")")
    end
end

return RecruitItems