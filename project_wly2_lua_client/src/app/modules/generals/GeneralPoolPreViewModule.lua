local GeneralPoolPreViewModule = class("GeneralPoolPreViewModule", require('app.base.PopupBase'))
local EquipItem = require("app.modules.common.EquipItem")

GeneralPoolPreViewModule.RESOURCE_FILENAME = "generals/GeneralPoolPreView.csb"
GeneralPoolPreViewModule.RESOURCE_BINDING = {
    ["Panel_tableview"]                         = {["varname"] = "_panelTableView"},
    ["Text_weight"]                             = {["varname"] = "_txtTypeTips"},
    ["Text_name"]                               = {["varname"] = "_txtName"},
    ["Button_close"]                            = {["varname"] = "_btnExit", ["events"] = {{["event"] = "touch",["method"] = "_onTouchExit"}}},
    ["Panel_title"]                             = {["varname"] = "_panelTitle"},
    ["Text_title"]                              = {["varname"] = "_txtTitle"},
}

function GeneralPoolPreViewModule:ctor(name, params)
    GeneralPoolPreViewModule.super.ctor(self, name, params)
    self._poolId = params.pool_id or 101
end

function GeneralPoolPreViewModule:init()
    self:centerView()
    self:parseView()
    self:setLayerColor()
    self:initData()
    self:initTableView()
    self:refreshPage()
end

function GeneralPoolPreViewModule:initData()
    if not self._poolId then
        return
    end
    local pool_info = StaticData['general_appoint'].GeneralAppoint[self._poolId]
    if not pool_info then
        return
    end
    local role_level = uq.cache.role.master_lvl
    local total_info = {}
    local all_card_rate = {}
    self._mapAllInfo = {}
    for k, v in pairs(pool_info.Businessman) do
        if v.level <= role_level then
            local total_packet_weight = 0
            for _, item in ipairs(v.Business) do
                if item.openLevel <= role_level and item.closeLevel > role_level and (uq.cache.role.country_id == tonumber(item.camp) or tonumber(item.camp) == 0) then
                    total_packet_weight = total_packet_weight + item.weight
                    table.insert(total_info, {info = item, packet_weight = v.weight, card_ident = k})
                end
            end
            all_card_rate[k] = total_packet_weight
        end
    end

    local total_weight = 0
    for k, v in pairs(all_card_rate) do
        total_weight = total_weight + v
    end
    local map_type_weight = {}

    for k, v in ipairs(total_info) do
        local info = uq.RewardType.new(v.info.itemId)
        if not self._mapAllInfo[info._type] then
            self._mapAllInfo[info._type] = {}
        end
        local total_card_weight = all_card_rate[v.card_ident] or 0
        local add_weight = v.info.weight / total_card_weight * total_card_weight / total_weight
        local grade_info = StaticData['types'].GeneralGrade[1].Type[info._data.grade]
        if not self._mapAllInfo[info._type][info._id] then
            local data = info:toEquipWidget()
            data.qualityType = grade_info.qualityType
            data.max_num = 0
            self._mapAllInfo[info._type][info._id] = {data = data, weight = add_weight}
        else
            self._mapAllInfo[info._type][info._id].weight = self._mapAllInfo[info._type][info._id].weight + add_weight
        end

        local quality_weight = map_type_weight[grade_info.qualityType]
        map_type_weight[grade_info.qualityType] = quality_weight and quality_weight + add_weight or add_weight
    end

    self._allItemInfo = {}
    self._allItemType = {}
    self._allTypeWeight = {}
    for k, item in pairs(self._mapAllInfo) do
        if not self._allItemInfo[k] then
            self._allItemInfo[k] = {}
        end
        table.insert(self._allItemType, k)
        for _, info in pairs(item) do
            table.insert(self._allItemInfo[k], info)
        end
    end

    for k, v in pairs(map_type_weight) do
        table.insert(self._allTypeWeight, {type_id = k, value = v})
    end

    for k, v in pairs(self._allItemInfo) do
        table.sort(v, function(a, b)
            if a.data.qualityType ~= b.data.qualityType then
                return a.data.qualityType > b.data.qualityType
            else
                return a.data.id > b.data.id
            end
        end)
    end

    table.sort(self._allItemType, function(a, b)
        if a == uq.config.constant.COST_RES_TYPE.MATERIAL then
            return false
        elseif b == uq.config.constant.COST_RES_TYPE.MATERIAL then
            return true
        end
        return a < b
    end)

    table.sort(self._allTypeWeight, function(a, b)
        return a.type_id > b.type_id
    end)
end

function GeneralPoolPreViewModule:refreshPage()
    local text = ""
    for k, v in ipairs(self._allTypeWeight) do
        local color_info = "FFFFFF"
        if StaticData['types'].ItemQuality[1].Type[v.type_id] then
            color_info = StaticData['types'].ItemQuality[1].Type[v.type_id].color
        end
        local info = StaticData['types'].GeneralGrade[1].Type[v.type_id]
        if not info then
            return
        end
        local name = info.name .. StaticData['local_text']['label.level2'] .. StaticData['local_text']['label.general']
        local str = ""
        if k == 1 then
            str = string.format("<font color='#'" .. color_info ..">%s</font><font color= '#ffffff'> %.2f%%</font>", name, v.value * 100)
        else
            str = string.format("<font color='#'" .. color_info ..">  %s</font><font color= '#ffffff'> %.2f%%</font>", name, v.value * 100)
        end
        text = text .. str
    end
    self._txtTypeTips:setHTMLText(text)

    local info = StaticData['general_appoint'].GeneralAppoint[self._poolId]
    if not info then
        return
    end
    self._txtName:setString(info.name .. StaticData['local_text']['label.common.preview'])
end

function GeneralPoolPreViewModule:initTableView()
    local size = self._panelTableView:getContentSize()
    self._tableView = cc.TableView:create(cc.size(size.width,size.height))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setAnchorPoint(cc.p(0,0))
    self._tableView:setDelegate()
    self._panelTableView:addChild(self._tableView)

    self._tableView:registerScriptHandler(handler(self,self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:reloadData()
end

function GeneralPoolPreViewModule:cellSizeForTable(view, idx)
    local index = idx * 8 + 1
    local info, real_index = self:checkUsingInfo(index)
    if type(info) == "nil" then
        return 0, 0
    elseif type(info) == "table" then
        return 1000, 130
    elseif type(info) == "number" then
        return 1000, 39
    end
    return 1000, 130
end

function GeneralPoolPreViewModule:numberOfCellsInTableView(view)
    local num = #self._allItemInfo
    for k, v in pairs(self._allItemInfo) do
        num = num + 1
        local ids_count = 0
        for _, item in pairs(v) do
            ids_count = ids_count + 1
        end
        num = num + math.ceil(ids_count / 8)
    end
    return num
end

function GeneralPoolPreViewModule:tableCellTouched(view, cell, touch)
    local touch_point = touch:getLocation()
    local index = cell:getIdx() * 8 + 1
    for i = 0, 7, 1 do
        local item = cell:getChildByName("item"..i)
        if item == nil then
            return
        end
        local pos = item:convertToNodeSpace(touch_point)
        local width = item:getContentSize().width
        local height = item:getContentSize().height
        local rect = cc.rect(0, 0, width, height)
        if cc.rectContainsPoint(rect, pos) then
            if not item:isVisible() then
                return
            end
            uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
            uq.showItemTips(item:getEquipInfo())
            break
        end
        index = index + 1
    end
end

function GeneralPoolPreViewModule:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx * 8 + 1
    local info, real_index = self:checkUsingInfo(index)

    if not cell then
        cell = cc.TableViewCell:new()
        self:createCellItem(cell, info, real_index)
    else
        self:setCellItem(cell, info, real_index)
    end
    return cell
end

function GeneralPoolPreViewModule:checkUsingInfo(index)
    local all_info = self._allItemInfo
    local all_type = self._allItemType

    for i = 1,#all_type do
        local count = 0
        count = count + 8 * i
        for j = 1, (i-1) do
            count = count + math.ceil(#all_info[all_type[j]] / 8) * 8
        end
        if index <= count then
            return all_type[i]
        end
        local real_index = index - count
        count = count + #all_info[all_type[i]]
        if index <= count then
            return all_info[all_type[i]], real_index
        end
    end

    return
end

function GeneralPoolPreViewModule:createCellItem(cell, info, index)
    local item = self._panelTitle:clone()
    item:setPosition(cc.p(500, 19.5))
    item:setTag(1000)
    cell:addChild(item)
    for i = 0, 7, 1 do
        local item = EquipItem:create()
        item:setPosition(cc.p(120 * i + 85, 65))
        item:setName("item" .. i)
        item:setScale(0.9)
        cell:addChild(item)
    end
    self:setCellItem(cell, info, index)
end

function GeneralPoolPreViewModule:setCellItem(cell, info, index)
    local title_item = cell:getChildByTag(1000)
    if title_item then
        title_item:setVisible(info ~= nil and type(info) == "number")
    end
    for i = 0, 7, 1 do
        local item = cell:getChildByName("item" .. i)
        if item then
            item:setVisible(info ~= nil and type(info) == "table")
        end
    end
    if info == nil then
        return
    end
    if type(info) == "table" then
        for i = 0, 7, 1 do
            local item = cell:getChildByName("item" .. i)
            if item == nil then
                return
            end
            item:setVisible(info[index] ~= nil)
            if info[index] ~= nil then
                item:setInfo(info[index].data)
                item:showName(true, string.format("%.2f%%" , info[index].weight * 100), true)
            end
            index = index + 1
        end
    elseif type(info) == "number" then
        local title_item = cell:getChildByTag(1000)
        if title_item == nil then
            return
        end
        local title_str = StaticData['local_text']['general.pool.info.title1']
        if info == uq.config.constant.COST_RES_TYPE.MATERIAL then
            title_str = StaticData['local_text']['general.pool.info.title3']
        elseif info == uq.config.constant.COST_RES_TYPE.SPIRIT then
            title_str = StaticData['local_text']['general.pool.info.title2']
        end
        title_item:getChildByName('Text_title'):setString(title_str)
    end
end

function GeneralPoolPreViewModule:dispose()
    GeneralPoolPreViewModule.super.dispose(self)
end

return GeneralPoolPreViewModule