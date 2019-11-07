local cmd = {}

function cmd.run(report, cb, bg_path)
    bg_path = bg_path or 'img/bg/battle/BF_006.png'
    report.bg_path = bg_path
    local params = {report, cb}
    local args = {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE}

    local effect = StaticData['effect'][900121]
    local effect_png = 'animation/effect/' .. effect.tx .. '.png'
    --此处进行预加载兵种
    args.imgs = {bg_path, effect_png}
    args.plist = {}
    args.params = params
    args.cb = 'show_single_battle_report'
    uq.ModuleManager:getInstance():show(uq.ModuleManager.LOADING_MODULE, args)
end

return cmd