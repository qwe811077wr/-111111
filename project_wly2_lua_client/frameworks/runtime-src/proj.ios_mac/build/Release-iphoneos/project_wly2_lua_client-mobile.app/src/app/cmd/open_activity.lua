local cmd = {}

function cmd.run()
    -- uq.fadeInfo('enter activity')
    uq.ModuleManager:getInstance():darkenToModule(uq.ModuleManager.TRIALS_TOWER_MODULE, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE_ALL})
end

return cmd