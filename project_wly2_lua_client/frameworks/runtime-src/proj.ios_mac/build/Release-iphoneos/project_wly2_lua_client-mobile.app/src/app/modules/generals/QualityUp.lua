local QualityUp = class("QualityUp", require("app.base.PopupBase"))

QualityUp.RESOURCE_FILENAME = "generals/QualityUp.csb"
QualityUp.RESOURCE_BINDING  = {
    ["Node_1"]                                ={["varname"] = "_nodeAction"},
    ["Node_2"]                                ={["varname"] = "_nodeBase"},
    ["Node_3"]                                ={["varname"] = "_nodeItems"},
    ["Image_1"]                               ={["varname"] = "_img1"},
    ["Image_1_0"]                             ={["varname"] = "_img2"},
    ["Image_6"]                               ={["varname"] = "_imgTitle"},
}

function QualityUp:ctor(name, args)
    QualityUp.super.ctor(self,name,args)
    self._curGeneralInfo = args.general_info or {}
end

function QualityUp:init()
    self:parseView()
    self:centerView()
    self:setLayerColor()

    uq.playSoundByID(46)
    local tab_color = StaticData['types'].AdvanceLevel[1].Type
    local data_colorType = StaticData['advance_levels'] or {}
    local quality = math.max(self._curGeneralInfo.advanceLevel, 2)
    if data_colorType and data_colorType[quality] then
        local att_tab = self:getFixedAttTab(data_colorType[quality].attributes)
        for i = 1, 6 do
            if att_tab[i] then
                self._nodeBase:getChildByName("name_" .. i .. "_txt"):setString(att_tab[i].name)
                self._nodeBase:getChildByName("num_" .. i .. "_txt"):setString(tostring(att_tab[i].value))
            else
                self._nodeBase:getChildByName("name_" .. i .. "_txt"):setString("")
                self._nodeBase:getChildByName("num_" .. i .. "_txt"):setString("")
            end
        end
    end
    local next_quality = quality
    if data_colorType[quality - 1] then
        next_quality = quality - 1
    end
    if data_colorType[next_quality] then
        local att_tab = self:getFixedAttTab(data_colorType[next_quality].attributes)
        for i = 1, 6 do
            if att_tab[i] then
                self._nodeBase:getChildByName("old_" .. i .. "_txt"):setString(tostring(att_tab[i].value))
            else
                self._nodeBase:getChildByName("old_" .. i .. "_txt"):setString("")
            end
        end
    end
    for i = 1, 2 do
        local item = uq.createPanelOnly("generals.GeneralsInfo")
        self._nodeItems:addChild(item)
        local pos_x = i == 1 and -140 or 140
        local quality_value = i == 1 and next_quality or quality
        item:setData(self._curGeneralInfo, true, quality_value)
        item:setPosition(cc.p(pos_x, 0))
        item:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.MoveTo:create(0.2, cc.p(0, 0)),
            cc.CallFunc:create(function ()
                if i == 1 then
                    item:setVisible(false)
                end
            end)))
        uq.delayAction(self["_img" .. i], 0.9, function ()
            uq:addEffectByNode(self["_img" .. i], 900076, 1, true, cc.p(-220, 0))
        end)
    end
    uq.delayAction(self._nodeBase, 1, function ()
            uq:addEffectByNode(self._nodeAction, 900077, 1, true, cc.p(0, 158))
        end)
    self._imgTitle:setVisible(false)
    uq.delayAction(self._nodeItems, 1.5, function ()
           self._imgTitle:setVisible(true)
        end)
end

function QualityUp:getFixedAttTab(str)
    if str == nil or str == "" then
        return {}
    end
    local tab = {}
    local str_tab = string.split(str, ";")
    for i, v in ipairs(str_tab) do
        local str_str = string.split(v, ",")
        if str_str[2] then
            local tab_types = StaticData['bosom']['attr_type'][tonumber(str_str[1])]
            if tab_types and tab_types.display then
                table.insert(tab, {type = tonumber(str_str[1]), value = tonumber(str_str[2]), name = tab_types.display})
            end
        end
    end
    return tab
end

return QualityUp