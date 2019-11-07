local cmd = {}

function cmd.run()
    uq.ModuleManager:getInstance():show(uq.ModuleManager.GENERAL_POOL_MODULE, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
end

return cmd