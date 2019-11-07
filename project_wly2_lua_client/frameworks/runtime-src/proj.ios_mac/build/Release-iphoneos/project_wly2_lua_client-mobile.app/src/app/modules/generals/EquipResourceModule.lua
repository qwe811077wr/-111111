local EquipResourceModule = class("EquipResourceModule", require('app.base.PopupBase'))

EquipResourceModule.RESOURCE_FILENAME = "generals/EquipTypeFrom.csb"
EquipResourceModule.RESOURCE_BINDING = {
    ["ScrollView_1"]                 = {["varname"] = "_scrollView"},
    ["Button_1"]                     = {["varname"] = "_btnExit", ["events"] = {{["event"] = "touch",["method"] = "_onTouchExit"}}},
}

function EquipResourceModule:ctor(name, params)
    EquipResourceModule.super.ctor(self, name, params)
    self._type = params.type
end

function EquipResourceModule:init()
    self:parseView()
    self:centerView()
    self:initUi()
    self:setLayerColor()
end

function EquipResourceModule:initUi()
    self._scrollView:removeAllChildren()
    local size = self._scrollView:getContentSize()

    self._allData = uq.cache.equipment:getAllXmlEquipByType(self._type)
    if not self._allData and next(self._allData) == nil then
        return
    end
    self._scrollView:removeAllChildren()
    local height = #self._allData * 130
    self._scrollView:setInnerContainerSize(cc.size(size.width, height))
    for k, v in ipairs(self._allData) do
        local item = uq.createPanelOnly("generals.EquipResourceItem")
        local item_size = item:getChildByName("Layer"):getContentSize()
        item:setInfo(v)
        item:setPosition(cc.p(size.width / 2, height - item_size.height / 2))
        height = height - 130
        self._scrollView:addChild(item)
    end
end

function EquipResourceModule:dispose()
    EquipResourceModule.super.dispose(self)
end

return EquipResourceModule