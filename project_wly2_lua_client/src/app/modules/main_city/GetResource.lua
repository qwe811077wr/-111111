local GetResource = class("BuyGeste", require('app.base.PopupBase'))

GetResource.RESOURCE_FILENAME = "main_city/GetResource.csb"
GetResource.RESOURCE_BINDING = {
    ["Panel_1"]      = {["varname"] = "_panelBg"},
    ["image_icon"]   = {["varname"] = "_imageIcon"},
    ["text_name"]    = {["varname"] = "_txtName"},
    ["text_num"]     = {["varname"] = "_txtNum"},
    ["text_desc"]    = {["varname"] = "_txtDesc"},
    ["close_btn"]    = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onBtnClose",["sound_id"] = 0}}},
}

function GetResource:ctor(name, params)
    GetResource.super.ctor(self, name, params)
    self._resType = params.type
end

function GetResource:init()
    self:centerView()
    self:parseView()
    self:refreshPage()
    self:createList()

    self._eventName = services.EVENT_NAMES.ON_CONSUME_RES_CHANGE .. self._resType
    self._eventTag = self._eventName .. tostring(self)
    services:addEventListener(self._eventName, handler(self, self.refreshPage), self._eventTag)
end

function GetResource:onExit()
    services:removeEventListenersByTag(self._eventTag)
    GetResource.super.onExit(self)
end

function GetResource:refreshPage()
    self._itemConfig = StaticData['types'].Cost[1].Type[self._resType]
    self._getPath = string.split(self._itemConfig.jumpId, ',')
    self._imageIcon:loadTexture('img/common/item/' .. self._itemConfig.icon)
    self._txtName:setString(self._itemConfig.name)

    local num = uq.cache.role:getResNum(self._resType)
    self._txtNum:setString(num)
    self._txtDesc:setString(self._itemConfig.desc)
end

function GetResource:createList()
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

function GetResource:tableCellTouched(view, cell)
end

function GetResource:cellSizeForTable(view, idx)
    return 1040, 150
end

function GetResource:numberOfCellsInTableView(view)
    return #self._getPath
end

function GetResource:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cellItem = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cellItem = uq.createPanelOnly("main_city.GetResourceItem")
        cell:addChild(cellItem)
    else
        cellItem = cell:getChildByTag(1000)
    end

    cellItem:setTag(1000)
    cellItem:setIndex(index)
    cellItem:setData(self._getPath[index], handler(self, self.onBtnClose))

    local width, height = self:cellSizeForTable(view, idx)
    cellItem:setPosition(cc.p(width / 2, height / 2))

    return cell
end

function GetResource:onBtnClose(event)
    if event.name == "ended" then
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BACK)
        self:disposeSelf()
    end
end


return GetResource