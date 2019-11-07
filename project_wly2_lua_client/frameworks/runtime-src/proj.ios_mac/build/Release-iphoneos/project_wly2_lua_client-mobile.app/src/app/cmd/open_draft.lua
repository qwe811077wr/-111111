local cmd = {}

function cmd.run(args)
    uq.ModuleManager:getInstance():darkenToModule(uq.ModuleManager.BUILD_SOLDIER_DARFT_MODULE,
        {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
end

return cmd