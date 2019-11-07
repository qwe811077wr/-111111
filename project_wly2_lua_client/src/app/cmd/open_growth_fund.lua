local cmd = {}

function cmd.run()
    uq.ModuleManager:getInstance():darkenToModule(uq.ModuleManager.GROWTH_FUND, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
end

return cmd