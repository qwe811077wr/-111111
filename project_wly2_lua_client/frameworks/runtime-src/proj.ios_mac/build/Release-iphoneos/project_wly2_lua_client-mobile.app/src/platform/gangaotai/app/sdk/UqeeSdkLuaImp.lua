local UqeeSdkLua = require("app.sdkcommon.UqeeSdkLua")
local UqeeSdkLuaImp = class("UqeeSdkLuaImp", UqeeSdkLua)

function UqeeSdkLuaImp:ctor(  )
	-- body
	UqeeSdkLuaImp.super.ctor(self)
	self._productIDs = {
		-- ["9999"] = {"com.wzlm.tw.1013",1 , "99.99"},
		-- ["4999"] = {"com.wzlm.tw.1012",2 , "49.99"},
		-- ["2999"] = {"com.wzlm.tw.1011",3 , "29.99"},
		-- ["1499"] = {"com.wzlm.tw.1010",4 , "14.99"},
		-- ["999"] = {"com.wzlm.tw.1009",5 , "9.99"},
		-- ["499"] = {"com.wzlm.tw.1008",6 , "4.99"},
		-- ["99"] = {"com.wzlm.tw.1007",7 , "0.99"},
		-- ["16"] = {"com.wzlm.tw.1001", 20 , "0.16"},
		-- ["127"] = {"com.wzlm.tw.1002", 21 , "1.27"},
		-- ["599"] = {"com.wzlm.tw.1003", 22 , "5.99"},
		-- ["1599"] = {"com.wzlm.tw.1004", 23 , "15.99"},
		-- ["4799"] = {"com.wzlm.tw.1005", 24 , "47.99"},
		-- ["9499"] = {"com.wzlm.tw.1006", 25 , "94.99"},
		-- ["1048"] = {"com.uqee.mxcj.bag_26", 26},
		-- ["899"] = {"com.wzlm.tw.1016", 31 , "8.99"},
		-- ["1399"] = {"com.wzlm.tw.1017", 32 , "13.99"},
		["299"] = {"com.wyx.tw.1002", 21 , "2.99"},
		["599"] = {"com.wyx.tw.1003", 22 , "5.99"},
		["1599"] = {"com.wyx.tw.1004", 23 , "15.99"},
		["4799"] = {"com.wyx.tw.1005", 24 , "47.99"},
		["9499"] = {"com.wyx.tw.1006", 25 , "94.99"},
		["15999"] = {"com.wyx.tw.1007", 26 , "159.99"},
		["99"] = {"com.wyx.tw.1008", 7 , "0.99"},
		["499"] = {"com.wyx.tw.1009", 6 , "4.99"},
		["999"] = {"com.wyx.tw.1010", 5 , "9.99"},
		["1499"] = {"com.wyx.tw.1011", 4 , "14.99"},
		["2999"] = {"com.wyx.tw.1012", 3 , "29.99"},
		["4999"] = {"com.wyx.tw.1013", 2 , "49.99"},
		["9999"] = {"com.wyx.tw.1014", 1 , "99.99"},
		["899"] = {"com.wyx.tw.1017", 33 , "8.99"},
		["1399"] = {"com.wyx.tw.1018", 34 , "13.99"},
		["199"] = {"com.wyx.tw.1019", 10 , "1.99"},
		["399"] = {"com.wyx.tw.1020", 11 , "3.99"},
		["699"] = {"com.wyx.tw.1021", 12 , "6.99"},
		["1099"] = {"com.wyx.tw.1022", 13 , "10.99"},
		["1799"] = {"com.wyx.tw.1023", 14 , "17.99"},
		["2699"] = {"com.wyx.tw.1024", 15 , "26.99"},
		["3999"] = {"com.wyx.tw.1025", 16 , "39.99"},
		["5499"] = {"com.wyx.tw.1026", 17 , "54.99"},
		["6999"] = {"com.wyx.tw.1027", 18 , "69.99"},
		["799"] = {"com.wyx.tw.1028", 35 , "7.99"},
		["1199"] = {"com.wyx.tw.1029", 36 , "11.99"},
		["1299"] = {"com.wyx.tw.1030", 37 , "12.99"},
		["1699"] = {"com.wyx.tw.1031", 38 , "16.99"},
		["1999"] = {"com.wyx.tw.1032", 39 , "19.99"},
		["2199"] = {"com.wyx.tw.1033", 40 , "21.99"},
		["2599"] = {"com.wyx.tw.1034", 41 , "25.99"},
		["2799"] = {"com.wyx.tw.1035", 42 , "27.99"},
		["3099"] = {"com.wyx.tw.1036", 43 , "30.99"},
		["3199"] = {"com.wyx.tw.1037", 44 , "31.99"},
		["3799"] = {"com.wyx.tw.1038", 45 , "37.99"},
		["4199"] = {"com.wyx.tw.1039", 46 , "41.99"},
		["4599"] = {"com.wyx.tw.1040", 47 , "45.99"},
		["4899"] = {"com.wyx.tw.1041", 48 , "48.99"},
		["5999"] = {"com.wyx.tw.1042", 49 , "59.99"},
		["7499"] = {"com.wyx.tw.1043", 50 , "74.99"},
		["8499"] = {"com.wyx.tw.1044", 51 , "84.99"},
		["8999"] = {"com.wyx.tw.1045", 52 , "89.99"},
	}
end

function UqeeSdkLuaImp:getAmountbyProductID( ProductID )
	-- body
	for k, v in pairs(self._productIDs) do
		if v[1] == ProductID then
			return tonumber(k), v[2]
		end
	end
	return 0
end

function UqeeSdkLua:getProductIDByAmount( amount )
	-- body
	local v = self._productIDs[tostring(amount)]
	if v then
		return v[1] , v[3]
	end
	return ""
end

function UqeeSdkLua:pay(amount, pid, pname, desc, num,callback, gold)
	local realAmount , price = self:getProductIDByAmount(amount)
	local server = uq.cache.server
    local role = uq.cache.role 
    if not (role and server) then
    	print("=========role or server  is nil")
    	return
    end
    local loginname = uq.cache.account.loginname or "" 
    local username = uq.cache.account.username or ""
	local uri = "/rest/payment/morefun/get_order_sn"
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
			p["amount"]    	= realAmount
			p["product_id"]	= pid
			p["product_name"]	= pname
			p["product_desc"]	= desc
			p["pay_num"]		= num
			p["pay_url"]		= uq.sdk.pay_url
			p["cpOrderNUmber"]		= data.data.trade_no
			p["price"]		= price
			
			local param = json.encode(p)
			print("==============================22==================",param)
			if param then
				self._uqsdkNative:pay(param)
			end
		else
			uq.TipLayer:createTipLayer(uq.Language.uqsdk.getOrderFail):show()
		end
	end)
end

function UqeeSdkLuaImp:_sendLoginVerifyRequest(uid, token )
	-- body
	local uri = "/rest/partner/morefun/mengxin/login"
    local method = "GET"
    local params = {}
    params.uid = uid -- already is md5
    params.timestamp = os.time()
    --params.machine_id = self:getDeviceID()

    local sign = uq.http_auth(method, uri, params)
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
	local data = json.decode(param)
	if not (data and data.username and data.token) then
		return 
	end
	self:_sendLoginVerifyRequest(data.uuid, data.token)
end

return UqeeSdkLuaImp;