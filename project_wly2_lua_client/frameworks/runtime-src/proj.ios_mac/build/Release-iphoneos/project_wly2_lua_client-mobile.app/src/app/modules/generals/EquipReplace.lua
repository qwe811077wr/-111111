local EquipReplace = class("EquipReplace", require("app.base.PopupBase"))

EquipReplace.RESOURCE_FILENAME = "generals/EquipReplace.csb"
EquipReplace.RESOURCE_BINDING  = {
    ["Panel_4"]         ={["varname"] = "_tabelViewPanel"},
    ["btn_advanced"]    ={["varname"] = "_btnReplace", ["events"] = {{["event"] = "touch",["method"] = "onReplace"}}},
    ["Button_1"]        ={["varname"] = "_onExit", ["events"] = {{["event"] = "touch",["method"] = "_onTouchExit"}}},
}

function EquipReplace:ctor(name, args)
    EquipReplace.super.ctor(self, name, args)
    self._tableView = nil
    self._generalId = args.general_id or 0
    self._generalId2 = 0
end

function EquipReplace:init()
    self:parseView(self._view)
    self:centerView(self._view)
    self:setLayerColor()
    self._generalArray = {}
    self._itemList = {}
    self:initUi()
    self._scrolling = false
    network:addEventListener(Protocol.S_2_C_EXCHANGE_ITEM, handler(self, self._onExchangeItemByReplace),'_onExchangeItemByReplace')
end

function EquipReplace:onReplace(event)
    if event.name ~= "ended" then
        return
    end
    local info = self._generalArray[self._selectedIndex]
    self._generalId2 = info.id
    network:sendPacket(Protocol.C_2_S_EXCHANGE_ITEM, {generalId1 = self._generalId, generalId2 = info.id})
end

function EquipReplace:_onExchangeItemByReplace(evt)
    if tonumber(evt.data.ret) == 0 then
        if uq.cache.equipment:exchangeItem(self._generalId, self._generalId2) then
            uq.fadeInfo(StaticData["local_text"]["equip.changes.success"])
        else
            uq.fadeInfo(StaticData["local_text"]["equip.changes.success2"])
        end
        self:disposeSelf()
    end
end

function EquipReplace:initUi()
    self._tabelViewPanel:removeAllChildren()
    local up_list = uq.cache.generals:getUpGeneralsByType(0)
    for k, v in ipairs(up_list) do
        local general_info = uq.cache.generals:getGeneralDataByID(v.id)
        if v.id ~= self._generalId then
            local info = {id = v.id, name = general_info.name}
            table.insert(self._generalArray, info)
        end
    end
    self:_initTableView()
end

function EquipReplace:_initTableView()
    if self._generalArray == nil then
        uq.log("error EquipReplace:_initTableView")
        return
    end
    local size = self._tabelViewPanel:getContentSize()
    self._tableView = cc.TableView:create(cc.size(size.width, size.height))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setAnchorPoint(cc.p(0,0))
    self._tableView:setDelegate()
    self._tabelViewPanel:addChild(self._tableView)

    self._tableView:registerScriptHandler(handler(self,self.scrollScriptScroll), cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._tableView:registerScriptHandler(handler(self,self.tableHighLight), cc.TABLECELL_HIGH_LIGHT)
    self._tableView:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:reloadData()
end

function EquipReplace:cellSizeForTable(view, idx)
    return 600, 140
end

function EquipReplace:numberOfCellsInTableView(view)
    return math.ceil(#self._generalArray / 5)
end

function EquipReplace:tableHighLight()
    self._scrolling = false
end

function EquipReplace:scrollScriptScroll()
    self._scrolling = true
end

function EquipReplace:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx * 5 + 1
    if not cell then
        cell = cc.TableViewCell:new()
        local width = 0
        for i = 0, 4, 1 do
            local item = uq.createPanelOnly("generals.EquipReplaceItem")
            local info = self._generalArray[index]
            item:setTag(index)
            item:setName("item" .. i)
            local node = item:getChildByName("Node")
            local panel = node:getChildByName("Panel_1")
            panel:setSwallowTouches(false)
            panel:addClickEventListenerWithSound(function(sender)
                if self._scrolling then
                    return
                end
                for k, v in ipairs(self._itemList) do
                    v:setSelectedImgState(false)
                end
                local panel = sender:getParent():getParent()
                panel:setSelectedImgState(true)
                self._selectedIndex = panel:getTag()
            end)
            item:setPositionX(width)
            cell:addChild(item)
            width = panel:getContentSize().width + 20 + width
            item:setVisible(info ~= nil)
            item:setInfo(info)
            table.insert(self._itemList, item)

            if index == 1 then
                item:setSelectedImgState(true)
                self._selectedIndex = index
            end
            index = index + 1
        end
    else
        for i = 0, 4 do
            local info = self._generalArray[index]
            local item = cell:getChildByName("item" .. i)
            item:setTag(index)
            item:setVisible(info ~= nil)
            item:setInfo(info)
            index = index + 1
        end
    end
    return cell
end

function EquipReplace:dispose()
    EquipReplace.super.dispose(self)
    display.removeUnusedSpriteFrames()
    network:removeEventListenerByTag('_onExchangeItemByReplace')
end

return EquipReplace