local cmd = {}

function cmd.run(params)
    uq.ModuleManager:getInstance():darkenToModule(uq.ModuleManager.COLLECT_MODULE, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, mode = params.mode})
end

return cmd