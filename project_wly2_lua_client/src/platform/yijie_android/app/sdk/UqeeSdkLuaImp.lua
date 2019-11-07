local UqeeSdkLua = require("app.sdkcommon.UqeeSdkLua")
local UqeeSdkLuaImp = class("UqeeSdkLua", UqeeSdkLua)

function UqeeSdkLuaImp:ctor(  )
	-- body
	UqeeSdkLuaImp.super.ctor(self)
end

function UqeeSdkLuaImp:_sendLoginVerifyRequest(channelId, appId, userId, token, deviceID)
	-- body
	local uri = "/rest/partner/yijie/mengxin/login"
	local method = "GET"
	local params = {}
	params.sdk = channelId
	params.app = appId
	params.uin = userId
	params.sess = token
	params.machine_id = deviceID
	local sign = uq.http_auth(method, uri ,params)
	local paramStr = uq.http_params_str(params)
	local url = string.format("%s%s?%s&sign=%s", uq.sdk.http_addr, uri, paramStr, sign)
	uq.http_request(method, url, nil, function (data)
		self:_notifyLogin(data)
	end)
end

function UqeeSdkLuaImp:_verifyLogin( param )
	-- body
	if not param then
		return 
	end
	param = string.gsub(param,"\\/","/")
	local data = json.decode(param)
	if not data then
		return 
	end

	local userId = data.userId or ""
	if self._sdkLoginUser and self._isGameLogin then
		if self._sdkLoginUser ~= userId then
			release_print("is not same user and cur user exist switch account")
			self:_notifySwitchAccount(param)
			return 
		else 
			release_print("is same user not need login")
			return
		end
	end

	local channelId = data.channelId or ""

	if string.find(channelId, "{") then
		channelId = string.sub(channelId, 2, -2)
		channelId = string.gsub(channelId, "-", "")
		uq.sdk.platform = channelId
	else
		uq.sdk.platform = data.channelId
	end

	local appId = data.appId or ""
	if string.find(appId, "{") then
		appId = string.sub(appId, 2, -2)
		appId = string.gsub(appId, "-", "")
	end

	self._sdkLoginUser = userId
	local deviceID = self:getDeviceID()
	self:_sendLoginVerifyRequest(uq.sdk.platform, appId, data.userId, data.token, deviceID)
	return
end

return UqeeSdkLuaImp;