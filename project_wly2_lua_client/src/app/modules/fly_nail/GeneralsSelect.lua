local GeneralsSelect = class("GeneralsSelect", require("app.base.PopupBase"))

GeneralsSelect.RESOURCE_FILENAME = "fly_nail/GeneralsSelect.csb"

GeneralsSelect.RESOURCE_BINDING  = {
    ["Panel_1/Panel_type"]                              ={["varname"] = "_panelType"},
    ["Panel_1/Panel_time"]                              ={["varname"] = "_panelTime"},
    ["Panel_1/Panel_quality"]                           ={["varname"] = "_panelQuality"},
    ["Panel_1/Panel_1/lbl_des1"]                        ={["varname"] = "_desLabel1"},
    ["Panel_1/Panel_1/lbl_des2"]                        ={["varname"] = "_desLabel2"},
    ["Panel_1/Panel_1/lbl_des3"]                        ={["varname"] = "_desLabel3"},
    ["Panel_1/Panel_1/Panel_tabview"]                   ={["varname"] = "_panelTableView"},
    ["Panel_1/Panel_1/Image_bg1"]                       ={["varname"] = "_imgBg1"},
    ["Panel_1/Panel_1/Image_bg2"]                       ={["varname"] = "_imgBg2"},
    ["Panel_1/Panel_1/Image_bg3"]                       ={["varname"] = "_imgBg3"},
    ["Panel_1/btn_close"]                               ={["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "_onTouchExit",["sound_id"] = 0}}},
    ["Panel_1/Button_determine"]                        ={["varname"] = "_btnDetermine",["events"] = {{["event"] = "touch",["method"] = "onTouchDetermine",["sound_id"] = 0}}},
}

function GeneralsSelect:ctor(name, args)
    GeneralsSelect.super.ctor(self, name, args)
    self._info = args.info
    self._selectGeneralId1 = args.select_general_id1
    self._selectGeneralId2 = args.select_general_id2
    self._timeId = self._info.data == nil and 1 or self._info.data.time_id
    if self._timeId == 0 then
        self._timeId = 1
    end
    self._soldierType = 0  --职业全部
    self._qualityType = 0  --品阶全部
    self._itemArray = {}
    self._dataArray = {}
    self._timeLabelArray = {}
    self._occupationLabelArray = {}
    self._qualityLabelArray = {}
    self._totalGeneralsArray = {}
end

function GeneralsSelect:init()
    self:parseView()
    self:centerView()
    self:initDialog()
end

function GeneralsSelect:initDialog()
    self._imgBg1:setTouchEnabled(true)
    self._imgBg1:addClickEventListener(function(sender)
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
        self._panelTime:setVisible(true)
    end)

    self._imgBg2:setTouchEnabled(true)
    self._imgBg2:addClickEventListener(function(sender)
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
        self._panelType:setVisible(true)
    end)

    self._imgBg3:setTouchEnabled(true)
    self._imgBg3:addClickEventListener(function(sender)
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
        self._panelQuality:setVisible(true)
    end)

    self._panelType:setTouchEnabled(true)
    self._panelType:addClickEventListenerWithSound(function(sender)
        self._panelType:setVisible(false)
    end)
    self._panelTime:setTouchEnabled(true)
    self._panelTime:addClickEventListenerWithSound(function(sender)
        self._panelTime:setVisible(false)
    end)
    self._panelQuality:setTouchEnabled(true)
    self._panelQuality:addClickEventListenerWithSound(function(sender)
        self._panelQuality:setVisible(false)
    end)
    self:initQuality()
    self:initTimeDes()
    self:initOccupationDes()
    self:updateOccupationDes()
    self:updateQualityDes()
    self:updateTimeDes()
    self:initTableView()
    local generals_array = uq.cache.generals:getUpGeneralsByType(0)
    local info = uq.cache.fly_nail.flyNailInfo
    for k2, v2 in ipairs(generals_array) do
        local isfind = false
        if not isfind then
            for k, v in pairs(info.items) do
                if v2.id == v.general_id1 or v2.id == v.general_id2 then
                    isfind = true
                    break
                end
            end
        end
        if not isfind then
            table.insert(self._totalGeneralsArray, v2)
        end
    end
    self:initData()
end

function GeneralsSelect:initQuality()
    for i = 1, 9 do
        local lbl = self._panelQuality:getChildByName("lbl_des" .. i)
        lbl:setTouchEnabled(true)
        lbl:addClickEventListenerWithSound(function(sender)
            local tag = sender:getTag()
            self._qualityType =  tag
            self._panelQuality:setVisible(false)
            self:updateQualityDes()
            self:initData()
        end)
        table.insert(self._qualityLabelArray, lbl)
    end
    local index = 1
    self._qualityLabelArray[index]:setString(StaticData['local_text']['label.collect.all'])
    self._qualityLabelArray[index]:setTag(0)
    index = index + 1
    for k, v in ipairs(StaticData['advance_levels']) do
        if self._qualityLabelArray[index] then
            self._qualityLabelArray[index]:setString(v.name)
            self._qualityLabelArray[index]:setTag(v.ident)
        end
        index = index + 1
    end
end

function GeneralsSelect:initTimeDes()
    for i = 1, 3 do
        local lbl = self._panelTime:getChildByName("lbl_des" .. i)
        lbl:setTouchEnabled(true)
        lbl:addClickEventListenerWithSound(function(sender)
            local tag = sender:getTag()
            self._timeId =  tag
            self._panelTime:setVisible(false)
            self:updateTimeDes()
        end)
        table.insert(self._timeLabelArray, lbl)
    end
    local index = 1
    for k, v in ipairs(self._info.xml.Idle) do
        self._timeLabelArray[index]:setString(string.format(StaticData['local_text']['fly.nail.general.des5'], math.floor(v.time / 3600)))
        self._timeLabelArray[index]:setTag(v.ident)
        index = index + 1
    end
end

function GeneralsSelect:initOccupationDes()
    for i = 1, 6 do
        local lbl = self._panelType:getChildByName("lbl_des" .. i)
        lbl:setTouchEnabled(true)
        lbl:addClickEventListenerWithSound(function(sender)
            local tag = sender:getTag()
            self._soldierType =  tag
            self._panelType:setVisible(false)
            self:updateOccupationDes()
            self:initData()
        end)
        table.insert(self._occupationLabelArray, lbl)
    end
    local index = 1
    self._occupationLabelArray[index]:setString(StaticData['local_text']['label.collect.all'])
    self._occupationLabelArray[index]:setTag(0)
    index = index + 1
    for k, v in ipairs(StaticData['types'].Soldier[1].Type) do
        if index < 7 then
            self._occupationLabelArray[index]:setString(v.name)
            self._occupationLabelArray[index]:setTag(v.ident)
            index = index + 1
        end
    end
end

function GeneralsSelect:updateQualityDes()
    local soldier_info = StaticData['advance_levels'][self._qualityType]
    if soldier_info == nil then
        self._desLabel3:setString(StaticData['local_text']['label.collect.all'])
    else
        self._desLabel3:setString(soldier_info.name)
    end
end

function GeneralsSelect:updateTimeDes()
    local idle_info = self._info.xml.Idle[self._timeId]
    self._desLabel1:setString(string.format(StaticData['local_text']['fly.nail.general.des5'], math.floor(idle_info.time / 3600)))
end

function GeneralsSelect:updateOccupationDes()
    local soldier_info = StaticData['types'].Soldier[1].Type[self._soldierType]
    if soldier_info == nil then
        self._desLabel2:setString(StaticData['local_text']['label.collect.all'])
    else
        self._desLabel2:setString(soldier_info.name)
    end
end

function GeneralsSelect:initData()
    self._dataArray = {}
    if self._soldierType == 0 and self._qualityType == 0 then
        self._dataArray = self._totalGeneralsArray
    else
        for k, v in ipairs(self._totalGeneralsArray) do
            local general_data = uq.cache.generals:getGeneralDataByID(v.id)
            local soldier_info1 = StaticData['soldier'][general_data.soldierId1]
            local soldier_info2 = StaticData['soldier'][general_data.soldierId2]
            if self._soldierType == 0 then
                if general_data.advanceLevel == self._qualityType then
                    table.insert(self._dataArray, v)
                end
            elseif self._qualityType == 0 then
                if soldier_info1.type == self._soldierType or soldier_info2.type == self._soldierType then
                    table.insert(self._dataArray, v)
                end
            elseif (soldier_info1.type == self._soldierType or soldier_info2.type == self._soldierType) and general_data.advanceLevel == self._qualityType then
                table.insert(self._dataArray, v)
            end
        end
    end
    self._tableView:reloadData()
end

function GeneralsSelect:onTouchItem(info)
    if self._selectGeneralId1 == info.id then
        self._selectGeneralId1 = 0
    elseif self._selectGeneralId2 == info.id then
        self._selectGeneralId2 = 0
    elseif self._selectGeneralId1 == 0 then
        self._selectGeneralId1 = info.id
    elseif self._selectGeneralId2 == 0 then
        self._selectGeneralId2 = info.id
    else
        uq.fadeInfo(StaticData['local_text']['fly.nail.general.des6'])
        return
    end
    for k, v in ipairs(self._itemArray) do
        v:setSelectGeneral(self._selectGeneralId1, self._selectGeneralId2)
    end
end

function GeneralsSelect:initTableView()
    local size = self._panelTableView:getContentSize()
    self._tableView = cc.TableView:create(cc.size(size.width,size.height))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setAnchorPoint(cc.p(0, 0))
    self._tableView:setDelegate()
    self._panelTableView:addChild(self._tableView)

    self._tableView:registerScriptHandler(handler(self,self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
end

function GeneralsSelect:cellSizeForTable(view, idx)
    return 960, 156
end

function GeneralsSelect:numberOfCellsInTableView(view)
    return math.floor((#self._dataArray + 1) / 2)
end

function GeneralsSelect:tableCellTouched(view, cell,touch)

end

function GeneralsSelect:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx * 2 + 1
    if not cell then
        cell = cc.TableViewCell:new()
        for i = 0, 1 do
            local info = self._dataArray[index]
            local cell_item = uq.createPanelOnly("fly_nail.FlyNailSelectItem")
            cell:addChild(cell_item)
            local width = cell_item:getContentSize().width
            cell_item:setPosition(cc.p((width + 20) * i, 0))
            cell_item:setName("item" .. i)
            cell_item:setCallBack(handler(self, self.onTouchItem))
            if info then
                cell_item:setInfo(info)
                cell_item:setSelectGeneral(self._selectGeneralId1, self._selectGeneralId2)
            else
                cell_item:setVisible(false)
            end
            table.insert(self._itemArray, cell_item)
            index = index + 1
        end
    else
        for i = 0, 1 do
            local info = self._dataArray[index]
            local cell_item = cell:getChildByName("item" .. i)
            if info then
                cell_item:setVisible(true)
                cell_item:setInfo(info)
                cell_item:setSelectGeneral(self._selectGeneralId1, self._selectGeneralId2)
            else
                cell_item:setVisible(false)
            end
            index = index + 1
        end
    end
    return cell
end

function GeneralsSelect:onTouchDetermine(event)
    if event.name ~= "ended" then
        return
    end
    local data = {time_id = self._timeId}
    data.general_id1 = self._selectGeneralId1
    data.general_id2 = self._selectGeneralId2
    services:dispatchEvent({name = services.EVENT_NAMES.ON_FLYNAIL_SELECT_GENERALS, data = data})
    self:disposeSelf()
end

function GeneralsSelect:dispose()
    GeneralsSelect.super.dispose(self)
end

return GeneralsSelect
