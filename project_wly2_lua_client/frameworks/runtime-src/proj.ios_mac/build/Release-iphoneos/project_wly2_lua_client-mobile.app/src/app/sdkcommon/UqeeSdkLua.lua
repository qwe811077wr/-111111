UqeeSdkLua = class("UqeeSdkLua")

UqeeSdkLua.kReturnSuccess = 0
UqeeSdkLua.kReturnFailed = 1
UqeeSdkLua.kReturnCancel = 2
UqeeSdkLua.kReturnUnknow = 3

UqeeSdkLua.kInitEvent = 0
UqeeSdkLua.kLoginEvent = 1
UqeeSdkLua.kLogoutEvent = 2
UqeeSdkLua.kSwitchAccountEvent = 3
UqeeSdkLua.kPayEvent = 4
UqeeSdkLua.kGameExitEvent = 5
UqeeSdkLua.kUpdateEvent = 6
UqeeSdkLua.kCheckOrderEvent = 7
UqeeSdkLua.kShowLoadingEvent = 8
UqeeSdkLua.kHideLoadingEvent = 9

function UqeeSdkLua:ctor()
	-- body
	self._sdkLoginUser = nil
	self._isGameLogin = nil
	self._intervalSchedule= nil
	if uq.UqeeSdk then
		self._uqsdkNative = uq.UqeeSdk:getInstance()
		self._uqsdkNative:registerScriptHandle(handler(self, self._onEventListen))
	end
end

function UqeeSdkLua:startIntervalSchedule(time)
	-- body
	self:stopIntervalSchedule()
	self._intervalSchedule = scheduler.scheduleGlobal(function()
	        self:stopIntervalSchedule()
	    end, time)
end

function UqeeSdkLua:stopIntervalSchedule( ... )
	-- body
	if self._intervalSchedule then
		scheduler.unscheduleGlobal(self._intervalSchedule)
		self._intervalSchedule = nil
	end 
end

-- 设置一个超时时间
function UqeeSdkLua:showLoading(msg, time)
	-- body
	if not self._isGameLogin then
		return
	end
	self:hideLoading()
	uq.showLoading(msg)
	if not time then 
		time = 20
	end
	self._loadingSchedule = scheduler.scheduleGlobal(function()
	        self:hideLoading()
	    end, time)
end

function UqeeSdkLua:hideLoading()
	-- body
	if not self._isGameLogin then
		return
	end
	if self._loadingSchedule then
		scheduler.unscheduleGlobal(self._loadingSchedule)
		self._loadingSchedule = nil
		uq.closeLoading()
	end 
end

function UqeeSdkLua:getDeviceID()
	-- body
	if uq.UqeeNativeExtend.getDeviceID then
		return uq.UqeeNativeExtend:getDeviceID() or ""
	else
		return ""
	end
end

function UqeeSdkLua:initSDK()
	-- body
	self._uqsdkNative:initSDK()
end

function UqeeSdkLua:login()
	-- body
	if self._sdkLoginUser and self._isGameLogin then
		return
	end
	if self._intervalSchedule then
		uq.log("==========- too fast")
		-- uq.TipLayer:createTipLayer(uq.Language.uqsdk.tooFast):show()
		return
	end
	self:startIntervalSchedule(3)
	if self:getInitStatus() == UqeeSdkLua.kReturnSuccess then
		self._uqsdkNative:login()
	else
		self._doLoginKey = true
		self:initSDK()
	end
end

function UqeeSdkLua:logout(param)
	-- body
	self._uqsdkNative:logout(param)
end

function UqeeSdkLua:switchAccount(param)
	-- body
	self._uqsdkNative:switchAccount(param)
end

function UqeeSdkLua:isHasUserCenter()
	-- body
	return self._uqsdkNative:isHasUserCenter()
end

function UqeeSdkLua:gotoUserCenter(param)
	-- body
	self._uqsdkNative:gotoUserCenter(param)
end

function UqeeSdkLua:checkNativeUpdate(param)
	-- body
	self._uqsdkNative:checkNativeUpdate(param)
end

function UqeeSdkLua:pay(amount, pid, pname, desc, num,callback, gold)
	-- body
	local role = uq.cache.role
	if not role then
		return
	end
	local loginname = uq.cache.account.loginname or "" 
	local server = uq.cache.server or {}
	local p = {}
	p["login_name"] 	= loginname
	p["role_id"]    	= role.id
	p["role_name"]  	= role.name
	p["role_level"] 	= role.level
	p["server_uid"] 	= server.id or 0
	p["server_id"]  	= server.sid or 0
	p["amount"]    	= amount
	p["product_id"]	= pid
	p["product_name"]	= pname
	p["product_desc"]	= desc
	p["pay_num"]		= num
	p["pay_url"]		= uq.sdk.pay_url
	
	local param = json.encode(p)
	if param then
		self._uqsdkNative:pay(param)
	end
	
end

function UqeeSdkLua:checkOrder(param)
	-- body
	self._uqsdkNative:checkOrder(param)
end

function UqeeSdkLua:getUserInfo(param)
	-- body
	return self._uqsdkNative:getUserInfo(param)
end

function UqeeSdkLua:setUserData(isLogin)
	-- body
	if not uq.sdk.platform then
		return
	end
	local role = uq.cache.role
	if not role then
		return
	end
	local server = uq.cache.server or {}
	local level = cc.UserDefault:getInstance():getIntegerForKey("kRoleLevel")
	local p = {}
	p["role_id"] 		= role.id
	p["role_name"] 	= role.name
	p["role_level"] 	= role.level
	p["diamond"] 	= role.diamond
	p["vip"] 		= role.vip_lvl
	p["corp_name"]	= role.cropName
	p["server_id"] 	= server.sid or 0
	p["server_name"] 	= (uq.cache.server.sid..uq.Language.common.cur_server.." "..uq.cache.server.server_name) or server.server_name or ""
	p["create_time"] 	= role.create_time or "0"
	p["level_m_time"] = tostring(os.time())
	p["submit_type"]	= "levelup"
	if isLogin then
		p["submit_type"]	= "enterServer"
		if uq.cache.is_new_role == true then
			uq.cache.is_new_role = false
			p["submit_type"]	= "createrole"
		end
	end
	cc.UserDefault:getInstance():setIntegerForKey("kRoleLevel", role.level)
	local param = json.encode(p)
	if param then
		self._uqsdkNative:setUserData(param)
	end
end

function UqeeSdkLua:getSdkName(  )
	-- body
	return self._uqsdkNative:getSdkName()
end


function UqeeSdkLua:getPlatformName()
	-- body
	return self._uqsdkNative:getPlatformName()
end


function UqeeSdkLua:getInitStatus()
	-- body
	return self._uqsdkNative:getInitStatus()
end

-- 针对不同sdk 差异 兼容
function UqeeSdkLua:sdkExtendFunc(param)
	-- body
	self._uqsdkNative:extend(param)
end
--[[
	回调函数
]]
function UqeeSdkLua:_onEventListen( event, ret, param )
	-- body
	if event == UqeeSdkLua.kInitEvent then
		self:_onInitCallback(ret, param)
	elseif event == UqeeSdkLua.kLoginEvent then
		self:_onLoginCallback(ret, param)
	elseif event == UqeeSdkLua.kLogoutEvent then
		self:_onLogoutCallback(ret, param)
	elseif event == UqeeSdkLua.kSwitchAccountEvent then
		self:_onSwitchAccountCallback(ret, param)
	elseif event == UqeeSdkLua.kPayEvent then
		if not self._isGameLogin then
			return
		end
		self:_onPayCallback(ret, param)
	elseif event == UqeeSdkLua.kUpdateEvent then
		self:_onUpdateCallback(ret, param)
	elseif event == UqeeSdkLua.kCheckOrderEvent then
		self:_onCheckOrderCallback(ret, param)
	elseif event == UqeeSdkLua.kShowLoadingEvent then
		self:_onShowLoading(ret, param)
	elseif event == UqeeSdkLua.kHideLoadingEvent then
		self:_onHideLoading(ret, param)
	elseif event == UqeeSdkLua.kExtendEvent then
		self:_onExtendCallback(ret, param)
	end
end

function UqeeSdkLua:_onInitCallback( ret, param )
	-- body
	if self._doLoginKey then
		self:stopIntervalSchedule()
		self._doLoginKey = nil
		if ret == UqeeSdkLua.kReturnSuccess then
			self:login()
		else 
			uq.TipLayer:createTipLayer(uq.Language.uqsdk.initFail):show()
		end
	end
end


function UqeeSdkLua:_onLoginCallback( ret, param )
	-- body
	if ret == UqeeSdkLua.kReturnSuccess then
		self:_verifyLogin(param)
	elseif ret == UqeeSdkLua.kReturnFailed then
		self:stopIntervalSchedule()
		scheduler.performWithDelayGlobal(function (  )
			uq.TipLayer:createTipLayer(uq.Language.uqsdk.loginFailed):show()
		end, 0.5)
	elseif ret == UqeeSdkLua.kReturnCancel then
		self:stopIntervalSchedule()
		-- uq.TipLayer:createTipLayer(uq.Language.uqsdk.cancelLogin):show()
	end
end

function UqeeSdkLua:_onLogoutCallback( ret, param )
	-- body
	self:_notifyLogout(param)
end

function UqeeSdkLua:_onSwitchAccountCallback( ret, param )
	-- body
	self:_notifySwitchAccount(param)
end

function UqeeSdkLua:_onPayCallback( ret, param )
	-- body

end

function UqeeSdkLua:_onUpdateCallback( ret, param )
	-- body
end

function UqeeSdkLua:_onCheckOrderCallback( ret, param )
	-- body
end

function UqeeSdkLua:_onShowLoading(ret, param)
	local str = uq.Language.common.loading
	if param then
		str = param
	end
	self:showLoading(str)
end

function UqeeSdkLua:_onHideLoading(ret, param)
	self:hideLoading()
end

function UqeeSdkLua:_onExtendCallback( ret, param )
	-- body
end

function UqeeSdkLua:sdkEnterMainModuleCallBack( )
	-- body
end


--[[
	登录验证
]]

function UqeeSdkLua:_verifyLogin( param )
	-- body
end

--[[
	表现
]]
function UqeeSdkLua:_notifyLogin(data)
	-- body
	self:stopIntervalSchedule()
	if not uq.check_response_data(data) then
		return
	end

	local loginData = data.data or {}

	if nil == loginData.username then
		if data and data.desc then
			uq.TipLayer:createTipLayer(data.desc):show()
		else
			uq.TipLayer:createTipLayer(uq.Language.login.error_code[9004]):show()
		end
		return
	end

	self._isGameLogin = true
	local loginModule = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.SDK_LOGIN_MODULE)
	if loginModule then
		loginModule:onSdkLoginNotify(loginData)
		uq.log("========loginData.username",loginData.username,loginData.passwd)
		uq.cache.account.username = loginData.username
		uq.cache.passwd = loginData.passwd
		uq.cache.uid = loginData.uid
	end
end


function UqeeSdkLua:_notifySwitchAccount(param)
	-- body
	local paramstr = param
	scheduler.performWithDelayGlobal(function ()
		-- body
		uq.cache.is_connet = false
	    uq.cache.is_login = true
	    network:disconnect()
	    self._isGameLogin = nil

	    local function relogin()
	        if uq.sdk.platform then
		        uq.ModuleManager:getInstance():show(uq.ModuleManager.SDK_LOGIN_MODULE,{moduleType=1})
		        scheduler.performWithDelayGlobal(function ( )
	        	-- body
		        	if paramstr then
			        	self:startIntervalSchedule(3)
			        	self:_verifyLogin(paramstr)
			     	else
			     		self:login()
			        end
	        	end,0.2)
		    else
		        uq.ModuleManager:getInstance():show(uq.ModuleManager.LOGIN_MODULE,{moduleType=1})
		    end
	    end
	    uq.ModuleManager:getInstance():show(uq.ModuleManager.COMMON_POP_MODULE, 
	        {title = uq.Language.uqsdk.switchAccountTitle, btn={{image = "d/d0020.png", cb=relogin, close=true}}, content = uq.Language.uqsdk.switchAccountContent, closeVisible=false, zOrder = 20000})
	end,0.2)
	
end

function UqeeSdkLua:_notifyLogout()
	-- body
	scheduler.performWithDelayGlobal(function ()
		-- body
		uq.cache.is_connet = false
	    uq.cache.is_login = true
	    network:disconnect()
	    self._isGameLogin = nil
	    if uq.sdk.platform then
	    	uq.log("========notify logout! out")
			if uq.sdk.platform == "linghou_tencent" then
				cc.Director:getInstance():endToLua()
				return
			end
	        uq.ModuleManager:getInstance():show(uq.ModuleManager.SDK_LOGIN_MODULE,{moduleType=1})
	    else
	        uq.ModuleManager:getInstance():show(uq.ModuleManager.LOGIN_MODULE,{moduleType=1})
	    end
	end,0.2)

end

return UqeeSdkLua