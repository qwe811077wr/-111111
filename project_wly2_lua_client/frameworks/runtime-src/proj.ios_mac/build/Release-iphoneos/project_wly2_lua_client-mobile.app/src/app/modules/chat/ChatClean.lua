local ChatClean = class("ChatClean", require('app.base.PopupBase'))

ChatClean.RESOURCE_FILENAME = "chat/ChatClean.csb"
ChatClean.RESOURCE_BINDING = {
    ["Button_1"]  = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onClose"}}},
    ["Button_2"]  = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onClose"}}},
    ["Button_2_0"]  = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onConfirm"}}},
}

function ChatClean:ctor(name, params)
    ChatClean.super.ctor(self, name, params)
end

function ChatClean:init()
    self._chatData = nil

    self:parseView()
    self:setLayerColor(0.4)
    self:centerView()
end

function ChatClean:setData(data)
end

function ChatClean:onClose(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

function ChatClean:onConfirm(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

return ChatClean