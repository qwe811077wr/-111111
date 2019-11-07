local cmd = {}

function cmd.run(equip_info,tab_index)
    uq.ModuleManager:getInstance():darkenToModule(uq.ModuleManager.EQUIP_MODULE, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE,_equip_info = equip_info,_tab_index = tab_index})
end

return cmd