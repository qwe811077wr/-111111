local LoginModuleCommon = class("LoginModuleCommon", require('app.base.ModuleBase'))

local Protocol = require "protocol_base_pb"
local ProtocolLogin = require "protocol_login_pb"
local ProtocolHero = require "protocol_hero_pb"
local loginController = uq.modules.login.LoginController
local Lang = uq.Language.common

local logger = uq.log_console("sdk.LoginModule")
local Lang = uq.Language.common

function LoginModuleCommon:ctor(name, params)
	LoginModuleCommon.super.ctor(self, name, params)

	self.servers = {}
	self.arm = nil
	self.dragonArm = nil
	self.server_index = 0
	self.servers_count = 0

	self._user = {}
end

function LoginModuleCommon:init()
	logger:debug("LoginModuleCommon init")

	self._view = uq.parseView(cc.CSLoader:createNode("login/LoginModule.csb"))
	self:dragonAction()

	self:autoAdapition()
	self:centerView(self._view)

    uq.config.servers = {}

	local btn_account = self._view:getChildByName('btn_account')
	-- uq.setBtnScaleEvent(btn_account)
	-- btn_account:addClickEventListenerWithSound(handler(self, self._onShowLoginAccountPop))
	local bg_account = self._view:getChildByName('bg_account')
	local txt_cur_account = self._view:getChildByName('txt_cur_account')
	btn_account:setVisible(false)
	bg_account:setVisible(false)
	txt_cur_account:setVisible(false)

	local bg_login = self._view:getChildByName("bg_login")
	local btn_switch_server = bg_login:getChildByName('btn_choose_server')
	btn_switch_server:addClickEventListenerWithSound(handler(self, self._onShowServers))

	local btn_guide_switch = self._view:getChildByName('btn_guide_switch')
	btn_guide_switch:setVisible(false)

	local btn_enter = bg_login:getChildByName('btn_enter')
	uq.setBtnScaleEvent(btn_enter)
	btn_enter:addClickEventListenerWithSound(handler(self, self._onEnterGame))

	local btn_notice = self._view:getChildByName('btn_notice')
	if uq.config.COUNTRY_CODE == uq.config.constant.COUNTRY_CODE.CODE_VIETNAM then
		btn_notice:setVisible(false)
	else
		uq.setBtnScaleEvent(btn_notice)
		btn_notice:addClickEventListenerWithSound(function( )
				if uq.cache.noticeBoardData then
					self:_showNotice(uq.cache.noticeBoardData)
				end
			end)
	end

	self.position = cc.p(self._view:getPositionX(), self._view:getPositionY())
    services:addEventListener("OnServerSelect", handler(self, self._onServerSelect), "_onServerSelectListListener")
    services:addEventListener("OnLoginGameServer", handler(self, self._onLoginGameServer), "_onLoginGameServer")

  	self:_requestServers()
  	self:waitForLogin(1)

	if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
    	self:returnKeyListen()
    end

	if uq.sdk.platform and uq.sdk.platform == "vietnam" then
		local textTip1 = uq.seekNodeByName(self._view , "Text_tip1")
		local textTip2 = uq.seekNodeByName(self._view , "Text_tip2")
		textTip1:setVisible(false)
		textTip2:setVisible(false)
	end
end

function LoginModuleCommon:_showNotice(data)
	-- body
	local noticeModule = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.NOTICE_BOARD_MODULE)
	if self._view and uq.cache.noticeBoardData and not noticeModule then
		uq.ModuleManager:getInstance():show(uq.ModuleManager.NOTICE_BOARD_MODULE,{data=data})
		return
	end
end

function LoginModuleCommon:_getNoticeData(callback)
	-- body
	if uq.cache.noticeBoardData then
		if callback then
			callback(uq.cache.noticeBoardData)
		end
		return
	end
	uq.http_broad(function(data)
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
		if callback then
			callback(uq.cache.noticeBoardData)
		end
		self:_doLogin()
	end)
end


function LoginModuleCommon:autoAdapition()
	self:pushTopNode(self._view:getChildByName('img_log'))
	self:pushTopNode(self._view:getChildByName('bg_account'))
	self:pushTopNode(self._view:getChildByName('btn_account'))
	-- self:pushTopNode(self._view:getChildByName('btn_choose_account'))
	self:pushTopNode(self._view:getChildByName('txt_cur_account'))
	self:pushTopNode(self._view:getChildByName('btn_notice'))

	self:pushMiddleNode(self._view:getChildByName('btn_guide_switch'))
	self:pushBottomNode(self._view:getChildByName('bg_login'))
end

--手机返回键监听
function LoginModuleCommon:returnKeyListen()
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

function LoginModuleCommon:waitForLogin(time)
	-- body
	uq.log("waitForLogin ------------")
	self:cancelWaitForLogin()
	self._waitForSdkLogin = scheduler.scheduleGlobal(function()
			uq.log("sharedScheduler cancel waitForLogin")
	        self:cancelWaitForLogin()
	    end, time)
end

function LoginModuleCommon:cancelWaitForLogin(  )
	-- body
	uq.log("cancelWaitForLogin ------------")
	if self._waitForSdkLogin then
		scheduler.unscheduleGlobal(self._waitForSdkLogin)
		self._waitForSdkLogin = nil
	end
end

function LoginModuleCommon:_doLogin()
	uq.sdkLogin()
end

function LoginModuleCommon:onSdkLoginNotify(data)
	uq.log("======_onSdkHandler=========", ret)
	if not data or not data.username then
		if data and data.desc then
			uq.TipLayer:createTipLayer(data.desc):show()
		else
			uq.TipLayer:createTipLayer(uq.Language.login.error_code[9004]):show()
		end
		self:cancelWaitForLogin()
		return
	end
	self._user.username = data.username
	self._user.passwd = data.passwd
	uq.cache.account.username = data.username
	uq.cache.passwd = data.passwd
	if uq.SdkHelper then
		local deviceId
        if uq.UqeeNativeExtend and uq.UqeeNativeExtend.getDeviceID then
        	deviceId = uq.UqeeNativeExtend:getDeviceID()
        else
        	deviceId = uq.SdkHelper:getInstance():getUniqueIdentification()
       	end
       	if not deviceId or deviceId == "" then
	 		deviceId = "empty"
	 	end
		local ip = uq.SdkHelper:getInstance():getIpAddress()

		if uq.sdk.platform ~= "uqee" then
			local pf = uq.sdk.platform or tostring(uq.sdk.platform_id)
			uq.http_uqee_report_equipment(deviceId, ip, pf, function(data)
				uq.log("=====http_uqee_report_equipment=======!", data)
			end)
		-- else
			-- local adid = uq.sdk.ad_id or 0
			-- uq.http_uqee_report_register(uq.cache.account.username, deviceId, ip, adid, function(subData)
			-- 	uq.log("=====http_uqee_report_register=======!", subData)
			-- end)
		end
 	end
	self:_getNoticeData(handler(self, self._showNotice))
	-- uq.TipLayer:createTipLayer(uq.Language.login.error_code[0]):show()
	self:cancelWaitForLogin()
end

function LoginModuleCommon:dragonAction()
	if uq.config.COUNTRY_CODE == uq.config.constant.COUNTRY_CODE.CODE_CHINA then
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
			if uq.sdk.third_platform ~= "linghou" then
				ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("tx/ui/wzfb_lo.pvr.ccz", "tx/ui/wzfb_lo_pvr.plist", "tx/ui/wzfb_lo.xml")
				local dragonArm = ccs.Armature:create("wzfb_lo")
				dragonArm:getAnimation():play("_open",-1,1)
				dragonArm:setAnchorPoint(cc.p(0.5, 0.5))
				dragonArm:getAnimation():setSpeedScale(0.5)
				dragonArm:setPosition(cc.p(0,-10))
				dragonArm:setName("auto_bg")
				self._view:addChild(dragonArm,-1)
			else
				local bg=cc.Sprite:create("login/lo_4.jpg")
				self._view:addChild(bg,-100)
			end		

			local logo = self._view:getChildByName("Image_1")
			logo:setContentSize(cc.size(237, 161))
			logo:setPosition(cc.p(-480, 250))

			local bg_account = self._view:getChildByName("bg_account")
			local btn_notice = self._view:getChildByName("btn_notice")
			bg_account:setVisible(false)
			btn_notice:setVisible(false)

			local Text_tip2 = self._view:getChildByName("bg_login"):getChildByName("Text_tip2")
    		Text_tip2:setString(uq.Language.king_storm_ver)

    		local login_btn = self._view:getChildByName("bg_login"):getChildByName("btn_enter")
    		login_btn:setContentSize(cc.size(348, 93))
		end
	else
		local test_img_1 = cc.Sprite:create("login/lo_4.jpg")
		test_img_1:setName("auto_bg")
	 	self._view:addChild(test_img_1,-1)

	 	local logo = self._view:getChildByName("Image_1")
	 	logo:setVisible(false)

	 	local sp_icon = cc.Sprite:create("login/lo_8.png")
	 	sp_icon:setPosition(cc.p(-430,260))
	 	self._view:addChild(sp_icon)
	end
end

function LoginModuleCommon:_requestServers()
	-- self.servers = {}
	-- uq.config.servers = {}
	-- local function func( ... )
	-- 	uq.http_servers(nil, function(data)
	-- 		uq.closeLoading()
	-- 		self:_getNoticeData()
	-- 		if not uq.check_response_data(data) then
	-- 			uq.log("===========uq.check_response_data wrong=============")
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
----------================-----------------------
	-- self.servers = {}
	-- uq.config.servers = {}
	-- uq.http_servers(nil, function(data)
	-- 	uq.closeLoading()
	-- 	self:_getNoticeData()
	-- 	if not uq.check_response_data(data) then
	-- 		uq.log("===========uq.check_response_data wrong=============")
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
		self:_getNoticeData()
		if not uq.check_response_data(data) then
			uq.log("===========uq.check_response_data wrong=============")
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
			-- uq.log("========big_type",big_type)
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

function LoginModuleCommon:_initServerInfo()
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
	if uq.config.COUNTRY_CODE == uq.config.constant.COUNTRY_CODE.CODE_VIETNAM then
		txt_server_name:setString("S"..serIndex.." "..uq.cache.server.server_name)
	end
	txt_server_name:setColor(cc.c3b(255,0,0))

	local user = cc.UserDefault:getInstance():getStringForKey("USER")
	if user ~= "" then
		self._view:getChildByName("txt_cur_account"):setString(Lang.cur_account..user)
	end
end

function LoginModuleCommon:_judgeStatusIndex( state )
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

function LoginModuleCommon:_getLastServer()
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
	------------------------
	return self.servers[1],self.servers[1].server_id_index
end

function LoginModuleCommon:_getServer(sid)
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
	--------------------
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

function LoginModuleCommon:updateAccount()
	local user = cc.UserDefault:getInstance():getStringForKey("USER")
	if user ~= "" then
		self._view:getChildByName("txt_cur_account"):setString(Lang.cur_account..user)
	end
end

function LoginModuleCommon:_onShowLoginAccountPop()
	uq.ModuleManager:getInstance():show(uq.ModuleManager.SDK_LOGIN_ACCOUNT_POP,{moduleType=2})
end

function LoginModuleCommon:_onShowServers()
	if not self.servers or self.servers_count <= 0 then
		uq.TipLayer:createTipLayer(Lang.no_server):show()
		self:_requestServers()
		return
	end
	uq.ModuleManager:getInstance():show(uq.ModuleManager.LOGIN_SERVER_MODULE)
end

function LoginModuleCommon:_onServerSelect(evt)
	uq.cache.server = evt.data.server
	self.server_index = evt.data.index
	local _serverIndex = tonumber(self.server_index) % 10000
	local _bgLogin = self._view:getChildByName("bg_login")
	_bgLogin:getChildByName("txt_server_name"):setString(_serverIndex..Lang.cur_server.." "..uq.cache.server.server_name)
	if uq.config.COUNTRY_CODE == uq.config.constant.COUNTRY_CODE.CODE_VIETNAM then
		_bgLogin:getChildByName("txt_server_name"):setString("S".._serverIndex.." "..uq.cache.server.server_name)
	end
	local cur_index = self:_judgeStatusIndex(uq.cache.server.state)
	_bgLogin:getChildByName("img_server_status"):loadTexture("e/e0039_"..cur_index..".png")
end

function LoginModuleCommon:_anonymousEnterGame()
	local platform = uq.sdk.platform or tostring(uq.sdk.platform_id)
	local req_str = platform .. uq.cache.server.sid .. uq.config.SOURCE ..uq.config.FCM
	uq.http_guest_signature(uq.cache.server.server_id, req_str, function(data) 
		uq.log("=====http_guest_signature=======")
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
				uq.log("=====http_bind_account=======")
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

function LoginModuleCommon:_onEnterGame()
	if self._waitForSdkLogin then
		uq.log("wait for login")
		return 
	end
	-- sdk登录
	if self._user.username == nil then
		self:_doLogin()
		return
	end

	if not self.servers or self.servers_count <= 0 then
		uq.showLoading(uq.Language.common.loading)
		self:_requestServers()
		return
	end
	if not uq.cache.server then
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
		return
	end

	local user = self._user.username
	local passwd = self._user.passwd
	-- self._user.username = user
	-- self._user.passwd = passwd

	self:waitForLogin(3)
	if not self._clickID then
		self._clickID = 0
	end
	local clickID = self._clickID

	uq.http_role_list(user, passwd, uq.cache.server.server_id, function(data)

		if clickID ~= self._clickID then
			release_uq.log("=====mul http request=======")
			return
		end

		uq.log("=====http_role_list=======")
		uq.log("role list reponse data:", data)
		if data and data.code ~= 0 then
			if data and data.desc then
				uq.TipLayer:createTipLayer(data.desc):show()
			else
				uq.TipLayer:createTipLayer(uq.Language.login.error_code[9004]):show()
			end
			self:cancelWaitForLogin()
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
				uq.log("=====http_guest_signature=======")
				uq.log("guest signature response data:", data)
				if data and data.code ~= 0 then
					if data and data.desc then
						uq.TipLayer:createTipLayer(data.desc):show()
					else
						uq.TipLayer:createTipLayer(uq.Language.login.error_code[9004]):show()
					end
					self:cancelWaitForLogin()
					return
				end
				self._user.loginname = data.loginname
				uq.http_bind_account(self._user.username, self._user.passwd, uq.cache.server.server_id, self._user.loginname, function(data) 
					uq.log("=====http_bind_account=======")
					uq.log("bind account response data:", data)
					if data and data.code ~= 0 then
						if data and data.desc then
							uq.TipLayer:createTipLayer(data.desc):show()
						else
							uq.TipLayer:createTipLayer(uq.Language.login.error_code[9004]):show()
						end
						self:cancelWaitForLogin()
						return
					end
					self:_enterServer(self._user.loginname)
				end)
			end)
		end
	end)
end

function LoginModuleCommon:_enterServer(loginname)
	--重置缓存
	uq.cache.reset()
	local platform = uq.sdk.platform or tostring(uq.sdk.platform_id)
	local req_str = platform .. uq.cache.server.sid .. uq.config.SOURCE ..uq.config.FCM
	uq.http_server_signatrue(self._user.username, self._user.passwd, uq.cache.server.server_id, loginname, req_str, function(data)
		uq.log("=====http_server_signatrue=======")
		uq.log("server signatrue response data:", data)
		if data and data.code ~= 0 then
			uq.TipLayer:createTipLayer(uq.Language.login.error_code[9004]):show()
			self:cancelWaitForLogin()
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

function LoginModuleCommon:_onLoginGameServer()
	if not uq.cache.is_connet then
		uq.cache.is_connet = true
		self:loginGameServer()
	end
end

function LoginModuleCommon:loginGameServer()
	if not self._user.loginname or #self._user.loginname == 0 then
		uq.log("-----no loginname")
		return
	end
	local deviceId = "null"
    if uq.UqeeNativeExtend and uq.UqeeNativeExtend.getDeviceID then
      	deviceId = uq.UqeeNativeExtend:getDeviceID()
    else
      	deviceId = uq.SdkHelper:getInstance():getUniqueIdentification()
   	end

	uq.cache.account.loginname = self._user.loginname
	local data = {login_name = uq.cache.account.loginname, 
				  pf = uq.sdk.platform or tostring(uq.sdk.platform_id),
				  server_zone_id = uq.cache.server.sid,
				  source = tostring(uq.config.SOURCE), 
				  timestamp = self._user.timestamp,
				  fcm = uq.config.FCM,
				  deviceId = deviceId,
				  ip = uq.cache.server.address}
	data.ticket = self._user.server_sign
	loginController.C2SLogin(data);
	cc.UserDefault:getInstance():setStringForKey("LAST_SERVER_INDEX", self.server_index)
end

function LoginModuleCommon:dispose()
    services:removeEventListenersByTag('_onServerSelectListListener')
    services:removeEventListenersByTag('_onLoginGameServer')
	LoginModuleCommon.super.dispose(self)
end

return LoginModuleCommon
