local EquipAttributeModule = class("EquipAttributeModule", require('app.base.PopupBase'))

EquipAttributeModule.RESOURCE_FILENAME = "generals/EquipAttribute.csb"
EquipAttributeModule.RESOURCE_BINDING = {
    ["Panel_13"]                         = {["varname"] = "_panelTableView"},
}

function EquipAttributeModule:ctor(name, params)
    self._generalId = params.id
    EquipAttributeModule.super.ctor(self, name, params)
end

function EquipAttributeModule:init()
    self:parseView()
    self:centerView()
    self:initTableView()
    self:initData()
end

function EquipAttributeModule:initTableView()
    local size = self._panelTableView:getContentSize()
    self._tableView = cc.TableView:create(cc.size(size.width,size.height))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setAnchorPoint(cc.p(0,0))
    self._tableView:setDelegate()
    self._panelTableView:addChild(self._tableView)

    self._tableView:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
end

function EquipAttributeModule:initData()
    self._allXmlData = {}
    local map_base_attr = {}
    local map_add_attr = {}
    local info = uq.cache.equipment:getInfoByGeneralId(self._generalId)
    for k, v in ipairs(info) do
        local add = uq.cache.equipment:getBaseValue(v.db_id)
        if not map_base_attr[v.xml.effectType] then
            map_base_attr[v.xml.effectType] = {effectType = v.xml.effectType, value = 0}
        end
        map_base_attr[v.xml.effectType].value = map_base_attr[v.xml.effectType].value + add

        for k, v in ipairs(v.attributes) do
            if not map_add_attr[v.attr_type] then
                map_add_attr[v.attr_type] = {effectType = v.attr_type, value = v.value}
            else
                map_add_attr[v.attr_type].value = map_add_attr[v.attr_type].value + v.value
            end
        end
    end
    if next(map_base_attr) ~= nil then
        local base_attr_list = {}
        for k, v in pairs(map_base_attr) do
            table.insert(base_attr_list, v)
        end
        table.insert(self._allXmlData, {title = StaticData['local_text']['label.base.attr'], List = base_attr_list})
    end
    if next(map_add_attr) ~= nil then
        local add_attr_list = {}
        for k, v in pairs(map_add_attr) do
            table.insert(add_attr_list, v)
        end
        table.insert(self._allXmlData, {title = StaticData['local_text']['label.add.attr'], List = add_attr_list})
    end



    local suit_info = {}
    self._suitInfo = {}
    local info = uq.cache.equipment:getInfoByGeneralId(self._generalId)
    if info and next(info) ~= nil then
        for k, v in ipairs(info) do
            if v.xml.suitId then
                if not suit_info[v.xml.suitId] then
                    suit_info[v.xml.suitId] = 1
                else
                    suit_info[v.xml.suitId] = suit_info[v.xml.suitId] + 1
                end
            end
        end
        if next(suit_info) ~= nil then
            for k, v in pairs(suit_info) do
                local xml = StaticData['item_suit'][k]
                table.insert(self._suitInfo, {id = k, num = v, xml = xml})
            end
            table.sort(self._suitInfo, function(a, b)
                return a.num > b.num
            end)

            table.insert(self._allXmlData, self._suitInfo)
        end
    end
    self._tableView:reloadData()
end

function EquipAttributeModule:cellSizeForTable(view, idx)
    local index = idx + 1
    if self._allXmlData[index].title then
        local num = math.ceil(#self._allXmlData[index].List / 2)
        return 430, 50 + 43 * num
    else
        local height = 0
        for k, v in ipairs(self._allXmlData[index]) do
            local str = string.split(v.xml.suitEffect, '|')
            height = height + #str * 30 + 50
        end
        return 420, height + 50
    end
end

function EquipAttributeModule:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local item = nil
    if not cell then
        cell = cc.TableViewCell:new()
        item = uq.createPanelOnly('generals.EquipAttributeItem')
        item:setName("item")
        cell:addChild(item)
    else
        item = cell:getChildByName("item")
    end
    local size_x, size_y = self:cellSizeForTable(view, idx)
    local state = self._allXmlData[index].List == nil
    item:setPositionY(size_y)
    item:setInfo(self._allXmlData[index], state)
    return cell
end

function EquipAttributeModule:numberOfCellsInTableView()
    return #self._allXmlData
end

function EquipAttributeModule:dispose()
    services:removeEventListenersByTag('ON_GET_GENERAL_INFO' .. tostring(self))
    EquipAttributeModule.super.dispose(self)
end

return EquipAttributeModule