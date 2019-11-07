local ChatInfo = class("ChatInfo", require('app.base.PopupBase'))

ChatInfo.RESOURCE_FILENAME = "chat/ChatInfo.csb"
ChatInfo.RESOURCE_BINDING = {
    --["Text_1_0"]   = {["varname"]="_txtName"},
}

function ChatInfo:ctor(name, params)
    ChatInfo.super.ctor(self, name, params)
end

function ChatInfo:init()
    self._chatData = nil

    self:parseView()
    self:setLayerColor(0)
end

function ChatInfo:setData(data)
end

return ChatInfo