local WorldTroop = class("WorldTroop", require('app.base.PopupBase'))

WorldTroop.RESOURCE_FILENAME = "world/WorldTroop.csb"
WorldTroop.RESOURCE_BINDING = {
    ["Button_1_0_0"]                = {["varname"] = "_btnBattle",["events"] = {{["event"] = "touch",["method"] = "onBattle"}}},
    ["Panel_1"]                     = {["varname"] = "_panelBg"},
    ["Text_1"]                      = {["varname"] = "_cityNameLabel"},
    ["txt_defence_city"]            = {["varname"] = "_defenceCityLabel"},
    ["txt_defence_soldier"]         = {["varname"] = "_defenceSoldierLabel"},
    ["Image_percent"]               = {["varname"] = "_imgPercent"},
    ["g03_0000433_6"]               = {["varname"] = "_percentImgBg"},
    ["g05_000080_5"]                = {["varname"] = "_spriteIcon"},
    ["sprite_status"]               = {["varname"] = "_spriteStatus"},
    ["CheckBox_1"]                  = {["varname"] = "_checkBox"},
    ["Text_des"]                    = {["varname"] = "_foodDesLabel"},
    ["Sprite_1"]                    = {["varname"] = "_curFoodImg"},
    ["Text_food"]                   = {["varname"] = "_foodNumLabel"},
    ["Text_total_food"]             = {["varname"] = "_totalFoodNumLabel"},
    ["Sprite_1_0"]                  = {["varname"] = "_totalFoodImg"},
}

function WorldTroop:ctor(name, args)
    WorldTroop.super.ctor(self, name, args)
    self._dataList = args.data
    self._dialogType = args.type or 1
    self._percentSize = cc.size(self._percentImgBg:getContentSize().width - 2, self._imgPercent:getContentSize().height)
    self:initProtoCol()
    self:initDialog()
end

function WorldTroop:init()
end

function WorldTroop:onCreate()
    WorldTroop.super.onCreate(self)

    self._dataList = {}
    self._itemList = {}
    self._curSelectIndex = 1
    self._foodNum = 0
    self:centerView()
    self:parseView()
    self:setLayerColor()
    self:createList()
end

function WorldTroop:initDialog()
    self._foodDesLabel:setVisible(false)
    self._foodNumLabel:setVisible(false)
    self._curFoodImg:setVisible(false)
    self._btnBattle:setPressedActionEnabled(true)
    self._totalFoodNumLabel:setString(uq.cache.role:getResNum(uq.config.constant.COST_RES_TYPE.FOOD))
    local temp = StaticData['world_city'][uq.cache.world_war.battle_city_info.city_id]
    if temp == nil then
        return
    end
    self._cityNameLabel:setString(temp.name)
    self._spriteIcon:setTexture('img/building/city_war/' .. temp.icon)
    self._listView:reloadData()
    self._checkBox:addEventListener(handler(self, self.onCheckEvent))
    if uq.cache.world_war.battle_city_info.declare_crop_id == 0 then
        self._spriteStatus:setTexture("img/world/s04_00205_5.png")
        if uq.cache.world_war:checkMapCityIsDeclareByCityId(uq.cache.world_war.battle_city_info.city_id) then
            self._spriteStatus:setTexture("img/world/s04_00205_1.png")
        end
    elseif uq.cache.world_war.battle_city_info.battle_time > 0 then
        self._spriteStatus:setTexture("img/world/s04_00205_3.png")
    elseif uq.cache.world_war.battle_city_info.declare_time > 0 then
        self._spriteStatus:setTexture("img/world/s04_00205_2.png")
    end
    if self._dialogType ~= 2 then
        self._defenceCityLabel:setString(temp.defWall .. "/" .. temp.defWall)
        self._defenceSoldierLabel:setString(temp.defCount)
        self._imgPercent:setContentSize(cc.size(self._percentSize.width, self._percentSize.height))
    else
        local war_info = StaticData['world_war_city'][temp.type]
        local cur_city = war_info.war[uq.cache.world_war.field_city_info.id] --副本内部战斗的出生点
        self._cityNameLabel:setString(temp.name .. "-" .. cur_city.name)
        self._defenceCityLabel:setString(uq.cache.world_war.field_city_info.hp .. "/" .. temp.defWall)
        self._defenceSoldierLabel:setString(uq.cache.world_war:getPointArmysNumById(uq.cache.world_war.field_city_info.id))
        local hp = uq.cache.world_war.field_city_info.hp
        if uq.cache.world_war.field_city_info.hp > temp.defWall then
            hp = temp.defWall
        end
        self._imgPercent:setContentSize(cc.size(math.floor(self._percentSize.width * hp / temp.defWall), self._percentSize.height))
    end
end

function WorldTroop:onCheckEvent(sender, eventType)
    for k, v in ipairs(self._itemList) do
        v:setCheckBoxState(eventType == ccui.CheckBoxEventType.selected)
    end
    self:updateFood()
end

function WorldTroop:updateFood()
    if self._dialogType ~= 1 then
        return
    end
    self._foodNum = 0
    for k, v in ipairs(self._itemList) do
        if v:getCheckBoxState() then
            local info = v:getData()
            local soldier_num = v:getSoldier()
            local path_ids = {}
            if uq.cache.world_war:getCityBattlePath(path_ids, info.id, uq.cache.world_war.battle_city_info.city_id) then
                local tab_server_time = os.date("*t", uq.cache.server_data:getServerTime())
                if tab_server_time.hour < 8 then
                    self._foodNum = (soldier_num * (#path_ids - 1) * StaticData['world_grain'][1].distance)
                     * (uq.cache.world_war.world_enter_info.night_battle * uq.cache.world_war.world_enter_info.night_battle + 1)
                else
                    self._foodNum = (soldier_num * (#path_ids - 1) * StaticData['world_grain'][1].distance)
                end
            end
        end
    end
    self._foodNum = math.floor(self._foodNum)
    self._foodDesLabel:setVisible(self._foodNum > 0)
    self._foodNumLabel:setVisible(self._foodNum > 0)
    self._curFoodImg:setVisible(self._foodNum > 0)
    self._foodNumLabel:setString(self._foodNum)
    if uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.FOOD, self._foodNum) then
        self._foodNumLabel:setTextColor(uq.parseColor("#FFFFFF"))
    else
        self._foodNumLabel:setTextColor(uq.parseColor("#FF0000"))
    end
end

function WorldTroop:_onLoadArmy()
    self._dataList = uq.cache.world_war.cur_army_info
    self._listView:reloadData()
end

function WorldTroop:_onCheckBoxChange()
    local is_select = true
    for k, v in ipairs(self._itemList) do
        if not v:getCheckBoxState() then
            is_select = false
            break
        end
    end
    self:updateFood()
    self._checkBox:setSelected(is_select)
end

function WorldTroop:createList()
    local viewSize = self._panelBg:getContentSize()
    self._listView = cc.TableView:create(cc.size(viewSize.width, viewSize.height))
    self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listView:setPosition(cc.p(0, 0))
    self._listView:setDelegate()
    self._listView:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._listView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._listView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._listView:reloadData()
    self._panelBg:addChild(self._listView)
end

function WorldTroop:tableCellTouched(view, cell)
end

function WorldTroop:cellSizeForTable(view, idx)
    return 480, 160
end

function WorldTroop:numberOfCellsInTableView(view)
    return #self._dataList
end

function WorldTroop:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("world.WorldTroopItem")
        cell:addChild(cell_item)
        table.insert(self._itemList, cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end

    cell_item:setTag(1000)
    cell_item:setData(self._dataList[index], self._dialogType)
    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))
    return cell
end

function WorldTroop:onMovingChange()
    self._listView:reloadData()
end

function WorldTroop:initProtoCol()
    services:addEventListener(services.EVENT_NAMES.ON_WORLD_BATTLE_LOAD_ARMY, handler(self, self._onLoadArmy), "onWorldBattleLoadArmy")
    services:addEventListener(services.EVENT_NAMES.ON_WORLD_FORMATION_CHECK_BOX_CHANGE, handler(self, self._onCheckBoxChange), "onWorldCheckBoxChange")
    self._worldMovingChangeTag = services.EVENT_NAMES.ON_WORLD_MOVING_STATE_CHANGE .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_WORLD_MOVING_STATE_CHANGE, handler(self, self.onMovingChange), self._worldMovingChangeTag)
end

function WorldTroop:onExit()
    services:removeEventListenersByTag("onWorldBattleLoadArmy")
    services:removeEventListenersByTag("onWorldCheckBoxChange")
    services:removeEventListenersByTag(self._worldMovingChangeTag)
    WorldTroop.super.onExit(self)
end

function WorldTroop:sendBattleData(army_id, is_declare)
    local path_ids = {}
    if not uq.cache.world_war:getCityBattlePath(path_ids, army_id, uq.cache.world_war.battle_city_info.city_id) then
        uq.fadeInfo(StaticData["local_text"]["world.war.formation.des7"])
        return
    end
    local data = {
        army_id = army_id,
        is_declare = is_declare,
        count = #path_ids,
        path_ids = path_ids
    }
    network:sendPacket(Protocol.C_2_S_NATION_BATTLE_DO_MOVE, data)
end

function WorldTroop:worldCityInfo()
    local city_info = uq.cache.world_war:getCityData(uq.cache.world_war.battle_city_info.city_id)
    if city_info.crop_id == uq.cache.role.cropsId then
        --查找到选中的队列
        self:sendMoveData(0)
    elseif city_info.declare_crop_id == 0 then  --可以宣战
        --判断自己是否是军团长
        if uq.cache.crop:getMyCropLeaderId() ~= uq.cache.role.id then
            uq.fadeInfo(StaticData["local_text"]["world.war.formation.des6"])
            return
        end
        --判断自己是否已经有队列正在宣战中
        for k, v in ipairs(self._itemList) do
            local info = v:getData()
            if uq.cache.world_war:checkArmyIsDeclare(info.id, uq.cache.world_war.battle_city_info.city_id) then
                uq.fadeInfo(StaticData["local_text"]["world.war.formation.des12"])
                return
            end
        end
        --查找到选中的队列
        self:sendMoveData(1)
    elseif city_info.declare_crop_id == uq.cache.role.cropsId then
        --宣战的是自己的国家，可以打
        self:sendMoveData(0)
    else
        uq.fadeInfo(StaticData["local_text"]["world.war.formation.des9"])
    end
end

function WorldTroop:MoveToCity()
    local city_info = uq.cache.world_war:getCityData(uq.cache.world_war.battle_city_info.city_id)
    if city_info.crop_id == uq.cache.role.cropsId then
        --查找到选中的队列
        self:sendMoveData(2)
    else
        uq.fadeInfo(StaticData["local_text"]["world.war.formation.des11"])
    end
end

function WorldTroop:sendMoveData(type)
    local army_id = 0
    for k, v in ipairs(self._itemList) do
        if v:getCheckBoxState() then
            local info = v:getData()
            army_id = info.id
            self:sendBattleData(army_id, type)
        end
    end
    if army_id == 0 then
        uq.fadeInfo(StaticData["local_text"]["world.war.formation.des8"])
        return
    end
    self:disposeSelf()
end

function WorldTroop:battleFieldInfo()
    local city_info = StaticData['world_city'][uq.cache.world_war.battle_city_info.city_id]
    local war_info = StaticData['world_war_city'][city_info.type]
    local point_city = war_info.war[uq.cache.world_war.field_city_info.id]
    if uq.cache.world_war.battle_city_info.battle_time == 0 then --战斗没开始
        if point_city.type > 1 then
            uq.fadeInfo(StaticData["local_text"]["world.war.formation.des10"])
            return
        end
        self:toBattleField()
    else
        self:toBattleField()
    end
end

function WorldTroop:toBattleField()
    local army_id = 0
    for k, v in ipairs(self._itemList) do
        if v:getCheckBoxState() then
            local info = v:getData()
            army_id = info.id
            network:sendPacket(Protocol.C_2_S_NATION_BATTLE_FIELD_MOVE, {army_id = army_id, to_point_id = uq.cache.world_war.field_city_info.id})
        end
    end
    if army_id == 0 then
        uq.fadeInfo(StaticData["local_text"]["world.war.formation.des8"])
        return
    end
    self:disposeSelf()
end

function WorldTroop:onBattle(event)
    if event.name == 'ended' then
        if self._dialogType == 2 then
            self:battleFieldInfo()
        elseif self._dialogType == 1 then
            if not uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.FOOD, self._foodNum) then
                uq.fadeInfo(string.format(StaticData["local_text"]["label.res.tips.less"], StaticData.getCostInfo(uq.config.constant.COST_RES_TYPE.FOOD).name))
            end
            self:worldCityInfo()
        else
            self:MoveToCity()
        end
    end
end

return WorldTroop