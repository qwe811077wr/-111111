local cmd = {}

function cmd.run()
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ARENA_VIEW, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
end

return cmd