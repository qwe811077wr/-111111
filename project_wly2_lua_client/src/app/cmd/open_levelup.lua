local cmd = {}

function cmd.run(args)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.BUILD_LEVEL_UP_MODULE,
        {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, build_id = args.build_id})
end

return cmd