local cmd = {}

function cmd.run()
    uq.ModuleManager:getInstance():darkenToModule(uq.ModuleManager.DAILY_ACTIVITY, {})
end

return cmd