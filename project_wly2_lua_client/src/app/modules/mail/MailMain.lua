local MailMain = class("MailMain", require('app.modules.common.BaseViewWithHead'))

MailMain.RESOURCE_FILENAME = "mail/MailMain.csb"
MailMain.RESOURCE_BINDING = {
    ["Node_3"]           = {["varname"] = "_node"},
    ["Node_2"]           = {["varname"] = "_nodeNone"},
    ["Node_1"]           = {["varname"] = "_nodeMailList"},
    ["Node_1/Panel_1"]   = {["varname"] = "_panelList"},
    ["Button_1"]         = {["varname"] = "_btnDelete",["events"] = {{["event"] = "touch",["method"] = "onDelete",["sound_id"] = 0}}},
    ["Button_2"]         = {["varname"] = "_btnDelete",["events"] = {{["event"] = "touch",["method"] = "onReadAll"}}},
    ["CheckBox_1"]       = {["varname"] = "_checkboxSelect"},
    ["Node_tab"]         = {["varname"] = "_nodeMenu"},
    ["Text_16"]          = {["varname"] = "_txtState"},
    ["node_left_middle"] = {["varname"] = "_nodeLeftMiddle"},
}

MailMain._MailHeadName = {
    StaticData['local_text']['mail.type.game'],
    StaticData['local_text']['label.crop'],
}

function MailMain:ctor(name, params)
    MailMain.super.ctor(self, name, params)

    self._curMailType = uq.cache.mail._MailType.MAIL_SYSTEM
    self._allUi = {}
    self._curMailData = {}
    self._curIndex = 0
end

function MailMain:showMenuRed()
    local red_array = uq.cache.mail._mailRed
    for k, v in ipairs(self._tabArray) do
        local red = red_array[k] ~= nil
        uq.showRedStatus(v, red, -v:getContentSize().width / 2 + 10, v:getContentSize().height / 2 - 10)
    end
end

function MailMain:init()
    self:addShowCoinGroup({uq.config.constant.COST_RES_TYPE.GESTE, uq.config.constant.COST_RES_TYPE.MONEY, uq.config.constant.COST_RES_TYPE.GOLDEN})
    self:setTitle(uq.config.constant.MODULE_ID.MAIL_MAIN)
    self:centerView()
    self:parseView()
    self:adaptBgSize()

    self:initMailList()
    self:addTab()
    self:adaptNode()

    self._checkboxSelect:addEventListener(handler(self, self.onCheckSelected))
    self._refreshTag = "_onTabRefresh" .. tostring(self)
    self:showMenuRed()
    services:addEventListener(services.EVENT_NAMES.ON_MAIN_REWARD_GET_REFRESH, handler(self, self.refreshPage), self._refreshTag)
    services:addEventListener(services.EVENT_NAMES.ON_MAIL_MAIN_RED, handler(self, self.showMenuRed), "update_red" .. tostring(self))
end

function MailMain:addTab()
    self._tabArray = {}
    local tab_item = self._nodeMenu:getChildByName("Panel_1")
    local posx, posy = tab_item:getPosition()
    tab_item:removeSelf()
    for k = 1, #self._MailHeadName do
        local item = tab_item:clone()
        self._nodeMenu:addChild(item)
        item:setTag(k)
        item:getChildByName("txt"):setString(self._MailHeadName[k])
        item:setPosition(posx, posy)
        item:setTouchEnabled(true)
        item:addClickEventListener(handler(k, function(tag, sender)
            uq.playSoundByID(uq.config.constant.COMMON_SOUND.CHANGE)
            if self._curMailType == tag then
                return
            end
            self:onMailType(tag, sender)
        end))

        table.insert(self._tabArray, item)
        if k == self._curMailType then
            self:onMailType(k, item, true)
        end
        posy = posy - item:getContentSize().height - 5
    end
end

function MailMain:initMailList()
    local viewSize = self._panelList:getContentSize()
    self._listView = cc.TableView:create(cc.size(viewSize.width, viewSize.height))
    self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listView:setPosition(cc.p(0, 0))
    self._listView:setAnchorPoint(cc.p(0,0))
    self._listView:setDelegate()
    self._listView:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._listView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._listView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._panelList:addChild(self._listView)
end

function MailMain:refreshMailButton(sender, stop_action)
    for k, v in ipairs(self._tabArray) do
        v:getChildByName("img_select1"):setVisible(false)
        v:getChildByName("img_select2"):setVisible(false)
    end
    local img1 = sender:getChildByName("img_select1")
    local img2 = sender:getChildByName("img_select2")
    img1:setVisible(true)
    img2:setVisible(true)
    if not stop_action then
        img1:runAction(cc.RotateBy:create(0.15, -180))
        img2:runAction(cc.RotateBy:create(0.15, 180))
    end
end

function MailMain:getMapType()
    return self._curMailType == uq.cache.mail._MailType.MAIL_ARMY
end

function MailMain:switchMail()
    self._curMailData = uq.cache.mail:getMailListByType(self:getMapType())

    if #self._curMailData > 1 then
        table.sort(self._curMailData, function(item1, item2)
            if item1.state ~= item2.state then
                return item1.state < item2.state
            elseif item1.create_time ~= item2.create_time then
                return item1.create_time > item2.create_time
            end
            return item1.reward_len > item2.reward_len
        end)
    end

    self._curIndex = 0

    if self:numberOfCellsInTableView() == 0 then
        self._nodeNone:setVisible(true)
        self._nodeMailList:setVisible(false)
    else
        self._nodeNone:setVisible(false)
        self._nodeMailList:setVisible(true)
        self._listView:reloadData()
    end

    self._checkboxSelect:setSelected(false)
    self:setAllMailSelect(false)
end

function MailMain:refreshPage()
    self:switchMail()
    self:getReadNum()
end

function MailMain:getReadNum()
    local num = 0
    for k, v in ipairs(self._curMailData) do
        if v.state == uq.config.constant.TYPE_MAIL_CELL_STATE.NEW then
            num = num + 1
        end
    end
    self._txtState:setString(string.format(StaticData['local_text']['mail.now.state'] , num, #self._curMailData))
end

function MailMain:onMailType(tag, sender, stop_action)
    self._curMailType = tag
    self:refreshMailButton(sender, stop_action)
    self:switchMail()
    self:getReadNum()
    self:showAction()
end

function MailMain:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
    local cell_item = cell:getChildByName("item")

    self._curIndex = index

    if uq.cache.mail:getMailInfoByID(self._curMailData[index].id) then
        local panel = uq.ModuleManager:getInstance():show(uq.ModuleManager.MAIL_INFO, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
        panel:setData(uq.cache.mail:getMailInfoByID(self._curMailData[index].id))
    end
end

function MailMain:cellSizeForTable(view, idx)
    return 1000, 115
end

function MailMain:numberOfCellsInTableView(view)
    return #self._curMailData
end

function MailMain:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local item = nil

    if not cell then
        cell = cc.TableViewCell:new()
        item = uq.createPanelOnly("mail.MailCell")
        item:setName("item")
        local size = item:getContentSize()
        item:setPosition(cc.p(size.width / 2, size.height / 2 - 10))
        cell:addChild(item)
        table.insert(self._allUi, item)
    else
        item = cell:getChildByName("item")
    end

    item:setData(self._curMailData[index], index)
    item:setCallback(handler(self, self.cellCallback))

    return cell
end

function MailMain:cellCallback(index, flag)
    self._curMailData[index].is_checked = flag
end

--删除邮件
function MailMain:onDelete(event)
    if event.name ~= "ended" then
        return
    end
    uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON_TWO)
    local function confirm()
        local mail_id = {}
        for k, item in ipairs(self._curMailData) do
            if item.is_checked == true and item.state ~= 0 then
                table.insert(mail_id,item.id)
            end
        end

        if #mail_id ~= 0 then
            network:sendPacket(Protocol.C_2_S_MAIL_DELETE, {count = #mail_id,mail_id = mail_id})
        end
    end
    local des = StaticData['local_text']['mail.delete.all']
    local data = {
        content = des,
        confirm_callback = confirm
    }
    uq.addConfirmBox(data)
end

function MailMain:onReadAll(event)
    if event.name ~= "ended" then
        return
    end
    network:sendPacket(Protocol.C_2_S_MAIL_REWARD, {mail_id = -1})
end

function MailMain:onCheckSelected(sender, eventType)
    if eventType == ccui.CheckBoxEventType.selected then
        self:setAllMailSelect(true)
    elseif eventType == ccui.CheckBoxEventType.unselected then
        self:setAllMailSelect(false)
    end
end

function MailMain:dispose()
    services:removeEventListenersByTag(self._refreshTag)
    services:removeEventListenersByTag('update_red' .. tostring(self))
    MailMain.super.dispose(self)
end

function MailMain:setAllMailSelect(flag)
    for i = 1, self:numberOfCellsInTableView() do
        local cell_tb = self._listView:cellAtIndex(i - 1)
        if cell_tb then
            local cell_item = cell_tb:getChildByName("item")
            cell_item:setCheckBox(flag)
        end
    end
    for k, item in ipairs(self._curMailData) do
        item.is_checked = flag
    end
end

function MailMain:showAction()
    for k, v in pairs(self._allUi) do
        v:showAction()
    end
end

return MailMain