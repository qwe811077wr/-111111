cc.exports.StaticData = cc.exports.StaticData or {}

local function getDatasetDir()
    return 'app/static_data/' .. uq.config.STATIC_DATA_DIR .. '/'
end

function StaticData.load(name)
    return require(getDatasetDir() .. name)
end

function StaticData.getAttackAndDefInfo(array,attr) --根据兵种的值，获取兵种s,a,b信息
    for _,v in pairs(array) do
        if v.min <= attr and v.max > attr then
            return v
        end
    end
    return nil
end

function StaticData.getCostInfo(type, id) --根据类型，id取type  cost数据
    local info = StaticData['types'].Cost[1].Type[type]
    if type == uq.config.constant.COST_RES_TYPE.MATERIAL then
        info = StaticData['material'][id]
    elseif type == uq.config.constant.COST_RES_TYPE.CLEAR_MATERIAL then
        info = StaticData['att_stone'][id]
    elseif type == uq.config.constant.COST_RES_TYPE.ORDER_MATERIAL then
        info = StaticData['advance_data'][id]
    elseif type == uq.config.constant.COST_RES_TYPE.EQUIP then
        info = StaticData['items'][id]
    elseif type == uq.config.constant.COST_RES_TYPE.GENERALS then
        info = StaticData['general'][id]
    elseif type == uq.config.constant.COST_RES_TYPE.SPIRIT then
        info = StaticData['general'][tonumber(id .. '1')]
    end
    return info
end

function StaticData.splitString(str, character)
    local value_array = {}
    if type(str) == "string" then
        value_array = string.split(cost_str, character)
    end
    return value_array
end

StaticData['types'] = StaticData.load('Types')
StaticData['buildings'] = StaticData.load('CastleMaps')
StaticData['buildings']['names'] = StaticData['types']['Building'][1]['Type']
StaticData['draft'] = StaticData.load('Conscriptions')
StaticData['defeat'] = StaticData.load('Defeat').promote

StaticData['local_text'] = {}
local local_txt = StaticData.load('LocalText')
for _, v in pairs(local_txt.text) do
    StaticData['local_text'][v.key] = v.value
end

StaticData['menus'] = StaticData.load('Menus').CastleObject

StaticData['game_config'] = {}
local local_config = StaticData.load('game_config')
for k, v in pairs(local_config.game_config[1]) do
    StaticData['game_config'][k] = v
end

StaticData['item_cast'] = {}
StaticData['item_cast_toItem'] = {}
local item_cast = StaticData.load('ItemCasts')
for k, v in pairs(item_cast.Cast) do
    StaticData['item_cast'][v.oriItemId] = v
    StaticData['item_cast_toItem'][v.toItemId] = v
end

local vips = StaticData.load('VipCfgs')
StaticData['vip'] = {}
for _, v in pairs(vips.Vip) do
    StaticData['vip'][v.level] = v
end

StaticData['reinforce_soldiers'] = {}
local local_soldiers = StaticData.load('ReinforcedSoldiers')
for k, v in pairs(local_soldiers.Reinforced) do
    StaticData['reinforce_soldiers'][v.oriId] = v
end

StaticData['formation'] = StaticData.load('Formations').Formation
StaticData['tech'] = StaticData.load('Techs').Tech
StaticData['tech_info'] = StaticData.load('Techs').Info
StaticData['general'] = StaticData.load('Generals').General

StaticData['instance'] = {}
StaticData.initInstanceData = function(contry_id)
    for k, item in pairs(StaticData.load('CampaignCfgs').Campaign) do
        if tonumber(item.countryType) == 0 or tonumber(item.countryType) == contry_id then
            StaticData['instance'][k] = item
        end
    end

    for _, v in pairs(StaticData['instance']) do
        local arrays = string.split(v.parentId, ';')
        if #arrays == 1 and tonumber(arrays[1]) > 0 then
            local p = StaticData['instance'][tonumber(arrays[1])]
            p.next = v
            v.parent = p
        elseif #arrays == 3 then
            local p = StaticData['instance'][tonumber(arrays[contry_id])]
            p.next = v
            v.parent = p
        end
    end
end

StaticData['soldier'] = StaticData.load('Soldiers').Soldier
StaticData['skill'] = StaticData.load('Skills').Skill
StaticData['rebirth'] = StaticData.load('Rebirths').Rebirth
StaticData['items'] = StaticData.load('Items').Item
StaticData['module'] = StaticData.load('Modules').Module
StaticData['LevyEventCfg'] = StaticData.load('LevyEventCfgs').Event
StaticData['constant'] = StaticData.load('Constants').Constant
StaticData['lvlfarms'] = StaticData.load('Levelfarms')
StaticData['growthFund'] = StaticData.load('GrowthFund')
StaticData['item_score'] = StaticData.load('ItemScore')

StaticData['material'] = StaticData.load('Materials').Material
StaticData['PrestigeCfg'] = StaticData.load('PrestigeCfgs').Official
StaticData['att_stone'] = StaticData.load('AttStones').AttStones
StaticData['item_level'] = StaticData.load('ItemLevels').ItemLevel
StaticData['item_level'].getCost = function(lvl)
    local cost_array = {}
    for i = 0, lvl - 1, 1 do
        if StaticData['item_level'][i] then
            table.insert(cost_array, StaticData['item_level'][i].cost)
        end
    end
    return cost_array
end
StaticData['intensify'] = StaticData.load('Intensifys').Type
StaticData['rule'] = StaticData.load('Rules').Rule
StaticData['vip_shop_gift'] = StaticData.load('VipShopGifts').VipGift
StaticData['vip_gift'] = StaticData.load('VipGifts').VipGift
StaticData['pay'] = StaticData.load('Pay').Pay
StaticData['livenesses'] = StaticData.load('Livenesses')
StaticData['world_maps'] = StaticData.load('WorldMaps').Object
StaticData['city_develops'] = StaticData.load('CityDevelops').DevItem
StaticData['bosom'] = {}
StaticData['bosom']['women'] = StaticData.load('Womens').Women
StaticData['bosom']['talk'] = StaticData.load('WomenTalks').Talk
StaticData['bosom']['quality_type'] = StaticData['types']['TalkQualityType'][1]['Type']
StaticData['bosom']['attr_type'] = StaticData['types']['Effect'][1]['Type']
StaticData['bosom']['level'] = {}
StaticData['appoint_item'] = StaticData.load('AppointNews').Appoint
StaticData['appoint_reward'] = StaticData.load('AppointNews').Rewards
StaticData['legion_heads'] = StaticData.load('LegionHeads').Head
local women_lvl = StaticData.load('WomanLevels').Effect
for _, v in pairs(women_lvl) do
    if not StaticData['bosom']['level'][v.levelType] then
        StaticData['bosom']['level'][v.levelType] = {}
    end
    StaticData['bosom']['level'][v.levelType][v.level] = v.exp
end

local wife_effect = StaticData.load('WifeEffects').Effect
StaticData['wife'] = {}
StaticData['wife']['effect'] = {}
for _, v in pairs(wife_effect) do
    if not StaticData['wife']['effect'][v.levelType] then
        StaticData['wife']['effect'][v.levelType] = {}
    end
    StaticData['wife']['effect'][v.levelType][v.level] = v.effect
end

StaticData['bosom']['getDearType'] = function(lvl)
    local dear_types = StaticData['types']['DearType'][1]['Type']
    local ret = 1
    local max_lvl = 0
    for k, v in pairs(dear_types) do
        if lvl >= v.rank and v.rank >= max_lvl then
            max_lvl = v.rank
            ret = k
        end
    end
    return ret
end

StaticData['constant'].getCost = function (id, num)
    local constant = StaticData['constant'][id]
    if not constant then
        return 0
    end
    if not constant.Data then
        return 0
    end
    if constant.Data[num] then
        local value_array = StaticData.splitString(constant.Data[num].cost, ";")
        if #value_array > 2 then
            return tonumber(value_array[2])
        end
        return 0
    end
    if not constant.sort then
        local tab = {}
        for k, v in pairs(constant.Data) do
            table.insert(tab, v)
        end
        table.sort(tab, function (a, b)
            return a.ident > b.ident
        end)
        constant.sort = tab
    end
    local tab = constant.sort
    if tab[1].ident < num then
        local value_array = StaticData.splitString(tab[1].cost, ";")
        if #value_array > 2 then
            return tonumber(value_array[2])
        end
        return 0
    end
    for _, v in pairs(tab) do
        if v.ident <= num then
            local value_array = StaticData.splitString(v.cost, ";")
            if #value_array > 2 then
                return tonumber(value_array[2])
            end
            return 0
        end
    end
    return 0
end

StaticData['majesty_heads']     = StaticData.load('MajestyHeads').Head
StaticData['default_settings']  = StaticData.load('DefaultSettings')
StaticData['advance_levels']    = StaticData.load('AdvanceLevels').AdvanceLevel
StaticData['mansion_map']       = StaticData.load('MansionMaps').Object
StaticData['ancients']          = StaticData.load('Ancients').Ancient
StaticData['ancient_times']     = StaticData.load('Ancients').BuyTimes
StaticData['ancient_info']      = StaticData.load('Ancients').Info
StaticData['vip_func']          = StaticData.load('VipFuncs').VipFunc
StaticData['daily_goal']        = StaticData.load('Ancients').DailyGoal
StaticData['ancients_detour']   = StaticData.load('Ancients').Detour
StaticData['ancient_trade']     = StaticData.load('AncientTraders')
StaticData['ancient_store']     = StaticData.load('AncientStores')
StaticData['arena']             = StaticData.load('ArenaMatchRules').Params
StaticData['arena_reward']      = StaticData.load('ArenaRewards').RankRewards
StaticData['daily']             = StaticData.load('Dailys').Daily
StaticData['daily_instance']    = StaticData.load('DailyInstances').Instance
StaticData['tower_cfg']         = StaticData.load('TowerCfgs').Layer
StaticData['tower_store']       = StaticData.load('TowerStore')
StaticData['general_level']     = StaticData.load('GeneralLevels')
StaticData['general_train_exp'] = StaticData.load('GeneralLevels').TrainExp
StaticData['sound']             = StaticData.load('Sounds').Sound
StaticData['soldier_transfer']  = StaticData.load('SoldierTransfers').SoldierTransfer
StaticData['advance_data']      = StaticData.load('AdvanceDatas').AdvanceData
StaticData['Illustration']      = StaticData.load('Illustrations')
StaticData['arena_store']       = StaticData.load('ArenaStores')
StaticData['eight_diagrams']    = StaticData.load('EightDiagrams')
StaticData['checkin']           = StaticData.load('Checkin').Checkin
StaticData['checkin_complement']= StaticData.load('Checkin').Complement
StaticData['zong_event']        = StaticData.load('ZongEvents').ZongTask
StaticData['item_back'] = {}
local item_back = StaticData.load('ItemBack').Sheet
for _, v in ipairs(item_back) do
    if not StaticData['item_back'][v.effectType] then
        StaticData['item_back'][v.effectType] = {}
    end
    table.insert(StaticData['item_back'][v.effectType], v)
end
StaticData['item_back'].getCost = function(value, type)
    local pre_info = nil
    local cur_info = nil
    if not StaticData['item_back'][type] then
        return pre_info, cur_info
    end
    if value <= 0 then
        return pre_info, cur_info
    end
    for _, v in ipairs(StaticData['item_back'][type]) do
        if v.effectValue >= value then
            cur_info = v
            break
        end
        pre_info = v
    end
    return pre_info, cur_info
end
StaticData['chat'] = StaticData.load('Chat')
StaticData['legion_envelopes'] = StaticData.load('LegionEnvelopes').LegionEnvelopes

StaticData['general_grades'] = {}
local general_grades = StaticData.load('GeneralGrades').GeneralGrade
for _, v in ipairs(general_grades) do
    local grade_array = string.split(v.grade, ";")
    local info_array = {}
    for k, grade in ipairs(grade_array) do
        local item_array = string.split(grade, ":")
        local data = {
            tonumber(item_array[1]),
            item_array[2]
        }
        table.insert(info_array, data)
    end
    StaticData['general_grades'][v.effectType] = info_array
end
StaticData['general_grades'].getGrade = function(value, type)
    local info_array = StaticData['general_grades'][type]
    if info_array == nil then
        return nil
    end
    local info = nil
    for k, v in ipairs(info_array) do
        if value < v[1] then
            break
        end
        info = v[2]
    end
    return info
end

StaticData['soldier_grades'] = {}
local soldier_grades = StaticData.load('SoldierGrades').SoldierGrade
for _, v in ipairs(soldier_grades) do
    local grade_array = string.split(v.grade, ";")
    local info_array = {}
    for k, grade in ipairs(grade_array) do
        local item_array = string.split(grade, ":")
        local data = {
            tonumber(item_array[1]),
            item_array[2]
        }
        table.insert(info_array, data)
    end
    StaticData['soldier_grades'][v.effectType] = info_array
end
StaticData['soldier_grades'].getGrade = function(value, type)
    local info_array = StaticData['soldier_grades'][type]
    if info_array == nil then
        return nil
    end
    local info = nil
    for k, v in ipairs(info_array) do
        if value == v[1] then
            info = v[2]
            break
        end
    end
    return info
end
StaticData['iron']            = StaticData.load('LevelIron')
StaticData['government']      = StaticData.load('Government')
StaticData['loading_pictures']= StaticData.load('Loadingpictures').Loadingpicture
StaticData['jiu_guan']        = StaticData.load('Jiuguan')
StaticData['effect']          = StaticData.load('Txs').Txs
StaticData['sound']           = StaticData.load('Sounds').Sound
StaticData['shake']           = StaticData.load('Shakes').Shake
StaticData["legion_campaign"] = StaticData.load('LegionCampaign').Instance
StaticData['top_bar']         = StaticData.load('Topbars').Topbar
StaticData['level_gift']      = StaticData.load('LevelGift').levelGift
StaticData['welfare']         = StaticData.load('Welfare').Welfare
StaticData['achievements']    = StaticData.load('Achievements').Achievement
StaticData['end_achievements']= StaticData.load('Achievements').End_Achievement
StaticData['world_city']      = StaticData.load('WorldCities').WorldCity
StaticData['world_type']      = StaticData.load('WorldCities').WorldType
StaticData['world_grain']      = StaticData.load('WorldCities').Worldgrain
StaticData['world_develop']   = StaticData.load('WarDevelops').WarDevelop
StaticData['world_flag']      = StaticData.load('WorldCities').Worldflag
StaticData['world_nation']    = StaticData.load('WarNations').WarNation
StaticData['war_season']      = StaticData.load('WarSeasons')
StaticData['world_road']      = StaticData.load('WorldCityRoads').WorldCityRoad
StaticData['world_war_city']  = StaticData.load('WorldWars').Worldwar
StaticData['seven_task']      = StaticData.load('SevenTask')
StaticData['legion_tech']     = StaticData.load('LegionTechs').LegionTech
StaticData['buff']            = StaticData.load('Buffs').Buff
StaticData['map_config']      = StaticData.load('WorldCityMaps').WorldCityMap
StaticData['loading_tips']    = StaticData.load('LoadingTips').LoadingTip
StaticData['pass']            = StaticData.load('Pass')
StaticData['choose_country']  = StaticData.load('ChooseCountry').ChooseCountry
StaticData['function_tips']   = StaticData.load('Functiontips').Functiontip
StaticData['keyword']         = StaticData.load('Keyword')
StaticData['guide']           = StaticData.load('Guide')
StaticData['drill_ground']    = StaticData.load('DrillGround')
StaticData['drill_skill']     = StaticData.load('DrillSkill').DrillSkill
StaticData['random_event']    = StaticData.load('RandomEvents')
StaticData['formation_loc']   = StaticData.load('Formationloc')
StaticData['war_task']        = StaticData.load('WarTasks').Task
StaticData['crop_help']       = StaticData.load('LegionMutualitys').LegionMutuality[1]
StaticData['officer']         = StaticData.load('Officer')
StaticData['officer_level']   = StaticData.load('OfficerLevel')
StaticData['officer_build_map'] = {}
for k, item in pairs(StaticData['officer'].Building) do
    StaticData['officer_build_map'][item.castleMapType] = item
end
StaticData['level_collection'] = StaticData.load('LevelCollections')
StaticData['gm_instruction']   = StaticData.load('GMInstructions').GMInstructions
StaticData['drop']             = StaticData.load('Drops').Drop
StaticData['war_sign']         = StaticData.load('WarSigns')
StaticData['player_level']     = StaticData.load('PlayerLevels')
StaticData['general_effect']   = StaticData.load('GeneralEffectList').GeneralEffectList
StaticData['item_suit']        = StaticData.load('ItemSuit').ItemSuit
StaticData['npc_level_soldier']= StaticData.load('LevelPowers').LevelPower
StaticData['item_effect']      = StaticData.load('ItemEffectList').ItemEffectList
StaticData['item_appoint']     = StaticData.load('ItemAppoint')
StaticData['res_refresh']      = StaticData.load('Junling').Junling
