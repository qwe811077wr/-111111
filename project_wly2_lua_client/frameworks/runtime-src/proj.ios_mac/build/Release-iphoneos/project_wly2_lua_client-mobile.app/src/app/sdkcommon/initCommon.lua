require('app.sdk.SDKConfig')

local uq = cc.exports.uq or {}
local app = cc.Application:getInstance()
local target = app:getTargetPlatform()

local uqeesdk = require('app.sdk.UqeeSdkLuaImp')
local uqeesdkImp = uqeesdk.new()

function uq.sdkLogin(callback)
  	uqeesdkImp:login()
end

function uq.sdkLogout(callback)
 	uqeesdkImp:logout()
end

function uq.submitRole(isLogin)
	uqeesdkImp:setUserData(isLogin)
end

function uq.sdkEnterMainModuleCallBack()
	uqeesdkImp:sdkEnterMainModuleCallBack()
end

function uq.sdkPay(amount, pid, pname, desc, num, callback, gold)
	uqeesdkImp:pay(amount, pid, pname, desc, num, callback, gold)
end

function uq.sdkExit()
	-- if not uq.SdkHelper then
	-- 	return
	-- end

	-- local p = {}
	-- p[uq.sdk.Cmd] = uq.sdk.CmdString.EXIT
	
	-- local param = json.encode(p)
	-- uq.SdkHelper:getInstance():runSDKCmd(param, callback)

	-- uq.SdkHelper:getInstance():exit()
end

function uq.listenerBack(view)

end

function uq.bindPushDevice()
	local type = 2
	if target ~= cc.PLATFORM_OS_ANDROID then
		type = 1
	end
	local appid = "uZ88yxZXzgAVYmjfEpHRz8"
	local server = uq.cache.server or {}
	local serverid = server.server_id
	if not serverid then
		uq.log("必须使用sdk登录才会有serverid")
		return
	end
	local loginname = uq.cache.account.loginname or ""

	if not uq.RemoteNotificationHelp then
		return
	end
	local obj = uq.RemoteNotificationHelp:getInstance()
	if not obj then
		return 
	end

	local token_name = ""
	local clientid = obj:getClientid()
	uq.log("clientid====="..clientid)

	if target ~= cc.PLATFORM_OS_ANDROID then
		uq.log("bindPushDevice for ios")
		token_name = obj:getDeviceToken()
    else
    	uq.log("bindPushDevice for android")
    	token_name = clientid
    end
    uq.log("token_name==="..token_name)
	
	uq.http_bind_push(type,appid,serverid,loginname,token_name,function (data)
		uq.log("data====",data)
	end)
end

function uq.setNewUserGuideCompleteEvent(param1 , param2 )
end

function uq.setEvent( eventType , param )
end
