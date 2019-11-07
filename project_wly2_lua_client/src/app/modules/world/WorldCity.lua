local WorldCity = class("WorldCity", require('app.base.ChildViewBase'))

WorldCity.RESOURCE_FILENAME = "world/WorldCity.csb"
WorldCity.RESOURCE_BINDING = {
    ["icon"]                                    = {["varname"] = "_spriteIcon"},
    ["Text_14"]                                 = {["varname"] = "_txtCityName"},
    ["txt_name"]                                = {["varname"] = "_txtCropName"},
    ["country"]                                 = {["varname"] = "_countryImg"},
    ["txt_name1"]                               = {["varname"] = "_countryName"},
    ["Node_3"]                                  = {["varname"] = "_nodeCrop"},
    ["Node_2"]                                  = {["varname"] = "_cityStateNode"},
    ["Image_2"]                                 = {["varname"] = "_cityStateImg"},
    ["txt_time"]                                = {["varname"] = "_timeLabel"},
    ["Node_info"]                               = {["varname"] = "_nodeInfo"},
    ["Node_info/Node_4"]                        = {["varname"] = "_nodeSoldier"},
    ["Node_info/Node_4/Image_soldiertype"]      = {["varname"] = "_soldierTypeImg"},
    ["Node_info/Node_4/Image_red"]              = {["varname"] = "_soldierNumImg"},
    ["Node_info/Node_4/Text_num"]               = {["varname"] = "_soldierNumLabel"},
    ["Node_view"]                               = {["varname"] = "_nodeView"},
    ["label_city_soldier"]                      = {["varname"] = "_soldierLabel"},
    ["label_city_def"]                          = {["varname"] = "_defLabel"},
    ["Node_effect"]                             = {["varname"] = "_nodeEffect"},
    ["Node_fight_effect"]                       = {["varname"] = "_nodeFightEffect"},
    ["Image_selfbg"]                            = {["varname"] = "_imgSelfBg"},
}

function WorldCity:onCreate()
    WorldCity.super.onCreate(self)
    self:setLocalZOrder(uq.ui.MapScene.ObjectZOrder.CITY)
    self._info = nil
    self._nodeCrop:setVisible(false)
    self._cityStateNode:setVisible(false)
    self._nodeView:setVisible(false)
    self._nodeSoldier:setVisible(false)
    self._imgSelfBg:setVisible(false)
    self._curStatePosY = self._cityStateNode:getPositionY()
    self._timeCd = 0
end

function WorldCity:onExit()

    WorldCity.super.onExit(self)
end

function WorldCity:updateInfoState(is_visible)
    self._nodeInfo:setVisible(is_visible)
end

function WorldCity:onClick()
    self:setLocalZOrder(100)
    self:addPopMenu()
end

function WorldCity:removePopMenu()
    self:setLocalZOrder(50)
    self._nodeView:setVisible(false)
    self._nodeInfo:setVisible(true)
    self:updateSoldierNum()
    if self:getParent():getChildByName('pop_menu') then
        self:getParent():removeChildByName('pop_menu')
    end
end

function WorldCity:timer(dt)
    if self._timeCd <= 0 then
        return
    end
    self._timeCd = self._timeCd - dt
    if self._timeCd < 0 then
        self._timeCd = 0
    end
    self._timeLabel:setString(uq.getTime(self._timeCd, uq.config.constant.TIME_TYPE.HHMMSS))
end

function WorldCity:setInfo(info) --城池状态更新下一步会走这里
    self._info = info
    if uq.cache.world_war.battle_city_info and uq.cache.world_war.battle_city_info.city_id == self._info.city_id then
        uq.cache.world_war.battle_city_info = self._info
        local pop_menu = self:getParent():getChildByName("pop_menu")
        if pop_menu then
            pop_menu:initDialog()
        end
    end
    local crop_data = uq.cache.crop:getCropDataById(self._info.crop_id)
    self._nodeCrop:setVisible(next(crop_data) ~= nil)
    if next(crop_data) ~= nil then
        self._txtCropName:setString(crop_data.name)
        local flag_info = StaticData['world_flag'][crop_data.color_id]
        if flag_info then
            self._countryImg:setTexture("img/create_power/" .. flag_info.color)
            self._countryName:setString(crop_data.power_name)
        end
    end
    self:updateSoldierNum()
    self:updateState()
end

function WorldCity:updateSelfBgState(is_visible)
    self._imgSelfBg:setVisible(is_visible)
end

function WorldCity:updateState()
    self._timeCd = 0
    self._cityStateNode:setVisible(false)
    self._nodeFightEffect:removeAllChildren()
    self._nodeEffect:removeAllChildren()
    if self._info.declare_crop_id > 0 then
        self._cityStateNode:setVisible(true)
        self._timeLabel:setString("")
        if self._info.battle_time > 0 then --战斗中
            local temp = StaticData['world_city'][self._info.city_id]
            uq:addEffectByNode(self._nodeEffect, 900160, -1, true, cc.p(temp.offset_x, temp.offset_y))
            uq:addEffectByNode(self._nodeFightEffect, 900134, -1, true)
            uq:addEffectByNode(self._nodeFightEffect, 900133, -1, true)
            self._cityStateImg:loadTexture("img/world/s04_00205_3.png")
            self._timeCd = temp.battleTime - (self._info.battle_time + (os.time() - self._info.cur_time))
        elseif self._info.declare_time > 0 or self._info.cur_time > 0 then --备战中
            self._cityStateImg:loadTexture("img/world/s04_00205_2.png")
            self._timeCd = 15 * 60 - (self._info.declare_time + (os.time() - self._info.cur_time))
        end
    elseif uq.cache.world_war:checkMapCityIsDeclare(uq.cache.crop:getMyCropLeaderId(), self._info.city_id) then
        self._cityStateNode:setVisible(true)
        self._timeLabel:setString("")
        self._cityStateImg:loadTexture("img/world/s04_00205_1.png")
    elseif self._info.crop_id ~= uq.cache.role.cropsId then --判断是否可以宣战
        local road = uq.cache.world_war:getCityRoadInfo(self._info.city_id)
        for k, v in pairs(road) do
            local city_info = uq.cache.world_war.world_city_info[v.ident]
            if city_info.crop_id == uq.cache.role.cropsId then
                self._cityStateNode:setVisible(true)
                self._timeLabel:setString("")
                self._cityStateImg:loadTexture("img/world/s04_00205_5.png")
                break
            end
        end
    end
end

function WorldCity:setData(build_data)
    self._spriteIcon:setTexture('img/building/city_war/' .. build_data.icon)
    self._txtCityName:setString(build_data.name)
    self._soldierLabel:setString(build_data.defCount)
    self._defLabel:setString(build_data.defWall)
end

function WorldCity:getIcon()
    return self._spriteIcon
end

function WorldCity:updateSoldierNum(def_num, atk_num)
    self._info.def_num = def_num or self._info.def_num
    self._info.atk_num = atk_num or self._info.atk_num
    local is_visible = self._info.def_num > 0 and not self._nodeView:isVisible()
    if is_visible then
        self._cityStateNode:setPositionY(self._curStatePosY)
    else
        self._cityStateNode:setPositionY(self._curStatePosY - 50)
    end
    self._nodeSoldier:setVisible(is_visible)
    self._soldierNumImg:setVisible(self._info.def_num > 1)
    if self._info.crop_id == uq.cache.role.cropsId then
        self._soldierTypeImg:loadTexture("img/world/s02_00154.png")
    else
        self._soldierTypeImg:loadTexture("img/world/s02_00153.png")
    end
    if self._info.def_num > 1 then
        self._soldierNumLabel:setString(self._info.def_num)
    else
        self._soldierNumLabel:setString("")
    end
end

function WorldCity:addPopMenu()
    self._nodeView:setVisible(true)
    self._nodeInfo:setVisible(false)
    self._nodeSoldier:setVisible(false)
    local pop_menu = uq.createPanelOnly('world.WorldCityPopMenu')
    pop_menu:setName('pop_menu')
    uq.cache.world_war.battle_city_info = self._info
    uq.log("battle_city_info   ",uq.cache.world_war.battle_city_info)
    local size = self._spriteIcon:getContentSize()
    local x, y = self:getPosition()
    pop_menu:setPosition(cc.p(x, y))
    pop_menu:initDialog()
    self:getParent():addChild(pop_menu)
    pop_menu:setLocalZOrder(101)
end


return WorldCity