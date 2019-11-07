local cmd = {}

function cmd.run()
    local args = {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE_ALL}
    local soldier = StaticData['soldier'][11]
    local soldier2 = StaticData['soldier'][16]
    args.plist = {'animation/soldier/' .. string.format('%s_%d', soldier.action, 3),
                  'animation/soldier/' .. string.format('%s_%d', soldier2.action, 3)}
    args.cb = 'show_world'
    uq.ModuleManager:getInstance():show(uq.ModuleManager.LOADING_MODULE, args)
end

return cmd