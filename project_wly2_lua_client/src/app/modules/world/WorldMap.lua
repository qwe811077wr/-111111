local WorldMap = class("WorldMap", require("app.base.ModuleBase"))

WorldMap.RESOURCE_FILENAME = "world/WorldMap.csb"

WorldMap.RESOURCE_BINDING  = {
    ["img_bg_adapt"]                            ={["varname"] = "_bgImg"},
    ["Panel_1/Node_city"]                       ={["varname"] = "_nodeCity"},
    ["Panel_1/Node_draw"]                       ={["varname"] = "_nodeDraw"},
    ["Panel_1/Node_5"]                          ={["varname"] = "_nodeLeftTop"},
    ["Panel_1/node_right"]                      ={["varname"] = "_nodeRightMiddle"},
    ["Panel_1/node_right/Image_7"]              ={["varname"] = "_imgPress"},
    ["Panel_1/Node_5/back_btn"]                 ={["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onCloseBtn"}}},
    ["Panel_1/node_right/Image_22"]             ={["varname"] = "_imgArrow"},
    ["Panel_1/node_right/ScrollView_1"]         ={["varname"] = "_scrollView"},
    ["leader_node"]                             ={["varname"] = "_nodeInfo"},
    ["leader_node/city_name"]                   ={["varname"] = "_nameCityLabel"},
    ["leader_node/btn_moveto"]                  ={["varname"] = "_btnMoveTo",["events"] = {{["event"] = "touch",["method"] = "onMoveToBtn"}}},
}
function WorldMap:ctor(name, args)
    WorldMap.super.ctor(self,name,args)
    self._dataArray = {}
end

function WorldMap:init()
    self:parseView()
    self:centerView()
    self:adaptBgSize()
    self:adaptNode()
    self._btnClose:setPressedActionEnabled(true)
    self._btnMoveTo:setPressedActionEnabled(true)
    self._nodeInfo:setVisible(false)
    self._drawNode = cc.DrawNode:create()
    self._nodeDraw:addChild(self._drawNode)
    self._drawNode:setLineWidth(2)
    self._isShow = false
    self._nodeRightMiddle:setPositionX(display.width + 180)
    self._nodeCity:setPosition(cc.p(display.width * 0.5, display.height * 0.5))
    self._imgPress:setTouchEnabled(true)
    self._imgPress:addClickEventListenerWithSound(function()
        self._isShow = not self._isShow
        self._nodeRightMiddle:stopAllActions()
        if self._isShow then
            self._nodeRightMiddle:runAction(cc.MoveTo:create(0.05, cc.p(display.width, display.height * 0.5)))
            self._imgArrow:setRotation(180)
        else
            self._nodeRightMiddle:runAction(cc.MoveTo:create(0.05, cc.p(display.width + 180, display.height * 0.5)))
            self._imgArrow:setRotation(0)
        end
    end)
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self, self._onTouchBegin), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self._onTouchMove), cc.Handler.EVENT_TOUCH_MOVED)
    local event_dispatcher = self._bgImg:getEventDispatcher()
    event_dispatcher:addEventListenerWithSceneGraphPriority(listener, self._bgImg)
    self:initUi()
end

function WorldMap:_onTouchBegin(touches, event)
    local touch_point = touches:getLocation()
    local pos = self._bgImg:convertToNodeSpace(touch_point)
    self:updateScrollMapPos(pos)
    self._nodeInfo:setVisible(false)
    return true
end

function WorldMap:_onTouchMove(touches, event)
    local touch_point = touches:getLocation()
    local pos = self._bgImg:convertToNodeSpace(touch_point)
    self:updateScrollMapPos(pos)
end

function WorldMap:updateScrollMapPos(pos)
    local size = self._bgImg:getContentSize()
    local mini_map_pos = cc.p(pos.x - size.width * 0.5, pos.y - size.height * 0.5)
    self:setDrawPosition(mini_map_pos.x, mini_map_pos.y)
end

function WorldMap:setDrawNodePosition()
    local pos = self._mapScene:convertToMapNodeSpace(display.center)
    self._drawNode:setPosition(cc.p(pos.x * self._scaleWidth, pos.y * self._scaleHeight))
end

function WorldMap:initUi()
    self._itemArray = {}
    self._scrollView:removeAllChildren()
    local power_array = {}
    local crop_array = {}
    for k, v in pairs(uq.cache.world_war.world_city_info) do
        if v.crop_id > 0 then
            local crop_info = uq.cache.crop:getCropDataById(v.crop_id)
            if power_array[v.crop_id] == nil then
                power_array[v.crop_id] = true
                if v.crop_id == uq.cache.role.cropsId then
                    table.insert(crop_array, 1, v.crop_id)
                else
                    table.insert(crop_array, v.crop_id)
                end
            end
        end
    end
    local node = cc.CSLoader:createNode("world/WorldMapPowerItem.csb")
    local pos_y = #crop_array * 92
    if pos_y < self._scrollView:getContentSize().height then
        pos_y = self._scrollView:getContentSize().height
    end
    self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width, pos_y))
    pos_y = pos_y - 46
    for k, v in ipairs(crop_array) do
        local crop_info = uq.cache.crop:getCropDataById(v)
        local item = node:getChildByName("Panel_1"):clone()
        item:getChildByName("power_name"):setString(crop_info.name)
        local flag_info = StaticData['world_flag'][crop_info.color_id]
        if flag_info then
            item:getChildByName("Image_9"):loadTexture("img/create_power/" .. flag_info.color)
            item:getChildByName("txt_name1"):setString(crop_info.power_name)
        end
        item["crop_id"] = v
        item:getChildByName("img_state"):setVisible(v == uq.cache.role.cropsId)
        item:setTouchEnabled(true)
        item:addClickEventListenerWithSound(function(sender)
            for k, v in ipairs(self._itemArray) do
                v:getChildByName("img_state"):setVisible(v["crop_id"] == sender["crop_id"])
            end
            local crop_info = uq.cache.crop:getCropDataById(sender["crop_id"])
            if crop_info == nil then
                return
            end
            local xml_info = StaticData['world_city'][crop_info.city_id]
            local size = self._mapScene:getMapContentSize()
            local px = (xml_info.pos_x - size.width / 2)
            local py = (-xml_info.pos_y + size.height / 2)
            self:setDrawPosition(px * self._scaleWidth, py * self._scaleHeight)
        end)
        item:setPosition(cc.p(140, pos_y))
        pos_y = pos_y - 92
        table.insert(self._itemArray, item)
        self._scrollView:addChild(item)
    end
    self._scrollView:setScrollBarEnabled(false)
end

function WorldMap:updateCityPos()
    self._nodeCity:removeAllChildren()
    local node = cc.CSLoader:createNode("world/WorldMapItem.csb")
    local node2 = cc.CSLoader:createNode("world/WorldMapItem2.csb")
    for k, v in pairs(uq.cache.world_war.world_city_info) do
        local xml_info = StaticData['world_city'][v.city_id]
        if next(v) ~= nil and xml_info then
            if v.crop_id > 0 then
                local item = node:getChildByName("Panel_1"):clone()
                local crop_info = uq.cache.crop:getCropDataById(v.crop_id)
                local is_show = (crop_info.city_id == v.city_id)
                item:getChildByName("city_name"):setVisible(is_show)
                item:getChildByName("img_state"):setVisible(is_show)
                item:getChildByName("Image_battle"):setVisible(v.battle_time > 0)
                item:getChildByName("city_name"):setString(xml_info.name)
                if v.crop_id == uq.cache.role.cropsId then
                    item:getChildByName("img_state"):loadTexture("img/create_power/s03_0007128.png")
                else
                    item:getChildByName("img_state"):loadTexture("img/create_power/s03_0007127.png")
                end
                item:getChildByName("Button_1")["city_id"] = v.city_id
                local flag_info = StaticData['world_flag'][crop_info.color_id]
                if flag_info then
                    item:getChildByName("txt_name1"):setString(crop_info.power_name)
                    item:getChildByName("Button_1"):loadTextures("img/create_power/" .. flag_info.color, "img/create_power/" .. flag_info.color)
                    item:getChildByName("Button_1"):setPressedActionEnabled(true)
                    item:getChildByName("Button_1"):addClickEventListenerWithSound(function(sender)
                        local city_id = sender["city_id"]
                        local xml_info = StaticData['world_city'][city_id]
                        self:showPressCityInfo(xml_info)
                    end)
                end
                self._nodeCity:addChild(item)
                self:setCityPosition(xml_info, item)
            else
                local item = node2:getChildByName("Panel_1"):clone()
                item:getChildByName("Image_battle"):setVisible(v.battle_time > 0)
                item:getChildByName("Button_1"):loadTextures("img/create_power/s03_0007102.png", "img/create_power/s03_0007102.png")
                item:getChildByName("Button_1")["city_id"] = v.city_id
                item:getChildByName("Button_1"):setPressedActionEnabled(true)
                item:getChildByName("Button_1"):addClickEventListenerWithSound(function(sender)
                    local city_id = sender["city_id"]
                    local xml_info = StaticData['world_city'][city_id]
                    self:showPressCityInfo(xml_info)
                end)
                self._nodeCity:addChild(item)
                self:setCityPosition(xml_info, item)
            end
        end
    end
end

function WorldMap:setCityPosition(data, node)
    local size = self._mapScene:getMapContentSize()
    local px = (data.pos_x - size.width / 2)
    local py = (-data.pos_y + size.height / 2)
    node:setPosition(cc.p(px * self._scaleWidth, py * self._scaleHeight))
end

function WorldMap:showPressCityInfo(xml_info)
    self._pressInfo = xml_info
    local size = self._mapScene:getMapContentSize()
    local px = (xml_info.pos_x - size.width / 2)
    local py = (-xml_info.pos_y + size.height / 2)
    self._nodeInfo:setVisible(true)
    local pos_x = px * self._scaleWidth
    local pos_y = py * self._scaleHeight
    pos_x = pos_x + 140
    if pos_x > display.width * 0.5 - 280 then
        pos_x = display.width * 0.5 - 280
    end
    self._nodeInfo:setPosition(cc.p(pos_x, pos_y))
    self._nameCityLabel:setString(xml_info.name)
    self:setDrawPosition(px * self._scaleWidth, py * self._scaleHeight)
end

function WorldMap:setDrawPosition(pos_x, pos_y)
    if pos_x < -display.width * 0.5 + display.width / 8 then
        pos_x = -display.width * 0.5 + display.width / 8
    elseif pos_x > display.width * 0.5 - display.width / 8 then
        pos_x = display.width * 0.5 - display.width / 8
    end
    if pos_y < -display.height * 0.5 + display.height / 8 then
        pos_y = -display.height * 0.5 + display.height / 8
    elseif pos_y > display.height * 0.5 - display.height / 8 then
        pos_y = display.height * 0.5 - display.height / 8
    end
    self._drawNode:setPosition(cc.p(pos_x, pos_y))
end

function WorldMap:setMapScene(map_scene)
    self._mapScene = map_scene
    local map_size = self._mapScene:getMapContentSize()
    self._scaleWidth = display.width / map_size.width
    self._scaleHeight = display.height / map_size.height
    self._drawNode:drawRect(cc.p(-display.width / 8, -display.height / 8), cc.p(display.width / 8, display.height / 8), cc.c4b(0.22, 0.95, 0.07, 1.0))
    self:updateCityPos()
    self:setDrawNodePosition()
end

function WorldMap:onMoveToBtn(event)
    if event.name ~= "ended" then
        return
    end
    local size = self._mapScene:getMapContentSize()
    local px = (self._pressInfo.pos_x - size.width / 2)
    local py = (-self._pressInfo.pos_y + size.height / 2)
    services:dispatchEvent({name = services.EVENT_NAMES.ON_PRESS_MINI_MAP_POS, pos = cc.p(px, py)})
    self:disposeSelf()
end

function WorldMap:onCloseBtn(event)
    if event.name ~= "ended" then
        return
    end
    self:disposeSelf()
end

function WorldMap:dispose()
    WorldMap.super.dispose(self)
end

return WorldMap