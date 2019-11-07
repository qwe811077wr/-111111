local LoginModule = class("LoginModule", require('app.sdkcommon.LoginModuleCommon'))

function LoginModule:ctor(name, params)
	LoginModule.super.ctor(self, name, params)
end

function LoginModule:init()
	LoginModule.super.init(self )
	local textTip1 = uq.seekNodeByName(self._view , "Text_tip1")
	local textTip2 = uq.seekNodeByName(self._view , "Text_tip2")
	textTip1:setVisible(false)
	textTip2:setVisible(false)
end

function LoginModule:dragonAction()
	local test_img_1 = cc.Sprite:create("login/lo_4.jpg")
	test_img_1:setName("auto_bg")
 	self._view:addChild(test_img_1,-1)

 	local logo = self._view:getChildByName("Image_1")
 	logo:setVisible(false)

 	local sp_icon = cc.Sprite:create("login/lo_8.png")
 	sp_icon:setPosition(cc.p(-430,260))
 	self._view:addChild(sp_icon)
end

return LoginModule
