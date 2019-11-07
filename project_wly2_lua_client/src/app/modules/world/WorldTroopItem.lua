local WorldTroopItem = class("WorldTroopItem", require('app.base.ChildViewBase'))

WorldTroopItem.RESOURCE_FILENAME = "world/WorldTroopItem.csb"
WorldTroopItem.RESOURCE_BINDING = {
    ["Node_1"]          = {["varname"] = "_nodeData"},
    ["Text_1"]          = {["varname"] = "_armyName"},
    ["Image_7"]         = {["varname"] = "_imgHead"},
    ["Text_1_0"]        = {["varname"] = "_armyTime"},
    ["Text_1_0_0"]      = {["varname"] = "_powerLabel"},
    ["Image_4"]         = {["varname"] = "_soldierBgImg"},
    ["Image_percent"]   = {["varname"] = "_soldierPercentImg"},
    ["Image_state"]     = {["varname"] = "_soldierStatueImg"},
    ["Text_1_0_1_0_0"]  = {["varname"] = "_battleCityNumLabel"},
    ["Text_1_0_1_0_1"]  = {["varname"] = "_cityNameLabel"},
    ["Text_1_1"]        = {["varname"] = "_desLabel"},
    ["CheckBox_1"]      = {["varname"] = "_checkBox"},
}

function WorldTroopItem:onCreate()
    WorldTroopItem.super.onCreate(self)
    self._percentSize = cc.size(self._soldierBgImg:getContentSize().width - 2, self._soldierPercentImg:getContentSize().height)
    self._type = 1
    self._curSoldier = 0
    self._checkBox:addEventListener(handler(self, self.onCheckEvent))
end

function WorldTroopItem:onCheckEvent()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_WORLD_FORMATION_CHECK_BOX_CHANGE})
end

function WorldTroopItem:setData(data, type)
    self._info = data
    self._type = type
    if not self._info then
        return
    end
    self._nodeData:setVisible(self._info.formation_id ~= 0)
    self._desLabel:setVisible(self._info.formation_id == 0)

    self._armyName:setString(StaticData["local_text"]["world.war.formation.des" .. self._info.id])
    if self._info.formation_id == 0 then
        return
    end
    local power = 0
    local battle_city = 0
    self._curSoldier = 0
    local total_soldier = 0
    local res_head = uq.getHeadRes(self._info.main_general_id, uq.config.constant.HEAD_TYPE.GENERAL)
    self._imgHead:loadTexture(res_head)
    for k, v in ipairs(self._info.generals) do
        local general_info = uq.cache.generals:getGeneralDataByID(v.general_id)
        if general_info then
            power = power + general_info.power
            battle_city = battle_city + general_info.siege
            total_soldier = total_soldier + general_info.max_soldiers
            self._curSoldier = self._curSoldier + (general_info.current_soldiers == 0 and general_info.max_soldiers or general_info.current_soldiers)
        end
    end
    if self._curSoldier > total_soldier then
        self._curSoldier = total_soldier
    end
    self._powerLabel:setString(power)
    self._battleCityNumLabel:setString(battle_city)
    self._soldierPercentImg:setContentSize(cc.size(math.floor(self._percentSize.width * self._curSoldier / total_soldier), self._percentSize.height))
    if self._info.cur_city == 0 then
        self._info.cur_city = uq.cache.world_war.world_enter_info.city_id
    end
    local city_info = StaticData['world_city'][self._info.cur_city]
    if city_info == nil then
        return
    end
    self._cityNameLabel:setString(city_info.name)
    self._armyTime:setString("00:00:00")
    self._armyTime:setTextColor(uq.parseColor("#7FFF01"))
    if self._type == 2 then
        local war_info = StaticData['world_war_city'][city_info.type]
        local brith_city = uq.cache.world_war:getBirthCity(self._info.id)
        local cur_city = war_info.war[brith_city] --副本内部战斗的出生点
        if cur_city then
            self._cityNameLabel:setString(city_info.name .. "-" .. cur_city.name)
        end
        local move_cd = uq.cache.world_war:getFieldMovingCd(uq.cache.role.id, self._info.id)
        self._checkBox:setVisible(move_cd == 0)
        if move_cd > 0 or not cur_city then
            self._soldierStatueImg:loadTexture("img/world/xsj07_0033.png")
            self._armyTime:setString(string.format(StaticData["local_text"]["world.war.formation.des4"], math.floor(move_cd / 3600), math.floor(move_cd % 3600 / 60), move_cd % 60))
        else
            --计算时间
            self._checkBox:setVisible(uq.cache.world_war.field_city_info.id ~= brith_city)
            if uq.cache.world_war.field_city_info.id == brith_city then
                self._soldierStatueImg:loadTexture("img/world/xsj07_0033_2.png")
            else
                self._soldierStatueImg:loadTexture("img/world/xsj07_0033_3.png")
                self._checkBox:setSelected(false)
                self:updateFieldMoveTime(war_info, cur_city)
            end
        end
    else
        local move_cd = uq.cache.world_war:getCityMovingCd(uq.cache.role.id, self._info.id)
        self._checkBox:setVisible(move_cd == 0)
        if move_cd > 0 then
            self._soldierStatueImg:loadTexture("img/world/xsj07_0033.png")
            self._armyTime:setString(string.format(StaticData["local_text"]["world.war.formation.des4"], math.floor(move_cd / 3600), math.floor(move_cd % 3600 / 60), move_cd % 60))
        elseif uq.cache.world_war:checkArmyIsInBattleCity(self._info.id) then --所在的城池已经开始打仗不能在世界地图移动
            self._checkBox:setVisible(false)
            self._soldierStatueImg:loadTexture("img/world/xsj07_0033_4.png")
        elseif uq.cache.world_war:checkArmyIsInDeclareCity(self._info.id) then --所在的城池已经开始宣战不能在世界地图移动
            self._checkBox:setVisible(false)
            self._soldierStatueImg:loadTexture("img/world/xsj07_0033_5.png")
        else
            --计算时间
            self._checkBox:setVisible(uq.cache.world_war.battle_city_info.city_id ~= self._info.cur_city)
            if uq.cache.world_war.battle_city_info.city_id == self._info.cur_city then
                self._soldierStatueImg:loadTexture("img/world/xsj07_0033_2.png")
            else
                self._soldierStatueImg:loadTexture("img/world/xsj07_0033_3.png")
                self._checkBox:setSelected(false)
                self:updateCityMoveTime()
            end
        end
    end
end

function WorldTroopItem:setCheckBoxState(state)
    if #self._info.generals == 0 or not self._checkBox:isVisible() then
        return
    end
    self._checkBox:setSelected(state)
end

function WorldTroopItem:getCheckBoxState()
    if #self._info.generals == 0 then
        return false
    end
    return self._checkBox:isVisible() and self._checkBox:isSelected() or false
end

function WorldTroopItem:updateFieldMoveTime(war_info, cur_city)
    local dec_city = war_info.war[uq.cache.world_war.field_city_info.id]
    local distance = cc.pGetDistance(cc.p(dec_city.pos_x, dec_city.pos_y), cc.p(cur_city.pos_x, cur_city.pos_y))
    local time = math.floor(distance / war_info.speed)
    self._armyTime:setString(string.format(StaticData["local_text"]["world.war.formation.des4"], math.floor(time / 3600), math.floor(time % 3600 / 60), time % 60))
end

function WorldTroopItem:updateCityMoveTime()
    local path_ids = {}
    if not uq.cache.world_war:getCityBattlePath(path_ids, self._info.id, uq.cache.world_war.battle_city_info.city_id) then
        self._armyTime:setString(StaticData["local_text"]["world.war.formation.des7"])
        self._armyTime:setTextColor(uq.parseColor("#ff0000"))
        self._checkBox:setVisible(false)
        return
    end
    local total_time = 0
    for i = 1, #path_ids - 1 do
        local cur_city_id = path_ids[i]
        local next_city_id = path_ids[i + 1]
        local cur_road_info = uq.cache.world_war:getCityRoadInfo(cur_city_id)
        if cur_road_info then
            local distance = cur_road_info[next_city_id].distance
            total_time = total_time + distance / StaticData['world_city'][next_city_id].speed
        end
    end
    total_time = math.floor(total_time)
    self._armyTime:setString(string.format(StaticData["local_text"]["world.war.formation.des4"], math.floor(total_time / 3600), math.floor(total_time % 3600 / 60), total_time % 60))
end

function WorldTroopItem:getData()
    return self._info, self._curSoldier
end

function WorldTroopItem:getSoldier()
    return self._curSoldier
end
return WorldTroopItem