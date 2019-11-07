local cmd = {}

function cmd.run(args)
    local chat_channel = args and args.channel_id
    uq.ModuleManager:getInstance():show(uq.ModuleManager.CHAT_MAIN, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, chatChannel = chat_channel})
end

return cmd