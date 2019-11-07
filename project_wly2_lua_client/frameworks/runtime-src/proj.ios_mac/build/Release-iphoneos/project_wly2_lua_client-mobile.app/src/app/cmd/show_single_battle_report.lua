local cmd = {}

function cmd.run(report, cb)
    local params = {['report'] = report, ['cb'] = cb}
    uq.ModuleManager:getInstance():show(uq.ModuleManager.SINGLE_BATTLE_MODULE, params)
end

return cmd