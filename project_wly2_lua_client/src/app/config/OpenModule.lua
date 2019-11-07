local OpenModule = class("OpenModule")

function OpenModule:ctor()

end

function OpenModule:checkModuleOpend(module_index)
    local config = StaticData['module'][module_index]
    return uq.cache.role:level() >= tonumber(config.openLevel)
end

return OpenModule