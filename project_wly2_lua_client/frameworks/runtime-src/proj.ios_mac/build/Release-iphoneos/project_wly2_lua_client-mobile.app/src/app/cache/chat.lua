local Chat = class("Chat")

Chat.MAX_CHAT_LENGTH = 100

function Chat:ctor()
    self._broadData = {}
    self._allChatMsgMap = {}
    self._curMsgType = nil
    self._unReadMsgNum = 0
    self._chatChannelRedIndex = {}
    self._chatPrivateInfo = {}
    self._chatPrivateInfoSearch = {}
    self._curChatPrivateInfoId = 0
    self._mainUIWorldChatInfo = {}
    self._readData = {}
    network:addEventListener(Protocol.S_2_C_CHAT_MSG, handler(self, self._onReceiveMsg))
    network:addEventListener(Protocol.S_2_C_BROAD_MSG, handler(self, self._onBroadMsg))
    network:addEventListener(Protocol.S_2_C_CHAT_MSG_LOAD, handler(self, self._onReceive))
    network:addEventListener(Protocol.S_2_C_CHAT_MSG_LOAD_END,handler(self, self._onRefreshChat))
    network:addEventListener(Protocol.S_2_C_CHOOSE_BUBBLE,handler(self, self._onBubbleIdChange))
    services:addEventListener(services.EVENT_NAMES.ON_CHAT_WRITE_FILE_DATA, handler(self, self._onWriteChatPrivateFile))
end

function Chat:_onReceiveMsg(msg)
    local content = msg.packet:readString(msg.packet:size())
    msg.data.content = content
    self:addChat(msg.data)
end

function Chat:addChat(data)
    if not self._allChatMsgMap[data.msg_type] then
        self._allChatMsgMap[data.msg_type] = {}
    end
    self._unReadMsgNum = self._unReadMsgNum + 1
    table.insert(self._allChatMsgMap[data.msg_type], data)
    self:_onSelectChannelRedIndex(data.msg_type)
    if data.msg_type == uq.config.constant.TYPE_CHAT_CHANNEL.CC_CONVERSATION then
        self:_addChatPrivateInfo(data)
    elseif data.msg_type == uq.config.constant.TYPE_CHAT_CHANNEL.CC_WORLD then
        self:refreshWorldInfo(data)
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CHAT_REFRESH, channel = data.msg_type, count = 1})
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CHAT_REFRESH_PROMPT_RED_NUM, {}})
end

function Chat:_onSelectChannelRedIndex(index)
    if not self._chatChannelRedIndex[index] then
        self._chatChannelRedIndex[index] = {num = 0}
    end
    self._chatChannelRedIndex[index].num = self._chatChannelRedIndex[index].num + 1
end

function Chat:_onReceive(msg)
    self._unReadMsgNum = self._unReadMsgNum + msg.data.count
    for k, item in pairs(msg.data.msgs) do
        if not self._allChatMsgMap[item.msg_type] then
            self._allChatMsgMap[item.msg_type] = {}
        end
        table.insert(self._allChatMsgMap[item.msg_type], item)
        self._curMsgType = item.msg_type

        self:_onSelectChannelRedIndex(item.msg_type)
    end
end

function Chat:_onReadChatPrivateFile()
    local json = require("json")

    local file_instance = cc.FileUtils:getInstance()
    local find_path = file_instance:getWritablePath() .. 'chatInfoDt'
    file_instance:addSearchPath(find_path)

    local file_name = 'chatPrivateInfo.json'
    local full_path = find_path .. "/" .. file_name
    local isExist = file_instance:isFileExist(file_name)

    if isExist then
        --读取文件
        local read_file = io.readfile(full_path)
        self._readData = json.decode(read_file)
        self:initChatPrivateInfoSearch()
    else
        --创建文件
        cc.FileUtils:getInstance():createDirectory(find_path)
    end
end

function Chat:initChatPrivateInfoSearch()
    if self._readData == nil or next(self._readData) == nil then
        return
    end
    local data = {}
    for k, v in pairs(self._readData) do
        if v.id == uq.cache.role.id then
            data = self._readData[k]
            break
        end
    end
    if next(data) == nil or not data.channel_info then
        return
    end
    for k, v in pairs(data.channel_info) do
        local tag = tonumber(k)
        if not self._allChatMsgMap[tag] then
            self._allChatMsgMap[tag] = {}
        end
        for k2, data in ipairs(v) do
            table.insert(self._allChatMsgMap[tag], data)
        end
    end
    local info = data.info
    if next(info.chat_data) == nil  then
        return
    end
    self._curChatPrivateInfoId = info.cur_chat_id
    self._chatPrivateInfo = {}
    for k, v in pairs(info.chat_data) do
        if #v.content > 0 then
            for k2, content in ipairs(v.content) do
                if content.sender_id ~= nil then
                    self:_addChatPrivateInfo(content)
                end
            end
        end
    end
end

function Chat:createConversation(data, flag, is_self)
    local info = {
        contact_id = data.sender_id,
        contact_name = data.role_name,
        img_id = data.img_id,
        img_type = data.img_type,
        create_time = os.time(),
        country_id = data.country_id
    }

    if is_self then
        info.contact_id = data.contact_role_id
    end

    local private_info = self._chatPrivateInfoSearch[info.contact_id]
    if not private_info and uq.cache.role.id ~= info.contact_id then
        --创建新的会话
        info.content = {}
        self._chatPrivateInfoSearch[info.contact_id] = info
        table.insert(self._chatPrivateInfo, info)
        local first_info = {
            msg_type = uq.config.constant.TYPE_CHAT_CHANNEL.CC_CONVERSATION,
            content_type = uq.config.constant.TYPE_CHAT_CONTENT.CCT_TIPS_PRIVATE,
            contact_id = data.sender_id,
            contact_name = data.role_name,
            role_name = uq.cache.role.name,
            create_time = os.time(),
            content = "",
            crop_name = data.crop_name
        }
        private_info = info
        table.insert(private_info.content, first_info)
    end

    if not flag then
        table.insert(private_info.content, data)
        return
    end
    self._curChatPrivateInfoId = data.sender_id
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CHAT_CONVERSATION_REFRESH, data = private_info})
end

function Chat:_addChatPrivateInfo(data)
    if uq.cache.role.id == data.sender_id then
        self:createConversation(data, false, true)
    else
        self:createConversation(data, false, false)
    end
end

function Chat:_mergeChatPrivateInfo()
    local index = uq.config.constant.TYPE_CHAT_CHANNEL.CC_CONVERSATION
    if not self._allChatMsgMap[index] then
        return
    end

    for i, v in pairs(self._allChatMsgMap[index]) do
       self:createConversation(v, false)
    end
end

function Chat:_onWriteChatPrivateFile()
    local full_path = cc.FileUtils:getInstance():getWritablePath() .. 'chatInfoDt/chatPrivateInfo.json'

    local data = self:findData()
    local wirtjson = json.encode(data)
    local open_file = io.writefile(full_path, wirtjson, "w")
end

function Chat:findData()
    local data = self:wirteData()
    local is_find = false
    for k, v in pairs(self._readData) do
        if v.id == data.id then
            self._readData[k] = data
            is_find = true
            break
        end
    end
    if not is_find then
        table.insert(self._readData, data)
    end
    return self._readData
end

function Chat:wirteData()
    local data = {}
    data.id = uq.cache.role.id
    data.info = {}
    data.info.cur_chat_id = self._curChatPrivateInfoId
    for k, v in pairs(self._chatPrivateInfoSearch) do
        self:_limitWriteLen(v.content)
    end

    data.info.chat_data = self._chatPrivateInfo
    data.channel_info = {}
    local world_data = self:getChannelData(uq.config.constant.TYPE_CHAT_CHANNEL.CC_WORLD)
    self:_limitWriteLen(world_data)
    data.channel_info[uq.config.constant.TYPE_CHAT_CHANNEL.CC_WORLD] = world_data
    local country_data = self:getChannelData(uq.config.constant.TYPE_CHAT_CHANNEL.CC_COUNTRY)
    self:_limitWriteLen(country_data)
    data.channel_info[uq.config.constant.TYPE_CHAT_CHANNEL.CC_COUNTRY] = country_data
    local team_data = self:getChannelData(uq.config.constant.TYPE_CHAT_CHANNEL.CC_TEAM)
    self:_limitWriteLen(team_data)
    data.channel_info[uq.config.constant.TYPE_CHAT_CHANNEL.CC_TEAM] = team_data
    return data
end

function Chat:_limitWriteLen(data)
    if #data <= 50 then
        return
    end

    table.sort(data, function(a, b)
        return a.create_time < b.create_time
    end)

    --保存最近的50条
    local content = {}
    for i = #data, #data - 50 do
        table.insert(content, data[i])
    end
    data = content
end

function Chat:_sortData()
    local type_array = {
        uq.config.constant.TYPE_CHAT_CHANNEL.CC_WORLD,
        uq.config.constant.TYPE_CHAT_CHANNEL.CC_COUNTRY,
        uq.config.constant.TYPE_CHAT_CHANNEL.CC_TEAM,
        uq.config.constant.TYPE_CHAT_CHANNEL.CC_CONVERSATION,
        uq.config.constant.TYPE_CHAT_CHANNEL.CC_SYSTEM,
    }
    for i, v in ipairs(type_array) do
        local data = self:getChannelData(v)
        if next(data) ~= nil and #data > 1 then
            table.sort(data, function(item1, item2)
                return item1.create_time < item2.create_time
            end)
        end
    end
end

function Chat:_onRefreshChat(msg)
    self:_onReadChatPrivateFile()
    self:_sortData()
    self:_mergeChatPrivateInfo()
    self:_onSelectWorldInfo()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CHAT_REFRESH, channel = self._curMsgType})
end

function Chat:_onSelectWorldInfo()
    if not self._allChatMsgMap[uq.config.constant.TYPE_CHAT_CHANNEL.CC_WORLD] then
        return
    end
    local world_data = self._allChatMsgMap[uq.config.constant.TYPE_CHAT_CHANNEL.CC_WORLD]
    if #world_data <= 1 then
        self._mainUIWorldChatInfo[1] = world_data[1]
        return
    end

    self._mainUIWorldChatInfo[1] = world_data[#world_data - 1]
    self._mainUIWorldChatInfo[2] = world_data[#world_data]
end

function Chat:getInterceptLen(info)
    local name = info.role_name .. ":"
    local content = info.role_name .. ":" .. info.content
    if string.utfLen(content) > 13 then
        local len = 13 - string.utfLen(name)
        return len
    end
    return
end

function Chat:getInterceptReportLen(info, content)
    local name = info.role_name .. ":"
    local content = info.role_name .. ":" .. content
    if string.utfLen(content) > 13 then
        local len = 13 - string.utfLen(name)
        return len
    end
    return
end

function Chat:refreshWorldInfo(info)
    if not self._mainUIWorldChatInfo[2] then
        if not self._mainUIWorldChatInfo[1] then
            self._mainUIWorldChatInfo[1] = info
        else
            self._mainUIWorldChatInfo[2] = info
        end
        services:dispatchEvent({name = services.EVENT_NAMES.ON_CHAT_WORLD_REFRESH})
        return
    end

    self._mainUIWorldChatInfo[1] = self._mainUIWorldChatInfo[2]
    self._mainUIWorldChatInfo[2] = info
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CHAT_WORLD_REFRESH})
end

function Chat:_onBubbleIdChange(msg)
    uq.cache.role.bubble_id = msg.data.id
end
--公告信息
function Chat:_onBroadMsg(msg)
    local count = 0
    for k, item in ipairs(msg.data.msgs) do
        item.time = uq.cache.server_data:getServerTime()
        table.insert(self._broadData, item)

        if not self._allChatMsgMap[uq.config.constant.TYPE_CHAT_CHANNEL.CC_SYSTEM] then
            self._allChatMsgMap[uq.config.constant.TYPE_CHAT_CHANNEL.CC_SYSTEM] = {}
        end
        table.insert(self._allChatMsgMap[uq.config.constant.TYPE_CHAT_CHANNEL.CC_SYSTEM], {id = item.id, content = item.content, create_time = item.time})
        count = count + 1
    end

    table.sort(self._broadData, function(item1, item2)
        if item1.broad_type ~= item2.broad_type then
            return item1.broad_type > item2.broad_type
        else
            return item1.time < item2.time
        end
    end)
    self:playBroadMsg()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_CHAT_REFRESH, channel = uq.config.constant.TYPE_CHAT_CHANNEL.CC_SYSTEM, count = count})
end

function Chat:playBroadMsg()
    services:dispatchEvent({name = services.EVENT_NAMES.ON_PLAY_BROAD_MSG})
end

function Chat:addCropData(data)
    self:addChat(data)
end

function Chat:getChannelData(channel)
    if self._allChatMsgMap[channel] then
        return self._allChatMsgMap[channel]
    else
        return {}
    end
end

function Chat:addShield(name)
    local names = cc.UserDefault:getInstance():getStringForKey("chat_shield", "")
    names = names .. ";" .. name
    cc.UserDefault:getInstance():setStringForKey("chat_shield", names)
end

function Chat:deleteShield(name)
    local names = cc.UserDefault:getInstance():getStringForKey("chat_shield", "")
    local names = string.split(names, ";")
    for k, item in ipairs(names) do
        if item == name then
            table.remove(names, k)
        end
    end

    local new_names = ''
    for k, item in ipairs(names) do
        new_names = new_names .. item
    end

    cc.UserDefault:getInstance():setStringForKey("chat_shield", new_names)
end

function Chat:getShield(name)
    local names = cc.UserDefault:getInstance():getStringForKey("chat_shield", "")
    local names = string.split(names, ";")
    for k, item in ipairs(names) do
        if item == name then
            return true
        end
    end
    return false
end

return Chat