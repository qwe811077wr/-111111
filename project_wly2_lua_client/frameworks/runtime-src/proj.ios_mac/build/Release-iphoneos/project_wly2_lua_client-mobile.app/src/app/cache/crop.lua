local Crop = class("Crop")

function Crop:ctor()
    self._allCropInfo = {}
    self._allCropInfoMap = {}
    self._allMemberInfo = {}
    self._allApplyInfoSelf = {} --本人申请信息
    self._allApplyInfo = {} --他人申请信息
    self._loadCropInfo = {}
    self.join_cd = 0
    self._allLegionCampaign = {}
    self._openInstance = {}
    self._bossFight = {}
    self._bossRank = nil
    self._cropIconId = 1
    self._allRedbag = {}
    self._cropHelpData = {}
    self._cropHelpBuildData = {}
    self._helpReward = 0
    self._formationInfo = {}

    network:addEventListener(Protocol.S_2_C_LOAD_ALL_CROP_INFO_BEGIN, handler(self, self._onAllCropInfoBegin))
    network:addEventListener(Protocol.S_2_C_LOAD_ALL_CROP_INFO, handler(self, self._onAllCropInfo))
    network:addEventListener(Protocol.S_2_C_CREATE_CROP, handler(self, self._onCreateCrop))
    network:addEventListener(Protocol.S_2_C_CROP_APPLY, handler(self, self._onCropApply))
    network:addEventListener(Protocol.S_2_C_LOAD_ALL_MEMBER, handler(self, self._onMemberInfoList))
    network:addEventListener(Protocol.S_2_C_CROP_KICKOUT, handler(self, self._onKickOffMember))
    network:addEventListener(Protocol.S_2_C_CROP_KICKOUT_NOTIFY, handler(self, self._onKickOffMemberNotify))
    network:addEventListener(Protocol.S_2_C_LOAD_ALL_APPLY_MEMBER_BEGIN, handler(self, self._onAllApplyMemberBegin))
    network:addEventListener(Protocol.S_2_C_LOAD_ALL_APPLY_MEMBER, handler(self, self._onAllApplyMember))
    network:addEventListener(Protocol.S_2_C_LOAD_ALL_APPLY_MEMBER_END, handler(self, self._onAllApplyMemberEnd))
    network:addEventListener(Protocol.S_2_C_CROP_REJECT, handler(self, self._onApplyReject))
    network:addEventListener(Protocol.S_2_C_CROP_APPROVE, handler(self, self._onApprove))
    network:addEventListener(Protocol.S_2_C_CROP_APPROVE_NOTIFY, handler(self, self._onApproveNotify))
    network:addEventListener(Protocol.S_2_C_CROP_QUIT, handler(self, self._onCropQuit))
    network:addEventListener(Protocol.S_2_C_CROP_DISMISS, handler(self, self._onCropDismiss))
    network:addEventListener(Protocol.S_2_C_CANCEL_APPLY, handler(self, self._onCancelApply))
    network:addEventListener(Protocol.S_2_C_LOAD_CROP_INFO, handler(self, self._onCropInfo))
    network:addEventListener(Protocol.S_2_C_CROP_JOIN_SETTING, handler(self, self._onJoinSetting))
    network:addEventListener(Protocol.S_2_C_CROP_UPDATE_HEAD_ID, handler(self, self._onUpdateHeadId))

    network:addEventListener(Protocol.S_2_C_CROP_BOSS_LOAD, handler(self, self._onCropInstance))
    network:addEventListener(Protocol.S_2_C_CROP_BOSS_OPEN, handler(self, self._onOpenInstance))
    network:addEventListener(Protocol.S_2_C_CROP_BOSS_FIGHT, handler(self, self._onBossFight))
    network:addEventListener(Protocol.S_2_C_CROP_BOSS_RANK, handler(self, self._onBossRank))

    network:addEventListener(Protocol.S_2_C_CROP_REDBAG_LOAD_BEGIN,handler(self, self._onRedbagBegin))
    network:addEventListener(Protocol.S_2_C_CROP_REDBAG_LOAD, handler(self, self._onAllRedbag))
    network:addEventListener(Protocol.S_2_C_CROP_REDBAG_SEND, handler(self, self._onRedbagSend))
    network:addEventListener(Protocol.S_2_C_CROP_REDBAG_OVER, handler(self, self._onRedbagOver))
    network:addEventListener(Protocol.S_2_C_CROP_APPOINT_NOTIFY, handler(self, self._onCropAppointNotify))
    network:addEventListener(Protocol.S_2_C_CROP_LOAD_HELP, handler(self, self.onLoadCropHelp))
    network:addEventListener(Protocol.S_2_C_CROP_APPLY_HELP, handler(self, self.onApplyHelp))
    network:addEventListener(Protocol.S_2_C_CROP_HELP_UPDATE, handler(self, self.onApplyHelpUpdate))
    network:addEventListener(Protocol.S_2_C_CROP_DO_HELP, handler(self, self.onDoHelp))
    network:addEventListener(Protocol.S_2_C_CROP_HELP_DEL, handler(self, self.onCropHelpDel))
    network:addEventListener(Protocol.S_2_C_CROP_INSTANCE_FORMATION_LOAD, handler(self, self.onFormationLoad))
end

function Crop:isFriendly(crops_id)
    return true
end

function Crop:_onCropAppointNotify(msg)
    uq.log("_onCropAppointNotify   ", msg.data)
    for k, v in ipairs(msg.data.appoint) do
        local info = self:getMemberInfoById(v.role_id)
        if info then
            info.pos_cityid = v.pos_city
            info.pos = v.pos
        end
    end
    uq.fadeInfo(StaticData["local_text"]["crop.appoint.success"])
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CROP_APPOINT_NOTIFY})
end

function Crop:getMemberInfoById(id)
    for k, v in ipairs(self._allMemberInfo) do
        if id == v.id then
            return self._allMemberInfo[k]
        end
    end
    return nil
end

function Crop:_onAllCropInfoBegin(msg)
    uq.cache.role:setCropId(msg.data.my_crop_id)
    self._allCropInfo = {}
    self._allCropInfoMap = {}
    self._allApplyInfoSelf = msg.data.apply_crop_ids
    self.join_cd = msg.data.join_cd
end

function Crop:_onAllCropInfo(msg)
    for k, item in ipairs(msg.data.crops) do
        table.insert(self._allCropInfo, item)
        self._allCropInfoMap[item.id] = item
        if uq.cache.role.cropsId == item.id then
            self._cropIconId = item.head_id
            uq.cache.role.crop_name = item.name
        end
    end
end

function Crop:_onUpdateHeadId(msg)
    local data = msg.data
    if data.ret ~= 0 then
        uq.fadeInfo(StaticData["local_text"]["crop.change.head.fail"])
        return
    end
    self._cropIconId = data.head_id
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CROP_CHANGE_HEAD})
end

function Crop:getCropDisbandStaus(id)
    if self._allCropInfoMap[id] and self._allCropInfoMap[id].disband_cd > 0 then
        return true
    end
    return false
end

function Crop:_onCropLimits(evt)
    local my_crop = self._allCropInfoMap[uq.cache.role.cropsId]
    if my_crop and next(my_crop) ~= nil then
        my_crop.auto_join = evt.data.auto_join
        my_crop.limit_type = evt.data.limit_type
        my_crop.limit_value = evt.data.limit_value
    end
end

function Crop:isApplying(crop_id)
    for k, id in ipairs(self._allApplyInfoSelf) do
        if id == crop_id then
            return true
        end
    end
    return false
end

function Crop:openCrop()
    local close_layer = uq.ModuleManager.CROP_MY
    local go_layer = uq.ModuleManager.CROP_MAIN
    if uq.cache.role:hasCrop() then
        close_layer = uq.ModuleManager.CROP_MAIN
        go_layer = uq.ModuleManager.CROP_MY
    end
    local panel = uq.ModuleManager:getInstance():getModule(close_layer)
    if panel then
        panel:disposeSelf()
    end
    local last_music = uq.getLastMusic()
    local func = function ()
        if last_music ~= "" then
            uq.playBackGroundMusic(last_music)
        end
    end
    uq.ModuleManager:getInstance():darkenToModule(go_layer, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, func = func})
    uq.playSoundByID(111)
end

function Crop:_onCreateCrop(msg)
    if msg.data.ret == Protocol.CREATE_CROP_RET.cr_ok then
        uq.cache.role:setCropId(msg.data.id)
        self.join_cd = 0
        self:openCrop()
    elseif msg.data.ret == Protocol.CREATE_CROP_RET.cr_name_dup then
        uq.fadeInfo(StaticData['local_text']['crop.name.dup'])
    elseif msg.data.ret == Protocol.CREATE_CROP_RET.cr_has_crop then
        uq.fadeInfo(StaticData['local_text']['crop.already.has'])
    end
end
function Crop:isApplyFinish(id)
    for _,v in pairs(self._allApplyInfoSelf) do
        if v == id then
            return true
        end
    end
    return false
end

function Crop:_onCropApply(msg)
    if msg.data.ret == Protocol.CROP_APPLY_RET.ar_ok then
        for _,v in pairs(msg.data.apply_ids) do
            if not self:isApplyFinish(v) then
                table.insert(self._allApplyInfoSelf,v)
            end
        end
        services:dispatchEvent({name = services.EVENT_NAMES.ON_CRROP_REFRESH_APPLY})
    elseif msg.data.ret == Protocol.CROP_APPLY_RET.ar_full then
        uq.fadeInfo(StaticData['local_text']['crop.full'])
    elseif msg.data.ret == Protocol.CROP_APPLY_RET.ar_has_crop then
        uq.fadeInfo(StaticData['local_text']['crop.already.has'])
    elseif msg.data.ret == Protocol.CROP_APPLY_RET.ar_no_crop then
        uq.fadeInfo(StaticData['local_text']['crop.dismiss'])
    elseif msg.data.ret == Protocol.CROP_APPLY_RET.ar_unkown then
        uq.fadeInfo(StaticData['local_text']['label.error'])
    end
end

function Crop:_onCancelApply(msg)
    local data = msg.data
    for k,v in pairs(self._allApplyInfoSelf) do
        if v == data.crop_id then
            table.remove(self._allApplyInfoSelf,k)
            break
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CRROP_REFRESH_APPLY})
end

function Crop:_onCropInfo(evt)
    local data = evt.data
    if data and data.id then
        self._loadCropInfo[data.id] = data
    end
end

function Crop:getLoadCropInfoById(id)
    if self._loadCropInfo[id] and next(self._loadCropInfo[id]) ~= nil then
        return self._loadCropInfo[id]
    end
    return {}
end

function Crop:_onCropApplyCancel(msg)
    for i = #self._allApplyInfoSelf, 1, -1 do
        table.remove(self._allApplyInfoSelf,i)
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CRROP_REFRESH_APPLY})
end

function Crop:getCropIcon(id)
    local id = id or self._cropIconId
    local tab = StaticData['legion_heads']
    if tab and tab[id] and tab[id].icon then
        return "img/crop/" .. tab[id]["end"], "img/crop/" .. tab[id].icon
    end
    return "img/crop/" .. tab[1]["end"], "img/crop/" .. tab[1].icon
end

function Crop:getCropByName(name)
    local list = {}
    if name == '' then
        list = self._allCropInfo
    else
        for k, item in ipairs(self._allCropInfo) do
            if item.name == name then
                table.insert(list, item)
                break
            end
        end
    end
    return list
end

function Crop:getCropDataById(crop_id)
    return self._allCropInfoMap[crop_id] or {}
end

function Crop:getCropData()
    return self._allCropInfoMap
end

function Crop:getCropLevel()
    local tab = self:getCropDataById(uq.cache.role.cropsId)
    if tab and tab.level then
        return tab.level
    end
    return 0
end

function Crop:_onJoinSetting(msg)
    local data = msg.data
    if self._allCropInfoMap[uq.cache.role.cropsId] then
        self._allCropInfoMap[uq.cache.role.cropsId].limit_type = data.limit_type
        self._allCropInfoMap[uq.cache.role.cropsId].limit_value = data.limit_value
        self._allCropInfoMap[uq.cache.role.cropsId].auto_join = data.auto_join
    end
end

function Crop:_onAllApplyMemberBegin(msg)
    self._allApplyInfo = {}
end

function Crop:_onAllApplyMember(msg)
    for k, item in ipairs(msg.data.members) do
        table.insert(self._allApplyInfo, item)
    end
    if msg.data.is_notify == 1 then
        self:updataApplyRed()
    end
end

function Crop:_onAllApplyMemberEnd(msg)
    self:updataApplyRed()
end
--退出军团
function Crop:_onCropQuit(msg)
    if msg.data.ret == 0  and uq.cache.role.id == msg.data.role_id then
        uq.cache.role:setCropId(0)
        self.join_cd = msg.data.join_cd
        local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.CROP_MY)
        if panel then
            self:openCrop()
        end
    end
end
--自己退出军团
function Crop:_onCropDismiss(msg)
    if msg.data.ret == 0 then
        uq.cache.role:setCropId(0)
        self.join_cd = msg.data.dismiss_cd
        local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.CROP_MY)
        if panel then
            self:openCrop()
        end
    end
end

function Crop:_onMemberInfoList(msg)
    if msg.data.crop_id ~= uq.cache.role.cropsId then
        return
    end
    if msg.data.is_notify == 0 then
        self._allMemberInfo = {}
    end
    for k, item in ipairs(msg.data.members) do
        table.insert(self._allMemberInfo, item)
    end
    if msg.data.is_notify ~= 0 then
        for k, item in ipairs(msg.data.members) do
            local info = {
                msg_type = uq.config.constant.TYPE_CHAT_CHANNEL.CC_TEAM,
                content_type = uq.config.constant.TYPE_CHAT_CONTENT.CCT_TIPS_TEAM,
                role_name = item.name,
                create_time = os.time(),
                content = "",
            }
            uq.cache.chat:addCropData(info)
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CRROP_REFRESH_MY})
end

function Crop:getApplyMemberId(id)
    return self._allApplyMemberIdMap[id]
end

function Crop:_onCropsApplyMemberInfoRet(msg)
    for k,item in ipairs(msg.data.cropsApplyMemberInfo) do
        self._allApplyMemberIdMap[item.accId] = item
    end
end

function Crop:_onKickOffMember(msg)
    if msg.data.ret == 0 then
        for k, item in ipairs(self._allMemberInfo) do
            if item.id == msg.data.id then
                table.remove(self._allMemberInfo, k)
                break
            end
        end
        services:dispatchEvent({name = services.EVENT_NAMES.ON_CRROP_REFRESH_MY})
    end
end

function Crop:_onKickOffMemberNotify(msg)
    if msg.data.id == uq.cache.role.id then
        uq.cache.role:setCropId(0)

        local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.CROP_MY)
        if panel then
            panel:disposeSelf()
        end

        services:dispatchEvent({name = services.EVENT_NAMES.ON_CRROP_REFRESH_MAIN})
    end
end

function Crop:_cropAutoJionSetting(msg)
end

function Crop:_onApplyReject(msg)
    for i, apply_info in ipairs(self._allApplyInfo) do
        for j, id in ipairs(msg.data.ids) do
            if apply_info.id == id then
                table.remove(self._allApplyInfo, i)
            end
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CRROP_REFRESH_APPLY_LIST})
    self:updataApplyRed()
end

function Crop:_onApprove(msg)
    for i, apply_info in ipairs(self._allApplyInfo) do
        for j, id in ipairs(msg.data.ids) do
            if apply_info.id == id then
                table.remove(self._allApplyInfo, i)
            end
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CRROP_REFRESH_APPLY_LIST})
    self:updataApplyRed()
end

function Crop:_onApproveNotify(msg)
    uq.cache.role:setCropId(msg.data.crop_id)

    local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.CROP_MAIN)
    if panel then
        self:openCrop()
    end
end

function Crop:getMyCropLeaderId()
    if uq.cache.role.cropsId == 0 then
        return 0
    end
    local tab = self._loadCropInfo[uq.cache.role.cropsId]
    if tab and tab.leader_id then
        return tab.leader_id
    end
    return 0
end

function Crop:getMyCropInfo()
    return self._loadCropInfo[uq.cache.role.cropsId]
end

function Crop:_onCropInstance(msg)
    self._allLegionCampaign = msg.data

    services:dispatchEvent({name = services.EVENT_NAMES.ON_LEGION_CAMPAIGN_OPEN, data = self._allLegionCampaign})
end

function Crop:_onOpenInstance(msg)
    self._openInstance = msg.data
    self._allLegionCampaign.cur_boss_id = msg.data.boss_id
    self._allLegionCampaign.cur_instance_id = msg.data.instance_id
    self._allLegionCampaign.max_hp = msg.data.max_hp
    self._allLegionCampaign.cur_hp = msg.data.max_hp
end

function Crop:_onBossFight(msg)
    self._bossFight = msg.data
    self._allLegionCampaign.battle_num = msg.data.battle_num

    services:dispatchEvent({name = services.EVENT_NAMES.ON_REFRESH_HP_BAR, data = self._bossFight})
end

function Crop:_onBossRank(msg)
    self._bossRank = msg.data

    services:dispatchEvent({name = services.EVENT_NAMES.ON_REFRESH_RANK_DATA, data = self._bossRank})
end

function Crop:_onRedbagBegin(msg)
    self._redbagSendNum = msg.data.send_num
    self._redbagPickNum = msg.data.pick_num
end

function Crop:_onAllRedbag(msg)
    for k,v in pairs(msg.data.redbags) do
        table.insert(self._allRedbag, v)
    end

    services:dispatchEvent({name = services.EVENT_NAMES.ON_CHAT_REFRESH, channel = uq.config.constant.TYPE_CHAT_CHANNEL.CC_BOARD})
end

function Crop:_onRedbagSend(msg)
    if msg.data.ret == 0 then
        self._redbagSendNum = self._redbagSendNum + msg.data.count
    end

    services:dispatchEvent({name = services.EVENT_NAMES.ON_CROP_REDBAG_SEND_NUM_REFRESH, {}})
end

function Crop:_onRedbagOver(msg)
    for k, v in pairs(self._allRedbag) do
        if v.id == msg.data.id then
            v.left_num = 0
        end
    end

    services:dispatchEvent({name = services.EVENT_NAMES.ON_CHAT_REFRESH, channel = uq.config.constant.TYPE_CHAT_CHANNEL.CC_BOARD})
end

function Crop:updataApplyRed()
    local is_red = self:getMyCropLeaderId() == uq.cache.role.id and #self._allApplyInfo > 0
    uq.cache.hint_status.status[uq.cache.hint_status.RED_TYPE.CROP_APPLY] = is_red
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CROP_RED_APPLY, data = uq.cache.hint_status.RED_TYPE.CROP_APPLY})
    self:updateRed()
end

function Crop:updateRed()
    local red_type = {
        uq.cache.hint_status.RED_TYPE.CROP_APPLY,
    }
    local is_red = false
    for k, v in ipairs(red_type) do
        if is_red then
            break
        else
            is_red = uq.cache.hint_status.status[v]
        end
    end
    uq.cache.hint_status.status[uq.cache.hint_status.RED_TYPE.MAIN_CITY_CROP] = is_red
    services:dispatchEvent({name = services.EVENT_NAMES.ON_MAIN_CITY_BOTTOM_SIDE_RED_CHANGES, data = uq.cache.hint_status.RED_TYPE.MAIN_CITY_CROP})
end

function Crop:refreshCropHelp(help_data)
    local build_id = help_data.build_id
    if not self._cropHelpBuildData[build_id] then
        self._cropHelpBuildData[build_id] = {}
        self._cropHelpBuildData[build_id].count = 0
    end
    local off_count = help_data.count - self._cropHelpBuildData[build_id].count
    local build_data = uq.cache.role.buildings[build_id]
    local xml_data = StaticData['crop_help'].build[build_data.level]
    uq.cache.role.buildings[build_id].cd_time = build_data.cd_time - off_count * xml_data.effect

    if uq.cache.role.buildings[help_data.build_id].cd_time <= os.time() then
        network:sendPacket(Protocol.C_2_S_BUILD_FINISH_LEVEL_UP, {build_id = data.build_id})
    else
        services:dispatchEvent({name = services.EVENT_NAMES.ON_MAIN_CITY_REFRESH_BUILD})
    end
    self._cropHelpBuildData[build_id] = help_data
end

function Crop:onLoadCropHelp(evt)
    self._helpReward = evt.data.help_reward
    for k, item in ipairs(evt.data.help_list) do
        self._cropHelpData[item.member_id .. '_' .. item.build_id] = item
        if item.member_id == uq.cache.role.id then
            self:refreshCropHelp(item)
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CROP_REFRESH})
end

function Crop:onApplyHelpUpdate(evt)
    self._cropHelpData[evt.data.member_id .. '_' .. evt.data.build_id] = evt.data
    if evt.data.member_id == uq.cache.role.id then
        self:refreshCropHelp(evt.data)
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CROP_REFRESH})
end

function Crop:getHelpDataList()
    local datalist = {}
    for k, item in pairs(self._cropHelpData) do
        if item.cd_time > uq.curServerSecond() and item.member_id ~= uq.cache.role.id then
            table.insert(datalist, item)
        end
    end
    table.sort(datalist, function(item1, item2)
        local score1 = self:isHelped(item1) and 1 or 0
        local score2 = self:isHelped(item2) and 1 or 0
        return score1 > score2
    end)
    return datalist
end

function Crop:isHelped(help_data)
    local helped = false
    for k, item in ipairs(help_data) do
        if item == uq.cache.role.id then
            helped = true
            break
        end
    end
    return helped
end

function Crop:onApplyHelp(evt)
    if evt.data.ret == 0 then
        uq.fadeInfo(StaticData['local_text']['label.crop_help.desc1'])
    end
end

function Crop:isCropHelping(build_id)
    return self._cropHelpBuildData[build_id] ~= nil
end

function Crop:removeCropHelpData(build_id)
    self._cropHelpBuildData[build_id] = nil
end

function Crop:getCropHelpData(build_id)
    return self._cropHelpBuildData[build_id]
end

function Crop:getCropHelpReward()
    return self._helpReward
end

function Crop:onDoHelp(evt)
    self._helpReward = evt.data.help_reward
end

function Crop:onCropHelpDel(evt)
    self._cropHelpData[evt.data.member_id .. '_' .. evt.data.build_id] = nil
    if evt.data.member_id == uq.cache.role.id then
        self._cropHelpBuildData[evt.data.build_id] = nil
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CROP_REFRESH})
end

function Crop:getFormationInfo()
    if self._formationInfo.formation_id == 0 then
        self._formationInfo.formation_id = uq.cache.formation:getDefaultIndex()
    end
    if not self._formationInfo.general_loc then
        self._formationInfo.general_loc = {}
    end
    return self._formationInfo
end

function Crop:onFormationLoad(evt)
    self._formationInfo = evt.data
end

function Crop:setFormation(data)
    self._formationInfo.formation_id = data.formation_id
    self._formationInfo.general_loc = data.general_loc
end

function Crop:setCropLevel(level)
    local tab = self._allCropInfoMap[uq.cache.role.cropsId] or {}
    if not tab or next(tab) == nil then
        return
    end
    self._allCropInfoMap[uq.cache.role.cropsId].level = level
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CRROP_CHANGE_INFO})
end

return Crop