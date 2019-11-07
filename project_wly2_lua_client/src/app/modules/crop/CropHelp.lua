local  CropHelp = class("CropHelp", require('app.base.PopupBase'))
CropHelp.RESOURCE_FILENAME = "crop/CropHelp.csb"
CropHelp.RESOURCE_BINDING = {
    ["Button_16"]    = {["varname"] = "_btnHelpHelpList",["events"] = {{["event"] = "touch",["method"] = "onHelpList"}}},
    ["Panel_1"]      = {["varname"] = "_panelBg"},
    ["Button_1"]     = {["varname"] = "_btnClose",["events"] = {{["event"] = "touch",["method"] = "onClosePanel"}}},
    ["Text_33"]      = {["varname"] = "_txtName"},
    ["Text_35"]      = {["varname"] = "_txtMoney"},
    ["Text_36_0"]    = {["varname"] = "_txtMoneyOnce"},
    ["LoadingBar_6"] = {["varname"] = "_barMoney"},
    ["Button_8"]     = {["varname"] = "_btnHelpOneKey",["events"] = {{["event"] = "touch",["method"] = "onHelpOneKey"}}},
}

function CropHelp:onCreate()
    CropHelp.super.onCreate(self)
    self:centerView()
    self:parseView()
    self:setLayerColor(0.4)

    self._dataList = {}
    self:createList()
    self:refreshPage()

    self._eventCropRefresh = services.EVENT_NAMES.ON_CROP_REFRESH .. tostring(self)
    services:addEventListener(services.EVENT_NAMES.ON_CROP_REFRESH, handler(self, self.refreshPage), self._eventCropRefresh)
end

function CropHelp:refreshPage()
    local crop_data = uq.cache.crop:getCropDataById(uq.cache.role.cropsId)
    self._txtName:setString(crop_data.name)

    local xml_data = StaticData['crop_help']
    local moneys = string.split(xml_data.rewards, ';')
    local money_onces = string.split(xml_data.gains, ';')
    local total_money = uq.cache.crop:getCropHelpReward()
    self._txtMoney:setString(total_money .. ' / ' .. moneys[2])
    self._txtMoneyOnce:setString(money_onces[2])
    self._barMoney:setPercent(total_money / tonumber(moneys[2]) * 100)
    self:reloadPage()
end

function CropHelp:reloadPage()
    self._dataList = uq.cache.crop:getHelpDataList()
    self._listView:reloadData()
end

function CropHelp:onExit()
    services:removeEventListenersByTag(self._eventCropRefresh)
    CropHelp.super:onExit()
end

function CropHelp:onHelpList(event)
    if event.name == "ended" then
        uq.ModuleManager:getInstance():show(uq.ModuleManager.CROP_HELP_LIST, {moduleType = uq.ModuleManager.SHOW_TYPE_REPLACE})
    end
end

function CropHelp:createList()
    local viewSize = self._panelBg:getContentSize()
    self._listView = cc.TableView:create(cc.size(viewSize.width, viewSize.height))
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

function CropHelp:tableCellTouched(view, cell)
    local index = cell:getIdx() + 1
end

function CropHelp:cellSizeForTable(view, idx)
    return 965, 75
end

function CropHelp:numberOfCellsInTableView(view)
    return #self._dataList
end

function CropHelp:tableCellAtIndex(view, idx)
    local index = idx + 1
    local cell = view:dequeueCell()
    local cell_item = nil

    if not cell then
        cell = cc.TableViewCell:new();
        --创建列表项
        cell_item = uq.createPanelOnly("crop.CropHelpItem")
        cell_item:setTag(1000)
        cell:addChild(cell_item)
    else
        cell_item = cell:getChildByTag(1000)
    end
    cell_item:setData(self._dataList[index])

    local width, height = self:cellSizeForTable(view, idx)
    cell_item:setPosition(cc.p(width / 2, height / 2))

    return cell
end

function CropHelp:onClosePanel(event)
    if event.name == "ended" then
        self:disposeSelf()
    end
end

function CropHelp:onHelpOneKey(event)
    if event.name ~= "ended" then
        return
    end

    for k, item in ipairs(self._dataList) do
        local cell = self._listView:cellAtIndex(k - 1)
        if cell then
            local cell_item = cell:getChildByTag(1000)
            cell_item:oneKeyHelp()
        end
    end
end

return CropHelp