local cmd = {}

function cmd.run(param)
    local index = param and param.index
    local sub_index = param and param.subIndex
    uq.ModuleManager:getInstance():darkenToModule(uq.ModuleManager.GENRAL_SHOP_MODULE,
        {_tab_index = index,_sub_index = sub_index})
end

return cmd