local InfoLeftItems = class("InfoLeftItems", require('app.base.ChildViewBase'))

InfoLeftItems.RESOURCE_FILENAME = "retainer/InfoLeftItems.csb"
InfoLeftItems.RESOURCE_BINDING = {
    ["Panel_1/Image_2"]           = {["varname"]="_imgFullZhu"},
    ["Panel_1/Text_1"]            = {["varname"]="_txtRole"},
    ["Panel_1/Text_2"]            = {["varname"]="_txtName"},
    ["Panel_1/Text_2_0"]          = {["varname"]="_txtGs"},
    ["Panel_1/Text_2_1"]          = {["varname"]="_txtLv"},
    ["Panel_1/Text_1_2"]          = {["varname"]="_txtTime"},
}

function InfoLeftItems:onCreate()
    InfoLeftItems.super.onCreate(self)
end

function InfoLeftItems:setData(data)
    self:parseView()
    local data = data or {}
    if data.info and data.info[1] and next(data.info[1]) ~= nil then
        local info = data.info[1]
        local is_suzerain = uq.cache.retainer:isOwnSuzerain(info.id)
        local str = StaticData["local_text"]["retainer.courtier"]
        if is_suzerain then
            str = StaticData["local_text"]["retainer.king"]
        end
        self._txtRole:setString(str .. ":")
        self._imgFullZhu:setVisible(is_suzerain)
        self._txtName:setString(info.name)
        self._txtGs:setString(tostring(info.force_value))
        self._txtLv:setString(tostring(info.level))
        self._txtTime:setString(StaticData['local_text']['label.common.online'])
        if info.is_online == 0 then
            local time = info.offline_time
            if time > 0 then
                self._txtTime:setString(uq.getTime2(time) .. StaticData['local_text']['label.common.before'])
            end
        end
    end
    self.data = data
end

return InfoLeftItems