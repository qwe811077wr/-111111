local uq = cc.exports.uq or {}

local json = require("json")
function uq.http_auth(method, uri, params, ext)
	ext = ext or ""
	local signStr = uq.http_signatrue_str(params)
	local str = method..uri..signStr..ext..uq.config.APP_KEY

	uq.log("==============-:  ",str)
	local sign = uq.Commons:md5(str)
	return sign
end

--分享功能http请求签名
function uq.http_share_auth(params)
	local signStr = uq.http_signatrue_str(params)
	local str = signStr..uq.config.SHARE_KEY
	local sign = uq.Commons:md5(str)
	return sign
end

function uq.http_signatrue_str(params)
	if type(params) ~= "table" then
		return params
	end

	local str = ""
	local ks = {}
	for k,v in pairs(params) do
		table.insert(ks, k)
	end
	table.sort(ks)
	for i,v in ipairs(ks) do
		str = str .. v..params[v]
	end
	return str
end

function uq.http_params_str(params)
	if type(params) ~= "table" then
		return params
	end

	local str = ""
	local ks = {}
	for k,v in pairs(params) do
		table.insert(ks, k)
	end
	table.sort(ks)
	for i,v in ipairs(ks) do
		str = str .. v.."="..params[v]
		if i ~= #ks then
			str = str.."&"
		end
	end
	return str
end

function uq.http_uqee_stat_auth(method, uri, params, ext)
	ext = ext or ""
	local signStr = uq.http_signatrue_str_nosort(params)
	local str = signStr..ext..uq.sdk.uqee_stat_key
	local sign = uq.Commons:md5(str)
	return sign
end

function uq.http_signatrue_str_nosort(params)
	if type(params) ~= "table" then
		return params
	end

	local str = ""
	for i,v in ipairs(params) do
		str = str .. v.val
	end
	return str
end

function uq.http_params_str_nosort(params)
	if type(params) ~= "table" then
		return params
	end

	local str = ""
	for i,v in ipairs(params) do
		if v.key == "nickname" then
			str = str .. v.key.."=".. uq.encodeURI(v.val)
		else
			str = str .. v.key.."=".. v.val
		end
		if i ~= #params then
			str = str.."&"
		end
	end
	return str
end

function uq.http_request(method, url, params, callback, sign)
	local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr:open(method, url)
    uq.log("---http request:", url)
    local function onReadyStateChanged()
    	uq.log("xhr.readyState",xhr.readyState,xhr.status)
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            uq.log("=======1111======",xhr.response)
            uq.log("")
            local response = xhr.response
            local str = string.unicodeToUtf8(response)
            uq.log("=======22222======",str)
            collectgarbage("collect")
            str = string.gsub(str,"\\/","/")
            local t = json.decode(str)
            uq.log("======3333======",t)
          	if callback ~= nil then
            	callback(t)
            end
            collectgarbage("collect")
        else
            uq.log("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
            if callback ~= nil then
            	callback({code=-1})
            end
        end
        xhr:unregisterScriptHandler()
    end

    xhr:registerScriptHandler(onReadyStateChanged)
    if params ~= nil then
    	uq.log("========uq.http_params_str(params)",uq.http_params_str(params))
    	if sign then
    		xhr:send(string.format("%s&sign=%s", uq.http_params_str(params), sign))
    	else
    		xhr:send(uq.http_params_str(params))
    	end
    else
    	xhr:send()
    end
end

function uq.http_request_no_unicode(method, url, params, callback)
	local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr:open(method, url)
    uq.log("---http request:", url)
    local function onReadyStateChanged()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            print(xhr.response)
            uq.log("")
            local response = xhr.response
            response = string.gsub(response,"\\/","/")
            local t = json.decode(response)
          	if callback ~= nil then
            	callback(t)
            end
            collectgarbage("collect")
        else
            uq.log("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
            if callback ~= nil then
            	callback({code=-1})
            end
        end
        xhr:unregisterScriptHandler()
    end

    xhr:registerScriptHandler(onReadyStateChanged)
    if params~= nil then
    	xhr:send(uq.http_params_str(params))
    else
    	xhr:send()
    end
end

function uq.http_request_json(method, url, jsonData, callback)
	local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	xhr:setRequestHeader("Content-Type", "application/json")
    xhr:open(method, url)
    local function onReadyStateChanged()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            -- print(xhr.response)
            local response = xhr.response
            local t = json.decode(response)
          	if callback ~= nil then
            	callback(t)
            end
            --collectgarbage("collect")
        else
            uq.log("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
            if callback ~= nil then
            	callback({code=-1})
            end
        end
        xhr:unregisterScriptHandler()
    end

    xhr:registerScriptHandler(onReadyStateChanged)
    if jsonData ~= nil then
    	xhr:send(jsonData)
    else
    	xhr:send()
    end
end

function uq.http_broad(callback)
	-- local uri = "/rest/broad_msg"
	-- local method = "GET"

	-- local params = {}
	-- params.game_id = "mengxin"
	-- params.platform_id = uq.sdk.platform_id
	-- params.channel = uq.sdk.platform or "uqee"

	-- local sign = uq.http_auth(method, uri ,params)

	-- local paramStr = uq.http_params_str(params)

	-- local url = string.format("%s%s?%s", uq.sdk.http_addr, uri, paramStr)

	-- uq.http_request(method, url, nil, callback)
	local uri = "/rest/broad_msg"
	local method = "GET"

	local params = {}
	params.game_id = "mengxin"
	params.platform_id = uq.sdk.platform_id
	params.channel = uq.sdk.platform or "uqee"

	local sign = uq.http_auth(method, uri ,params)

	local paramStr = uq.http_params_str(params)
	if uq.config.SERVER_LIST_IS_UTF8 and uq.http_request_no_unicode then
		uq.log("====================server list use utf8")
		params.format = "utf8"
	end
	local url = string.format("%s%s?%s", uq.sdk.http_addr, uri, paramStr)

	-- uq.http_request(method, url, nil, callback)
	if params.format == "utf8" then
		uq.log("====================http request! server list use utf8")
		uq.http_request_no_unicode(method, url, nil, callback)
	else
		uq.log("====================http request! server list use unicode")
		uq.http_request(method, url, nil, callback)
	end
end

function uq.http_servers(isRec, callback)
	local uri = "/rest/server_list"
	local method = "GET"

	local params = {}
	params.game_id = uq.sdk.game_id
	params.platform_id = uq.sdk.platform_id
	params.tags = uq.sdk.game_tag
	params.recommend = isRec or 0
	params.timestamp = os.time()
	if uq.config.SERVER_LIST_IS_UTF8 and uq.http_request_no_unicode then
		uq.log("====================server list use utf8")
		params.format = "utf8"
	end

	local sign = uq.http_auth(method, uri ,params)

	local paramStr = uq.http_params_str(params)

	local url = string.format("%s%s?%s&sign=%s", uq.sdk.http_addr, uri, paramStr, sign)

	if params.format == "utf8" then
		uq.log("====================http request! server list use utf8")
		uq.http_request_no_unicode(method, url, nil, callback)
	else
		uq.log("====================http request! server list use unicode")
		uq.http_request(method, url, nil, callback)
	end
end

function uq.http_login(uid, pwd, callback)
    local uri = "/rest/login"
    local method = "GET"

    local params = {}
    params.game_id = uq.sdk.game_id
    params.username = uid
    params.passwd_hash = pwd -- already is md5
    params.timestamp = os.time()

    local sign = uq.http_auth(method, uri, params)

    local paramStr = uq.http_params_str(params)

    local url = string.format("%s%s?%s&sign=%s", uq.sdk.http_addr, uri, paramStr, sign)

    uq.http_request(method, url, nil, callback)
end

function uq.http_register(uid, pwd, callback)
	local uri = "/rest/register"
	local method = "POST"

	local params = {}
	params.game_id = uq.sdk.game_id
	params.username = uid
	params.password = pwd --already is md5
	-- params.email = ""
	-- params.mobile = ""
	params.machine_id = ""
	params.timestamp = os.time()

	local sign = uq.http_auth(method, uri, params)

	local paramStr = uq.http_params_str(params)

	local url = string.format("%s%s?%s&sign=%s", uq.sdk.http_addr, uri, paramStr, sign)

	uq.http_request(method, url, nil, callback)
end

function uq.http_server_signatrue(uid, passwd, server_id, loginname, req_str, callback)
	local uri = "/rest/server_signature"
	local method = "GET"

	local params = {}
	params.game_id = uq.sdk.game_id
	params.username = uid
	params.server_id = server_id
	params.timestamp = os.time()
	params.loginname = loginname
	params.request_str = req_str

	local sign = uq.http_auth(method, uri, params, passwd)

	local paramStr = uq.http_params_str(params)

	local url = string.format("%s%s?%s&sign=%s", uq.sdk.http_addr, uri, paramStr, sign)

	uq.http_request(method, url, nil, callback)
end

function uq.http_change_pwd(uid, npwd, oldpwd, callback)
	local uri = "/rest/password"
	local method = "POST"

	local params = {}
	params.game_id = uq.sdk.game_id
	params.username = uid
	params.new_passwd = npwd
	params.timestamp = os.time()

	local sign = uq.http_auth(method, uri, params, oldpwd)

	local paramStr = uq.http_params_str(params)

	local url = string.format("%s%s?%s&sign=%s", uq.sdk.http_addr, uri, paramStr, sign)

	uq.http_request(method, url, nil, callback)
end

function uq.http_role_list(uid, passwd, server_id, callback)
	local uri = "/rest/role_list"
	local method = "GET"

	local params = {}
	params.game_id = uq.sdk.game_id
	params.username = uid
	params.server_id = server_id
	params.timestamp = os.time()

	local paramStr = uq.http_params_str(params)

	local sign = uq.http_auth(method, uri, params, passwd)

	local url = string.format("%s%s?%s&sign=%s", uq.sdk.http_addr, uri, paramStr, sign)
	uq.http_request(method, url, nil, callback)
end

function uq.http_guest_signature(server_id, req_str, callback)
	local uri = "/rest/guest_signature"
	local method = "GET"

	local params = {}
	params.game_id = uq.sdk.game_id
	params.server_id = server_id
	params.timestamp = os.time()
	params.request_str = req_str

	local paramStr = uq.http_params_str(params)

	local sign = uq.http_auth(method, uri, params)

	local url = string.format("%s%s?%s&sign=%s", uq.sdk.http_addr, uri, paramStr, sign)

	uq.http_request(method, url, nil, callback)
end

function uq.http_bind_account(uid, passwd, server_id, loginname, callback)
	local uri = "/rest/bind_account"
	local method = "POST"

	local params = {}
	params.game_id = uq.sdk.game_id
	params.username = uid
	params.server_id = server_id
	params.timestamp = os.time()
	params.loginname = loginname

	local paramStr = uq.http_params_str(params)

	local sign = uq.http_auth(method, uri, params, passwd)

	local url = string.format("%s%s?%s&sign=%s", uq.sdk.http_addr, uri, paramStr, sign)

	uq.http_request(method, url, nil, callback)
end

function uq.decodeURI(s)
    s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
    return s
end

function uq.encodeURI(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end

function uq.http_bind_push(type,appid,serverid,loginname,token_name,callback)
	local uri = "/Api/Push/set_device"
	local method = "GET"

	local params = {}
	params.type = type
	params.appid = appid
	params.serverid = serverid
	params.loginname = loginname
	params.token_name = token_name
	params.push_method = 1
	params.channel = ""

	local paramStr = uq.http_params_str(params)
	uq.log("paramStr======="..paramStr)

	local sign = uq.http_auth(method, uri, params)

	local url = string.format("%s%s?%s&sign=%s", "http://g.uqee.com", uri, paramStr, sign)
	uq.log("url======="..url)
	uq.http_request(method, url, nil, callback)
end

function uq.check_response_data(data)
	if not data then
		uq.log("-------no return data")
		uq.TipLayer:createTipLayer(uq.Language.login.error_code[9000]):show()
		return false
	end
	if data.code and tonumber(data.code) ~= 0 then
		local errorStr = uq.Language.login.error_code[tonumber(data.code)]
		if errorStr then
			uq.log(errorStr)
			uq.TipLayer:createTipLayer(errorStr):show()
		else
			uq.TipLayer:createTipLayer(uq.Language.login.error_code[9002]):show()
		end
		return false
	end
	if not data.data then
		uq.log("-------data is empty")
		uq.TipLayer:createTipLayer(uq.Language.login.error_code[9001]):show()
		return false
	end
	return true
end

function uq.http_uqee_report_register(account, eq_num, ip, ad_id, callback)
	local uri = "/mobile/register"
	local method = "POST"

	local params = {}
	table.insert(params, {key="account", val=account or ""})
	table.insert(params, {key="eq_num", val=eq_num or ""})
	table.insert(params, {key="ip", val=ip or ""})
	table.insert(params, {key="ad_id", val=ad_id or ""})

	local sign = uq.http_uqee_stat_auth(method, uri, params)

	local paramStr = uq.http_params_str_nosort(params)

	local url = string.format("%s%s?%s&gameid=20&sign=%s",uq.sdk.uqee_stat_addr, uri, paramStr, sign)

	uq.http_request(method, url, nil, callback)
end

function uq.http_uqee_report_equipment(eq_num, ip, ad_id, callback)
	local uri = "/mobile/equipment"
	local method = "POST"

	local params = {}
	table.insert(params, {key="eq_num", val=eq_num or ""})
	table.insert(params, {key="ip", val=ip or ""})
	table.insert(params, {key="ad_id", val=ad_id or ""})

	local sign = uq.http_uqee_stat_auth(method, uri, params)

	local paramStr = uq.http_params_str_nosort(params)

	local url = string.format("%s%s?%s&gameid=20&sign=%s",uq.sdk.uqee_stat_addr, uri, paramStr, sign)

	uq.http_request(method, url, nil, callback)
end

function uq.http_uqee_report_createaccount(account, rolename, serverid, eq_num, ip, ad_id, callback)
	local uri = "/mobile/createaccount"
	local method = "POST"

	local params = {}
	table.insert(params, {key="account", val=account or ""})
	table.insert(params, {key="nickname", val=rolename or ""})
	table.insert(params, {key="serverid", val=serverid or ""})
	table.insert(params, {key="eq_num", val=eq_num or ""})
	table.insert(params, {key="ip", val=ip or ""})
	table.insert(params, {key="ad_id", val=ad_id or ""})

	local sign = uq.http_uqee_stat_auth(method, uri, params)

	local paramStr = uq.http_params_str_nosort(params)

	local url = string.format("%s%s?%s&gameid=20&sign=%s",uq.sdk.uqee_stat_addr, uri, paramStr, sign)
	uq.http_request(method, url, nil, callback)
end

function uq.uqee_pay_url(amount, pid, pname, num)
	local uri = "/mxapi/pay"
	local method = "POST"

	local role = uq.cache.role
	if not role then
		return
	end
	local server = uq.cache.server or {}
	local loginname = uq.cache.account.loginname or ""

	local params = {}
	params.username = uq.cache.account.usernameUid
	params.login_name = loginname
	uq.log("rolename : " , role.name)
	params.role_name = uq.encodeURI(role.name)
	params.gameid = "mxcj"
	params.serverid = server.sid
	params.time = os.time()
	params.agent = "uqee"
	params.client = "iosmalaysia"
	params.ext = tostring(server.id or "0") .. "," .. loginname .. "," .. tostring(pid) .. "," .. tostring(role.id)
	params.amount = amount
	uq.log("rolename : " , pname)
	params.productname = uq.encodeURI(pname)

	local sign = uq.http_auth(method, uri, params)

	local paramStr = uq.http_params_str(params)

	local url = string.format("%s%s?%s&sign=%s", "http://www.uqee.com", uri, paramStr, sign)
	return url
end

function uq.http_reyun_report_startup(params, callback)
	local uri = "/receive/rest/startup"
	local method = "POST"

	local jsonData = json.encode(params)

	local url = string.format("%s%s",uq.config.REYUN_HTTP_ADDR, uri)
	uq.http_request_json(method, url, jsonData, callback)
end

function uq.http_reyun_report_register(params, callback)
	local uri = "/receive/rest/register"
	local method = "POST"

	local jsonData = json.encode(params)

	local url = string.format("%s%s",uq.config.REYUN_HTTP_ADDR, uri)
	uq.http_request_json(method, url, jsonData, callback)
end

function uq.http_reyun_report_economy(params, callback)
	local uri = "/receive/rest/economy"
	local method = "POST"

	local jsonData = json.encode(params)

	local url = string.format("%s%s",uq.config.REYUN_HTTP_ADDR, uri)
	uq.http_request_json(method, url, jsonData, callback)
end

function uq.http_reyun_report_quest(params, callback)
	local uri = "/receive/rest/quest"
	local method = "POST"

	local jsonData = json.encode(params)

	local url = string.format("%s%s",uq.config.REYUN_HTTP_ADDR, uri)
	uq.http_request_json(method, url, jsonData, callback)
end

function uq.http_reyun_report_event(params, callback)
	local uri = "/receive/rest/event"
	local method = "POST"

	local jsonData = json.encode(params)

	local url = string.format("%s%s",uq.config.REYUN_HTTP_ADDR, uri)
	uq.http_request_json(method, url, jsonData, callback)
end

function uq.http_reyun_report_heartbeat(params, callback)
	local uri = "/receive/rest/heartbeat"
	local method = "POST"

	local jsonData = json.encode(params)

	local url = string.format("%s%s",uq.config.REYUN_HTTP_ADDR, uri)
	uq.http_request_json(method, url, jsonData, callback)
end

--获取邀请码图片地址
function uq.http_share_pic(login_id,role_name,head,level,role_power,callback)
	local uri = "/Mxshare/sharepic"
	local method = "POST"
	local params = {}
	params.login_id = login_id
	params.role_name = role_name
	params.head = head
	params.level = level
	params.role_power = role_power

	local sign = uq.http_share_auth(params)
	local paramStr = uq.http_params_str(params)
	local url = string.format("%s%s?%s&sign=%s",uq.sdk.uqee_stat_addr, uri, paramStr, sign)
	uq.http_request(method, url, nil, callback)
end

--输入邀请码邀请
function uq.http_share_invate(login_id,keystr,callback)
	local uri = "/Mxshare/invitation"
	local method = "POST"
	local params = {}
	params.login_id = login_id
	params.keystr = keystr

	local sign = uq.http_share_auth(params)
	local paramStr = uq.http_params_str(params)
	local url = string.format("%s%s?%s&sign=%s",uq.sdk.uqee_stat_addr, uri, paramStr, sign)
	uq.http_request(method, url, nil, callback)
end

--查询玩家邀请者相关信息
function uq.http_share_guider(login_id,callback)
	local uri = "/Mxshare/guider"
	local method = "POST"
	local params = {}
	params.login_id = login_id

	local sign = uq.http_share_auth(params)
	local paramStr = uq.http_params_str(params)
	local url = string.format("%s%s?%s&sign=%s",uq.sdk.uqee_stat_addr, uri, paramStr, sign)
	uq.http_request(method, url, nil, callback)
end

--查询玩家招募列表
function uq.http_share_fetters(login_id,callback)
	local uri = "/Mxshare/fetters"
	local method = "POST"
	local params = {}
	params.login_id = login_id

	local sign = uq.http_share_auth(params)
	local paramStr = uq.http_params_str(params)
	local url = string.format("%s%s?%s&sign=%s",uq.sdk.uqee_stat_addr, uri, paramStr, sign)
	uq.http_request(method, url, nil, callback)
end

--查询玩家奖励记录
function uq.http_share_prizelog(login_id,callback)
	local uri = "/Mxshare/prizelog"
	local method = "POST"
	local params = {}
	params.login_id = login_id

	local sign = uq.http_share_auth(params)
	local paramStr = uq.http_params_str(params)
	local url = string.format("%s%s?%s&sign=%s",uq.sdk.uqee_stat_addr, uri, paramStr, sign)
	uq.http_request(method, url, nil, callback)
end

--领取奖励
function uq.http_share_getprize(login_id,prizeid,type,amount,callback)
	local uri = "/Mxshare/getprize"
	local method = "POST"
	local params = {}
	params.login_id = login_id
	params.prize_id = prize_id
	params.type = type
	params.amount = amount

	local sign = uq.http_share_auth(params)
	local paramStr = uq.http_params_str(params)
	local url = string.format("%s%s?%s&sign=%s",uq.sdk.uqee_stat_addr, uri, paramStr, sign)
	uq.http_request(method, url, nil, callback)
end

function uq.http_login_server_enter(uid, server_id, callback)
	local uri = "/rest/login/server_enter"
	local method = "GET"

	local params = {}
	uq.log("==========http_role_list_report===username==",username,passwd)
	params.uid = uid
	params.server_id = server_id
	params.game_id = uq.sdk.game_id
	params.timestamp = os.time()

	local sign = uq.http_auth(method, uri, params)

	local paramStr = uq.http_params_str(params)

	local url = string.format("%s%s?%s&sign=%s", uq.sdk.http_addr, uri, paramStr, sign)

	uq.http_request(method, url, params, callback)
end

function uq.http_role_list_report(username, passwd, server_id, loginname, role_name, role_level, role_id, callback)
	local uri = "/rest/role_list/role_report"
	local method = "POST"

	local params = {}
	uq.log("==========http_role_list_report===username==",username,passwd)
	params.username = username
	params.server_id = server_id
	params.game_id = uq.sdk.game_id
	params.timestamp = os.time()
	params.loginname = loginname
	params.role_name = uq.encodeURI(role_name)
	params.role_level = role_level
	params.role_id = role_id

	local sign = uq.http_auth(method, uri, params, passwd)

	local paramStr = uq.http_params_str(params)

	local url = string.format("%s%s?%s&sign=%s", uq.sdk.http_addr, uri, paramStr, sign)

	local params_f = {}
	params_f.username = username
	params_f.server_id = server_id
	params_f.game_id = uq.sdk.game_id
	params_f.timestamp = os.time()
	params_f.loginname = loginname
	params_f.role_name = role_name
	params_f.role_level = role_level
	params_f.role_id = role_id

	local sign_f = uq.http_auth(method, uri, params_f, passwd)

	uq.http_request(method, url, params, callback ,sign_f)
end

function uq.http_get_history_server(uid, loginname, callback)
	local uri = "/rest/server_list/get_history_server"
	local method = "GET"

	local params = {}
	params.uid = uid
	params.game_id = uq.sdk.game_id
	params.timestamp = os.time()
	params.loginname = loginname
	params.length = 10
	params.simplify = 0

	local sign = uq.http_auth(method, uri, params)

	local paramStr = uq.http_params_str(params)

	local url = string.format("%s%s?%s&sign=%s", uq.sdk.http_addr, uri, paramStr, sign)
	uq.log("==http_get_history_server=======url=",url)
	uq.http_request_no_unicode(method, url, nil, callback)
end

function uq.http_auth_phone_bind(params , key)
	local signStr = uq.http_signatrue_str(params)
	local str = signStr..key

	uq.log("==============-:  ",str)
	local sign = uq.Commons:md5(str)
	return sign
end

function uq.http_phone_sendsms(uid , mobilenum , callback)
	local uri = "/Mxsms/sendsms"
	local method = "GET"

	local params = {}
	params.uid = uid
	params.mobile = mobilenum

	local sign = uq.http_auth_phone_bind(params, "68e0a2f2523397b")
	local paramStr = uq.http_params_str(params)

	local url = string.format("%s%s?%s&sign=%s","http://www.uqee.com", uri, paramStr, sign)
	uq.http_request(method, url, nil, callback)
end

function uq.http_phone_bind(uid , mobilenum , smsid , vcode , pid , gid , serverid , callback)
	local uri = "/Mxsms/verify"
	local method = "GET"

	local params = {}
	params.uid = uid
	params.mobile = mobilenum
	params.smsid = smsid
	params.vcode = vcode
	params.pid = pid
	params.gid = gid
	params.serverid = serverid

	local sign = uq.http_auth_phone_bind(params, "68e0a2f2523397b")
	local paramStr = uq.http_params_str(params)

	local url = string.format("%s%s?%s&sign=%s","http://www.uqee.com", uri, paramStr, sign)
	uq.http_request(method, url, nil, callback)
end
