local FilterChoiceModule = class("FilterChoiceModule", require('app.base.ChildViewBase'))

FilterChoiceModule.RESOURCE_FILENAME = "embattle/GeneralFilterModule.csb"
FilterChoiceModule.RESOURCE_BINDING = {
    ["Image_1"]                     = {["varname"] = "_imgBg"},
    ["Panel_1"]                     = {["varname"] = "_panelItem"},
}

function FilterChoiceModule:ctor(name, args)
    FilterChoiceModule.super.ctor(self, name, args)
    self._info = args.info
    self._siftTab = {"GeneralGrade", "SkillType", "Soldier"}
end

function FilterChoiceModule:init()
    self:initPage()
end

function FilterChoiceModule:initPage()
    if not self._info then
        return
    end
    local data = StaticData['types'][self._siftTab[self._info.tab]]
    if not data then
        return
    end
    local img_size = self._imgBg:getContentSize()
    local pos_x, pos_y = self._panelItem:getPosition()
    local size = self._panelItem:getContentSize()
    self._panelItem:addClickEventListenerWithSound(function()
        self._info.type = nil
        for k, v in ipairs(self._panelItems) do
            v:getChildByName("Panel"):setVisible(k == 1)
        end
        if self._info.callback then
            self._info.callback(nil, self._info.tab)
        end
        self:setVisible(false)
    end)
    self._panelItem:getChildByName("Panel"):setVisible(self._info ~= nil)

    self._panelItems = {self._panelItem}
    for k, v in ipairs(data[1].Type) do
        if self._info.tab == 3 and v.ident > 5 then
            break
        end
        local item = self._panelItem:clone()
        item:addClickEventListener(handler(v, function(info)
            self._info.type = v.ident
            for k, v in ipairs(self._panelItems) do
                v:getChildByName("Panel"):setVisible(k - 1 == self._info.type)
            end
            if self._info.callback then
                self._info.callback(v.ident, self._info.tab, v.name)
            end
            self:setVisible(false)
        end))
        pos_y = pos_y - size.height
        item:setPosition(cc.p(pos_x, pos_y))
        item:getChildByName("Text"):setString(v.name)
        item:getChildByName("Panel"):setVisible(self._info.type == v.ident)
        table.insert(self._panelItems, item)
        self._view:addChild(item)
    end
    self._imgBg:setContentSize(cc.size(140, -pos_y + size.height))
end

function FilterChoiceModule:setInfo(info)
    self._info = info
    self:initPage()
end

function FilterChoiceModule:dispose()
    FilterChoiceModule.super.dispose(self)
end

return FilterChoiceModule