local cmd = {}

function cmd.run()
    uq.ModuleManager:getInstance():show(uq.ModuleManager.AREA_MODULE, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE_ALL})
end

return cmd