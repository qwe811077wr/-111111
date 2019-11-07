
local TableViewBase = class("TableViewBase", require('app.base.ChildViewBase'))

function TableViewBase:ctor(name)
    TableViewBase.super.ctor(self,name)
end

function TableViewBase:dispose()

end

return TableViewBase
