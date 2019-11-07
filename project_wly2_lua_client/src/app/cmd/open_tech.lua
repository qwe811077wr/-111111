local cmd = {}

function cmd.run()
    uq.ModuleManager:getInstance():darkenToModule(uq.ModuleManager.STRATEGY_MODULE,
        {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
end

return cmd