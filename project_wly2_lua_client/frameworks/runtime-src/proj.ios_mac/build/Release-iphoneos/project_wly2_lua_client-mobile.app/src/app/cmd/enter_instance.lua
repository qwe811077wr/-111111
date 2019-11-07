local cmd = {}

function cmd.run(params)
    local instance_id = 0
    uq.cache.instance._jumpToChapter = nil
    if params.chapter_id then
        instance_id = math.floor(params.chapter_id / 100)
        uq.cache.instance._jumpToChapter = params.chapter_id
    elseif params.instance_id then
        instance_id = params.instance_id
    else
        instance_id = uq.cache.role:getCurInstance()
    end

    --enter instance
    local args = {}
    local temp = StaticData['instance'][instance_id]
    if not temp then
       return
    end

    local function checkInstanceLimit(instance_id, last_instance_id)
        local instance_info = StaticData['instance'][instance_id]
        if not instance_info then
            return false
        end
        if not uq.cache.instance:isNpcPassed(instance_info.premiseObjectId) then
            return checkInstanceLimit(instance_info.parentId, instance_id)
        end
        if instance_id == last_instance_id then
            return true
        end
        local last_instance_info = StaticData['instance'][last_instance_id]
        if last_instance_info.parent then
            local premise_object_name = StaticData.load('instance/' .. last_instance_info.parent.fileId).Map[last_instance_info.parentId].Object[last_instance_info.premiseObjectId].Name
            uq.fadeInfo(string.format('%s%s %s', StaticData['local_text']['main.pass.instance.limit'], last_instance_info.parent.name, premise_object_name))
        end
        return false
    end

    if checkInstanceLimit(instance_id, instance_id) == false then
        return
    end

    local map_config = StaticData.load('instance/' .. temp.fileId)
    local bg_path = map_config.Map[instance_id].background

    args.params = {instance_id}
    args.imgs = {string.format('img/bg/fb/%s', bg_path)}
    args.plist = {}

    -- for k, item in pairs(map_config.Map[instance_id].Object) do
    --     local troop_data = StaticData['soldier'][item.troopShow]
    --     table.insert(args.plist, 'animation/soldier/' .. troop_data.action)
    -- end

    args.cb = 'show_instance'
    uq.ModuleManager:getInstance():show(uq.ModuleManager.LOADING_MODULE, args)
end

return cmd
