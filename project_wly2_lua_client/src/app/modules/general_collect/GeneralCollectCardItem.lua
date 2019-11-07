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
    ["Text_2"]       ={["varname"]="_txtDesc"},
    ["Image_3"]      ={["varname"]="_imgDesc"},
    ["Image_1"]      ={["varname"]="_imgRecruit",["events"]={{["event"]="touch",["method"]="onRecruit"}}},
    ["Image_32_0"]   ={["varname"]="_imgLock"},
}

function GeneralCollectCardItem:onCreate()
    self._generalID = 0
    self:setArmyVisible(false)
end

function GeneralCollectCardItem:onExit()
    services:removeEventListenersByTag(self._eventSoldierSupply)
    GeneralCollectCardItem.super.onExit(self)
end

function GeneralCollectCardItem:dispose()
    GeneralCollectCardItem.super.dispose(self)
end

function GeneralCollectCardItem:setData(data, mode, recruit)
    if self._eventSoldierSupply then
        services:removeEventListenersByTag(self._eventSoldierSupply)
    end
    self._eventSoldierSupply = services.EVENT_NAMES.ON_INSTANCE_WAR_SOLDIER_SUPPLY .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_INSTANCE_WAR_SOLDIER_SUPPLY, handler(self, self.soldierSupply), self._eventSoldierSupply)

    self._gameMode = mode
    self._generalID = data.id
    self._generalTempId = data.temp_id
    self._data = data
    local general_data = uq.cache.generals:getGeneralDataXML(self._generalTempId)

    local general_info = nil
    if self._gameMode == uq.config.constant.GAME_MODE.INSTANCE_WAR then
        general_info = uq.cache.instance_war:getGeneralData(self._generalID)
    else
        general_info = uq.cache.generals:getGeneralDataByID(self._generalID)
    end
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

    self._imgLock:setVisible(false)
    local advace_lv = data.advance_lv or data.advanceLevel or 1
    if self._gameMode == uq.config.constant.GAME_MODE.INSTANCE_WAR then
        self._sprEmbattle:setVisible(uq.cache.instance_war:inGeneralInFormation(data.id))
        self._nodeDown:setVisible(false)
        self._imgRecruit:setVisible(not data.unlock)
        if recruit then
            if data.unlock then
                if not uq.cache.instance_war._generalCityMap[data.id] then
                    self._txtDesc:setString('出战中')
                else
                    local city_id = uq.cache.instance_war._generalCityMap[data.id]
                    self._txtDesc:setString(StaticData['instance_city'][city_id].name)
                end
            else
                local instance_id = uq.cache.instance_war:getCurInstanceId()
                local power_data = uq.cache.instance_war:getPowerConfig(instance_id, data.from_power)
                self._txtDesc:setString(power_data.Name .. '势力')
                self._imgLock:setVisible(true)
            end
        else
            self._txtDesc:setVisible(false)
            self._imgDesc:setVisible(false)
            self._imgRecruit:setVisible(false)
        end
    else
        self._txtDesc:setVisible(false)
        self._imgDesc:setVisible(false)
        self._imgRecruit:setVisible(false)
        local state = uq.cache.formation:checkGeneralIsInFormationById(self._generalID)
        if data.state ~= nil then
            state = data.state
        end
        self._sprEmbattle:setVisible(state)
    end

    local tab_advance = StaticData['advance_levels'][advace_lv] or {}
    local tab_color = StaticData['types'].AdvanceLevel[1].Type
    if tab_advance and next(tab_advance) ~= nil and tab_color and next(tab_color) ~= nil then
        self._txtQuality:setString(tab_advance.name)
        self._txtQuality:setTextColor(uq.parseColor("#" .. tab_color[tab_advance.color].color))
    end

    local general_data = nil
    if self._gameMode == uq.config.constant.GAME_MODE.INSTANCE_WAR then
        general_data = uq.cache.instance_war:getGeneralData(self._generalID)
    else
        general_data = uq.cache.generals:getGeneralDataByID(self._generalID)
    end
    if general_data then
        self._txtArmy:setString(general_data.current_soldiers)
    else
        self._txtArmy:setString("0")
    end
end

function GeneralCollectCardItem:soldierSupply()
    local general_data = nil
    if self._gameMode == uq.config.constant.GAME_MODE.INSTANCE_WAR then
        general_data = uq.cache.instance_war:getGeneralData(self._generalID)
    else
        general_data = uq.cache.generals:getGeneralDataByID(self._generalID)
    end
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
    if self._gameMode == uq.config.constant.GAME_MODE.INSTANCE_WAR then
        local is_red = false
        if uq.cache.instance_war:isGeneralUp(self._generalID) then
            --属性
            is_red = uq.cache.instance_war:isCanLevelUp(self._generalID)
        end
        uq.showRedStatus(self._nodeRed, is_red, 0, 0)
    else
        local is_red = false
        for i = 1, 5 do
            is_red = uq.cache.generals:getGeneralsModuleRedByIndex(i, self._generalID)
            if is_red then
                break
            end
        end
        uq.showRedStatus(self._nodeRed, is_red, 0, 0)
    end
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

function GeneralCollectCardItem:onRecruit(event)
    if event.name ~= 'ended' then
        return
    end

    local instance_id = uq.cache.instance_war:getCurInstanceId()
    local power_data = uq.cache.instance_war:getPowerConfig(instance_id, self._data.from_power)

    local function confirm()
         network:sendPacket(Protocol.C_2_S_CAMPAIGN_RECRUIT_CAPTURE, {city_id = self._data.city_id, general_id = self._data.temp_id})
    end

    local general_info = uq.cache.generals:getGeneralDataXML(self._generalTempId)
    local str = string.format('是否劝降武将%s？%s势力其余武将将被流放。', general_info.name, power_data.Name)
    local data = {
        content = str,
        confirm_callback = confirm,
    }
    uq.addConfirmBox(data)
end

return GeneralCollectCardItem