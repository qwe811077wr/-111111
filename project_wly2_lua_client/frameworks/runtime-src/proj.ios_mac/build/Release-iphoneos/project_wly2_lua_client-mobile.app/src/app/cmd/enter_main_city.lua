local cmd = {}

function cmd.run()
    local args = {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE_ALL}

    args.imgs = uq.ui.MapImage:getMapRectImage(2, cc.p(643, 495), uq.config.constant.MAP_IMAGE_SCALE)
    --args.imgs = {'map/castle/castle.png'}
    --args.plist = {'img/building/buildings'}
    args.cb = 'show_main_city'
    uq.ModuleManager:getInstance():show(uq.ModuleManager.LOADING_MODULE, args)
end

return cmd