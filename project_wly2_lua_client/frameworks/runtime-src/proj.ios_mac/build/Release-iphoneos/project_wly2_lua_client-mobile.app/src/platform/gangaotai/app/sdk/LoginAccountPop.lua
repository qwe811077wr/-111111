local LoginAccountPop = class("LoginAccountPop", require('app.sdkcommon.LoginAccountPopCommon'))
function LoginAccountPop:ctor(name, params)
	LoginAccountPop.super.ctor(self, name, params)
end
return LoginAccountPop