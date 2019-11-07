local InitProtocol = class("InitProtocol")

local bit = require("bit")

function InitProtocol:init()
end

function InitProtocol:run()
    network:addEventListener(Protocol.S_2_C_ACCOUNT_INFO, handler(self, self._onAccountInfo), '_onAccountInfo')
    network:addEventListener(Protocol.S_2_C_CHAR_INFO, handler(self, self._onCharInfo), '_onCharInfo')
    network:addEventListener(Protocol.S_2_C_BUILD_ALL_INFO, handler(self, self._onCitysInfo), '_onCitysInfo')
    network:addEventListener(Protocol.S_2_C_CHAR_LOAD_END, handler(self, self._onLoadCharEnd), '_onLoadCharEnd')
    network:addEventListener(Protocol.S_2_C_ROLE_UPDATE_RESOURCE, handler(self, self._onRoleUpdateResource), '_onRoleUpdateResource')
    network:addEventListener(Protocol.S_2_C_LOAD_ROLE_RESOURCE, handler(self, self._onRoleLoadResource), '_onRoleLoadResource')
    network:addEventListener(Protocol.S_2_C_PEER_STATE, handler(self, self._onPeerState), '_onPeerState')
    network:addEventListener(Protocol.S_2_C_PEER_LOCAL_SERVERID, handler(self, self._onLocalServerId), '_onLocalServerId')
    network:addEventListener(Protocol.S_2_C_CHAR_TIMELIST_INFO, handler(self, self._onCharTimeListInfo), '_onCharTimeListInfo')
    network:addEventListener(Protocol.S_2_C_UPDATE_GAMETIME, handler(self, self._onGameTime), '_onGameTime')
    network:addEventListener(Protocol.S_2_C_MATERIALS_LOAD, handler(self, self._onMaterialsLoad), '_onMaterialsLoad')
    network:addEventListener(Protocol.S_2_C_MASTER_SEND_IMG, handler(self, self._onMasterSendImg), '_onMasterSendImg')
    network:addEventListener(Protocol.S_2_C_SCHOOL_FIELD_INFO, handler(self, self._onSchoolFieldInfo), '_onSchoolFieldInfo')
    network:addEventListener(Protocol.S_2_C_BUILD_LEVEL_UP, handler(self, self._onCityLevelUpRes), '_onCityLevelUpRes')
    network:addEventListener(Protocol.S_2_C_BUILD_MAIN_INFO, handler(self, self._onBuildMainInfo), '_onBuildMainInfo')
    network:addEventListener(Protocol.S_2_C_SWAP_SESSION, handler(self, self._onSwapSession), '_onSwapSession')
    network:addEventListener(Protocol.S_2_C_BUILD_CD_LIST, handler(self, self._onBuildCDList), '_onBuildCDList')
    network:addEventListener(Protocol.S_2_C_GENERAL_PIECE_NUM, handler(self, self._onLoadGeneralPiece), '_onLoadGeneralPiece')
    network:addEventListener(Protocol.S_2_C_ROLE_UPDATE_FORCE_VALUE, handler(self, self._onUpdateForceValue), '_onUpdateForceValue')
    network:addEventListener(Protocol.S_2_C_BUILD_CANCEL_LEVEL_UP, handler(self, self._onBuildCancleLevelUp), '_onBuildCancleLevelUp')
    network:addEventListener(Protocol.S_2_C_BUILD_FINISH_LEVEL_UP, handler(self, self._onFinishLevelUp), '_onFinishLevelUp')
    network:addEventListener(Protocol.S_2_C_BUILD_SPEED_UP, handler(self, self._onBuildSpeedUp), '_onBuildSpeedUp')
    network:addEventListener(Protocol.S_2_C_BUY_MILITYORDER_RES, handler(self, self._onBuyMilitoryRet), '_onBuyMilitoryRet')
    network:addEventListener(Protocol.S_2_C_BUILD_ADD_OFFICER, handler(self, self._onBuildOfficerAddRet), '_onBuildAddRet')
    network:addEventListener(Protocol.S_2_C_BUILD_DEL_OFFICER, handler(self, self._onBuildOfficerDelRet), '_onBuildDelRet')
    network:addEventListener(Protocol.S_2_C_BUILD_OFFICER_STATE_UPDATE, handler(self, self.onBuildOfficerStateUpdate), '_onBuildOfficerStateUpdate')
    network:addEventListener(Protocol.S_2_C_BUILD_BUSY_GENERAL_UPDATE, handler(self, self.onBuildOfficerBusyUpdate), '_onBuildOfficerBusyUpdate')
    network:addEventListener(Protocol.S_2_C_BUILD_RESOURCE_UPDATE, handler(self, self.onBuildResourceUpdate), '_onBuildResourceUpdate')
    network:addEventListener(Protocol.S_2_C_BUILD_GET_RESOURCE, handler(self, self.onBuildGetResource), '_onBuildGetResource')
    network:addEventListener(Protocol.S_2_C_BUILD_GENERAL_UNLOAD, handler(self, self.onBuildGeneralUnLoad), '_onBuildGeneralUnLoad')
    network:addEventListener(Protocol.S_2_C_BUILD_ONEKEY_ADD_OFFICER, handler(self, self.onBuildOfficerOneKey), '_onBuildOfficerOneKey')
    network:addEventListener(Protocol.S_2_C_MASTER_LOAD_ALL_INFO, handler(self, self._onMasterLoadAllInfo), '_onMasterLoadAllInfo')
    network:addEventListener(Protocol.S_2_C_MASTER_LEVEL_UP_NOTIFY, handler(self, self._onMasterLevelUpNotify), '_onMasterLevelUpNotify')
    network:addEventListener(Protocol.S_2_C_MASTER_LOAD_EXP, handler(self, self._onMasterLoadExp), '_onMasterLoadExp')
end

function InitProtocol:removeEvents()
    network:removeEventListenerByTag('_onMasterLoadExp')
    network:removeEventListenerByTag('_onMasterLevelUpNotify')
    network:removeEventListenerByTag('_onMasterLoadAllInfo')
    network:removeEventListenerByTag('_onAccountInfo')
    network:removeEventListenerByTag('_onRoleInfo')
    network:removeEventListenerByTag('_onCitysInfo')
    network:removeEventListenerByTag('_onLoadCharEnd')
    network:removeEventListenerByTag('_onPeerState')
    network:removeEventListenerByTag('_onLocalServerId')
    network:removeEventListenerByTag('_onCharTimeListInfo')
    network:removeEventListenerByTag('_onGameTime')
    network:removeEventListenerByTag('_onMaterialsLoad')
    network:removeEventListenerByTag('_onMasterSendImg')
    network:removeEventListenerByTag('_onSchoolFieldInfo')
    network:removeEventListenerByTag('_onSwapSession')
    network:removeEventListenerByTag('_onCityLevelUpRes')
    network:removeEventListenerByTag('_onBuildMainInfo')
    network:removeEventListenerByTag('_onBuildCDList')
    network:removeEventListenerByTag('_onLoadGeneralPiece')
    network:removeEventListenerByTag('_onUpdateForceValue')
    network:removeEventListenerByTag('_onBuildCancleLevelUp')
    network:removeEventListenerByTag('_onFinishLevelUp')
    network:removeEventListenerByTag('_onBuildSpeedUp')
    network:removeEventListenerByTag('_onBuyMilitoryRet')
    network:removeEventListenerByTag('_onBuildAddRet')
    network:removeEventListenerByTag('_onBuildDelRet')
    network:removeEventListenerByTag('_onBuildOfficerStateUpdate')
    network:removeEventListenerByTag('_onBuildOfficerBusyUpdate')
    network:removeEventListenerByTag('_onBuildResourceUpdate')
    network:removeEventListenerByTag('_onBuildGetResource')
    network:removeEventListenerByTag('_onBuildGeneralUnLoad')
    network:removeEventListenerByTag('_onBuildOfficerOneKey')
end

function InitProtocol:_onMasterLoadAllInfo(evt)
    uq.cache.role.master_lvl = evt.data.masterLvl
    uq.cache.role.master_exp = evt.data.exp
end

function InitProtocol:_onMasterLevelUpNotify(evt)
    for k, v in ipairs(evt.data.level_up) do
        table.insert(uq.cache.role.level_up_array, v)
    end
    local panel_instance = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.ARRANGED_BEFORE_WAR)
    if not panel_instance then
        uq.showRoleLevelUp()
    end
end

function InitProtocol:_onMasterLoadExp(evt)
    uq.cache.role.master_lvl = evt.data.lvl
    uq.cache.role.master_exp = evt.data.exp
    services:dispatchEvent({name = services.EVENT_NAMES.ON_MASTER_EXP_CHANGE})
end

function InitProtocol:_onMasterSendImg(evt)
    uq.cache.role.img_id = evt.data.img_id
    uq.cache.role.img_type = evt.data.img_type
end

function InitProtocol:_onLoadGeneralPiece(evt)
    local data = evt.data
    if data.count <= 0 then
        return
    end
    for k, v in ipairs(data.pieces) do
        uq.cache.role:setResChange(uq.config.constant.COST_RES_TYPE.SPIRIT, v.num, v.id)
    end
end

function InitProtocol:_onRoleUpdateResource(evt)
    local data = evt.data
    local materials_change = false
    local update_general = false
    local compose_general = false
    for s, t in pairs(data.rwds) do
        if t.type < uq.config.constant.COST_RES_TYPE.MATERIAL then
            local old_value = uq.cache.role.consume_res[t.type] or 0
            uq.cache.role.consume_res[t.type] = t.num
            services:dispatchEvent({name = services.EVENT_NAMES.ON_CONSUME_RES_CHANGE .. t.type, data = {old_value = old_value, new_value = t.num}})
            if uq.config.constant.COST_RES_TYPE.VIP_EXP == t.type then
                uq.cache.role.vip_exp = t.num
                uq.cache.role:updateVipLevel()
                services:dispatchEvent({name = services.EVENT_NAMES.ON_VIP_EXP_CHANGES,{}})
            end
        else
            materials_change = true
            local old_value = 0
            if t.type == uq.config.constant.COST_RES_TYPE.TRANSFORMED_SPIRIT then
                t.type = uq.config.constant.COST_RES_TYPE.SPIRIT
                uq.cache.generals:dealGetNewGenerals(t.paraml, false)
            end
            if uq.cache.role.materials_res[t.type] == nil then
                uq.cache.role.materials_res[t.type] = {}
            end
            old_value = uq.cache.role.materials_res[t.type][t.paraml] or 0
            if t.type == uq.config.constant.COST_RES_TYPE.MATERIAL then
                if t.paraml == uq.config.constant.MATERIAL_TYPE.PURPLE_DRAGON_JADE or
                    t.paraml == uq.config.constant.MATERIAL_TYPE.ORANGE_DRAGON_JADE or
                    t.paraml == uq.config.constant.MATERIAL_TYPE.REFRESH_ORDER or
                    t.paraml == uq.config.constant.MATERIAL_TYPE.MOIRE or
                    t.paraml == uq.config.constant.MATERIAL_TYPE.EQUIP_VOURCHER or
                    t.paraml == uq.config.constant.MATERIAL_TYPE.GENENRAL_VOURCHER then

                    services:dispatchEvent({name = services.EVENT_NAMES.ON_CONSUME_RES_CHANGE .. t.type,
                        data = {old_value = old_value, new_value = t.num, id = t.paraml}})
                end
            end
            if t.type == uq.config.constant.COST_RES_TYPE.SPIRIT or t.type == uq.config.constant.COST_RES_TYPE.ORDER_MATERIAL or
                (t.type == uq.config.constant.COST_RES_TYPE.MATERIAL and
                (t.paraml == uq.config.constant.MATERIAL_TYPE.EPIPHANY_STONE or t.paraml == uq.config.constant.MATERIAL_TYPE.SOUL)) then
                update_general = true
            end
            if t.type == uq.config.constant.COST_RES_TYPE.SPIRIT then
                compose_general = true
            end
            uq.cache.role.materials_res[t.type][t.paraml] = t.num
        end
    end
    if materials_change then
        services:dispatchEvent({name = services.EVENT_NAMES.ON_CONSUME_RES_CHANGE, {}})
    end

    if compose_general then
        services:dispatchEvent({name = services.EVENT_NAMES.ON_GENERALS_COMPOSE_RED})
    end

    if update_general then
        services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_ALL_GENERAL_RED})
    end
end

function InitProtocol:_onRoleLoadResource(evt)
    local data = evt.data
    for s, t in pairs(data.rwds) do
        if t.type < uq.config.constant.COST_RES_TYPE.MATERIAL then
            local old_value = uq.cache.role.consume_res[t.type] or 0
            uq.cache.role.consume_res[t.type] = t.num
            if uq.config.constant.COST_RES_TYPE.VIP_EXP == t.type then
                uq.cache.role.vip_exp = t.num
            end
        else
            if uq.cache.role.materials_res[t.type] == nil then
                uq.cache.role.materials_res[t.type] = {}
            end

            uq.cache.role.materials_res[t.type][t.paraml] = t.num
        end
    end
end

function InitProtocol:_onMaterialsLoad(evt)
    local data = evt.data
    for s,t in pairs(data.materials) do
        if uq.cache.role.materials_res[t.type] == nil then
            uq.cache.role.materials_res[t.type] = {}
        end
        uq.cache.role.materials_res[t.type][t.id] = t.num
    end
end

function InitProtocol:_onCharInfo(evt)
    uq.cache.role.id = evt.data.role_id
    uq.cache.role.name = evt.data.name
    uq.cache.role.country_id = evt.data.country_id
    uq.cache.role.vip_level = evt.data.vip_lvl
    uq.cache.role.vip_exp = evt.data.vip_exp
    uq.cache.role.vip_reward_lvl = evt.data.vip_reward_lvl
    uq.cache.role.cur_instance_id = evt.data.current_instance_id
    uq.cache.role.warehouse_num = evt.data.total_warehouse_num
    uq.cache.role.used_warehouse_num = evt.data.used_warehouse_num
    uq.cache.role.warehouse_draw_time = evt.data.warehouse_draw_time
    uq.cache.role.total_online_time = evt.data.total_online_time
    uq.cache.role.train_nums = evt.data.train_nums
    uq.cache.role.cropsId = evt.data.crop_id
    uq.cache.role.bubble_id = evt.data.bubble_id
    uq.cache.role.rename_times = evt.data.rename_times
    uq.cache.role.generalnums_max = evt.data.max_general_num > 3 and evt.data.max_general_num or 3
    uq.cache.role.create_time = evt.data.create_time
    uq.cache.role.buy_militory_order_num = evt.data.buy_militory_order_num

    StaticData.initInstanceData(uq.cache.role.country_id)
    StaticData.initInstanceWarData(uq.cache.role.country_id)
end

function InitProtocol:_onCharTimeListInfo(evt)
   uq.cache.role.join_crops_cd_time = evt.data.join_crops_cd_time
end

function InitProtocol:_onLoadCharEnd(evt)
    uq.cache.account.session_seed = evt.data.session_seed
    self:_loadInitInfo()
    -- uq.runCmd('enter_main_city')
end

function InitProtocol:_onPeerState(evt)
    local data = evt.data
    if data.msg_type == 1 then
        uq.cache.nodes._nodes[data.id] = data
    else
        uq.cache.nodes._nodes[data.id] = nil
    end
end

function InitProtocol:_onLocalServerId(evt)
    uq.cache.nodes._localNode = evt.data.serverId
end

function InitProtocol:_onAccountInfo(evt)
    local data = evt.data
    uq.cache.role.name = data.accName
    uq.cache.role.create_time = data.createTime
    uq.cache.role.vip_level = data.vip_lvl
    uq.cache.role.diamond = data.diamond
    services:dispatchEvent({name = "onAccountInfo"})
end

function InitProtocol:_onGameTime(evt)
    local data = evt.data
    uq.cache.server.year = data.year
    uq.cache.server.season = data.season
    uq.cache.server_data.server_client_offtime = data.server_time - os.time()
end

function InitProtocol:_onSchoolFieldInfo(evt)
    local data = evt.data
    --uq.cache.role.golden_sudden_fly_num = data.golden_sudden_fly_num
end

function InitProtocol:_onCitysInfo(evt)
    local data = evt.data
    uq.cache.role.build_times = data.build_times

    -- uq.cache.role.build_office_map = {}
    for i = 1, #data.builds do
        local build_id = data.builds[i].build_id
        if data.builds[i].cd_time > 0 and data.builds[i].cd_time <= uq.curServerSecond() then
            --上线cd时间完成
            network:sendPacket(Protocol.C_2_S_BUILD_FINISH_LEVEL_UP, {build_id = build_id})
        end

        uq.cache.role.buildings[build_id] = data.builds[i]
        uq.cache.role.buildings[build_id].cd_time = uq.cache.role.buildings[build_id].cd_time - uq.curServerSecond() + os.time()
    end

    for i = 1, #data.build_officier do
        local build_type = data.build_officier[i].build_type
        uq.cache.role.build_officer_list[build_type] = data.build_officier[i]
        for k, item in ipairs(data.build_officier[i].officer_list) do
            if item.general_id > 0 then
                uq.cache.role.build_office_map[item.general_id] = build_type
            end
        end
    end

    for k, item in pairs(StaticData['buildings']['CastleMap']) do
        if not uq.cache.role.buildings[k] then
            uq.cache.role.buildings[k] = {build_id = k, type = -1, level = 1, cd_time = 0, resource = 0}
        end
    end

    for k, item in pairs(uq.config.constant.BUILD_TYPE) do
        if not uq.cache.role.build_officer_list[k] then
            uq.cache.role.build_officer_list[k] = {officer_list = {}}
        end
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_MAIN_CITY_REFRESH_BUILD})
end

function InitProtocol:_onCityLevelUpRes(evt)
    local data = evt.data
    if data.ret ~= 0 then
        return
    end
    uq.cache.role.build_times = data.build_times
    uq.cache.role.buildings[data.build_id].cd_time = data.cd_time + os.time()

    services:dispatchEvent({name = services.EVENT_NAMES.ON_MAIN_CITY_REFRESH_BUILD})
end

function InitProtocol:_onBuildMainInfo(evt)
    local build_data = evt.data.build
    local build_id = build_data.build_id
    if build_data.cd_time > 0 and build_data.cd_time <= uq.curServerSecond() then
        -- 上线cd时间完成
        network:sendPacket(Protocol.C_2_S_BUILD_FINISH_LEVEL_UP, {build_id = build_id})
    end

    uq.cache.role.buildings[build_id] = build_data
    uq.cache.role.buildings[build_id].cd_time = uq.cache.role.buildings[build_id].cd_time - uq.curServerSecond() + os.time()

    services:dispatchEvent({name = services.EVENT_NAMES.ON_MAIN_CITY_REFRESH_BUILD})
end

function InitProtocol:_onSwapSession(evt)
    if evt.data.ret == 0 then
        uq.fadeInfo(StaticData["local_text"]["label.common.relogin.success"])
        services:dispatchEvent({name = services.EVENT_NAMES.ON_NETWORK_CONNECT_SUCCESS})
    else
        local data = {}
        if evt.data.ret == 3 then
            data.msg = "<#FFFFFF><24>" .. StaticData["local_text"]["label.common.network.logout"]
        else
            data.msg = "<#FFFFFF><24>" .. StaticData["local_text"]["label.common.relogin.error"]
        end
        data.style = 3
        data.title = nil
        data.confirmFunc = function() network:logout() end
        data.cancelFunc = nil
        uq.ModuleManager:getInstance():show(uq.ModuleManager.NETWORK_ERROR, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, dialogInfo = data, zOrder=10003})
    end
end

function InitProtocol:_onUpdateForceValue(evt)
    local add_power = uq.cache.role.power <= 0 and 0 or math.floor(evt.data.force_value - uq.cache.role.power)
    uq.cache.role.power = evt.data.force_value
    uq.cache.role.athleticPower = evt.data.athletic_rank
    services:dispatchEvent({name = services.EVENT_NAMES.REFRESH_POWER})
    if add_power <= 0 then
        return
    end
    local panel = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.POWER_PROMOTE_MODULE)
    if panel then
        panel:disposeSelf()
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.POWER_PROMOTE_MODULE, {add_power = add_power})
end

function InitProtocol:_onBuildCancleLevelUp(evt)
    if evt.data.ret == 0 then
        uq.cache.role.buildings[evt.data.build_id].cd_time = 0

        services:dispatchEvent({name = services.EVENT_NAMES.ON_MAIN_CITY_REFRESH_BUILD})
    end
end

function InitProtocol:_onFinishLevelUp(evt)
    self:onLevelUp(evt.data)
end

function InitProtocol:_onBuildCDList(evt)
    self:onLevelUp(evt.data)
end

function InitProtocol:onLevelUp(data)
    if data.ret == 0 then
        local is_lv_up = data.build_id == 0 and uq.cache.role.buildings[data.build_id].level < data.level
        uq.cache.role.build_times = data.build_times
        uq.cache.role.buildings[data.build_id].cd_time = 0
        uq.cache.role.buildings[data.build_id].level = data.level

        services:dispatchEvent({name = services.EVENT_NAMES.ON_MAIN_CITY_REFRESH_BUILD})

        local build = uq.cache.role.buildings[data.build_id]
        if build.build_id == 0 then
            services:dispatchEvent({name = services.EVENT_NAMES.ON_MAIN_BUILD_LEVEL_CHANGED})
        end
        services:dispatchEvent({name = services.EVENT_NAMES.ON_BUILD_LEVEL_UP, build_id = build.build_id})

        if build.level == 2 and data.build_id == 0 then
            uq.cache.level_up:setShowOpen(false)
        end
        if is_lv_up then
            uq.cache.guide:refreshToNextGuide()
        end
    end
end

function InitProtocol:_onBuildSpeedUp(evt)
    local data = evt.data
    if data.ret ~= 0 then
        return
    end

    local materials_data = StaticData['material'][data.material_id]
    local effect = materials_data.effect * data.material_num
    uq.cache.role.buildings[data.build_id].cd_time = uq.cache.role.buildings[data.build_id].cd_time - effect

    if uq.cache.role.buildings[data.build_id].cd_time <= os.time() then
        --加速道具使用成功
        network:sendPacket(Protocol.C_2_S_BUILD_FINISH_LEVEL_UP, {build_id = data.build_id})
    else
        services:dispatchEvent({name = services.EVENT_NAMES.ON_MAIN_CITY_REFRESH_BUILD})
    end
end

function InitProtocol:_onBuyMilitoryRet(evt)
    if evt.data.ret == 0 then
        uq.cache.role.buy_militory_order_num = evt.data.buy_times
        services:dispatchEvent({name = services.EVENT_NAMES.BUY_MILITORY_ORDER})
    end
end

function InitProtocol:_onBuildOfficerAddRet(evt)
    local data = evt.data
    if data.ret ~= 0 then
        return
    end
    local old_id = uq.cache.role.build_officer_list[data.build_type].officer_list[data.officer_pos + 1].general_id
    uq.cache.role.build_office_map[old_id] = nil

    uq.cache.role.build_officer_list[data.build_type].officer_list[data.officer_pos + 1].general_id = data.general_id
    uq.cache.role.build_office_map[data.general_id] = data.build_type

    uq.fadeInfo(StaticData['local_text']['label.buildofficer.up.success2'])
    uq.cache.role.build_officer_list[data.build_type].officer_list[data.officer_pos + 1].general_id = data.general_id
    uq.cache.role.build_officer_list[data.build_type].officer_list[data.officer_pos + 1].lock_state = 0

    services:dispatchEvent({name = services.EVENT_NAMES.ON_BUILD_OFFICER_REFRESH, build_type = data.build_type})
end

function InitProtocol:_onBuildOfficerDelRet(evt)
    local data = evt.data
    if data.ret ~= 0 then
        return
    end
    uq.cache.role.build_officer_list[data.build_type].officer_list[data.officer_pos + 1].general_id = 0
    uq.cache.role.build_office_map[data.general_id] = nil

    uq.fadeInfo(StaticData['local_text']['label.buildofficer.down.success'])
    uq.cache.role.build_officer_list[data.build_type].officer_list[data.officer_pos + 1].general_id = 0
    uq.cache.role.build_officer_list[data.build_type].officer_list[data.officer_pos + 1].lock_state = 0

    services:dispatchEvent({name = services.EVENT_NAMES.ON_BUILD_OFFICER_REFRESH, build_type = data.build_type})
end

function InitProtocol:onBuildOfficerStateUpdate(evt)
    local data = evt.data
    uq.cache.role.build_officer_list[data.build_type].officer_list = data.officer_item
    services:dispatchEvent({name = services.EVENT_NAMES.ON_BUILD_OFFICER_REFRESH, build_type = data.build_type})
end

function InitProtocol:onBuildOfficerBusyUpdate(evt)
    local data = evt.data
    for k, item in ipairs(evt.data.builds) do
        uq.cache.role.main_build_officer_effect[item.build_id] = item.general_id
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_BUILD_OFFICER_REFRESH})
end

function InitProtocol:onBuildResourceUpdate(evt)
    for k, item in ipairs(evt.data.build_resource) do
        uq.cache.role.buildings[item.build_id].resource = item.resource
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_BUILDER_RESOURCE})
end

function InitProtocol:onBuildGetResource(evt)
    local data = evt.data
    uq.cache.role.buildings[data.build_id].resource = 0
    uq.fadeItemInfo(data.rwds[1])

    services:dispatchEvent({name = services.EVENT_NAMES.ON_UPDATE_BUILDER_RESOURCE})
end

function InitProtocol:onBuildGeneralUnLoad(evt)
    --疲劳值满 武将强行卸任
    local office_data = {}
    for j, unload_data in ipairs(evt.data.unload) do
        for k, data_temp in ipairs(uq.cache.role.build_officer_list[unload_data.build_type].officer_list) do
            if data_temp.general_id == unload_data.general_id then
                uq.cache.role.build_officer_list[unload_data.build_type].officer_list[k].general_id = 0
                uq.cache.role.build_officer_list[unload_data.build_type].officer_list[k].lock_state = 0
            end
        end
        for build_id, effect_data in pairs(uq.cache.role.main_build_officer_effect) do
            local build_xml = StaticData['buildings']['CastleMap'][build_id]
            if build_xml.type == unload_data.build_type then
                for k, general_id in ipairs(uq.cache.role.main_build_officer_effect[build_id]) do
                    if general_id == unload_data.general_id then
                        table.remove(uq.cache.role.main_build_officer_effect[unload_data.build_id], k)
                    end
                end
            end
        end
        uq.cache.role.build_office_map[unload_data.general_id] = nil
        if not office_data[unload_data.build_type] then
            office_data[unload_data.build_type] = {}
        end
        table.insert(office_data[unload_data.build_type], unload_data.general_id)
        services:dispatchEvent({name = services.EVENT_NAMES.ON_BUILD_OFFICER_REFRESH, build_type = unload_data.build_type})
    end
    uq.cache.role.unload_officer_data = office_data

    services:dispatchEvent({name = services.EVENT_NAMES.ON_OFFICE_UNLOAD})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_STRATRGY_UP_REFRESH})
end

function InitProtocol:onBuildOfficerOneKey(evt)
    local data = evt.data
    local pop_info = false
    local pop_lock = false
    local build_type = data.build_type
    for k, item in ipairs(data.officer) do
        local old_id = uq.cache.role.build_officer_list[build_type].officer_list[item.officer_pos + 1].general_id
        uq.cache.role.build_office_map[old_id] = nil

        uq.cache.role.build_officer_list[build_type].officer_list[item.officer_pos + 1].general_id = item.general_id
        uq.cache.role.build_office_map[item.general_id] = build_type

        uq.cache.role.build_officer_list[build_type].officer_list[item.officer_pos + 1].general_id = item.general_id
        uq.cache.role.build_officer_list[build_type].officer_list[item.officer_pos + 1].lock_state = item.lock_state
        if item.lock_state == 0 then
            pop_info = true
        else
            pop_lock = true
        end
    end
    if pop_info then
        if pop_lock then
            uq.fadeInfo(StaticData['local_text']['label.buildofficer.up.success'])
        else
            uq.fadeInfo(StaticData['local_text']['label.buildofficer.up.success2'])
        end
        services:dispatchEvent({name = services.EVENT_NAMES.ON_BUILD_OFFICER_REFRESH, build_type = build_type})
    end
end

function InitProtocol:_loadInitInfo()
    network:sendPacket(Protocol.C_2_S_MASTER_LOAD_ALL_INFO)
    network:sendPacket(Protocol.C_2_S_CROP_LOAD_HELP)
    network:sendPacket(Protocol.C_2_S_EQUIPMENT_LOADALL, {})
    network:sendPacket(Protocol.C_2_S_FORMATION_INFO, {})
    network:sendPacket(Protocol.C_2_S_ALLGENERAL_INFO, {})
    network:sendPacket(Protocol.C_2_S_GENERAL_PIECE_NUM)
    network:sendPacket(Protocol.C_2_S_MATERIALS_LOAD, {})
    network:sendPacket(Protocol.C_2_S_LOAD_MAIN_TASK, {})
    network:sendPacket(Protocol.C_2_S_PASSCARD_INFO_LOAD)
    network:sendPacket(Protocol.C_2_S_MAIL_LOAD)
    network:sendPacket(Protocol.C_2_S_SCHOOL_FIELD_INFO)
    network:sendPacket(Protocol.C_2_S_INSTANCE_LIST)
    network:sendPacket(Protocol.C_2_S_LOAD_ALL_CROP_INFO)
    network:sendPacket(Protocol.C_2_S_LOAD_CROP_INFO, {id = 0})
    network:sendPacket(Protocol.C_2_S_LOAD_ALL_APPLY_MEMBER)
    network:sendPacket(Protocol.C_2_S_BOSOM_FRIEND_INFO, {})
    network:sendPacket(Protocol.C_2_S_GETRECRUIT_GENERAL_IDS, {})
    network:sendPacket(Protocol.C_2_S_ZONG_LOAD_INFO, {})
    network:sendPacket(Protocol.C_2_S_ANCIENT_CITY_ENTER, {})
    network:sendPacket(Protocol.C_2_S_LIVENESS_LOAD, {})
    network:sendPacket(Protocol.C_2_S_ILLUSTRATION_LOAD, {})
    network:sendPacket(Protocol.C_2_S_MIRACLE_FIGHT_LOAD, {})
    network:sendPacket(Protocol.C_2_S_CHAT_MSG_LOAD)
    network:sendPacket(Protocol.C_2_S_CROP_REDBAG_LOAD, {})
    network:sendPacket(Protocol.C_2_S_ACHIEVEMENT_LOAD)
    network:sendPacket(Protocol.C_2_S_APPOINT_INFO, {})
    network:sendPacket(Protocol.C_2_S_APPOINT_GENERAL_INFO, {})
    network:sendPacket(Protocol.C_2_S_LEVEL_GIFT_LOAD, {})
    network:sendPacket(Protocol.C_2_S_TASK_DAY7_LOAD)
    network:sendPacket(Protocol.C_2_S_ROLE_CHECKIN_LOAD)
    network:sendPacket(Protocol.C_2_S_GUIDE_LOAD, {})
    network:sendPacket(Protocol.C_2_S_RANDOM_EVENT_INFO_LOAD)
    network:sendPacket(Protocol.C_2_S_DRILL_GROUND_LOAD)
    network:sendPacket(Protocol.C_2_S_JIUGUAN_LOAD)
    network:sendPacket(Protocol.C_2_S_TRIAL_TOWER_LOAD_INFO, {})
    network:sendPacket(Protocol.C_2_S_TECHNOLOGY_LOAD, {})
    network:sendPacket(Protocol.C_2_S_CAMPAIGN_INFO_LOAD)
end

return InitProtocol