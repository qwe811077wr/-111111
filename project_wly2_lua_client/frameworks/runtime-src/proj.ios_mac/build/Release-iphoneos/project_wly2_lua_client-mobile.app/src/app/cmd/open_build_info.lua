local cmd = {}

function cmd.run()
    uq.ModuleManager:getInstance():show(uq.ModuleManager.BUILD_INFO, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
end

return cmd