local cmd = {}

function cmd.run(params)
    uq.ModuleManager:getInstance():darkenToModule(uq.ModuleManager.GENERALS_MODULE, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, _general_id = params.generals_id, _index = params.index, _occupation = params.occupation, _tab_index = params.tabIndex, _sub_index = params.subIndex, _max_index = params.max_index})
end

return cmd