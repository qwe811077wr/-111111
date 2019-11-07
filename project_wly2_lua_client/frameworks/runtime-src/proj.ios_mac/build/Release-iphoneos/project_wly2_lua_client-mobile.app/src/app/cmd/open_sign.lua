local cmd = {}

function cmd.run()
    uq.ModuleManager:getInstance():darkenToModule(uq.ModuleManager.ACTIVITY_SIGN, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
end

return cmd