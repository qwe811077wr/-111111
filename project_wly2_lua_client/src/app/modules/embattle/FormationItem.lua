local FormationItem = class("FormationItem", require('app.base.ChildViewBase'))

FormationItem.RESOURCE_FILENAME = "embattle/FormationItem.csb"
FormationItem.RESOURCE_BINDING = {
    ["Text_1"]  = {["varname"] = "_txtTitle"},
    ["Image_1"] = {["varname"] = "_imgBg",["events"] = {{["event"] = "touch",["method"] = "onSelect"}}},
}

function FormationItem:onCreate()
    FormationItem.super.onCreate(self)
end

function FormationItem:setData(index, call_back)
    self._txtTitle:setString('阵容' .. index)
    self._imgBg:setFlippedX(flip)
    self._callback = call_back
    self._index = index
end

function FormationItem:onSelect(event)
    if event.name == "ended" then
        if self._callback then
            self._callback(self._index)
        end
    end
end

function FormationItem:setSelect(flag)
    if flag then
        self:setPositionX(48)
    else
        self:setPositionX(38)
    end
end

return FormationItem