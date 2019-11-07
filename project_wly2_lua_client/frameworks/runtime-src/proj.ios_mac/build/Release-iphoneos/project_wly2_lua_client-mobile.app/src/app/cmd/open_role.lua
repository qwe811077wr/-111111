local cmd = {}

function cmd.run(param)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.ROLE_VIEW,param)
end

return cmd