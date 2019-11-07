local LoginResetPasswordPop = class("LoginResetPasswordPop", require('app.sdkcommon.LoginResetPasswordPopCommon'))
function LoginResetPasswordPop:ctor(name, params)
	LoginResetPasswordPop.super.ctor(self, name, params)
end

return LoginResetPasswordPop