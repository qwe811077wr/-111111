local ServerData = class("ServerData")

function ServerData:ctor()
    self.server_client_offtime = 0
end

function ServerData:getServerTime()
    return self.server_client_offtime + os.time()
end

return ServerData