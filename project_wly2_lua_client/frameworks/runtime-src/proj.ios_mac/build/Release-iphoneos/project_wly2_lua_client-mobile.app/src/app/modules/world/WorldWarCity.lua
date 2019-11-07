local WorldWarCity = class("WorldWarCity", require('app.base.ChildViewBase'))

WorldWarCity.RESOURCE_FILENAME = "world/WorldWarCity.csb"
WorldWarCity.RESOURCE_BINDING = {
    ["icon"]                                    = {["varname"] = "_spriteIcon"},
    ["Image_battle"]                            = {["varname"] = "_battleStateImg"},
    ["Text_14"]                                 = {["varname"] = "_txtCityName"},
    ["txt_name1"]                               = {["varname"] = "_countryName"},
    ["txt_name"]                                = {["varname"] = "_txtCropName"},
    ["country"]                                 = {["varname"] = "_countryImg"},
    ["Node_3"]                                  = {["varname"] = "_cropNode"},
    ["Node_4"]                                  = {["varname"] = "_infoNode"},
    ["Node_4/label_city_soldier"]               = {["varname"] = "_soldierLabel"},
    ["Node_4/label_city_def"]                   = {["varname"] = "_defLabel"},
    ["Node_4/Image_bg"]                         = {["varname"] = "_percentBgImg"},
    ["Node_4/Image_percent"]                    = {["varname"] = "_percentImg"},
    ["Node_4/Node_btn/button_def"]              = {["varname"] = "_btnInfo",["events"] = {{["event"] = "touch",["method"] = "onBtnClick"}}},
    ["Node_4/Node_btn"]                         = {["varname"] = "_nodeBtn"},
    ["Node_effect"]                             = {["varname"] = "_nodeEffect"},
    ["Node_fight_effect"]                       = {["varname"] = "_nodeBattleEffect"},
    ["Node_5"]                                  = {["varname"] = "_nodeSoldier"},
    ["Node_5/Image_soldiertype"]                = {["varname"] = "_soldierTypeImg"},
    ["Node_5/Image_red"]                        = {["varname"] = "_soldierNumImg"},
    ["Node_5/Text_num"]                         = {["varname"] = "_soldierNumLabel"},
    ["Node_4/label_soldier_reply"]              = {["varname"] = "_soldierReplyLabel"},
    ["Node_4/label_def_reply"]                  = {["varname"] = "_defReplyLabel"},
}

function WorldWarCity:onCreate()
    WorldWarCity.super.onCreate(self)
    self._armysInfo = {}
    self._buildData = nil
    self._info = nil
    self._percentSize = cc.size(self._percentBgImg:getContentSize().width - 2, self._percentImg:getContentSize().height)
    self:setLocalZOrder(uq.ui.MapScene.ObjectZOrder.CITY)
    self._infoNode:setVisible(false)
    self._cropNode:setVisible(false)
    self._nodeSoldier:setVisible(false)
    self._effectState = 0  --没有特效，1攻打特效，2修复特效
    self._replyTime = 15 * 60
end

function WorldWarCity:onExit()
    WorldWarCity.super.onExit(self)
end

function WorldWarCity:onClick()
    self:setLocalZOrder(100)
    self:addPopMenu()
end

function WorldWarCity:removePopMenu()
    self:setLocalZOrder(50)
    local crop_data = uq.cache.crop:getCropDataById(self._info.crop_id)
    self._cropNode:setVisible(next(crop_data) ~= nil)
    self._infoNode:setVisible(false)
    self:updateSoldierNum()
end

function WorldWarCity:setData(build_data)
    self._buildData = build_data
    self._txtCityName:setString(build_data.name)
    self._spriteIcon:setTexture('img/building/world_city/' .. build_data.icon)
end

function WorldWarCity:timer(dt)
    if self._info == nil then
        return
    end
    if self._info.wall_time + self._replyTime > uq.cache.server_data:getServerTime() then
        self._defReplyLabel:setString(StaticData["local_text"]["world.war.reply.des2"]
        .. uq.getTime(self._info.wall_time + self._replyTime - uq.cache.server_data:getServerTime(), uq.config.constant.TIME_TYPE.HHMMSS))
    end
    if self._info.def_time + self._replyTime > uq.cache.server_data:getServerTime() then
        self._soldierReplyLabel:setString(StaticData["local_text"]["world.war.reply.des1"]
        .. uq.getTime(self._info.def_time + self._replyTime - uq.cache.server_data:getServerTime(), uq.config.constant.TIME_TYPE.HHMMSS))
    end
end

function WorldWarCity:updateHp(hp)
    self._info.hp = hp
    self._defLabel:setString(self._info.hp .. "/" .. self._buildData.defWall)
    self._percentImg:setContentSize(cc.size(math.floor(self._percentSize.width * self._info.hp / self._buildData.defWall), self._percentSize.height))
end

function WorldWarCity:playBattleEffect()
    uq:addEffectByNode(self._nodeBattleEffect, 900134, 2, true, cc.p(self._buildData.offset_x, self._buildData.offset_y + 80))
    uq:addEffectByNode(self._nodeBattleEffect, 900133, 2, true, cc.p(self._buildData.offset_x, self._buildData.offset_y + 80))
end

function WorldWarCity:setFieldInfo(info)
    self._info = info
    if not self._info then
        return
    end
    if uq.cache.world_war.field_city_info and uq.cache.world_war.field_city_info.id == self._info.id then
        uq.cache.world_war.field_city_info = self._info
        local pop_menu = self:getParent():getChildByName("pop_menu")
        if pop_menu then
            pop_menu:initDialog()
        end
    end
    self._defLabel:setString(self._info.hp .. "/" .. self._buildData.defWall)
    self._percentImg:setContentSize(cc.size(math.floor(self._percentSize.width * self._info.hp / self._buildData.defWall), self._percentSize.height))
    local crop_data = uq.cache.crop:getCropDataById(self._info.crop_id)
    self._cropNode:setVisible(next(crop_data) ~= nil)
    if next(crop_data) ~= nil then
        self._txtCropName:setString(crop_data.name)
        local flag_info = StaticData['world_flag'][crop_data.color_id]
        if flag_info then
            self._countryImg:setTexture("img/create_power/" .. flag_info.color)
            self._countryName:setString(crop_data.power_name)
        end
    end
end

function WorldWarCity:updateCityState()
    if not self._info then
        return
    end
    self._battleStateImg:setVisible(uq.cache.world_war:checkFieldCityIsMoveTo(uq.cache.role.id, self._info.id))
end

function WorldWarCity:updateReplyTime()
    self:timer()
    self._soldierReplyLabel:setVisible(self._info.def_time + self._replyTime > uq.cache.server_data:getServerTime())
    self._defReplyLabel:setVisible(self._info.wall_time + self._replyTime > uq.cache.server_data:getServerTime())
end

function WorldWarCity:updateArmysInfo(info)
    self._armysInfo = info or {}
    if not self._info then
        return
    end
    self:updateSoldierNum()
    local npc_num = uq.cache.world_war:getPointArmysNumById(self._info.id)
    self._soldierLabel:setString(npc_num)
    if self._buildData.type ~= 3 then
        return
    end
    self:updateReplyTime()
    if npc_num == 0 then
        if self._effectState ~= 2 then
            self._effectState = 2
            self._nodeEffect:removeAllChildren()
            uq:addEffectByNode(self._nodeEffect, 900158, -1, true, cc.p(self._buildData.offset_x, self._buildData.offset_y))
            uq:addEffectByNode(self._nodeEffect, 900161, -1, true, cc.p(self._buildData.offset_x, self._buildData.offset_y + 80))
        end
    elseif npc_num < self._buildData.defCount then
        if self._effectState ~= 1 then
            self._effectState = 1
            self._nodeEffect:removeAllChildren()
            uq:addEffectByNode(self._nodeEffect, 900160, -1, true, cc.p(self._buildData.offset_x, self._buildData.offset_y))
        end
    else
        self._effectState = 0
        self._nodeEffect:removeAllChildren()
    end
end

function WorldWarCity:getIcon()
    return self._spriteIcon
end

function WorldWarCity:updateSoldierNum()
    local player_num = uq.cache.world_war:getPointArmysNumById(self._info.id, 0)
    self._nodeSoldier:setVisible(player_num > 0 and not self._infoNode:isVisible())
    self._soldierNumImg:setVisible(player_num > 1)
    if self._info.crop_id == uq.cache.role.cropsId then
        self._soldierTypeImg:loadTexture("img/world/s02_00154.png")
    else
        self._soldierTypeImg:loadTexture("img/world/s02_00153.png")
    end
    if player_num > 1 then
        self._soldierNumLabel:setString(player_num)
    else
        self._soldierNumLabel:setString("")
    end
end

function WorldWarCity:addPopMenu()
    self._cropNode:setVisible(false)
    self._infoNode:setVisible(true)
    self._nodeSoldier:setVisible(false)
    uq.cache.world_war.field_city_info = self._info
    self._nodeBtn:setVisible(self._buildData.type ~= 4)
    if self._info.crop_id == uq.cache.role.cropsId then
        self._btnInfo:loadTextures("img/world/s02_00150_5.png", "img/world/s02_00150_5.png")
    else
        self._btnInfo:loadTextures("img/world/s02_00150_4.png", "img/world/s02_00150_4.png")
    end
end

function WorldWarCity:onBtnClick(event)
    if event.name ~= "ended" then
        return
    end
    if self._info.wall_time > 0 and self._info.crop_id == uq.cache.role.cropsId then
        uq.fadeInfo(StaticData["local_text"]["world.battle.field.des1"])
        return
    end
    local list = {}
    local info_array = uq.cache.world_war.cur_army_info
    for k, v in ipairs(info_array) do
        if v.cur_city == uq.cache.world_war.battle_city_info.city_id and #v.generals > 0 then
            table.insert(list, v)
        end
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.WORLD_TROOP, {type = 2, data = list})
    self:removePopMenu()
end

return WorldWarCity