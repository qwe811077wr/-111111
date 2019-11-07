local cmd = {}

function cmd.run()
    uq.ModuleManager:getInstance():darkenToModule(uq.ModuleManager.TASK_DAY_SEVEN, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
end

return cmd