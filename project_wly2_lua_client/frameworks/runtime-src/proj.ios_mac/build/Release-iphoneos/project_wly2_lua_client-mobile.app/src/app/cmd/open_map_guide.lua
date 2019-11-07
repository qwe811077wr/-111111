local cmd = {}

function cmd.run()
    uq.ModuleManager:getInstance():darkenToModule(uq.ModuleManager.MAP_GUIDE_INFO, {})
end

return cmd