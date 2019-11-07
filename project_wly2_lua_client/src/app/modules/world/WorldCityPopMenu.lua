local WorldCityPopMenu = class("WorldCityPopMenu", require('app.base.ChildViewBase'))

WorldCityPopMenu.RESOURCE_FILENAME = "world/WorldCityPopMenu.csb"
WorldCityPopMenu.RESOURCE_BINDING = {
    ["button_declare_war"] = {["varname"] = "_btnDecalreWar",["events"] = {{["event"] = "touch",["method"] = "onBtnPress",["sound_id"] = 0}}},
    ["button_fire"]        = {["varname"] = "_btnMoveToCity",["events"] = {{["event"] = "touch",["method"] = "onBtnMoveToCity"}}},
    ["button_develop"]     = {["varname"] = "_btnDevelop",["events"] = {{["event"] = "touch",["method"] = "onBtnPress",["sound_id"] = 0}}},
    ["Node_1"]             = {["varname"] = "_moveToCityNode"},
}

WorldCityPopMenu._BTN_TYPE = { --区分第一个按钮，跟第二个按钮
    DEVELOP_BTN = 1,
    DECALRE_BTN = 2
}

function WorldCityPopMenu:onCreate()
    WorldCityPopMenu.super.onCreate(self)
    self._btnCallBack = {}
    self:setLocalZOrder(uq.ui.MapScene.ObjectZOrder.POP_MENU)
    self._btnDecalreWar["index"] = self._BTN_TYPE.DECALRE_BTN
    self._btnDevelop["index"] = self._BTN_TYPE.DEVELOP_BTN
end

function WorldCityPopMenu:initDialog()
    self:updateWorldInfo()
end

function WorldCityPopMenu:updateWorldInfo()
    local cur_city_info = uq.cache.world_war.battle_city_info
    if cur_city_info.crop_id == uq.cache.role.cropsId then --自己城池
        if cur_city_info.declare_crop_id == 0 then --没有别宣战
            self._moveToCityNode:setVisible(true)
            self._btnCallBack[self._BTN_TYPE.DEVELOP_BTN] = handler(self, self._onDevelopCity)
            self._btnDevelop:loadTextures("img/world/s02_00150.png", "img/world/s02_00150.png", "img/world/s02_00150.png")
            self._btnDecalreWar:loadTextures("img/world/s02_00150_5.png", "img/world/s02_00150_5.png", "img/world/s02_00150_5.png")
            self._btnCallBack[self._BTN_TYPE.DECALRE_BTN] = handler(self, self._onMoveCity)
        else
            self._moveToCityNode:setVisible(false)
            self:updateDeclareBtn()
        end
    else
        self._moveToCityNode:setVisible(false)
        if cur_city_info.declare_crop_id == 0 then --可宣战城池
            self._btnDecalreWar:loadTextures("img/world/s02_00151.png", "img/world/s02_00151.png", "img/world/s02_00151.png")
            self._btnDevelop:loadTextures("img/world/s02_00150_3.png", "img/world/s02_00150_3.png", "img/world/s02_00150_3.png")
            self._btnCallBack[self._BTN_TYPE.DEVELOP_BTN] = handler(self, self._onRapid)
            self._btnCallBack[self._BTN_TYPE.DECALRE_BTN] = handler(self, self._onMoveCity)
        else
            if cur_city_info.declare_crop_id == uq.cache.role.cropsId then
                self:updateDeclareBtn()
            else
                self._btnDecalreWar:setEnabled(false)
                self._btnDevelop:setEnabled(false)
                uq.ShaderEffect:addGrayButton(self._btnDevelop)
                uq.ShaderEffect:addGrayButton(self._btnDecalreWar)
                self._btnDecalreWar:loadTextures("img/world/s02_00151.png", "img/world/s02_00151.png", "img/world/s02_00151.png")
                self._btnDevelop:loadTextures("img/world/s02_00150_3.png", "img/world/s02_00150_3.png", "img/world/s02_00150_3.png")
            end
        end
    end
end

function WorldCityPopMenu:updateDeclareBtn()
    self._btnCallBack[self._BTN_TYPE.DEVELOP_BTN] = handler(self, self._onEnterCity)
    self._btnDecalreWar:loadTextures("img/world/s02_00150_2.png", "img/world/s02_00150_2.png", "img/world/s02_00150_2.png")
    self._btnDevelop:loadTextures("img/world/s02_00150_1.png", "img/world/s02_00150_1.png", "img/world/s02_00150_1.png")
    self._btnDevelop:setEnabled(true)
    self._btnCallBack[self._BTN_TYPE.DECALRE_BTN] = handler(self, self._onMoveCity)
    self._btnDecalreWar:setEnabled(uq.cache.world_war.battle_city_info.battle_time == 0)
    if uq.cache.world_war.battle_city_info.battle_time > 0 then --开始打城战了
        uq.ShaderEffect:addGrayButton(self._btnDecalreWar)--城战按钮，点击不了了，屏蔽掉
    else
        uq.ShaderEffect:removeGrayButton(self._btnDecalreWar) --通过此处调兵
    end
end

function WorldCityPopMenu:onExit()
    WorldCityPopMenu.super.onExit(self)
end

function WorldCityPopMenu:_onDevelopCity() --开发
    uq.ModuleManager:getInstance():show(uq.ModuleManager.WORLD_CITY_DEVELOP, {info = uq.cache.world_war.battle_city_info})
end

function WorldCityPopMenu:onBtnMoveToCity(event) --迁城
    if event.name ~= "ended" then
        return
    end
    if uq.cache.world_war.world_enter_info.move_times > 0 then
        uq.fadeInfo(StaticData["local_text"]["world.city.state.des4"])
        return
    end
    network:sendPacket(Protocol.C_2_S_NATION_BATTLE_MOVE_CITY, {city_id = uq.cache.world_war.battle_city_info.city_id})
end

function WorldCityPopMenu:_onEnterCity()
    uq.runCmd('enter_world_city_war')
end

function WorldCityPopMenu:_onMoveCity() --宣战、移动
    local cur_city_info = uq.cache.world_war.battle_city_info
    if cur_city_info.crop_id ~= uq.cache.role.cropsId and cur_city_info.declare_crop_id == 0 then --可宣战城池
        if uq.cache.crop:getMyCropLeaderId() ~= uq.cache.role.id then
            uq.fadeInfo(StaticData["local_text"]["world.war.formation.des6"])
            return
        end
        local city_info = StaticData['world_city'][cur_city_info.city_id]
        if city_info.gate == "" then
            uq.ModuleManager:getInstance():show(uq.ModuleManager.WORLD_TROOP, {type = 1, data = uq.cache.world_war.cur_army_info})
            self:removeSelf()
            return
        end
        local city_array = string.split(city_info.gate, ";")
        local name_array = {}
        for k, v in ipairs(city_array) do
            local city_data = uq.cache.world_war:getCityData(tonumber(v))
            if city_data and city_data.crop_id ~= uq.cache.role.cropsId then
                local xml_info = StaticData['world_city'][city_data.city_id]
                table.insert(name_array, xml_info.name)
            end
        end
        if #name_array > 0 then
            local str = ""
            for k = 1, #name_array do
                str = str .. name_array[k]
                if k < #name_array then
                    str = str .. ","
                end
            end
            uq.fadeInfo(string.format(StaticData["local_text"]["world.battle.declare.des"], str))
            return
        end
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.WORLD_TROOP, {type = 1, data = uq.cache.world_war.cur_army_info})
    self:removeSelf()
end

function WorldCityPopMenu:_onRapid() --急袭
    uq.ModuleManager:getInstance():show(uq.ModuleManager.WORLD_TROOP, {type = 1, data = uq.cache.world_war.cur_army_info})
    self:removeSelf()
end

function WorldCityPopMenu:onBtnPress(event)
    if event.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    local index = event.target.index
    if self._btnCallBack[index] then
        self._btnCallBack[index]()
    end
end

return WorldCityPopMenu