local cmd = {}

function cmd.run()
    if not uq.cache.pass_check:isCanOpenPassCheck() then
        uq.fadeInfo(StaticData["local_text"]["activity.please.wait"])
        return
    end
    uq.ModuleManager:getInstance():darkenToModule(uq.ModuleManager.PASS_CHECK_MAIN, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
end

return cmd