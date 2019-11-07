local WorldMiniMap = class("WorldMiniMap", require('app.base.ChildViewBase'))

WorldMiniMap.RESOURCE_FILENAME = "world/WorldMiniMap.csb"
WorldMiniMap.RESOURCE_BINDING = {
    ["Image_1"]         = {["varname"] = "_bgImg"},
    -- ["g03_0000675_2"]   = {["varname"] = "_posSprite"},
}

function WorldMiniMap:onCreate()
    WorldMiniMap.super.onCreate(self)

    self._drawNode = cc.DrawNode:create()
    self:addChild(self._drawNode)
    self._drawNode:setLineWidth(2)
    services:addEventListener(services.EVENT_NAMES.ON_CHANGE_MINI_MAP_POS, handler(self, self.updateMapPos), "onChangesMiniMapPos")
    self._bgImg:setTouchEnabled(true)
    self._mapLayer = nil
    self._bgImg:addClickEventListener(function(sender)
        local layer_map = uq.ModuleManager:getInstance():show(uq.ModuleManager.WORLD_MAP)
        layer_map:setMapScene(self._mapScene)
    end)
end

function WorldMiniMap:updateCity()
    self._bgImg:removeAllChildren()
    for k, v in pairs(uq.cache.world_war.world_city_info) do
        if next(v) ~= nil and StaticData['world_city'][v.city_id] then
            local img = nil
            if v.crop_id == uq.cache.role.cropsId then
                img = ccui.ImageView:create("img/world/s03_000641_4.png")
            elseif v.crop_id > 0 then
                img = ccui.ImageView:create("img/world/s03_000641_2.png")
            else
                img = ccui.ImageView:create("img/world/s03_000641_0.png")
            end
            self:updateImgPos(img, StaticData['world_city'][v.city_id])
        end
    end
end

function WorldMiniMap:updateImgPos(img, data)
    local size = self._mapScene:getMapContentSize()
    local bg_size = self._bgImg:getContentSize()
    local px = (data.pos_x - size.width / 2)
    local py = (-data.pos_y + size.height / 2)
    img:setPosition(cc.p(px * self._scaleWidth + bg_size.width * 0.5, py * self._scaleHeight + bg_size.height * 0.5))
    self._bgImg:addChild(img)
end

function WorldMiniMap:setMapScene(map_scene)
    self._mapScene = map_scene
    local map_size = self._mapScene:getMapContentSize()
    local size = self:getContentSize()
    self._scaleWidth = size.width / map_size.width
    self._scaleHeight = size.height / map_size.height
    self._width = display.width * self._scaleWidth
    self._height = display.height * self._scaleHeight

    self._drawNode:drawRect(cc.p(-self._width / 2, -self._height / 2), cc.p(self._width / 2, self._height / 2), cc.c4b(0.22, 0.95, 0.07, 1.0))
end

function WorldMiniMap:updateMapPos()
    local info_array = uq.cache.world_war.cur_army_info
    local cur_city = 0
    for k, v in ipairs(info_array) do
        local info = info_array[k]
        if #info.generals > 0 then
            cur_city = info.cur_city
            break
        end
    end
    if cur_city == 0 then
        cur_city = uq.cache.world_war.world_enter_info.city_id
    end
    local city_info = StaticData['world_city'][cur_city]
    if city_info == nil then
        return
    end
    local map_size = self._mapScene:getMapContentSize()
    self:updateCity()
    -- self._posSprite:setPosition(cc.p(city_info.pos_x * self._scaleWidth, (map_size.height - city_info.pos_y) * self._scaleHeight + 1))
end

function WorldMiniMap:setMapScale(scale)
    self._drawNode:setScale(1 / scale)
end

function WorldMiniMap:setDrawNodePosition()
    local pos = self._mapScene:convertToMapNodeSpace(display.center)
    self._drawNode:setPosition(cc.p(pos.x * self._scaleWidth, pos.y * self._scaleHeight))
    local layer_map = uq.ModuleManager:getInstance():getModule(uq.ModuleManager.WORLD_MAP)
    if layer_map then
        layer_map:setDrawNodePosition()
    end
end

function WorldMiniMap:onExit()
    services:removeEventListenersByTag('onChangesMiniMapPos')
    WorldMiniMap.super.onExit(self)
end

return WorldMiniMap