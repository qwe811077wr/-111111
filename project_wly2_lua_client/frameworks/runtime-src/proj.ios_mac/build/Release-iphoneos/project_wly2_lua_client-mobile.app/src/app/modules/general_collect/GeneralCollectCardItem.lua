local GeneralCollectCardItem = class("GeneralCollectCardItem", require('app.base.ChildViewBase'))

GeneralCollectCardItem.RESOURCE_FILENAME = "general_collect/GeneralCollectItem.csb"
GeneralCollectCardItem.RESOURCE_BINDING = {
    ["name_txt"]     ={["varname"]="_txtName"},
    ["icon_spr"]     ={["varname"]="_sprIcon"},
    ["Node_10"]      ={["varname"]="_nodeUp"},
    ["Node_11"]      ={["varname"]="_nodeDown"},
    ["Node_12"]      ={["varname"]="_nodeRed"},
    ["lv_txt"]       ={["varname"]="_txtLv"},
    ["num_txt"]      ={["varname"]="_txtNum"},
    ["call_img"]     ={["varname"]="_imgCall"},
    ["embattle_spr"] ={["varname"]="_sprEmbattle"},
    ["chip_spr"]     ={["varname"]="_sprChip"},
    ["Node_5"]       ={["varname"]="_nodeBase"},
    ["bg_img"]       ={["varname"]="_imgBg"},
    ["bg_box_img"]   ={["varname"]="_imgBgBox"},
    ["quality_txt"]  ={["varname"]="_txtQuality"},
    ["node_army"]    ={["varname"]="_nodeArmy"},
    ["Text_1"]       ={["varname"]="_txtArmy"},
}

function GeneralCollectCardItem:onCreate()
    self._generalID = 0
    self:setArmyVisible(false)
end

function GeneralCollectCardItem:dispose()
    GeneralCollectCardItem.super.dispose(self)
end

function GeneralCollectCardItem:setData(data)
    self._generalID = data.id
    self._generalTempId = data.temp_id
    local general_info = uq.cache.generals:getGeneralDataByID(self._generalID)
    local general_data = uq.cache.generals:getGeneralDataXML(self._generalTempId)
    local rgeneral_xml = uq.cache.generals:getGeneralDataXML(data.rtemp_id)
    if not general_data then
        return
    end
    self._nodeUp:setVisible(data.unlock)
    self._nodeDown:setVisible(not data.unlock)
    if general_info == nil then
        self._txtName:setString(general_data.name)
    else
        self._txtName:setString(general_info.name)
    end
    self._sprIcon:setTexture("img/common/general_head/" .. rgeneral_xml.icon)
    local compose_num = general_data.composeNums
    if data.unlock then
        for i = 1, 5 do
            self._nodeUp:getChildByName("star_" .. i):setVisible(general_data.qualityType >= i)
            self._nodeUp:getChildByName("star_" .. i):setPosition(self:getStarPosition(i, general_data.qualityType))
        end
        self._txtLv:setString(tostring(data.lvl))
    else
        local piece_num = uq.cache.role:getResNum(uq.config.constant.COST_RES_TYPE.SPIRIT, self._generalID)
        self._txtNum:setString(piece_num .. "/" .. compose_num)
        self._imgCall:setVisible(compose_num <= piece_num)
        local generals_xml = StaticData['general'][tonumber(self._generalID .. '1')]
        if generals_xml and generals_xml.pieceIcon then
            self._sprChip:setTexture("img/common/general_spirit/" .. generals_xml.pieceIcon)
        end
    end
    local quality_type = 1
    local grade = data.unlock and general_info.grade or 1
    local tab_grade = StaticData['types'].GeneralGrade[1].Type[grade] or {}
    if tab_grade and tab_grade.qualityType then
        quality_type = tab_grade.qualityType
    end
    local tab_quality = StaticData['types'].ItemQuality[1].Type[quality_type] or {}
    if tab_quality and next(tab_quality) ~= nil then
        self._imgBg:loadTexture("img/general_collect/" .. tab_quality.landscapeQuality)
        self._imgBgBox:loadTexture("img/general_collect/" .. tab_quality.headQuality)
        self._txtName:setTextColor(uq.parseColor("#" .. tab_quality.color))
    end
    local advace_lv = data.advance_lv or 1
    local state = uq.cache.formation:checkGeneralIsInFormationById(self._generalID)
    if data.state ~= nil then
        state = data.state
    end
    self._sprEmbattle:setVisible(state)
    local tab_advance = StaticData['advance_levels'][advace_lv] or {}
    local tab_color = StaticData['types'].AdvanceLevel[1].Type
    if tab_advance and next(tab_advance) ~= nil and tab_color and next(tab_color) ~= nil then
        self._txtQuality:setString(tab_advance.name)
        self._txtQuality:setTextColor(uq.parseColor("#" .. tab_color[tab_advance.color].color))
    end

    local general_data = uq.cache.generals:getGeneralDataByID(self._generalID)
    if general_data then
        self._txtArmy:setString(general_data.current_soldiers)
    else
        self._txtArmy:setString("0")
    end
end

function GeneralCollectCardItem:getStarPosition(idx, all_idx)
    if (all_idx % 2 == 1 and idx % 2 == 1) or (all_idx % 2 ~= 1 and idx % 2 ~= 1) then
        return cc.p((idx / 2 - 0.5) * 35 , -85)
    end
    return cc.p(-idx / 2 * 35 , -85)
end

function GeneralCollectCardItem:showRed()
    local is_red = false
    if uq.cache.generals:isGeneralUp(self._generalID) then
        for i = 1, 5 do
            is_red = uq.cache.generals:getGeneralsModuleRedByIndex(i, self._generalID)
            if is_red then
                break
            end
        end
    end
    uq.showRedStatus(self._nodeRed, is_red, 0, 0)
end

function GeneralCollectCardItem:showLevel(isvisible)
    self._txtLv:setVisible(isvisible)
end

function GeneralCollectCardItem:showName(isvisible)
    self._txtName:setVisible(isvisible)
end

function GeneralCollectCardItem:showEmbattle(isvisible)
    self._sprEmbattle:setVisible(isvisible)
end

function GeneralCollectCardItem:getGeneralID()
    return self._generalID
end

function GeneralCollectCardItem:setCardState(state)
    if not state then
        for i = 1, 5 do
            self._nodeUp:getChildByName("star_" .. i):setVisible(false)
        end
    end
    if not state then
        uq.ShaderEffect:addGrayNode(self._sprIcon)
    else
        uq.ShaderEffect:removeGrayNode(self._sprIcon)
    end
end

function GeneralCollectCardItem:showAction()
    uq.intoAction(self._nodeBase)
end

function GeneralCollectCardItem:setArmyVisible(flag)
    self._nodeArmy:setVisible(flag)
end

return GeneralCollectCardItem