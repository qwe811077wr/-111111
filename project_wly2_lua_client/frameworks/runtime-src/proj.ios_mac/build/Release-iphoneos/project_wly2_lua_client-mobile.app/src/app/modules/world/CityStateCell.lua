local CityStateCell = class("CityStateCell", require('app.base.ChildViewBase'))

CityStateCell.RESOURCE_FILENAME = "world/CityStateCell.csb"
CityStateCell.RESOURCE_BINDING = {
    ["Image_1"]             = {["varname"] = "_imgBg"},
    ["Node_1"]              = {["varname"] = "_nodeBuffAction"},
    ["Text_des"]            = {["varname"] = "_desLabel"},
}

function CityStateCell:ctor(name, params)
    CityStateCell.super.ctor(self, name, params)
end

function CityStateCell:onCreate()
    CityStateCell.super.onCreate(self)
    self:setContentSize(self._imgBg:getContentSize())
end

function CityStateCell:setIndex(index)
    self._desLabel:setHTMLText(StaticData['local_text']['world.city.state.des1' .. index])
    local item = uq.createPanelOnly('world.CityStatusItem')
    item:setType(index)
    self._nodeBuffAction:addChild(item)
end

function CityStateCell:onExit()
    CityStateCell.super.onExit(self)
end

return CityStateCell