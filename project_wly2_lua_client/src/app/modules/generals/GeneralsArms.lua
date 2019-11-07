local GeneralsArms = class("GeneralsArms", require("app.base.TableViewBase"))

GeneralsArms.RESOURCE_FILENAME = "generals/GeneralsArms.csb"

GeneralsArms.RESOURCE_BINDING  = {
    ["Panel_2/btn_rework"]                          ={["varname"] = "_btnRework",["events"] = {{["event"] = "touch",["method"] = "onBtnRework",["sound_id"] = 0}}},
    ["Panel_2/btn_advanced"]                        ={["varname"] = "_btnAdvanced",["events"] = {{["event"] = "touch",["method"] = "onBtnAdvanced",["sound_id"] = 0}}},
    ["Panel_2/label_armstype1"]                     ={["varname"] = "_armsTypeLabel1"},
    ["Panel_2/label_armstype2"]                     ={["varname"] = "_armsTypeLabel2"},
    ["Panel_2/Panel_1"]                             ={["varname"] = "_panelArms1"},
    ["Panel_2/Panel_data"]                          ={["varname"] = "_panelValue"},
    ["Image_35"]                                    ={["varname"] = "_imgSoldierType1"},
    ["Image_36"]                                    ={["varname"] = "_imgSoldierType2"},
    ["Panel_2/Panel_5"]                             ={["varname"] = "_panelItem1"},
    ["Panel_2/Panel_5_0"]                           ={["varname"] = "_panelItem2"},
}
function GeneralsArms:ctor(name, args)
    GeneralsArms.super.ctor(self)
    self._armsItem1 = nil
    self._armsInfoItem = nil
    self._curSoldierId = 0
    self._selectedIndex = 1
end

function GeneralsArms:init()
    self:parseView()
    self._curGeneralInfo = {}
    self:initTabView()
    self:initUi()
    self:initProtocal()
end

function GeneralsArms:initUi()
    self._btnRework:setPressedActionEnabled(true)
    self._btnAdvanced:setPressedActionEnabled(true)
    self._armsItem1 = uq.createPanelOnly("generals.ArmsResInfoItem")
    self._panelArms1:addChild(self._armsItem1)

    self._armsInfoItem = uq.createPanelOnly("generals.ArmsValueText")
    self._panelValue:addChild(self._armsInfoItem)
end

function GeneralsArms:_onSeceltCallBack(soldier_id)
    if soldier_id ~= self._curGeneralInfo.battle_soldier_id then
        network:sendPacket(Protocol.C_2_S_GENARAL_SET_BATTLE_SOLDIER, {general_id = self._curGeneralInfo.id, soldier_id = soldier_id})
    end
end

function GeneralsArms:_onBgCallBack(soldier_id)
    if soldier_id ~= self._curSoldierId then
        self._curSoldierId = soldier_id
        self:updateBaseInfo()
        self:_updateChangeDialog()
    end
end

function GeneralsArms:filterInfo()
    local soldier_xml1 = StaticData['soldier'][self._curGeneralInfo.soldierId1]
    local soldier_xml2 = StaticData['soldier'][self._curGeneralInfo.soldierId2]
    if not soldier_xml1 or not soldier_xml2 then
        return
    end
    self._soldierArray1 = {}
    self._soldierArray2 = {}
    for k, v in pairs(StaticData['soldier']) do
        if v.isHidden == 0 and v.level >= soldier_xml1.level then
            local info = {['id'] = v.ident, ['level'] = v.level, ['cur_level'] = soldier_xml1.level, ['general_id'] = self._curGeneralInfo.id}
            if v.type == soldier_xml1.type and v.ident ~= soldier_xml1.ident then
                table.insert(self._soldierArray1, info)
            elseif v.type == soldier_xml2.type and v.ident ~= soldier_xml2.ident then
                table.insert(self._soldierArray2, info)
            end
        end
    end

    table.sort(self._soldierArray1, function(a, b)
        return a.level < b.level
    end)
    table.insert(self._soldierArray1, 1, {id = soldier_xml1.ident, level = soldier_xml1.level, cur_level = soldier_xml1.level, general_id = self._curGeneralInfo.id})

    table.sort(self._soldierArray2, function(a, b)
        return a.level < b.level
    end)
    table.insert(self._soldierArray2, 1, {id = soldier_xml2.ident, level = soldier_xml2.level, cur_level = soldier_xml2.level, general_id = self._curGeneralInfo.id})
end

function GeneralsArms:initTabView()
    local size = self._panelItem1:getContentSize()
    self._tableView = cc.TableView:create(cc.size(size.width,size.height))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setAnchorPoint(cc.p(0,0))
    self._tableView:setDelegate()
    self._panelItem1:addChild(self._tableView)

    self._tableView:registerScriptHandler(handler(self,self.scrollScriptScroll), cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._tableView:registerScriptHandler(handler(self,self.tableHighLight), cc.TABLECELL_HIGH_LIGHT)
    self._tableView:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

    local size = self._panelItem2:getContentSize()
    self._tableView1 = cc.TableView:create(cc.size(size.width,size.height))
    self._tableView1:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self._tableView1:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView1:setPosition(cc.p(0, 0))
    self._tableView1:setAnchorPoint(cc.p(0,0))
    self._tableView1:setDelegate()
    self._panelItem2:addChild(self._tableView1)

    self._tableView1:registerScriptHandler(handler(self,self.scrollScriptScroll1), cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._tableView1:registerScriptHandler(handler(self,self.tableHighLight1), cc.TABLECELL_HIGH_LIGHT)
    self._tableView1:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView1:registerScriptHandler(handler(self,self.tableCellAtIndex1), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView1:registerScriptHandler(handler(self,self.numberOfCellsInTableView1), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
end

function GeneralsArms:cellSizeForTable()
    return 135, 160
end

function GeneralsArms:scrollScriptScroll()
    self._scrolling = true
end

function GeneralsArms:tableHighLight()
    self._scrolling = false
end

function GeneralsArms:scrollScriptScroll1()
    self._scrolling1 = true
end

function GeneralsArms:tableHighLight1()
    self._scrolling1 = false
end

function GeneralsArms:numberOfCellsInTableView()
    return #self._soldierArray1
end

function GeneralsArms:numberOfCellsInTableView1()
    return #self._soldierArray2
end

function GeneralsArms:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        item = uq.createPanelOnly("generals.ArmyItem")
        item:setName("item")
        item:setSwallowTouch(false)
        item:getChildByName("Node"):getChildByName("Panel_1"):addClickEventListenerWithSound(handler(item, function(item)
            if self._scrolling then
                return
            end
            self:_onSelectdItemChanged(item)
        end))
        cell:addChild(item)
    else
        item = cell:getChildByName("item")
    end
    local state = self._soldierArray1[index].id == self._curGeneralInfo.battle_soldier_id
    if state then
        self._selectedItem = item
    end
    item:setSelectedImgVisible(state)
    item:setData(self._soldierArray1[index])
    return cell
end

function GeneralsArms:_onSelectdItemChanged(item)
    if item:getSelectedImgVisible() then
        return
    end
    self._isChangeInfo = true
    self._selectedItem:setSelectedImgVisible(false)
    self._selectedItem = item
    self._selectedItem:setSelectedImgVisible(true)
    local id = item:getSoldierId()
    self._armsItem1:setInfo(id)
    self._armsInfoItem:setData(id)
end

function GeneralsArms:tableCellAtIndex1(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        item = uq.createPanelOnly("generals.ArmyItem")
        item:setName("item")
        item:setSwallowTouch(false)
        item:getChildByName("Node"):getChildByName("Panel_1"):addClickEventListenerWithSound(handler(item, function(item)
            if self._scrolling1 then
                return
            end
            self:_onSelectdItemChanged(item)
        end))
        cell:addChild(item)
    else
        item = cell:getChildByName("item")
    end
    local state = self._soldierArray2[index].id == self._curGeneralInfo.battle_soldier_id
    if state then
        self._selectedItem = item
    end
    item:setSelectedImgVisible(state)
    item:setData(self._soldierArray2[index])
    return cell
end

function GeneralsArms:update(param)
    local offset1 = self._tableView:getContentOffset()
    local offset2 = self._tableView1:getContentOffset()
    if self._isChangeInfo or offset1.x ~= 0 or offset2.x ~= 0 then
        self._isChangeInfo = false
        self:updateBaseInfo()
        self:_updateChangeDialog()
    end
end

function GeneralsArms:onBtnRework(event)
    if event.name ~= "ended" then
        return
    end
    if self._curGeneralInfo.transferSoldierTimes <= 0 then
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
        uq.fadeInfo(StaticData["local_text"]["soldier.rebuild.des"])
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    uq.ModuleManager:getInstance():show(uq.ModuleManager.GENERALS_ARMS_REBUILD_MODULE, {general_id = self._curGeneralInfo.id})
end

function GeneralsArms:onBtnAdvanced(event)
    if event.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    local soldier_xml1 = StaticData['soldier'][self._curGeneralInfo.soldierId1]
    if not soldier_xml1 then
        uq.log("error GeneralsArms updateBaseInfo  soldier_xml1")
        return
    end
    if soldier_xml1.level > 3 and soldier_xml1.level < 6 then --进阶等级已达最高
        uq.fadeInfo(StaticData["local_text"]["soldier.advance.level.max"])
        return
    end
    uq.ModuleManager:getInstance():show(uq.ModuleManager.GENERALS_ARMS_ADVANCE_MODULE, {general_id = self._curGeneralInfo.id})
end

function GeneralsArms:initProtocal()
    services:addEventListener(services.EVENT_NAMES.ON_CHANGE_GENERALS, handler(self,self._onUpdateDialog), "_onUpdateDialog")
    services:addEventListener(services.EVENT_NAMES.ON_INIT_GENERALS_INFO, handler(self,self._onInitDialog), "_onInitDialogByArms")
    services:addEventListener(services.EVENT_NAMES.ON_CHANGE_BATTLE_SOLDIER_ID, handler(self,self.updateGeneralsSoldier), "_onChangeBattleSoldier" .. tostring(self))
end

function GeneralsArms:_onInitDialog(evt)--切换tab时，如果界面首次打开需要传入数据
    services:removeEventListenersByTag("_onInitDialogByArms")
    self._curGeneralInfo = evt.data
    self._curSoldierId = self._curGeneralInfo.battle_soldier_id
    self:updateBaseInfo()
    self:_updateChangeDialog()
    local red = uq.cache.generals:isCanAdvance(self._curGeneralInfo.id)
    uq.showRedStatus(self._btnAdvanced, red, self._btnAdvanced:getContentSize().width / 2 - 10, self._btnAdvanced:getContentSize().height / 2 - 10)
end

function GeneralsArms:updateGeneralsSoldier(msg)
    if msg.data.general_id == self._curGeneralInfo.id then
        self._playAttack = true
    end
end

function GeneralsArms:_onUpdateDialog(evt)
    if self._curGeneralInfo.id ~= evt.data.id then
        self._curSoldierId = evt.data.battle_soldier_id
    end
    self._curGeneralInfo = evt.data
    if self:isVisible() then
        self._isChangeInfo = false
        self:updateBaseInfo()
        self:_updateChangeDialog()
    else
        self._isChangeInfo = true
    end
    local red = uq.cache.generals:isCanAdvance(self._curGeneralInfo.id)
    uq.showRedStatus(self._btnAdvanced, red, self._btnAdvanced:getContentSize().width / 2 - 10, self._btnAdvanced:getContentSize().height / 2 - 10)
end

function GeneralsArms:updateBaseInfo()
    local soldier_xml1 = StaticData['soldier'][self._curGeneralInfo.soldierId1]
    if not soldier_xml1 then
        uq.log("error GeneralsArms updateBaseInfo  soldier_xml1")
        return
    end
    local type_solider1 = StaticData['types'].Soldier[1].Type[soldier_xml1.type]
    self._armsTypeLabel1:setString(type_solider1.name)
    self._imgSoldierType1:loadTexture("img/generals/" .. type_solider1.normalTab)
    local soldier_xml2 = StaticData['soldier'][self._curGeneralInfo.soldierId2]
    if not soldier_xml2 then
        uq.log("error GeneralsArms updateBaseInfo  soldier_xml2")
        return
    end
    local type_solider2 = StaticData['types'].Soldier[1].Type[soldier_xml2.type]
    self._armsTypeLabel2:setString(type_solider2.name)
    self._imgSoldierType2:loadTexture("img/generals/" .. type_solider2.normalTab)
    local info = self._curGeneralInfo.battle_soldier_id
    self._armsItem1:setInfo(info)
    if self._playAttack then
        self._armsItem1:playAttackAction(true)
        self._playAttack = false
    end
    self._armsInfoItem:setData(self._curGeneralInfo.battle_soldier_id)

    self:filterInfo()
    self._tableView:reloadData()
    self._tableView1:reloadData()
end

function GeneralsArms:_updateChangeDialog()
    if self._curGeneralInfo.soldierId1 == self._curGeneralInfo.battle_soldier_id then
        self._armsTypeLabel1:setTextColor(uq.parseColor("#2CED12"))
        self._armsTypeLabel2:setTextColor(uq.parseColor("#FFFFFF"))
    else
        self._armsTypeLabel2:setTextColor(uq.parseColor("#2CED12"))
        self._armsTypeLabel1:setTextColor(uq.parseColor("#FFFFFF"))
    end
end

function GeneralsArms:dispose()
    self._armsItem1:dispose()
    services:removeEventListenersByTag("_onUpdateDialog")
    services:removeEventListenersByTag("_onInitDialogByArms")
    services:removeEventListenersByTag("_onChangeBattleSoldier" .. tostring(self))
    GeneralsArms.super.dispose(self)
end

return GeneralsArms