local cmd = {}

function cmd.run()
    uq.ModuleManager:getInstance():show(uq.ModuleManager.EQUIP_POOL_MODULE, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
end

return cmd