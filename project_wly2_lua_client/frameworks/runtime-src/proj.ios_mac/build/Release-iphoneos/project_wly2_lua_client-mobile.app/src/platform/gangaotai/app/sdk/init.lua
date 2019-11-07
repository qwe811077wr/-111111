require('app.sdkcommon.initCommon')

function uq.submitRole(isLogin)
end

function uq.setNewUserGuideCompleteEvent(param1 , param2)
	do return end

	local roleId = uq.cache.role:getId()
	if (param1 == 133030 and param2 == nil) or (param1 == nil and param2 == 308070) or (param1 == nil and param2 == nil) then
		if not cc.UserDefault:getInstance():getBoolForKey("GUIDE_COMPLETE"..tostring(roleId)) then
			cc.UserDefault:getInstance():setBoolForKey("GUIDE_COMPLETE"..tostring(roleId) , true)
			local tb = {}
			tb["data_type"] = "new_user"
			tb["data_context"] = ""
			local param = json.encode(tb)
			uq.UqeeSdk:getInstance():setUserData(param)
		end
	end
end

-- type=1 vip   type=2 role level 
function uq.setEvent( eventType , param )
	local roleId = uq.cache.role:getId()
	local dicVip = {["1"]="vip 1",["5"]="vip 5",["10"]="vip 10",["15"]="vip 15"}
	local dicLvl = {["20"]="20 level",["50"]="50 level",["200"]="200 level"}
	local context = nil
	if eventType == 1 then
		local tempParam = math.floor(param/5)*5
		context = dicVip[tostring(tempParam)]		
	else
		if param>5 and param<=10 then 
			local roleId = uq.cache.role:getId()
			if not cc.UserDefault:getInstance():getBoolForKey("GUIDE_COMPLETE"..tostring(roleId)) then
				cc.UserDefault:getInstance():setBoolForKey("GUIDE_COMPLETE"..tostring(roleId) , true)
				local tb = {}
				tb["data_type"] = "new_user"
				tb["data_context"] = ""
				local param = json.encode(tb)
				uq.UqeeSdk:getInstance():setUserData(param)
			end
		elseif param>=20 and param<50 then
			param = 20 
		elseif param>=50 and param<200 then
			param = 50
		elseif param>=200 then
			param = 200
		end
		context = dicLvl[tostring(param)]
	end

	if context and not cc.UserDefault:getInstance():getBoolForKey(context..tostring(roleId)) then
		cc.UserDefault:getInstance():setBoolForKey(context..tostring(roleId) , true)
		if context then
			local tb = {}
			tb["data_type"] = "others"
			tb["data_context"] = context
			local param = json.encode(tb)
			uq.UqeeSdk:getInstance():setUserData(param)
		end
	end
end