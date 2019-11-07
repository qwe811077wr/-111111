local DailyActivityModule = class("DailyActivityModule", require("app.base.PopupTabView"))
local DailyActivityItem = require("app.modules.daily_activity.DailyActivityItem")

DailyActivityModule.RESOURCE_FILENAME = "daily_activity/DailyActivityMain.csb"

DailyActivityModule.RESOURCE_BINDING  = {
    ["Panel_1/Panel_item"]                              ={["varname"] = "_panelTableView"},
    ["Panel_1/Image_left"]                              ={["varname"] = "_imgLeft"},
    ["Panel_1/Image_right"]                             ={["varname"] = "_imgRight"},
}

DailyActivityModule.CENTER_POS = cc.p(615, 305)

function DailyActivityModule:ctor(name, args)
    DailyActivityModule.super.ctor(self, name, args)
    self._curTabInfo = {}
end

function DailyActivityModule:init()
    local top_ui = uq.ui.CommonHeaderUI:create()
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.MONEY,  true))
    top_ui:addResItem(uq.ui.ResourceBox.createRes(uq.config.constant.COST_RES_TYPE.GOLDEN,  true))
    top_ui:setTitle(uq.config.constant.MODULE_ID.DAILY)

    self._topUI = top_ui
    self._view:addChild(top_ui:getNode())
    self:parseView()
    self:centerView()
    self:initData()
    self:initDialog()
    self:adaptBgSize()
end

function DailyActivityModule:initData()
    for k, v in ipairs(StaticData['daily']) do
        table.insert(self._curTabInfo, v)
    end
    table.sort(self._curTabInfo, function(a, b)
        return a.ident < b.ident
    end)
end

function DailyActivityModule:initDialog()
    self._imgLeft:setTouchEnabled(true)
    self._imgLeft:addClickEventListener(function(sender)
        local offset = self._tableView1:getContentOffset();
        offset.x = offset.x + 350
        if offset.x > 0 then
            offset.x = 0
        end
        self._tableView1:setContentOffset(offset);
    end)
    self._imgRight:setTouchEnabled(true)
    self._imgRight:addClickEventListener(function(sender)
        local offset = self._tableView1:getContentOffset();
        offset.x = offset.x - 350
        if offset.x < 1105 - 350 * #self._curTabInfo then
            offset.x = 1105 - 350 * #self._curTabInfo
        end
        self._tableView1:setContentOffset(offset);
    end)
    self:initTableView()
    self._tableView1:reloadData()
end

function DailyActivityModule:initTableView()
    local size = self._panelTableView:getContentSize()
    self._tableView1 = cc.TableView:create(cc.size(size.width,size.height))
    self._tableView1:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self._tableView1:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView1:setPosition(cc.p(0, 0))
    self._tableView1:setAnchorPoint(cc.p(0,0))
    self._tableView1:setDelegate()
    self._panelTableView:addChild(self._tableView1)

    self._tableView1:registerScriptHandler(handler(self,self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self._tableView1:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView1:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView1:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
end

function DailyActivityModule:cellSizeForTable(view, idx)
    return 350, 580
end

function DailyActivityModule:numberOfCellsInTableView(view)
    return #self._curTabInfo
end

function DailyActivityModule:tableCellTouched(view, cell, touch)
    local index = cell:getIdx() + 1
    local info = self._curTabInfo[index]
    if info ~= nil then
        local module_info = StaticData['module'][tonumber(info.moduleId)]
        if module_info == nil then
            uq.fadeInfo(info.Content)
            return
        end
        if tonumber(module_info.openLevel) > uq.cache.role:level() then
            uq.fadeInfo(string.format(StaticData["local_text"]["label.open.lv"], module_info.openLevel))
            return
        end
        uq.playSoundByID(uq.config.constant.COMMON_SOUND.BUTTON)
        uq.jumpToModule(tonumber(info.moduleId))
    end
end

function DailyActivityModule:tableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local index = idx + 1
    local euqip_item = nil
    if not cell then
        cell = cc.TableViewCell:new()
        euqip_item = DailyActivityItem:create()
        local width = euqip_item:getContentSize().width
        euqip_item:setPosition(cc.p(width * 0.5, 290))
        cell:addChild(euqip_item)
        euqip_item:setName("item")
    else
        euqip_item = cell:getChildByName("item")
    end
    local info = self._curTabInfo[index]
    if info ~= nil and euqip_item ~= nil then
        euqip_item:setInfo(info)
    end
    return cell
end

function DailyActivityModule:dispose()
    if self._topUI then
        self._topUI:dispose()
    end
    DailyActivityModule.super.dispose(self)
end

return DailyActivityModule
