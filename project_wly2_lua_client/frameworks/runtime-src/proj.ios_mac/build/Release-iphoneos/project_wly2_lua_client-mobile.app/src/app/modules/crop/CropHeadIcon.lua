local CropHeadIcon = class("CropHeadIcon", require('app.base.ChildViewBase'))

CropHeadIcon.RESOURCE_FILENAME = "crop/CropHeadIcon.csb"
CropHeadIcon.RESOURCE_BINDING = {
    ["Node_1"]      = {["varname"]="_node"},
    ["Image_1"]     = {["varname"]="_imgBg"},
    ["Sprite_1"]    = {["varname"]="_sprHead"},
    ["Sprite_3"]    = {["varname"]="_sprBg"},
    ["Image_2"]     = {["varname"]="_imgSel"},
}

function CropHeadIcon:onCreate()
    CropHeadIcon.super.onCreate(self)
    self.data = {}
end

function CropHeadIcon:setData(data, select_id)
    self.data = data or {}
    self._node:setVisible(next(self.data) ~= nil)
    self:refreshSelected(select_id)
    if next(self.data) == nil then
        return
    end
    self._sprHead:setTexture("img/crop/" .. self.data.icon)
    self._sprBg:setTexture("img/crop/" .. self.data["end"])
end

function CropHeadIcon:refreshSelected(id)
    if not self.data or not self.data.ident then
        return
    end
    self._imgSel:setVisible(self.data.ident ~= id)
    self._imgBg:setVisible(self.data.ident == id)
end

return CropHeadIcon