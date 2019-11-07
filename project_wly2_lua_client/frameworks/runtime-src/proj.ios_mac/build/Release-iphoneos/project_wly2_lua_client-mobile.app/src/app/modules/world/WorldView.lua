local WorldView = class("WorldView", require('app.base.ChildViewBase'))
local EquipItem = require("app.modules.common.EquipItem")

WorldView.RESOURCE_FILENAME = "world/WorldView.csb"
WorldView.RESOURCE_BINDING = {
    ["node_left_middle"]                                                            = {["varname"] = "_nodeLeftMiddle"},
    ["node_left_middle/Node_left_view"]                                             = {["varname"] = "_leftViewNode"},
    ["node_left_middle/Node_left_info"]                                             = {["varname"] = "_leftInfoNode"},
    ["node_left_middle/Node_left_view/Node_17"]                                     = {["varname"] = "_taskNode"},
    ["node_left_middle/Node_left_view/guozheng/button_guozheng"]                    = {["varname"] = "_btnGuozheng",["events"] = {{["event"] = "touch",["method"] = "onGuozheng"}}},
    ["node_left_middle/Node_left_view/chengchi/Button_1"]                           = {["varname"] = "_btnCity",["events"] = {{["event"] = "touch",["method"] = "onCity"}}},
    ["node_left_middle/Node_left_view/Node_report/btn_report"]                      = {["varname"] = "_btnReport",["events"] = {{["event"] = "touch",["method"] = "onReport"}}},
    ["node_left_middle/Node_left_view/Node_report/btn_report/Image_num"]            = {["varname"] = "_reportRed"},
    ["node_left_middle/Node_left_view/Node_report/btn_report/Image_num/Text_num"]   = {["varname"] = "_reportNumLabel"},
    ["node_left_middle/Node_left_view/Node_7"]                                      = {["varname"] = "_nodeGuozheng"},

    ["node_left_middle/Node_left_info/country"]                                     = {["varname"] = "_spriteColor"},
    ["node_left_middle/Node_left_info/txt_name1"]                                   = {["varname"] = "_colorLabel"},
    ["node_left_middle/Node_left_info/txt_name"]                                    = {["varname"] = "_cropNameLabel"},
    ["node_left_middle/Node_left_info/city_type"]                                   = {["varname"] = "_cityTypeLabel"},
    ["node_left_middle/Node_left_info/city_name"]                                   = {["varname"] = "_cityNameLabel"},
    ["node_left_middle/Node_left_info/ScrollView_1"]                                = {["varname"] = "_scrollView"},
    ["node_left_middle/Node_left_info/text_form"]                                   = {["varname"] = "_formLabel"},
    ["node_left_middle/Node_left_info/text_def"]                                    = {["varname"] = "_defCityLabel"},
    ["node_left_middle/Node_left_info/Text_des1"]                                   = {["varname"] = "_desLabel1"},
    ["node_left_middle/Node_left_info/Text_des2"]                                   = {["varname"] = "_desLabel2"},
    ["node_left_middle/Node_left_info/Text_des3"]                                   = {["varname"] = "_desLabel3"},
    ["node_left_middle/Node_left_info/text_battle"]                                 = {["varname"] = "_battleLabel"},
    ["node_left_middle/Node_left_info/text_form_add"]                               = {["varname"] = "_formAddLabel"},
    ["node_left_middle/Node_left_info/text_def_add"]                                = {["varname"] = "_defCityAddLabel"},
    ["node_left_middle/Node_left_info/text_battle_add"]                             = {["varname"] = "_battleAddLabel"},

    ["node_right_middle"]                                                           = {["varname"] = "_nodeRightMiddle"},
    ["node_right_middle/Node_right_view"]                                           = {["varname"] = "_rightMiddleViewNode"},
    ["node_right_middle/Node_right_view/army_num"]                                  = {["varname"] = "_armyNumLabel"},

    ["Node_right_top"]                                                              = {["varname"] = "_nodeRightTop"},
    ["Node_right_top/Node_right_top_info"]                                          = {["varname"] = "_nodeRightTopInfo"},
    ["Node_right_top/Node_right_top_info/Button_exit"]                              = {["varname"] = "_btnExit",["events"] = {{["event"] = "touch",["method"] = "onBtnExit"}}},

    ["node_bottom_middle"]                                                          = {["varname"] = "_nodeBottomMiddle"},
    ["node_bottom_middle/Node_bottom_middle_info"]                                  = {["varname"] = "_nodeBottomMiddelInfo"},
    ["node_bottom_middle/Node_bottom_middle_info/ScrollViewleft"]                   = {["varname"] = "_scrollViewLeft"},
    ["node_bottom_middle/Node_bottom_middle_info/Image_8"]                          = {["varname"] = "_rewardImg"},
    ["node_bottom_middle/Node_bottom_middle_info/Text_add"]                         = {["varname"] = "_rewardAddLabel"},
    ["node_bottom_middle/Node_bottom_middle_info/ScrollViewright"]                  = {["varname"] = "_scrollViewRight"},
}

function WorldView:onCreate()
    WorldView.super.onCreate(self)
    self._taskDialogShow = true
    self:setContentSize(display.size)
    self:setPosition(display.center)
    self._nodeGuozheng:setVisible(false)
    self._nodeBottomMiddle:setPosition(display.top_bottom)
    self._nodeRightMiddle:setPosition(cc.p(display.right_center.x - uq.getAdaptOffX(), display.right_center.y))
    self._nodeLeftMiddle:setPosition(cc.p(display.left_center.x + uq.getAdaptOffX(), display.left_center.y))
    self._nodeRightTop:setPosition(display.right_top)
    self._leftInfoNode:setPosition(cc.p(-500, 0))
    self._nodeRightTopInfo:setPosition(cc.p(0, 200))
    self._nodeBottomMiddelInfo:setPosition(cc.p(0, -200))
    self._taskView = uq.createPanelOnly('world.WorldTask')
    self._taskNode:addChild(self._taskView)
    self._cityNameInfoArray = {self._desLabel1, self._desLabel2, self._desLabel3}
    self._cityDesInfoArray = {self._battleLabel, self._defCityLabel, self._formLabel}
    self._cityAddInfoArray = {self._battleAddLabel, self._defCityAddLabel, self._formAddLabel}
    services:addEventListener(services.EVENT_NAMES.ON_BATTLE_REPORT_NOTIFY, handler(self, self._onBattleReportNotify), "onBattleReportLoadByWorldView")
    services:addEventListener(services.EVENT_NAMES.ON_WORLD_CITY_SELECT, handler(self, self._onWorldCitySelect), "onWorldCitySelect")
    self:initRightView()
    self._rewardImg:setTouchEnabled(true)
    self._rewardImg:addClickEventListener(function(sender)
        uq.ModuleManager:getInstance():show(uq.ModuleManager.WORLD_INFO, {info = uq.cache.world_war.battle_city_info})
    end)
end

function WorldView:showView(is_show)
    self._leftViewNode:stopAllActions()
    self._leftInfoNode:stopAllActions()
    self._rightMiddleViewNode:stopAllActions()
    self._nodeRightTopInfo:stopAllActions()
    self._nodeBottomMiddelInfo:stopAllActions()
    if is_show then
        self._leftViewNode:runAction(cc.MoveTo:create(0.5, cc.p(0, 0)))
        self._rightMiddleViewNode:runAction(cc.MoveTo:create(0.5, cc.p(0, 0)))
        self._leftInfoNode:runAction(cc.MoveTo:create(0.5, cc.p(-500, 0)))
        self._nodeRightTopInfo:runAction(cc.MoveTo:create(0.5, cc.p(0, 200)))
        self._nodeBottomMiddelInfo:runAction(cc.MoveTo:create(0.5, cc.p(0, -200)))
    else
        self._leftViewNode:runAction(cc.MoveTo:create(0.5, cc.p(-500, 0)))
        self._rightMiddleViewNode:runAction(cc.MoveTo:create(0.5, cc.p(500, 0)))
        self._leftInfoNode:runAction(cc.MoveTo:create(0.5, cc.p(0, 0)))
        self._nodeRightTopInfo:runAction(cc.MoveTo:create(0.5, cc.p(0, 0)))
        self._nodeBottomMiddelInfo:runAction(cc.MoveTo:create(0.5, cc.p(0, 0)))
    end
end

function WorldView:_onWorldCitySelect()
    if uq.cache.world_war.battle_city_info == nil then
        return
    end
    self:onCloseArmyItemView()
    local info = uq.cache.world_war.battle_city_info
    local crop_info = uq.cache.crop:getCropDataById(info.crop_id)
    self._spriteColor:setVisible(next(crop_info) ~= nil)
    if next(crop_info) == nil then
        self._colorLabel:setString(StaticData["local_text"]["world.city.power.des2"])
        self._cropNameLabel:setString(StaticData["local_text"]["world.city.power.des1"])
    else
        self._cropNameLabel:setString(crop_info.name)
        self._colorLabel:setString(crop_info.power_name)
        local flag_info = StaticData['world_flag'][crop_info.color_id]
        if flag_info then
            self._spriteColor:setTexture("img/create_power/" .. flag_info.color)
        end
    end
    local city_info = StaticData['world_city'][info.city_id]
    self._cityNameLabel:setString(city_info.name)
    self._cityTypeLabel:setString(StaticData['world_type'][city_info.type].desc)
    self:initScrollView(city_info.featureType)
    self:showCityData(info)
    self:initOccupyCity(city_info.gate)
    self:initAddCity(city_info.territory)
end

function WorldView:showCityData(info)
    for k, v in ipairs(StaticData['world_develop']) do
        local develop_info = info.develop[k]
        self._cityNameInfoArray[k]:setString(v.name)
        local data = v.Effect[develop_info.level]
        self._cityDesInfoArray[k]:setString(string.format(StaticData["local_text"]["label.level"], develop_info.level))
        if data.value > 0 and data.value < 5 then
            self._cityAddInfoArray[k]:setString("+" .. data.value * 100 .. "%")
        else
            self._cityAddInfoArray[k]:setString("+" .. data.value)
        end
    end
end

function WorldView:initOccupyCity(str_citys)
    self._scrollViewLeft:removeAllChildren()
    if str_citys == "" then
        return
    end
    local city_array = string.split(str_citys, ";")
    local item_size = self._scrollViewLeft:getContentSize()
    local inner_width = (#city_array - 1) * 160
    self._scrollViewLeft:setInnerContainerSize(cc.size(inner_width, item_size.height))

    local item_pos_x = 80
    for k, t in ipairs(city_array) do
        local city_info = StaticData['world_city'][tonumber(t)]
        if city_info then
            local node = cc.CSLoader:createNode("world/WorldViewInfoItem.csb")
            node:getChildByName("icon"):setTexture('img/building/city_war/' .. city_info.icon)
            node:getChildByName("label"):setString(city_info.name)
            node:setPosition(cc.p(item_pos_x, 60))
            item_pos_x = item_pos_x + 160
            self._scrollViewLeft:addChild(node)
        end
    end
end

function WorldView:initAddCity(str_citys)
    self._scrollViewRight:removeAllChildren()
    if str_citys == "" then
        return
    end
    local city_array = string.split(str_citys, ";")
    local item_size = self._scrollViewRight:getContentSize()
    local inner_width = (#city_array - 1) * 160
    self._scrollViewRight:setInnerContainerSize(cc.size(inner_width, item_size.height))

    local item_pos_x = 80
    for k, t in ipairs(city_array) do
        local city_info = StaticData['world_city'][tonumber(t)]
        if city_info then
            local node = cc.CSLoader:createNode("world/WorldViewInfoItem.csb")
            node:getChildByName("icon"):setTexture('img/building/city_war/' .. city_info.icon)
            node:getChildByName("label"):setHTMLText(city_info.name)
            node:setPosition(cc.p(item_pos_x, 60))
            item_pos_x = item_pos_x + 160
            self._scrollViewRight:addChild(node)
            if city_info.protect ~= "" then
                local pro_array = string.split(city_info.protect, ";")
                for k, v in ipairs(pro_array) do
                    local str = string.split(v, ",")
                    local info = StaticData['types'].Effect[1].Type[tonumber(str[1])]
                    local value = info.percent * tonumber(str[2])
                    if info.percent < 1 then
                        node:getChildByName("label"):setHTMLText(city_info.name .. string.format(StaticData["local_text"]["world.city.add.des1"], value))
                    else
                        node:getChildByName("label"):setHTMLText(city_info.name .. string.format(StaticData["local_text"]["world.city.add.des2"], value))
                    end
                    break
                end
            end
        end
    end
end

function WorldView:initScrollView(reward_info)
    self._scrollView:removeAllChildren()
    local item_size = self._scrollView:getContentSize()
    local cost_array = uq.RewardType.parseRewards(reward_info)
    local inner_width = (#cost_array - 1) * 80
    self._scrollView:setInnerContainerSize(cc.size(inner_width, item_size.height))
    if inner_width < item_size.width then
        self._scrollView:setTouchEnabled(false)
    else
        self._scrollView:setTouchEnabled(true)
    end

    local item_pos_x = 40
    for k, t in ipairs(cost_array) do
        local euqip_item = EquipItem:create({info = t:toEquipWidget()})
        euqip_item:setTouchEnabled(true)
        euqip_item:setScale(0.6)
        euqip_item:addClickEventListener(function(sender)
            local info = sender:getEquipInfo()
            uq.showItemTips(info)
        end)
        euqip_item:setPosition(cc.p(item_pos_x, 40))
        item_pos_x = item_pos_x + 80
        self._scrollView:addChild(euqip_item)
    end
end

function WorldView:_onBattleReportNotify(msg)
    if uq.ModuleManager:getInstance():getModule(uq.ModuleManager.BATTLE_REPORT_INFO) or uq.cache.world_war.not_read_nums == 0 then
        self._reportRed:setVisible(false)
    else
        self._reportRed:setVisible(true)
        self._reportNumLabel:setString(uq.cache.world_war.not_read_nums)
    end
end

function WorldView:initRightView()
    self._armyArray = {}
    for k = 1, 2 do
        local node = self._rightMiddleViewNode:getChildByName("Node_" .. k)
        local item = uq.createPanelOnly("world.WorldCityWarArmyItem")
        node:addChild(item)
        item:setName("item")
        item:setBgTouchClick(function()
            local index = 1
            if k == 1 then
                index = 2
            end
            local node = self._rightMiddleViewNode:getChildByName("Node_" .. index)
            local item = node:getChildByName("item")
            item:setState(false)
        end)
        item:setViewType(1, k)
        table.insert(self._armyArray, item)
    end
    self:_onBattleReportNotify()
end

function WorldView:updateRightArmyView()
    local info_array = uq.cache.world_war.cur_army_info
    local num = 0
    for k, v in ipairs(self._armyArray) do
        local info = info_array[k]
        if #info.generals > 0 then
            num = num + 1
        end
        v:setData(info)
    end
    self._armyNumLabel:setString(num .. "/2")
end

function WorldView:onExit()
    services:removeEventListenersByTag('onBattleReportLoadByWorldView')
    services:removeEventListenersByTag('onWorldCitySelect')
    WorldView.super.onExit(self)
end

function WorldView:onCloseArmyItemView()
    for k, v in ipairs(self._armyArray) do
        v:setState(false)
    end
end

function WorldView:onGuozheng(event)
    if event.name ~= "ended" then
        return
    end
    self:onCloseArmyItemView()
    uq.ModuleManager:getInstance():show(uq.ModuleManager.GOVERNMENT_MODULE, {})
end

function WorldView:onCity(event)
    if event.name ~= "ended" then
        return
    end
    self:onCloseArmyItemView()
    uq.ModuleManager:getInstance():show(uq.ModuleManager.GOVERNMENT_MODULE, {})
end

function WorldView:onReport(event)
    if event.name ~= "ended" then
        return
    end
    self:onCloseArmyItemView()
    uq.ModuleManager:getInstance():show(uq.ModuleManager.BATTLE_REPORT_INFO, {})
end

function WorldView:onBtnExit(event)
    if event.name ~= "ended" then
        return
    end
    services:dispatchEvent({name = services.EVENT_NAMES.ON_WORLD_CITY_CLOSE})
end

return WorldView