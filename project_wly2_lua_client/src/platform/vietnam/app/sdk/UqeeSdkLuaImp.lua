local UqeeSdkLua = require("app.sdkcommon.UqeeSdkLua")
local UqeeSdkLuaImp = class("UqeeSdkLua", UqeeSdkLua)

function UqeeSdkLuaImp:ctor(  )
	-- body
	UqeeSdkLuaImp.super.ctor(self)
end

function UqeeSdkLuaImp:_sendLoginVerifyRequest(username, token )
	-- body
	local uri = "/rest/partner/vegaid/mengxin/login"
    local method = "GET"
    local params = {}
    params.username = username
    params.access_token = token 
    params.machine_id = self:getDeviceID()
    
    -- params.timestamp = os.time()
    local sign = uq.http_auth(method, uri, params)
    local paramStr = uq.http_params_str(params)
    local url = string.format("%s%s?%s&sign=%s", uq.sdk.http_addr, uri, paramStr, sign)

    -- print("------------1-1-------:  ", url)
    print("======22=========--2---:",string.urlencode(url))

    uq.http_request(method, url, nil, function (data)
		self:_notifyLogin(data)
	end)

end

function UqeeSdkLuaImp:_verifyLogin( param )
	-- body
	if not param or param == "" then
		return 
	end
	print("--------------",param)
	param = string.gsub(param,"\\/","/")
	local data = json.decode(param)
	if not (data and data.username and data.token) then
		return 
	end
	self:_sendLoginVerifyRequest(data.username, data.token)
end


-- function UqeeSdkLuaImp:_getOrderNum(amount, pid, pname, desc, num)
-- 	-- body
-- 	local server = uq.cache.server
--     local role = uq.cache.role 
--     if not (role and server) then
--     	print("=========role or server  is nil")
--     	return
--     end
--     local loginname = uq.cache.account.loginname or "" 
-- 	local uri = "/rest/payment/vegaid/get_order_sn"
--     local method = "GET"
--     local params = {}

--     params.game_id = uq.sdk.game_id
--     params.platform_id = uq.sdk.platform_id 
--     params.server_id = server.sid
--     params.login_name = loginname
--     params.role_name = role.name
--     params.role_level = role.level
-- 	params.extra = string.format("%s,%s",pid,role.id)
-- 	params.cash = amount
-- 	params.golden = 60
--     -- params.timestamp = os.time()

--     local sign = uq.http_auth(method, uri, params)
--     local paramStr = uq.http_params_str(params)
--     local url = string.format("%s%s?%s&sign=%s", "http://g.api.uqeegame.com", uri, paramStr, sign)
--     -- print("------------1-1-----------:  ", url)
--      print("======22=========--2---:",string.urlencode(url))

--     uq.http_request(method, url, nil, function (data)
-- 		self:_notifyLogin(data)
-- 	end)

-- end

function UqeeSdkLuaImp:pay(amount, pid, pname, desc, num,callback, gold)

	local server = uq.cache.server
    local role = uq.cache.role 
    if not (role and server) then
    	print("=========role or server  is nil")
    	return
    end
    local loginname = uq.cache.account.loginname or "" 
    local username = uq.cache.account.username or ""
	local uri = "/rest/payment/vegaid/get_order_sn"
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
    -- params.timestamp = os.time()
    local sign = uq.http_auth(method, uri, params)

    params.role_name = string.urlencode(role.name)
    local paramStr = uq.http_params_str(params)
    local url = string.format("%s%s?%s&sign=%s", uq.sdk.http_addr, uri, paramStr, sign)
    print("------------1-1-----------:  ", url)
    uq.http_request(method, url, nil, function (data)
    	print("==============================11==================")
		uq.log(data)
		if data and data.data and data.data.trade_no then
			local role = uq.cache.role
			if not role then
				return
			end
			local loginname = uq.cache.account.loginname or "" 
			local server = uq.cache.server or {}
			local p = {}
			p["login_name"] 	= loginname
			p["role_id"]    	= data.data.trade_no
			p["role_name"]  	= role.name
			p["role_level"] 	= role.level
			p["server_uid"] 	= server.id or 0
			p["server_id"]  	= server.id or 0
			p["amount"]    	= amount
			p["product_id"]	= pid
			p["product_name"]	= pname
			p["product_desc"]	= desc
			p["pay_num"]		= num
			p["pay_url"]		= uq.sdk.pay_url
			p["cpOrderNUmber"]		= data.data.trade_no
			
			local param = json.encode(p)
			print("==============================22==================",param)
			if param then
				self._uqsdkNative:pay(param)
			end
		else
			uq.TipLayer:createTipLayer(uq.Language.uqsdk.getOrderFail):show()
		end
	end)



	-- body
	-- local role = uq.cache.role
	-- if not role then
	-- 	return
	-- end
	-- local loginname = uq.cache.account.loginname or "" 
	-- local server = uq.cache.server or {}
	-- local p = {}

	-- p["login_name"] 	= loginname
	-- p["role_id"]    	= role.id
	-- p["role_name"]  	= role.name
	-- p["role_level"] 	= role.level
	-- p["server_uid"] 	= server.id or 0
	-- p["server_id"]  	= server.sid or 0
	-- p["amount"]    	= amount
	-- p["product_id"]	= pid
	-- p["product_name"]	= pname
	-- p["product_desc"]	= desc
	-- p["pay_num"]		= num
	-- p["pay_url"]		= uq.sdk.pay_url

	-- local param = json.encode(p)
	-- if param then
	-- 	self._uqsdkNative:pay(param)
	-- end
	
end

return UqeeSdkLuaImp