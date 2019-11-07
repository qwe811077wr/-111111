local cmd = {}

function cmd.run()
	uq.ModuleManager:getInstance():show(uq.ModuleManager.MAIN_CITY_MODULE, {moduleType = 1})
end

return cmd