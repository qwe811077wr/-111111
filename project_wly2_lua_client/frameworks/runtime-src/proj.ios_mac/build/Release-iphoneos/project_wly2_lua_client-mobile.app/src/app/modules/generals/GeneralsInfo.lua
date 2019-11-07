local GeneralsInfo = class("GeneralsInfo", require('app.base.ChildViewBase'))

GeneralsInfo.RESOURCE_FILENAME = "generals/GeneralsInfo.csb"
GeneralsInfo.RESOURCE_BINDING = {
    ["Node_1"]                     = {["varname"]="_nodeBase"},
    ["Node_1/lv_txt"]              = {["varname"]="_txtLv"},
    ["Node_1/Sprite_1"]            = {["varname"]="_sprIcon"},
    ["Node_1/img_bg"]              = {["varname"]="_imgBg"},
    ["Node_1/img_bg_down"]         = {["varname"]="_imgBgDown"},
    ["Node_1/name_txt"]            = {["varname"]="_txtName"},
    ["lv_bg1"]                     = {["varname"]="_imgBgLv"},
    ["lv_bg1/Text_19"]             = {["varname"]="_txtAtt"},
    ["lv_bg1/Text_20"]             = {["varname"]="_txtAdd"},
}

function GeneralsInfo:onCreate()
    GeneralsInfo.super.onCreate(self)
end

function GeneralsInfo:setData(info, is_show, quality)
    local info = info or {}
    if not info or next(info) == nil then
        return
    end
    local generalData = uq.cache.generals:getGeneralDataXML(info.temp_id)
    local general_xml = uq.cache.generals:getGeneralDataXML(info.rtemp_id)
    if not generalData or next(generalData) == nil then
        return
    end
    local icon_bg = {
        "img/general_collect/j03_00009463.png",
        "img/general_collect/j03_00009465.png",
        "img/general_collect/j03_00009467.png",
        "img/general_collect/j03_00009469.png",
        "img/general_collect/j03_00009471.png",
    }
    local icon_up = {
        "img/general_collect/j03_00009464.png",
        "img/general_collect/j03_00009466.png",
        "img/general_collect/j03_00009468.png",
        "img/general_collect/j03_00009470.png",
        "img/general_collect/j03_00009472.png",
    }
    self._txtLv:setString(tonumber(info.lvl))
    self._sprIcon:setTexture("img/common/general_head/" .. general_xml.icon)
    self._imgBg:loadTexture(icon_bg[generalData.qualityType])
    self._imgBgDown:loadTexture(icon_up[generalData.qualityType])
    self._txtName:setString(info.name)
    self._imgBgLv:setVisible(is_show)
    if is_show then
        local quality = quality or info.advanceLevel
        local now_color = 1
        local tab_color = StaticData['types'].AdvanceLevel[1].Type
        local data_colorType = StaticData['advance_levels'] or {}
        if data_colorType and data_colorType[quality] then
            local str_str, str_add = self:getStrNameTab(data_colorType[quality].name)
            self._txtAtt:setString(str_str)
            self._txtAdd:setString(str_add)
            now_color = data_colorType[quality].color
        end
        self._imgBgLv:loadTexture("img/common/ui/" .. tab_color[now_color].icon)
        self._txtAtt:setTextColor(uq.parseColor("#" .. tab_color[now_color].color))
        self._txtAdd:setTextColor(uq.parseColor("#" .. tab_color[now_color].color))
    end
end

function GeneralsInfo:getStrNameTab(str)
    local str = str or ""
    local str_len = string.len(str)
    local str_str = str
    local str_add = ""
    if str_len > 3 then
        str_str = string.sub(str, 1, 3)
        str_add = string.sub(str, 4, str_len)
    end
    return str_str, str_add
end

return GeneralsInfo