local cmd = {}

function cmd.run(args)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.GET_RESOURCE, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, type = args.type})
end

return cmd