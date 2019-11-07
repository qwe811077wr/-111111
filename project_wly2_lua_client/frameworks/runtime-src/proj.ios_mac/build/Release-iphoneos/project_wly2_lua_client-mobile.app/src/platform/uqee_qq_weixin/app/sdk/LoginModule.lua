local LoginModule = class("LoginModule", require('app.base.ModuleBase'))

local Protocol = require "protocol_base_pb"
local ProtocolLogin = require "protocol_login_pb"
local ProtocolHero = require "protocol_hero_pb"
local loginController = uq.modules.login.LoginController
local Lang = uq.Language.common

local logger = uq.log_console("sdk.LoginModule")
local Lang = uq.Language.common

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
end

function LoginModule:init()
	logger:debug("LoginModule init")
	if uq.sdk.platform == "uqee" and uq.SdkHelper then
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
	if uq.sdk.platform == "uqee" then
		bg_login:setVisible(false)
		local loginNodePosX, loginNodePosY = bg_login:getPosition()

		local btnUqee = ccui.Button:create("c/c0127_1.png", "c/c0127_1.png", "c/c0127_1.png")
	    btnUqee:setName("btn_login_uqee")
	    btnUqee:setPosition(cc.p(loginNodePosX - 250, loginNodePosY))
		btnUqee:setPressedActionEnabled(true)
		btnUqee:setZoomScale(0.02)
	    self._view:addChild(btnUqee)
		btnUqee:addClickEventListenerWithSound(handler(self, self._onShowLoginAccountPop))

		local btnWX = ccui.Button:create("c/c0127_2.png", "c/c0127_2.png", nil)
	    btnWX:setName("btn_login_wx")
	    btnWX:setPosition(cc.p(loginNodePosX, loginNodePosY))
		btnWX:setPressedActionEnabled(true)
		btnWX:setZoomScale(0.02)
	    self._view:addChild(btnWX)
		btnWX:addClickEventListenerWithSound(handler(self, self._onWxLogin))

		local btnQQ = ccui.Button:create("c/c0127_3.png", "c/c0127_3.png", nil)
	    btnQQ:setName("btn_login_qq")
	    btnQQ:setPosition(cc.p(loginNodePosX + 250, loginNodePosY))
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
  	--self:_doLogin()

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
	if uq.sdk.platform == "uqee" then
		self:pushBottomNode(self._view:getChildByName('btn_login_uqee'))
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
		if self._loginChan == "uqee" then
			self:_uqeeLoginHandler()
		elseif self._loginChan == "wx" then
			local uid = cc.UserDefault:getInstance():getStringForKey("WX_UNIONID")
			self:_wxLoginHandler(uid)
		elseif self._loginChan == "qq" then
			--todo
			local openid = cc.UserDefault:getInstance():getStringForKey("QQ_OPENID")
			local openkey = cc.UserDefault:getInstance():getStringForKey("QQ_OPENKEY")
			local pf = cc.UserDefault:getInstance():getStringForKey("QQ_PF")
			self:_qqLoginHandler(openid, openkey, pf)
		else
			return
		end

		-- self:updateLayerWhenLoginOK()
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
	uq.http_wx_access_token(data.app_id, data.app_secret, data.token, function(data)
		print("=====http_wx_access_token=======")
		uq.log("wx access token:", data)
		self._accessToken = data.access_token
		self._unionid = data.unionid
		self._openid = data.openid
		cc.UserDefault:getInstance():setStringForKey("WX_UNIONID", self._unionid)

		uq.http_wx_userinfo(self._accessToken, self._openid, function(userData)
			uq.log("wx userinfo:", userData)
			cc.UserDefault:getInstance():setStringForKey("WX_NICK_NAME", userData.nickname)
			cc.UserDefault:getInstance():setStringForKey("WX_SEX", userData.sex)
			cc.UserDefault:getInstance():setStringForKey("WX_HEAD_IMG_URL", userData.headimgurl)
			cc.UserDefault:getInstance():setStringForKey("WX_PROVINCE", userData.province)
			cc.UserDefault:getInstance():setStringForKey("WX_CITY", userData.city)
			cc.UserDefault:getInstance():setStringForKey("WX_COUNTRY", userData.country)
		end)

		self:_wxLoginHandler(self._unionid)
	end)
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
		
	self._accessToken = data.access_token
	self._openid = data.open_id
	cc.UserDefault:getInstance():setStringForKey("QQ_OPENID", self._openid)
	cc.UserDefault:getInstance():setStringForKey("QQ_OPENKEY", self._accessToken)
	cc.UserDefault:getInstance():setStringForKey("QQ_PF", data.pf)

	uq.http_qq_userinfo(self._accessToken, self._openid, data.app_id, function(userData)
		uq.log("qq userinfo:", userData)
		cc.UserDefault:getInstance():setStringForKey("QQ_NICK_NAME", userData.nickname)
		cc.UserDefault:getInstance():setStringForKey("QQ_SEX", userData.gender)
		cc.UserDefault:getInstance():setStringForKey("QQ_HEAD_IMG_URL", userData.figureurl_qq_1)
	end)

	self:_qqLoginHandler(self._openid, self._accessToken, data.pf)
end

function LoginModule:_onSdkHandler(ret)
end

function LoginModule:uqeeLogin(uid, token, chan)
	uq.cache.account.username = uid
	uq.http_login_uqee(uid, token, function(subData)
		print("=====http_login_uqee=======")
		uq.log("login uqee response data:", subData)
		if not uq.check_response_data(subData) then
			return
		end
		if nil == subData or nil == subData.data.username then
			if subData and subData.desc then
				uq.TipLayer:createTipLayer(subData.desc):show()
			else
				uq.TipLayer:createTipLayer(uq.Language.login.error_code[9004]):show()
			end
			return
		end
		self._user.username = subData.data.username
		self._user.passwd = subData.data.passwd

		uq.cache.passwd = subData.data.passwd
		-- uq.TipLayer:createTipLayer(uq.Language.login.error_code[0]):show()

		self._loginChan = chan or "uqee"
		cc.UserDefault:getInstance():setStringForKey("LOGIN_CHAN", self._loginChan)

		self:updateAccountLayer()
		self:updateLayerWhenLoginOK()

		uq.log("-------user:", self._user)
	end)

	if uq.sdk.platform and uq.SdkHelper then
		local adid = uq.sdk.ad_id or 0
 		local deviceId = uq.SdkHelper:getInstance():getUniqueIdentification()
 		local ip = uq.SdkHelper:getInstance():getIpAddress()
		uq.http_uqee_report_register(uid, deviceId, ip, adid, function(subData)
			uq.log("=====http_uqee_report_register=======!", subData)
		end)
	end
end

function LoginModule:_uqeeLoginHandler(inputUser, inputPasswd)
	local uqeeLogin = false
	local user = inputUser
	local pwd = inputPasswd
	if not user or not pwd then
		user = cc.UserDefault:getInstance():getStringForKey("USER")
		pwd = cc.UserDefault:getInstance():getStringForKey("PASSWD")
	else
		uqeeLogin = true
	end

	if uq.sdk.platform and uq.sdk.platform == "uqee" then
		uq.http_uqee_login(user, uq.Commons:md5(pwd), function(data)
			if uqeeLogin then
				if not data or (data.status and tonumber(data.status) ~= 0) then
					uq.TipLayer:createTipLayer(uq.Language.login.error_code[1009]):show()
					return
				end
			else
				if not uq.check_response_data(data) then
					return
				end
			end
			if nil == data or nil == data.data.uid or nil == data.data.token then
				if data and data.info then
					uq.TipLayer:createTipLayer(data.info):show()
				else
					uq.TipLayer:createTipLayer(uq.Language.login.error_code[9004]):show()
				end
				return
			end

			cc.UserDefault:getInstance():setStringForKey("USER", user)
			cc.UserDefault:getInstance():setStringForKey("PASSWD", pwd)

			uq.log("=========http_uqee_login=====>",data)
			uq.cache.account.username = data.data.uid
			uq.cache.uid = data.data.uid
			self:uqeeLogin(data.data.uid, data.data.token, "uqee")
		end)
	end
end

function LoginModule:_wxLoginHandler(uid)
	local machineId = uq.SdkHelper:getInstance():getUniqueIdentification()
	if not machineId then
		machineId = ""
	end

	if uq.sdk.platform and uq.sdk.platform == "uqee" then
		uq.http_uqee_login_qqwx(uid, "wx", function(data)
			print("=====http_uqee_login_qqwx=======")
			uq.log("login uqee wx response data:", data)
			if not uq.check_response_data(data) then
				return
			end
			if nil == data or nil == data.data.uid or nil == data.data.token then
				if data and data.info then
					uq.TipLayer:createTipLayer(data.info):show()
				else
					uq.TipLayer:createTipLayer(uq.Language.login.error_code[9004]):show()
				end
				return
			end

			uq.cache.account.username = data.data.uid
			self:uqeeLogin(data.data.uid, data.data.token, "wx")
		end)
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

function LoginModule:_qqLoginHandler(openid, openkey, pf)
	if uq.sdk.platform and uq.sdk.platform == "uqee" then
		uq.http_uqee_login_qqwx(openid, "qq", function(data)
			print("=====http_uqee_login_qqwx=======")
			uq.log("login uqee qq response data:", data)
			if not uq.check_response_data(data) then
				return
			end
			if nil == data or nil == data.data.uid or nil == data.data.token then
				if data and data.info then
					uq.TipLayer:createTipLayer(data.info):show()
				else
					uq.TipLayer:createTipLayer(uq.Language.login.error_code[9004]):show()
				end
				return
			end

			uq.cache.account.username = data.data.uid
			self:uqeeLogin(data.data.uid, data.data.token, "qq")
		end)
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
	local btn_uqee = self._view:getChildByName("btn_login_uqee")
	local btn_wx = self._view:getChildByName("btn_login_wx")
	local btn_qq = self._view:getChildByName("btn_login_qq")
	bg_login:setVisible(true)
	btn_uqee:setVisible(false)
	btn_wx:setVisible(false)
	btn_qq:setVisible(false)
end

function LoginModule:dragonAction()
	if not uq.config.GAME_NAME_TAG or uq.config.GAME_NAME_TAG == 0 then
		ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("tx/ui/bn_open21.pvr.ccz", "tx/ui/bn_open21_pvr.plist", "tx/ui/bn_open21.xml")
		local dragonArm = ccs.Armature:create("bn_open21")
		dragonArm:getAnimation():play("_open2",-1,1)
		dragonArm:setAnchorPoint(cc.p(0.5, 0.5))
		dragonArm:getAnimation():setSpeedScale(0.5)
		dragonArm:setPosition(cc.p(0,-10))
		dragonArm:setName("auto_bg")
		self._view:addChild(dragonArm,-1)

		ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("tx/ui/bn_open21_2.pvr.ccz", "tx/ui/bn_open21_2_pvr.plist", "tx/ui/bn_open21_2.xml")
		local dragonArm1 = ccs.Armature:create("bn_open21_2")
		dragonArm1:getAnimation():play("_open1",-1,1)
		dragonArm1:setAnchorPoint(cc.p(0.5, 0.5))
		dragonArm1:getAnimation():setSpeedScale(0.5)
		dragonArm1:setPosition(cc.p(56,-140))
		dragonArm:addChild(dragonArm1,100)
		dragonArm1:setName("arm_bg_2")
		uq.setHighLight(dragonArm1)

		ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("tx/ui/bn_tx_ui10075_1.pvr.ccz", "tx/ui/bn_tx_ui10075_1_pvr.plist", "tx/ui/bn_tx_ui10075_1.xml")
		local dragonArm2 = ccs.Armature:create("bn_tx_ui10075_1")
		dragonArm2:getAnimation():play("_open1",-1,1)
		dragonArm2:setAnchorPoint(cc.p(0.5, 0.5))
		dragonArm2:getAnimation():setSpeedScale(0.4)
		dragonArm2:setPosition(cc.p(-130,100))
		self._view:addChild(dragonArm2,100)
		dragonArm2:setName("arm_bg_3")
		uq.setHighLight(dragonArm2)

	elseif uq.config.GAME_NAME_TAG == 1 then
		ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("tx/ui/wzfb_lo.pvr.ccz", "tx/ui/wzfb_lo_pvr.plist", "tx/ui/wzfb_lo.xml")
		local dragonArm = ccs.Armature:create("wzfb_lo")
		dragonArm:getAnimation():play("_open",-1,1)
		dragonArm:setAnchorPoint(cc.p(0.5, 0.5))
		dragonArm:getAnimation():setSpeedScale(0.5)
		dragonArm:setPosition(cc.p(0,-10))
		dragonArm:setName("auto_bg")
		self._view:addChild(dragonArm,-1)
		local bg=cc.Sprite:create("login/lo_4wz.jpg")
		self._view:addChild(bg,-100)			

		local logo = self._view:getChildByName("Image_1")
		logo:setPosition(cc.p(-420, 230))

		local bg_account = self._view:getChildByName("bg_account")
		local btn_notice = self._view:getChildByName("btn_notice")
		bg_account:setVisible(false)
		btn_notice:setVisible(false)

		local Text_tip2=self._view:getChildByName("bg_login"):getChildByName("Text_tip2")
    	Text_tip2:setString(uq.Language.king_storm_ver)
	end	
	-- local test_img_1 = cc.Sprite:create("login/lo_1.jpg")
	-- test_img_1:setName("auto_bg")
 -- 	self._view:addChild(test_img_1,-1)

 -- 	local logName = nil
 -- 	if uq.sdk.log_flag == 1 then
 -- 		logName = "login/lo_7.png"   ----部落大乱斗
 -- 	else
	--  	logName = "login/lo_8.png"   ----萌新出击
	--  end
	-- local img_log = cc.Sprite:create(logName)
	-- img_log:setName("img_log")
 -- 	img_log:setPosition(cc.p(-480,260))
 -- 	self._view:addChild(img_log)
end

function LoginModule:_requestServers()
	-- self.servers = {}
	-- uq.config.servers = {}
	-- local function func( ... )
	-- 	uq.http_servers(nil, function(data)
	-- 		uq.closeLoading()
	-- 		if not uq.check_response_data(data) then
	-- 			return
	-- 		end
	-- 		table.sort(data.data,function( a,b )
	-- 			return tonumber(a.sid) < tonumber(b.sid)
	-- 		end)
	-- 		for i,v in ipairs(data.data) do
	-- 			self.servers[i] = v
	-- 			uq.config.servers[i] = v
	-- 			self.servers_count = self.servers_count + 1
	-- 		end
	-- 		self:_doLogin()
	-- 		uq.log("------uq.config.servers:",uq.config.servers)
	--   		self:_initServerInfo()
	-- 	end)
	-- end
	-- if uq.sdk.platform_id == 15 then
	-- 	uq.sdk.game_tag = "2mx"
	-- 	uq.http_servers(nil, function(data)
	-- 		uq.closeLoading()
	-- 		if not uq.check_response_data(data) then
	-- 			return
	-- 		end
	-- 		uq.sdk.game_tag = "mx2"
	-- 		table.sort(data.data,function( a,b )
	-- 			return tonumber(a.sid) < tonumber(b.sid)
	-- 		end)
	-- 		for i,v in ipairs(data.data) do
	-- 			self.servers[10000 + i] = v
	-- 			uq.config.servers[10000 + i] = v
	-- 			self.servers_count = self.servers_count + 1
	-- 		end
	-- 		func()
	-- 	end)
	-- 	return
	-- end
	-- func()
----------------=========----------------
	-- self.servers = {}
	-- uq.config.servers = {}
	-- uq.http_servers(nil, function(data)
	-- 	uq.closeLoading()
	-- 	self:_getNoticeData()
	-- 	if not uq.check_response_data(data) then
	-- 		print("===========uq.check_response_data wrong=============")
	-- 		return
	-- 	end

	-- 	for i,v in ipairs(data.data) do
	-- 		if v.group <= 0 then
	-- 			self.servers[tonumber(v.sid)] = v
	-- 			uq.config.servers[tonumber(v.sid)] = v
	-- 		else
	-- 			self.servers[(v.group - 1) * 10000 + v.sid] = v
	-- 			uq.config.servers[(v.group - 1) * 10000 + v.sid] = v
	-- 		end
	-- 		self.servers_count = self.servers_count + 1
	-- 	end
	-- 	uq.log("------uq.config.servers:",uq.config.servers)
	-- 	self:_initServerInfo()
	-- end)
------------======================-------------------
	if uq.sdk.game_tag == "mx3" then
		uq.sdk.game_tag = "mx2"
	end
	self.servers = {}
	uq.config.servers = {}
	self.servers_count = 0
	uq.http_servers(nil, function(data)
		uq.closeLoading()
		if not uq.check_response_data(data) then
			print("===========uq.check_response_data wrong=============")
			return
		end

		-- for i,v in ipairs(data.data) do
		-- 	if not v.group or tonumber(v.group) <= 0 then
		-- 		if not self.servers[1] then
		-- 			self.servers[1] = {}
		-- 		end
		-- 		table.insert(self.servers[1],v)
		-- 	else
		-- 		if not self.servers[tonumber(v.group)] then
		-- 			self.servers[tonumber(v.group)] = {}
		-- 		end
		-- 		table.insert(self.servers[tonumber(v.group)],v)
		-- 	end
		-- 	self.servers_count = self.servers_count + 1
		-- end
		-- for i,v in ipairs(self.servers) do
		-- 	table.sort( v, function(a,b)
		-- 		return tonumber(a.sid) < tonumber(b.sid)
		-- 	end )
		-- end
		-- uq.config.servers = self.servers
		-- uq.log("------uq.config.servers:",uq.config.servers)
		-- self:_initServerInfo()
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
		-- uq.log("---111---cur_servers:",#cur_servers)
		-- uq.log("---222---cur_servers:",cur_servers)
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
	-- local max = 1
	-- local index = 1
	-- for i,v in ipairs(self.servers) do
	-- 	local server_id = v[#v].server_id
	-- 	local len = string.len(server_id)
	-- 	local time = string.sub(server_id,len-2,len)
	-- 	if tonumber(time) > max then
	-- 		max = tonumber(time)
	-- 		index = tonumber(i)
	-- 	end
	-- end
	-- self.server_index = (index - 1) * 10000 + #self.servers[index]
	-- return self.servers[index][#self.servers[index]],#self.servers[index]
	return self.servers[1],self.servers[1].server_id_index
end

function LoginModule:_getServer(sid)
	-- local _lastIndex = sid
	-- if not _lastIndex or _lastIndex == "" or tonumber(_lastIndex) <= 0 then
	-- 	return nil
	-- end
	-- local _bigServerType = math.ceil(tonumber(_lastIndex) / 10000)
	-- local _serverIndex = tonumber(_lastIndex) % 10000
	-- if self.servers[_bigServerType] and self.servers[_bigServerType][_serverIndex] then
	-- 	return self.servers[_bigServerType][_serverIndex],_serverIndex
	-- end
	-- return nil
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
	if self._loginChan == "uqee" then
		local user = cc.UserDefault:getInstance():getStringForKey("USER")
		if user ~= "" then
			self._view:getChildByName("txt_cur_account"):setString(Lang.cur_account..user)
		end
	elseif self._loginChan == "wx" then
		local nickName = cc.UserDefault:getInstance():getStringForKey("WX_NICK_NAME")
		self._view:getChildByName("txt_cur_account"):setString(Lang.wx_account..nickName)			
	else
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

function LoginModule:_onShowLoginAccountPop()
	uq.log("-------_onShowLoginAccountPop")
	uq.ModuleManager:getInstance():show(uq.ModuleManager.SDK_LOGIN_ACCOUNT_POP,{moduleType=2})
end

function LoginModule:_onSwitchLogin()
	local bg_login = self._view:getChildByName("bg_login")
	local btn_uqee = self._view:getChildByName("btn_login_uqee")
	local btn_wx = self._view:getChildByName("btn_login_wx")
	local btn_qq = self._view:getChildByName("btn_login_qq")
	bg_login:setVisible(false)
	btn_uqee:setVisible(true)
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
