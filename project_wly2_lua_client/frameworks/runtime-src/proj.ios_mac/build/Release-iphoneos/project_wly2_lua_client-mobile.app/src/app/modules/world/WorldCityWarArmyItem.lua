local WorldCityWarArmyItem = class("WorldCityWarArmyItem", require('app.base.ChildViewBase'))

WorldCityWarArmyItem.RESOURCE_FILENAME = "world/WorldCityWarArmyItem.csb"
WorldCityWarArmyItem.RESOURCE_BINDING = {
    ["Node_1/Image_9"]                      = {["varname"] = "_bgImg"},
    ["Node_1/Image_percent"]                = {["varname"] = "_percentImg"},
    ["Node_1/sprite_bg"]                    = {["varname"] = "_percentBg"},
    ["Node_1/Panel_2/Image_7"]              = {["varname"] = "_headImg"},
    ["Node_1/Node_4"]                       = {["varname"] = "_nodeBtn"},
    ["Node_1/Node_4/button_pos"]            = {["varname"] = "_btnPos",["events"] = {{["event"] = "touch",["method"] = "onBtnPos"}}},
    ["Node_1/Node_4/button_embattle"]       = {["varname"] = "_btnEmbattle",["events"] = {{["event"] = "touch",["method"] = "onBtnEmbattle"}}},
}

function WorldCityWarArmyItem:onCreate()
    WorldCityWarArmyItem.super.onCreate(self)
    self:parseView()
    self._percentSize = self._percentBg:getContentSize()
    self._nodeBtn:setVisible(false)
    self._percentBg:setVisible(false)
    self._percentImg:setVisible(false)
    self._headImg:setVisible(false)
end

function WorldCityWarArmyItem:setBgTouchClick(call_back)
    self._bgImg:setTouchEnabled(true)
    self._bgImg:addClickEventListenerWithSound(function(sender)
        self._nodeBtn:setVisible(not self._nodeBtn:isVisible())
        if call_back then
            call_back()
        end
    end)
end

function WorldCityWarArmyItem:setState(is_visible)
    self._nodeBtn:setVisible(is_visible)
end

function WorldCityWarArmyItem:setViewType(view_type, index)
    self._type = view_type
    self._index = index
end

function WorldCityWarArmyItem:setData(data)
    self._data = data or {}
    if next(self._data) == nil or #self._data.generals == 0 then
        return
    end
    self._percentBg:setVisible(true)
    self._percentImg:setVisible(true)
    self._headImg:setVisible(true)
    local general_xml = uq.cache.generals:getGeneralDataXML(self._data.main_general_id)
    if general_xml then
        self._headImg:loadTexture("img/common/general_head/" .. general_xml.icon)
    end
    local cur_soldier = 0
    local total_soldier = 0
    for k, v in ipairs(self._data.generals) do
        local general_info = uq.cache.generals:getGeneralDataByID(v.general_id)
        if general_info then
            total_soldier = total_soldier + general_info.max_soldiers
            cur_soldier = cur_soldier + (general_info.current_soldiers == 0 and general_info.max_soldiers or general_info.current_soldiers)
        end
    end
    if cur_soldier > total_soldier then
        uq.log("error  cur_soldier  total_soldier ", cur_soldier, total_soldier)
        cur_soldier = total_soldier
    end
    self._percentImg:setContentSize(cc.size(math.floor(self._percentSize.width * cur_soldier / total_soldier), self._percentSize.height))
end

function WorldCityWarArmyItem:onBtnPos(event)
    if event.name ~= "ended" then
        return
    end
    if nest(self._data) == nil then
        return
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_WORLD_CITY_POS, data = self._data})
end

function WorldCityWarArmyItem:onBtnEmbattle(event)
    if event.name ~= "ended" then
        return
    end
    if self._type == 2 then
        uq.fadeInfo(StaticData["local_text"]["world.war.formation.open"])
        return
    end
    local move_cd = uq.cache.world_war:getCityMovingCd(uq.cache.role.id, self._index)
    if move_cd > 0 then
        uq.fadeInfo(StaticData["local_text"]["world.war.formation.des" .. self._index] .. StaticData["local_text"]["world.war.formation.des14"])
        return
    elseif uq.cache.world_war:checkArmyIsInBattleCity(self._index) then --所在的城池已经开始打仗不能设置
        uq.fadeInfo(StaticData["local_text"]["world.war.formation.des" .. self._index] .. StaticData["local_text"]["world.war.formation.des16"])
        return
    elseif uq.cache.world_war:checkArmyIsInDeclareCity(self._index) then --所在的城池已经开始宣战不能设置
        uq.fadeInfo(StaticData["local_text"]["world.war.formation.des" .. self._index] .. StaticData["local_text"]["world.war.formation.des15"])
        return
    end
    local army_data = {}
    local army_info = uq.cache.world_war.cur_army_info[1]
    if #army_info.generals == 0 then
        army_data = {
            ids = {1},
            array = {'army_1'},
            army_1 = {},
        }
        self:updateArmyData(army_data , 1)
    else
        army_data = {
            ids = {1, 1},
            array = {'army_1', 'army_2'},
            army_1 = {},
            army_2 = {},
        }
        self:updateArmyData(army_data , 1)
        self:updateArmyData(army_data , 2)
    end
    local confirm = function()
        services:dispatchEvent({name = services.EVENT_NAMES.ON_CLOSE_ARRANGED_BEFORE})
    end
    local data = {
        enemy_data = {},
        army_data = {army_data},
        embattle_type = uq.config.constant.TYPE_EMBATTLE.NATIONAL_WAR_EMBATTLE,
        confirm_callback = confirm
    }
    self:setState(false)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ARRANGED_BEFORE_WAR, data)
end

function WorldCityWarArmyItem:updateArmyData(army_data, index)
    local info = uq.cache.world_war.cur_army_info[index]
    army_data.ids[index] = info.formation_id == 0 and 1 or info.formation_id
    local army_info = army_data[army_data.array[index]]
    for k, v in ipairs(info.generals) do
        local formation_info = {
            index = v.pos,
            general_id = v.general_id
        }
        table.insert(army_info, formation_info)
    end
end

return WorldCityWarArmyItem