local cmd = {}

function cmd.run(info)
    uq.ModuleManager:getInstance():darkenToModule(uq.ModuleManager.EQUIP_MODULE, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, _equip_info = info.equip_info, _tab_index = info.tabIndex})
end

return cmd