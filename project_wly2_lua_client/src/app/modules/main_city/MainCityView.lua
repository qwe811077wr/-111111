local MainCityView = class("MainCityView", require('app.base.ChildViewBase'))

MainCityView.RESOURCE_FILENAME = "main_city/MainCityView.csb"
MainCityView.RESOURCE_BINDING = {
    ["node_right_bottom"]      = {["varname"] = "_nodeRightBottom"},
    ["node_left_bottom"]       = {["varname"] = "_nodeLeftBottom"},
    ["node_left_top"]          = {["varname"] = "_nodeLeftTop"},
    ["node_right_top"]         = {["varname"] = "_nodeRightTop"},
    ["node_right_middle"]      = {["varname"] = "_nodeRightMiddle"},
    ["node_left_middle"]       = {["varname"] = "_nodeLeftMiddle"},
    ["role_icon_img"]          = {["varname"] = "_imgHead",["events"] = {{["event"] = "touch",["method"] = "openViewByTag"}}},
    ["open_general"]           = {["varname"] = "_btnGeneral",["events"] = {{["event"] = "touch",["method"] = "openViewByTag",["sound_id"] = 21}}},
    ["open_warehouse"]         = {["varname"] = "_btnWareHouse",["events"] = {{["event"] = "touch",["method"] = "openViewByTag",["sound_id"] = 21}}},
    ["open_crop"]              = {["varname"] = "_btnCrop",["events"] = {{["event"] = "touch",["method"] = "openViewByTag",["sound_id"] = 21}}},
    ["btn_mail"]               = {["varname"] = "_btnMail",["events"] = {{["event"] = "touch",["method"] = "openViewByTag"}}},
    ["reward_online"]          = {["varname"] = "_btnCommand",["events"] = {{["event"] = "touch",["method"] = "openViewByTag"}}},
    ["btn_chat"]               = {["varname"] = "_btnChat",["events"] = {{["event"] = "touch",["method"] = "openViewByTag"}}},
    ["Button_builder"]         = {["varname"] = "_btnBuilder",["events"] = {{["event"] = "touch",["method"] = "openListBuilds",["sound_id"] = 0}}},
    ["open_pass_check"]        = {["varname"] = "_imgPassCheck",["events"] = {{["event"] = "touch",["method"] = "openViewByTag"}}},
    ["farm_num"]               = {["varname"] = "_txtFarmNum"},
    ["farm_max_num"]           = {["varname"] = "_txtFarmMaxNum"},
    ["btn_world"]              = {["varname"] = "_btnWorld",["events"] = {{["event"] = "touch",["method"] = "openViewByTag"}}},
    ["btn_daily"]              = {["varname"] = "_btnDaily",["events"] = {{["event"] = "touch",["method"] = "openViewByTag"}}},
    ["reward_online_activity"] = {["varname"] = "_btnActivity",["events"] = {{["event"] = "touch",["method"] = "openViewByTag"}}},
    ["bottom_side"]            = {["varname"] = "_panelRightLeft"},
    ["btn_prompt"]             = {["varname"] = "_btnPrompt",["events"] = {{["event"] = "touch",["method"] = "onCropInvitePrompt"}}},
    ["chat_first_name"]        = {["varname"] = "_txtWorldFirstName"},
    ["chat_first_content"]     = {["varname"] = "_txtWorldFirstContent"},
    ["chat_second_name"]       = {["varname"] = "_txtWorldSecondName"},
    ["chat_second_content"]    = {["varname"] = "_txtWorldSecondContent"},
    ["txt_power"]              = {["varname"] = "_txtPower"},
    ["image_top_bg"]           = {["varname"] = "_imgTopBg"},
    ["image_bottom_bg"]        = {["varname"] = "_imgBottomBg"},
    ["node_top_left_info"]     = {["varname"] = "_nodeTopLeftInfo"},
    ["node_bottom_left_info"]  = {["varname"] = "_nodeBottomLeftInfo"},
    ["node_bottom_right_info"] = {["varname"] = "_nodeBottomRightInfo"},
    ["node_top_right_info"]    = {["varname"] = "_nodeTopRightInfo"},
    ["pass_check"]             = {["varname"] = "_txtPassCheckLevel"},
    ["btn_season"]             = {["varname"] = "_btnSeasonYear",["events"] = {{["event"] = "touch",["method"] = "openViewByTag"}}},
    ["txt_year"]               = {["varname"] = "_txtSeasonYear"},
    ["node_pop"]               = {["varname"] = "_nodePop"},
    ["node_instance"]          = {["varname"] = "_nodeTask"},
    ["image_general"]          = {["varname"] = "_imgGeneral"},
    ["lv_txt"]                 = {["varname"] = "_txtLv"},
    ["flag_img"]               = {["varname"] = "_imgFlag"},
    ["crop_coin_txt"]          = {["varname"] = "_txtCropCoin"},
    ["list_build_node"]        = {["varname"] = "_nodeListBuild"},
    ["Node_res"]               = {["varname"] = "_nodeRes"},
    ["btn_crop_help"]          = {["varname"] = "_btnCropHelp",["events"] = {{["event"] = "touch",["method"] = "openViewByTag",["sound_id"] = 3}}},
    ["crop_coin_btn"]          = {["varname"] = "_btnCropCoin",["events"] = {{["event"] = "touch",["method"] = "buyCropCoin",["sound_id"] = 0}}},
    ["task_img"]               = {["varname"] = "_btnTask",["events"] = {{["event"] = "touch",["method"] = "openViewByTag"}}},
    ["Panel_5"]                = {["varname"] = "_pnlClostList",["events"] = {{["event"] = "touch",["method"] = "closeListBuilds"}}},
    ["list_1_btn"]             = {["varname"] = "_btnList1",["events"] = {{["event"] = "touch",["method"] = "openListBtn",["sound_id"] = 0}}},
    ["list_2_btn"]             = {["varname"] = "_btnList2",["events"] = {{["event"] = "touch",["method"] = "openViewByTag"}}},
    ["list_3_btn"]             = {["varname"] = "_btnList3",["events"] = {{["event"] = "touch",["method"] = "openViewByTag"}}},
    ["list_4_btn"]             = {["varname"] = "_btnList4",["events"] = {{["event"] = "touch",["method"] = "openViewByTag"}}},
    ["list_5_btn"]             = {["varname"] = "_btnList5",["events"] = {{["event"] = "touch",["method"] = "openViewByTag"}}},
    ["list_6_btn"]             = {["varname"] = "_btnList6",["events"] = {{["event"] = "touch",["method"] = "openViewByTag"}}},
    ["list_7_btn"]             = {["varname"] = "_btnList7",["events"] = {{["event"] = "touch",["method"] = "openViewByTag"}}},
    ["list_8_btn"]             = {["varname"] = "_btnList8",["events"] = {{["event"] = "touch",["method"] = "openViewByTag",["sound_id"] = 21}}},
    ["btn_equip_pool"]         = {["varname"] = "_btnOpenPool",["events"] = {{["event"] = "touch",["method"] = "openViewByTag"}}},
    ["list_img"]               = {["varname"] = "_imgList"},
    ["list_node"]              = {["varname"] = "_nodeList"},
    ["list_btn"]               = {["varname"] = "_btnListOpen",["events"] = {{["event"] = "touch",["method"] = "closeListLayer",["sound_id"] = 0}}},
    ["list_btn_0"]             = {["varname"] = "_btnListClose",["events"] = {{["event"] = "touch",["method"] = "openListLayer",["sound_id"] = 0}}},
    ["action_1_node"]          = {["varname"] = "_nodeAction1"},
    ["action_2_node"]          = {["varname"] = "_nodeAction2"},
    ["action_3_node"]          = {["varname"] = "_nodeAction3"},
    ["open_instance_war"]      = {["varname"] = "_imgInstanceWar",["events"] = {{["event"] = "touch",["method"] = "openViewByTag"}}}
}

function MainCityView:onCreate()
    MainCityView.super.onCreate(self)

    self:setContentSize(display.size)
    self:setPosition(display.center)
    self:parseView()

    self._buildLevelChangeEeventTag = services.EVENT_NAMES.ON_MAIN_BUILD_LEVEL_CHANGED .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_MAIN_BUILD_LEVEL_CHANGED, handler(self, self._updateMainBuildLevel), self._buildLevelChangeEeventTag)

    local pass_level = uq.cache.pass_check._passCardInfo.level or 0
    self._txtPassCheckLevel:setString(tostring(pass_level))

    local tab_country = StaticData['types'].Country[1]["Type"][uq.cache.role.country_id]
    if tab_country and tab_country.icon then
        self._imgFlag:loadTexture("img/common/ui/" .. tab_country.icon)
    end
    self._resArray = {}
    local currencys = {7, 6, 5, 4, 2}
    self._actionNum = {}
    self._imgArray = {}
    local space = (display.width - 484) / 5
    for k, item in ipairs(currencys) do
        local xml_data = StaticData['top_bar'][tonumber(item)]
        if xml_data then
            self._actionNum[xml_data.type] = {num = 0, total_res = 0, event_tag = ""}
            local panel = uq.createPanelOnly('main_city.MainCityCurrency')
            local oy = k == 5 and -40 or -30
            local pos = cc.p(- (k - 1) * space - 270, oy)
            panel:setPosition(pos)
            panel:setData(xml_data)
            if k == 5 then
                panel:showGoldLayer()
            end
            table.insert(self._resArray, panel)
            self._nodeRightTop:addChild(panel)
        end
    end

    self._nodeLeftTop:setPosition(display.left_top)
    self._nodeRightBottom:setPosition(display.right_bottom)
    self._nodeLeftBottom:setPosition(display.left_bottom)
    self._nodeRightTop:setPosition(display.right_top)
    self._nodeRightMiddle:setPosition(cc.p(display.right_center.x - uq.getAdaptOffX(), display.right_center.y))
    self._nodeLeftMiddle:setPosition(cc.p(display.left_center.x + uq.getAdaptOffX(), display.left_center.y))

    local size = self._imgTopBg:getContentSize()
    self._imgTopBg:setContentSize(cc.size(display.width + 1, size.height))
    self._imgTopBg:setPositionX(0)
    local size = self._imgBottomBg:getContentSize()
    self._imgBottomBg:setContentSize(cc.size(display.width + 1, size.height))
    self._imgBottomBg:setPositionX(0)

    self:updateBuilder()
    self:refreshPower()

    self._openList = false
    self:showListLayer(self._openList)

    self._cropInviteInfo = {}
    self._btnPrompt:setVisible(false)
    network:addEventListener(Protocol.S_2_C_CROP_INVITE_NOTIEY, handler(self, self._onCropInvite))

    self._eventUpdateGoldName = services.EVENT_NAMES.ON_CONSUME_RES_CHANGE .. uq.config.constant.COST_RES_TYPE.GOLDEN
    self._eventUpdateGoldTag = self._eventUpdateGoldName .. tostring(self)
    self._eventUpdateGesteName = services.EVENT_NAMES.ON_CONSUME_RES_CHANGE .. uq.config.constant.COST_RES_TYPE.GESTE
    self._eventUpdateGesteTag = self._eventUpdateGesteName .. tostring(self)
    self._eventUpdateCropName = services.EVENT_NAMES.ON_CONSUME_RES_CHANGE .. uq.config.constant.COST_RES_TYPE.MILITORY_ORDER
    self._eventUpdateCropTag = self._eventUpdateCropName .. tostring(self)

    self:updateResource()
    services:addEventListener(self._eventUpdateGoldName, handler(self, self.updateResource), self._eventUpdateGoldTag)
    services:addEventListener(self._eventUpdateGesteName, handler(self, self.updateResource), self._eventUpdateGesteTag)
    services:addEventListener(self._eventUpdateCropName, handler(self, self.updateResource), self._eventUpdateCropTag)

    self:showChatRed()
    self._eventUpdateChatRedTag = services.EVENT_NAMES.ON_CHAT_REFRESH_PROMPT_RED_NUM .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_CHAT_REFRESH_PROMPT_RED_NUM, handler(self, self.showChatRed), self._eventUpdateChatRedTag)

    self:showAchieveRed()
    self._eventUpdateAchieveRedTag = services.EVENT_NAMES.ON_ACHIEVEMENT_MAIN_CITY_RED_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_ACHIEVEMENT_MAIN_CITY_RED_REFRESH, handler(self, self.showAchieveRed), self._eventUpdateAchieveRedTag)

    self:showMailRed()
    services:addEventListener(services.EVENT_NAMES.ON_MAIL_MAIN_RED, handler(self, self.showMailRed), "update_mail_red" .. tostring(self))

    self:showEquipPoolRed()
    services:addEventListener(services.EVENT_NAMES.ON_UPDATE_EQUIP_POOL_REN, handler(self, self.showEquipPoolRed), "update_equip_pool_red" .. tostring(self))

    self:initRedUI()
    self:_onMainCityDownRedChanges()
    self._eventRedDownTag = services.EVENT_NAMES.ON_MAIN_CITY_BOTTOM_SIDE_RED_CHANGES .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_MAIN_CITY_BOTTOM_SIDE_RED_CHANGES, handler(self, self._onMainCityDownRedChanges),self._eventRedDownTag)

    self:refreshWorldChatContent()
    self._eventUpdateWorldChatTag = services.EVENT_NAMES.ON_CHAT_WORLD_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_CHAT_WORLD_REFRESH, handler(self, self.refreshWorldChatContent), self._eventUpdateWorldChatTag)

    self._eventTagRefresh = services.EVENT_NAMES.ON_MAIN_CITY_REFRESH_BUILD .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_MAIN_CITY_REFRESH_BUILD, handler(self, self.updateCityInfo), self._eventTagRefresh)

    self._eventNewInstance = services.EVENT_NAMES.ON_NEW_INSTANCE .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_NEW_INSTANCE, handler(self, self.updateCityInfo), self._eventNewInstance)

    self._eventRefreshPower = services.EVENT_NAMES.REFRESH_POWER .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.REFRESH_POWER, handler(self, self.refreshPower), self._eventRefreshPower)

    self._eventAchievementOpen = services.EVENT_NAMES.ON_ACHIEVEMENT_OPEN .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_ACHIEVEMENT_OPEN, handler(self, self._onAchievementOpen), self._eventAchievementOpen)

    self._eventRefreshSeason = services.EVENT_NAMES.REFRESH_SEASON .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.REFRESH_SEASON, handler(self, self.setSeason), self._eventRefreshSeason)

    self._buildLevelUpEventTag = services.EVENT_NAMES.ON_BUILD_LEVEL_UP .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_BUILD_LEVEL_UP, handler(self, self.buildLevelUpEvent), self._buildLevelUpEventTag)

    self:onPassCardLevel()
    self._eventPassCardTag = services.EVENT_NAMES.ON_REFRESH_PASS_CHECK_INFO .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_REFRESH_PASS_CHECK_INFO, handler(self, self.onPassCardLevel), self._eventPassCardTag)

    self._eventPassCardRedTag = services.EVENT_NAMES.ON_PASS_CHECK_RED_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_PASS_CHECK_RED_REFRESH, handler(self, self.showPassCardRed), self._eventPassCardRedTag)

    self._eventPlayBroadMsg = services.EVENT_NAMES.ON_PLAY_BROAD_MSG .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_PLAY_BROAD_MSG, handler(self, self.playBroadMsg), self._eventPlayBroadMsg)

    self._eventCropRefresh = services.EVENT_NAMES.ON_CROP_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_CROP_REFRESH, handler(self, self.refreshCropHelp), self._eventCropRefresh)

    self._eventUnloadRefresh = services.EVENT_NAMES.ON_OFFICE_UNLOAD .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_OFFICE_UNLOAD, handler(self, self.refreshOnloadOfficer), self._eventUnloadRefresh)

    self._eventActionTag = services.EVENT_NAMES.ON_RESOURCE_ACTION .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_RESOURCE_ACTION, handler(self, self.updateActionEvent), self._eventActionTag)

    self._eventRefreshRoleInfo = services.EVENT_NAMES.ON_REFRESH_ROLE_INFO .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_REFRESH_ROLE_INFO, handler(self, self.setRoleInfo), self._eventRefreshRoleInfo)

    self._eventRefreshMasterLevel = services.EVENT_NAMES.ON_MASTER_EXP_CHANGE .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_MASTER_EXP_CHANGE, handler(self, self.refreshMasterLevel), self._eventRefreshMasterLevel)

    self._eventTagUpRefresh = services.EVENT_NAMES.ON_STRATRGY_UP_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_STRATRGY_UP_REFRESH, handler(self, self.updateBuilder), self._eventTagUpRefresh)

    self:setSeason()
    self:initTaskUI()
    self:refreshCropHelp()

    self:playBroadMsg()
    self:setRoleInfo()
    self:refreshMasterLevel()

    self:_onRefreshTime()
    self._onTimeRefresh = "_onRefreshTime" .. tostring(self)
    uq.TimerProxy:addTimer(self._onTimeRefresh, handler(self, self._onRefreshTime), 1, -1)
    self:refreshListShow()
    self:showAction()
end

function MainCityView:showAction(not_move)
    local time = not_move and 0 or 0.2
    uq.intoAction(self._nodeList, nil, cc.p(uq.config.constant.MOVE_DISTANCE, -100), cc.p(0, -100), time)
    uq.intoAction(self._nodeAction1, nil, cc.p(-uq.config.constant.MOVE_DISTANCE, 0), cc.p(0, 0), time)
    uq.intoAction(self._nodeAction2, nil, cc.p(-uq.config.constant.MOVE_DISTANCE, -375), cc.p(0, -375), time)
    uq.intoAction(self._nodeAction3, nil, cc.p(0, -uq.config.constant.MOVE_DISTANCE), cc.p(0, 0), time)
end

function MainCityView:_onRefreshTime()
    uq.cache.technology:updataTechnologyUp()
end

function MainCityView:getTopResPosition(res_type)
    for k, v in ipairs(self._resArray) do
        if v:getDataType() == res_type then
            return v:getIconWorldPos()
        end
    end
    return nil
end

function MainCityView:setMainParent(main_parent)
    self._parentMain = main_parent
end

function MainCityView:getIconImg()
    for k, v in ipairs(self._imgArray) do
        if v['state'] then
            return v
        end
    end
    return nil
end

function MainCityView:updateActionEvent(msg)
    local info = msg.data
    local to_pos = self:getTopResPosition(info.res_type)
    if to_pos == nil then
        return
    end
    local cost_info = StaticData.getCostInfo(info.res_type)
    local pop_pos = self._nodeRes:convertToNodeSpace(info.pos_pop)
    local scale = self._parentMain:getMapScene():getBgLayer():getScale()

    local city_pos = self._nodeRes:convertToNodeSpace(info.pos_city)
    local posx_array = {
        {city_pos.x - 150 * scale, city_pos.x - 50 * scale},
        {city_pos.x + 50 * scale, city_pos.x + 150 * scale},
    }
    local posy_array = {
        {city_pos.y - 50 * scale, city_pos.y - 20 * scale},
        {city_pos.y, city_pos.y + 80 * scale},
    }
    self._actionNum[info.res_type].total_res = info.total_res
    for i = 1, 10 do
        self._actionNum[info.res_type].num = self._actionNum[info.res_type].num + 1
        local img = self:getIconImg()
        if not img then
            img = ccui.ImageView:create('img/common/ui/' .. cost_info.miniIcon)
            self._nodeRes:addChild(img)
            table.insert(self._imgArray, img)
        end
        img:setPosition(pop_pos)
        img:setVisible(true)
        img["res_type"] = info.res_type
        local posx_interval = posx_array[math.random(1, #posx_array)]
        local pos_x = math.random(posx_interval[1], posx_interval[2])
        local posy_interval = posy_array[math.random(1, #posy_array)]
        local pos_y = math.random(posy_interval[1], posy_interval[2])
        local bezier ={
            pop_pos,
            cc.p((pos_x + pop_pos.x) * 0.5, (pop_pos.y + 70 * scale)),
            cc.p(pos_x, pos_y),
        }
        local bezierTo = cc.BezierTo:create(0.2 + i * 0.05, bezier)
        img:runAction(cc.Sequence:create(cc.EaseSineIn:create(bezierTo), cc.DelayTime:create(0.3 + i * 0.05), cc.EaseSineIn:create(cc.MoveTo:create(0.6, to_pos)),
            cc.CallFunc:create(handler(self, self.actionEnd))))
    end
    if self._actionNum[info.res_type].event_tag == "" then
        self._actionNum[info.res_type].event_tag = services.EVENT_NAMES.ON_RESOURCE_ACTION .. info.res_type .. tostring(self)
    end
    uq.TimerProxy:addTimer(self._actionNum[info.res_type].event_tag, function()
        uq.TimerProxy:removeTimer(self._actionNum[info.res_type].event_tag)
        self._actionNum[info.res_type].event_tag = ""
        services:dispatchEvent({name = services.EVENT_NAMES.ON_RESOURCE_ACTION .. info.res_type, data = {is_begain = true}})
    end, 0, 1, 1.5)
end

function MainCityView:actionEnd(node)
    local res_type = node["res_type"]
    self._actionNum[res_type].num = self._actionNum[res_type].num - 1
    if self._actionNum[res_type].num <= 0 then
        services:dispatchEvent({name = services.EVENT_NAMES.ON_RESOURCE_ACTION .. res_type,
        data = {is_begain = false, total_res = self._actionNum[res_type].total_res}})
    end
    node:removeFromParent()
end

function MainCityView:initRedUI()
    self._redUIArray = {}
    self._redUIArray[uq.cache.hint_status.RED_TYPE.MAIN_CITY_WAREHOUSE] = self._btnWareHouse
    self._redUIArray[uq.cache.hint_status.RED_TYPE.MAIN_CITY_GENERALS] = self._btnGeneral
    self._redUIArray[uq.cache.hint_status.RED_TYPE.MAIN_CITY_CROP] = self._btnCrop
    self._redUIArray[uq.cache.hint_status.RED_TYPE.MAIN_CITY_ACHIEVEMENT] = self._btnActivity
end

function MainCityView:initTaskUI()
    local btn = self._nodeTask:getChildByName('Button_8')
    btn:addClickEventListener(function(sender)
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
        uq.jumpToModule(uq.config.constant.MODULE_ID.ACHIEVEMENT)
    end)
    self:refreshTask()
end

function MainCityView:refreshTask()
    local btn = self._nodeTask:getChildByName('Button_8')
    local txt_name = self._nodeTask:getChildByName('Text_16_0')
    local is_exist = uq.cache.achievement._mainTask.exist_reward
    local data = uq.cache.achievement:getMinTask()
    if data == nil or next(data) == nil then
        return
    end
    local dec = ' (' .. data.task_cur_num .. '/' .. data.task_all_num .. ')'
    local str = string.format(StaticData['local_text']['main.city.task.title'], data.chapter_num, data.chapter_name .. dec)
    txt_name:setHTMLText(str)
end

function MainCityView:_onMainCityDownRedChanges(msg)
    if msg then
        if self._redUIArray[msg.data] ~= nil then
            uq.showRedStatus(self._redUIArray[msg.data], uq.cache.hint_status.status[msg.data], self._redUIArray[msg.data]:getContentSize().width / 4, self._redUIArray[msg.data]:getContentSize().width / 4)
        end
    else
        for k, v in pairs(self._redUIArray) do
            uq.showRedStatus(v, uq.cache.hint_status.status[k], v:getContentSize().width / 4, v:getContentSize().width / 4)
        end
    end
end

function MainCityView:updateResource()
    local num = uq.cache.role:getResNum(uq.config.constant.COST_RES_TYPE.MILITORY_ORDER, 0)
    local max_num = math.floor(StaticData['types'].MaxLimit[1].Type[3].value)
    self._txtCropCoin:setString(num .. "/" .. max_num)
end

function MainCityView:openViewByTag(event)
    if event.name == "ended" then
        self:showListLayer(false)
        local tag = event.target:getTag()
        --聊天
        if StaticData['module'][10].ident == tag then
            uq.cache.chat._unReadMsgNum = 0
            self:showChatRed()
        end
        --国战
        if StaticData['module'][4].ident == tag then
            --判断自己是否是军团长
            local crop_data = uq.cache.crop:getCropDataById(uq.cache.role.cropsId)
            if next(crop_data) == nil then
                uq.fadeInfo(StaticData["local_text"]["world.war.power.des5"])
                return
            end
            if crop_data.power_id == 0 then
                uq.ModuleManager:getInstance():show(uq.ModuleManager.CREATE_POWER_MODULE)
                return
            end
            uq.cache.world_war.move_city_id = 0
        end
        uq.jumpToModule(tag)
    end
end

function MainCityView:_updateMainBuildLevel()
    self:showBuildGradeUp()
end

function MainCityView:onExit()
    services:removeEventListenersByTag(self._buildLevelChangeEeventTag)
    services:removeEventListenersByTag(self._eventUpdateGesteTag)
    services:removeEventListenersByTag(self._eventUpdateGoldTag)
    services:removeEventListenersByTag(self._eventUpdateCropTag)
    services:removeEventListenersByTag(self._eventUpdateChatRedTag)
    services:removeEventListenersByTag(self._eventUpdateAchieveRedTag)
    services:removeEventListenersByTag(self._eventRedDownTag)
    services:removeEventListenersByTag(self._eventTagRefresh)
    services:removeEventListenersByTag(self._eventNewInstance)
    services:removeEventListenersByTag(self._eventUpdateWorldChatTag)
    services:removeEventListenersByTag(self._eventRefreshPower)
    services:removeEventListenersByTag(self._eventAchievementOpen)
    services:removeEventListenersByTag(self._eventRefreshSeason)
    services:removeEventListenersByTag(self._buildLevelUpEventTag)
    services:removeEventListenersByTag(self._eventPassCardTag)
    services:removeEventListenersByTag(self._eventPassCardRedTag)
    services:removeEventListenersByTag(self._eventPlayBroadMsg)
    services:removeEventListenersByTag(self._eventCropRefresh)
    services:removeEventListenersByTag(self._eventUnloadRefresh)
    services:removeEventListenersByTag(self._eventActionTag)
    services:removeEventListenersByTag(self._eventRefreshRoleInfo)
    services:removeEventListenersByTag(self._eventRefreshMasterLevel)
    services:removeEventListenersByTag(self._eventTagUpRefresh)
    services:removeEventListenersByTag('update_mail_red' .. tostring(self))
    services:removeEventListenersByTag("update_equip_pool_red" .. tostring(self))
    if self._buildTimerField then
        self._buildTimerField:dispose()
        self._buildTimerField = nil
    end
    uq.TimerProxy:removeTimer(self._onTimeRefresh)
    for k, info in pairs(self._actionNum) do
        if info.event_tag ~= "" then
            uq.TimerProxy:removeTimer(info.event_tag)
        end
        info.event_tag = ""
    end
    MainCityView.super.onExit(self)
end

function MainCityView:updateCityInfo()
    self:updateBuilder()
    self:refreshBtnView()
    for k, v in pairs(self._resArray) do
        v:updateValue()
    end
end

function MainCityView:updateBuilder()
    local num = uq.cache.technology:isFullFinish() and 0 or 1
    local builder_num = uq.cache.role:getAvailableBuildNum() + num
    local max_builder_num = uq.cache.role:getBuildNum() + 1
    self._txtFarmNum:setString(max_builder_num - builder_num)
    self._txtFarmMaxNum:setString('/' .. max_builder_num)

    local min_time, build_id = uq.cache.role:getMinBuilderCDTime()
    self._curCdBuildID = build_id
    if min_time <= 0 then
        if self._buildTimerField then
            self._buildTimerField:dispose()
            self._buildTimerField = nil
        end
        return
    end

    if self._buildTimerField then
        self._buildTimerField:setTime(min_time)
    else
        self._buildTimerField = uq.ui.TimerField:create(nil, min_time, handler(self, self.updateBuilderTimerEnd))
    end
end

function MainCityView:updateBuilderTimerEnd()
    --计时结束 通知服务器升级
    uq.cache.role.buildings[self._curCdBuildID].builder_index = nil
    network:sendPacket(Protocol.C_2_S_BUILD_FINISH_LEVEL_UP, {build_id = self._curCdBuildID})
    self:updateBuilder()
end

function MainCityView:showChatRed()
    self._notReadNum = uq.cache.chat._unReadMsgNum
    if self._notReadNum >= 99 then
        self._notReadNum = 99
    end

    local imgRed = self._btnChat:getChildByName("widget_red_img")
    local size = self._btnChat:getContentSize()
    if self._notReadNum == 0 then
        uq.showRedStatus(self._btnChat, false)
        return
    end

    if imgRed == nil then
        uq.showRedStatus(self._btnChat, true, -size.width / 2 + 11, size.height / 2 - 11)
        local img = self._btnChat:getChildByName("widget_red_img")
        img:loadTexture("img/common/ui/g03_0000484.png")

        local label = cc.LabelTTF:create('', "font/hwkt.ttf", 16)
        label:setString(self._notReadNum)
        label:setName("red_label")
        label:setColor(uq.parseColor("#FEFDDD"))
        label:setPosition(cc.p(10, 12))
        img:addChild(label)
    else
        local red_label = imgRed:getChildByName("red_label")
        red_label:setString(self._notReadNum)
    end
end

function MainCityView:showAchieveRed()
    local isExist = uq.cache.task._isExistTaskReward
    local size = self._btnTask:getContentSize()
    uq.showRedStatus(self._btnTask, isExist, size.width / 4, size.height / 4)

    local isMainExist = uq.cache.achievement._isExistAchieveReward
    local btn = self._nodeTask:getChildByName('Button_8')
    local size = btn:getContentSize()
    uq.showRedStatus(btn, isMainExist, size.width / 2 - 30, size.height / 2 - 20)
    self:refreshTask()
end

function MainCityView:showMailRed()
    local isExist = uq.cache.mail._isExistMailRed
    local size = self._btnMail:getContentSize()
    uq.showRedStatus(self._btnMail, isExist, size.width / 4, size.height / 4)
end

function MainCityView:showEquipPoolRed()
    local isExist = false
    for k, v in pairs(uq.cache.equipment._equipPoolRed) do
        if v then
            isExist = true
            break
        end
    end
    local size = self._btnOpenPool:getContentSize()
    uq.showRedStatus(self._btnOpenPool, isExist, size.width / 4, size.height / 4)
end

function MainCityView:setEnterMainCity()
    self._btnWorld:setTag(100)
    self._btnWorld:loadTextureNormal('img/main_city/s03_0007029_1.png')
    self._btnWorld:loadTextureDisabled('img/main_city/s03_0007029_1.png')
end

function MainCityView:setNodeRightBottom(flag)
    self._nodeRightBottom:setVisible(flag)
end

function MainCityView:setNodeRightTop(flag)
    self._nodeRightTop:setVisible(flag)
end

function MainCityView:setNodeLeftTop(flag)
    self._nodeLeftTop:setVisible(flag)
end

function MainCityView:setNodeLeftBottom(flag)
    self._nodeLeftBottom:setVisible(flag)
end

--根据tag显示开放的入口
function MainCityView:showModules(modules)
    modules = string.split(modules, ',')

    for k, item in ipairs(self._panelRightLeft:getChildren()) do
        item:setVisible(false)
    end

    local index = 0
    for k = #modules, 1, -1 do
        local panel_module = self._panelRightLeft:getChildByTag(tonumber(modules[k]))
        if panel_module then
            panel_module:setVisible(true)
            panel_module:setPositionX(443 - index * 86)
            index = index + 1
        end
    end
end

function MainCityView:_onCropInvite(msg)
    self._btnPrompt:setVisible(true)
    self._cropInviteInfo = msg.data
end

function MainCityView:onCropInvitePrompt(event)
    if event.name ~= "ended" then
        return
    end

    local function confirm()
        network:sendPacket(Protocol.C_2_S_CROP_APPLY, {crop_id = self._cropInviteInfo.crop_id})
        self._cropInviteInfo = {}
        self._btnPrompt:setVisible(false)
    end

    local des = string.format(StaticData['local_text']['chat.legion.invitate'], self._cropInviteInfo.from_name)
    local data = {
        content = des,
        confirm_callback = confirm
    }
    uq.addConfirmBox(data)
end

function MainCityView:refreshWorldChatContent()
    local data = uq.cache.chat._mainUIWorldChatInfo

    if not data[1] then
        return
    end
    self:setWorldChatInfo(self._txtWorldFirstName, self._txtWorldFirstContent, data[1])

    if not data[2] then
        return
    end
    self:setWorldChatInfo(self._txtWorldSecondName, self._txtWorldSecondContent, data[2])
end

function MainCityView:setWorldChatInfo(name, content, data)
    name:setString(data.role_name .. ':')
    local size = name:getContentSize()
    local pos_x = name:getPositionX()
    local content_x = pos_x + size.width + 10
    content:setPositionX(content_x)

    local info = ""
    local new_info = ""
    local len = nil
    if data.content_type == uq.config.constant.TYPE_CHAT_CONTENT.CCT_CHAT_BATTLE_SHARE then
        local data_content = json.decode(data.content)
        info = StaticData['local_text']['main.city.chat.share'].. " " .. data_content.ower.player_name .. StaticData['local_text']['main.city.chat.battle'] .. data_content.enemy.player_name
        len = uq.cache.chat:getInterceptReportLen(data, info)

    else
        info = data.content
        len = uq.cache.chat:getInterceptLen(data)
    end
    new_info = info
    if len then
        new_info = string.subUtf(info, 1 , len)
    end

    content:setString(new_info)
end

function MainCityView:refreshPower()
    self._txtPower:setString(uq.cache.role.power)
end

function MainCityView:_onAchievementOpen(msg)
    local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.ACHIEVEMENT_CHAPTER_OPEN, {zOrder = uq.ModuleManager.SPECIAL_ZORDER.TIP_ZORDER - 10, moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
    panel:setData(msg.data)
end

function MainCityView:setNodeTopLeftInfoVisible(flag)
    self._nodeTopLeftInfo:setVisible(flag)
end

function MainCityView:setNodeBottomLeftInfoVisible(flag)
    self._nodeBottomLeftInfo:setVisible(flag)
end

function MainCityView:setNodeBottomRightVisible(flag)
    self._nodeBottomRightInfo:setVisible(flag)
end

function MainCityView:setNodeTopRightInfoVisible(flag)
    self._nodeTopRightInfo:setVisible(flag)
end

function MainCityView:showWorldOnly(flag)
    self._btnWorld:setVisible(flag)
    self._btnCommand:setVisible(not flag)
    self._btnActivity:setVisible(not flag)
    self._btnOpenPool:setVisible(not flag)
end

function MainCityView:setLeftMiddleVisible(flag)
    self._nodeLeftMiddle:setVisible(flag)
end

function MainCityView:setRightMiddleVisible(flag)
    self._nodeRightMiddle:setVisible(flag)
end

function MainCityView:setNodeRightBottom(flag)
    self._nodeRightBottom:setVisible(flag)
end

function MainCityView:setNodeRightTop(flag)
    self._nodeRightTop:setVisible(flag)
end

function MainCityView:setNodeLeftTop(flag)
    self._nodeLeftTop:setVisible(flag)
end

function MainCityView:setSeason()
    self._txtSeasonYear:setString(uq.cache.server.year .. StaticData['local_text']['label.year'])
end

function MainCityView:buildLevelUpEvent(data)
    local bid = data.build_id
    local temp = StaticData['buildings']['CastleMap'][bid] or {}
    local build = uq.cache.role.buildings[bid]
    local exp = uq.formula.buildLevelUpExp(build.level - 1, temp.coefficient, bid)
    local str = string.format(StaticData['local_text']['decree.str.green'], "+" .. exp)
    uq.fadeInfo(StaticData['local_text']['decree.role.exp'] .. " " .. str, nil , nil , nil, nil, 900080, -10 , 40)
    uq.playSoundByID(25)
end

function MainCityView:refreshMasterLevel()
    self._txtLv:setString("Lv." .. uq.cache.role.master_lvl)
end

function MainCityView:showBuildGradeUp()
    local data = StaticData['function_tips']
    local level = uq.cache.role:level()
    for i, v in ipairs(data) do
        if v.type == uq.config.constant.OPEN_TIPS.LV and level == tonumber(v.openLevel) then
            local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.MAIN_CITY_LEVEL_UP)
            panel:setData(v)
            break
        end
    end
end

function MainCityView:setNodePopVisible(flag)
    self._nodePop:setVisible(flag)
end

function MainCityView:onPassCardLevel()
    if uq.cache.pass_check._passCardInfo == nil or next(uq.cache.pass_check._passCardInfo) == nil then
        return
    end
    self._txtPassCheckLevel:setString(tostring(uq.cache.pass_check._passCardInfo.level))
    self:showPassCardRed()
    if uq.cache.pass_check._passCardInfo.state == 0 then
        self._imgPassCheck:loadTexture("img/main_city/j03_000045.png")
        return
    end
    local data = StaticData['types']['PassLevel'][1]['Type']
    for k, v in ipairs(data) do
        if uq.cache.pass_check._passCardInfo.level < v.level then
            self._imgPassCheck:loadTexture("img/main_city/" .. v.image)
            break
        end
    end
end

function MainCityView:showPassCardRed()
    local data = uq.cache.pass_check._reds
    local size = self._imgPassCheck:getContentSize()
    local is_exist = false
    for k, v in pairs(data) do
        is_exist = is_exist or v
    end
    uq.showRedStatus(self._imgPassCheck, is_exist, size.width / 2 - 10, size.height / 2 - 10)
end

function MainCityView:playBroadMsg()
    if #uq.cache.chat._broadData == 0 then
        return
    end

    if not self._broadMsg then
        self._broadMsg = uq.createPanelOnly('chat.BroadMsg')
        self:addChild(self._broadMsg)
    end
    self._broadMsg:setVisible(true)

    for k, item in ipairs(uq.cache.chat._broadData) do
        self._broadMsg:pushData(item)
    end
    uq.cache.chat._broadData = {}
end

function MainCityView:refreshCropHelp()
    self._btnCropHelp:setVisible(uq.cache.role:hasCrop())
end

function MainCityView:buyCropCoin(event)
    if event.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    uq.jumpToModule(uq.config.constant.MODULE_ID.BUY_MILITORY_ORDER)
end

function MainCityView:openListBuilds(event)
    if event.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    self._nodeListBuild:setVisible(true)
    if not self._buildList then
        self._buildList = uq.createPanelOnly("main_city.BuilderListModule")
        self._nodeListBuild:addChild(self._buildList)
    end
    self._buildList:openAction()
end

function MainCityView:closeListBuilds(event)
    if event.name ~= "ended" then
        return
    end
    self._nodeListBuild:setVisible(false)
    if self._buildList then
        self._buildList:removeSelf()
        self._buildList = nil
    end
end

function MainCityView:closeListLayer(event)
    if event.name ~= "ended" then
        return
    end
    self:showListLayer(false)
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
end

function MainCityView:openListLayer(event)
    if event.name ~= "ended" then
        return
    end
    self:showListLayer(true)
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
end

function MainCityView:openListBtn(event)
    if event.name ~= "ended" then
        return
    end
    self:showListLayer(not self._openList)
    local sound_id = self._openList and uq.config.constant.COMMON_SOUND.BUTTON_TWO or uq.config.constant.COMMON_SOUND.BUTTON
    uq.playSoundByID(sound_id)
end

function MainCityView:showListLayer(is_open)
    local num = 1
    for i = 2, 7 do
        local tag = self["_btnList" .. i]:getTag()
        local is_show = uq.jumpToModule(tag, nil, true)
        self["_btnList" .. i]:setVisible(is_open and is_show)
        if is_show then
            num = num + 1
        end
    end
    self._imgList:setContentSize(cc.size(num * 100 + 64, 90))
    self._btnListOpen:setPositionX(-num * 100 - 44)
    self._imgList:setVisible(is_open)
    self._btnListClose:setVisible(false)
    self._btnListOpen:setVisible(is_open)
    self._openList = is_open
end

function MainCityView:isShowList()
    for i = 2, 7 do
        local tag = self["_btnList" .. i]:getTag()
        local is_show = uq.jumpToModule(tag, nil, true)
        if is_show then
            return is_show
        end
    end
    return false
end

function MainCityView:refreshListShow()
    local is_show = self:isShowList()
    self._btnList1:setVisible(is_show)
    if not is_show then
        self:showListLayer(false)
    end
end

function MainCityView:onEnter()
    MainCityView.super.onEnter()

    self:refreshOnloadOfficer()
end

function MainCityView:refreshOnloadOfficer()
    if not uq.cache.role.unload_officer_data then
        return
    end

    local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.BUILD_OFFICER_TIP, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
    panel:setData(uq.cache.role.unload_officer_data)

    uq.cache.role.unload_officer_data = nil
end

function MainCityView:setRoleInfo()
    local head_id = uq.cache.role:getImgId()
    local resh_type = uq.cache.role:getImgType()
    local res_head = uq.getHeadRes(head_id, resh_type)
    self._imgHead:loadTexture(res_head)
end

function MainCityView:refreshBtnView()
    local tab_btn = {"_btnActivity", "_btnOpenPool"}
    for i, v in ipairs(tab_btn) do
        local tag = self[v]:getTag()
        local is_show = uq.jumpToModule(tag, nil, true)
        self[v]:setVisible(is_show)
    end
    self:isShowList()
end


return MainCityView