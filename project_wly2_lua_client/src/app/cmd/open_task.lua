local cmd = {}

function cmd.run()
    uq.ModuleManager:getInstance():darkenToModule(uq.ModuleManager.DAILY_TASK, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE,_tab_index = 2})
end

return cmd