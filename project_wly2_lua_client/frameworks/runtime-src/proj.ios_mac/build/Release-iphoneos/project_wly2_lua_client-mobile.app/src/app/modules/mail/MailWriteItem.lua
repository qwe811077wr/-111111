local MailWriteItem = class("MailWriteItem", require('app.base.ChildViewBase'))

MailWriteItem.RESOURCE_FILENAME = "mail/MailWriteItem.csb"
MailWriteItem.RESOURCE_BINDING = {
    ["Text_1"] = {["varname"] = "_txtName"}
}

function MailWriteItem:onCreate()
    MailWriteItem.super:onCreate()
end

function MailWriteItem:setData(data)
    self._txtName:setString(data)
end

return MailWriteItem