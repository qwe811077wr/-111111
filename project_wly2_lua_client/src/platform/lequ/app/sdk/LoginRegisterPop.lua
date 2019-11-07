local LoginRegisterPop = class("LoginRegisterPop", require('app.sdkcommon.LoginRegisterPopCommon'))

function LoginRegisterPop:ctor(name, params)
	LoginRegisterPop.super.ctor(self, name, params)
end


return LoginRegisterPop