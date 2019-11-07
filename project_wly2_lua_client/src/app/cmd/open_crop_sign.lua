local cmd = {}

function cmd.run()
    uq.ModuleManager:getInstance():show(uq.ModuleManager.CROP_SIGN, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
end

return cmd