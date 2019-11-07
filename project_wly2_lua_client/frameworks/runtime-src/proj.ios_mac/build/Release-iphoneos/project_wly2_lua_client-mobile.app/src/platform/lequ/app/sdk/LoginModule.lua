local LoginModule = class("LoginModule", require('app.sdkcommon.LoginModuleCommon'))

function LoginModule:ctor(name, params)
	LoginModule.super.ctor(self, name, params)
end

return LoginModule
