local CollectItem = class("CollectItem", require('app.base.ChildViewBase'))

CollectItem.RESOURCE_FILENAME = "collect/CollectConditionItem.csb"
CollectItem.RESOURCE_BINDING = {
    ["Sprite_1"]             = {["varname"] = "_iconSprite"},
    ["Image_to"]             = {["varname"] = "_imgTo",["events"] = {{["event"] = "touch",["method"] = "_onImgGoto"}}},
    ["des"]                  = {["varname"] = "_desLabel"},
    ["Image_ok"]             = {["varname"] = "_imgOk"},
}

function CollectItem:ctor(name, params)
    CollectItem.super.ctor(self, name, params)
end

function CollectItem:onCreate()
    CollectItem.super.onCreate(self)
end

function CollectItem:setInfo(info)
    self._info = info
    local data = StaticData.getCostInfo(self._info.type, self._info.id)
    local max_num = uq.cache.role:getResNum(self._info.type, self._info.id)
    self._desLabel:setString(self._info.num .. "/" .. max_num)
    if self._info.num <= max_num then
        self._desLabel:setTextColor(uq.parseColor("#69ec2d"))
    else
        self._desLabel:setTextColor(uq.parseColor("#f22926"))
    end
    self._iconSprite:setTexture("img/common/ui/" .. data.miniIcon)
    self._imgTo:setVisible(self._info.num > max_num)
    self._imgOk:setVisible(self._info.num <= max_num)
end

function CollectItem:getInfo()
    return self._info
end

function CollectItem:_onImgGoto(event)
    if event.name ~= "ended" then
        return
    end

end


return CollectItem