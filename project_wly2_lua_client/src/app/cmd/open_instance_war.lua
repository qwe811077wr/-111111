local cmd = {}

function cmd.run(instance_id)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.INSTANCE_WAR_MAIN, {instance_id = instance_id})
end

return cmd