local Role = class("Role")

function Role:ctor()
    self.diamond = 0
    self.vip_level = 0
    self.vip_exp = 0
    self.vip_reward_lvl = 0
    self.vip_reward_info = 0
    self.cur_instance_id = 1
    self.warehouse_num = 0
    self.used_warehouse_num = 0
    self.name = ''
    self.id = 0
    self.create_time = 0
    self.build_times = 0
    self.builder_num = 0
    self.country_id = 0
    self.train_nums = 0
    self.cropsId = 0
    self.cropsStat = 0
    self.cropsContribute = 0
    self.world_area_id = 0
    self.areaId = 0
    self.bubble_id = 0 --气泡id
    self.join_crops_cd_time = 0
    self.generalnums_max = 0
    self.buildings = {}
    self.build_officer_list = {}
    self.consume_res = {}  --不带id的资源，金币什么的
    self.materials_res = {}  --对应type（cost）内ident = 150以上的材料
    self.confirm_ids = {}
    self.bosom = require('app/cache/bosom'):create()
    self.power = 0
    self.img_type = 0 --头像类型
    self.img_id = 0 --头像id
    self.master_lvl = 0 --主公等级
    self.master_exp = 0 --主公经验
    self.level_up_array = {} --主公升级数据
    self.crop_name = ''
    self.rename_times = 0
    --self.golden_sudden_fly_num = 0
    self.warehouse_draw_time = 0
    self.total_online_time = 0
    self.game_time = os.time()
    self.soldierNum = 0
    self.buy_militory_order_num = 0
    self.build_office_map = {} --武将对应占用它的建筑
    self.main_build_officer_effect = {} --建筑官 主建筑最大cd效果 建筑-effect
    self.switch_property = true
    self.unload_officer_data = nil
    self.rank = 0
end

function Role:isMaxMasterLevel()
    local constant = StaticData['player_level'].parameter[1]
    return constant.levelLimit <= self.master_lvl
end

function Role:getBuyMilitoryOrderNum()
    return self.buy_militory_order_num
end

function Role:level()
    local build = self.buildings[0]
    if build == nil then
        return 1
    end
    return build.level
end

function Role:exp()
    local build = self.buildings[0]
    if build == nil then
        return 1
    end
    return build.exp or 0
end

function Role:getImgId()
    self:refreshHeadInfo()
    return self.img_id
end

function Role:checkGeneralIsInBuild(id)
    return self.build_office_map[id] ~= nil
end

function Role:getImgType()
    self:refreshHeadInfo()
    return self.img_type
end

function Role:refreshHeadInfo()
    if self.img_type == 0 or self.img_id == 0 then
        for k,v in pairs(StaticData['majesty_heads']) do
            self.img_id = v.ident
            self.img_type = v.type
            break
        end
    end
end

function Role:setImgIdAndType(img_type, img_id)
    if img_type ~= "" and img_type ~= 0 then
        self.img_type = img_type
        self.img_id = img_id
        services:dispatchEvent({name = services.EVENT_NAMES.ON_REFRESH_ROLE_INFO})
    end
end
--TYPE_BUILDING
function Role:getBuildingLevel(id)
    local build = self.buildings[id]
    if build == nil then
        return 1
    end
    return build.level
end

function Role:isAvailableBuilderCDTime()
    return self:getAvailableBuildNum() > 0
end

function Role:getMinBuilderCDTime()
    local min_time = 0
    local build_id = nil

    for k, item in pairs(self.buildings) do
        if item.cd_time > os.time() then
            if min_time == 0 then
                min_time = item.cd_time
                build_id = item.build_id
            elseif item.cd_time < min_time then
                min_time = item.cd_time
                build_id = item.build_id
            end
        end
    end

    return min_time - os.time(), build_id
end

function Role:getAvailableBuildNum()
    local num = 0
    for k, item in pairs(self.buildings) do
        if item.cd_time > os.time() then
            num = num + 1
        end
    end
    return self:getBuildNum() - num
end

function Role:getBuildNum()
    local str_nums = StaticData['vip_func'][1].VipFunc
    local nums = string.split(str_nums, ',')
    return tonumber(nums[1])
end

function Role:getResNum(type,id)
    local res_num = 0
    if type == uq.config.constant.COST_RES_TYPE.MASTER_EXP then
        res_num = self.master_exp
    elseif type < uq.config.constant.COST_RES_TYPE.MATERIAL then  --小于150的，存放在consume内
        res_num = self.consume_res[type]
    elseif self.materials_res[type] then
        res_num = self.materials_res[type][id]
    end
    if res_num == nil then
        res_num = 0
    end
    return res_num
end

function Role:checkRes(type,num,id) --类型判断资源是否满足条件
    local is_meet = true
    local res_num = self:getResNum(type,id)
    local cost_num = math.floor(num)
    is_meet = res_num >= cost_num
    return is_meet
end

function Role:setResChange(type_res, num, id)--客户端更改资源数量
    if type_res == nil or num == nil then
        return
    end
    if type_res < uq.config.constant.COST_RES_TYPE.MATERIAL then
        if not self.consume_res[type_res] then
            self.consume_res[type_res] = 0
        end
        self.consume_res[type_res] = math.max(self.consume_res[type_res] + num, 0)
    else
        if not self.materials_res[type_res] then
            self.materials_res[type_res] = {}
        end
        if not self.materials_res[type_res][id] then
            self.materials_res[type_res][id] = 0
        end
        self.materials_res[type_res][id] = math.max(self.materials_res[type_res][id] + num, 0)
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CONSUME_RES_CHANGE,{}})
end

function Role:setTrainNums(num)
    self.train_nums = num
end

function Role:setCropId(id)
    uq.cache.role.cropsId = id
    uq.cache.crop:updataApplyRed()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CROP_REFRESH})
end

function Role:hasCrop()
    return self.cropsId > 0
end

function Role:getCountryShortName(id)
    id = id or self.country_id
    return StaticData['types'].Country[1].Type[id].shortName
end

function Role:getCountryBg(id)
    local str = {'xsj03_0194.png', 'xsj03_0195.png', 'xsj03_0193.png'}
    id = id or self.country_id
    if str[id] ~= '' then
        return 'img/common/ui/' .. str[id]
    else
        return 'img/common/ui/' .. str[1]
    end
end

function Role:getCountryImg(id)
    id = id or self.country_id
    local data = StaticData['types'].Country[1].Type[id]
    return 'img/common/ui/' .. data.icon
end

function Role:setCurInstance(id)
    self.cur_instance_id = id
end

function Role:getCurInstance()
    return self.cur_instance_id
end

function Role:getGameTime() --获取本次游戏运行时间
    return os.time() - self.game_time
end

function Role:updateVipLevel()
    local vip_exp = self.vip_exp
    for k, v in ipairs(StaticData['vip']) do
        if vip_exp < v.vipExp then
            break
        end
        self.vip_level = v.level
    end
end

function Role:getCityCanLevelUp(city_id)
    local build_xml = StaticData['buildings']['CastleMap'][city_id]
    local level = uq.cache.role:getBuildingLevel(city_id)
    local cost = uq.formula.buildLevelUpCost(build_xml.cost, level, build_xml.coefficient, city_id)

    local can_levelup = true
    local instance_id = uq.cache.instance:getMaxIntanceID()
    local level_limit = StaticData['instance'][instance_id].premiselevel
    if not uq.cache.role:isAvailableBuilderCDTime() then
        can_levelup = false
    elseif city_id == 0 and level >= level_limit then
        can_levelup = false
    elseif build_xml.maxLevel ~= 0 and level >= build_xml.maxLevel then
        can_levelup = false
    elseif not uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.MONEY, cost) then
        can_levelup = false
    elseif city_id ~= 0 and level >= uq.cache.role:level() then
        can_levelup = false
    end
    return can_levelup
end

function Role:getBuildLevelCDTime(build_id, is_all_time)
    local temp = StaticData['buildings']['CastleMap'][build_id]
    local build = self.buildings[build_id]
    local cost = math.floor(uq.formula.buildLevelUpCost(temp.cost, build.level, temp.coefficient, build_id))
    return uq.formula.buildLevelUpCDTime(self.build_times, build.level, temp.buildTime, temp.coefficient, build_id, is_all_time)
end

function Role:isConfirmNoSelect(confirm_id)
    return self.confirm_ids[uq.config.constant.CONFIRM_TYPE.BUILD_SPEED_UP]
end

function Role:finishCD(build_id)
    local build_data = uq.cache.role.buildings[build_id]
    local build_xml = StaticData['buildings']['CastleMap'][build_id]

    local gold =  self:getLevelUpCDGold(build_data.cd_time - os.time(), build_xml.freeTime)
    if gold <= 0 then
        network:sendPacket(Protocol.C_2_S_BUILD_CD_LIST, {build_id = build_id})
        return
    end

    local function confirm()
        if not uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN, gold) then
            uq.fadeInfo(StaticData['local_text']['label.common.not.enough.gold'])
            return
        end

        if build_data.cd_time - os.time() > 0 then
            network:sendPacket(Protocol.C_2_S_BUILD_CD_LIST, {build_id = build_id})
        end
    end

    --本次登录不在提示
    if uq.cache.role:isConfirmNoSelect(uq.config.constant.CONFIRM_TYPE.BUILD_SPEED_UP) then
        confirm()
        return
    end

    local str = ''
    if gold <= 0 then
        str = StaticData['local_text']['label.build.levelup.free.cd']
    else
        str = string.format(StaticData['local_text']['arena.reset.tip'], '<img img/common/ui/03_0003.png>', gold)
    end

    local data = {
        content = str,
        confirm_callback = confirm
    }
    uq.addConfirmBox(data, uq.config.constant.CONFIRM_TYPE.BUILD_SPEED_UP)
end

function Role:getLevelUpCDGold(left_time, free_time)
    local gold = math.ceil((left_time - free_time) * 0.9 / 60)
    if gold < 0 then
        gold = 0
    end
    return gold
end

function Role:getResRefreshXml(res_type)
    local data = StaticData['res_refresh']
    for k, v in ipairs(data) do
        if v.type == res_type then
            return v
        end
    end
    return nil
end

function Role:directFinishBuildUp(build_id)
    local build_data = uq.cache.role.buildings[build_id]
    local build_xml = StaticData['buildings']['CastleMap'][build_id]
    local cd_time = self:getBuildLevelCDTime(build_id)
    local cost = self:getLevelUpCDGold(cd_time, build_xml.freeTime)
    if cost == 0 then
        network:sendPacket(Protocol.C_2_S_BUILD_CD_LIST, {build_id = build_id})
        return
    end
    local function confirm()
        if not self:checkRes(uq.config.constant.COST_RES_TYPE.GOLDEN, cost) then
            uq.fadeInfo(StaticData['local_text']['label.no.enough.res'])
            return
        end
        network:sendPacket(Protocol.C_2_S_BUILD_CD_LIST, {build_id = build_id})
    end
    local data = {
        content = string.format(StaticData['local_text']['build.direct.finish.up'], cost),
        confirm_callback = confirm
    }
    uq.addConfirmBox(data, uq.config.constant.CONFIRM_TYPE.BUILD_SPEED_UP)
end

function Role:isBuildLock(xml_data)
    return uq.cache.role:level() < xml_data.level or not uq.cache.instance:isNpcPassed(xml_data.objectId)
end

function Role:getBuildOfficerData(build_type)
    return self.build_officer_list[build_type].officer_list
end

function Role:getGeneralBuildOffcerType(general_id)
    return self.build_office_map[general_id]
end

function Role:getBuildOfficerPropertyData(build_type, property_type)
    local property_data = self:getBuildOfficerData(build_type)
    local nums = 0
    for k, item in ipairs(property_data) do
        if item.general_id > 0 then --锁定状态 不生病
            local temp_id = uq.cache.generals:getGeneralTempId(item.general_id)
            local tire_data = uq.cache.generals:getGeneralTireModeData(item.general_id)

            if tire_data.ident < 5 then
                local values = uq.cache.generals:getGeneralBuildOfficerPropertyAdd(item.general_id)
                nums = nums + values[property_type][1]
            end
        end
    end
    return nums
end

function Role:getBuildOfficerMainBuildEffect(build_id, property_type)
    local property_data = self.main_build_officer_effect[build_id]
    if not property_data then
        return 0
    end

    local nums = 0
    for k, general_id in ipairs(property_data) do
        local temp_id = uq.cache.generals:getGeneralTempId(general_id)
        local values = uq.cache.generals:getGeneralBuildOfficerPropertyAdd(general_id)
        nums = nums + values[property_type][1]
    end
    return nums
end

--获取建筑官效果
function Role:getBuildOfficerEffect(effect_num)
    if effect_num > #StaticData['officer'].Officer then
        effect_num = #StaticData['officer'].Officer
    end
    local strs = string.split(StaticData['officer'].Officer[effect_num].addEffect, '|')
    local data = {}
    for k, item in ipairs(strs) do
        local nums = string.split(item, ',')
        table.insert(data, tonumber(nums[2]))
    end
    return data
end

--获取武将总cd lock状态下
function Role:getBuildOfficerLevelUpMaxCD(build_type, general_id)
    if build_type == uq.config.constant.BUILD_TYPE.MAIN_CITY then
        local max_cd = 0
        for build_id_temp, id_list in pairs(self.main_build_officer_effect) do
            for k, general_id_temp in ipairs(id_list) do
                if general_id_temp == general_id then --升级建筑 占用该武将
                    --跟新过的时间
                    local time = uq.cache.role.buildings[build_id_temp].cd_time - os.time()
                    if max_cd < time then
                        max_cd = time
                    end
                end
            end
        end
        return max_cd
    elseif build_type == uq.config.constant.BUILD_TYPE.STRATEGY then
        return uq.cache.technology:getSurplusTime()
    end

    return 0
end

function Role:getBuildOfficerPropertyAdd(build_type, property_type)
    if property_type == uq.config.constant.BUILD_OFFICER_EFFECT.TYPE_LEVEL_UP_TIME or property_type == uq.config.constant.BUILD_OFFICER_EFFECT.TYPE_LEVEL_UP_COST then --针对所有
        --主城的升级时间和消耗针对所有的建筑
        local xml_data = StaticData['officer_build_map'][uq.config.constant.BUILD_TYPE.MAIN_CITY]
        local nums = uq.cache.role:getBuildOfficerPropertyData(uq.config.constant.BUILD_TYPE.MAIN_CITY, xml_data.officerAttrType)
        local office_data = uq.cache.role:getBuildOfficerEffect(nums)
        return office_data[property_type]
    else
        local xml_data = StaticData['officer_build_map'][build_type]
        local nums = uq.cache.role:getBuildOfficerPropertyData(build_type, xml_data.officerAttrType)
        local office_data = uq.cache.role:getBuildOfficerEffect(nums)
        return office_data[property_type]
    end
    return 0
end

--获取升级生病建设官
function Role:getSickBuildOfficer(build_type)
    local officer_list = self:getBuildOfficerData(build_type)
    local valeus = {}
    if not officer_list then
        return valeus
    end
    for k, officer_data in ipairs(officer_list) do
        if officer_data.general_id > 0 then
            local tire_data = uq.cache.generals:getGeneralTireModeData(officer_data.general_id)
            if tire_data.ident == 5 then --生病
                table.insert(valeus, officer_data.general_id)
            end
        end
    end
    return valeus
end

--判断当前建筑是否可以委任建设管
function Role:checkIsCanOfficer(build_type)
    local officer_list = self:getBuildOfficerData(build_type)
    local unlock_num = self:getBuildOfficerUnlockNum(build_type)
    for k, item in ipairs(officer_list) do
        if item.general_id == 0 and k <= unlock_num then
            return true
        end
    end
    return false
end

function Role:getMaxLevelBuild(build_type)
    local build_data = nil
    for build_id, item in pairs(uq.cache.role.buildings) do
        local build_xml = StaticData['buildings']['CastleMap'][build_id]
        if build_xml.type == build_type then
            if not build_data or build_data.level < item.level then
                build_data = item
            end
        end
    end
    return build_data
end

function Role:getBuildOfficerUnlockNum(build_type)
    local build_data = self:getMaxLevelBuild(build_type)
    local xml_data = StaticData['officer_build_map'][build_type]
    if not xml_data then
        return 0, 0
    end

    local unlock_num = 0
    local nums = string.split(xml_data.officerNums, ';')
    for i = #nums, 1, -1 do
        local strs = string.split(nums[i], ',')
        if build_data.level >= tonumber(strs[1]) then
            unlock_num = tonumber(strs[2]), total_num
            break
        end
    end
    local strs = string.split(nums[#nums], ',')
    local total_num = tonumber(strs[2])
    return unlock_num, total_num
end

function Role:isHasGeneralCanOffice(build_type)
    local general_list = uq.cache.generals:getBuildOfficeSelect(build_type) --获取可用列表
    for k, general_data in ipairs(general_list) do
        local is_procesing = uq.cache.generals:isGeneralProcesing(general_data.id)
        if not is_procesing then
            local tire_cd = uq.cache.generals:getTireCdTime(general_data.id, StaticData['officer_level'].Info[1].reWorkTired)
            if tire_cd == 0 then
                return true
            end
        end
    end
    return false
end

function Role:isHasGeneralCanOfficeAll()
    if not uq.jumpToModule(uq.config.constant.MODULE_ID.BUILD_OFFICER, nil, true) then
        return false
    end

    for k, item in pairs(StaticData['officer'].Building) do
        if self:checkIsCanOfficer(item.castleMapType) and self:isHasGeneralCanOffice(item.castleMapType) then
            return true
        end
    end
    return false
end

function Role:isMyHeadEqual(head_id, head_type)
    return self:getImgId() == head_id and self:getImgType() == head_type
end

function Role:getUnipeKey(str)
    return str .. self.id
end

function Role:getBuildIdByType(build_type)
    for build_id, item in pairs(self.buildings) do
        local build_xml = StaticData['buildings']['CastleMap'][build_id]
        if build_xml.type == build_type then
            return build_id
        end
    end
end

function Role:getBuildType(build_id)
    local build_xml = StaticData['buildings']['CastleMap'][build_id]
    return build_xml.type
end

function Role:getBuildResource(build_type)
    local resource = 0
    for build_id, item in pairs(self.buildings) do
        local build_xml = StaticData['buildings']['CastleMap'][build_id]
        if build_xml.type == build_type then
            resource = resource + item.resource
        end
    end
    return resource
end

function Role:getFilterBuildName(build_name)
    local name = string.gsub(build_name, "[0-9]", "")
    return name
end

function Role:getTotalArmySpeed()
    local speed = 0
    local xml_data = StaticData['draft'].Conscription
    for k, item in pairs(self.buildings) do
        local build_data = StaticData['buildings']['CastleMap'][item.build_id]
        if build_data.type == uq.config.constant.BUILD_TYPE.SOLDIER and not self:isBuildLock(build_data) then
            speed = speed + xml_data[item.level].conscript
        end
    end
    return speed
end

--整分钟跟新
function Role:getDraftLeftTime(off_soldier, speed)
    local left_time = math.ceil(off_soldier / speed / 60) * 60
    local second = os.date("*t", uq.curServerSecond()).sec
    return left_time - second + 1
end

return Role