local cmd = {}

function cmd.run()
    uq.ModuleManager:getInstance():show(uq.ModuleManager.FLY_NAIL_MODULE, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
end

return cmd