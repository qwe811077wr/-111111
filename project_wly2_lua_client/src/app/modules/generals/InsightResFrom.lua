local InsightResFrom = class("InsightResFrom", require("app.base.PopupBase"))
local EquipItem = require("app.modules.common.EquipItem")

InsightResFrom.RESOURCE_FILENAME = "generals/InsightResFrom.csb"

InsightResFrom.RESOURCE_BINDING  = {
    ["label_name"]          ={["varname"] = "_nameLabel"},
    ["label_num"]           ={["varname"] = "_numLabel"},
    ["label_name_0"]        ={["varname"] = "_txtHead"},
    ["panel_icon"]          ={["varname"] = "_iconPanel"},
    ["ScrollView_1"]        ={["varname"] = "_itemScrollView"},
    ["Image_9_0"]           ={["varname"] = "_bgImg"},
    ["Text_4"]              ={["varname"] = "_txtDesc"},
    ["ScrollView_2"]        ={["varname"] = "_scrollView"},
    ["Button_1"]            ={["varname"] = "_btnExit", ["events"] = {{["event"] = "touch",["method"] = "_onTouchExit",["sound_id"] = 0}}},
    ["img_icon"]            ={["varname"] = "_imgIcon"},
    ["spr_icon"]            ={["varname"] = "_sprIcon"},
    ["title_txt"]           ={["varname"] = "_txtTitle"},
}
--[[
    显示资源来源界面,需要传入id用于去表内获取基础信息
    要显示数量的需要传入curNum(默认0)，要显示xxx/xxx的，需要传入curNum和totalNum
    type参考constant内ITEM_TYPE
]]
function InsightResFrom:ctor(name, args)
    InsightResFrom.super.ctor(self, name, args)
    self._curInfo = args or nil
end

function InsightResFrom:init()
    self:parseView(self._view)
    self:centerView(self._view)
    local size = self._scrollView:getContentSize()
    self._txtDesc:setTextAreaSize(cc.size(size.width, 0))
    self._txtDesc:getVirtualRenderer():setLineHeight(25)
    if self._curInfo.type == uq.config.constant.COST_RES_TYPE.EQUIP then
        self:initEquipItem()
    elseif self._curInfo.type == uq.config.constant.COST_RES_TYPE.ORDER_MATERIAL then
        self:initSpecialItem()
    else
        self:initUi()
    end
    self:setLayerColor()

    self._eventChange = services.EVENT_NAMES.ON_CONSUME_RES_CHANGE .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_CONSUME_RES_CHANGE, handler(self, self.refreshPage), self._eventChange)
end

function InsightResFrom:refreshPage()
    if self._curInfo.type == uq.config.constant.COST_RES_TYPE.EQUIP then
        return
    end
    local num = uq.cache.role:getResNum(self._curInfo.type, self._curInfo.id)
    self._numLabel:setString(num .. "/" .. self._curInfo.totalNum)
end

function InsightResFrom:initEquipItem()
    local data = StaticData['items'][self._curInfo.id]
    self._nameLabel:setString(data.name)
    self:setNameLabelQuality(data.qualityType)
    local type_xml  = StaticData['types'].Effect[1].Type[data.effectType]
    if type_xml then
        self._txtHead:setString(StaticData['local_text']['label.state.init'] .. type_xml.name)
    end
    self._numLabel:setString('+' .. data.effectValue)
    self:addItem(self._curInfo)
    self:_initScrollView(data.jumpId)
    self._txtDesc:setString(data.desc)
    self._txtTitle:setString(StaticData["local_text"]["general.equip.type.resource"])
end

function InsightResFrom:initSpecialItem()
    local info = StaticData['advance_data'][self._curInfo.id] or {}
    if not info or next(info) == nil then
        return
    end
    if info.icon then
        self._sprIcon:setTexture("img/common/item/" .. info.icon)
        self._sprIcon:setVisible(true)
    end
    if info.qualityType then
        local tab = StaticData['types'].ItemQuality[1].Type[tonumber(info.qualityType)]
        if tab and tab.qualityIcon then
            self._imgIcon:loadTexture("img/common/ui/" .. tab.qualityIcon)
            self._imgIcon:setVisible(true)
        end
        self._nameLabel:setTextColor(uq.parseColor("#" .. tab.color))
    end
    self._nameLabel:setString(info.name)
    local pos_x = self._numLabel:getPositionX()
    self._numLabel:setPositionX(pos_x - 60)
    local num = uq.cache.role:getResNum(self._curInfo.type, self._curInfo.id)
    self._numLabel:setString(num)
    self._txtDesc:setString(info.desc)
    self:_initScrollView(info.jumpId)
    self._txtTitle:setString(StaticData["local_text"]["general.from.res"])
end

function InsightResFrom:setNameLabelQuality(quality_type)
    local quality_info = StaticData['types'].ItemQuality[1].Type[tonumber(quality_type)]
    if not quality_info then
        return
    end
    self._nameLabel:setTextColor(uq.parseColor("#" .. quality_info.color))
end

function InsightResFrom:initUi()
    if self._curInfo == nil  then
        uq.log("InsightResFrom:initUi error")
        return
    end
    self:addExceptNode(self._bgImg)
    if self._curInfo.curNum == nil then
        self._curInfo.curNum = uq.cache.role:getResNum(self._curInfo.type, self._curInfo.id) or 0
    end
    self._iconPanel:removeAllChildren()
    local xml_data = StaticData['types'].Cost[1].Type[self._curInfo.type]
    if not xml_data then
        uq.log("xml_data error  ", self._curInfo.type)
        return
    end
    local info_data = StaticData.getCostInfo(self._curInfo.type, self._curInfo.id)
    if info_data == nil then
        return
    end
    local str = StaticData["local_text"]["general.from.res"]
    local des = info_data.desc
    local name = info_data.name
    local quality_type = self._curInfo.qualityType
    if self._curInfo.type == uq.config.constant.COST_RES_TYPE.SPIRIT then
        local general_xml = uq.cache.generals:getGeneralDataXML(tonumber(self._curInfo.id .. 1))
        des = string.format(xml_data.desc, general_xml.composeNums, info_data.name, info_data.name)
        name = name .. StaticData["local_text"]["general.piece"]
        local generals_grade = StaticData['types'].GeneralGrade[1].Type[general_xml.grade]
        str = StaticData["local_text"]["general.from.piece"]
        quality_type = generals_grade.qualityType
    end
    self._txtDesc:setString(des)
    self._nameLabel:setString(name)
    self:setNameLabelQuality(tonumber(quality_type))

    local pos_x = self._numLabel:getPositionX()
    self._numLabel:setPositionX(pos_x - 60)
    self._numLabel:setString(self._curInfo.curNum)
    local info = {id = self._curInfo.id, type = self._curInfo.type}
    self:addItem(info)
    self:_initScrollView(info_data.jumpId)
    self._txtTitle:setString(str)
end

function InsightResFrom:addItem(info)
    local item = EquipItem:create({info = info})
    local scale = 0.9
    item:setScale(scale)
    item:setPosition(self._iconPanel:getContentSize().width * scale * 0.5, self._iconPanel:getContentSize().height * scale * 0.5)
    item:addTo(self._iconPanel)
end

function InsightResFrom:_initScrollView(jumpinfo)
    if jumpinfo == nil then
        return
    end
    local array = string.split(jumpinfo, ',')
    local jump_array = {}
    for k, v in ipairs(array) do
        local data = string.split(v, ';')
        if #data <= 1 then
            table.insert(jump_array, {id = v})
        else
            for i, id in ipairs(data) do
                table.insert(jump_array, {id = id, is_special = true})
            end
        end
    end

    self._itemScrollView:removeAllChildren()
    local size = self._itemScrollView:getContentSize()
    local inner_height = #jump_array * 95
    self._itemScrollView:setTouchEnabled(inner_height > size.height)
    self._itemScrollView:setScrollBarEnabled(false)
    local item_poxY = inner_height < size.height and size.height or inner_height
    self._itemScrollView:setInnerContainerSize(cc.size(size.width, inner_height))
    for k, v in pairs(jump_array) do
        local item = uq.createPanelOnly("generals.QualityItem")
        local item_size = item:getChildByName("Layer"):getContentSize()
        item:setPosition(cc.p(item_size.width / 2 - 20, item_poxY - item_size.height / 2))
        item:setInfo(v)
        item_poxY = item_poxY - item_size.height
        self._itemScrollView:addChild(item)
    end
end

function InsightResFrom:getItemsInfo()
    return self._curInfo
end

function InsightResFrom:dispose()
    services:removeEventListenersByTag(self._eventChange)
    InsightResFrom.super.dispose(self)
    display.removeUnusedSpriteFrames()
end

return InsightResFrom