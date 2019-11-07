require('app.sdkcommon.initCommon')

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
	elseif ttPf == 'qq' then
	  	p[uq.sdk.Cmd] = uq.sdk.CmdString.QQLOGIN
	else
	  	p[uq.sdk.Cmd] = uq.sdk.CmdString.TENCENTLOGIN
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

function uq.sdkPay(amount, pid, pname, desc, num, callback, gold)
	local server = uq.cache.server
    local role = uq.cache.role 
    if not (role and server) then
    	print("=========role or server  is nil")
    	return
    end
   	if not uq.SdkHelper then
	 	return
	end
    local loginname = uq.cache.account.loginname or "" 
    local username = uq.cache.account.username or ""
	local uri = "/rest/payment/ysdk/get_order_sn"
    local method = "GET"
    local params = {}

    params.game_id = uq.sdk.game_id
    params.platform_id = uq.sdk.platform_id 
    params.server_id = server.server_id or ""
    params.login_name = loginname
    params.role_name = role.name
    params.role_level = role.level
    params.username = username
	params.extra = string.format("%s,%s",pid,role.id)
	params.cash = amount
	params.golden = gold
	if gold == nil or tonumber(gold) == 0 then
		params.golden = tonumber(amount) * 10
	end
    local sign = uq.http_auth(method, uri, params)
    params.role_name = string.urlencode(role.name)
    local paramStr = uq.http_params_str(params)
    local url = string.format("%s%s?%s&sign=%s", uq.sdk.http_addr, uri, paramStr, sign)
    uq.http_request(method, url, nil, function (data)
    	uq.log("=======Pay step 1: get_order_sn! data:", data)
		uq.log(data)
		if data and data.data and data.data.trade_no then
			local role = uq.cache.role
			if not role then
				return
			end

			uq.cache.order = {}
			uq.cache.order.cp_order_id = data.data.trade_no
			uq.cache.order.amt = amount*10
	    	uq.log("=======Pay step 1: get_order_sn! orderSn:", uq.cache.order.cp_order_id)

			local loginname = uq.cache.account.loginname or "" 
			local server = uq.cache.server or {}
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
			
			-- if not callback then
			-- 	callback = function(ret) print("ret==", ret) end
			-- end
			uq.cache.payCallBack = callback

			uq.log("=======Pay step 2: tencent sdk pay")
			local param = json.encode(p)
			uq.SdkHelper:getInstance():runSDKCmd(param, uq.tencentPayResponse)
		else
			uq.TipLayer:createTipLayer(uq.Language.uqsdk.getOrderFail):show()
		end
	end)
end

function uq.tencentPayResponse(ret)
	uq.log("=======Pay step 3: tencent sdk pay response! ret:", ret)
	uq.log("=======Pay! from:", uq.cache.tencentChannel, ",openid:", uq.cache.openid, ",openkey:", uq.cache.payToken, ",pf:", uq.cache.pf,
		",pfkey:", uq.cache.pfkey, ",serverId:", uq.cache.server.id, ",order:", uq.cache.order)
	
	if not ret then
		uq.cache.payCallBack(ret)
		return
	end
	ret = string.gsub(ret,"\\/","/")
	local data = json.decode(ret)
	if not data then
		uq.cache.payCallBack(ret)
		return
	end
	if data.action ~= uq.sdk.CmdString.PAY then
		uq.cache.payCallBack(ret)
		return
	end
	if data.error_code == "-1" then
		uq.cache.payCallBack(ret)
		return
	end
	if data.error_code == "0" then
		uq.cache.accessToken = data.access_token
		uq.cache.payToken = data.pay_token
		uq.cache.pf = data.pf
		uq.cache.pfkey = data.pfkey
	end

	local openkey = uq.cache.payToken
	if uq.cache.tencentChannel == "wx" then
		openkey = uq.cache.accessToken
	end

	uq.http_tencent_pay(uq.cache.tencentChannel, uq.cache.openid, openkey, uq.cache.pf, uq.cache.pfkey, uq.cache.server.sid, uq.cache.order.amt, uq.cache.order.cp_order_id, function(d)
		uq.log("=======Pay step 4: tencent http pay response! d:", d)
		if not uq.check_response_data(d) then
			return
		end
		if nil == d then
			if d and d.desc then
				uq.TipLayer:createTipLayer(d.desc):show()
			else
				uq.TipLayer:createTipLayer(uq.Language.login.error_code[9004]):show()
			end
			return
		end

		uq.cache.payCallBack(ret)
	end)
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

	local function logout()
		if uq.sdkLogout then
			uq.sdkLogout()
		end
	end

	uq.ModuleManager:getInstance():show(uq.ModuleManager.COMMON_POP_MODULE , {title = uq.Language.common.logoutTitle , btn={{image = "d/d0020.png" , cb = logout , close = true} , {image = "d/d0019.png" } } , content = uq.Language.common.logoutContent })
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

