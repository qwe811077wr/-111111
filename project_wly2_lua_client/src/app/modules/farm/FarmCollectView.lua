local FarmCollectView = class("FarmCollectView", require('app.modules.common.BaseViewWithHead'))

FarmCollectView.RESOURCE_FILENAME = "collect/CollectView.csb"
FarmCollectView.RESOURCE_BINDING = {
    ["Node_item"]                             = {["varname"] = "_nodeData"},
    ["Node_appoint"]                          = {["varname"] = "_nodeAppoint"},
    ["Node_item/Node_2/Text_level"]           = {["varname"] = "_mainBuildLvlLabel"},
    ["Node_item/Node_get/canget"]             = {["varname"] = "_txtCangetMoney"},
    ["Node_item/Node_get/Sprite_9"]           = {["varname"] = "_spriteCost"},
    ["Node_item/node_cd/Text_1"]              = {["varname"] = "_txtCdTime"},
    ["Node_item/node_cd"]                     = {["varname"] = "_nodeCD"},
    ["Node_item/Node_house1"]                 = {["varname"] = "_nodeHouse1"},
    ["Node_item/Node_house2"]                 = {["varname"] = "_nodeHouse2"},
    ["Node_item/Node_house3"]                 = {["varname"] = "_nodeHouse3"},
    ["Node_item/Node_house4"]                 = {["varname"] = "_nodeHouse4"},
    ["Node_item/Button_collect"]              = {["varname"] = "_btnCollect",["events"] = {{["event"] = "touch",["method"] = "onCollect"}}},
    ["Node_item/Button_force"]                = {["varname"] = "_btnForce"},
    ["Node_1"]                                = {["varname"] = "_nodeInfo"},
    ["Node_item/Node_4"]                      = {["varname"] = "_nodeForce"},
}

function FarmCollectView:ctor(name, params)
    FarmCollectView.super.ctor(self, name, params)
    self._buildArray = {
        uq.config.constant.BUILD_ID.FARM_LAND_1,
        uq.config.constant.BUILD_ID.FARM_LAND_2,
        uq.config.constant.BUILD_ID.FARM_LAND_3,
        uq.config.constant.BUILD_ID.FARM_LAND_4,
    }
    self._buildId = params.build_id or 0
    services:dispatchEvent({name = services.EVENT_NAMES.ON_MAIN_CITY_BUILD_TO_POS, build_id = params.build_id})
    network:addEventListener(Protocol.S_2_C_LOAD_INFO, handler(self, self.setDataPage), '_onLoadFarmInfo' .. tostring(self))
    network:addEventListener(Protocol.S_2_C_FRAM_HARVEST, handler(self, self.onFramRet), '_onFram')
    self._resUpdataTag = services.EVENT_NAMES.ON_UPDATE_BUILDER_RESOURCE .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_UPDATE_BUILDER_RESOURCE, handler(self, self.onUpdateRes), self._resUpdataTag)
    self._nodeInfo:setVisible(false)
    self._nodeForce:setVisible(false)
    self._btnForce:setVisible(false)
    self._btnCollect:setPositionX(self._btnCollect:getPositionX() - 134)
    self._nodeCD:setPositionX(self._nodeCD:getPositionX() - 134)
    self._spriteCost:setTexture("img/common/ui/s03_000517.png")
end

function FarmCollectView:init()
    self:setPosition(display.center)
    self:setContentSize(display.size)
    self:hideMainUI()
    self._cdTimeNormalCollectReleaseTag = '_onNormalCollectCdTimeReleaseTag'
    self:addShowCoinGroup({uq.config.constant.COST_RES_TYPE.FOOD, uq.config.constant.COST_RES_TYPE.GOLDEN})
    self:centerView()
    self:parseView()
    self._cdTime = 0
    self:setTitle(uq.config.constant.MODULE_ID.FARM_LAND)
    self:setBaseBgClip()
    self._nodeData:setVisible(true)
    self._houseArray = {self._nodeHouse1, self._nodeHouse2, self._nodeHouse3, self._nodeHouse4}
    self._nodeData:setPosition(display.right_bottom)
    self._nodeAppoint:setPositionX(display.left)
    self:initDialog()
    network:sendPacket(Protocol.C_2_S_LOAD_INFO)
    self:adaptBgSize()
end

function FarmCollectView:initDialog()
    self._mainBuildLvlLabel:setString(StaticData['local_text']['label.common.level'] .. uq.cache.role:level())
    for k, v in ipairs(self._houseArray) do
        local build_xml = StaticData['buildings']['CastleMap'][self._buildArray[k]]
        v:getChildByName("name"):setString(build_xml.name)
        local level = uq.cache.role:getBuildingLevel(self._buildArray[k])
        local is_lock = uq.cache.role:isBuildLock(build_xml)
        v:getChildByName("Image_icon"):setVisible(not is_lock)
        v:getChildByName("Image_lock"):setVisible(is_lock)
        v:getChildByName("house_level"):setTextColor(uq.parseColor("#F22926"))
        v:getChildByName("Image_goto"):setTouchEnabled(true)
        v:getChildByName("Image_goto")['info'] = build_xml
        v:getChildByName("Image_goto"):addClickEventListenerWithSound(function(sender)
            local build_xml = sender['info']
            local info = StaticData['menus'][build_xml.type]
            if info and #info.Menu == 1 then
                local config = info.Menu[1]
                uq.jumpToModule(config.moduleId, {build_id = build_xml.ident})
                self:disposeSelf()
            end
        end)
        if is_lock then
            v:getChildByName("Image_goto"):setVisible(false)
            v:getChildByName("Image_ok"):setVisible(false)
            v:getChildByName("house_level"):setString(string.format(StaticData['local_text']['collect.lock.des'], build_xml.level))
        else
            local max_level = uq.cache.role:level()
            if build_xml.maxLevel ~= 0 and build_xml.maxLevel < uq.cache.role:level() then
                max_level = build_xml.maxLevel
            end
            v:getChildByName("Image_goto"):setVisible(level < max_level)
            v:getChildByName("Image_ok"):setVisible(level >= max_level)
            v:getChildByName("house_level"):setString(level .. "/" .. max_level)
            if level >= max_level then
                v:getChildByName("house_level"):setTextColor(uq.parseColor("#FFFFFF"))
            else
                v:getChildByName("house_level"):setTextColor(uq.parseColor("#F22926"))
            end
        end
    end
    self._appointItem = uq.createPanelOnly('collect.AppointGeneral')
    self._nodeAppoint:addChild(self._appointItem)
    self._appointItem:setBuildId(self._buildId)
end

function FarmCollectView:onUpdateRes()
    local food = 0
    for k, v in ipairs(self._buildArray) do
        food = food + (uq.cache.role.buildings[v].resource or 0)
    end
    if self._collectData.food ~= food then
        self._collectData.food = food
        self:updateCDTime()
    end
end

function FarmCollectView:updateCDTime()
    self._txtCangetMoney:setString(self._collectData.food)
    local tab_server_time = os.date("*t", uq.cache.server_data:getServerTime())
    self._cdTime = 0
    if self._collectData.food <= 0 then
        self._cdTime = StaticData['level_collection'].Collection[1].cd - (tab_server_time.min * 60 + tab_server_time.sec)
    end
    self._btnCollect:setEnabled(self._cdTime <= 0)
    if self._cdTime <= 0 then
        uq.ShaderEffect:removeGrayButton(self._btnCollect)
    else
        uq.ShaderEffect:addGrayButton(self._btnCollect)
    end
    self._nodeCD:setVisible(self._cdTime > 0)
    uq.TimerProxy:removeTimer(self._cdTimeNormalCollectReleaseTag .. tostring(self))
    if self._cdTime > 0 then
        uq.ShaderEffect:addGrayButton(self._btnCollect)
        self._txtCdTime:setString(uq.getTime(self._cdTime, uq.config.constant.TIME_TYPE.HHMMSS))
        uq.TimerProxy:addTimer(self._cdTimeNormalCollectReleaseTag, function()
            self._cdTime = self._cdTime - 1
            self._txtCdTime:setString(uq.getTime(self._cdTime, uq.config.constant.TIME_TYPE.HHMMSS))
            if self._cdTime <= 0 then
                self._nodeCD:setVisible(false)
                self._btnCollect:setEnabled(true)
                uq.ShaderEffect:removeGrayButton(self._btnCollect)
                uq.TimerProxy:removeTimer(self._cdTimeNormalCollectReleaseTag)
            end
        end, 1, -1)
    else
        uq.ShaderEffect:removeGrayButton(self._btnCollect)
    end
end

function FarmCollectView:setDataPage(evt)
    if not evt then return end
    local data = evt.data
    self._collectData = {food = 0}
    for k, v in pairs(data.items) do
        if v.type_build == uq.config.constant.BUILD_TYPE.FARM_LAND then
            self._collectData.food = v.value
        end
    end
    self:updateCDTime()
end

function FarmCollectView:onCollect(event)
    if event.name ~= "ended" then
        return
    end
    if self._cdTime > 0 or self._collectData.food <= 0 then
        return
    end
    network:sendPacket(Protocol.C_2_S_FRAM_HARVEST)
end

function FarmCollectView:onExit()
    network:removeEventListenerByTag("_onLoadFarmInfo" .. tostring(self))
    uq.TimerProxy:removeTimer(self._cdTimeNormalCollectReleaseTag)
    network:removeEventListenerByTag("_onFram")
    services:removeEventListenersByTag(self._resUpdataTag)
    FarmCollectView.super:onExit()
end

function FarmCollectView:onFramRet(evt)
    if evt.data.ret ~= 0 then
        return
    end
    uq.fadeInfo(string.format(StaticData["local_text"]["label.collect.zhengshou.reward.money"], StaticData['types']['Cost'][1]['Type'][5]['icon'], tostring(evt.data.food)))
    uq.playSoundByID(39)
    network:sendPacket(Protocol.C_2_S_LOAD_INFO)
end

return FarmCollectView

