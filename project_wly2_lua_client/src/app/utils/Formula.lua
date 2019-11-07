local Formula = {}

Formula.buildLevelUpCost = function(build_cost, lvl, coef, build_id)
    local build_xml = StaticData['buildings'].BuildLevel[lvl]
    if not build_xml then
        return 0
    end
    local build_type = uq.cache.role:getBuildType(build_id)
    local rate = uq.cache.role:getBuildOfficerPropertyAdd(build_type, uq.config.constant.BUILD_OFFICER_EFFECT.TYPE_LEVEL_UP_COST)
    local rate1 = uq.cache.technology:getBuildCostFreeRatio()
    return math.ceil(math.ceil(build_xml.cost * coef * (1 - rate1)) * (1 - rate))
end

Formula.buildLevelUpCDTime = function(build_times, lvl, base_time, coef, build_id, is_all_time)
    local build_xml = StaticData['buildings'].BuildLevel[lvl]
    if not build_xml then
        return 0
    end
    local build_type = uq.cache.role:getBuildType(build_id)
    local rate = uq.cache.role:getBuildOfficerPropertyAdd(build_type, uq.config.constant.BUILD_OFFICER_EFFECT.TYPE_LEVEL_UP_TIME)
    local rate1 = uq.cache.technology:getBuildTimeFreeRatio()
    if is_all_time then
        return math.ceil(build_xml.time * coef)
    end
    return math.ceil(math.ceil(build_xml.time * coef * (1 - rate1)) * (1 -  rate))
end

Formula.buildLevelUpExp = function(lvl, coef, build_id)
    local build_xml = StaticData['buildings'].BuildLevel[lvl]
    if not build_xml then
        return 0
    end
    local build_type = uq.cache.role:getBuildType(build_id)
    local rate = uq.cache.role:getBuildOfficerPropertyAdd(build_type, uq.config.constant.BUILD_OFFICER_EFFECT.TYPE_LEVEL_UP_TIME)
    local exp = build_xml.expReward * coef * (1 - rate)
    return math.ceil(exp)
end


uq.formula = Formula