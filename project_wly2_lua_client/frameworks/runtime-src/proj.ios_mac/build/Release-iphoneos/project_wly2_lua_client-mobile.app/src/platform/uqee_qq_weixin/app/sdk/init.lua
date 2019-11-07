require('app.sdk.SDKConfig')

local uq = cc.exports.uq or {}
local app = cc.Application:getInstance()
local target = app:getTargetPlatform()

function uq.sdkLogin(callback)
	if not uq.SdkHelper then
		return
	end
	local p = {}
  	p[uq.sdk.Cmd] = uq.sdk.CmdString.LOGIN
	local param = json.encode(p)
  	uq.SdkHelper:getInstance():runSDKCmd(param, callback)
  	uq.log("-----------sdk login")
end

function uq.sdkLogout(callback)
	if not uq.SdkHelper then
		return
	end
	local p = {}
  	p[uq.sdk.Cmd] = uq.sdk.CmdString.LOGOUT
	local param = json.encode(p)
  	uq.SdkHelper:getInstance():runSDKCmd(param, callback)
end

function uq.sdkTencentLogin(ttPf, callback)
	if not uq.SdkHelper then
		return
	end
	local p = {}
	if ttPf == 'wx' then
	  	p[uq.sdk.Cmd] = uq.sdk.CmdString.WXLOGIN
	else
	  	p[uq.sdk.Cmd] = uq.sdk.CmdString.QQLOGIN
	end
	local param = json.encode(p)
  	uq.SdkHelper:getInstance():runSDKCmd(param, callback)
  	uq.log("-----------sdk tencent login")
end

function uq.submitRole(isLogin)
	uq.submitRoleForYijie(isLogin)
end

function uq.submitRoleForYijie(isLogin)
	if not uq.sdk.platform then
		return
	end
	if not uq.SdkHelper then
		return
	end
	local role = uq.cache.role
	if not role then
		return
	end
	local server = uq.cache.server or {}
	local level = cc.UserDefault:getInstance():getIntegerForKey("kRoleLevel")

	local p = {}
	p[uq.sdk.Cmd] = uq.sdk.CmdString.SUBMITDATA
	p[uq.sdk.Param.RoleId] 		= role.id
	p[uq.sdk.Param.RoleName] 	= role.name
	p[uq.sdk.Param.RoleLevel] 	= role.level
	p[uq.sdk.Param.Diamond] 	= role.diamond
	p[uq.sdk.Param.Vip] 		= role.vip_lvl
	p[uq.sdk.Param.CorpName]	= role.cropName
	p[uq.sdk.Param.ServerId] 	= server.sid or 0
	p[uq.sdk.Param.ServerName] 	= (uq.cache.server.sid..uq.Language.common.cur_server.." "..uq.cache.server.server_name) or server.server_name or ""
	p[uq.sdk.Param.CreateTime] 	= role.create_time or "0"
	p[uq.sdk.Param.LevelMTime] = tostring(os.time())
	p[uq.sdk.Param.SubmitType]	= "levelup"
	if isLogin then
		p[uq.sdk.Param.SubmitType]	= "enterServer"
		if uq.cache.is_new_role == true then
			uq.cache.is_new_role = false
			p[uq.sdk.Param.SubmitType]	= "createrole"
		end
	end
	if not uq.SdkHelper then
		return
	end
	local param = json.encode(p)
  	uq.SdkHelper:getInstance():runSDKCmd(param, function(ret)
  		print("submit role ret==", ret)
  	end)
  	cc.UserDefault:getInstance():setIntegerForKey("kRoleLevel", role.level)

  	uq.log("SUBMIT ROLE DATA : " , p)
end

function uq.sdkPay(amount, pid, pname, desc, num, callback)
	if uq.sdk.platform and uq.sdk.platform == "uqee" then
		uq.sdkUqeePay(amount, pid, pname, desc, num)
		return
	end

	if not uq.SdkHelper then
	 	return
	end
	local role = uq.cache.role
	if not role then
		return
	end
	local server = uq.cache.server or {}

	local loginname = uq.cache.account.loginname or "" 
	local p = {}
	p[uq.sdk.Cmd] = uq.sdk.CmdString.PAY
	p[uq.sdk.Param.LoginName] 	= loginname
	p[uq.sdk.Param.RoleId]    	= role.id
	p[uq.sdk.Param.RoleName]  	= role.name
	p[uq.sdk.Param.RoleLevel] 	= role.level
	p[uq.sdk.Param.ServerUId] 	= server.id or 0
	p[uq.sdk.Param.ServerId]  	= server.sid or 0
	p[uq.sdk.Param.Amount]    	= amount
	p[uq.sdk.Param.ProductId]	= pid
	p[uq.sdk.Param.ProductName]	= pname
	p[uq.sdk.Param.ProductDesc]	= desc
	p[uq.sdk.Param.PayNum]		= num
	p[uq.sdk.Param.PayUrl]		= uq.sdk.pay_url

	if not callback then
		callback = function(ret) print("ret==", ret) end
	end

	local param = json.encode(p)
	uq.SdkHelper:getInstance():runSDKCmd(param, callback)
end

function uq.sdkUqeePay(amount, pid, pname, desc, num)
	if not uq.SdkHelper then
	 	return
	end
	local url = uq.uqee_pay_url(amount, pid, pname, num)
	if not url then
		return
	end
	local p = {}
	p[uq.sdk.Cmd] = uq.sdk.CmdString.UQEEPAY
	p[uq.sdk.Param.Url] 	= url

	if not callback then
		callback = function(ret) print("ret==", ret) end
	end

	local param = json.encode(p)
	uq.SdkHelper:getInstance():runSDKCmd(param, callback)
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
		print("必须使用sdk登录才会有serverid")
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
	print("clientid====="..clientid)

	if target ~= cc.PLATFORM_OS_ANDROID then
		print("bindPushDevice for ios")
		token_name = obj:getDeviceToken()
    else
    	print("bindPushDevice for android")
    	token_name = clientid
    end
    print("token_name==="..token_name)
	
	uq.http_bind_push(type,appid,serverid,loginname,token_name,function (data)
		uq.log("data====",data)
	end)
end

