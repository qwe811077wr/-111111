local cmd = {}

function cmd.run()
    uq.ModuleManager:getInstance():darkenToModule(uq.ModuleManager.MAIN_TASK, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
end

return cmd