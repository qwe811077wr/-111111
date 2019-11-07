local LevelItems = class("LevelItems", require('app.base.ChildViewBase'))

LevelItems.RESOURCE_FILENAME = "activity/LevelItems.csb"
LevelItems.RESOURCE_BINDING = {
    ["Node_1"]            = {["varname"] = "_nodeShow"},
    ["Node_1/down_fnt"]   = {["varname"] = "_fntName"},
    ["Node_3/up_fnt"]     = {["varname"] = "_fntName1"},
    ["Node_1/Sprite_1"]   = {["varname"] = "_spriteBg"},
    ["Node_3"]            = {["varname"] = "_nodeSelect"},
    ["Node_4"]            = {["varname"] = "_nodeNext"},
    ["Node_5"]            = {["varname"] = "_nodeRed"},
    ["Image_2"]           = {["varname"] = "_imgLock"},
}

function LevelItems:onCreate()
    LevelItems.super.onCreate(self)
    self:parseView()
end

function LevelItems:setData(data, index, next_id, select_id)
    local data = data or {}
    if next(data) == nil then
        return
    end
    self._index = index
    self._selectId = select_id
    self._nodeShow:setVisible(select_id ~= index)
    self._nodeSelect:setVisible(select_id == index)
    self._imgLock:setVisible(next_id ~= 0 and index > next_id)
    self._nodeNext:setVisible(next_id == index)
    self._fntName:setString(tostring(data.level))
    self._fntName1:setString(tostring(data.level))
    self:refreshRed()
end

function LevelItems:refreshLayer(select_id)
    if not self._index or not select_id then
        return
    end
    self._nodeShow:setVisible(select_id ~= self._index)
    self._nodeSelect:setVisible(select_id == self._index)
    self:refreshRed()
end

function LevelItems:refreshRed()
    self._nodeRed:setVisible(self._index and uq.cache.achievement:isRedStatusLevelById(self._index))
end

return LevelItems