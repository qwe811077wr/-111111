local UqeeSdkLua = require("app.sdkcommon.UqeeSdkLua")
local UqeeSdkLuaImp = class("UqeeSdkLua", UqeeSdkLua)

function UqeeSdkLuaImp:ctor(  )
	-- body
	UqeeSdkLuaImp.super.ctor(self)
end

function UqeeSdkLuaImp:_sendLoginVerifyRequest(uid, token )
	-- body
	local uri = "/rest/partner/uqee/mengxin/login"
    local method = "GET"
    local params = {}
    params.token = token
    params.uid = uid -- already is md5
    params.machine_id = self:getDeviceID()
    
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
	param = string.gsub(param,"\\/","/")
	local data = json.decode(param)
	if not (data and data.uid and data.token) then
		return 
	end
	self:_sendLoginVerifyRequest(data.uid, data.token)
end


return UqeeSdkLuaImp;