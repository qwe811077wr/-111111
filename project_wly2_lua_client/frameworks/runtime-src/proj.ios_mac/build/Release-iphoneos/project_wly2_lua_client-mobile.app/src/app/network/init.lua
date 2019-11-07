local Protocol = {}
Protocol.structs = {}

Protocol.DataType = {
    char = 'char',
    uchar = 'unsigned char',
    short = 'short',
    ushort = 'unsigned short',
    int = 'int',
    uint = 'unsigned int',
    longlong = 'long long',
    ulonglong = 'unsigned long long',
    llstring = 'long long string',
    float = 'float',
    double = 'double',
    string = 'string',
    object = 'object',
    binary = 'binary'
}

cc.exports.Protocol = Protocol

local network = {
    _socket = nil,
    _schedulerID = -1,
    _lastTickTime = os.time(),
    _listener = {},
    _eventTags = {},
    _sendAliveTime = 0,
    _lastAliveTime = os.time(), -- 最后接收到消息的时间、与最后发送消息时间区分
    _retryTimes = 0,            -- 重练次数
    _tickHeart = 0,
    _tickAlive = 0,
}

local KEEP_ALIVE_TIMEOUT = 50
local KEEP_CONNECT_TIMEOUT = 1800
local KEEP_HEART_TIMEOUT = 5
local RETRY_MAX_TIMES = 10

function network:clear()
    self._listener = {}
    self._eventTags = {}
    self:close()
    self._retryTimes = 0
    self._socket = nil
end

function network:connect(addr, port)
    self._socket = uq.GameConnection:sharedGameConnection(addr, port)
    local ret = self._socket:connect()
    if ret > 0 then
        return ret
    end
    local packet = uq.ProtocolPacket:new()
    packet:writeInt(2)
    self._socket:sendRawDataLua(packet)
    self._socket:start()
    local scheduler = cc.Director:getInstance():getScheduler()
    self._schedulerID = scheduler:scheduleScriptFunc(handler(self, self.packetPeak), 0, false)
    return 0
end

function network:reConnect()
    uq.debug(uq.cache.server.addr, uq.cache.server.port)
    self._retryTimes = self._retryTimes + 1
    self:addEventListener(Protocol.S_2_C_GATE_STATE, function(evt)
        self:removeEventListenerByTag('_onGateState')
        self._retryTimes = 0
        self:sendPacket(Protocol.C_2_S_SWAP_SESSION, {session_seed = uq.cache.account.session_seed, role_id = uq.cache.role.id})
    end, '_onGateState')
    self:connect(uq.cache.server.address, tonumber(uq.cache.server.port))
end

function network:logout()
    self:clear()
    require('app.network.InitProtocol'):run()
    uq.cache.initCache()
    uq.TimerProxy:cleanAllTimer()
    uq.ModuleManager:getInstance():show(uq.ModuleManager.LOGIN_MODULE, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE_ALL})
end

function network:_onLoginResult(evt)
    self:removeEventListenerByTag('_onLoginResult')
    local data = evt.data
    require("app.network.InitProtocol"):init()
    self:sendPacket(Protocol.C_2_S_LOAD_ROLE_INFO, {role_id = data.roles[1].role_id})
end

function network:connectError()
    --第一次自动连接五次没有成功，跳转重连界面
    if self._retryTimes == 5 then
        local data = {}
        data.style = 1
        data.title = nil
        data.msg = "<#FFFFFF><24>" .. StaticData['local_text']['label.common.network.error']
        data.cancelFunc = handler(self, self.logout)
        data.confirmFunc = handler(self, self.reConnect)
        uq.ModuleManager:getInstance():show(uq.ModuleManager.NETWORK_ERROR, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, dialogInfo = data})
    end
end

function network:packetPeak(dt)
    if not self._socket then
        return
    end
    if self._socket:getState() == 3 or
        self._socket:getState() == 4 then
        if not uq.ModuleManager:getInstance():getModule(uq.ModuleManager.NETWORK_ERROR) then
            if uq.ModuleManager:getInstance():getModule(uq.ModuleManager.LOGIN_MODULE) then
                -- 登录界面
                local data = {}
                data.style = 3
                data.title = nil
                data.msg = "<#FFFFFF><24>" .. StaticData['local_text']['label.common.network.unconnect']
                data.confirmFunc = function() self._socket = nil end
                data.cancelFunc = nil
                uq.ModuleManager:getInstance():show(uq.ModuleManager.NETWORK_ERROR, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, dialogInfo = data})
            else
                if os.time() - self._lastAliveTime >= KEEP_CONNECT_TIMEOUT or self._retryTimes > RETRY_MAX_TIMES then
                    -- 到最后接收到消息时间超过半小时，重新走登录逻辑
                    local data = {}
                    data.style = 2
                    data.msg = "<#FFFFFF><24>" .. StaticData['local_text']['label.common.network.logout']
                    data.confirmFunc = handler(self, self.logout)
                    data.cancelFunc = handler(self, self.reConnect)
                    uq.ModuleManager:getInstance():show(uq.ModuleManager.NETWORK_ERROR, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE, dialogInfo = data})
                else
                    --先眺loading界面，自动重连
                    if not uq.ModuleManager:getInstance():getModule(uq.ModuleManager.NETWORK_LOADING) then
                        uq.ModuleManager:getInstance():show(uq.ModuleManager.NETWORK_LOADING, {call_back = handler(self, self.reConnect), zOrder = uq.ModuleManager.SPECIAL_ZORDER.TIP_ZORDER - 1})
                    end
                end
            end
        end
    else
        if self._sendAliveTime > 0 then
            self._tickHeart = self._tickHeart + dt
            if self._tickHeart >= KEEP_HEART_TIMEOUT then
                self._tickHeart = 0
                self._sendAliveTime = 0
                --先眺loading界面，自动重连
                if not uq.ModuleManager:getInstance():getModule(uq.ModuleManager.NETWORK_LOADING) and
                 not uq.ModuleManager:getInstance():getModule(uq.ModuleManager.NETWORK_ERROR) then
                    uq.ModuleManager:getInstance():show(uq.ModuleManager.NETWORK_LOADING, {call_back = handler(self, self.reConnect), zOrder = uq.ModuleManager.SPECIAL_ZORDER.TIP_ZORDER - 1})
                end
            end
        end
        self._tickAlive = self._tickAlive + dt
        if self._tickAlive >= KEEP_ALIVE_TIMEOUT then
            self._tickAlive = 0
            self:sendPacket(Protocol.C_2_S_KEEP_ALIVE, {})
            self._lastTickTime = os.time()
            self._sendAliveTime = os.time()
        end
    end

    for i = 1, 10 do
        local packet = self._socket:getPacket()
        if not packet then
            break
        end
        self:dispatchPacket(packet)
        packet:del()
    end
end

function network:dispatchPacket(packet)
    if not packet then
        return
    end
    print(packet:type())
    local struct = Protocol.structs[packet:type()]
    if not struct then
        uq.debug('No such Protocol defined ' .. packet:type())
        return
    end
    local obj = self:_parsePacket(packet, struct)
    if not obj then
        uq.debug("Parse data failed " .. packet:type())
        return
    end
    --uq.log("[Packet][Recv]["..packet:type().."]:"..table.keyof(Protocol, packet:type()).."", obj)

    if packet:type() == Protocol.S_2_C_KEEP_ALIVE then
        self._sendAliveTime = 0
        self._tickHeart = 0
    end
    self._lastAliveTime = os.time()
    uq.ModuleManager:getInstance():dispose(uq.ModuleManager.NETWORK_LOADING)
    --
    self:_dispatchEvent(packet:type(), {data = obj, ['packet'] = packet})
end

function network:sendPacket(id, data)
    local struct = Protocol.structs[id]
    local packet = nil
    if struct then
        packet = self:_buildPacket(struct, data)
    end
    if not packet then
        packet = uq.ProtocolPacket:new()
    end
    packet:type(id)
    self._lastTickTime = os.time()
    self._socket:sendPacket(packet)
end

function network:addEventListener(id, handle, tag)
    if not self._listener[id] then
        self._listener[id] = {}
    end
    if not tag then
        table.insert(self._listener[id], handle)
    else
        if not self._listener[id][tag] then
            self._listener[id][tag] = {}
        end
        table.insert(self._listener[id][tag], handle)
        self._eventTags[tag] = id
    end
end

function network:removeEventListenerByTag(tag)
    -- if not self._eventTags[tag] then
    --     return
    -- end
    -- self._listener[self._eventTags[tag]] = nil
    -- self._eventTags[tag] = nil

    if self._eventTags[tag] then
        self._listener[self._eventTags[tag]][tag] = nil
        self._eventTags[tag] = nil
    else
        self._listener[tag] = nil
    end
end

function network:_dispatchEvent(id, data)
    local handlers = self._listener[id]
    if not handlers then
        return
    end
    for k, v in pairs(handlers) do
        if type(v) == 'table' then
            for k1, v1 in pairs(v) do
                v1(data)
            end
        else
            v(data)
        end
    end
end

function network:close()
    self._socket:close()
end

function network:_parsePacket(packet, struct)
    --uq.log('_parsePacket', packet:type(), packet, struct)
    local ret = {}
    local dt = Protocol.DataType
    for i = 1, #struct.fields do
        local f = struct.fields[i]
        local desc = struct[f]
        local len = desc.length
        if not len then
            len = 1
        end
         if len < 0 then
             len = ret[struct.fields[i - 1]]
         end
        if desc.type == dt.char or desc.type == dt.uchar then
            local v = nil
            if not desc.length then
                v = packet:readChar()
            else
                v = {}
                for j = 1, len do
                     v[j] = packet:readChar()
                 end
             end
             ret[f] = v
         elseif desc.type == dt.short or desc.type == dt.ushort then
             local v = nil
             if not desc.length then
                 v = packet:readShort()
             else
                 v = {}
                 for j = 1, len do
                     v[j] = packet:readShort()
                 end
             end
             ret[f] = v
         elseif desc.type == dt.int then
             local v = nil
             if not desc.length then
                 v = packet:readInt()
             else
                 v = {}
                 for j = 1, len do
                     v[j] = packet:readInt()
                 end
             end
             ret[f] = v
         elseif desc.type == dt.uint then
             local v = nil
             if not desc.length then
                 v = packet:readUInt()
             else
                 v = {}
                 for j = 1, len do
                     v[j] = packet:readInt()
                 end
             end
             ret[f] = v
         elseif desc.type == dt.longlong or desc.type == dt.ulonglong then
             local v = nil
             if not desc.length then
                 v = packet:readLongLong()
             else
                 v = {}
                 for j = 1, len do
                     v[j] = packet:readLongLong()
                 end
             end
             ret[f] = v
        elseif desc.type == dt.llstring then
            local v = nil
            if not desc.length then
                v = packet:readLLongString()
            else
                v = {}
                for j = 1, len do
                    v[j] = packet:readLLongString()
                end
            end
            ret[f] = v
         elseif desc.type == dt.float then
             local v = nil
             if not desc.length then
                 v = packet:readFloat()
             else
                 v = {}
                 for j = 1, len do
                     v[j] = packet:readFloat()
                 end
             end
             ret[f] = v
         elseif desc.type == dt.double then
             local v = nil
             if not desc.length then
                 v = packet:readDouble()
             else
                 v = {}
                 for j = 1, len do
                     v[j] = packet:readDouble()
                 end
             end
             ret[f] = v
         elseif desc.type == dt.string then
             local str = nil
             if desc.length < 0 then
                 str = packet:readString(ret[struct.fields[i - 1]])
             else
                 str = packet:readString(desc.length)
                 str = string.sub(str, 1, ret[struct.fields[i - 1]])
             end
             ret[f] = str
         elseif desc.type == dt.object then
             if not ret[f] then
                 ret[f] = {}
             end
             if not Protocol[desc.clazz] then
                 uq.debug('No such define ' .. desc.clazz)
                 return nil
             end
             for j = 1, len do
                 local o = self:_parsePacket(packet, Protocol[desc.clazz])
                 table.insert(ret[f], o)
             end
        end
    end
    return ret
end

function network:_buildPacket(struct, data)
    local dt = Protocol.DataType
    local packet = uq.ProtocolPacket:new()
    for i = 1, #struct.fields do
        local f = struct.fields[i]
        local desc = struct[f]
        if desc.type == dt.string then
            local str = data[f]
            data[struct.fields[i - 1]] = #str
            if desc.length > 0 then
                if #str > desc.length then
                    str = string.sub(str, 1, desc.length)
                else
                    str = str .. string.rep('0', desc.length - #str)
                end
            end
            data[f] = str
        end
    end
    local ret = {}
    for i = 1, #struct.fields do
        local desc = struct[struct.fields[i]]
         local f = struct.fields[i]
         ret[f] = data[f]
         if desc.type == dt.char or desc.type == dt.uchar then
             -- packet:writeChar(tonumber(data[f]))
             local len = desc.length
            if len and len > 0 then
                for j = 1, len do
                     packet:writeChar(tonumber(data[f][j]))
                 end
             else
                 packet:writeChar(tonumber(data[f]))
            end
         elseif desc.type == dt.short or desc.type == dt.ushort then
            local len = desc.length
            if len and len > 0 then
                for j = 1, len do
                     packet:writeShort(tonumber(data[f][j]))
                 end
             else
                 packet:writeShort(tonumber(data[f]))
            end
         elseif desc.type == dt.int or desc.type == dt.uint then
            local len = desc.length
            if len then
                if len == -1 then
                    len = ret[struct.fields[i - 1]]
                end
                for j = 1, len do
                     packet:writeInt(tonumber(data[f][j]))
                 end
             else
                 packet:writeInt(tonumber(data[f]))
            end
         elseif desc.type == dt.longlong or desc.type == dt.ulonglong then
            local len = desc.length
            if len then
                if len == -1 then
                    len = ret[struct.fields[i - 1]]
                end
                for j = 1, len do
                     packet:writeLongLong(tonumber(data[f][j]))
                 end
             else
                 packet:writeLongLong(tonumber(data[f]))
            end
         elseif desc.type == dt.float then
             packet:writeFloat(tonumber(data[f]))
         elseif desc.type == dt.double then
             packet:writeDouble(tonumber(data[f]))
         elseif desc.type == dt.string or desc.type == dt.binary then
             packet:writeString(data[f])
         elseif desc.type == dt.object then
            if not Protocol[desc.clazz] then
                uq.debug('No such define ' .. desc.clazz)
                return nil
            end
            local len = desc.length
            if len then
                if len == -1 then
                    len = ret[struct.fields[i - 1]]
                end
                for j = 1, len do
                    local packet_object = self:_buildPacket(Protocol[desc.clazz], data[f][j])
                    packet:concat(packet_object, packet_object:size())
                end
            else
                local packet_object = self:_buildPacket(Protocol[desc.clazz], data[f])
                packet:concat(packet_object, packet_object:size())
            end
        end
    end
    return packet
end

cc.exports.network = network
cc.exports.services = cc.exports.services or {}
cc.bind(cc.exports.services, "event")

require('app.network.protocol.init')
require('app.network.EventName')
require('app.network.InitProtocol'):run()