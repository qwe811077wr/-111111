local CityFaceItem = class("CityFaceItem", require('app.base.ChildViewBase'))

CityFaceItem.RESOURCE_FILENAME = "area/CityFaceItem.csb"
CityFaceItem.RESOURCE_BINDING = {
    ["Image_2"]    = {["varname"] = "_imgSelect"},
    ["g03_0188_4"] = {["varname"] = "_spriteFlag"},
    ["qycc_9_3"]   = {["varname"] = "_spriteCity"},
    ["Text_1"]     = {["varname"] = "_txtName"},
    ["Image_1"]    = {["varname"] = "_imgBg",["events"] = {{["event"] = "touch",["method"] = "onBgTouch"}}},
}

function CityFaceItem:onCreate()
    CityFaceItem.super.onCreate(self)
    self._imgBg:setSwallowTouches(false)
end

function CityFaceItem:setData(index)
    self._index = index

    local config = StaticData['city_facades'][self._index]
    self._spriteCity:setTexture('img/areaicon/' .. config.file .. '.png')
    self._txtName:setString(config.name)
end

function CityFaceItem:setSelected(flag)
    self._imgSelect:setVisible(flag)
end

function CityFaceItem:setCurCityData(data)
    self._spriteFlag:setVisible(data.city_skin == self._index)
end

function CityFaceItem:onBgTouch(event)
    if event.name == 'ended' then
        self:setSelected(true)

        local area_view = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.AREA_CITY_FACE)
        if area_view then
            area_view:itemSelected(self._index)
        end
    end
end

return CityFaceItem