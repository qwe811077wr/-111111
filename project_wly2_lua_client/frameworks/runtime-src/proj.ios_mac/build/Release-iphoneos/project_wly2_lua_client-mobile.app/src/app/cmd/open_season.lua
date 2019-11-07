local cmd = {}

function cmd.run()
    uq.ModuleManager:getInstance():darkenToModule(uq.ModuleManager.MAIN_CITY_SEASON, {})
end

return cmd