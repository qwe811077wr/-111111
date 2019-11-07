local BuildLevelUpModule = class('BuildLevelUpModule', require("app.modules.common.BaseViewWithHead"))

BuildLevelUpModule.RESOURCE_FILENAME = "main_city/BuildLevelUp.csb"
BuildLevelUpModule.RESOURCE_BINDING = {
    ["Node_2"]                 = {["varname"] = "_nodeOpen"},
    ["Node_3"]                 = {["varname"] = "_nodeClose"},
    ["leve_tip"]               = {["varname"] = "_txtLevelTip"},
    ["lvl_txt"]                = {["varname"] = "_txtLevel"},
    ["cost_txt"]               = {["varname"] = "_txtCost"},
    ["need_time_txt"]          = {["varname"] = "_txtNeedTime"},
    ["need_time_txt_1"]        = {["varname"] = "_txtNeedTimeAll"},
    ["levelup_effect_txt"]     = {["varname"] = "_txtLevelUpEffect"},
    ["levelup_effect_txt_num"] = {["varname"] = "_txtLevelUpEffectNum"},
    ["levelup_effect_txt_0"]   = {["varname"] = "_txtLevelUpEffectResult"},
    ["level_up_btn"]           = {["varname"] = "_btnLevelUp",["events"] = {{["event"] = "touch",["method"] = "onLevelUp",["sound_id"] = 24}}},
    ["Node_1"]                 = {["varname"] = "_nodeLevelLimit"},
    ["instance_name"]          = {["varname"] = "_txtInstanceName"},
    ["button_instance"]        = {["varname"] = "_btnInstance",["events"] = {{["event"] = "touch",["method"] = "onInstance"}}},
    ["text_title"]             = {["varname"] = "_txtBuildName"},
    ["Node_4"]                 = {["varname"] = "_nodeLevelUp"},
    ["Node_5"]                 = {["varname"] = "_nodeCD"},
    ["up_time_txt"]            = {["varname"] = "_txtTimeCD"},
    ["up_lbr"]                 = {["varname"] = "_loadBarCD"},
    ["btn_cancle"]             = {["varname"] = "_btnCancle",["events"] = {{["event"] = "touch",["method"] = "onCancle"}}},
    ["add_speed_btn"]          = {["varname"] = "_btnCancle1",["events"] = {{["event"] = "touch",["method"] = "onCancleBuild"}}},
    ["btn_finish"]             = {["varname"] = "_btnFinish",["events"] = {{["event"] = "touch",["method"] = "onFinish",["sound_id"] = 0}}},
    ["txt_free"]               = {["varname"] = "_txtFreeTime"},
    ["up_lv_txt"]              = {["varname"] = "_txtLevelUpBtn"},
    ["next_lv_txt"]            = {["varname"] = "_txtLvNext"},
    ["up_dec_txt"]             = {["varname"] = "_txtCropHelp"},
    ["up_node"]                = {["varname"] = "_nodeUp"},
    ["before_up_node"]         = {["varname"] = "_nodeUpBefore"},
    ["card_ok_img"]            = {["varname"] = "_imgOkCard"},
    ["cost_finish_txt"]        = {["varname"] = "_txtCDGold"},
    ["up_ok_img"]              = {["varname"] = "_imgOkUp"},
    ["master_exp"]             = {["varname"] = "_masterExpLabel"},
    ["up_dec_btn"]             = {["varname"] = "_btnCropHelp",["events"] = {{["event"] = "touch",["method"] = "onCropHelp"}}},
    ["att_node"]               = {["varname"] = "_nodeAtt"},
    ["title_node"]             = {["varname"] = "_nodeTitle"},
    ["right_node"]             = {["varname"] = "_nodeRightMiddle"},
    ["stock_txt"]              = {["varname"] = "_txtStock"},
    ["stock_max_txt"]          = {["varname"] = "_txtStockNum"},
    ["stock_node"]             = {["varname"] = "_nodeStock"},
    ["level_node"]             = {["varname"] = "_nodeLevel"},
    ["stock_new_txt"]          = {["varname"] = "_txtStockNew"},
    ["recovery_txt"]           = {["varname"] = "_txtRecovery"},
    ["recovery_node"]          = {["varname"] = "_nodeRecovery"},
    ["recovery_new_txt"]       = {["varname"] = "_txtRecoveryNew"},
    ["img_bg_adapt"]           = {["varname"] = "_imgBg",["events"] = {{["event"] = "touch",["method"] = "onBgClose"}}},
}

function BuildLevelUpModule:ctor(name, params)
    BuildLevelUpModule.super.ctor(self, name, params)
    self._buildId = params.build_id

    self._eventTagRefresh = services.EVENT_NAMES.ON_MAIN_CITY_REFRESH_BUILD .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_MAIN_CITY_REFRESH_BUILD, handler(self, self.updateCityInfo), self._eventTagRefresh)

    self._eventCropRefresh = services.EVENT_NAMES.ON_CROP_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_CROP_REFRESH, handler(self, self.refreshCropHelp), self._eventCropRefresh)
    services:dispatchEvent({name = services.EVENT_NAMES.ON_MAIN_CITY_BUILD_TO_POS, build_id = self._buildId})
end

function BuildLevelUpModule:init()
    self:addShowCoinGroup({uq.config.constant.COST_RES_TYPE.MONEY, uq.config.constant.COST_RES_TYPE.GOLDEN})
    self:centerView()
    self:parseView()
    self._posy = self._nodeLevel:getPositionY()
    self:hideMainUI()
    self:setTitle(uq.config.constant.MODULE_ID.LEVEL_UP)
    self:updateView(self._buildId)
    self:adaptBgSize()
    self:adaptNode()
    self:setBaseBgClip()
    uq.intoAction(self._nodeAtt, cc.p(0, - uq.config.constant.MOVE_DISTANCE))
    uq.intoAction(self._nodeTitle)
    uq.intoAction(self._nodeRightMiddle, cc.p(uq.config.constant.MOVE_DISTANCE, 0))
end

function BuildLevelUpModule:onLevelUp(event)
    if event.name ~= "ended" then
        return
    end
    self:_doUpdateBuild()
end

function BuildLevelUpModule:onExit()
    if self._timerField then
        self._timerField:dispose()
        self._timerField = nil
    end
    services:removeEventListenersByTag(self._eventTagRefresh)
    services:removeEventListenersByTag(self._eventCropRefresh)
    BuildLevelUpModule.super:onExit()
end

function BuildLevelUpModule:updateView(bid)
    self._buildId = bid
    local temp = StaticData['buildings']['CastleMap'][bid] or {}
    self._txtBuildName:setString(temp.name)

    local build = uq.cache.role.buildings[bid]
    self._txtLevel:setString(tostring(build.level))

    local cost = math.floor(uq.formula.buildLevelUpCost(temp.cost, build.level, temp.coefficient, self._buildId))
    local res_num = uq.cache.role:getResNum(uq.config.constant.COST_RES_TYPE.MONEY, 0)
    self._txtCost:setString(res_num .. "/" .. cost)
    local color = res_num >= cost and "#69ec2d" or "#f22926"
    self._txtCost:setTextColor(uq.parseColor(color))

    self._cdTotalTime = uq.cache.role:getBuildLevelCDTime(bid)
    self._txtNeedTime:setString(uq.getTime(self._cdTotalTime, uq.config.constant.TIME_TYPE.HHMMSS))
    local all_time = uq.cache.role:getBuildLevelCDTime(bid, true)
    self._txtNeedTimeAll:setString(uq.getTime(all_time, uq.config.constant.TIME_TYPE.HHMMSS))
    self._txtFreeTime:setString(string.format(StaticData['local_text']['label.build.free'], temp.freeTime))
    if self._cdTotalTime <= temp.freeTime then
        self._txtLevelUpBtn:setString(StaticData['local_text']['label.build.free.levelup'])
    else
        self._txtLevelUpBtn:setString(StaticData['local_text']['label.level.up2'])
    end
    local direct_cost = uq.cache.role:getLevelUpCDGold(self._cdTotalTime, temp.freeTime)
    local cost_str = direct_cost == 0 and StaticData['local_text']['ancient.city.shop.refresh.free'] or tostring(direct_cost)
    self._txtCDGold:setString(cost_str)
    self._txtLevelUpEffect:setString(temp.result)
    local effect_num, stock_num = uq.cache.decree:getAttValue(build.type, build.level)
    local effect_new_num, stock_new_num = uq.cache.decree:getAttValue(build.type, build.level + 1)
    self._txtLevelUpEffectNum:setString(tostring(effect_num))
    self._txtLevelUpEffectResult:setString(tostring(effect_new_num))
    self._txtLvNext:setString(tostring(build.level + 1))
    local is_show = stock_num ~= nil
    self._nodeStock:setVisible(is_show)
    if is_show then
        self._txtStockNum:setString(tostring(stock_num))
        self._txtStockNew:setString(tostring(stock_new_num))
    else
        self._nodeLevel:setPositionY(self._posy - 15)
    end
    local up_exp_info = StaticData['buildings']['BuildLevel'][build.level]
    if up_exp_info == nil then
        self._masterExpLabel:setString("+0")
    else
        local exp = uq.formula.buildLevelUpExp(build.level, temp.coefficient, self._buildId)
        self._masterExpLabel:setString("+" .. exp)
    end
    local is_soldier = build.type == uq.config.constant.BUILD_TYPE.SOLDIER
    self._nodeRecovery:setVisible(is_soldier)
    if is_soldier then
        self._txtRecovery:setString(tostring(self:getRecoveryNum(build.level)))
        self._txtRecoveryNew:setString(tostring(self:getRecoveryNum(build.level + 1)))
    end
    self:refreshCdTime()
    self:refreshCropHelp()
end

function BuildLevelUpModule:getRecoveryNum(level)
    local tab = StaticData['draft'].Conscription
    if tab[level] and tab[level].conscript then
        return math.ceil(tab[level].conscript * 3600)
    end
    return 0
end

function BuildLevelUpModule:refreshCdTime()
    local build_xml = StaticData['buildings']['CastleMap'][self._buildId]
    local build_data = uq.cache.role.buildings[self._buildId]
    local left_time = build_data.cd_time - os.time()
    local total_time = uq.cache.role:getBuildLevelCDTime(build_data.build_id)
    local is_show = left_time > 0
    self._nodeCD:setVisible(is_show)
    self._nodeUp:setVisible(is_show)
    self._nodeUpBefore:setVisible(not is_show)
    self._nodeLevelUp:setVisible(not is_show)
    if not is_show then
        self:refreshUpLayer()
        if self._timerField then
            self._timerField:dispose()
            self._timerField = nil
        end
        return
    end

    local function timer_end()
        self:refreshCdTime()
    end

    local function timer_call(left_time)
        self._loadBarCD:setPercent(100 - left_time / total_time * 100)
        self._gold = uq.cache.role:getLevelUpCDGold(left_time, build_xml.freeTime)

        if self._gold == 0 then
            self._txtCDGold:setString(StaticData['local_text']['ancient.city.shop.refresh.free'])
        else
            self._txtCDGold:setString(tostring(self._gold))
        end
    end
    if self._timerField then
        self._timerField:setTime(left_time)
    else
        self._timerField = uq.ui.TimerField:create(self._txtTimeCD, left_time, timer_end, nil, timer_call)
    end
end

function BuildLevelUpModule:refreshUpLayer()
    local build = uq.cache.role.buildings[self._buildId] or {}
    local instance_id = uq.cache.instance:getMaxIntanceID()
    local instance_data = StaticData['instance'][instance_id]
    local str = ""
    local is_pass = false
    if self._buildId == 0 then
        local next_data = uq.cache.instance:getMaxPermisionData(instance_id)
        str = '[' .. next_data.name .. ']'
        is_pass = build.level < instance_data.premiselevel
        self._imgOkCard:setVisible(is_pass)
    else
        is_pass = uq.cache.role:level() > build.level
        str = string.format(StaticData['local_text']['label.build.unlock.tip'], build.level + 1)
        self._imgOkCard:setVisible(false)
    end
    self._btnInstance:setVisible(self._buildId == 0 and not is_pass)
    self._txtInstanceName:setString(str)
    local color = is_pass and "#69ec2d" or "#f22926"
    self._txtInstanceName:setTextColor(uq.parseColor(color))
end

function BuildLevelUpModule:_doUpdateBuild()
    local level = uq.cache.role:getBuildingLevel(self._buildId)
    local build_xml = StaticData['buildings']['CastleMap'][self._buildId]
    local cost = uq.formula.buildLevelUpCost(build_xml.cost, level, build_xml.coefficient, self._buildId)
    local instance_id = uq.cache.instance:getMaxIntanceID()
    local instance_data = StaticData['instance'][instance_id]
    local sick_build_officers = uq.cache.role:getSickBuildOfficer(uq.config.constant.BUILD_ID.MAIN)

    local function confirm()
        if self._cdTotalTime <= build_xml.freeTime then
            network:sendPacket(Protocol.C_2_S_BUILD_CD_LIST, {build_id = self._buildId})
        else
            network:sendPacket(Protocol.C_2_S_BUILD_LEVEL_UP, {build_id = self._buildId})
        end

        self._btnLevelUp:setVisible(false)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            self._btnLevelUp:setVisible(true)
        end)))
    end

    if not uq.cache.role:isAvailableBuilderCDTime() then
        uq.fadeInfo(StaticData['local_text']['label.build.not.builder'])
    elseif build_xml.maxLevel ~= 0 and level >= build_xml.maxLevel then
        uq.fadeInfo(StaticData['local_text']['main.build.levle.limit'])
    elseif self._buildId == 0 and level >= instance_data.premiselevel then
        uq.fadeInfo(StaticData['local_text']['main.pass.instance.limit'])
    elseif not uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.MONEY, cost) then
        uq.fadeInfo(StaticData['local_text']['main.not.enough.money'])
    elseif self._buildId ~= 0 and level >= uq.cache.role:level() then
        uq.fadeInfo(StaticData['local_text']['main.levleup'])
    elseif #sick_build_officers > 0 then --主建筑建设官作用于所有建筑
        local names = ''
        for k, genersl_id in ipairs(sick_build_officers) do
            local info = uq.cache.generals:getGeneralDataByID(genersl_id)
            names = names .. info.name
            if k < #sick_build_officers then
                names = names .. ','
            end
        end

        local function cancle()
            uq.jumpToModule(uq.config.constant.MODULE_ID.BUILD_OFFICER)
        end

        local str = string.format(StaticData['local_text']['label.buildofficer.tip'], names)
        local data = {
            content = str,
            confirm_callback = confirm,
            confirm_txt = StaticData['local_text']['label.buildofficer.continue'],
            cancle_txt = StaticData['local_text']['label.buildofficer.giveup'],
            cancle_callback = cancle
        }
        uq.addConfirmBox(data, uq.config.constant.CONFIRM_TYPE.BUILD_OFFICER)
    else
        confirm()
    end
end

function BuildLevelUpModule:directFinishBuildUp()
    local level = uq.cache.role:getBuildingLevel(self._buildId)
    local build_xml = StaticData['buildings']['CastleMap'][self._buildId]
    local instance_id = uq.cache.instance:getMaxIntanceID()
    local instance_data = StaticData['instance'][instance_id]
    local cost = uq.formula.buildLevelUpCost(build_xml.cost, level, build_xml.coefficient, self._buildId)
    if level >= build_xml.maxLevel then
        uq.fadeInfo(StaticData['local_text']['main.build.levle.limit'])
    elseif self._buildId ~= 0 and level >= uq.cache.role:level() then
        uq.fadeInfo(StaticData['local_text']['main.levleup'])
    elseif not uq.cache.role:checkRes(uq.config.constant.COST_RES_TYPE.MONEY, cost) then
        uq.fadeInfo(StaticData['local_text']['main.not.enough.money'])
    elseif self._buildId == 0 and level >= instance_data.premiselevel then
        uq.fadeInfo(StaticData['local_text']['main.pass.instance.limit'])
    else
        uq.cache.role:directFinishBuildUp(self._buildId)
    end
end

function BuildLevelUpModule:onInstance(event)
    if event.name == "ended" then
        uq.jumpToModule(uq.config.constant.MODULE_ID.INSTANCE, {instance_id = uq.cache.instance:getMaxIntanceID()})
        self:disposeSelf()
    end
end

function BuildLevelUpModule:onCancle(event)
    if event.name == "ended" then
        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.BUILD_SPEED_UP, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
        panel:setData(self._buildId)
    end
end

function BuildLevelUpModule:onCancleBuild(event)
    if event.name ~= "ended" then
        return
    end
    local function confirm()
        network:sendPacket(Protocol.C_2_S_BUILD_CANCEL_LEVEL_UP, {build_id = self._buildId})
    end

    local data = {
        content = StaticData['local_text']['label.build.levelup.cancle'],
        confirm_callback = confirm
    }
    uq.addConfirmBox(data, uq.config.constant.CONFIRM_TYPE.BUILD_LEVEL_UP_CANCLE)
end

function BuildLevelUpModule:onFinish(event)
    if event.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    local build_data = uq.cache.role.buildings[self._buildId]
    local left_time = build_data.cd_time - uq.curServerSecond()
    if left_time < 0 then
        self:directFinishBuildUp()
        return
    end
    uq.cache.role:finishCD(self._buildId)
end

function BuildLevelUpModule:updateCityInfo()
    self:updateView(self._buildId)
end

function BuildLevelUpModule:refreshCropHelp()
    local build_data = uq.cache.role.buildings[self._buildId]
    local xml_data = StaticData['crop_help'].build[build_data.level] or {}
    local help_data = uq.cache.crop:getCropHelpData(self._buildId)
    local times = help_data and  help_data.count or 0
    self._txtCropHelp:setString(string.format(StaticData["local_text"]["build.crop.help.times"], times, xml_data.times))
    local is_finsih = times >= xml_data.times
    local color = is_finsih and "#69ec2d" or "#f22926"
    self._txtCropHelp:setTextColor(uq.parseColor(color))
    self._btnCropHelp:setVisible(not is_finsih)
    self._imgOkUp:setVisible(is_finsih)
end

function BuildLevelUpModule:onCropHelp(event)
    if event.name ~= "ended" then
        return
    end
    local help_data = uq.cache.crop:getCropHelpData(self._buildId)
    if not help_data then
        uq.fadeInfo(StaticData["local_text"]["build.not.crop"])
        return
    end
    uq.jumpToModule(uq.config.constant.MODULE_ID.CROP_HELP)
end

function BuildLevelUpModule:onBgClose(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

return BuildLevelUpModule