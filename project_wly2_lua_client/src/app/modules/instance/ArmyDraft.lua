local ArmyDraft = class("ArmyDraft", require('app.base.ChildViewBase'))

ArmyDraft.RESOURCE_FILENAME = "instance/ArmyDraft.csb"
ArmyDraft.RESOURCE_BINDING = {
    ["Panel_1"]    = {["varname"]="_panelBg"},
    ["Image_17_0"] = {["varname"]="_imgBg"},
}

function ArmyDraft:onCreate()
    ArmyDraft.super.onCreate(self)
    self:parseView()

    self._dataListArmy = {}

    self._eventArmy = services.EVENT_NAMES.ON_ARMY_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_ARMY_REFRESH, handler(self, self.refreshArmy), self._eventArmy)

    self:refreshArmy()
end

function ArmyDraft:refreshArmy()
    self._dataListArmy = {}
    self._armySpeed = uq.cache.role:getTotalArmySpeed()
    if self._armySpeed > 0 then
        self._dataListArmy = uq.cache.generals:getGeneralArmyList()
    end

    self:setVisible(#self._dataListArmy > 0)

    local off_num = 5 - #self._dataListArmy
    if #self._dataListArmy == 4 then
        self._imgBg:setContentSize(cc.size(220, 246 - 25))
        self._panelBg:setContentSize(cc.size(220, 193 - 25))
    elseif #self._dataListArmy < 4 then
        self._imgBg:setContentSize(cc.size(220, 246 - 25 - (off_num - 1) * 42))
        self._panelBg:setContentSize(cc.size(220, 193 - 25 - (off_num - 1) * 42))
    else
        self._imgBg:setContentSize(cc.size(220, 246))
        self._panelBg:setContentSize(cc.size(220, 193))
    end
    self:createList()
end

function ArmyDraft:onExit()
    services:removeEventListenersByTag(self._eventArmy)

    ArmyDraft.super.onExit(self)
end

function ArmyDraft:showAction()
    self:runAction(cc.MoveBy:create(0.2, cc.p(220, 0)))
end

function ArmyDraft:createList()
    if self._listView then
        self._listView:removeSelf()
        self._listView = nil
    end
    local view_size = self._panelBg:getContentSize()
    self._listView = cc.TableView:create(cc.size(view_size.width, view_size.height))
    self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listView:setPosition(cc.p(0, 0))
    self._listView:setDelegate()
    self._listView:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._listView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._listView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._listView:reloadData()
    self._panelBg:addChild(self._listView)
end

function ArmyDraft:tableCellTouched(view, cell)
    local cell_item = cell:getChildByTag(1000)
    local general_data_item = cell_item:getGeneralData()
    local res_num = uq.cache.role:getResNum(uq.config.constant.COST_RES_TYPE.REDIF)
    if res_num == 0 then
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
        uq.fadeInfo(StaticData['local_text']['label.draft.not.soldier'])
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    local function confirm()
        network:sendPacket(Protocol.C_2_S_DRAFT_SPEED, {general_id = general_data_item.id})
    end

    local general_data = uq.cache.generals:getGeneralDataByID(general_data_item.id)
    local off_num = general_data.max_soldiers - general_data.current_soldiers
    local res_num = uq.cache.role:getResNum(uq.config.constant.COST_RES_TYPE.REDIF)
    local str = string.format(StaticData['local_text']['label.draft.speed'], general_data_item.name, off_num, res_num)
    local data = {
        content = str,
        confirm_callback = confirm,
    }
    uq.addConfirmBox(data, uq.config.constant.CONFIRM_TYPE.DRAFT_SOLDIER)
end

function ArmyDraft:cellSizeForTable(view, idx)
    return 220, 42
end

function ArmyDraft:numberOfCellsInTableView(view)
    return #self._dataListArmy
end

function ArmyDraft:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("instance.ArmyDraftItem")
        cell_item:setTag(1000)
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end
    cell_item:setData(self._dataListArmy[index], self._armySpeed)

    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))

    return cell
end

return ArmyDraft