local LoginModule = class("LoginModule", require('app.sdkcommon.LoginModuleCommon'))

function LoginModule:ctor(name, params)
	LoginModule.super.ctor(self, name, params)
end

function LoginModule:onSdkLoginNotify(data)
	print("======_onSdkHandler=========", ret)
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
			-- local pf = uq.sdk.platform or tostring(uq.sdk.platform_id)
			-- uq.http_uqee_report_equipment(deviceId, ip, pf, function(data)
			-- 	uq.log("=====http_uqee_report_equipment=======!", data)
			-- end)
		-- else
			-- local adid = uq.sdk.ad_id or 0
			-- uq.http_uqee_report_register(uq.cache.account.username, deviceId, ip, adid, function(subData)
			-- 	uq.log("=====http_uqee_report_register=======!", subData)
			-- end)
		end
 	end
	self:_getNoticeData(handler(self, self._showNotice))
	uq.TipLayer:createTipLayer(uq.Language.login.error_code[0]):show()
	self:cancelWaitForLogin()
end
function LoginModule:_getNoticeData(callback)
	-- body
	if uq.cache.noticeBoardData then
		if callback then
			callback(uq.cache.noticeBoardData)
			else
			self:_doLogin()
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
function LoginModule:_onEnterGame()
	if self._waitForSdkLogin then
		print("wait for login")
		return 
	end
	-- sdk登录
	if self._user.username == nil then
		-- self:_doLogin()
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
			release_print("=====mul http request=======")
			return
		end

		print("=====http_role_list=======")
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
				print("=====http_guest_signature=======")
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
					print("=====http_bind_account=======")
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
function LoginModule:_enterServer(loginname)
	--重置缓存
	uq.cache.reset()
	local platform = uq.sdk.platform or tostring(uq.sdk.platform_id)
	local req_str = platform .. uq.cache.server.sid .. uq.config.SOURCE ..uq.config.FCM
	uq.http_server_signatrue(self._user.username, self._user.passwd, uq.cache.server.server_id, loginname, req_str, function(data)
		print("=====http_server_signatrue=======")
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

		--appstore 上传登录区服id 通过游奇sdk
		if uq.UqeeSdk then
			local uqsdkNative = uq.UqeeSdk:getInstance()
			local sdkName = uqsdkNative:getSdkName() or ""
			uqsdkNative:uploadLoginServerId(tostring(uq.cache.server.id))
		end
	end)
end

return LoginModule
