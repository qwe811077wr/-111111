local LoginAccountPopCommon = class("LoginAccountPopCommon", require('app.base.PopupBase'))

local Lang = uq.Language.common

function LoginAccountPopCommon:ctor(name, params)
	LoginAccountPopCommon.super.ctor(self, name, params)
end

function LoginAccountPopCommon:init()
	self._view = uq.parseView(cc.CSLoader:createNode("login/LoginAccountPop.csb"))
	self._view:setPosition(cc.p(display.width / 2, display.height / 2))
	self:autoScale(self._view)
	self:setLayerColor(0.4)

	local btn_back = self._view:getChildByName("btn_back")
	btn_back:addClickEventListenerWithSound(handler(self, self.closeModule))
	
	local btnSubmit = self._view:getChildByName("btn_submit")
	uq.setBtnScaleEvent(btnSubmit)
	btnSubmit:addClickEventListenerWithSound(handler(self, self._onSubmit))

	local btnReset = self._view:getChildByName("btn_change_passwd")
	uq.setBtnScaleEvent(btnReset)
	btnReset:addClickEventListenerWithSound(handler(self, self._onReset))

	local btnRegister = self._view:getChildByName("btn_new_user")
	uq.setBtnScaleEvent(btnRegister)
	btnRegister:addClickEventListenerWithSound(handler(self, self._onRegister))

	local tf_user = self._view:getChildByName("tf_user")
	local user = cc.UserDefault:getInstance():getStringForKey("USER")
	if user and user ~= "" then tf_user:setString(user) end

	local tf_passwd = self._view:getChildByName("tf_passwd")
	local passwd = cc.UserDefault:getInstance():getStringForKey("PASSWD")
	if passwd and passwd ~= "" then tf_passwd:setString(passwd) end
end

function LoginAccountPopCommon:_onSubmit()
	local user = self._view:getChildByName("tf_user"):getString()
	local pwd = self._view:getChildByName("tf_passwd"):getString()
	if user and user ~= "" then
		uq.log("=====http_login=======")
		uq.http_login(user, pwd, function(data)
			if not uq.check_response_data(data) then
				return
			end

			cc.UserDefault:getInstance():setStringForKey("USER", user)
			cc.UserDefault:getInstance():setStringForKey("PASSWD", pwd)
		
			local loginMod = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.SDK_LOGIN_MODULE)
			if loginMod then
				loginMod:view():getChildByName("txt_cur_account"):setString(Lang.cur_account..user)
			end
			self:closeModule()
		end)
	end
end

function LoginAccountPopCommon:_onReset()
	uq.ModuleManager:getInstance():show(uq.ModuleManager.SDK_LOGIN_RESET_PASSWORD_POP)
	self:closeModule()
end

function LoginAccountPopCommon:_onRegister()
	uq.ModuleManager:getInstance():show(uq.ModuleManager.SDK_LOGIN_REGISTER_POP)
	self:closeModule()
end

return LoginAccountPopCommon