local cmd = {}

function cmd.run()
    uq.ModuleManager:getInstance():darkenToModule(uq.ModuleManager.ANCIENT_CITY_MODULE, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
end

return cmd