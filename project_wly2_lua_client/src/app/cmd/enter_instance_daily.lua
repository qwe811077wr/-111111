local cmd = {}

function cmd.run()
    uq.ModuleManager:getInstance():show(uq.ModuleManager.DAILY_INSTANCE, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
end

return cmd