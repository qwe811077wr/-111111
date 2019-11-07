local cmd = {}

function cmd.run(instance_id)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.INSTANCE_MODULE, {instance_id = instance_id})
end

return cmd