local MailRewardItem = class("MailRewardItem", require('app.base.ChildViewBase'))

MailRewardItem.RESOURCE_FILENAME = "mail/MailRewardItem.csb"
MailRewardItem.RESOURCE_BINDING = {
    ["Text_12"]={["varname"]="_txtNum"},
    ["Panel_item/Item_0004_5"]={["varname"]="_itemPic"}
}

function MailRewardItem:onCreate()
    MailRewardItem.super.onCreate(self)
end

return MailRewardItem