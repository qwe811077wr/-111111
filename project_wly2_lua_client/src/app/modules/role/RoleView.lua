local RoleView = class("RoleView", require('app.modules.common.BaseViewWithHead'))

RoleView.RESOURCE_FILENAME = "role/RoleView.csb"
RoleView.RESOURCE_BINDING = {
    ["Node_1"]           = {["varname"] = "_nodeFlag"},
    ["button_gm"]        = {["varname"] = "_btnGM",["events"] = {{["event"] = "touch",["method"] = "onTouchGMBtn",["sound_id"] = 0}}},
    ["img_head"]         = {["varname"] = "_imgHead",["events"] = {{["event"] = "touch",["method"] = "onChangeHead",["sound_id"] = 0}}},
    ["button_name"]      = {["varname"] = "_btnName",["events"] = {{["event"] = "touch",["method"] = "onChangeName",["sound_id"] = 0}}},
    ["button_switch"]    = {["varname"] = "_btnSwitch",["events"] = {{["event"] = "touch",["method"] = "onRoleSwitch",["sound_id"] = 0}}},
    ["txt_country_name"] = {["varname"] = "_txtCountryName"},
    ["img_country_bg"]   = {["varname"] = "_imgCountryBg"},
    ["txt_name"]         = {["varname"] = "_txtName"},
    ["txt_level"]        = {["varname"] = "_txtLv"},
    ["txt_exp"]          = {["varname"] = "_txtExp"},
    ["LoadingBar_2"]     = {["varname"] = "_loadExp"},
    ["txt_power"]        = {["varname"] = "_txtPower"},
    ["txt_main_level"]   = {["varname"] = "_txtMainCityLevel"},
    ["txt_crop"]         = {["varname"] = "_txtCrop"},
    ["txt_server"]       = {["varname"] = "_txtServer"},
    ["button_info"]      = {["varname"] = "_btnInfo",["events"] = {{["event"] = "touch",["method"] = "onSwitch",["sound_id"] = 0}}},
    ["button_set"]       = {["varname"] = "_btnSet",["events"] = {{["event"] = "touch",["method"] = "onSwitch",["sound_id"] = 0}}},
    ["node_info"]        = {["varname"] = "_nodeInfo"},
    ["node_set"]         = {["varname"] = "_nodeSet"},
    ["Panel_9"]          = {["varname"] = "_panelRes"},
    ["CheckBox_music"]   = {["varname"] = "_checkboxMusic"},
    ["CheckBox_sound"]   = {["varname"] = "_checkboxSound"},
    ["CheckBox_report"]  = {["varname"] = "_checkboxReport"},
    ["CheckBox_msg"]     = {["varname"] = "_checkboxMsg"},
    ["Slider_music"]     = {["varname"] = "_sliderMusic"},
    ["Slider_sound"]     = {["varname"] = "_sliderSound"},
    ["Button_music_dec"] = {["varname"] = "_btnMusicDec",["events"] = {{["event"] = "touch",["method"] = "onMusicDec",["sound_id"] = 0}}},
    ["Button_music_add"] = {["varname"] = "_btnMusicAdd",["events"] = {{["event"] = "touch",["method"] = "onMusicAdd",["sound_id"] = 0}}},
    ["Button_sound_dec"] = {["varname"] = "_btnSoundDec",["events"] = {{["event"] = "touch",["method"] = "onSoundDec",["sound_id"] = 0}}},
    ["Button_sound_add"] = {["varname"] = "_btnSoundAdd",["events"] = {{["event"] = "touch",["method"] = "onSoundAdd",["sound_id"] = 0}}},
    ["Text_1"]           = {["varname"] = "_txtServerTime"},
    ["btn_exchange"]     = {["varname"] = "_btnExchange",["events"] = {{["event"] = "touch",["method"] = "onExchange"}}},
    ["btn_service"]      = {["varname"] = "_btnService",["events"] = {{["event"] = "touch",["method"] = "onService"}}},
}
function RoleView:ctor(name, params)
    RoleView.super.ctor(self, name, params)
    self._params = params or {}
end

function RoleView:init()
    self:addShowCoinGroup({uq.config.constant.COST_RES_TYPE.MONEY, uq.config.constant.COST_RES_TYPE.GOLDEN})
    self:centerView()
    self:parseView()
    self:setTitle(uq.config.constant.MODULE_ID.ROLE)

    self._curPage = 1
    self._bgMusicOpen = false
    self._sound1 = 55
    self._sound2 = 56
    self:initLayer()
    self:initSetting()
    self:refreshSwitch()
    self:adaptBgSize()

    local time = os.date('%Y-%m-%d %H:%M:%S', uq.curServerSecond())
    self._txtServerTime:setString('server time:' .. time)
end

function RoleView:onSwitch(event)
    if event.name == "ended" then
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.CHANGE)
        self._curPage = event.target:getTag()
        self:refreshSwitch()
    end
end

function RoleView:refreshSwitch()
    self._btnInfo:setEnabled(self._curPage  == 2)
    self._btnSet:setEnabled(self._curPage   == 1)
    self._nodeInfo:setVisible(self._curPage == 1)
    self._nodeSet:setVisible(self._curPage  == 2)

    if self._curPage == 1 then
        for i = 1, 4 do
            self._btnInfo:getChildByName('txt' .. i):setTextColor(uq.parseColor('#FFFFFF'))
            self._btnSet:getChildByName('txt' .. i):setTextColor(uq.parseColor('#DFD199'))
        end
    else
        for i = 1, 4 do
            self._btnInfo:getChildByName('txt' .. i):setTextColor(uq.parseColor('#DFD199'))
            self._btnSet:getChildByName('txt' .. i):setTextColor(uq.parseColor('#FFFFFF'))
        end
    end
    self:showAction()
end

function RoleView:initLayer()
    self._txtName:setString(uq.cache.role.name)
    self._txtLv:setString(uq.cache.role.master_lvl)
    if uq.cache.server and uq.cache.server.name ~= nil then
        self._txtServer:setString(uq.cache.server.name)
    end
    self._imgCountryBg:loadTexture(uq.cache.role:getCountryBg())
    self._txtCountryName:setString(uq.cache.role:getCountryShortName())
    self:refreshRoleRes()
    self._txtPower:setString(tostring(uq.cache.role.power))
    self._txtMainCityLevel:setString(uq.cache.role:level())
    if uq.cache.role:hasCrop() then
        self._txtCrop:setString(uq.cache.role.crop_name)
    else
        self._txtCrop:setString(StaticData['local_text']['label.none'])
    end
    local exp_config = StaticData['player_level'].playerLevel[uq.cache.role.master_lvl]
    if exp_config then
        local max_exp = exp_config.exp
        self._txtExp:setString(string.format('%d/%d', uq.cache.role.master_exp, max_exp))
        self._loadExp:setPercent(uq.cache.role.master_exp / max_exp * 100)
    else
        self._txtExp:setString(string.format('%d/%d', 0, 0))
        self._loadExp:setPercent(0)
    end
    self:refreshRoleSetting()

    network:addEventListener(Protocol.S_2_C_MASTER_SEND_IMG, handler(self, self._onMasterSend), '_onMasterSend')
    network:addEventListener(Protocol.S_2_C_MODITY_ACCOUNT_NAME, handler(self, self._onChangeName), "_onChangeName")
end

function RoleView:onChangeName(event)
    if event.name == "ended" then
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
        uq.ModuleManager:getInstance():show(uq.ModuleManager.ROLE_NAME, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
    end
end

function RoleView:onChangeHead(event)
    if event.name == "ended" then
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
        uq.ModuleManager:getInstance():show(uq.ModuleManager.ROLE_HEAD, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
    end
end

function RoleView:onRoleSwitch(event)
    if event.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    local function confirm()
        network:clear()
        require('app.network.InitProtocol'):run()
        uq.cache.initCache()
        uq.TimerProxy:cleanAllTimer()
        uq.ModuleManager:getInstance():show(uq.ModuleManager.LOGIN_MODULE,{moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE_ALL})
    end

    local str = string.format(StaticData['local_text']['label.buildofficer.tip'], names)
    local data = {
        title = StaticData['local_text']['label.role.change'],
        content = StaticData['local_text']['label.role.change.desc'],
        confirm_callback = confirm,
        need_close = false,
    }
    uq.addConfirmBox(data)
end

function RoleView:onTouchGMBtn(event)
    if event.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.GM_VIEW)
end

function RoleView:refreshRoleRes()
    local head_id = uq.cache.role:getImgId()
    local resh_type = uq.cache.role:getImgType()
    local res_head = uq.getHeadRes(head_id, resh_type)
    local pre_path, general_config = self:getHeadBody(head_id, resh_type)
    self._imgHead:loadTexture(res_head)

    self._panelRes:removeAllChildren()
    local size = self._panelRes:getContentSize()
    if cc.FileUtils:getInstance():isFileExist(pre_path .. '.skel') then
        local anim = sp.SkeletonAnimation:createWithBinaryFile(pre_path .. '.skel', pre_path .. '.atlas', 1)
        self._panelRes:addChild(anim)
        anim:setScale(general_config.imageRatio)
        anim:setPosition(cc.p(size.width * 0.5 + general_config.imageX - 200, general_config.imageY))
        anim:setAnimation(0, 'idle', true)
    else
        local img = ccui.ImageView:create(pre_path .. '.png')
        self._panelRes:addChild(img)
        img:setAnchorPoint(cc.p(0.5, 1))
        img:setScale(general_config.imageRatio)
        img:setPosition(cc.p(size.width * 0.5 + general_config.imageX + 200, size.height + general_config.imageY))
    end
end

function RoleView:initSetting()
    self._checkboxMusic:onEvent(function(event)
        if event.name == "selected" then
            cc.UserDefault:getInstance():setStringForKey(uq.config.constant.ROLE_SETTING.SET_MUSIC, "on")
            local value_cache = cc.UserDefault:getInstance():getIntegerForKey(uq.config.constant.ROLE_SETTING.SET_MUSIC_VOLUM, 60)
            uq.setMusicVolume(math.min(1, value_cache / 100))
            if value_cache > 0 and not self._bgMusicOpen then
                uq.playSoundByID(1102)
                self._bgMusicOpen = true
            end
        else
            uq.setMusicVolume(0)
            cc.UserDefault:getInstance():setStringForKey(uq.config.constant.ROLE_SETTING.SET_MUSIC, "off")
        end
    end)

    self._checkboxSound:onEvent(function(event)
        if event.name == "selected" then
            cc.UserDefault:getInstance():setStringForKey(uq.config.constant.ROLE_SETTING.SET_SOUND, "on")
            local value_cache = cc.UserDefault:getInstance():getIntegerForKey(uq.config.constant.ROLE_SETTING.SET_SOUND_VOLUM, 70)
            uq.setSoundsVolume(math.min(1, value_cache / 100))
        else
            uq.setSoundsVolume(0)
            cc.UserDefault:getInstance():setStringForKey(uq.config.constant.ROLE_SETTING.SET_SOUND, "off")
        end
    end)

    self._checkboxReport:onEvent(function(event)
        if event.name == "selected" then
            cc.UserDefault:getInstance():setStringForKey(uq.cache.role:getUnipeKey(uq.config.constant.ROLE_SETTING.SET_REPORT), "on")
        else
            cc.UserDefault:getInstance():setStringForKey(uq.cache.role:getUnipeKey(uq.config.constant.ROLE_SETTING.SET_REPORT), "off")
        end
    end)

    self._checkboxMsg:onEvent(function(event)
        if event.name == "selected" then
            cc.UserDefault:getInstance():setStringForKey(uq.cache.role:getUnipeKey(uq.config.constant.ROLE_SETTING.SET_MSG), "on")
        else
            cc.UserDefault:getInstance():setStringForKey(uq.cache.role:getUnipeKey(uq.config.constant.ROLE_SETTING.SET_MSG), "off")
        end
    end)

    self._sliderMusic:onEvent(function(event)
        if event.name == 'ON_PERCENTAGE_CHANGED' then
            local percent = self._sliderMusic:getPercent()
            if cc.UserDefault:getInstance():getStringForKey(uq.config.constant.ROLE_SETTING.SET_MUSIC, "on") == 'on' then
                local hide_music = false
                if self._endTimeMusic and os.time() - self._endTimeMusic < 0.1 then
                    hide_music = true
                else
                    self._endTimeMusic = os.time()
                end
                if not hide_music then
                    local sound_id = self._sound1
                    if percent <= 0 or percent >= 100 then
                        sound_id = self._sound2
                    end
                    uq.playSoundByID(sound_id)
                end
                uq.setMusicVolume(math.min(1, percent / 100))
                if percent > 0 and not self._bgMusicOpen and cc.UserDefault:getInstance():getIntegerForKey(uq.config.constant.ROLE_SETTING.SET_MUSIC_VOLUM, 60) == 0 then
                    uq.playSoundByID(1102)
                    self._bgMusicOpen = true
                end
            end
            cc.UserDefault:getInstance():setIntegerForKey(uq.config.constant.ROLE_SETTING.SET_MUSIC_VOLUM, percent)
        end
    end)

    self._sliderSound:onEvent(function(event)
        if event.name == 'ON_PERCENTAGE_CHANGED' then
            local percent = self._sliderSound:getPercent()
            if cc.UserDefault:getInstance():getStringForKey(uq.config.constant.ROLE_SETTING.SET_SOUND, "on") == "on" then
                local hide_music = false
                if self._endTimeSound and os.time() - self._endTimeSound < 0.1 then
                    hide_music = true
                else
                    self._endTimeSound = os.time()
                end
                if not hide_music then
                    local sound_id = self._sound1
                    if percent <= 0 or percent >= 100 then
                        sound_id = self._sound2
                    end
                    uq.playSoundByID(sound_id)
                end
                uq.setSoundsVolume(math.min(1, percent / 100))
            end
            cc.UserDefault:getInstance():setIntegerForKey(uq.config.constant.ROLE_SETTING.SET_SOUND_VOLUM, percent)
        end
    end)
end

function RoleView:refreshRoleSetting()
    local str_music = cc.UserDefault:getInstance():getStringForKey(uq.config.constant.ROLE_SETTING.SET_MUSIC, "on")
    self._checkboxMusic:setSelected(str_music == 'on')

    local str_sound = cc.UserDefault:getInstance():getStringForKey(uq.config.constant.ROLE_SETTING.SET_SOUND, "on")
    self._checkboxSound:setSelected(str_sound == 'on')

    local value_cache = cc.UserDefault:getInstance():getStringForKey(uq.cache.role:getUnipeKey(uq.config.constant.ROLE_SETTING.SET_REPORT), "on")
    self._checkboxReport:setSelected(value_cache == 'on')

    local value_cache = cc.UserDefault:getInstance():getStringForKey(uq.cache.role:getUnipeKey(uq.config.constant.ROLE_SETTING.SET_MSG), "on")
    self._checkboxMsg:setSelected(value_cache == 'on')

    local value_cache = cc.UserDefault:getInstance():getIntegerForKey(uq.config.constant.ROLE_SETTING.SET_MUSIC_VOLUM, 60)
    self._sliderMusic:setPercent(tonumber(value_cache))
    if str_music == 'off' then
        uq.setMusicVolume(0)
    else
        uq.setMusicVolume(math.min(1, tonumber(value_cache) / 100))
        if value_cache > 0 then
            self._bgMusicOpen = true
        end
    end

    local value_cache = cc.UserDefault:getInstance():getIntegerForKey(uq.config.constant.ROLE_SETTING.SET_SOUND_VOLUM, 70)
    self._sliderSound:setPercent(tonumber(value_cache))
    if str_sound == 'off' then
        uq.setSoundsVolume(0)
    else
        uq.setSoundsVolume(math.min(1, tonumber(value_cache) / 100))
    end
end

function RoleView:onMusicAdd(event)
    if event.name == "ended" then
        local percent = self._sliderMusic:getPercent()
        local sound_id = percent >= 100 and self._sound2 or self._sound1
        uq.playSoundByID(sound_id)
        self._sliderMusic:setPercent(percent + 1)
        percent = self._sliderMusic:getPercent()
        cc.UserDefault:getInstance():setIntegerForKey(uq.config.constant.ROLE_SETTING.SET_MUSIC_VOLUM, percent)
    end
end

function RoleView:onMusicDec(event)
    if event.name == "ended" then
        local percent = self._sliderMusic:getPercent()
        local sound_id = percent <= 0 and self._sound2 or self._sound1
        uq.playSoundByID(sound_id)
        self._sliderMusic:setPercent(percent - 1)
        percent = self._sliderMusic:getPercent()
        cc.UserDefault:getInstance():setIntegerForKey(uq.config.constant.ROLE_SETTING.SET_MUSIC_VOLUM, percent)
    end
end

function RoleView:onSoundAdd(event)
    if event.name == "ended" then
        local percent = self._sliderSound:getPercent()
        local sound_id = percent >= 100 and self._sound2 or self._sound1
        uq.playSoundByID(sound_id)
        self._sliderSound:setPercent(percent + 1)
        percent = self._sliderSound:getPercent()
        cc.UserDefault:getInstance():setIntegerForKey(uq.config.constant.ROLE_SETTING.SET_SOUND_VOLUM, percent)
    end
end

function RoleView:onExchange(event)
    if event.name == "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
end

function RoleView:onService(event)
    if event.name == "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
end

function RoleView:onSoundDec(event)
    if event.name == "ended" then
        local percent = self._sliderSound:getPercent()
        local sound_id = percent <= 0 and self._sound2 or self._sound1
        uq.playSoundByID(sound_id)
        self._sliderSound:setPercent(percent - 1)
        percent = self._sliderSound:getPercent()
        cc.UserDefault:getInstance():setIntegerForKey(uq.config.constant.ROLE_SETTING.SET_SOUND_VOLUM, percent)
    end
end

function RoleView:_onMasterSend(evt)
    local data = evt.data
    if data and next(data) ~= nil then
        uq.cache.role:setImgIdAndType(data.img_type, data.img_id)
        self:refreshRoleRes()
    end
end

function RoleView:_onChangeName(evt)
    local data = evt.data

    if data.ret > 0 then
        if data.ret == 1 then
            uq.fadeInfo(StaticData['local_text']['crop.name.dup'])
        end
        return
    end

    if data and next(data) ~= nil then
        uq.cache.role.rename_times = data.rename_times
        uq.cache.role.name = data.name
        self._txtName:setString(data.name)
    end
end

function RoleView:getHeadBody(head_id, head_type)
    local path = "animation/spine/"
    local str_key = "imageId"
    local res_path, general_config = uq.dealHeadName(head_id, head_type, path, str_key)
    return res_path .. '/' .. general_config.imageId, general_config
end

function RoleView:showAction()
    uq.intoAction(self._nodeFlag)
end

function RoleView:onExit()
    network:removeEventListenerByTag('_onChangeName')
    network:removeEventListenerByTag('_onMasterSend')
    RoleView.super:onExit()
end

return RoleView