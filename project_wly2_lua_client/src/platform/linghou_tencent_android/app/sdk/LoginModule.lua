-- local LoginModule = class("LoginModule", require('app.base.ModuleBase'))
local LoginModule = class("LoginModule", require('app.sdkcommon.LoginModuleCommon'))

local Protocol = require "protocol_base_pb"
local ProtocolLogin = require "protocol_login_pb"
local ProtocolHero = require "protocol_hero_pb"
local loginController = uq.modules.login.LoginController
local Lang = uq.Language.common

local logger = uq.log_console("sdk.LoginModule")

function LoginModule:ctor(name, params)
	LoginModule.super.ctor(self, name, params)

	self.servers = {}
	self.arm = nil
	self.dragonArm = nil
	self._loginChan = nil

	self._user = {}

	self.inputUser = nil
	self.inputPasswd = nil

	self.server_index = 0
	self.servers_count = 0

	self.SDK_CALL_ALIVE_TS = 3600 * 24 * 7
end

function LoginModule:init()
	logger:debug("LoginModule init")
	if uq.sdk.platform == "linghou_tencent" and uq.SdkHelper then
		local adid = uq.sdk.ad_id or 0
	 	local deviceId
        if uq.UqeeNativeExtend and uq.UqeeNativeExtend.getDeviceID then
        	deviceId = uq.UqeeNativeExtend:getDeviceID() or ""
        else
        	deviceId = uq.SdkHelper:getInstance():getUniqueIdentification()
       	end
	 	local ip = uq.SdkHelper:getInstance():getIpAddress()
		uq.http_uqee_report_equipment(deviceId, ip, adid, function(subData)
			uq.log("=====http_uqee_report_register=======!", subData)
		end)
	end

	self._view = uq.parseView(cc.CSLoader:createNode("login/LoginModule.csb"))

	local bg_login = self._view:getChildByName("bg_login")
	if uq.sdk.platform == "linghou_tencent" then
		bg_login:setVisible(false)
		local loginNodePosX, loginNodePosY = bg_login:getPosition()

		local btnWX = ccui.Button:create("c/c0127_2.png", "c/c0127_2.png", nil)
	    btnWX:setName("btn_login_wx")
	    btnWX:setPosition(cc.p(loginNodePosX - 150, loginNodePosY))
		btnWX:setPressedActionEnabled(true)
		btnWX:setZoomScale(0.02)
	    self._view:addChild(btnWX)
		btnWX:addClickEventListenerWithSound(handler(self, self._onWxLogin))

		local btnQQ = ccui.Button:create("c/c0127_3.png", "c/c0127_3.png", nil)
	    btnQQ:setName("btn_login_qq")
	    btnQQ:setPosition(cc.p(loginNodePosX + 150, loginNodePosY))
		btnQQ:setPressedActionEnabled(true)
		btnQQ:setZoomScale(0.02)
		btnQQ:addClickEventListenerWithSound(handler(self, self._onQQLogin))
	    self._view:addChild(btnQQ)
	end

	self:dragonAction()

	self:autoAdapition()
	self:centerView(self._view)

    uq.config.servers = {}

    local btn_account = self._view:getChildByName('bg_account')
	btn_account:addClickEventListenerWithSound(handler(self, self._onSwitchLogin))

	local txt_cur_account = self._view:getChildByName('txt_cur_account')
	txt_cur_account:setVisible(true)
	txt_cur_account:setString("")

	local bg_login = self._view:getChildByName("bg_login")
	local btn_switch_server = bg_login:getChildByName('btn_choose_server')
	btn_switch_server:addClickEventListenerWithSound(handler(self, self._onShowServers))

	local btn_guide_switch = self._view:getChildByName('btn_guide_switch')
	btn_guide_switch:setVisible(false)

	local btn_enter = bg_login:getChildByName('btn_enter')
	uq.setBtnScaleEvent(btn_enter)
	btn_enter:addClickEventListenerWithSound(handler(self, self._onEnterGame))

	local btn_notice = self._view:getChildByName('btn_notice')
	uq.setBtnScaleEvent(btn_notice)
	btn_notice:addClickEventListenerWithSound(function( )
			uq.http_broad(function(data)
				uq.log(data)
				if not data then
					return
				end
				if data.code and tonumber(data.code) ~= 0 then
					return
				end
				if data.data and #data.data <= 0 then
					return
				end
				uq.cache.noticeBoardData = data
				uq.ModuleManager:getInstance():show(uq.ModuleManager.NOTICE_BOARD_MODULE,{data=data})
			end)
		end)

	self.position = cc.p(self._view:getPositionX(), self._view:getPositionY())

    services:addEventListener("OnServerSelect", handler(self, self._onServerSelect), "_onServerSelectListListener")
    services:addEventListener("OnLoginGameServer", handler(self, self._onLoginGameServer), "_onLoginGameServer")

  	self:_requestServers()
  	self:_doLogin()

	if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
    	self:returnKeyListen()
    end
end

function LoginModule:autoAdapition()
	self:pushTopNode(self._view:getChildByName('img_log'))
	self:pushTopNode(self._view:getChildByName('bg_account'))
	self:pushTopNode(self._view:getChildByName('btn_account'))
	-- self:pushTopNode(self._view:getChildByName('btn_choose_account'))
	self:pushTopNode(self._view:getChildByName('txt_cur_account'))
	self:pushTopNode(self._view:getChildByName('btn_notice'))

	self:pushMiddleNode(self._view:getChildByName('btn_guide_switch'))
	self:pushBottomNode(self._view:getChildByName('bg_login'))
	if uq.sdk.platform == "linghou_tencent" then
		self:pushBottomNode(self._view:getChildByName('btn_login_wx'))		
		self:pushBottomNode(self._view:getChildByName('btn_login_qq'))
	end
end

--手机返回键监听
function LoginModule:returnKeyListen()
    local layer = cc.Layer:create()
    uq.log("返回键监听")
    --回调方法
    local function onrelease(code, event)
        if code == cc.KeyCode.KEY_BACK then
            uq.log("你点击了返回键")
			uq.sdkExit()
        elseif code == cc.KeyCode.KEY_MENU then
            uq.log("你点击了菜单键")
        end
    end
    --监听手机返回键
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onrelease, cc.Handler.EVENT_KEYBOARD_RELEASED)
    --lua中得回调，分清谁绑定，监听谁，事件类型是什么
    local eventDispatcher =layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener,layer)
    self._view:addChild(layer)
end

function LoginModule:_doLogin()
	print("----------do login------------")
	self._loginChan = cc.UserDefault:getInstance():getStringForKey("LOGIN_CHAN")
	if self._loginChan and self._loginChan ~= "" then
		if self._loginChan == "wx" then
			local ts = cc.UserDefault:getInstance():getStringForKey("WX_CALL_SDK_TS")
			if uq.curSecond() - tonumber(ts) > self.SDK_CALL_ALIVE_TS then
				return
			end

			local openid = cc.UserDefault:getInstance():getStringForKey("WX_OPENID")
			local openkey = cc.UserDefault:getInstance():getStringForKey("WX_OPENKEY")

			uq.cache.openid = openid
			uq.cache.openkey = openkey
			uq.cache.pf = cc.UserDefault:getInstance():getStringForKey("WX_PF")
			uq.cache.pfkey = cc.UserDefault:getInstance():getStringForKey("WX_PFKEY")
			uq.cache.payToken = cc.UserDefault:getInstance():getStringForKey("WX_PAY_TOKEN")
			uq.cache.accessToken = cc.UserDefault:getInstance():getStringForKey("WX_ACCESS_TOKEN")

			uq.sdkTencentLogin(nil, handler(self, self._onAutoLoginResponse))
			
			self:_wxLoginHandler(openid, openkey)
		elseif self._loginChan == "qq" then
			local ts = cc.UserDefault:getInstance():getStringForKey("QQ_CALL_SDK_TS")
			if uq.curSecond() - tonumber(ts) > self.SDK_CALL_ALIVE_TS then
				return
			end

			local openid = cc.UserDefault:getInstance():getStringForKey("QQ_OPENID")
			local openkey = cc.UserDefault:getInstance():getStringForKey("QQ_OPENKEY")

			uq.cache.openid = openid
			uq.cache.openkey = openkey
			uq.cache.pf = cc.UserDefault:getInstance():getStringForKey("QQ_PF")
			uq.cache.pfkey = cc.UserDefault:getInstance():getStringForKey("QQ_PFKEY")
			uq.cache.payToken = cc.UserDefault:getInstance():getStringForKey("QQ_PAY_TOKEN")
			uq.cache.accessToken = cc.UserDefault:getInstance():getStringForKey("QQ_ACCESS_TOKEN")
		
			uq.sdkTencentLogin(nil, handler(self, self._onAutoLoginResponse))

			self:_qqLoginHandler(openid, openkey)
		end
	end
end

function LoginModule:_doWXLogin()
	print("----------do wx login------------")
	uq.sdkTencentLogin('wx')

	uq.SdkHelper:getInstance():registerScriptHandler(handler(self, self._onWXLoginResponse), 7)
end

function LoginModule:_onWXLoginResponse(ret)
	print("======_onWXLoginResponse=========", ret)
	if not ret then
		uq.TipLayer:createTipLayer(uq.Language.login.error_code[9004]):show()
		return
	end
	ret = string.gsub(ret,"\\/","/")
	local data = json.decode(ret)
	if not data then
		uq.TipLayer:createTipLayer(uq.Language.login.error_code[9004]):show()
		return
	end
	if data.action ~= uq.sdk.CmdString.WXLOGINRESP then
		uq.TipLayer:createTipLayer(uq.Language.login.error_code[9004]):show()
		return
	end
	if data.error_code == "-1" then
		uq.TipLayer:createTipLayer("微信未安装，请安装微信后再登录"):show()
		return
	end

	uq.cache.openid = data.openid
	uq.cache.accessToken = data.access_token
	uq.cache.payToken = data.pay_token
	uq.cache.pf = data.pf
	uq.cache.pfkey = data.pfkey
	
	self._accessToken = data.access_token
	self._openid = data.openid
	cc.UserDefault:getInstance():setStringForKey("WX_OPENID", self._openid)
	cc.UserDefault:getInstance():setStringForKey("WX_OPENKEY", self._accessToken)
	cc.UserDefault:getInstance():setStringForKey("WX_PF", data.pf)
	cc.UserDefault:getInstance():setStringForKey("WX_PFKEY", data.pfkey)
	cc.UserDefault:getInstance():setStringForKey("WX_ACCESS_TOKEN", data.access_token)
	cc.UserDefault:getInstance():setStringForKey("WX_PAY_TOKEN", data.pay_token)
	cc.UserDefault:getInstance():setStringForKey("WX_CALL_SDK_TS", uq.curSecond())

	uq.http_wx_userinfo(self._accessToken, self._openid, function(userData)
		uq.log("wx userinfo:", userData)
		cc.UserDefault:getInstance():setStringForKey("WX_NICK_NAME", userData.nickname)
		cc.UserDefault:getInstance():setStringForKey("WX_SEX", userData.sex)
		cc.UserDefault:getInstance():setStringForKey("WX_HEAD_IMG_URL", userData.headimgurl)
		cc.UserDefault:getInstance():setStringForKey("WX_PROVINCE", userData.province)
		cc.UserDefault:getInstance():setStringForKey("WX_CITY", userData.city)
		cc.UserDefault:getInstance():setStringForKey("WX_COUNTRY", userData.country)

		self:_wxLoginHandler(self._openid, self._accessToken)
	end)

	-- self:_wxLoginHandler(self._openid, self._accessToken)
end

function LoginModule:_doQQLogin()
	print("----------do qq login------------")
	uq.sdkTencentLogin('qq', handler(self, self._onQQLoginResponse))
end

function LoginModule:_onQQLoginResponse(ret)
	print("======_onQQLoginResponse=========", ret)
	if not ret then
		uq.TipLayer:createTipLayer(uq.Language.login.error_code[9004]):show()
		return
	end
	ret = string.gsub(ret,"\\/","/")
	local data = json.decode(ret)
	if not data then
		uq.TipLayer:createTipLayer(uq.Language.login.error_code[9004]):show()
		return
	end
	if data.action ~= uq.sdk.CmdString.QQLOGINRESP then
		uq.TipLayer:createTipLayer(uq.Language.login.error_code[9004]):show()
		return
	end

	uq.cache.openid = data.openid
	uq.cache.accessToken = data.access_token
	uq.cache.payToken = data.pay_token
	uq.cache.pf = data.pf
	uq.cache.pfkey = data.pfkey
		
	self._accessToken = data.access_token
	self._openid = data.openid
	cc.UserDefault:getInstance():setStringForKey("QQ_OPENID", self._openid)
	cc.UserDefault:getInstance():setStringForKey("QQ_OPENKEY", self._accessToken)
	cc.UserDefault:getInstance():setStringForKey("QQ_PF", data.pf)
	cc.UserDefault:getInstance():setStringForKey("QQ_PFKEY", data.pfkey)
	cc.UserDefault:getInstance():setStringForKey("QQ_ACCESS_TOKEN", data.access_token)
	cc.UserDefault:getInstance():setStringForKey("QQ_PAY_TOKEN", data.pay_token)
	cc.UserDefault:getInstance():setStringForKey("QQ_CALL_SDK_TS", uq.curSecond())

	uq.http_qq_userinfo(self._accessToken, self._openid, data.app_id, function(userData)
		uq.log("qq userinfo:", userData)
		cc.UserDefault:getInstance():setStringForKey("QQ_NICK_NAME", userData.nickname)
		cc.UserDefault:getInstance():setStringForKey("QQ_SEX", userData.gender)
		cc.UserDefault:getInstance():setStringForKey("QQ_HEAD_IMG_URL", userData.figureurl_qq_1)

		self:_qqLoginHandler(self._openid, self._accessToken)
	end)

	-- self:_qqLoginHandler(self._openid, self._accessToken)
end

function LoginModule:_onAutoLoginResponse(ret)
	print("======_onTencentAutoLoginResponse=========", ret)
	if not ret then
		return
	end
	ret = string.gsub(ret,"\\/","/")
	local data = json.decode(ret)
	if not data then
		return
	end

	uq.cache.openid = data.openid
	uq.cache.accessToken = data.access_token
	uq.cache.payToken = data.pay_token
	uq.cache.pf = data.pf
	uq.cache.pfkey = data.pfkey

	if self._loginChan == "wx" then
		cc.UserDefault:getInstance():setStringForKey("WX_OPENID", self._openid)
		cc.UserDefault:getInstance():setStringForKey("WX_OPENKEY", self._accessToken)
		cc.UserDefault:getInstance():setStringForKey("WX_PF", data.pf)
		cc.UserDefault:getInstance():setStringForKey("WX_PFKEY", data.pfkey)
		cc.UserDefault:getInstance():setStringForKey("WX_ACCESS_TOKEN", data.access_token)
		cc.UserDefault:getInstance():setStringForKey("WX_PAY_TOKEN", data.pay_token)
	elseif self._loginChan == "qq" then
		self._accessToken = data.access_token
		self._openid = data.openid
		cc.UserDefault:getInstance():setStringForKey("QQ_OPENID", self._openid)
		cc.UserDefault:getInstance():setStringForKey("QQ_OPENKEY", self._accessToken)
		cc.UserDefault:getInstance():setStringForKey("QQ_PF", data.pf)
		cc.UserDefault:getInstance():setStringForKey("QQ_PFKEY", data.pfkey)
		cc.UserDefault:getInstance():setStringForKey("QQ_ACCESS_TOKEN", data.access_token)
		cc.UserDefault:getInstance():setStringForKey("QQ_PAY_TOKEN", data.pay_token)
	end
end

function LoginModule:_verifyTencent(pf, openid, openkey)
	if pf == "wx" then
		uq.http_login_wx(openid, openkey, function(data)
			uq.log("wx login response data:", data)
			if not uq.check_response_data(data) then
				return
			end
			if nil == data or nil == data.data.username then
				if data and data.desc then
					uq.TipLayer:createTipLayer(data.desc):show()
				else
					uq.TipLayer:createTipLayer(uq.Language.login.error_code[9004]):show()
				end
				return
			end
			self._user.username = data.data.username
			self._user.passwd = data.data.passwd

			uq.cache.account.username = data.data.username
			uq.cache.passwd = data.data.passwd
			uq.cache.tencentChannel = "wx"

			self._loginChan = "wx"
			cc.UserDefault:getInstance():setStringForKey("LOGIN_CHAN", self._loginChan)

			self:updateAccountLayer()
			self:updateLayerWhenLoginOK()
		end)
	elseif pf == "qq" then
		uq.http_login_qq(openid, openkey, function(data)
			uq.log("qq login response data:", data)
			if not uq.check_response_data(data) then
				return
			end
			if nil == data or nil == data.data.username then
				if data and data.desc then
					uq.TipLayer:createTipLayer(data.desc):show()
				else
					uq.TipLayer:createTipLayer(uq.Language.login.error_code[9004]):show()
				end
				return
			end
			self._user.username = data.data.username
			self._user.passwd = data.data.passwd

			uq.cache.account.username = data.data.username
			uq.cache.passwd = data.data.passwd
			uq.cache.tencentChannel = "qq"

			self._loginChan = "qq"
			cc.UserDefault:getInstance():setStringForKey("LOGIN_CHAN", self._loginChan)

			self:updateAccountLayer()
			self:updateLayerWhenLoginOK()
		end)
	end
end

function LoginModule:_onSdkHandler(ret)
end

function LoginModule:_wxLoginHandler(openid, openkey)
	if uq.sdk.platform and uq.sdk.platform == "linghou_tencent" then
		self:_verifyTencent("wx", openid, openkey)
	end

	uq.http_broad(function(data)
		uq.log(data)
		if not data then
			return
		end
		if data.code and tonumber(data.code) ~= 0 then
			return
		end
		if data.data and #data.data <= 0 then
			return
		end
		uq.cache.noticeBoardData = data
		uq.ModuleManager:getInstance():show(uq.ModuleManager.NOTICE_BOARD_MODULE,{data=data})
	end)
end

function LoginModule:_qqLoginHandler(openid, openkey)
	if uq.sdk.platform and uq.sdk.platform == "linghou_tencent" then
		self:_verifyTencent("qq", openid, openkey)
	end

	uq.http_broad(function(data)
		uq.log(data)
		if not data then
			return
		end
		if data.code and tonumber(data.code) ~= 0 then
			return
		end
		if data.data and #data.data <= 0 then
			return
		end
		uq.cache.noticeBoardData = data
		uq.ModuleManager:getInstance():show(uq.ModuleManager.NOTICE_BOARD_MODULE,{data=data})
	end)
end

function LoginModule:updateLayerWhenLoginOK()
	local bg_login = self._view:getChildByName("bg_login")
	local btn_notice = self._view:getChildByName("btn_notice")
	local bg_account = self._view:getChildByName("bg_account")
	bg_login:setVisible(true)
	btn_notice:setVisible(true)
	bg_account:setVisible(true)

	local txt_cur_account = self._view:getChildByName('txt_cur_account')
	txt_cur_account:setVisible(true)

	local btn_wx = self._view:getChildByName("btn_login_wx")
	local btn_qq = self._view:getChildByName("btn_login_qq")
	btn_wx:setVisible(false)
	btn_qq:setVisible(false)
end

function LoginModule:dragonAction()
		local bg=cc.Sprite:create("login/lo_4.jpg")
		self._view:addChild(bg,-100)

		local logo = self._view:getChildByName("Image_1")
		logo:setContentSize(cc.size(237, 161))
		logo:setPosition(cc.p(-480, 250))

		local bg_account = self._view:getChildByName("bg_account")
		local btn_notice = self._view:getChildByName("btn_notice")
		bg_account:setVisible(false)
		btn_notice:setVisible(false)

		local Text_tip2=self._view:getChildByName("bg_login"):getChildByName("Text_tip2")
    	Text_tip2:setString(uq.Language.king_storm_ver)
end

function LoginModule:_requestServers()
	if uq.sdk.game_tag == "mx3" then
		uq.sdk.game_tag = "mx2"
	end
	self.servers = {}
	uq.config.servers = {}
	self.servers_count = 0
	uq.http_servers(nil, function(data)
		uq.closeLoading()
		uq.log("server lists:", data)
		if not uq.check_response_data(data) then
			print("===========uq.check_response_data wrong=============")
			return
		end

		self.servers = {}
		uq.config.servers = data.data
		local cur_servers = {}
		for i,v in ipairs(uq.config.servers) do
			if not v.group or tonumber(v.group) <= 0 then
				if not cur_servers[1] then
					cur_servers[1] = {}
				end
				table.insert(cur_servers[1],v)
			else
				if not cur_servers[tonumber(v.group)] then
					cur_servers[tonumber(v.group)] = {}
				end
				table.insert(cur_servers[tonumber(v.group)],v)
			end
		end
		for i,v in ipairs(cur_servers) do
			table.sort( v, function(a,b)
				return tonumber(a.sid) < tonumber(b.sid)
			end )
		end
		table.sort( uq.config.servers, function(a,b)
			local a_server_id = a.server_id
			local a_len = string.len(a_server_id)
			local a_time = string.sub(a_server_id,a_len-2,a_len)

			local b_server_id = b.server_id
			local b_len = string.len(b_server_id)
			local b_time = string.sub(b_server_id,b_len-2,b_len)

			return tonumber(a_time) > tonumber(b_time)
		end )

		for i,v in ipairs(uq.config.servers) do
			local big_type = v.group
			if not big_type or tonumber(big_type) <= 0 then
				big_type = 1
			end
			-- print("========big_type",big_type)
			for n,m in ipairs(cur_servers[tonumber(big_type)]) do
				if v.sid == m.sid then
					v.server_id_index = n
				end
			end
		end
		
		self.servers = uq.config.servers
		self.servers_count = #uq.config.servers
		-- uq.log("------------uq.config.servers",uq.config.servers)
		self:_initServerInfo()
	end)
end

function LoginModule:_initServerInfo()
	self.server_index = cc.UserDefault:getInstance():getStringForKey("LAST_SERVER_INDEX")
	local curServer,serIndex = self:_getServer(self.server_index)
	if not curServer or curServer == "" or curServer.server_name == "" or curServer.address == "" or curServer.port == "" then
		curServer,serIndex = self:_getLastServer()
		if not curServer then
			return
		end
	end

	uq.cache.server = curServer

	local bg_login = self._view:getChildByName("bg_login")
	local txt_server_name = bg_login:getChildByName("txt_server_name")
	local cur_index = self:_judgeStatusIndex(uq.cache.server.state)
	bg_login:getChildByName("img_server_status"):loadTexture("e/e0039_"..cur_index..".png")
	txt_server_name:setString(serIndex..Lang.cur_server.." "..uq.cache.server.server_name)
	txt_server_name:setColor(cc.c3b(255,0,0))

	local user = cc.UserDefault:getInstance():getStringForKey("USER")
	if user ~= "" then
		self._view:getChildByName("txt_cur_account"):setString(Lang.cur_account..user)
	end
end

function LoginModule:_judgeStatusIndex( state )
	local cur_index = 1
	if state == 0 then
		cur_index = 8
	elseif state == 1 then
		cur_index = 5
	elseif state == 2 then
		cur_index = 4
	elseif state == 4 then
		cur_index = 1
	elseif state == 8 then
		cur_index = 6
	elseif state == 64 then
		cur_index = 3
	elseif state == 128 then
		cur_index = 7
	end
	return cur_index
end

function LoginModule:_getLastServer()
	return self.servers[1],self.servers[1].server_id_index
end

function LoginModule:_getServer(sid)
	local _lastIndex = sid
	if not _lastIndex or _lastIndex == "" or tonumber(_lastIndex) <= 0 then
		return nil
	end
	local _bigServerType = math.ceil(tonumber(_lastIndex) / 10000)
	local _serverIndex = tonumber(_lastIndex) % 10000
	for i,v in ipairs(uq.config.servers) do
		local big_type = v.group
		if not big_type or tonumber(big_type) <= 0 then
			big_type = 1
		end
		if tonumber(big_type) == _bigServerType and _serverIndex == v.server_id_index then
			return v,_serverIndex
		end
	end
	return nil
end

function LoginModule:updateAccountLayer()
	if self._loginChan == "wx" then
		local nickName = cc.UserDefault:getInstance():getStringForKey("WX_NICK_NAME")
		self._view:getChildByName("txt_cur_account"):setString(Lang.wx_account..nickName)			
	elseif self._loginChan == "qq" then
		local nickName = cc.UserDefault:getInstance():getStringForKey("QQ_NICK_NAME")
		self._view:getChildByName("txt_cur_account"):setString(Lang.qq_account..nickName)	
	end
end

function LoginModule:_onWxLogin()
	uq.log("-------_onWxLogin")
	self:_doWXLogin()
end

function LoginModule:_onQQLogin()
	uq.log("-------_onQQLogin")
	self:_doQQLogin()
end

function LoginModule:_onSwitchLogin()
	local bg_login = self._view:getChildByName("bg_login")
	local bg_account = self._view:getChildByName("bg_account")
	local btn_notice = self._view:getChildByName("btn_notice")
	bg_login:setVisible(false)
	bg_account:setVisible(false)
	btn_notice:setVisible(false)

	local txt_cur_account = self._view:getChildByName('txt_cur_account')
	txt_cur_account:setVisible(false)

	local btn_wx = self._view:getChildByName("btn_login_wx")
	local btn_qq = self._view:getChildByName("btn_login_qq")
	btn_wx:setVisible(true)
	btn_qq:setVisible(true)



	local btn_enter = bg_login:getChildByName('btn_enter')
	btn_enter:setTouchEnabled(true)
end

function LoginModule:_onShowServers()
	if not self.servers or self.servers_count <= 0 then
		uq.TipLayer:createTipLayer(Lang.no_server):show()
		self:_requestServers()
		return
	end
	uq.ModuleManager:getInstance():show(uq.ModuleManager.LOGIN_SERVER_MODULE)
end

function LoginModule:_onServerSelect(evt)
	uq.cache.server = evt.data.server
	self.server_index = evt.data.index
	local _serverIndex = tonumber(self.server_index) % 10000
	local _bgLogin = self._view:getChildByName("bg_login")
	_bgLogin:getChildByName("txt_server_name"):setString(
		_serverIndex..Lang.cur_server.." "..uq.cache.server.server_name)
	local cur_index = self:_judgeStatusIndex(uq.cache.server.state)
	_bgLogin:getChildByName("img_server_status"):loadTexture("e/e0039_"..cur_index..".png")
end

function LoginModule:_anonymousEnterGame()
	local platform = uq.sdk.platform or tostring(uq.sdk.platform_id)
	local req_str = platform .. uq.cache.server.sid .. uq.config.SOURCE ..uq.config.FCM
	uq.http_guest_signature(uq.cache.server.server_id, req_str, function(data) 
		print("=====http_guest_signature=======")
		uq.log("guest_signature reponse data:", data)
		if data and data.code ~= 0 then
			if data and data.desc then
				uq.TipLayer:createTipLayer(data.desc):show()
			else
				uq.TipLayer:createTipLayer(uq.Language.login.error_code[9004]):show()
			end
			return
		end
		local loginname = data.loginname
		if self._user.username then
			uq.http_bind_account(self._user.username, self._user.passwd, uq.cache.server.server_id, loginname, function(data) 
				print("=====http_bind_account=======")
				uq.log("bind account response data:", data)
				if data and data.code ~= 0 then
					if data and data.desc then
						uq.TipLayer:createTipLayer(data.desc):show()
					else
						uq.TipLayer:createTipLayer(uq.Language.login.error_code[9004]):show()
					end
					return
				end
				self:_enterServer(loginname)
			end)
		else
			self._user.server_sign = data.hash
			self._user.timestamp = data.timestamp
			self._user.loginname = data.loginname
			local address = uq.cache.server.address
			if uq.cache.server.is_walled and tonumber(uq.cache.server.is_walled) == 1 then
				address = uq.cache.server.server_addr
			end
			network:connect(address, uq.cache.server.port, false, uq.cache.server.is_walled)
		end
	end)
end

function LoginModule:_onEnterGame()
	local bg_login = self._view:getChildByName("bg_login")
	local btn_enter = bg_login:getChildByName('btn_enter')
	btn_enter:setTouchEnabled(false)
	
	-- local user = cc.UserDefault:getInstance():getStringForKey("USER")
 -- 	local passwd = cc.UserDefault:getInstance():getStringForKey("PASSWD")
 -- 	if not user or user == "" then
 -- 		self:_onShowLoginAccountPop()
 -- 		-- self:_anonymousEnterGame()
	-- 	btn_enter:setTouchEnabled(true)
 -- 		return
 -- 	end

	if not self.servers or self.servers_count <= 0 then
		uq.showLoading(uq.Language.common.loading)
		self:_requestServers()
		btn_enter:setTouchEnabled(true)
		return
	end
	if not uq.cache.server then
		btn_enter:setTouchEnabled(true)
		return
	end
	if uq.cache.server and uq.cache.server.state >= 64 then
		local welcome = uq.cache.server.welcome
		if welcome and #welcome > 0 then
	        uq.ModuleManager:getInstance():show(uq.ModuleManager.COMMON_POP_MODULE, 
    	    	{title = uq.Language.text[645], btn={{image = "d/d0020.png"}}, content = uq.cache.server.welcome})
	    else
			uq.TipLayer:createTipLayer(uq.Language.login.error_code[9003]):show()
	    end
		btn_enter:setTouchEnabled(true)
		return
	end

	uq.log("---------enter game! username:", self._user.username, ",passwd:", self._user.passwd)
	uq.http_role_list(self._user.username, self._user.passwd, uq.cache.server.server_id, function(data)
		print("=====http_role_list=======")
		uq.log("role list reponse data:", data)
		if data and data.code ~= 0 then
			if data and data.desc then
				uq.TipLayer:createTipLayer(data.desc):show()
			else
				uq.TipLayer:createTipLayer(uq.Language.login.error_code[9004]):show()
			end
			btn_enter:setTouchEnabled(true)
			return
		end
		local roles = data.roles or {}
		if #roles > 0 then
			local role = roles[1]
			self._user.loginname = role.loginname
			self:_enterServer(role.loginname)
		else
			local platform = uq.sdk.platform or tostring(uq.sdk.platform_id)
			local req_str = platform .. uq.cache.server.sid .. uq.config.SOURCE ..uq.config.FCM
			uq.http_guest_signature(uq.cache.server.server_id, req_str, function(data) 
				print("=====http_guest_signature=======")
				uq.log("guest signature response data:", data)
				if data and data.code ~= 0 then
					if data and data.desc then
						uq.TipLayer:createTipLayer(data.desc):show()
					else
						uq.TipLayer:createTipLayer(uq.Language.login.error_code[9004]):show()
					end
					btn_enter:setTouchEnabled(true)
					return
				end
				self._user.loginname = data.loginname
				uq.http_bind_account(self._user.username, self._user.passwd, uq.cache.server.server_id, self._user.loginname, function(data) 
					print("=====http_bind_account=======")
					uq.log("bind account response data:", data)
					if data and data.code ~= 0 then
						if data and data.desc then
							uq.TipLayer:createTipLayer(data.desc):show()
						else
							uq.TipLayer:createTipLayer(uq.Language.login.error_code[9004]):show()
						end
						btn_enter:setTouchEnabled(true)
						return
					end
					self:_enterServer(self._user.loginname)
				end)
			end)
		end
	end)
end

function LoginModule:_enterServer(loginname)
	--重置缓存
	uq.cache.reset()

	local bg_login = self._view:getChildByName("bg_login")
	local btn_enter = bg_login:getChildByName('btn_enter')
	local platform = uq.sdk.platform or tostring(uq.sdk.platform_id)
	local req_str = platform .. uq.cache.server.sid .. uq.config.SOURCE ..uq.config.FCM
	uq.http_server_signatrue(self._user.username, self._user.passwd, uq.cache.server.server_id, loginname, req_str, function(data)
		print("=====http_server_signatrue=======")
		uq.log("server signatrue response data:", data)
		if data and data.code ~= 0 then
			uq.TipLayer:createTipLayer(uq.Language.login.error_code[9004]):show()
			btn_enter:setTouchEnabled(true)
			return
		end
		self._user.server_sign = data.hash
		self._user.timestamp = data.timestamp
		uq.log("------address:", uq.cache.server.address, ",port:", uq.cache.server.port)
		local address = uq.cache.server.address
		if uq.cache.server.is_walled and tonumber(uq.cache.server.is_walled) == 1 then
			address = uq.cache.server.server_addr
		end
		network:connect(address, uq.cache.server.port, false, uq.cache.server.is_walled)
	end)
end

function LoginModule:_onLoginGameServer()
	if not uq.cache.is_connet then
		uq.cache.is_connet = true
		self:loginGameServer()
	end
end

function LoginModule:loginGameServer()
	if not self._user.loginname or #self._user.loginname == 0 then
		uq.log("-----no loginname")
		return
	end

	uq.cache.account.loginname = self._user.loginname
	local data = {login_name = uq.cache.account.loginname, 
				  pf = uq.sdk.platform or tostring(uq.sdk.platform_id),
				  server_zone_id = uq.cache.server.sid,
				  source = tostring(uq.config.SOURCE), 
				  timestamp = self._user.timestamp,
				  fcm = uq.config.FCM,
				  deviceId = uq.SdkHelper:getInstance():getUniqueIdentification(),
				  ip = uq.cache.server.address}
	data.ticket = self._user.server_sign
	loginController.C2SLogin(data);
	cc.UserDefault:getInstance():setStringForKey("LAST_SERVER_INDEX", self.server_index)
end

function LoginModule:dispose()
    services:removeEventListenersByTag('_onServerSelectListListener')
    services:removeEventListenersByTag('_onLoginGameServer')
	LoginModule.super.dispose(self)
end

return LoginModule
