local InstanceModule = class("InstanceModule", require('app.modules.common.BaseViewWithHead'))

InstanceModule.RESOURCE_FILENAME = "instance/InstanceView.csb"
InstanceModule.RESOURCE_BINDING = {
    ["pre_btn"]           = {["varname"] = "_btnPre",["events"] = {{["event"] = "touch",["method"] = "enterPreInstance"}}},
    ["next_btn"]          = {["varname"] = "_btnNext",["events"] = {{["event"] = "touch",["method"] = "enterNextInstance"}}},
    ["node_left_middle"]  = {["varname"] = "_nodeLeftMiddle"},
    ["node_right_middle"] = {["varname"] = "_nodeRightMiddle"},
    ["txt_name"]          = {["varname"] = "_txtInstanceName"},
    ["image_bg"]          = {["varname"] = "_imageBg"},
    ["Text_1"]            = {["varname"] = "_txtStarNum"},
    ["LoadingBar_1"]      = {["varname"] = "_loadBar"},
    ["Node_3"]            = {["varname"] = "_nodeStarReward1"},
    ["Node_3_0"]          = {["varname"] = "_nodeStarReward2"},
    ["Node_3_1"]          = {["varname"] = "_nodeStarReward3"},
    ["node_right_bottom"] = {["varname"] = "_nodeRightBottom"},
    ["node_left_bottom"]  = {["varname"] = "_nodeLeftBottom"},
}

function InstanceModule:ctor(name, params)
    InstanceModule.super.ctor(self, name, params)
    self._npcs = {}
    uq.log('enter instance_id', params.instance_id)
    self._instanceId = params.instance_id
    uq.cache.role:setCurInstance(self._instanceId)
end

function InstanceModule:init()
    self:centerView()
    self._lastMusic = uq.getLastMusic()
    local coin_group = {
        uq.config.constant.COST_RES_TYPE.GESTE,
        uq.config.constant.COST_RES_TYPE.MONEY,
        uq.config.constant.COST_RES_TYPE.GOLDEN,
        uq.config.constant.COST_RES_TYPE.REDIF
    }
    self:addShowCoinGroup(coin_group)
    self:setTitle(uq.config.constant.MODULE_ID.INSTANCE)

    self._totalStar = uq.cache.instance:getChapterAllStar(self._instanceId)
    self._xmlData = StaticData['instance'][self._instanceId]
    self._mapConfig = StaticData.load('instance/' .. self._xmlData.fileId)
    local map_path = string.format('img/bg/fb/%s', self._mapConfig.Map[self._instanceId].background)
    self._imageBg:loadTexture(map_path)
    self._imageBg:ignoreContentAdaptWithSize(true)
    self:parseView()

    uq.playSoundByID(1107)

    self:initReward()
    self:initGeneralInfo()

    local instance_data = uq.cache.instance:getInstanceInfo(self._instanceId)
    if instance_data then
        --已有数据直接进
        self:enterInstance(self._instanceId)
    else
        network:sendPacket(Protocol.C_2_S_ENTER_INSTANCE, {instance_id = self._instanceId})
    end

    if uq.cache.instance:getMaxNpcID() % 10000 == 0 then
        self:showFunctions()
    end
    self._eventTag = services.EVENT_NAMES.ENTER_INSTANCE .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ENTER_INSTANCE, handler(self, self._eventEnterInstance), self._eventTag)

    self._panelArmy = uq.createPanelOnly('instance.ArmyDraft')
    self._nodeLeftMiddle:addChild(self._panelArmy)
    self._panelArmy:setPosition(cc.p(-110, 133))

    self:adaptNode()
    self:showAction()
end

function InstanceModule:initReward()
    for i = 1, 3 do
        local xml_data = self._mapConfig.Map[self._instanceId].starReward[self._instanceId * 10 + i]
        self['_nodeStarReward' .. i]:getChildByName('Text_2'):setString(xml_data.star)
        self['_nodeStarReward' .. i]:getChildByName('Image_5'):onTouch(handler(self, self.onRewardItemTouch))
        self['_nodeStarReward' .. i]:setPositionX(147 + xml_data.star / self._totalStar * 400)
    end
end

function InstanceModule:initGeneralInfo()
    self._generalRewardInfo = {}
    local index = 0
    for npc_id, item in pairs(self._mapConfig.Map[self._instanceId].Object) do
        if item.preview ~= "" then
            index = index + 1
            local ids = string.split(item.preview, ';')
            local general_id = 0
            for k, id in ipairs(ids) do
                local general_data = StaticData['general'][tonumber(id)]
                if general_data.camp == 0 or general_data.camp == uq.cache.role.country_id then
                    general_id = tonumber(id)
                end
            end
            local panel = uq.createPanelOnly('instance.InstanceGeneralItem')
            local size = panel:getContentSize()
            panel:setPosition(cc.p(-291 + size.width / 2, 25 + 83 * (index - 1) + size.height / 2))
            panel:setData(general_id, npc_id, self._xmlData)
            self._nodeRightBottom:addChild(panel)
            table.insert(self._generalRewardInfo, panel)
        end
    end
end

function InstanceModule:refreshGeneralInfo()
    for k, item in ipairs(self._generalRewardInfo) do
        item:refreshPage()
    end
end

function InstanceModule:onClose(event)
    if event.name == "ended" then
        self:disposeSelf()
        uq.jumpToModule(uq.config.constant.MODULE_ID.MAIN_CITY)
    end
end

function InstanceModule:onCreate()
    InstanceModule.super.onCreate(self)
    network:addEventListener(Protocol.S_2_C_INSTANCE_BATTLE, handler(self, self._onBattleRes), '_onInstanceBattleRes')

    self._eventNewInstance = services.EVENT_NAMES.ON_NEW_INSTANCE .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_NEW_INSTANCE, handler(self, self._onNewInstance), self._eventNewInstance)

    self._serviceShowMainUITag = services.EVENT_NAMES.ON_SHOW_MAIN_UI .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_SHOW_MAIN_UI, handler(self, self.showUI), self._serviceShowMainUITag)

    self._serviceHideMainUITag = services.EVENT_NAMES.ON_HIDE_MAIN_UI .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_HIDE_MAIN_UI, handler(self, self.hideUI), self._serviceHideMainUITag)

    self._eventFunctionOpenTag = services.EVENT_NAMES.ON_SHOW_FUNCTION_OPEN .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_SHOW_FUNCTION_OPEN, handler(self, self.showNextSingle), self._eventFunctionOpenTag)

    self._eventRewardGet = services.EVENT_NAMES.ON_INSTANCE_REWARD_GET .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_INSTANCE_REWARD_GET, handler(self, self.refreshReward), self._eventRewardGet)
end

function InstanceModule:onExit()
    network:removeEventListenerByTag('_onInstanceBattleRes')
    services:removeEventListenersByTag(self._eventNewInstance)
    services:removeEventListenersByTag(self._serviceShowMainUITag)
    services:removeEventListenersByTag(self._serviceHideMainUITag)
    services:removeEventListenersByTag(self._eventTag)
    services:removeEventListenersByTag(self._eventFunctionOpenTag)
    services:removeEventListenersByTag(self._eventRewardGet)

    InstanceModule.super.onExit(self)
end

function InstanceModule:_eventEnterInstance()
   self:enterInstance(self._instanceId)
end

function InstanceModule:enterInstance(id)
    self._npcs = {}

    local size = self._imageBg:getContentSize()
    for _, npc_config in pairs(self._mapConfig.Map[self._instanceId].Object) do
        if not self._npcs[npc_config.ident] then
            local panel = uq.createPanelOnly('instance.InstanceItem')
            self._imageBg:addChild(panel)
            local px = npc_config.x
            local py = npc_config.y
            panel:setPosition(cc.p(px, py))
            panel:setData(npc_config, self._instanceId)
            panel:setLocalZOrder(display.height - py)
            self._npcs[npc_config.ident] = panel
        end

        self:_showNode(self._npcs[npc_config.ident])
        --跳转
        if npc_config.ident == uq.cache.instance._jumpToChapter then
            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()
                self._npcs[npc_config.ident]:onHead({name = "ended"})
                uq.cache.instance._jumpToChapter = nil
            end)))
        end
    end
    self._txtInstanceName:setString(self._xmlData.name)
    self:refreshBtn()
    self:refreshReward()
    self:refreshGeneralInfo()
end

function InstanceModule:getMapMaxNpcID()
    local npc_id = 0
    for k, item in pairs(self._mapConfig.Map[self._instanceId].Object) do
        if item.ident > npc_id then
            npc_id = item.ident
        end
    end
    return npc_id
end

function InstanceModule:refreshBtn()
    self._btnPre:setVisible(true)
    if not self._xmlData.parent or not uq.cache.instance:getInstanceInfo(self._xmlData.parent.ident) then
        self._btnPre:setVisible(false)
    end

    self._btnNext:setVisible(false)
    if self._xmlData.next then
        if uq.cache.instance:getInstanceInfo(self._xmlData.next.ident) or uq.cache.instance:isNpcPassed(self:getMapMaxNpcID()) then
            self._btnNext:setVisible(true)
        end
    end
end

function InstanceModule:getCardPos(id)
    if not self._npcs[id] then
        return {}
    end
    local pos_x, pos_y = self._npcs[id]:getPosition()
    return self._imageBg:convertToWorldSpace(cc.p(pos_x, pos_y)) or {}
end

function InstanceModule:enterPreInstance(event)
    if event.name ~= 'ended' then
        return
    end
    local temp = StaticData['instance'][self._instanceId]
    if temp.parent then
        if not uq.cache.instance:getInstanceInfo(temp.parent.ident) then
            uq.fadeInfo(StaticData['local_text']['instance.unlock'])
        else
            uq.jumpToModule(uq.config.constant.MODULE_ID.INSTANCE, {instance_id = temp.parent.ident})
        end
    end
end

function InstanceModule:enterNextInstance(event)
    if event.name ~= 'ended' then
        return
    end

    local temp = StaticData['instance'][self._instanceId]
    if temp.next then
        if uq.cache.instance:getInstanceInfo(temp.next.ident) then
            uq.jumpToModule(uq.config.constant.MODULE_ID.INSTANCE, {instance_id = temp.next.ident})
        elseif uq.cache.instance:isNpcPassed(self:getMapMaxNpcID()) then
            uq.fadeInfo(string.format(StaticData['local_text']['label.achieve.limit'], temp.next.achievementId))
        end
    end
end

function InstanceModule:_onBattleRes(evt)
    local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.SINGLE_BATTLE_MODULE)
    if panel then
        return
    end

    local data = evt.data
    self._battleData = data
    self._npcID = data.npc_id
    local is_new = uq.cache.instance._instanceData[data.instance_id][data.npc_id].star == 0
    if data.star > uq.cache.instance._instanceData[data.instance_id][data.npc_id].star then
        uq.cache.instance._instanceData[data.instance_id][data.npc_id].star = data.star
        if is_new then
            services:dispatchEvent({name = services.EVENT_NAMES.ON_MAIN_CITY_REFRESH_BUILD})
        end
    end
    local info = StaticData['module'][uq.config.constant.MODULE_ID.DAILY_TASK]
    if info.openMission and info.openMission == data.npc_id then
        services:dispatchEvent({name = services.EVENT_NAMES.ON_TASK_UPDATE_RED})
    end

    local achievement_info = StaticData['module'][uq.config.constant.MODULE_ID.ACHIEVEMENT]
    if achievement_info.openMission and achievement_info.openMission == data.npc_id then
        services:dispatchEvent({name = services.EVENT_NAMES.ON_ACHIEVEMENT_UPDATE_RED})
    end
    local npc_config = self._mapConfig.Map[self._instanceId].Object[self._npcID]
    uq.BattleReport:getInstance():showBattleReport(data.report_id, handler(self, self.onPlayReportEnd), data.rewards, nil, 'img/bg/battle/' .. npc_config.battleBg)
end

function InstanceModule:onPlayReportEnd(report)
    if not report then
        return
    end
    uq.BattleReport:getInstance():showBattleResult(report)

    if report.is_replay then
        return
    end

    report.instance_id = self._instanceId
    report.npc_id = self._npcID
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CLOSE_NPC_INFO})
    if report.result > 0 then
        for k, item in pairs(self._npcs) do
            self:_showNode(item)
        end
        self:refreshItemEffect()
        uq.cache.instance:decNpcAtkNum(self._battleData.instance_id, self._battleData.npc_id)
        if self._npcID then
            uq.cache.guide:openTriggerGuide(uq.config.constant.GUIDE_TRIGGER.BATTLE_CLICK, self._npcID)
        end
    end
    self:refreshReward()
    self:refreshGeneralInfo()
end

function InstanceModule:refreshItemEffect()
    for k, item in pairs(self._npcs) do
        item:setEffect()
    end
end

function InstanceModule:_showNode(node)
    node:refresh()
end

function InstanceModule:_onNewInstance()
    if self._instanceId ~= uq.cache.role.cur_instance_id then
        uq.jumpToModule(uq.config.constant.MODULE_ID.INSTANCE, {instance_id = uq.cache.role.cur_instance_id})
    else
        self:refreshBtn()
    end

    if uq.cache.instance:getMaxNpcID() % 10000 ~= 0 then
        self:showFunctions()
    end
end

function InstanceModule:onNpcList(event)
    if event.name == "ended" then
        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.NPC_LIST, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
        if panel then
            panel:setData(self._instanceId)
        end
    end
end

function InstanceModule:showUI()
    --self._mainUI:setVisible(true)
end

function InstanceModule:hideUI()
    --self._mainUI:setVisible(false)
end

function InstanceModule:showFunctions()
    if uq.cache.instance:isRefrshOldMaxNpcId() then
        return
    end

    self:showFunc()
    uq.cache.instance:setOldMaxNpcId()
end

function InstanceModule:showFunc()
    local data = StaticData['function_tips'] or {}
    for i, v in ipairs(data) do
        local object = tonumber(v.openObject)
        if v.type == uq.config.constant.OPEN_TIPS.CARD and uq.cache.instance:getLastNpcID() == object then
            local module_ids = string.split(v.moduleId, ',')
            uq.cache.level_up:setFuncData(module_ids)
            break
        end
    end
    self:showNextSingle()
end

function InstanceModule:showNextSingle()
    self._timerTag = 'showNextSingle' .. tostring(self)
    uq.TimerProxy:addTimer(self._timerTag, function ()
        if not uq.cache.level_up:isFunctionOver() then
            return
        end

        local data = uq.cache.level_up:getFuncData()
        local index = uq.cache.level_up:getFuncIndex()
        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.NEW_FUNCTION_OPEN)
        panel:setData(data, index)
    end, 0.2, 1)
end

function InstanceModule:dispose()
    uq.playBackGroundMusic(self._lastMusic)
    InstanceModule.super.dispose(self)
end

function InstanceModule:refreshReward()
    local star_num = uq.cache.instance:getChapterTotalStar(self._instanceId)
    self._txtStarNum:setString(star_num .. '/' .. self._totalStar)
    self._loadBar:setPercent(star_num / self._totalStar * 100)

    for i = 1, 3 do
        local reward_node = self['_nodeStarReward' .. i]
        local id = self._instanceId * 10 + i
        local xml_data = self._mapConfig.Map[self._instanceId].starReward[id]
        reward_node:getChildByName('Text_2'):setString(xml_data.star)
        if xml_data.star <= star_num and not uq.cache.instance:isRewardGet(id) then
            reward_node:getChildByName('Image_8'):setVisible(true)
            reward_node:getChildByName('Image_9'):setVisible(true)
        else
            reward_node:getChildByName('Image_8'):setVisible(false)
            reward_node:getChildByName('Image_9'):setVisible(false)
        end
        if uq.cache.instance:isRewardGet(id) then
            reward_node:getChildByName('Image_5'):loadTexture('img/instance/s03_00073.png')
        else
            reward_node:getChildByName('Image_5'):loadTexture('img/instance/s03_00072.png')
        end
    end
    self._btnPre:getChildByName('img_red'):setVisible(false)
    if self._xmlData.parent then
        self._btnPre:getChildByName('img_red'):setVisible(not self:instanceRewardHasGot(self._xmlData.parent.ident))
    end

    self._btnNext:getChildByName('img_red'):setVisible(false)
    if self._xmlData.next then
        self._btnNext:getChildByName('img_red'):setVisible(not self:instanceRewardHasGot(self._xmlData.next.ident))
    end
end

function InstanceModule:instanceRewardHasGot(instance_id)
    local instance_data = StaticData['instance'][instance_id]
    local instance_id = instance_data.ident
    local map_config = StaticData.load('instance/' .. instance_data.fileId)
    local map_path = string.format('img/bg/fb/%s', map_config.Map[instance_id].background)
    local star_num = uq.cache.instance:getChapterTotalStar(instance_id)

    for i = 1, 3 do
        local id = instance_id * 10 + i
        local xml_data = map_config.Map[instance_id].starReward[id]
        if xml_data.star <= star_num and not uq.cache.instance:isRewardGet(id) then
            return false
        end
    end
    return true
end

function InstanceModule:onRewardItemTouch(event)
    if event.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    local tag = event.target:getTag()
    local id = self._instanceId * 10 + tag
    local star_num = uq.cache.instance:getChapterTotalStar(self._instanceId)
    local xml_data = self._mapConfig.Map[self._instanceId].starReward[id]

    local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.INSTANCE_REWARD_INFO, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
    panel:setData(xml_data, self._instanceId, id)
end

function InstanceModule:showAction()
    self._panelArmy:showAction()
    uq.intoAction(self._nodeLeftBottom, cc.p(0, -uq.config.constant.MOVE_DISTANCE))
    for i, v in ipairs(self._generalRewardInfo) do
        v:showAction()
    end
end

return InstanceModule