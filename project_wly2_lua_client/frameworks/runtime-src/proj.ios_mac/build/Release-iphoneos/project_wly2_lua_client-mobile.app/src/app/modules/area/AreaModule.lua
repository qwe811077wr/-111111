local AreaModule = class("AreaModule", require('app.modules.common.BaseViewWithHead'))

AreaModule.RESOURCE_FILENAME = "area/AreaView.csb"
AreaModule.RESOURCE_BINDING = {
    ["Node_4"]     = {["varname"] = "_nodeMainUI"},
    ["Node_1"]     = {["varname"] = "_nodeCity"},
    ["Button_1"]   = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onClose"}}},
    ["Image_1"]    = {["varname"] = "_imgBg"},
    ["Text_36"]    = {["varname"] = "_txtTitle"},
    ["Button_8"]   = {["varname"] = "_btnRight",["events"] = {{["event"] = "touch",["method"] = "onRight"}}},
    ["Button_8_0"] = {["varname"] = "_btnLeft",["events"] = {{["event"] = "touch",["method"] = "onLeft"}}},
}

function AreaModule:ctor(name, params)
    AreaModule.super.ctor(self, name, params)
end

function AreaModule:init()
    self._worldAreaIndex = uq.cache.role.world_area_id
    self._curPart = 1
    self._cityList = {}

    local coin_group = {
        uq.config.constant.COST_RES_TYPE.MONEY,
        uq.config.constant.COST_RES_TYPE.GOLDEN,
        uq.config.constant.COST_RES_TYPE.GESTE
    }
    self:addShowCoinGroup(coin_group)

    self:centerView()
    self:setTitle('地区')
    self:setCloseBack(handler(self, self.onClose))

    -- local main_ui = require('app/modules/common/MainUILayer'):create()
    -- main_ui:setPosition(display.width/2, display.height/2)
    -- main_ui:hideControl()
    -- self._nodeMainUI:addChild(main_ui)

    self._chatUI = uq.createPanelOnly('chat.ChatBottom')
    self._chatUI:setPosition(cc.p(-display.width / 2 + 20, -display.height / 2 + 50))
    self:addChild(self._chatUI)
    self:parseView()

    self:loadArea()
end

function AreaModule:loadArea(area_id, part_id)
    if not area_id then
        --打开自己
        self._worldAreaIndex = uq.cache.role.world_area_id
        self._curPart = uq.cache.role.areaId
        network:sendPacket(Protocol.C_2_S_AREA_GETMAXSEQNO, {area_id = uq.cache.role.world_area_id})
        network:sendPacket(Protocol.C_2_S_AREA_PARTLOAD, {area_id = uq.cache.role.world_area_id, part_id = uq.cache.role.areaId})
    else
        self._worldAreaIndex = area_id
        self._curPart = part_id
        network:sendPacket(Protocol.C_2_S_AREA_GETMAXSEQNO, {area_id = area_id})
        network:sendPacket(Protocol.C_2_S_AREA_PARTLOAD, {area_id = area_id, part_id = part_id})
    end
end

function AreaModule:onClose(event)
    if event.name == "ended" then
        self:disposeSelf()
        uq.runCmd('enter_main_city')
    end
end

function AreaModule:loadCity()
    local world_config = StaticData['world_maps'][self._worldAreaIndex]
    if not world_config then return end

    local map_id = world_config.areaMapId
    local map_url = 'img/areabg/qy_0' .. map_id .. '.png'
    self._imgBg:loadTexture(map_url)
    self:setTitle()

    if #self._cityList == 0 then
        for i = 1, 16 do
            local city = uq.createPanelOnly('area.AreaCity')
            self._nodeCity:addChild(city)
            table.insert(self._cityList, city)
        end
    end

    for i = 1, 16 do
        self._cityList[i]:setVisible(false)
    end

    local pos_config = StaticData.load('DQ' .. map_id).Object
    local pos_list = {}
    for k,item in pairs(pos_config) do
        table.insert(pos_list, item)
    end

    uq.log('uq.cache.area:getCityInfo', uq.cache.area:getCityInfo())
    for k, item in ipairs(uq.cache.area:getCityInfo()) do
        item.area_index = self._worldAreaIndex
        item.part_index = self._curPart
        self._cityList[k]:setVisible(true)
        self._cityList[k]:setData(item)
        self._cityList[k]:setPosition(cc.p(pos_list[k].x, pos_list[k].y))
    end
end

function AreaModule:setTitle()
    self._txtTitle:setString(string.format("区域%d", self._curPart))
end

function AreaModule:onRight(event)
    if event.name == "ended" then
        if self._curPart > 1 then
            self._curPart = self._curPart - 1
            network:sendPacket(Protocol.C_2_S_AREA_PARTLOAD, {area_id = self._worldAreaIndex, part_id = self._curPart})
        end
    end
end

function AreaModule:onLeft(event)
    if event.name == "ended" then
        if self._curPart < uq.cache.area._maxAreaNum then
            self._curPart = self._curPart + 1
            network:sendPacket(Protocol.C_2_S_AREA_PARTLOAD, {area_id = self._worldAreaIndex, part_id = self._curPart})
        end
    end
end

function AreaModule:refreshCurPage()
    network:sendPacket(Protocol.C_2_S_AREA_PARTLOAD, {area_id = self._worldAreaIndex, part_id = self._curPart})
end

return AreaModule