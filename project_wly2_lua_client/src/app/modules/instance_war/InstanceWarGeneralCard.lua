local InstanceWarGeneralCard = class("InstanceWarGeneralCard", require('app.base.ChildViewBase'))

InstanceWarGeneralCard.RESOURCE_FILENAME = "instance_war/InstanceWarGeneralCard.csb"
InstanceWarGeneralCard.RESOURCE_BINDING = {
    ["icon_spr"]     ={["varname"]="_sprIcon"},
    ["name_txt"]     ={["varname"]="_txtName"},
    ["Node_10"]      ={["varname"]="_nodeUp"},
    ["quality_txt"]  ={["varname"]="_txtQuality"},
}

function InstanceWarGeneralCard:onCreate()
    InstanceWarGeneralCard.super.onCreate(self)
end

function InstanceWarGeneralCard:setData(temp_id)
    self._generalTempId = temp_id
    local general_data = uq.cache.generals:getGeneralDataXML(self._generalTempId)

    self._txtName:setString(general_data.name)
    self._sprIcon:setTexture("img/common/general_head/" .. general_data.icon)
    for i = 1, 5 do
        self._nodeUp:getChildByName("star_" .. i):setVisible(general_data.qualityType >= i)
        self._nodeUp:getChildByName("star_" .. i):setPosition(self:getStarPosition(i, general_data.qualityType))
    end

    local advace_lv = 1
    local tab_advance = StaticData['advance_levels'][advace_lv] or {}
    local tab_color = StaticData['types'].AdvanceLevel[1].Type
    if tab_advance and next(tab_advance) ~= nil and tab_color and next(tab_color) ~= nil then
        self._txtQuality:setString(tab_advance.name)
        self._txtQuality:setTextColor(uq.parseColor("#" .. tab_color[tab_advance.color].color))
    end
end

function InstanceWarGeneralCard:getStarPosition(idx, all_idx)
    if (all_idx % 2 == 1 and idx % 2 == 1) or (all_idx % 2 ~= 1 and idx % 2 ~= 1) then
        return cc.p((idx / 2 - 0.5) * 35 , -85)
    end
    return cc.p(-idx / 2 * 35 , -85)
end

return InstanceWarGeneralCard