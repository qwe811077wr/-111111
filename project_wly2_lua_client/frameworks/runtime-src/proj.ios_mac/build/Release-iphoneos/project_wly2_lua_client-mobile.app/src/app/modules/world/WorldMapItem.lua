local WorldMapItem = class("WorldMapItem", require('app.base.ChildViewBase'))

WorldMapItem.RESOURCE_FILENAME = "world/WorldMapItem.csb"
WorldMapItem.RESOURCE_BINDING = {
    ["city_name"]            = {["varname"] = "_cityNameLabel"},
    ["state"]                = {["varname"] = "_stateLabel"},
    ["time"]                 = {["varname"] = "_timeLabel"},
}

function WorldMapItem:onCreate()
    WorldMapItem.super.onCreate(self)
end

function WorldMapItem:setData(data)
    self._data = data
    if not self._data then
        return
    end

end

return WorldMapItem