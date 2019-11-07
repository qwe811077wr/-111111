local cmd = {}

function cmd.run(args)
    uq.ModuleManager:getInstance():darkenToModule(uq.ModuleManager.RESOURCE_COLLECT_MODULE,
        {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, build_id = args.build_id})
end

return cmd