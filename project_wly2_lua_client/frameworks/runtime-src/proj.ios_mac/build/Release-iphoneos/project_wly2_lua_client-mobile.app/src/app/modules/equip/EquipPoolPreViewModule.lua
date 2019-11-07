local EquipPoolPreViewModule = class("EquipPoolPreViewModule", require('app.base.PopupBase'))
local EquipItem = require("app.modules.common.EquipItem")

EquipPoolPreViewModule.RESOURCE_FILENAME = "equip/EquipPoolPreView.csb"
EquipPoolPreViewModule.RESOURCE_BINDING = {
    ["Panel_7"]                         = {["varname"] = "_panelTableView"},
    ["Text_13"]                         = {["varname"] = "_txtTypeTips"},
    ["Text_21"]                         = {["varname"] = "_txtTitle"},
    ["Node_10"]                         = {["varname"] = "_nodeHead"},
    ["Node_19"]                         = {["varname"] = "_nodeItems"},
    ["Button_1"]                        = {["varname"] = "_btnExit", ["events"] = {{["event"] = "touch",["method"] = "_onTouchExit"}}},
}

function EquipPoolPreViewModule:ctor(name, params)
    EquipPoolPreViewModule.super.ctor(self, name, params)
    self._poolId = params.pool_id or 1
end

function EquipPoolPreViewModule:init()
    self:centerView()
    self:parseView()
    self:setLayerColor()
    self:initData()
    self:initTableView()
    self:refreshPage()
end

function EquipPoolPreViewModule:initData()
    if not self._poolId then
        return
    end
    local info = StaticData['item_appoint'].ItemAppoint[self._poolId]
    if not info then
        return
    end
    local level = uq.cache.role.master_lvl
    local total_info = {}
    local all_card_rate = {}
    local map_all_info = {}
    for k, v in pairs(info.Businessman) do
        if v.level <= level then
            local total_packet_weight = 0
            for _, item in ipairs(v.Business) do
                if item.openLevel <= level and item.closeLevel > level then
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
        if not map_all_info[info._type] then
            map_all_info[info._type] = {}
        end
        local total_card_weight = all_card_rate[v.card_ident] or 0
        local add_weight = v.info.weight / total_card_weight * total_card_weight / total_weight
        if not map_all_info[info._type][info._id] then
            local data = info:toEquipWidget()
            data.qualityType = info._data.qualityType
            map_all_info[info._type][info._id] = {data = data, weight = add_weight}
        else
            map_all_info[info._type][info._id].weight = map_all_info[info._type][info._id].weight + add_weight
        end

        local quality_weight = map_type_weight[info._data.qualityType]
        map_type_weight[info._data.qualityType] = quality_weight and quality_weight + add_weight or add_weight
    end

    self._allItemInfo = {}
    self._allTypeWeight = {}
    for k, item in pairs(map_all_info) do
        for _, info in pairs(item) do
            table.insert(self._allItemInfo, info)
        end
    end

    for k, v in pairs(map_type_weight) do
        table.insert(self._allTypeWeight, {type_id = k, value = v})
    end

    table.sort(self._allItemInfo, function(a, b)
        if a.data.qualityType ~= b.data.qualityType then
            return a.data.qualityType > b.data.qualityType
        else
            return a.data.id > b.data.id
        end
    end)

    table.sort(self._allTypeWeight, function(a, b)
        return a.type_id > b.type_id
    end)
end

function EquipPoolPreViewModule:refreshPage()
    local text = ""
    for k, v in ipairs(self._allTypeWeight) do
        local info = StaticData['types'].ItemQuality[1].Type[v.type_id]
        if not info then
            return
        end
        local str = ""
        if k == 1 then
            str = string.format("<font color='#'" .. info.color ..">%s</font><font color= '#ffffff'> %.2f%%</font>", info.name, v.value * 100)
        else
            str = string.format("<font color='#'" .. info.color ..">  %s</font><font color= '#ffffff'> %.2f%%</font>", info.name, v.value * 100)
        end
        text = text .. str
    end
    self._txtTypeTips:setHTMLText(text)

    local info = StaticData['item_appoint'].ItemAppoint[self._poolId]
    if not info then
        return
    end
    self._txtTitle:setString(info.name .. StaticData['local_text']['label.common.preview'])
end

function EquipPoolPreViewModule:initTableView()
    self._cellArray = {}
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

function EquipPoolPreViewModule:cellSizeForTable(view, idx)
    return 1000, 130
end

function EquipPoolPreViewModule:numberOfCellsInTableView(view)
    return math.ceil(#self._allItemInfo / 8)
end

function EquipPoolPreViewModule:tableCellTouched(view, cell, touch)
    local touch_point = touch:getLocation()
    local index = cell:getIdx() * 8 + 1
    for i = 0, 7, 1 do
        local item = cell:getChildByName("item"..i)
        if item == nil then
            return
        end
        local pos = item:convertToNodeSpace(touch_point)
        local rect = cc.rect(0, 0, 100, 100)
        if cc.rectContainsPoint(rect, pos) then
            uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
            uq.showItemTips(item:getEquipInfo())
            break
        end
        index = index + 1
    end
end

function EquipPoolPreViewModule:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx * 8 + 1
    if not cell then
        cell = cc.TableViewCell:new()
        for i = 0, 7, 1 do
            local item = EquipItem:create()
            item:setPosition(cc.p(120 * i + 85, 65))
            item:setName("item" .. i)
            item:setScale(0.9)
            table.insert(self._cellArray, item)
            item:setVisible(self._allItemInfo[index] ~= nil)
            if self._allItemInfo[index] ~= nil then
                item:setInfo(self._allItemInfo[index].data)
                item:showName(true, string.format("%.2f%%" , self._allItemInfo[index].weight * 100), true)
            end
            cell:addChild(item)
            index = index + 1
        end
    else
        for i = 0, 7, 1 do
            local item = cell:getChildByName("item" .. i)
            item:setVisible(self._allItemInfo[index] ~= nil)
            if self._allItemInfo[index] ~= nil then
                item:setInfo(self._allItemInfo[index].data)
                item:showName(true, string.format("%.2f%%" , self._allItemInfo[index].weight * 100), true)
            end
            index = index + 1
        end
    end
    return cell
end


function EquipPoolPreViewModule:dispose()
    EquipPoolPreViewModule.super.dispose(self)
end

return EquipPoolPreViewModule