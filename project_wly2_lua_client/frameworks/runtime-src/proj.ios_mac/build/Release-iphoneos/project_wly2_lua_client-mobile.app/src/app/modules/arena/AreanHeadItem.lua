local ArenaHeadItem = class("ArenaHeadItem", require('app.base.ChildViewBase'))

ArenaHeadItem.RESOURCE_FILENAME = 'arena/ArenaRole.csb'
ArenaHeadItem.RESOURCE_BINDING = {
    ["img"]                    = {["varname"] = "_imgSprite"}
}

function ArenaHeadItem:ctor(name, params)
    ArenaHeadItem.super.ctor(self, name, params)
end

return ArenaHeadItem