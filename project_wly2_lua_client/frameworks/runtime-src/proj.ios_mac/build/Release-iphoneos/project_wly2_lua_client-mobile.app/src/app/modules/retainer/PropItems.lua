local AddItems = class("PropItems", require('app.base.ChildViewBase'))

AddItems.RESOURCE_FILENAME = "retainer/PropItems.csb"
AddItems.RESOURCE_BINDING = {
    ["Node_1/Image_1"]                   = {["varname"]="_imgBg"},
    ["Node_1/Image_2"]                   = {["varname"]="_imgIcon"},
    ["Node_1/Text_1"]                    = {["varname"]="_txtNum"},
}

function AddItems:onCreate()
    AddItems.super.onCreate(self)
end

function AddItems:setData(data)
    local info = StaticData.getCostInfo(data.type,data.id)
    if info == nil then
        return
    end
    local num = data.num or 0
    local item_quality_info = StaticData['types'].ItemQuality[1].Type[tonumber(info.qualityType)]
    if item_quality_info then
        self._imgBg:loadTexture("img/common/ui/" .. item_quality_info.qualityIcon)
    end
    self._imgIcon:loadTexture("img/common/item/" .. info.icon)
    if num > 0 then
        self._txtNum:setString(tostring(num))
    else
        self._txtNum:setString("0")
    end
end

return AddItems