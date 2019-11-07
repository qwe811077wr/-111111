local CityFaceList = class("CityFaceList", require('app.base.ChildViewBase'))

CityFaceList.RESOURCE_FILENAME = "area/CityFaceList.csb"
CityFaceList.RESOURCE_BINDING = {
    --["Panel_1"]    = {["varname"] = "_panelSelect"},
}

function CityFaceList:onCreate()
    CityFaceList.super.onCreate(self)

    self._itemList = {}
    for i = 1, 3 do
        local panel = uq.createPanelOnly('area.CityFaceItem')
        panel:setPosition(cc.p((i - 2)*192, 0))
        table.insert(self._itemList, panel)
        self:addChild(panel)
    end
end

function CityFaceList:setData(index)
    self._index = index

    self._itemList[1]:setData((self._index - 1) * 3 + 1)
    self._itemList[2]:setData((self._index - 1) * 3 + 2)
    self._itemList[3]:setData((self._index - 1) * 3 + 3)
end

function CityFaceList:setSelected(index, flag)
    self._itemList[1]:setSelected(false)
    self._itemList[2]:setSelected(false)
    self._itemList[3]:setSelected(false)

    local item_index = index - (self._index - 1) * 3
    self._itemList[item_index]:setSelected(flag)
end

function CityFaceList:setCurCityData(data)
    self._cityData = data

    self._itemList[1]:setCurCityData(self._cityData)
    self._itemList[2]:setCurCityData(self._cityData)
    self._itemList[3]:setCurCityData(self._cityData)
end

return CityFaceList