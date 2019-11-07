local cmd = {}

function cmd.run()
    uq.ModuleManager:getInstance():show(uq.ModuleManager.BUY_MILITORY_ORDER, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
end

return cmd