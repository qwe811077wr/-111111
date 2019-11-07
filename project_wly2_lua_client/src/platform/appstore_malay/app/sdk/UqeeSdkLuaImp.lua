local UqeeSdkLua = require("app.sdkcommon.UqeeSdkLua")
local UqeeSdkLuaImp = class("UqeeSdkLuaImp", UqeeSdkLua)

function UqeeSdkLuaImp:ctor(  )
	-- body
	UqeeSdkLuaImp.super.ctor(self)
	self._productIDs = {
		["648"] = {"com.youqi.mx.golds_1",1},
		["328"] = {"com.youqi.mx.golds_2",2},
		["198"] = {"com.youqi.mx.golds_3",3},
		["98"] = {"com.youqi.mx.golds_4",4},
		["68"] = {"com.youqi.mx.golds_5",5},
		["30"] = {"com.youqi.mx.golds_6",6},
		["6"] = {"com.youqi.mx.golds_7",7},
		["1"] = {"com.youqi.mx.golds_10", 20},
		["8"] = {"com.youqi.mx.bag_21", 21},
		["40"] = {"com.youqi.mx.bag_22", 22},
		["108"] = {"com.youqi.mx.bag_23", 23},
		["308"] = {"com.youqi.mx.bag_24", 24},
		["618"] = {"com.youqi.mx.bag_25", 25},
		["1048"] = {"com.youqi.mx.bag_26", 26},
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

function UqeeSdkLuaImp:getProductIDByAmount( amount )
	-- body
	local v = self._productIDs[tostring(amount)]
	if v then
		return v[1]
	end
	return ""
end

function UqeeSdkLuaImp:_sendLoginVerifyRequest(uid, token )
	-- body
	local uri = "/rest/partner/uqee/mengxin/login"
    local method = "GET"
    local params = {}
    params.token = token
    params.uid = uid -- already is md5
    params.machine_id = self:getDeviceID()
    uq.cache.account.usernameUid = uid
    -- params.timestamp = os.time()
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
	if not (data and data.uid and data.token) then
		return 
	end
	self:_sendLoginVerifyRequest(data.uid, data.token)
end

function UqeeSdkLuaImp:pay(amount, pid, pname, desc, num)
	-- body
	local role = uq.cache.role
	if not role then
		return
	end
	self._uqsdkNative:pay(self:getProductIDByAmount(amount))
	self:showLoading()
end


function UqeeSdkLuaImp:_onPayCallback( ret, param )
	-- body
	if not uq.cache.role then
		return
	end 
	if ret == UqeeSdkLua.kReturnFailed then
		self:_onPayFail(param)
	elseif ret == UqeeSdkLua.kReturnSuccess then 
		-- uq.TipLayer:createTipLayer(uq.Language.login.error_code[10003]):show()
		self:_sendPayVerifyRequest(param)
	end
end

function UqeeSdkLuaImp:_onPayFail(param)
	-- body
	self:hideLoading()
	release_print("pay fail:", param)
	uq.TipLayer:createTipLayer(uq.Language.login.error_code[10002]):show()

end

function UqeeSdkLuaImp:_onPaySuccess(param)
	-- body
	self:hideLoading()
	uq.TipLayer:createTipLayer(uq.Language.login.error_code[10003]):show()
end

function UqeeSdkLuaImp:_sendPayVerifyRequest(param)
	-- body
	if not param then
		self:_onPayFail()
		return
	end
	param = string.gsub(param,"\\/","/")
	local data = json.decode(param)
	if not (data and data.receipt and data.id and data.productID) then
		self:_onPayFail()
		return
	end
	local receipt = data.receipt 
	local transactionsID = data.id
	local productID = data.productID

	local url = "http://www.uqee.com/mobilepay/order"
    local method = "POST"
    local receiptStr = receipt
    local params = {}
    local server = uq.cache.server or {}
    local amount, pid = self:getAmountbyProductID(productID)
	table.insert(params, {key="agent", val="uqee"})
	table.insert(params, {key="game", val="mxcj"})
	table.insert(params, {key="server_id", val=server.sid or 0})
	table.insert(params, {key="username", val=uq.cache.account.username or ""})
	table.insert(params, {key="login_name", val=uq.cache.account.loginname or ""})
	table.insert(params, {key="trade_no", val=""})
	table.insert(params, {key="amount", val= amount or 0})
	table.insert(params, {key="paytype", val="apple2"})
	table.insert(params, {key="cardtype", val=""})
	table.insert(params, {key="cardinfo", val=""})
	table.insert(params, {key="mobile", val=""})
	table.insert(params, {key="privatefield", val= receiptStr or ""})
	table.insert(params, {key="version", val=""})
	table.insert(params, {key="itemid", val=productID or ""})
	table.insert(params, {key="mac_addr", val=""})
	table.insert(params, {key="server_addr", val=""})
	table.insert(params, {key="mobilekey", val="2e9F19a3De4B4D56A5E362d0aB3F33dC"})
	
	local sign = uq.Commons:md5(uq.http_signatrue_str_nosort(params))
	table.remove(params, #params)
	table.insert(params, {key="client", val="mxcj,uqee"})
	local ext = string.format("%s,%s,%s,%s", server.id or 0, uq.cache.account.loginname or "", pid or 0, uq.cache.role.id or "")
	table.insert(params, {key="ext", val=ext})
	table.insert(params,  {key="sign", val=sign})

	--hot wind
	table.insert(params, {key="platform", val="ios"})
	local uqsdkNative = uq.UqeeSdk:getInstance()
	table.insert(params, {key="idfa", val=uqsdkNative:getIdfa()})
	table.insert(params, {key="idfv", val=uqsdkNative:getIdfv()})
	

	for k, v in pairs(params) do
		if v.key == "privatefield" then
			v.val = string.urlencode(receiptStr)
			break;
		end
	end
    local paramStr = uq.http_params_str_nosort(params)
    uq.http_request(method, url, paramStr, function (data)
    	if data.status == 1 then
    		self:_onPaySuccess()
    		--关闭订单
    		self:sdkExtendFunc(transactionsID)
    	else
    		self:_onPayFail()
    	end
	end)
end

function UqeeSdkLuaImp:sdkEnterMainModuleCallBack( )
	-- body
	self:checkOrder("check")
end

function UqeeSdkLuaImp:_onCheckOrderCallback( ret, param )
	-- body
	local function handlePayListLost( )
		-- body
		self:checkOrder()
	end
	uq.ModuleManager:getInstance():show(uq.ModuleManager.COMMON_POP_MODULE, 
        {title = uq.Language.uqsdk.payListLostTitle, btn={{image = "d/d0020.png", cb=handlePayListLost, close=true}}, content = uq.Language.uqsdk.payListLostContent, closeVisible=true, zOrder = 20000})
end


return UqeeSdkLuaImp;