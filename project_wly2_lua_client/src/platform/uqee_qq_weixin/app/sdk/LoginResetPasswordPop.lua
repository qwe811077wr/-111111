local LoginResetPasswordPop = class("LoginResetPasswordPop", require('app.base.PopupBase'))

local Lang = uq.Language.common

function LoginResetPasswordPop:ctor(name, params)
	LoginResetPasswordPop.super.ctor(self, name, params)
end

function LoginResetPasswordPop:init()
	self._view = uq.parseView(cc.CSLoader:createNode("login/LoginResetPasswordPop.csb"))
	self._view:setPosition(cc.p(display.width / 2, display.height / 2))
	self:autoScale(self._view)
	self:setLayerColor(0.4)

	local btn_back = self._view:getChildByName("btn_back")
	btn_back:addClickEventListener(handler(self, self.closeModule))
	
	local btn_submit = self._view:getChildByName("btn_submit")
	btn_submit:addClickEventListener(handler(self, self._onSubmit))

	local tf_user = self._view:getChildByName("tf_user")
	local user = cc.UserDefault:getInstance():getStringForKey("USER")
	if user and user ~= "" then tf_user:setString(user) end
end

function LoginResetPasswordPop:_onSubmit()
	local tf_user = self._view:getChildByName("tf_user")
	local tf_passwd = self._view:getChildByName("tf_passwd")
	local tf_sure_passwd = self._view:getChildByName("tf_sure_passwd")
	local user = tf_user:getString()
	local passwd = tf_passwd:getString()
	local surePasswd = tf_passwd:getString()

	local loginErr = uq.Language.login
	if user == "" then
		uq.TipLayer:createTipLayer(loginErr.input_account):show()
		return
	end
	if passwd == "" then
		uq.TipLayer:createTipLayer(loginErr.input_password):show()
		return
	end
	if surePasswd == "" then
		uq.TipLayer:createTipLayer(loginErr.input_sure_password):show()
		return
	end
	if passwd ~= surePasswd then
		uq.TipLayer:createTipLayer(loginErr.diff_password):show()
		return
	end

	if #passwd < 6 then
		uq.TipLayer:createTipLayer(uq.Language.text[648]):show()
		return	
	end

    local pattern = string.gsub(passwd, "%w", "")
    if #pattern > 0 then
		uq.TipLayer:createTipLayer(uq.Language.text[650]):show()
		return	
	end

	local oldPasswd = cc.UserDefault:getInstance():getStringForKey("PASSWD")
	if uq.sdk.platform and uq.sdk.platform == "uqee" then
		if not oldPasswd or #oldPasswd <= 0 then
			uq.TipLayer:createTipLayer(uq.Language.text[651]):show()
			return
		end
		uq.http_uqee_change_pwd(user, uq.Commons:md5(passwd), uq.Commons:md5(oldPasswd), function(data)
			print("=====http_change_pwd=======")
			if not data or (data.status and tonumber(data.status) ~= 0) then
				uq.TipLayer:createTipLayer(uq.Language.text[649]):show()
				return
			end
			cc.UserDefault:getInstance():setStringForKey("USER", user)
			cc.UserDefault:getInstance():setStringForKey("PASSWD", passwd)
			uq.TipLayer:createTipLayer(uq.Language.text[500]):show()
			loginMod = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.SDK_LOGIN_MODULE)
			if loginMod then
				loginMod._user.username = user
				-- loginMod._user.passwd = uq.Commons:md5(passwd)
			end
			self:closeModule()
		end)
	else
		-- uq.http_change_pwd(user, uq.Commons:md5(passwd), uq.Commons:md5(oldPasswd), function(data)
		-- 	print("=====http_change_pwd=======")
		-- 	if not uq.check_response_data(data) then
		-- 		return
		-- 	end
		-- 	cc.UserDefault:getInstance():setStringForKey("USER", user)
		-- 	cc.UserDefault:getInstance():setStringForKey("PASSWD", passwd)
		-- 	uq.TipLayer:createTipLayer("修改密码成功！"):show()
		-- 	loginMod = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.SDK_LOGIN_MODULE)
		-- 	if loginMod then
		-- 		loginMod._user.username = user
		-- 		-- loginMod._user.passwd = uq.Commons:md5(passwd)
		-- 	end
		-- 	self:closeModule()
		-- end)
	end
end

return LoginResetPasswordPop