local cmd = {}

function cmd.run()
    local args = {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE_ALL}
    --args.imgs = {'img/bg/CountryWar.jpg'}
    --args.plist = {'img/building/buildings'}
    args.cb = 'show_world_city_war'
    uq.ModuleManager:getInstance():show(uq.ModuleManager.LOADING_MODULE, args)
end

return cmd