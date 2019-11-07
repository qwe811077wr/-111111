local cmd = {}

function cmd.run()
    uq.ModuleManager:getInstance():show(uq.ModuleManager.RANK_VIEW, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
end

return cmd