local LoginModule = class("LoginModule", require('app.base.ModuleBase'))

LoginModule.RESOURCE_FILENAME = "login/LoginView.csb"
LoginModule.RESOURCE_BINDING = {
    ["server_pnl"]                    = {["varname"] = "_pnlServer"},
    ["server_pnl/choose_btn"]         = {["varname"] = "_btnChoose"},
    ["server_pnl/enter_btn"]          = {["varname"] = "_btnEnter"},
    ["server_pnl/logout_btn"]         = {["varname"] = "_btnLogout"},
    ["login_pnl"]                     = {["varname"] = "_pnlLogin"},
    ["login_pnl/account_pnl"]         = {["varname"] = "_pnlAccount"},
    ["login_pnl/ok_btn"]              = {["varname"] = "_btnOk"},
    ["login_pnl/Button_4"]            = {["varname"] = "_btnAccount"},
    ["login_pnl/name_txtfld"]         = {["varname"] = "_txtfldName"},
    ["login_pnl/pass_txtfld"]         = {["varname"] = "_txtfldPass"},
    ["login_pnl/Panel_2"]             = {["varname"] = "_pnlfldName"},
    ["login_pnl/Panel_3"]             = {["varname"] = "_pnlfldPwd"},
    ["login_pnl/Button_2"]            = {["varname"] = "_btnRegister"},
    ["healthy_img"]                   = {["varname"] = "_imgHealthy"},
    ["img_bg_adapt"]                  = {["varname"] = "_imgBg"},
    ["Panel_2"]                       = {["varname"] = "_pnlBlack"},
    ["Button_guide"]                  = {["varname"] = "_btnGuide",["events"] = {{["event"] = "touch",["method"] = "_onBtnGuide"}}},
    ["Text_14"]                       = {["varname"] = "_txtVersion"},
    ["Node_10"]                       = {["varname"] = "_nodeAction"},
}

function LoginModule:ctor(name, params)
    params.sound_id = 0
    LoginModule.super.ctor(self, name, params)
end

function LoginModule:init()
    self:centerView()
    self:parseView()
    self:adaptBgSize()
    self._tabPng = {"g03_0000757.png", "g03_0000758.png", "g03_0000759.png", "g03_0000760.png"}
    self._oftenServer, self._accountCache = self:getOftenUseCache()
    self._hideAccount = true
    self._pnlAccount:setSwallowTouches(true)
    self._pnlAccount:addClickEventListenerWithSound(function()
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
        self._pnlAccount:setVisible(false)
        self._hideAccount = true
    end)
    for i=1, 3 do
        local account_img = self._pnlAccount:getChildByName("account" .. i .. "_img")
        account_img:addClickEventListenerWithSound(function()
            uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
            self:selectAccount(i)
        end)
    end
    self:initSound()
    self:initLayer()
    self:initServerInfo()
    self:initHealtyAction()
    self:refreshLayerLogin()
    self._btnEnter:addClickEventListener(handler(self, self._enterChooseServer))
    self._btnChoose:addClickEventListener(handler(self, self._onChooseTapped))
    self._btnOk:addClickEventListener(handler(self, self._onAccountCheck))
    self._btnLogout:addClickEventListener(handler(self, self._onBackLogin))
    self._btnAccount:addClickEventListener(handler(self, self._showAccountLayer))
    self._btnRegister:addClickEventListener(handler(self, self._showRegisterLayer))

    local update_path = cc.FileUtils:getInstance():getWritablePath() .. 'update'
    local am = cc.AssetsManagerEx:create('project.manifest', update_path)
    local old_version = am:getLocalManifest():getVersion()
    self._txtVersion:setString('Ver:' .. old_version)

    network:addEventListener(Protocol.S_2_C_LOGIN_RESULT, handler(self, self._onLoginResult), '_onResultLogin')
    services:addEventListener("OnServerChanged", handler(self, self._onServerChanged), "_onServerChanged")
end

function LoginModule:initLayer()
    local size = self._pnlfldName:getContentSize()
    self._editBoxName = ccui.EditBox:create(cc.size(size.width, size.height), '')
    self._editBoxName:setAnchorPoint(cc.p(0.5, 0.5))
    self._editBoxName:setFontName("font/hwkt.ttf")
    self._editBoxName:setFontSize(30)
    self._editBoxName:setFontColor(uq.parseColor("#FEFDDD"))
    self._editBoxName:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._editBoxName:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self._editBoxName:setPosition(cc.p(size.width / 2, size.height / 2))
    self._editBoxName:setPlaceholderFontName("font/hwkt.ttf")
    self._editBoxName:setPlaceholderFontSize(30)
    self._editBoxName:setMaxLength(20)
    self._editBoxName:setPlaceHolder(StaticData["local_text"]["login.input.name"])
    self._editBoxName:setPlaceholderFontColor(cc.c3b(121, 129, 129))
    self._pnlfldName:addChild(self._editBoxName)

    local size = self._pnlfldPwd:getContentSize()
    self._editBoxPwd = ccui.EditBox:create(cc.size(size.width, size.height), '')
    self._editBoxPwd:setAnchorPoint(cc.p(0.5, 0.5))
    self._editBoxPwd:setFontName("font/hwkt.ttf")
    self._editBoxPwd:setFontSize(30)
    self._editBoxPwd:setFontColor(uq.parseColor("#FEFDDD"))
    self._editBoxPwd:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._editBoxPwd:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self._editBoxPwd:setPosition(cc.p(size.width / 2, size.height / 2))
    self._editBoxPwd:setPlaceholderFontName("font/hwkt.ttf")
    self._editBoxPwd:setPlaceholderFontSize(30)
    self._editBoxPwd:setMaxLength(20)
    self._editBoxPwd:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    self._editBoxPwd:setPlaceHolder(StaticData["local_text"]["login.input.pass"])
    self._editBoxPwd:setPlaceholderFontColor(cc.c3b(121, 129, 129))
    self._pnlfldPwd:addChild(self._editBoxPwd)
    --展示文本
    if self._accountCache[1] then
        self._editBoxName:setText(tostring(self._accountCache[1]))
    end
    self:updateGuideInfo()
end

function LoginModule:updateGuideInfo()
    if uq.cache.guide.guide_close then
        self._btnGuide:getChildByName("label_name"):setString(StaticData["local_text"]["gm.search.des3"])
    else
        self._btnGuide:getChildByName("label_name"):setString(StaticData["local_text"]["gm.search.des4"])
    end
end

function LoginModule:_onBtnGuide(event)
    if event.name ~= "ended" then
        return
    end
    uq.cache.guide.guide_close = not uq.cache.guide.guide_close
    cc.UserDefault:getInstance():setBoolForKey("guide_state", uq.cache.guide.guide_close)
    self:updateGuideInfo()
end

function LoginModule:initSound()
    for i = 1, 2 do
        local value_num = 0
        local init_num = i == 1 and 60 or 70
        local str_open = i == 1 and uq.config.constant.ROLE_SETTING.SET_MUSIC or uq.config.constant.ROLE_SETTING.SET_SOUND
        local value_cache = cc.UserDefault:getInstance():getStringForKey(str_open, "on")
        local str_value = i == 1 and uq.config.constant.ROLE_SETTING.SET_MUSIC_VOLUM or uq.config.constant.ROLE_SETTING.SET_SOUND_VOLUM
        local value_str = cc.UserDefault:getInstance():getStringForKey(str_value, init_num)
        if value_cache == "on" then
            value_num = tonumber(value_str)
        end
        if i == 1 then
            uq.setMusicVolume(math.min(value_num / 100, 1))
        else
            uq.setSoundsVolume(math.min(value_num / 100, 1))
        end
    end
    uq.playSoundByID(1100)
end


function LoginModule:initHealtyAction()
    local func1 = cc.CallFunc:create(function()
        self:showHealtyLayer(true)
    end)
    local func2 = cc.CallFunc:create(function()
        self:showHealtyLayer(false)
    end)
    local fade_out = cc.FadeOut:create(2)
    local delay = cc.DelayTime:create(1)
    self._nodeAction:runAction(cc.Sequence:create(func1, delay, fade_out, func2))
end

function LoginModule:showHealtyLayer(is_bool)
    self._imgBg:setVisible(not is_bool)
    self._pnlLogin:setVisible(not is_bool)
    self._nodeAction:setVisible(is_bool)
    self._pnlBlack:setVisible(is_bool)
end

function LoginModule:_onChooseTapped()
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.SERVER_LIST_MODULE, {often_server = self._oftenServer} )
end

function LoginModule:_enterChooseServer()
    uq.playSoundByID(20)
    local loginname = self._editBoxName:getText()
    if #loginname == 0 then
        return
    end
    local p, _ = string.find(loginname, '%W+')
    if p then
        uq.log('Invalid name ' .. loginname)
        return
    end
    uq.cache.account.loginname = loginname
    uq.log(loginname)

    local ret = network:connect(uq.cache.server.address, tonumber(uq.cache.server.port))
    if ret ~= 0 then
        uq.fadeInfo(StaticData["local_text"]["login.error.server"], display.cx, display.cy-100, cc.c3b(255, 0, 0))
        return
    end
    local data = {acc_id = 0, name_len = #uq.cache.account.loginname, login_name = uq.cache.account.loginname, server_id_len = 0,
                  server_id = "", source_len = 0, source = '', timestamp = os.time(), fcm = 1, version = 0}
    data.ticket = uq.Utils:md5(data.acc_id .. data.login_name .. data.server_id .. data.timestamp .. data.fcm .. uq.config.LOGIN_KEY)
    network:sendPacket(Protocol.C_2_S_LOGIN, data)
end

function LoginModule:_onServerChanged(evt)
    local data = uq.cache.server
    self._pnlServer:getChildByName("nameServer_txt"):setString(data.name)
    self._pnlServer:getChildByName('status_img'):loadTexture("img/login/" .. self._tabPng[3])
end

function LoginModule:_onLoginResult(evt)
    local data = evt.data
    uq.log(data)
    if data.result ~= 0 then
        return
    end
    local login_name = self._editBoxName:getText()
    self:setOftenCache(self._oftenServer, 0, uq.cache.server.sid, "oftenserver")
    self:setOftenCache(self._accountCache, "", login_name, "account")
    if data.is_new == 0 then
        uq.pauseBackGroundMusic()
        local back_function = function()
            uq.cache.account.rand_name = data.name
            uq.ModuleManager:getInstance():show(uq.ModuleManager.CREATE_ROLE_MODULE, {moduleType = 1})
        end
        local args = {
            name = "cg/opening.mp4",
            call_back = back_function
        }
        local video = uq.VideoPlayer.getVideoPlayer(args)
        if video then
            uq.ModuleManager:getInstance():getCurScene():addChild(video, -1)
            local attr = {
                title = StaticData['local_text']['label.skip.btn.des'],
                color = "#FFFFFF",
                font_size = 20,
                pos_x = 0.86,
                pos_y = 0.82
            }
            video:playVideo(true)
            video:setSkipBtnAttr(attr)
        else
            back_function()
        end
    else
        network:sendPacket(Protocol.C_2_S_LOAD_CHAR_INFO)
    end
end

function LoginModule:_onBackLogin(evt)
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    self:refreshLayerLogin()
end

function LoginModule:_onAccountCheck(evt)
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
    local login_name = self._editBoxName:getText()
    local login_pwd = self._editBoxPwd:getText()
    if login_name and login_name ~= "" then
        if uq.hasKeyWord(login_name) then
            uq.fadeInfo(StaticData["local_text"]["label.screen.word"])
            return
        end
        if self:isBanName(login_name) then
            uq.fadeInfo(StaticData["local_text"]["login.please.account.bug"])
            return
        end
        if self:isBanPassword(login_pwd) then
            uq.fadeInfo(StaticData["local_text"]["login.please.password.bug"])
            return
        end
        self:refreshLayerServer()
        self._pnlLogin:getChildByName('Text_7'):setVisible(false)
    else
        uq.fadeInfo(StaticData["local_text"]["login.error.passward"])
        self._pnlLogin:getChildByName('Text_7'):setVisible(true)
    end
end

function LoginModule:refreshLayerLogin()
    self._pnlLogin:setVisible(true)
    self._pnlServer:setVisible(false)
    self._pnlAccount:setVisible(false)
end

function LoginModule:refreshLayerServer()
    self._pnlLogin:setVisible(false)
    self._pnlServer:setVisible(true)
    local login_name = self._editBoxName:getText()
    self._pnlServer:getChildByName("name_txt"):setString(login_name)
    self._pnlServer:getChildByName("nameServer_txt"):setString(uq.cache.server.name)
    self._pnlServer:getChildByName('status_img'):loadTexture("img/login/" .. self._tabPng[3])
end

function LoginModule:_showAccountLayer(evt)
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    self._pnlAccount:setVisible(self._hideAccount)
    if self._hideAccount then
        for i=1, 3 do
            local account_img = self._pnlAccount:getChildByName("account" .. i .. "_img")
            account_img:setVisible(self._accountCache[i] ~= nil)
            if self._accountCache[i] ~= nil then
                account_img:getChildByName('account_txt'):setString(self._accountCache[i])
            end
        end
    end
end

function LoginModule:_showRegisterLayer(evt)
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
end

function LoginModule:selectAccount(index)
    self._pnlAccount:setVisible(false)
    if self._accountCache[index] ~= nil then
        self._editBoxName:setText(tostring(self._accountCache[index]))
    end
end

function LoginModule:getOftenUseCache()
    local tab = {}
    local tab_account = {}
    for i=1, 3, 1 do
        local id = cc.UserDefault:getInstance():getStringForKey("oftenserver" .. i, "0")
        if tonumber(id) ~= 0 then
            local tab_info = self:getServerBySid(tonumber(id))
            if next(tab_info) ~= nil then
                tab[i] = tab_info
            end
        end
        local account = cc.UserDefault:getInstance():getStringForKey("account" .. i, "")
        if account ~= "" then
            tab_account[i] = account
        end
    end
    return tab, tab_account
end

function LoginModule:getServerBySid(sid)
    for k, v in pairs(uq.config.servers) do
        if v.sid == sid then
            return v
        end
    end
    return {}
end

function LoginModule:setOftenCache(tab_info, default, now_value, str)
    local tab = {}
    for i=1, 3, 1 do
        if tab_info == self._oftenServer and tab_info[i] and next(tab_info[i]) ~= nil then
            tab[i] = tab_info[i].sid
        elseif tab_info == self._accountCache and tab_info[i] and tab_info[i] ~= "" then
            tab[i] = tab_info[i]
        else
            tab[i] = default
        end
    end
    local no_change = true
    for i=1, #tab, 1 do
        if tab[i] == now_value then
            if i == 1 then
                return
            else
                tab[1],tab[i] = tab[i] , tab[1]
                no_change = false
                break
            end
        end
    end
    if no_change then
        tab[3] = tab[2]
        tab[2] = tab[1]
        tab[1] = now_value
    end
    for i=1, #tab, 1 do
        cc.UserDefault:getInstance():setStringForKey(str .. i,tab[i])
    end
end

function LoginModule:initServerInfo()
    local sid = cc.UserDefault:getInstance():getStringForKey("oftenserver1", "0")
    sid = tonumber(sid)
    local server_rand = {}
    for k, v in pairs(uq.config.servers) do
        if v.sid == sid then
            uq.cache.server = v
            return
        end
        server_rand = v
    end
    uq.cache.server = uq.config.servers[1] or server_rand
end

function LoginModule:isBanName(str)
    local len = #str
    if len < 5 then
        return true
    end
    return string.match(str, '^[%w]+$') == nil
end

function LoginModule:isBanPassword(str)
    if str == nil or str == "" then
        return false
    end
    local len = #str
    if len < 6 then
        return true
    end
    return string.match(str, '^[%p%w]+$') == nil
end

function LoginModule:dispose()
    network:removeEventListenerByTag("_onResultLogin")
    services:removeEventListenersByTag("_onServerChanged")
    LoginModule.super.dispose(self)
end

return LoginModule