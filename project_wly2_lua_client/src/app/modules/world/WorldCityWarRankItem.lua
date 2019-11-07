local WorldCityWarRankItem = class("WorldCityWarRankItem", require('app.base.PopupBase'))

WorldCityWarRankItem.RESOURCE_FILENAME = "world/WorldCityWarRankItem.csb"
WorldCityWarRankItem.RESOURCE_BINDING = {
    ["Node_1/Image_crop"]     = {["varname"] = "_imgCrop"},
    ["Node_1/Image_battle"]   = {["varname"] = "_imgWorldBattle"},
    ["Node_1/Image_kill"]     = {["varname"] = "_imgKill"},
    ["Node_battle"]           = {["varname"] = "_nodeBattle"},
    ["Node_battle/Panel_1"]   = {["varname"] = "_panelTabView2"},
    ["Node_self/Panel_2"]     = {["varname"] = "_panelTabView1"},
    ["Node_self/Panel_self"]  = {["varname"] = "_panelSelf"},
    ["Node_self"]             = {["varname"] = "_nodeSelf"},
}

function WorldCityWarRankItem:onCreate()
    WorldCityWarRankItem.super.onCreate(self)
    self:parseView()
    self:centerView()
    self:setLayerColor()
    self._rankType = 1
    self._imgBtnArray = {}
    self._curDataArray = {}
    table.insert(self._imgBtnArray, self._imgCrop)
    table.insert(self._imgBtnArray, self._imgWorldBattle)
    table.insert(self._imgBtnArray, self._imgKill)
    self._worldNotifyTag = services.EVENT_NAMES.ON_BATTLE_RANK_NOTIFY .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_BATTLE_RANK_NOTIFY, handler(self, self.onBattleNotify), self._worldNotifyTag)
    self:initDialog()
end

function WorldCityWarRankItem:initItemTabView()
    local size = self._panelTabView1:getContentSize()
    self._itemTableView1 = cc.TableView:create(cc.size(size.width,size.height))
    self._itemTableView1:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._itemTableView1:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._itemTableView1:setPosition(cc.p(0, 0))
    self._itemTableView1:setAnchorPoint(cc.p(0,0))
    self._itemTableView1:setDelegate()
    self._panelTabView1:addChild(self._itemTableView1)

    self._itemTableView1:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._itemTableView1:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._itemTableView1:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

    local size = self._panelTabView2:getContentSize()
    self._itemTableView2 = cc.TableView:create(cc.size(size.width,size.height))
    self._itemTableView2:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._itemTableView2:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._itemTableView2:setPosition(cc.p(0, 0))
    self._itemTableView2:setAnchorPoint(cc.p(0,0))
    self._itemTableView2:setDelegate()
    self._panelTabView2:addChild(self._itemTableView2)

    self._itemTableView2:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._itemTableView2:registerScriptHandler(handler(self,self.tableCellAtIndex2), cc.TABLECELL_SIZE_AT_INDEX)
    self._itemTableView2:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
end

function WorldCityWarRankItem:cellSizeForTable(view, idx)
    if self._rankType == 1 then
        return 870, 54
    else
        return 870, 148
    end
end

function WorldCityWarRankItem:numberOfCellsInTableView(view)
    return #self._curDataArray
end

function WorldCityWarRankItem:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx + 1
    local cell_item = nil
    if not cell then
        cell = cc.TableViewCell:new()
        --创建列表项
        cell_item = uq.createPanelOnly("world.WorldCityRankItem")
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByName("item")
    end

    cell_item:setName("item")
    local info = self._curDataArray[index]
    info.rank = index
    cell_item:setData(info)

    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))
    if index == #self._curDataArray then
        cell_item:updateState(false)
    end
    return cell
end

function WorldCityWarRankItem:tableCellAtIndex2(view, idx)
    local cell = view:dequeueCell()
    local index = idx + 1
    local cell_item = nil
    if not cell then
        cell = cc.TableViewCell:new()
        --创建列表项
        cell_item = uq.createPanelOnly("world.WorldCityRankItem2")
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByName("item")
    end

    cell_item:setName("item")
    local info = self._curDataArray[index]
    info.rank = index
    cell_item:setData(info)

    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))
    if index == #self._curDataArray then
        cell_item:updateState(false)
    end
    return cell
end

function WorldCityWarRankItem:updateLeftBtn()
    for k, v in ipairs(self._imgBtnArray) do
        if k == self._rankType then
            v:loadTexture("img/world/s02_00136.png")
            v:setLocalZOrder(200)
            v:getChildByName("des"):setTextColor(uq.parseColor("#ffffff"))
            v:getChildByName("des"):setFontSize(26)
        else
            v:setLocalZOrder(100 + k)
            v:loadTexture("img/world/s02_00135.png")
            v:getChildByName("des"):setTextColor(uq.parseColor("#6f9cab"))
            v:getChildByName("des"):setFontSize(24)
        end
    end
    self:onBattleNotify()
end

function WorldCityWarRankItem:onBattleNotify()
    if self._rankType == 1 then
        self._curDataArray = uq.cache.world_war.battle_rank_info.crops_rank
    elseif self._rankType == 2 then
        self._curDataArray = uq.cache.world_war.battle_rank_info.dechp_rank
    else
        self._curDataArray = uq.cache.world_war.battle_rank_info.score_rank
    end
    if self._curDataArray == nil then
        self._curDataArray = {}
    end
    self._panelSelf:setVisible(self._rankType == 1)
    self._nodeSelf:setVisible(self._rankType == 1)
    self._nodeBattle:setVisible(self._rankType ~= 1)
    if self._rankType == 1 then
        self._itemTableView1:reloadData()
        local info = self:getDataByInfo(self._curDataArray, uq.cache.role.cropsId)
        if info == nil then
            local crop_data = uq.cache.crop:getCropDataById(uq.cache.role.cropsId)
            local data = {
                role_id = uq.cache.role.cropsId,
                name = crop_data.name,
                crop_id = uq.cache.role.cropsId,
                value = 0,
                is_atk = 1,
                rank = 0
            }
            self._selfItem:setData(data)
        else
            self._selfItem:setData(info)
        end
    else
        self._itemTableView2:reloadData()
    end
end

function WorldCityWarRankItem:getDataByInfo(info_array, id)
    if next(info_array) == nil then
        return nil
    end
    for k, v in ipairs(info_array) do
        if v.role_id == id then
            v.rank = k
            return v
        end
    end
    return nil
end

function WorldCityWarRankItem:initDialog()
    for k, v in ipairs(self._imgBtnArray) do
        v:setTouchEnabled(true)
        v:setTag(k)
        v:addClickEventListenerWithSound(function (sender)
            if self._rankType == sender:getTag() then
                return
            end
            self._rankType = sender:getTag()
            self:updateLeftBtn()
        end)
    end
    self._panelSelf:removeAllChildren()
    self._selfItem = uq.createPanelOnly("world.WorldCityRankItem")
    self._panelSelf:addChild(self._selfItem)
    self._selfItem:updateState(false)
    self._panelSelf:setVisible(false)
    self._selfItem:setPosition(cc.p(self._panelSelf:getContentSize().width * 0.5, self._panelSelf:getContentSize().height * 0.5))
    self:initItemTabView()
    self:updateLeftBtn()
end

function WorldCityWarRankItem:onExit()
    services:removeEventListenersByTag(self._worldNotifyTag)
    WorldCityWarRankItem.super.onExit(self)
end

return WorldCityWarRankItem