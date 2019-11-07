local cmd = {}

function cmd.run(params)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.FRAM_COLLECT_MODULE, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, build_id = params.build_id})
end

return cmd