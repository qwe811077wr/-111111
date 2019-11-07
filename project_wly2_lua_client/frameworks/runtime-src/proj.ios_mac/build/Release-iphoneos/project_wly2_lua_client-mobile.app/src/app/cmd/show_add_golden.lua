local cmd = {}

function cmd.run(param)
    local index = param and param.index
    uq.ModuleManager:getInstance():show(uq.ModuleManager.VIP_MODULE,
        {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE,_tab_index = index})
end

return cmd