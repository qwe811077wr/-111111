local EmbattleBottom = class("EmbattleBottom", require('app.base.ChildViewBase'))

EmbattleBottom.RESOURCE_FILENAME = "embattle/EmbattleBottom.csb"
EmbattleBottom.RESOURCE_BINDING = {
    ["panel_tab"]  = {["varname"]="_panelTableView"},
}

function EmbattleBottom:onCreate()
    EmbattleBottom.super.onCreate(self)
    self:parseView()
    services:addEventListener(services.EVENT_NAMES.ON_GENERAL_INFO_RET, handler(self, self._generalInfoRet), "_generalInfoRetByEmbattle")
    self._delayReloadDataTag = "embattle_reload_data" .. tostring(self)
    self:init()
end

function EmbattleBottom:onExit()
    services:removeEventListenersByTag("_generalInfoRetByEmbattle")
    EmbattleBottom.super:onExit()
end

function EmbattleBottom:_generalInfoRet(msg)
    --获取到的是武将信息
    self:updateTableView()
end

function EmbattleBottom:init()
    self._roleType = uq.cache.formation.ROLE.ROLE_GENERAL
    self._roleCardInfo = {}
    self:initTabView()
end

function EmbattleBottom:initTabView()
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
end

function EmbattleBottom:cellSizeForTable(view, idx)
    return 250, 140
end

function EmbattleBottom:numberOfCellsInTableView(view)
    local num = self:getDataNum()
    return math.floor((num + 1) / 2)
end

function EmbattleBottom:tableCellTouched(view, cell, touch)
end

function EmbattleBottom:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx * 2 + 1
    if not cell then
        cell = cc.TableViewCell:new()
        for i = 0, 1, 1 do
            local role_card = uq.createPanelOnly("embattle.EmbattleRoleCard")
            role_card:setPosition(cc.p(5 + 120 * i, -20))
            role_card:setSelected(false)
            role_card:setScale(0.8)
            role_card:setIndex(index)
            role_card:setName("card" .. i)
            role_card:setCallback(handler(self, self.cardCallback))
            cell:addChild(role_card, 1)
            table.insert(self._roleCardInfo, role_card)
            if index <= self:getDataNum() then
                role_card:setData(index, self._roleType)
            else
                role_card:setVisible(false)
            end
            index = index + 1
        end
    else
        for i = 0, 1, 1 do
            local role_card = cell:getChildByName("card" .. i)
            if index <= self:getDataNum() then
                role_card:setData(index, self._roleType)
                role_card:setVisible(true)
            else
                role_card:setVisible(false)
            end
            index = index + 1
        end
    end
    return cell
end

function EmbattleBottom:getDataNum()
    self._roleType = uq.cache.formation:getCurRoleType()
    return uq.cache.formation._allListDown[self._roleType] and #uq.cache.formation._allListDown[self._roleType] or 0
end

function EmbattleBottom:cardCallback(cell_index)
    local cell_parent = self._roleCardInfo[cell_index]:getParent():getParent()
    local pos = cell_parent:convertToWorldSpace(cc.p(self._roleCardInfo[cell_index]:getParent():getPosition()))
    if self._callBack then
        self._callBack(cell_index, cc.p(pos_x, pos.y))
    end
end

function EmbattleBottom:reLoad(role_type)
    if role_type then
        self._roleType = role_type
    end
    self:updateTableView()
end

function EmbattleBottom:updateTableView()
    uq.TimerProxy:removeTimer(self._delayReloadDataTag)
    uq.TimerProxy:addTimer(self._delayReloadDataTag, function()
        self._tableView:reloadData();
        uq.TimerProxy:removeTimer(self._delayReloadDataTag)
    end, 0, 1, 0.25)
end

function EmbattleBottom:setCallback(callback)
    self._callBack = callback
end

function EmbattleBottom:setFormation(index)

end

function EmbattleBottom:setSelectCurFormation(index)
    if self._roleCardInfo[index]:isVisible() then
        self._roleCardInfo[index]:setSelected(true)
    end
end

return EmbattleBottom