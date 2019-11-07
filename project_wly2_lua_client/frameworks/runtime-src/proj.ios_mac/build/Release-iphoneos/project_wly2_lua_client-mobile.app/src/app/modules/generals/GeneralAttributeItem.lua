local GeneralAttributeItem = class("GeneralAttributeItem", require('app.base.ChildViewBase'))

GeneralAttributeItem.RESOURCE_FILENAME = "generals/GeneralsAttributeItem.csb"
GeneralAttributeItem.RESOURCE_BINDING = {
    ["label_0_0"]                     = {["varname"] = "_txtTitle"},
    ["Node_2"]                        = {["varname"] = "_nodeBase"},
    ["Node_2/Panel_1"]                = {["varname"] = "_panelItem"},
}

function GeneralAttributeItem:ctor(name, params)
    GeneralAttributeItem.super.ctor(self, name, params)
end

function GeneralAttributeItem:onCreate()
    GeneralAttributeItem.super.onCreate(self)
    self._panelItem:setTag(1)
    self:addButtonEvent(self._panelItem)
    self._arrItems = {self._panelItem}
end

function GeneralAttributeItem:setCallBack(call_back)
    self._callback = call_back
end

function GeneralAttributeItem:setInfo(info)
    self._info = info
    if not info then
        return
    end
    self:refreshPage()
end

function GeneralAttributeItem:refreshPage()
    self._txtTitle:setString(self._info.title)
    for k, v in ipairs(self._info.List) do
        local item = self._arrItems[k]
        if not item then
            item = self._panelItem:clone()
            item:setTag(k)
            self:addButtonEvent(item)
            local size = item:getContentSize()
            item:setPositionY(-(size.height + 2) * (k - 1))
            table.insert(self._arrItems, item)
            self._nodeBase:addChild(item)
        end
        item:setVisible(true)
        self:setItemInfo(item, v)
    end
    for i = #self._info.List + 1, #self._arrItems do
        self._arrItems[i]:setVisible(false)
    end
end

function GeneralAttributeItem:addButtonEvent(item)
    local button = item:getChildByName("Button")
    button:addClickEventListenerWithSound(function(sender)
        local parent = sender:getParent()
        local index = parent:getTag()
        local info = self._info.List[index]
        local pos_x, pos_y = sender:getPosition()
        local pos = parent:convertToWorldSpace(cc.p(pos_y, pos_y))
        info.pos = pos
        if self._callback then
            self._callback(info)
        end
    end)
end

function GeneralAttributeItem:setItemInfo(item, info)
    local title = item:getChildByName("Text_1")
    title:setString(info.name)
    local text = item:getChildByName("Text_2")
    local value = uq.cache.generals:getNumByEffectType(info.effectType, info.value)
    text:setString(value)
end

return GeneralAttributeItem