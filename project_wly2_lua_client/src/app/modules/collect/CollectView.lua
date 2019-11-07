local CollectView = class("CollectView", require('app.modules.common.BaseViewWithHead'))

CollectView.RESOURCE_FILENAME = "collect/CollectView.csb"
CollectView.RESOURCE_BINDING = {
    ["img_bg_adapt"]                          = {["varname"] = "_imgBg"},
    ["Node_appoint"]                          = {["varname"] = "_nodeAppoint"},
    ["Node_item"]                             = {["varname"] = "_nodeData"},
    ["Node_item/Node_2/Text_level"]           = {["varname"] = "_mainBuildLvlLabel"},
    ["Node_item/Node_get/canget"]             = {["varname"] = "_txtCangetMoney"},
    ["Node_item/Node_4/cost"]                 = {["varname"] = "_txtCost"},
    ["Node_item/node_cd/Text_1"]              = {["varname"] = "_txtCdTime"},
    ["Node_item/node_cd"]                     = {["varname"] = "_nodeCD"},
    ["Node_item/Node_house1"]                 = {["varname"] = "_nodeHouse1"},
    ["Node_item/Node_house2"]                 = {["varname"] = "_nodeHouse2"},
    ["Node_item/Node_house3"]                 = {["varname"] = "_nodeHouse3"},
    ["Node_item/Node_house4"]                 = {["varname"] = "_nodeHouse4"},
    ["Node_item/Button_collect"]              = {["varname"] = "_btnCollect",["events"] = {{["event"] = "touch",["method"] = "onCollect"}}},
    ["Node_item/Button_force"]                = {["varname"] = "_btnForce",["events"] = {{["event"] = "touch",["method"] = "onCollectForce"}}},
    ["Node_item/Button_collect/txtcollect"]   = {["varname"] = "_txtCollect"},
    ["Node_item/Button_force/txtcollect"]     = {["varname"] = "_txtForceCollect"},
    ["Node_1/Node_event/Button_2"]            = {["varname"] = "_btnEvent",["events"] = {{["event"] = "touch",["method"] = "onEvent"}}},
    ["Node_1/Node_event/Text_btn_num"]        = {["varname"] = "_txtBtntNum"},
    ["Node_1/collect_force_num"]              = {["varname"] = "_forceCollectNumLabel"},
    ["Node_1/Image_39"]                       = {["varname"] = "_percentImgBg"},
    ["Node_1/img_force_percent"]              = {["varname"] = "_percentImg"},
    ["Node_1"]                                = {["varname"] = "_nodeInfo"},
    ["Node_1/Node_event"]                     = {["varname"] = "_nodeBtnEvent"},
}

function CollectView:ctor(name, params)
    CollectView.super.ctor(self, name, params)
    self._buildArray = {
        uq.config.constant.BUILD_ID.HOUSE_1,
        uq.config.constant.BUILD_ID.HOUSE_2,
        uq.config.constant.BUILD_ID.HOUSE_3,
        uq.config.constant.BUILD_ID.HOUSE_4,
    }
    self._buildId = params.build_id or 0
    services:dispatchEvent({name = services.EVENT_NAMES.ON_MAIN_CITY_BUILD_TO_POS, build_id = params.build_id})
    network:addEventListener(Protocol.S_2_C_LOAD_EVENT, handler(self, self.setDataPage), '_onLoadCollectionInfo')
    network:addEventListener(Protocol.S_2_C_COLLECTION_MONEY, handler(self, self._CollectionInfoRet), '_normalCollection')
    network:addEventListener(Protocol.S_2_C_EVENT_SELECT, handler(self, self._eventSelect), 'eventSelect')
    self._resUpdataTag = services.EVENT_NAMES.ON_UPDATE_BUILDER_RESOURCE .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_UPDATE_BUILDER_RESOURCE, handler(self, self.onUpdateRes), self._resUpdataTag)
end

function CollectView:init()
    self:setPosition(display.center)
    self:setContentSize(display.size)
    self:hideMainUI()
    self._cdTimeNormalCollectReleaseTag = '_onNormalCollectCdTimeReleaseTag'
    self:addShowCoinGroup({uq.config.constant.COST_RES_TYPE.MONEY, uq.config.constant.COST_RES_TYPE.GOLDEN})
    self:centerView()
    self:parseView()
    self._cdTime = 0
    self:setTitle(uq.config.constant.MODULE_ID.RESOURCE_COLLECT)
    self:setBaseBgClip()
    self._nodeData:setVisible(true)
    self._houseArray = {self._nodeHouse1, self._nodeHouse2, self._nodeHouse3, self._nodeHouse4}
    self._imgWidth = self._percentImgBg:getContentSize().width
    self._nodeInfo:setPosition(display.left_bottom)
    self._nodeData:setPosition(display.right_bottom)
    self._nodeAppoint:setPositionX(display.left)
    self:initDialog()
    network:sendPacket(Protocol.C_2_S_LOAD_EVENT)
    self:adaptBgSize()
end

function CollectView:initDialog()
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

function CollectView:onUpdateRes()
    local money = 0
    for k, v in ipairs(self._buildArray) do
        money = money + (uq.cache.role.buildings[v].resource or 0)
    end
    if self._collectData.money ~= money then
        self._collectData.money = money
        self:updateCDTime()
    end
end

function CollectView:updateCDTime()
    self._txtCangetMoney:setString(self._collectData.money)
    local tab_server_time = os.date("*t", uq.cache.server_data:getServerTime())
    self._cdTime = 0
    if self._collectData.money <= 0 then
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

function CollectView:setDataPage(evt)
    if not evt then return end
    self._collectData = evt.data
    self:updateCDTime()
    self:updateForceNum()
    self:refreshEventPage()
end

function CollectView:updateForceNum()
    local info = StaticData['level_collection'].Collection[1]
    self._txtCost:setString(info.forceNum)
    self._forceCollectNumLabel:setString(StaticData['local_text']['collect.force.des3'] .. self._collectData.force_collection_num .. "/" .. info.forceCounts)
    local width = math.floor(self._collectData.force_collection_num / info.forceCounts * self._imgWidth)
    if width > self._imgWidth then
        width = self._imgWidth
    end
    self._percentImg:setContentSize(cc.size(width , self._percentImg:getContentSize().height))
end

function CollectView:refreshEventPage()
    local event_num = #self._collectData.event_ids
    if event_num > 0 then
        local id = self._collectData.event_ids[event_num]
        uq.ModuleManager:getInstance():show(uq.ModuleManager.COLLECT_EVENT_MODULE, {event_id = id, event_num = #self._collectData.event_ids})
    end
    self:refreshEventPageNum()
end

function CollectView:refreshEventPageNum()
    self._eventNum = #self._collectData.event_ids
    self._nodeBtnEvent:setVisible(self._eventNum > 0)
    self._txtBtntNum:setString(tostring(self._eventNum))
end

function CollectView:onCollectForce(event)
    if event.name ~= "ended" then
        return
    end
    local info = StaticData['level_collection'].Collection[1]
    if self._collectData.force_collection_num >= info.forceCounts then
        uq.fadeInfo(StaticData["local_text"]["collect.force.des"])
        return
    end
    if not uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN, info.forceNum) then
        uq.fadeInfo(StaticData['local_text']['label.common.not.enough.gold'])
        return
    end

    local function confirm()
        network:sendPacket(Protocol.C_2_S_COLLECTION_MONEY)
    end
    local cost = uq.config.constant.COST_RES_TYPE.GOLDEN .. ";" .. info.forceNum .. ";0"
    local item_data = uq.RewardType.new(cost)
    local des = string.format(StaticData['local_text']['collect.force.des2'], item_data:toMiniIconHTMLStr())
    local data = {
        content = des,
        confirm_callback = confirm
    }
    uq.addConfirmBox(data)
end

function CollectView:onCollect(event)
    if event.name ~= "ended" then
        return
    end
    if self._cdTime > 0 then
        return
    end
    network:sendPacket(Protocol.C_2_S_COLLECTION_MONEY)
end

function CollectView:onEvent(event)
    if event.name ~= "ended" then
        return
    end
    local event_num = #self._collectData.event_ids
    if event_num > 0 then
        local id = self._collectData.event_ids[event_num]
        uq.ModuleManager:getInstance():show(uq.ModuleManager.COLLECT_EVENT_MODULE, {event_id = id, event_num = #self._collectData.event_ids})
    end
end

function CollectView:onExit()
    network:removeEventListenerByTag("_onLoadCollectionInfo")
    uq.TimerProxy:removeTimer(self._cdTimeNormalCollectReleaseTag)
    network:removeEventListenerByTag("_normalCollection")
    network:removeEventListenerByTag("eventSelect")
    services:removeEventListenersByTag(self._resUpdataTag)
    CollectView.super:onExit()
end

function CollectView:_CollectionInfoRet(evt)
    uq.fadeInfo(string.format(StaticData["local_text"]["label.collect.zhengshou.reward.money"], StaticData['types']['Cost'][1]['Type'][101]['icon'], tostring(evt.data.gold_num)))
    uq.playSoundByID(39)
    network:sendPacket(Protocol.C_2_S_LOAD_EVENT)
end

function CollectView:_eventSelect(msg)
    if msg.data.ret ~= 0 then
        return
    end
    local id = self._collectData.event_ids[#self._collectData.event_ids]
    local reward_xml = StaticData['LevyEventCfg'][id]['Option'][msg.data.event_index].reward
    local rewards = string.split(reward_xml, ';')
    if #rewards > 1 then
        local item_type = tonumber(rewards[1])
        local item_xml = StaticData['types']['Cost'][1]['Type'][item_type]
        local icon = item_xml.icon
        if icon == nil then
            local value = tonumber(rewards[3])
            icon = StaticData[item_xml.file][value].mimiIcon
        end
        uq.fadeInfo(string.format(StaticData["local_text"]["label.collect.zhengshou.reward.money"], icon, tostring(rewards[2])))
    else
        uq.fadeInfo(StaticData["local_text"]["label.collect.event.success"])
    end
    table.remove(self._collectData.event_ids, #self._collectData.event_ids)
    self:refreshEventPage(msg.data)
end

return CollectView

