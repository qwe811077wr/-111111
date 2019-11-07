local cmd = {}

function cmd.run()
    uq.ModuleManager:getInstance():dispose(uq.ModuleManager.INSTANCE_WAR_MAIN)
    uq.ModuleManager:getInstance():dispose(uq.ModuleManager.INSTANCE_WAR_CHAPTER_SELECT)

    if uq.cache.instance_war:getCurInstanceId() > 0 then
        uq.runCmd('open_instance_war', {uq.cache.instance_war:getCurInstanceId()})
    else
        uq.ModuleManager:getInstance():show(uq.ModuleManager.INSTANCE_WAR_CHAPTER_SELECT, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
    end
end

return cmd